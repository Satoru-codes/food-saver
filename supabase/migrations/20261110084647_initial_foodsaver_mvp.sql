-- FoodSaver MVP: household, pantry, permissions, invitations, and inventory ledger.
-- Target: the FoodSaver-dev Supabase project only.
-- Internal SECURITY DEFINER routines live in the unexposed private schema.
-- Never place database passwords or Supabase secret/service-role keys in this file.

begin;

create extension if not exists pgcrypto with schema extensions;

-- ---------------------------------------------------------------------------
-- Private schema and least-privilege defaults
-- ---------------------------------------------------------------------------

create schema if not exists private;
revoke all on schema private from public, anon, authenticated;
grant usage on schema private to authenticated;

-- Current Supabase projects may have different Data API default-grant settings.
-- Make this schema's future public objects opt-in rather than automatically exposed.
alter default privileges for role postgres in schema public
  revoke all on tables from anon, authenticated, service_role;
alter default privileges for role postgres in schema public
  revoke execute on functions from public, anon, authenticated, service_role;
alter default privileges for role postgres in schema public
  revoke usage, select on sequences from anon, authenticated, service_role;

-- ---------------------------------------------------------------------------
-- Profiles and household membership
-- ---------------------------------------------------------------------------

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default '',
  preferred_language text not null default 'en'
    check (preferred_language in ('en', 'hi')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.households (
  id uuid primary key default gen_random_uuid(),
  name text not null check (length(trim(name)) between 1 and 80),
  owner_user_id uuid not null references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.household_members (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'member'
    check (role in ('owner', 'admin', 'member')),
  can_manage_inventory boolean not null default false,
  can_log_own_consumption boolean not null default false,
  can_log_others_consumption boolean not null default false,
  can_record_waste boolean not null default false,
  can_view_household_analytics boolean not null default false,
  can_manage_members boolean not null default false,
  joined_at timestamptz not null default now(),
  unique (household_id, user_id),
  unique (id, household_id)
);

create unique index household_members_one_owner_idx
  on public.household_members(household_id)
  where role = 'owner';

create index household_members_user_idx
  on public.household_members(user_id, household_id);

-- Invitations store only a SHA-256 token hash, never the raw invitation token.
create table public.household_invitations (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  email text not null check (email = lower(trim(email))),
  token_hash text not null unique
    check (token_hash ~ '^[0-9a-f]{64}$'),
  invited_by uuid not null references auth.users(id),
  expires_at timestamptz not null default (now() + interval '7 days'),
  accepted_at timestamptz,
  accepted_by uuid references auth.users(id),
  revoked_at timestamptz,
  created_at timestamptz not null default now()
);

create index household_invitations_household_idx
  on public.household_invitations(household_id, created_at desc);

-- ---------------------------------------------------------------------------
-- Food categories, storage locations, and pantry
-- ---------------------------------------------------------------------------

create table public.food_categories (
  key text primary key,
  label_en text not null,
  label_hi text not null,
  sort_order integer not null default 0
);

insert into public.food_categories (key, label_en, label_hi, sort_order)
values
  ('dairy', 'Dairy products', 'डेयरी उत्पाद', 1),
  ('vegetables', 'Vegetables', 'सब्ज़ियाँ', 2),
  ('fruits', 'Fruits', 'फल', 3),
  ('grains', 'Grains and staples', 'अनाज और आवश्यक खाद्य', 4),
  ('meat', 'Meat and seafood', 'मांस और समुद्री भोजन', 5),
  ('drinks', 'Drinks', 'पेय पदार्थ', 6),
  ('other', 'Other', 'अन्य', 7)
on conflict (key) do update
set label_en = excluded.label_en,
    label_hi = excluded.label_hi,
    sort_order = excluded.sort_order;

create table public.storage_locations (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  name text not null check (length(trim(name)) between 1 and 60),
  is_active boolean not null default true,
  sort_order integer not null default 0,
  created_by uuid not null default auth.uid() references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id, household_id)
);

create index storage_locations_household_idx
  on public.storage_locations(household_id, sort_order);

create table public.pantry_items (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  name text not null check (length(trim(name)) between 1 and 100),
  category_key text not null references public.food_categories(key),
  storage_location_id uuid,
  quantity_base numeric(14,3) not null default 0 check (quantity_base >= 0),
  base_unit text not null
    check (base_unit in ('g', 'ml', 'pcs', 'pack', 'unit')),
  display_unit text not null
    check (display_unit in ('g', 'kg', 'ml', 'L', 'pcs', 'pack', 'unit')),
  expiry_date date,
  alert_days_before integer not null default 1
    check (alert_days_before between 0 and 30),
  notes text,
  created_by uuid not null default auth.uid() references auth.users(id),
  updated_by uuid references auth.users(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  archived_at timestamptz,
  unique (id, household_id),
  foreign key (storage_location_id, household_id)
    references public.storage_locations(id, household_id),
  check (
    (base_unit = 'g' and display_unit in ('g', 'kg')) or
    (base_unit = 'ml' and display_unit in ('ml', 'L')) or
    (base_unit = 'pcs' and display_unit = 'pcs') or
    (base_unit = 'pack' and display_unit = 'pack') or
    (base_unit = 'unit' and display_unit = 'unit')
  )
);

create index pantry_items_household_active_idx
  on public.pantry_items(household_id, archived_at, name);

create index pantry_items_category_idx
  on public.pantry_items(household_id, category_key)
  where archived_at is null;

-- ---------------------------------------------------------------------------
-- Append-only inventory ledger
-- quantity_delta is expressed in the pantry item's base unit.
-- ---------------------------------------------------------------------------

create table public.inventory_movements (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  pantry_item_id uuid not null,
  movement_type text not null
    check (movement_type in ('addition', 'consumption', 'waste', 'adjustment', 'reversal')),
  quantity_delta numeric(14,3) not null check (quantity_delta <> 0),
  base_unit text not null
    check (base_unit in ('g', 'ml', 'pcs', 'pack', 'unit')),
  actor_user_id uuid not null references auth.users(id),
  consumed_by_user_id uuid references auth.users(id),
  reason text check (reason in ('expired', 'spoiled', 'over_prepared', 'other')),
  reversal_of_id uuid unique references public.inventory_movements(id),
  created_at timestamptz not null default now(),
  foreign key (pantry_item_id, household_id)
    references public.pantry_items(id, household_id) on delete restrict,
  check (
    (movement_type = 'addition' and quantity_delta > 0) or
    (movement_type in ('consumption', 'waste') and quantity_delta < 0) or
    movement_type in ('adjustment', 'reversal')
  ),
  check (movement_type = 'consumption' or consumed_by_user_id is null),
  check (movement_type = 'waste' or reason is null),
  check (
    (movement_type = 'reversal' and reversal_of_id is not null) or
    (movement_type <> 'reversal' and reversal_of_id is null)
  )
);

create index inventory_movements_household_time_idx
  on public.inventory_movements(household_id, created_at desc);

create index inventory_movements_item_time_idx
  on public.inventory_movements(pantry_item_id, created_at desc);

-- ---------------------------------------------------------------------------
-- Internal timestamp and profile triggers
-- ---------------------------------------------------------------------------

create or replace function private.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $fn$
begin
  new.updated_at := pg_catalog.now();
  return new;
end;
$fn$;

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function private.set_updated_at();

create trigger households_set_updated_at
  before update on public.households
  for each row execute function private.set_updated_at();

create trigger storage_locations_set_updated_at
  before update on public.storage_locations
  for each row execute function private.set_updated_at();

create trigger pantry_items_set_updated_at
  before update on public.pantry_items
  for each row execute function private.set_updated_at();

create or replace function private.stamp_pantry_item_editor()
returns trigger
language plpgsql
set search_path = ''
as $fn$
begin
  new.updated_by := auth.uid();
  return new;
end;
$fn$;

create trigger pantry_items_stamp_editor
  before update on public.pantry_items
  for each row execute function private.stamp_pantry_item_editor();

create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $fn$
begin
  insert into public.profiles (id, display_name, preferred_language)
  values (
    new.id,
    coalesce(
      nullif(pg_catalog.btrim(new.raw_user_meta_data ->> 'full_name'), ''),
      nullif(pg_catalog.btrim(new.raw_user_meta_data ->> 'name'), ''),
      pg_catalog.split_part(coalesce(new.email, ''), '@', 1)
    ),
    case
      when new.raw_user_meta_data ->> 'preferred_language' = 'hi' then 'hi'
      else 'en'
    end
  )
  on conflict (id) do nothing;

  return new;
end;
$fn$;

create trigger on_auth_user_created_foodsaver
  after insert on auth.users
  for each row execute function private.handle_new_user();

-- The initial pantry quantity is recorded as an addition.
create or replace function private.log_initial_pantry_stock()
returns trigger
language plpgsql
security definer
set search_path = ''
as $fn$
begin
  if new.quantity_base > 0 then
    insert into public.inventory_movements (
      household_id, pantry_item_id, movement_type, quantity_delta,
      base_unit, actor_user_id
    )
    values (
      new.household_id, new.id, 'addition', new.quantity_base,
      new.base_unit, coalesce(new.created_by, auth.uid())
    );
  end if;
  return new;
end;
$fn$;

create trigger pantry_items_log_initial_stock
  after insert on public.pantry_items
  for each row execute function private.log_initial_pantry_stock();

-- ---------------------------------------------------------------------------
-- Internal authorization helpers used by RLS and controlled RPC routines
-- ---------------------------------------------------------------------------

create or replace function private.is_household_member(p_household_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $fn$
  select exists (
    select 1
    from public.household_members hm
    where hm.household_id = p_household_id
      and hm.user_id = auth.uid()
  );
$fn$;

create or replace function private.is_household_owner(p_household_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $fn$
  select exists (
    select 1
    from public.households h
    where h.id = p_household_id
      and h.owner_user_id = auth.uid()
  );
$fn$;

create or replace function private.has_household_permission(
  p_household_id uuid,
  p_permission text
)
returns boolean
language sql
stable
security definer
set search_path = ''
as $fn$
  select
    private.is_household_owner(p_household_id)
    or exists (
      select 1
      from public.household_members hm
      where hm.household_id = p_household_id
        and hm.user_id = auth.uid()
        and (
          hm.role = 'owner'
          or case p_permission
            when 'manage_inventory' then hm.can_manage_inventory
            when 'log_own_consumption' then hm.can_log_own_consumption
            when 'log_others_consumption' then hm.can_log_others_consumption
            when 'record_waste' then hm.can_record_waste
            when 'view_household_analytics' then hm.can_view_household_analytics
            when 'manage_members' then hm.can_manage_members
            else false
          end
        )
    );
$fn$;

-- ---------------------------------------------------------------------------
-- Internal household creation and member administration
-- ---------------------------------------------------------------------------

create or replace function private.create_household_impl(p_name text)
returns uuid
language plpgsql
security definer
set search_path = ''
as $fn$
declare
  v_user_id uuid := auth.uid();
  v_household_id uuid;
begin
  if v_user_id is null then
    raise exception 'You must be signed in to create a household.';
  end if;

  if p_name is null or pg_catalog.length(pg_catalog.btrim(p_name)) not between 1 and 80 then
    raise exception 'Household name must be between 1 and 80 characters.';
  end if;

  insert into public.households (name, owner_user_id)
  values (pg_catalog.btrim(p_name), v_user_id)
  returning id into v_household_id;

  insert into public.household_members (
    household_id, user_id, role,
    can_manage_inventory, can_log_own_consumption,
    can_log_others_consumption, can_record_waste,
    can_view_household_analytics, can_manage_members
  )
  values (
    v_household_id, v_user_id, 'owner',
    true, true, true, true, true, true
  );

  return v_household_id;
end;
$fn$;

create or replace function private.update_household_member_permissions_impl(
  p_member_id uuid,
  p_role text default null,
  p_can_manage_inventory boolean default null,
  p_can_log_own_consumption boolean default null,
  p_can_log_others_consumption boolean default null,
  p_can_record_waste boolean default null,
  p_can_view_household_analytics boolean default null,
  p_can_manage_members boolean default null
)
returns void
language plpgsql
security definer
set search_path = ''
as $fn$
declare
  v_actor uuid := auth.uid();
  v_target public.household_members%rowtype;
  v_owner_user_id uuid;
  v_new_role text;
  v_is_owner boolean;
begin
  if v_actor is null then
    raise exception 'You must be signed in.';
  end if;

  select hm.* into v_target
  from public.household_members hm
  where hm.id = p_member_id
  for update;

  if not found then
    raise exception 'Household member was not found.';
  end if;

  select h.owner_user_id into v_owner_user_id
  from public.households h
  where h.id = v_target.household_id;

  v_is_owner := v_owner_user_id = v_actor;

  if not v_is_owner
     and not private.has_household_permission(v_target.household_id, 'manage_members') then
    raise exception 'You do not have permission to manage household members.';
  end if;

  if v_target.user_id = v_actor then
    raise exception 'You cannot change your own household role or permissions.';
  end if;

  if v_target.role = 'owner' then
    raise exception 'The household Owner cannot be changed here.';
  end if;

  if not v_is_owner and v_target.role = 'admin' then
    raise exception 'Only the household Owner can change an existing Admin.';
  end if;

  if p_role is not null and p_role not in ('admin', 'member') then
    raise exception 'Role must be admin or member. Ownership transfer is separate.';
  end if;

  v_new_role := coalesce(p_role, v_target.role);

  update public.household_members
  set role = v_new_role,
      can_manage_inventory = coalesce(
        p_can_manage_inventory,
        case when v_new_role <> v_target.role then v_new_role = 'admin'
             else v_target.can_manage_inventory end
      ),
      can_log_own_consumption = coalesce(
        p_can_log_own_consumption,
        case when v_new_role <> v_target.role then v_new_role = 'admin'
             else v_target.can_log_own_consumption end
      ),
      can_log_others_consumption = coalesce(
        p_can_log_others_consumption,
        case when v_new_role <> v_target.role then v_new_role = 'admin'
             else v_target.can_log_others_consumption end
      ),
      can_record_waste = coalesce(
        p_can_record_waste,
        case when v_new_role <> v_target.role then v_new_role = 'admin'
             else v_target.can_record_waste end
      ),
      can_view_household_analytics = coalesce(
        p_can_view_household_analytics,
        case when v_new_role <> v_target.role then v_new_role = 'admin'
             else v_target.can_view_household_analytics end
      ),
      can_manage_members = coalesce(
        p_can_manage_members,
        case when v_new_role <> v_target.role then v_new_role = 'admin'
             else v_target.can_manage_members end
      )
  where id = p_member_id;
end;
$fn$;

create or replace function private.create_household_invitation_impl(
  p_household_id uuid,
  p_email text,
  p_token_hash text
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $fn$
declare
  v_actor uuid := auth.uid();
  v_invitation_id uuid;
  v_email text := pg_catalog.lower(pg_catalog.btrim(coalesce(p_email, '')));
begin
  if v_actor is null then
    raise exception 'You must be signed in.';
  end if;
  if not private.has_household_permission(p_household_id, 'manage_members') then
    raise exception 'You do not have permission to invite household members.';
  end if;
  if v_email = '' or v_email !~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$' then
    raise exception 'Enter a valid email address.';
  end if;
  if p_token_hash is null or p_token_hash !~ '^[0-9a-f]{64}$' then
    raise exception 'Invitation token hash must be a 64-character SHA-256 hex string.';
  end if;
  if exists (
    select 1
    from public.household_members hm
    join auth.users u on u.id = hm.user_id
    where hm.household_id = p_household_id
      and pg_catalog.lower(u.email) = v_email
  ) then
    raise exception 'This person is already a member of the household.';
  end if;

  insert into public.household_invitations (
    household_id, email, token_hash, invited_by
  )
  values (p_household_id, v_email, p_token_hash, v_actor)
  returning id into v_invitation_id;

  return v_invitation_id;
end;
$fn$;

create or replace function private.accept_household_invitation_impl(p_token text)
returns uuid
language plpgsql
security definer
set search_path = ''
as $fn$
declare
  v_actor uuid := auth.uid();
  v_email text;
  v_token_hash text;
  v_invitation public.household_invitations%rowtype;
begin
  if v_actor is null then
    raise exception 'Sign in before accepting a household invitation.';
  end if;
  if p_token is null or pg_catalog.length(p_token) < 20 or pg_catalog.length(p_token) > 512 then
    raise exception 'Invalid invitation token.';
  end if;

  select pg_catalog.lower(u.email) into v_email
  from auth.users u
  where u.id = v_actor;

  if v_email is null then
    raise exception 'Your account does not have an email address.';
  end if;

  v_token_hash := pg_catalog.encode(
    extensions.digest(p_token, 'sha256'),
    'hex'
  );

  select * into v_invitation
  from public.household_invitations hi
  where hi.token_hash = v_token_hash
  for update;

  if not found then
    raise exception 'Invitation was not found or is invalid.';
  end if;
  if v_invitation.accepted_at is not null or v_invitation.revoked_at is not null then
    raise exception 'This invitation has already been used or revoked.';
  end if;
  if v_invitation.expires_at <= pg_catalog.now() then
    raise exception 'This invitation has expired.';
  end if;
  if v_invitation.email <> v_email then
    raise exception 'Sign in with the email address to which this invitation was sent.';
  end if;

  insert into public.household_members (household_id, user_id, role)
  values (v_invitation.household_id, v_actor, 'member');

  update public.household_invitations
  set accepted_at = pg_catalog.now(),
      accepted_by = v_actor
  where id = v_invitation.id;

  return v_invitation.household_id;
end;
$fn$;

-- ---------------------------------------------------------------------------
-- Internal inventory operations. Each locks the item row and writes stock
-- plus its ledger entry in one transaction. Clients cannot update stock
-- quantities directly; use these routines instead.
-- ---------------------------------------------------------------------------

create or replace function private.add_inventory_stock_impl(
  p_pantry_item_id uuid,
  p_quantity_base numeric
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $fn$
declare
  v_actor uuid := auth.uid();
  v_item public.pantry_items%rowtype;
  v_movement_id uuid;
begin
  if v_actor is null then
    raise exception 'You must be signed in.';
  end if;
  if p_quantity_base is null or p_quantity_base <= 0 then
    raise exception 'Quantity to add must be greater than zero.';
  end if;

  select * into v_item
  from public.pantry_items
  where id = p_pantry_item_id and archived_at is null
  for update;

  if not found then
    raise exception 'Pantry item was not found.';
  end if;
  if not private.has_household_permission(v_item.household_id, 'manage_inventory') then
    raise exception 'You do not have permission to add inventory.';
  end if;

  update public.pantry_items
  set quantity_base = quantity_base + p_quantity_base,
      updated_by = v_actor
  where id = p_pantry_item_id;

  insert into public.inventory_movements (
    household_id, pantry_item_id, movement_type, quantity_delta,
    base_unit, actor_user_id
  )
  values (
    v_item.household_id, v_item.id, 'addition', p_quantity_base,
    v_item.base_unit, v_actor
  )
  returning id into v_movement_id;

  return v_movement_id;
end;
$fn$;

create or replace function private.adjust_inventory_stock_impl(
  p_pantry_item_id uuid,
  p_quantity_delta_base numeric
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $fn$
declare
  v_actor uuid := auth.uid();
  v_item public.pantry_items%rowtype;
  v_new_quantity numeric(14,3);
  v_movement_id uuid;
begin
  if v_actor is null then
    raise exception 'You must be signed in.';
  end if;
  if p_quantity_delta_base is null or p_quantity_delta_base = 0 then
    raise exception 'Adjustment must be non-zero.';
  end if;

  select * into v_item
  from public.pantry_items
  where id = p_pantry_item_id and archived_at is null
  for update;

  if not found then
    raise exception 'Pantry item was not found.';
  end if;
  if not private.has_household_permission(v_item.household_id, 'manage_inventory') then
    raise exception 'You do not have permission to adjust inventory.';
  end if;

  v_new_quantity := v_item.quantity_base + p_quantity_delta_base;
  if v_new_quantity < 0 then
    raise exception 'Adjustment would make inventory negative.';
  end if;

  update public.pantry_items
  set quantity_base = v_new_quantity,
      updated_by = v_actor
  where id = p_pantry_item_id;

  insert into public.inventory_movements (
    household_id, pantry_item_id, movement_type, quantity_delta,
    base_unit, actor_user_id
  )
  values (
    v_item.household_id, v_item.id, 'adjustment', p_quantity_delta_base,
    v_item.base_unit, v_actor
  )
  returning id into v_movement_id;

  return v_movement_id;
end;
$fn$;

create or replace function private.record_consumption_impl(
  p_pantry_item_id uuid,
  p_quantity_base numeric,
  p_consumed_by_user_id uuid default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $fn$
declare
  v_actor uuid := auth.uid();
  v_item public.pantry_items%rowtype;
  v_movement_id uuid;
begin
  if v_actor is null then
    raise exception 'You must be signed in.';
  end if;
  if p_quantity_base is null or p_quantity_base <= 0 then
    raise exception 'Consumption quantity must be greater than zero.';
  end if;

  select * into v_item
  from public.pantry_items
  where id = p_pantry_item_id and archived_at is null
  for update;

  if not found then
    raise exception 'Pantry item was not found.';
  end if;

  if p_consumed_by_user_id is null then
    if not private.has_household_permission(v_item.household_id, 'log_others_consumption') then
      raise exception 'You do not have permission to record shared household consumption.';
    end if;
  else
    if not exists (
      select 1 from public.household_members hm
      where hm.household_id = v_item.household_id
        and hm.user_id = p_consumed_by_user_id
    ) then
      raise exception 'The selected consumer is not a member of this household.';
    end if;

    if p_consumed_by_user_id = v_actor then
      if not private.has_household_permission(v_item.household_id, 'log_own_consumption') then
        raise exception 'You do not have permission to record your own consumption.';
      end if;
    else
      if not private.has_household_permission(v_item.household_id, 'log_others_consumption') then
        raise exception 'You do not have permission to record another member''s consumption.';
      end if;
    end if;
  end if;

  if p_quantity_base > v_item.quantity_base then
    raise exception 'Consumption exceeds the available inventory.';
  end if;

  update public.pantry_items
  set quantity_base = quantity_base - p_quantity_base,
      updated_by = v_actor
  where id = p_pantry_item_id;

  insert into public.inventory_movements (
    household_id, pantry_item_id, movement_type, quantity_delta,
    base_unit, actor_user_id, consumed_by_user_id
  )
  values (
    v_item.household_id, v_item.id, 'consumption', -p_quantity_base,
    v_item.base_unit, v_actor, p_consumed_by_user_id
  )
  returning id into v_movement_id;

  return v_movement_id;
end;
$fn$;

create or replace function private.record_food_waste_impl(
  p_pantry_item_id uuid,
  p_quantity_base numeric,
  p_reason text default null
)
returns uuid
language plpgsql
security definer
set search_path = ''
as $fn$
declare
  v_actor uuid := auth.uid();
  v_item public.pantry_items%rowtype;
  v_movement_id uuid;
begin
  if v_actor is null then
    raise exception 'You must be signed in.';
  end if;
  if p_quantity_base is null or p_quantity_base <= 0 then
    raise exception 'Waste quantity must be greater than zero.';
  end if;
  if p_reason is not null and p_reason not in ('expired', 'spoiled', 'over_prepared', 'other') then
    raise exception 'Invalid waste reason.';
  end if;

  select * into v_item
  from public.pantry_items
  where id = p_pantry_item_id and archived_at is null
  for update;

  if not found then
    raise exception 'Pantry item was not found.';
  end if;
  if not private.has_household_permission(v_item.household_id, 'record_waste') then
    raise exception 'You do not have permission to record food waste.';
  end if;
  if p_quantity_base > v_item.quantity_base then
    raise exception 'Waste quantity exceeds the available inventory.';
  end if;

  update public.pantry_items
  set quantity_base = quantity_base - p_quantity_base,
      updated_by = v_actor
  where id = p_pantry_item_id;

  insert into public.inventory_movements (
    household_id, pantry_item_id, movement_type, quantity_delta,
    base_unit, actor_user_id, reason
  )
  values (
    v_item.household_id, v_item.id, 'waste', -p_quantity_base,
    v_item.base_unit, v_actor, p_reason
  )
  returning id into v_movement_id;

  return v_movement_id;
end;
$fn$;

create or replace function private.reverse_inventory_movement_impl(p_movement_id uuid)
returns uuid
language plpgsql
security definer
set search_path = ''
as $fn$
declare
  v_actor uuid := auth.uid();
  v_movement public.inventory_movements%rowtype;
  v_item public.pantry_items%rowtype;
  v_new_quantity numeric(14,3);
  v_reversal_id uuid;
begin
  if v_actor is null then
    raise exception 'You must be signed in.';
  end if;

  select * into v_movement
  from public.inventory_movements
  where id = p_movement_id
  for update;

  if not found then
    raise exception 'Inventory movement was not found.';
  end if;
  if v_movement.movement_type = 'reversal' then
    raise exception 'A reversal cannot itself be reversed.';
  end if;
  if not private.is_household_member(v_movement.household_id) then
    raise exception 'You are no longer a member of this household.';
  end if;
  if v_actor <> v_movement.actor_user_id
     and not private.has_household_permission(v_movement.household_id, 'manage_inventory') then
    raise exception 'You can only undo your own entry unless you can manage inventory.';
  end if;
  if exists (
    select 1 from public.inventory_movements
    where reversal_of_id = v_movement.id
  ) then
    raise exception 'This entry has already been undone.';
  end if;

  select * into v_item
  from public.pantry_items
  where id = v_movement.pantry_item_id
  for update;

  if not found then
    raise exception 'The related pantry item no longer exists.';
  end if;

  v_new_quantity := v_item.quantity_base - v_movement.quantity_delta;
  if v_new_quantity < 0 then
    raise exception 'This entry cannot be undone because the available stock has since changed.';
  end if;

  update public.pantry_items
  set quantity_base = v_new_quantity,
      updated_by = v_actor
  where id = v_item.id;

  insert into public.inventory_movements (
    household_id, pantry_item_id, movement_type, quantity_delta,
    base_unit, actor_user_id, reversal_of_id
  )
  values (
    v_movement.household_id, v_movement.pantry_item_id, 'reversal',
    -v_movement.quantity_delta, v_movement.base_unit, v_actor, v_movement.id
  )
  returning id into v_reversal_id;

  return v_reversal_id;
end;
$fn$;

-- ---------------------------------------------------------------------------
-- Public, invoker-rights RPC wrappers. Private routines perform the validated
-- operation; the private schema is intentionally not exposed through the API.
-- ---------------------------------------------------------------------------

create or replace function public.create_household(p_name text)
returns uuid
language sql
security invoker
set search_path = ''
as $fn$
  select private.create_household_impl(p_name);
$fn$;

create or replace function public.update_household_member_permissions(
  p_member_id uuid,
  p_role text default null,
  p_can_manage_inventory boolean default null,
  p_can_log_own_consumption boolean default null,
  p_can_log_others_consumption boolean default null,
  p_can_record_waste boolean default null,
  p_can_view_household_analytics boolean default null,
  p_can_manage_members boolean default null
)
returns void
language sql
security invoker
set search_path = ''
as $fn$
  select private.update_household_member_permissions_impl(
    p_member_id, p_role, p_can_manage_inventory, p_can_log_own_consumption,
    p_can_log_others_consumption, p_can_record_waste,
    p_can_view_household_analytics, p_can_manage_members
  );
$fn$;

create or replace function public.create_household_invitation(
  p_household_id uuid,
  p_email text,
  p_token_hash text
)
returns uuid
language sql
security invoker
set search_path = ''
as $fn$
  select private.create_household_invitation_impl(p_household_id, p_email, p_token_hash);
$fn$;

create or replace function public.accept_household_invitation(p_token text)
returns uuid
language sql
security invoker
set search_path = ''
as $fn$
  select private.accept_household_invitation_impl(p_token);
$fn$;

create or replace function public.add_inventory_stock(
  p_pantry_item_id uuid,
  p_quantity_base numeric
)
returns uuid
language sql
security invoker
set search_path = ''
as $fn$
  select private.add_inventory_stock_impl(p_pantry_item_id, p_quantity_base);
$fn$;

create or replace function public.adjust_inventory_stock(
  p_pantry_item_id uuid,
  p_quantity_delta_base numeric
)
returns uuid
language sql
security invoker
set search_path = ''
as $fn$
  select private.adjust_inventory_stock_impl(p_pantry_item_id, p_quantity_delta_base);
$fn$;

create or replace function public.record_consumption(
  p_pantry_item_id uuid,
  p_quantity_base numeric,
  p_consumed_by_user_id uuid default null
)
returns uuid
language sql
security invoker
set search_path = ''
as $fn$
  select private.record_consumption_impl(p_pantry_item_id, p_quantity_base, p_consumed_by_user_id);
$fn$;

create or replace function public.record_food_waste(
  p_pantry_item_id uuid,
  p_quantity_base numeric,
  p_reason text default null
)
returns uuid
language sql
security invoker
set search_path = ''
as $fn$
  select private.record_food_waste_impl(p_pantry_item_id, p_quantity_base, p_reason);
$fn$;

create or replace function public.reverse_inventory_movement(p_movement_id uuid)
returns uuid
language sql
security invoker
set search_path = ''
as $fn$
  select private.reverse_inventory_movement_impl(p_movement_id);
$fn$;

-- ---------------------------------------------------------------------------
-- Row Level Security on every exposed table
-- ---------------------------------------------------------------------------

alter table public.profiles enable row level security;
alter table public.households enable row level security;
alter table public.household_members enable row level security;
alter table public.household_invitations enable row level security;
alter table public.food_categories enable row level security;
alter table public.storage_locations enable row level security;
alter table public.pantry_items enable row level security;
alter table public.inventory_movements enable row level security;

create policy "Profiles visible to self and household members"
on public.profiles for select to authenticated
using (
  id = (select auth.uid())
  or exists (
    select 1
    from public.household_members mine
    join public.household_members theirs
      on theirs.household_id = mine.household_id
    where mine.user_id = (select auth.uid())
      and theirs.user_id = profiles.id
  )
);

create policy "Users update their own profile"
on public.profiles for update to authenticated
using (id = (select auth.uid()))
with check (id = (select auth.uid()));

create policy "Household members can view their households"
on public.households for select to authenticated
using ((select private.is_household_member(id)));

create policy "Only the Owner can update household details"
on public.households for update to authenticated
using ((select private.is_household_owner(id)))
with check ((select private.is_household_owner(id)));

create policy "Household members can view the member list"
on public.household_members for select to authenticated
using ((select private.is_household_member(household_id)));

create policy "Household managers can view invitations"
on public.household_invitations for select to authenticated
using ((select private.has_household_permission(household_id, 'manage_members')));

create policy "Authenticated users can view food categories"
on public.food_categories for select to authenticated
using (true);

create policy "Members can view storage locations"
on public.storage_locations for select to authenticated
using ((select private.is_household_member(household_id)));

create policy "Permitted members create storage locations"
on public.storage_locations for insert to authenticated
with check ((select private.has_household_permission(household_id, 'manage_inventory')));

create policy "Permitted members update storage locations"
on public.storage_locations for update to authenticated
using ((select private.has_household_permission(household_id, 'manage_inventory')))
with check ((select private.has_household_permission(household_id, 'manage_inventory')));

create policy "Permitted members archive storage locations"
on public.storage_locations for delete to authenticated
using ((select private.has_household_permission(household_id, 'manage_inventory')));

create policy "Household members can view pantry items"
on public.pantry_items for select to authenticated
using ((select private.is_household_member(household_id)));

create policy "Permitted members add pantry items"
on public.pantry_items for insert to authenticated
with check ((select private.has_household_permission(household_id, 'manage_inventory')));

create policy "Permitted members update pantry metadata"
on public.pantry_items for update to authenticated
using ((select private.has_household_permission(household_id, 'manage_inventory')))
with check ((select private.has_household_permission(household_id, 'manage_inventory')));

create policy "Household members view permitted inventory history"
on public.inventory_movements for select to authenticated
using (
  (select private.has_household_permission(household_id, 'view_household_analytics'))
  or actor_user_id = (select auth.uid())
  or consumed_by_user_id = (select auth.uid())
);

-- ---------------------------------------------------------------------------
-- Least-privilege Data API grants
-- ---------------------------------------------------------------------------

revoke all on all tables in schema public from anon, authenticated, service_role;
revoke all on all sequences in schema public from anon, authenticated, service_role;
revoke execute on all functions in schema public from public, anon, authenticated, service_role;

grant usage on schema public to authenticated;

grant select, update (display_name, preferred_language)
  on public.profiles to authenticated;

grant select, update (name)
  on public.households to authenticated;

grant select on public.household_members to authenticated;
grant select on public.household_invitations to authenticated;
grant select on public.food_categories to authenticated;

grant select, insert, update (name, is_active, sort_order), delete
  on public.storage_locations to authenticated;

grant select,
      insert (
        household_id, name, category_key, storage_location_id,
        quantity_base, base_unit, display_unit, expiry_date,
        alert_days_before, notes
      ),
      update (
        name, category_key, storage_location_id, display_unit,
        expiry_date, alert_days_before, notes, archived_at
      )
  on public.pantry_items to authenticated;

grant select on public.inventory_movements to authenticated;

-- Private helper functions used by policies.
revoke all on function private.is_household_member(uuid) from public, anon, authenticated;
revoke all on function private.is_household_owner(uuid) from public, anon, authenticated;
revoke all on function private.has_household_permission(uuid, text) from public, anon, authenticated;
grant execute on function private.is_household_member(uuid) to authenticated;
grant execute on function private.is_household_owner(uuid) to authenticated;
grant execute on function private.has_household_permission(uuid, text) to authenticated;

-- Private operation routines are callable only by authenticated users through
-- the public invoker-rights RPC wrappers (and are not directly API-exposed).
revoke all on function private.create_household_impl(text) from public, anon, authenticated;
revoke all on function private.update_household_member_permissions_impl(uuid, text, boolean, boolean, boolean, boolean, boolean, boolean) from public, anon, authenticated;
revoke all on function private.create_household_invitation_impl(uuid, text, text) from public, anon, authenticated;
revoke all on function private.accept_household_invitation_impl(text) from public, anon, authenticated;
revoke all on function private.add_inventory_stock_impl(uuid, numeric) from public, anon, authenticated;
revoke all on function private.adjust_inventory_stock_impl(uuid, numeric) from public, anon, authenticated;
revoke all on function private.record_consumption_impl(uuid, numeric, uuid) from public, anon, authenticated;
revoke all on function private.record_food_waste_impl(uuid, numeric, text) from public, anon, authenticated;
revoke all on function private.reverse_inventory_movement_impl(uuid) from public, anon, authenticated;

grant execute on function private.create_household_impl(text) to authenticated;
grant execute on function private.update_household_member_permissions_impl(uuid, text, boolean, boolean, boolean, boolean, boolean, boolean) to authenticated;
grant execute on function private.create_household_invitation_impl(uuid, text, text) to authenticated;
grant execute on function private.accept_household_invitation_impl(text) to authenticated;
grant execute on function private.add_inventory_stock_impl(uuid, numeric) to authenticated;
grant execute on function private.adjust_inventory_stock_impl(uuid, numeric) to authenticated;
grant execute on function private.record_consumption_impl(uuid, numeric, uuid) to authenticated;
grant execute on function private.record_food_waste_impl(uuid, numeric, text) to authenticated;
grant execute on function private.reverse_inventory_movement_impl(uuid) to authenticated;

-- Trigger routines are not callable as RPCs.
revoke all on function private.set_updated_at() from public, anon, authenticated;
revoke all on function private.handle_new_user() from public, anon, authenticated;
revoke all on function private.log_initial_pantry_stock() from public, anon, authenticated;
revoke all on function private.stamp_pantry_item_editor() from public, anon, authenticated;

-- Public RPCs are intentionally available only to authenticated clients.
revoke all on function public.create_household(text) from public, anon, authenticated;
revoke all on function public.update_household_member_permissions(uuid, text, boolean, boolean, boolean, boolean, boolean, boolean) from public, anon, authenticated;
revoke all on function public.create_household_invitation(uuid, text, text) from public, anon, authenticated;
revoke all on function public.accept_household_invitation(text) from public, anon, authenticated;
revoke all on function public.add_inventory_stock(uuid, numeric) from public, anon, authenticated;
revoke all on function public.adjust_inventory_stock(uuid, numeric) from public, anon, authenticated;
revoke all on function public.record_consumption(uuid, numeric, uuid) from public, anon, authenticated;
revoke all on function public.record_food_waste(uuid, numeric, text) from public, anon, authenticated;
revoke all on function public.reverse_inventory_movement(uuid) from public, anon, authenticated;

grant execute on function public.create_household(text) to authenticated;
grant execute on function public.update_household_member_permissions(uuid, text, boolean, boolean, boolean, boolean, boolean, boolean) to authenticated;
grant execute on function public.create_household_invitation(uuid, text, text) to authenticated;
grant execute on function public.accept_household_invitation(text) to authenticated;
grant execute on function public.add_inventory_stock(uuid, numeric) to authenticated;
grant execute on function public.adjust_inventory_stock(uuid, numeric) to authenticated;
grant execute on function public.record_consumption(uuid, numeric, uuid) to authenticated;
grant execute on function public.record_food_waste(uuid, numeric, text) to authenticated;
grant execute on function public.reverse_inventory_movement(uuid) to authenticated;

commit;
