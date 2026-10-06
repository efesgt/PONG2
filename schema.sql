-- ============================================================
--  Beer Pong Turnuvası — Supabase şeması
--  Supabase paneli > SQL Editor'e yapıştırıp bir kez çalıştır.
--  (Tekrar çalıştırmak güvenlidir.)
-- ============================================================

-- Takımlar ---------------------------------------------------
create table if not exists public.teams (
  id          uuid primary key default gen_random_uuid(),
  name        text not null check (char_length(btrim(name)) between 1 and 40),
  difficulty  int  not null check (difficulty between 1 and 10),
  is_deleted  boolean not null default false,   -- turnuva başladıktan sonra silinenler
  created_at  timestamptz not null default now()
);

-- Aynı isimde iki aktif takım olmasın (büyük/küçük harf fark etmez)
create unique index if not exists teams_name_alive
  on public.teams (lower(name)) where not is_deleted;

-- Turnuva (tek satır) ---------------------------------------
create table if not exists public.tournament (
  id            int primary key default 1 check (id = 1),
  status        text not null default 'setup'
                check (status in ('setup','running','finished')),
  current_round int  not null default 0,
  pair_mode     text not null default 'close'
                check (pair_mode in ('close','balanced')),  -- close: benzer seviye, balanced: güçlü-zayıf
  champion      uuid references public.teams(id) on delete set null,
  updated_at    timestamptz not null default now()
);

insert into public.tournament (id) values (1) on conflict (id) do nothing;

-- Maçlar -----------------------------------------------------
create table if not exists public.matches (
  id          uuid primary key default gen_random_uuid(),
  round       int  not null,
  slot        int  not null,                       -- tur içindeki sıra
  team_a      uuid references public.teams(id) on delete cascade,
  team_b      uuid references public.teams(id) on delete cascade,
  winner      uuid references public.teams(id) on delete set null,
  status      text not null default 'waiting'
              check (status in ('waiting','playing','done')),
  table_name  text check (table_name in ('kirmizi','mavi','beyaz')),
  is_bye      boolean not null default false,      -- otomatik üst tura geçen (bay)
  walkover    boolean not null default false,      -- rakip silindiği için hükmen
  created_at  timestamptz not null default now()
);

create unique index if not exists matches_round_slot
  on public.matches (round, slot);

-- Aynı masada aynı anda iki maç oynanamasın
create unique index if not exists matches_one_per_table
  on public.matches (table_name) where status = 'playing';

-- Erişim (RLS) -----------------------------------------------
-- DİKKAT: Bu politikalar, sayfanın adresini bilen herkesin okumasına VE yazmasına izin verir.
-- Arkadaş grubu / tek seferlik etkinlik için pratik; herkese açık kalıcı kullanım için
-- Supabase Auth ile yazma iznini sadece giriş yapmış yöneticiye bağla.
alter table public.teams      enable row level security;
alter table public.tournament enable row level security;
alter table public.matches    enable row level security;

drop policy if exists bp_open_access on public.teams;
drop policy if exists bp_open_access on public.tournament;
drop policy if exists bp_open_access on public.matches;

create policy bp_open_access on public.teams
  for all to anon, authenticated using (true) with check (true);
create policy bp_open_access on public.tournament
  for all to anon, authenticated using (true) with check (true);
create policy bp_open_access on public.matches
  for all to anon, authenticated using (true) with check (true);

-- Canlı güncelleme (Realtime) --------------------------------
-- Başka telefon / ekranlarda tablo kendiliğinden güncellensin.
do $$ begin
  alter publication supabase_realtime add table public.teams;
exception when duplicate_object then null; end $$;

do $$ begin
  alter publication supabase_realtime add table public.matches;
exception when duplicate_object then null; end $$;

do $$ begin
  alter publication supabase_realtime add table public.tournament;
exception when duplicate_object then null; end $$;
