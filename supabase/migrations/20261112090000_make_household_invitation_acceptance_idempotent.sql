-- Reopening an already accepted household invitation from the same
-- authenticated account should be harmless. A different account must never
-- be allowed to reuse an accepted invitation.

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

  -- Idempotent success only for the same account that accepted this invite.
  -- This permits the invitee to reopen the original link later without
  -- inserting a duplicate membership or being signed out.
  if v_invitation.accepted_at is not null then
    if v_invitation.accepted_by = v_actor
       and v_invitation.email = v_email then
      return v_invitation.household_id;
    end if;

    raise exception 'This invitation has already been used.';
  end if;

  if v_invitation.revoked_at is not null then
    raise exception 'This invitation has been revoked.';
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
