-- The confirm-invited-email Edge Function uses the server-only
-- Supabase secret/service-role client to validate the caller's managed
-- household and an existing invitation before invoking Auth Admin.
-- Grant only the two read operations it needs. No browser role is changed.

begin;

grant select on public.household_members to service_role;
grant select on public.household_invitations to service_role;

commit;
