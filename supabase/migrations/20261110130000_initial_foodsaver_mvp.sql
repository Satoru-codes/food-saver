-- FoodSaver MVP: initial household, pantry, permissions, and inventory ledger.
-- Apply this migration to the FoodSaver-dev Supabase project only.
-- Keep credentials and API keys out of this file.

begin;

create extension if not exists pgcrypto;

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

create index household_members_user_idx
  on public.household_members(user_id, household_id);

-- Keep profile records in sync with Supabase Auth sign-ups.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, display_name, preferred_language)
  values (
    new.id,
    coalesce(
      nullif(trim(new.raw_user_meta_data ->> 'full_name'), ''),
      nullif(trim(new.raw_user_meta_data ->> 'name'), ''),
      split_part(coalesce(new.email, ''), '@', 1)
    ),
    case
      when new.raw_user_meta_data ->> 'preferred_language' = 'hi' then 'hi'
      else 'en'
    end
  )
  on conflict (id) do nothing;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created_foodsaver on auth.users;
create trigger on_auth_user_created_foodsaver
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ---------------------------------------------------------------------------
-- Pantry taxonomy and storage
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
-- Immutable inventory history
-- quantity_delta is expressed in the pantry item's base unit.
-- Addition/adjustment are positive or negative; consumption/waste are negative.
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
    references public.pantry_items(id, household_id) on delete cascade,
  check (
    (movement_type = 'consumption') or consumed_by_user_id is null
  ),
  check (
    (movement_type = 'waste') or reason is null
  ),
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
-- Updated timestamps and safe inventory movement logging
-- ---------------------------------------------------------------------------

create or replace function public.set_updated_at()
returns trigger
language plpgsql
set search_path = public
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

create trigger households_set_updated_at
  before update on public.households
  for each row execute function public.set_updated_at();

create trigger storage_locations_set_updated_at
  before update on public.storage_locations
  for each row execute function public.set_updated_at();

create trigger pantry_items_set_updated_at
  before update on public.pantry_items
  for each row execute function public.set_updated_at();

create or replace function public.log_pantry_item_stock_change()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_actor uuid;
  v_delta numeric(14,3);
begin
  if current_setting('foodsaver.skip_movement_log', true) = 'true' then
    return new;
  end if;

  if tg_op = 'INSERT' then
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
  end if;

  v_delta := new.quantity_base - old.quantity_base;
  if v_delta <> 0 then
    v_actor := coalesce(auth.uid(), new.updated_by, new.created_by);
    insert into public.inventory_movements (
      household_id, pantry_item_id, movement_type, quantity_delta,
      base_unit, actor_user_id
    )
    values (
      new.household_id, new.id, 'adjustment', v_delta,
      new.base_unit, v_actor
    );
  end if;

  return new;
end;
$$;

create trigger pantry_items_log_stock_insert
  after insert on public.pantry_items
  for each row execute function public.log_pantry_item_stock_change();

create trigger pantry_items_log_stock_update
  after update of quantity_base on public.pantry_items
  for each row execute function public.log_pantry_item_stock_change();

-- ---------------------------------------------------------------------------
-- Authorization helpers. SECURITY DEFINER avoids recursive RLS lookups.
-- Owner is unrestricted. Admins and Members receive explicit permissions.
-- ---------------------------------------------------------------------------

create or replace function public.is_household_member(p_household_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.household_members hm
    where hm.household_id = p_household_id
      and hm.user_id = auth.uid()
  );
$$;

create or replace function public.is_household_owner(p_household_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.households h
    where h.id = p_household_id
      and h.owner_user_id = auth.uid()
  );
$$;

