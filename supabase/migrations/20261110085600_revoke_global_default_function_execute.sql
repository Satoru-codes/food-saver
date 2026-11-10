-- PostgreSQL applies schema-specific default privileges additively.
-- Revoke the global default EXECUTE grant for future functions created by postgres.
-- Application-facing functions must receive explicit grants in their migrations.
begin;

alter default privileges for role postgres
  revoke execute on functions from public, anon, authenticated, service_role;

commit;
