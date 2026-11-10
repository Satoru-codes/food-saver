-- FoodSaver MVP follow-up: current-membership history access, safe undo,
-- and supporting foreign-key indexes reported by the Supabase advisor.

begin;

drop policy if exists "Household members view permitted inventory history"
  on public.inventory_movements;

create policy "Household members view permitted inventory history"
on public.inventory_movements
for select
to authenticated
using (
  (select private.is_household_member(household_id))
  and (
    (select private.has_household_permission(household_id, 'view_household_analytics'))
    or actor_user_id = (select auth.uid())
    or consumed_by_user_id = (select auth.uid())
  )
);

-- A removed household member must not be able to reverse a historical action.
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

-- Cover the foreign keys reported by the performance advisor.
create index if not exists households_owner_user_id_idx
  on public.households(owner_user_id);

create index if not exists household_invitations_invited_by_idx
  on public.household_invitations(invited_by);

create index if not exists household_invitations_accepted_by_idx
  on public.household_invitations(accepted_by);

create index if not exists inventory_movements_actor_user_id_idx
  on public.inventory_movements(actor_user_id);

create index if not exists inventory_movements_consumed_by_user_id_idx
  on public.inventory_movements(consumed_by_user_id);

create index if not exists inventory_movements_item_household_idx
  on public.inventory_movements(pantry_item_id, household_id);

create index if not exists pantry_items_category_key_idx
  on public.pantry_items(category_key);

create index if not exists pantry_items_created_by_idx
  on public.pantry_items(created_by);

create index if not exists pantry_items_updated_by_idx
  on public.pantry_items(updated_by);

create index if not exists pantry_items_storage_household_idx
  on public.pantry_items(storage_location_id, household_id);

create index if not exists storage_locations_created_by_idx
  on public.storage_locations(created_by);

commit;
