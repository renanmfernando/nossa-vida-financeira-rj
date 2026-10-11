-- Execute este arquivo no SQL Editor do Supabase uma única vez.
-- A trava fica no banco: uma mesma linha de fatura não pode ser importada
-- duas vezes para o mesmo cartão e área pessoal.
alter table public.transactions
add column if not exists import_fingerprint text;

alter table public.transactions
drop constraint if exists transactions_one_imported_line_per_card;

alter table public.transactions
add constraint transactions_one_imported_line_per_card
unique (household_id, card_id, import_fingerprint);

create index if not exists transactions_import_fingerprint_idx
on public.transactions (household_id, card_id, import_fingerprint);
