-- Allow every current household member to inspect the household activity ledger.
-- Direct reads remain limited to fields required by the UI; writes continue through RPCs.

begin;

drop policy if exists "Household members view permitted inventory history"
  on public.inventory_movements;

create policy "Household members can view all inventory activity"
on public.inventory_movements
for select
to authenticated
using ((select private.is_household_member(household_id)));

revoke select on table public.inventory_movements from authenticated;

grant select (
  id, household_id, pantry_item_id, movement_type, quantity_delta,
  base_unit, actor_user_id, consumed_by_user_id, reversal_of_id, created_at
) on table public.inventory_movements to authenticated;

commit;
