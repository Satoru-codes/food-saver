-- Ensure former household members cannot continue reading historical movements.
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