create or replace function public.has_household_permission(
  p_household_id uuid,
  p_permission text
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
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
$$;

-- A newly created household automatically has one Owner.
create or replace function public.create_household(p_name text)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_household_id uuid;
begin
  if v_user_id is null then
    raise exception 'You must be signed in to create a household.';
  end if;

  if p_name is null or length(trim(p_name)) not between 1 and 80 then
    raise exception 'Household name must be between 1 and 80 characters.';
  end if;

  insert into public.households (name, owner_user_id)
  values (trim(p_name), v_user_id)
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
$$;

-- Change another household member's role and granular permissions.
-- Owners can manage Admins and Members. An Admin must have can_manage_members
-- and can manage only Members; only the Owner can change an existing Admin.
-- The Owner role itself cannot be reassigned by this function.
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
language plpgsql
security definer
set search_path = public
as $
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

  select hm.*, h.owner_user_id
    into v_target, v_owner_user_id
  from public.household_members hm
  join public.households h on h.id = hm.household_id
  where hm.id = p_member_id
  for update of hm;

  if not found then
    raise exception 'Household member was not found.';
  end if;

  v_is_owner := v_owner_user_id = v_actor;

  if not v_is_owner
     and not public.has_household_permission(v_target.household_id, 'manage_members') then
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
$;

-- Record consumption and update stock in one database transaction.
create or replace function public.record_consumption(
  p_pantry_item_id uuid,
  p_quantity_base numeric,
  p_consumed_by_user_id uuid default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
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
  where id = p_pantry_item_id
    and archived_at is null
  for update;

  if not found then
    raise exception 'Pantry item was not found.';
  end if;

  if p_consumed_by_user_id is null then
    if not public.has_household_permission(v_item.household_id, 'log_others_consumption') then
      raise exception 'You do not have permission to record shared consumption.';
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
      if not public.has_household_permission(v_item.household_id, 'log_own_consumption') then
        raise exception 'You do not have permission to record your own consumption.';
      end if;
    else
      if not public.has_household_permission(v_item.household_id, 'log_others_consumption') then
        raise exception 'You do not have permission to record another member''s consumption.';
      end if;
    end if;
  end if;

  if p_quantity_base > v_item.quantity_base then
    raise exception 'Consumption exceeds the available inventory.';
  end if;

  perform set_config('foodsaver.skip_movement_log', 'true', true);
  update public.pantry_items
  set quantity_base = quantity_base - p_quantity_base,
      updated_by = v_actor
  where id = p_pantry_item_id;
  perform set_config('foodsaver.skip_movement_log', 'false', true);

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
$$;

-- Record food waste separately from consumption.
create or replace function public.record_food_waste(
  p_pantry_item_id uuid,
  p_quantity_base numeric,
  p_reason text default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
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
  where id = p_pantry_item_id
    and archived_at is null
  for update;

  if not found then
    raise exception 'Pantry item was not found.';
  end if;
  if not public.has_household_permission(v_item.household_id, 'record_waste') then
    raise exception 'You do not have permission to record food waste.';
  end if;
  if p_quantity_base > v_item.quantity_base then
    raise exception 'Waste quantity exceeds the available inventory.';
  end if;

  perform set_config('foodsaver.skip_movement_log', 'true', true);
  update public.pantry_items
  set quantity_base = quantity_base - p_quantity_base,
      updated_by = v_actor
  where id = p_pantry_item_id;
  perform set_config('foodsaver.skip_movement_log', 'false', true);

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
$$;

-- Undo a movement without deleting the original audit record.
create or replace function public.reverse_inventory_movement(p_movement_id uuid)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
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
  if v_actor <> v_movement.actor_user_id
     and not public.has_household_permission(v_movement.household_id, 'manage_inventory') then
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

  perform set_config('foodsaver.skip_movement_log', 'true', true);
  update public.pantry_items
  set quantity_base = v_new_quantity,
      updated_by = v_actor
  where id = v_item.id;
  perform set_config('foodsaver.skip_movement_log', 'false', true);

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
$$;

-- ---------------------------------------------------------------------------
-- Row Level Security
-- ---------------------------------------------------------------------------

alter table public.profiles enable row level security;
alter table public.households enable row level security;
alter table public.household_members enable row level security;
alter table public.food_categories enable row level security;
alter table public.storage_locations enable row level security;
alter table public.pantry_items enable row level security;
alter table public.inventory_movements enable row level security;

create policy "Profiles are visible to self and household members"
on public.profiles for select to authenticated
using (
  id = auth.uid()
  or exists (
    select 1
    from public.household_members mine
    join public.household_members theirs
      on theirs.household_id = mine.household_id
    where mine.user_id = auth.uid()
      and theirs.user_id = profiles.id
  )
);

create policy "Users update their own profile"
on public.profiles for update to authenticated
using (id = auth.uid())
with check (id = auth.uid());

create policy "Household members can view their households"
on public.households for select to authenticated
using (public.is_household_member(id));

create policy "Owner can update household details"
on public.households for update to authenticated
using (public.is_household_owner(id))
with check (public.is_household_owner(id));

create policy "Household members can view the member list"
on public.household_members for select to authenticated
using (public.is_household_member(household_id));

-- Membership roles and permissions are changed only through the controlled RPC below.
-- There is deliberately no direct UPDATE policy or table grant for clients.

create policy "Authenticated users can view food categories"
on public.food_categories for select to authenticated
using (true);

create policy "Members can view storage locations"
on public.storage_locations for select to authenticated
using (public.is_household_member(household_id));

create policy "Permitted members manage storage locations"
on public.storage_locations for insert to authenticated
with check (public.has_household_permission(household_id, 'manage_inventory'));

create policy "Permitted members update storage locations"
on public.storage_locations for update to authenticated
using (public.has_household_permission(household_id, 'manage_inventory'))
with check (public.has_household_permission(household_id, 'manage_inventory'));

create policy "Permitted members delete storage locations"
on public.storage_locations for delete to authenticated
using (public.has_household_permission(household_id, 'manage_inventory'));

create policy "Household members can view active and archived pantry items"
on public.pantry_items for select to authenticated
using (public.is_household_member(household_id));

create policy "Permitted members add pantry items"
on public.pantry_items for insert to authenticated
with check (public.has_household_permission(household_id, 'manage_inventory'));

create policy "Permitted members update pantry items"
on public.pantry_items for update to authenticated
using (public.has_household_permission(household_id, 'manage_inventory'))
with check (public.has_household_permission(household_id, 'manage_inventory'));

create policy "Members see household analytics or their own activity"
on public.inventory_movements for select to authenticated
using (
  public.has_household_permission(household_id, 'view_household_analytics')
  or actor_user_id = auth.uid()
  or consumed_by_user_id = auth.uid()
);

-- No direct insert/update/delete policies for inventory_movements:
-- changes must go through the stock-change trigger or controlled RPC functions.

-- ---------------------------------------------------------------------------
-- Explicit API grants. RLS policies above still determine which rows are visible.
-- ---------------------------------------------------------------------------

grant usage on schema public to authenticated;

grant select, update (display_name, preferred_language)
  on public.profiles to authenticated;

grant select, update (name)
  on public.households to authenticated;

grant select on public.household_members to authenticated;

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
        name, category_key, storage_location_id, quantity_base,
        display_unit, expiry_date, alert_days_before, notes,
        updated_by, archived_at
      )
  on public.pantry_items to authenticated;

grant select on public.inventory_movements to authenticated;

revoke all on function public.is_household_member(uuid) from public;
revoke all on function public.is_household_owner(uuid) from public;
revoke all on function public.has_household_permission(uuid, text) from public;
revoke all on function public.create_household(text) from public;
revoke all on function public.update_household_member_permissions(uuid, text, boolean, boolean, boolean, boolean, boolean, boolean) from public;
revoke all on function public.record_consumption(uuid, numeric, uuid) from public;
revoke all on function public.record_food_waste(uuid, numeric, text) from public;
revoke all on function public.reverse_inventory_movement(uuid) from public;

grant execute on function public.is_household_member(uuid) to authenticated;
grant execute on function public.is_household_owner(uuid) to authenticated;
grant execute on function public.has_household_permission(uuid, text) to authenticated;
grant execute on function public.create_household(text) to authenticated;
grant execute on function public.update_household_member_permissions(uuid, text, boolean, boolean, boolean, boolean, boolean, boolean) to authenticated;
grant execute on function public.record_consumption(uuid, numeric, uuid) to authenticated;
grant execute on function public.record_food_waste(uuid, numeric, text) to authenticated;
grant execute on function public.reverse_inventory_movement(uuid) to authenticated;

commit;
