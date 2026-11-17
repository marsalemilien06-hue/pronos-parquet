-- Pronos Parquet : comptes et sauvegardes en ligne.
-- À coller une seule fois dans Supabase > SQL Editor > New query, puis "Run".

create table if not exists public.saves (
  user_id uuid primary key references auth.users (id) on delete cascade,
  data jsonb not null,
  updated_at timestamptz not null default now(),
  constraint saves_taille check (pg_column_size(data) < 1000000)
);

alter table public.saves enable row level security;

-- Chacun ne voit et ne modifie que sa propre sauvegarde.
drop policy if exists "lire sa sauvegarde" on public.saves;
drop policy if exists "creer sa sauvegarde" on public.saves;
drop policy if exists "modifier sa sauvegarde" on public.saves;
create policy "lire sa sauvegarde" on public.saves for select to authenticated using ((select auth.uid()) = user_id);
create policy "creer sa sauvegarde" on public.saves for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "modifier sa sauvegarde" on public.saves for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);

-- Bouton "Supprimer mon compte" : efface le compte connecté et sa sauvegarde.
create or replace function public.delete_my_account()
returns void
language sql
security definer
set search_path = ''
as $$
  delete from auth.users where id = auth.uid();
$$;
revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;
