-- Execute este arquivo no SQL Editor para habilitar cartões e importação de faturas.
create table if not exists public.cards (
  id uuid primary key default gen_random_uuid(),
  household_id uuid not null references public.households(id) on delete cascade,
  name text not null,
  last_four text,
  credit_limit numeric(12,2),
  closing_day smallint check (closing_day between 1 and 31),
  due_day smallint check (due_day between 1 and 31),
  created_at timestamptz not null default now()
);

alter table public.cards enable row level security;

create policy "members manage their cards" on public.cards
for all using (public.is_household_member(household_id))
with check (public.is_household_member(household_id));

alter table public.transactions
add column if not exists card_id uuid references public.cards(id) on delete set null,
add column if not exists installment text;
