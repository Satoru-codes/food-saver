-- Keep future private-schema objects closed by default.
begin;

alter default privileges for role postgres in schema private
  revoke all on tables from public, anon, authenticated, service_role;

alter default privileges for role postgres in schema private
  revoke execute on functions from public, anon, authenticated, service_role;

alter default privileges for role postgres in schema private
  revoke usage, select on sequences from public, anon, authenticated, service_role;

commit;
