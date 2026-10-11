-- Base privada para o casal. Execute este arquivo no SQL Editor do Supabase.
create table public.households (
  id uuid primary key default gen_random_uuid(),
  name text not null default 'Nossa casa',
  created_at timestamptz not null default now()
);

create table public.household_members (
  household_id uuid not null references public.households(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null default 'member' check (role in ('owner','member')),
  primary key (household_id, user_id)
);

create table public.recurring_entries (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  kind text not null check (kind in ('income','fixed_expense')),
  name text not null,
  amount numeric(12,2) not null check (amount > 0),
  due_day smallint not null check (due_day between 1 and 31),
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);

create table public.transactions (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  name text not null,
  amount numeric(12,2) not null check (amount > 0),
  category text,
  occurred_on date not null,
  payment_method text,
  source text not null default 'manual' check (source in ('manual','invoice_import')),
  created_by uuid references auth.users(id),
  created_at timestamptz not null default now()
);

alter table public.households enable row level security;
alter table public.household_members enable row level security;
alter table public.recurring_entries enable row level security;
alter table public.transactions enable row level security;

create function public.is_household_member(target_household uuid)
returns boolean language sql stable security definer set search_path = public
as $$ select exists (
  select 1 from public.household_members
  where household_id = target_household and user_id = auth.uid()
); $$;

create policy "members can read their household" on public.households
for select using (public.is_household_member(id));
create policy "authenticated users can create a household" on public.households
for insert with check (auth.uid() is not null);
create policy "members can read memberships" on public.household_members
for select using (public.is_household_member(household_id));
create policy "members manage recurring entries" on public.recurring_entries
for all using (public.is_household_member(household_id))
with check (public.is_household_member(household_id));

-- Execute uma vez, já conectado no app, para criar a casa do casal.
-- A função cria a household e associa o usuário que a chamou como owner.
create function public.create_household(household_name text default 'Nossa casa')
returns uuid language plpgsql security definer set search_path = public
as $$
declare new_household uuid;
begin
  insert into public.households (name) values (household_name) returning id into new_household;
  insert into public.household_members (household_id, user_id, role)
  values (new_household, auth.uid(), 'owner');
  return new_household;
end;
$$;

grant execute on function public.create_household(text) to authenticated;
create policy "members manage transactions" on public.transactions
for all using (public.is_household_member(household_id))
with check (public.is_household_member(household_id));
