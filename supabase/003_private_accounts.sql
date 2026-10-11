-- Execute este arquivo no SQL Editor.
-- O compartilhamento entre usuários fica desativado: cada login terá dados isolados.
revoke execute on function public.join_household(text) from authenticated;

-- O app cria uma household privada automaticamente no primeiro login.
-- Não há convite nem tela para associar duas pessoas.
