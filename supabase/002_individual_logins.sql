-- Execute este segundo arquivo no SQL Editor após schema.sql.
-- Ele permite dois logins individuais compartilharem a mesma household.

alter table public.households
add column if not exists invite_code text unique
default upper(substr(md5(random()::text), 1, 8));

update public.households
set invite_code = upper(substr(md5(random()::text), 1, 8))
where invite_code is null;

alter table public.households
alter column invite_code set not null;

create or replace function public.join_household(code text)
returns uuid language plpgsql security definer set search_path = public
as $$
declare target_household uuid;
begin
  if auth.uid() is null then
    raise exception 'Você precisa estar autenticado.';
  end if;

  select id into target_household
  from public.households
  where invite_code = upper(trim(code));

  if target_household is null then
    raise exception 'Código de convite inválido.';
  end if;

  insert into public.household_members (household_id, user_id, role)
  values (target_household, auth.uid(), 'member')
  on conflict (household_id, user_id) do nothing;

  return target_household;
end;
$$;

grant execute on function public.join_household(text) to authenticated;
