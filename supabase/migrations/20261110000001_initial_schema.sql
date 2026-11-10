-- =============================================================================
-- Migration: 20261110000001_initial_schema.sql
-- Proyek   : Isyaratify (Pembelajaran Alfabet Statis BISINDO A-Z)
-- Deskripsi: Skema inti MVP (profiles, letters, learning_guides, quests,
--            user_progress, user_letter_mastery, practice_attempts,
--            quest_completions, badges, user_badges, leaderboard_entries,
--            leaderboard_view), trigger registrasi, RPC record_practice_attempt,
--            dan kebijakan Row Level Security (RLS).
-- =============================================================================

create schema if not exists private;

-- -----------------------------------------------------------------------------
-- 1. Tabel profiles (terkait 1:1 dengan auth.users, tanpa menyimpan email)
-- -----------------------------------------------------------------------------
create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text unique,
  display_name text not null,
  avatar_url text,
  bio text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

create policy "profiles_select_own"
  on public.profiles
  for select
  to authenticated
  using ((select auth.uid()) = id);

create policy "profiles_insert_own"
  on public.profiles
  for insert
  to authenticated
  with check ((select auth.uid()) = id);

create policy "profiles_update_own"
  on public.profiles
  for update
  to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

-- -----------------------------------------------------------------------------
-- 2. Tabel letters (Kamus & Materi Alfabet BISINDO A-Z)
-- -----------------------------------------------------------------------------
create table if not exists public.letters (
  id bigint generated always as identity primary key,
  letter char(1) not null unique check (letter ~ '^[A-Z]$'),
  hand_count smallint not null default 1 check (hand_count in (1, 2)),
  difficulty text not null default 'easy' check (difficulty in ('easy', 'medium', 'hard')),
  description text not null,
  step_by_step_guides jsonb not null default '[]'::jsonb,
  common_mistakes text not null default '',
  image_url text,
  sort_order smallint not null unique,
  created_at timestamptz not null default now()
);

alter table public.letters enable row level security;

create policy "letters_select_authenticated"
  on public.letters
  for select
  to authenticated
  using (true);

-- -----------------------------------------------------------------------------
-- 3. Tabel learning_guides (Modul Panduan Belajar & Setup Kamera via API)
-- -----------------------------------------------------------------------------
create table if not exists public.learning_guides (
  id bigint generated always as identity primary key,
  slug text not null unique,
  category text not null check (category in ('bisindo_intro', 'camera_setup', 'practice_tips')),
  title text not null,
  summary text not null,
  content text not null,
  icon_key text not null default 'school',
  sort_order smallint not null default 1,
  is_published boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.learning_guides enable row level security;

create policy "learning_guides_select_authenticated"
  on public.learning_guides
  for select
  to authenticated
  using (is_published = true);

-- -----------------------------------------------------------------------------
-- 4. Tabel quests (Definisi Misi Pembelajaran)
-- -----------------------------------------------------------------------------
create table if not exists public.quests (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  title text not null,
  description text not null,
  quest_type text not null default 'correct_count'
    check (quest_type in ('practice_count', 'correct_count', 'master_letters', 'specific_letters', 'two_hands_correct')),
  target_value integer not null default 1 check (target_value > 0),
  target_letters text[] not null default '{}',
  xp_reward integer not null default 20 check (xp_reward >= 0),
  is_active boolean not null default true,
  sort_order smallint not null default 1,
  created_at timestamptz not null default now()
);

alter table public.quests enable row level security;

create policy "quests_select_authenticated"
  on public.quests
  for select
  to authenticated
  using (true);

-- -----------------------------------------------------------------------------
-- 5. Tabel badges (Katalog Lencana Pencapaian)
-- -----------------------------------------------------------------------------
create table if not exists public.badges (
  id uuid primary key default gen_random_uuid(),
  code text not null unique,
  title text not null,
  description text not null,
  icon_key text not null default 'emoji_events',
  sort_order smallint not null default 1,
  created_at timestamptz not null default now()
);

alter table public.badges enable row level security;

create policy "badges_select_authenticated"
  on public.badges
  for select
  to authenticated
  using (true);

-- -----------------------------------------------------------------------------
-- 6. Tabel user_progress (Progres XP, Level, dan Streak Pengguna)
-- -----------------------------------------------------------------------------
create table if not exists public.user_progress (
  user_id uuid primary key references auth.users(id) on delete cascade,
  xp integer not null default 0 check (xp >= 0),
  level integer not null default 1 check (level >= 1),
  current_streak integer not null default 0 check (current_streak >= 0),
  last_practice_date date,
  total_attempts integer not null default 0 check (total_attempts >= 0),
  correct_attempts integer not null default 0 check (correct_attempts >= 0),
  updated_at timestamptz not null default now()
);

alter table public.user_progress enable row level security;

create policy "user_progress_select_own"
  on public.user_progress
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

-- -----------------------------------------------------------------------------
-- 7. Tabel user_letter_mastery (Penguasaan per Huruf A-Z untuk tiap Pengguna)
-- -----------------------------------------------------------------------------
create table if not exists public.user_letter_mastery (
  user_id uuid not null references auth.users(id) on delete cascade,
  letter char(1) not null references public.letters(letter) on delete cascade,
  total_attempts integer not null default 0 check (total_attempts >= 0),
  correct_attempts integer not null default 0 check (correct_attempts >= 0),
  best_confidence double precision not null default 0 check (best_confidence >= 0 and best_confidence <= 1),
  is_mastered boolean not null default false,
  last_practiced_at timestamptz not null default now(),
  primary key (user_id, letter)
);

create index if not exists idx_user_letter_mastery_user_id
  on public.user_letter_mastery(user_id);

create index if not exists idx_user_letter_mastery_letter
  on public.user_letter_mastery(letter);

alter table public.user_letter_mastery enable row level security;

create policy "user_letter_mastery_select_own"
  on public.user_letter_mastery
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

-- -----------------------------------------------------------------------------
-- 8. Tabel practice_attempts (Metadata Latihan Tanpa Foto/Video Kamera)
-- -----------------------------------------------------------------------------
create table if not exists public.practice_attempts (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  target_letter char(1) references public.letters(letter),
  predicted_letter char(1) not null check (predicted_letter ~ '^[A-Z]$'),
  confidence double precision not null check (confidence >= 0 and confidence <= 1),
  is_correct boolean not null,
  inference_ms integer check (inference_ms is null or inference_ms >= 0),
  platform text not null default 'unknown' check (platform in ('web', 'android', 'unknown')),
  created_at timestamptz not null default now()
);

create index if not exists idx_practice_attempts_user_created
  on public.practice_attempts(user_id, created_at desc);

create index if not exists idx_practice_attempts_target_letter
  on public.practice_attempts(target_letter);

alter table public.practice_attempts enable row level security;

create policy "practice_attempts_select_own"
  on public.practice_attempts
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

create policy "practice_attempts_insert_own"
  on public.practice_attempts
  for insert
  to authenticated
  with check ((select auth.uid()) = user_id);

-- -----------------------------------------------------------------------------
-- 9. Tabel quest_completions (Penyelesaian Misi oleh Pengguna)
-- -----------------------------------------------------------------------------
create table if not exists public.quest_completions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  quest_id uuid not null references public.quests(id) on delete cascade,
  completed_at timestamptz not null default now(),
  unique (user_id, quest_id)
);

create index if not exists idx_quest_completions_user_id
  on public.quest_completions(user_id);

create index if not exists idx_quest_completions_quest_id
  on public.quest_completions(quest_id);

alter table public.quest_completions enable row level security;

create policy "quest_completions_select_own"
  on public.quest_completions
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

-- -----------------------------------------------------------------------------
-- 10. Tabel user_badges (Lencana yang Diperoleh Pengguna)
-- -----------------------------------------------------------------------------
create table if not exists public.user_badges (
  user_id uuid not null references auth.users(id) on delete cascade,
  badge_id uuid not null references public.badges(id) on delete cascade,
  earned_at timestamptz not null default now(),
  primary key (user_id, badge_id)
);

create index if not exists idx_user_badges_user_id
  on public.user_badges(user_id);

create index if not exists idx_user_badges_badge_id
  on public.user_badges(badge_id);

alter table public.user_badges enable row level security;

create policy "user_badges_select_own"
  on public.user_badges
  for select
  to authenticated
  using ((select auth.uid()) = user_id);

-- -----------------------------------------------------------------------------
-- 11. Tabel leaderboard_entries & View leaderboard_view (Aman dari Ekspos Email)
-- -----------------------------------------------------------------------------
create table if not exists public.leaderboard_entries (
  user_id uuid primary key references auth.users(id) on delete cascade,
  username text,
  display_name text not null,
  avatar_url text,
  xp integer not null default 0 check (xp >= 0),
  level integer not null default 1 check (level >= 1),
  current_streak integer not null default 0 check (current_streak >= 0),
  mastered_letters_count smallint not null default 0 check (mastered_letters_count >= 0),
  updated_at timestamptz not null default now()
);

create index if not exists idx_leaderboard_entries_ranking
  on public.leaderboard_entries(xp desc, mastered_letters_count desc, updated_at asc);

alter table public.leaderboard_entries enable row level security;

create policy "leaderboard_entries_select_authenticated"
  on public.leaderboard_entries
  for select
  to authenticated
  using (true);

create or replace view public.leaderboard_view
with (security_invoker = true)
as
select
  row_number() over (
    order by le.xp desc, le.mastered_letters_count desc, le.updated_at asc
  )::integer as rank,
  le.user_id,
  le.username,
  le.display_name,
  le.avatar_url,
  le.xp,
  le.level,
  le.current_streak,
  le.mastered_letters_count,
  le.updated_at
from public.leaderboard_entries le;

-- -----------------------------------------------------------------------------
-- 12. Trigger Otomatis Pembuatan Profil & Sinkronisasi Leaderboard
-- -----------------------------------------------------------------------------
create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_display_name text;
  v_username text;
begin
  v_display_name := coalesce(
    nullif(trim(new.raw_user_meta_data->>'display_name'), ''),
    nullif(split_part(coalesce(new.email, ''), '@', 1), ''),
    'Pelajar BISINDO'
  );
  v_username := lower(regexp_replace(v_display_name, '[^a-zA-Z0-9_]', '_', 'g'))
    || '_' || substr(replace(new.id::text, '-', ''), 1, 6);

  insert into public.profiles (id, username, display_name)
  values (new.id, v_username, v_display_name)
  on conflict (id) do nothing;

  insert into public.user_progress (user_id)
  values (new.id)
  on conflict (user_id) do nothing;

  insert into public.leaderboard_entries (user_id, username, display_name)
  values (new.id, v_username, v_display_name)
  on conflict (user_id) do nothing;

  return new;
end;
$$;

create or replace trigger on_auth_user_created
  after insert on auth.users
  for each row execute function private.handle_new_user();

create or replace function private.sync_profile_to_leaderboard()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  new.updated_at := now();
  insert into public.leaderboard_entries (user_id, username, display_name, avatar_url, updated_at)
  values (new.id, new.username, new.display_name, new.avatar_url, now())
  on conflict (user_id) do update
    set username = excluded.username,
        display_name = excluded.display_name,
        avatar_url = excluded.avatar_url,
        updated_at = now();
  return new;
end;
$$;

create or replace trigger on_profile_updated
  before update on public.profiles
  for each row execute function private.sync_profile_to_leaderboard();

-- -----------------------------------------------------------------------------
-- 13. Fungsi Internal & RPC Atomik Pencatatan Latihan (record_practice_attempt)
-- -----------------------------------------------------------------------------
create or replace function private.process_practice_attempt(
  p_user_id uuid,
  p_target_letter text,
  p_predicted_letter text,
  p_confidence double precision,
  p_is_correct boolean,
  p_inference_ms integer,
  p_platform text
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_target char(1);
  v_predicted char(1);
  v_platform text;
  v_attempt_id uuid;
  v_xp_base integer := 0;
  v_quest_xp integer := 0;
  v_prev_level integer := 1;
  v_new_xp integer := 0;
  v_new_level integer := 1;
  v_new_streak integer := 0;
  v_last_date date;
  v_today date := (now() at time zone 'Asia/Jakarta')::date;
  v_mastered_letter char(1);
  v_is_letter_mastered boolean := false;
  v_mastered_count smallint := 0;
  v_total_attempts integer := 0;
  v_correct_attempts integer := 0;
  v_two_hands_correct integer := 0;
  v_completed_quests jsonb := '[]'::jsonb;
  v_earned_badges jsonb := '[]'::jsonb;
  v_quest record;
  v_badge record;
  v_qualifies boolean;
begin
  if p_user_id is null then
    raise exception 'Unauthenticated user';
  end if;

  v_predicted := upper(trim(coalesce(p_predicted_letter, '')));
  if v_predicted !~ '^[A-Z]$' then
    raise exception 'Huruf prediksi harus A-Z, diterima: %', p_predicted_letter;
  end if;

  if p_target_letter is not null and trim(p_target_letter) <> '' then
    v_target := upper(trim(p_target_letter));
    if v_target !~ '^[A-Z]$' then
      raise exception 'Huruf target harus A-Z, diterima: %', p_target_letter;
    end if;
  end if;

  if p_confidence < 0 or p_confidence > 1 then
    raise exception 'Confidence harus berada di rentang 0..1';
  end if;

  v_platform := lower(trim(coalesce(p_platform, 'unknown')));
  if v_platform not in ('web', 'android', 'unknown') then
    v_platform := 'unknown';
  end if;

  -- Pastikan baris profil dan progres pengguna sudah ada
  insert into public.profiles (id, display_name)
  values (p_user_id, 'Pelajar BISINDO')
  on conflict (id) do nothing;

  insert into public.user_progress (user_id)
  values (p_user_id)
  on conflict (user_id) do nothing;

  -- 1. Catat attempt
  insert into public.practice_attempts (
    user_id, target_letter, predicted_letter, confidence, is_correct, inference_ms, platform
  )
  values (
    p_user_id, v_target, v_predicted, p_confidence, p_is_correct, p_inference_ms, v_platform
  )
  returning id into v_attempt_id;

  -- 2. Perbarui penguasaan huruf (user_letter_mastery)
  v_mastered_letter := coalesce(v_target, v_predicted);
  insert into public.user_letter_mastery (
    user_id, letter, total_attempts, correct_attempts, best_confidence, is_mastered, last_practiced_at
  )
  values (
    p_user_id,
    v_mastered_letter,
    1,
    case when p_is_correct then 1 else 0 end,
    case when p_is_correct then p_confidence else 0 end,
    (p_is_correct and p_confidence >= 0.85),
    now()
  )
  on conflict (user_id, letter) do update
    set total_attempts = public.user_letter_mastery.total_attempts + 1,
        correct_attempts = public.user_letter_mastery.correct_attempts + (case when p_is_correct then 1 else 0 end),
        best_confidence = greatest(
          public.user_letter_mastery.best_confidence,
          case when p_is_correct then p_confidence else 0 end
        ),
        is_mastered = public.user_letter_mastery.is_mastered
          or (
            (public.user_letter_mastery.correct_attempts + (case when p_is_correct then 1 else 0 end)) >= 2
            and greatest(public.user_letter_mastery.best_confidence, case when p_is_correct then p_confidence else 0 end) >= 0.70
          ),
        last_practiced_at = now()
  returning is_mastered into v_is_letter_mastered;

  -- 3. Hitung XP dasar (15 XP untuk target practice benar, 10 XP free practice benar, 2 XP partisipasi latihan)
  if p_is_correct then
    if v_target is not null then
      v_xp_base := 15;
    else
      v_xp_base := 10;
    end if;
  else
    v_xp_base := 2;
  end if;

  select level, current_streak, last_practice_date
    into v_prev_level, v_new_streak, v_last_date
    from public.user_progress
   where user_id = p_user_id
   for update;

  if v_last_date is null then
    v_new_streak := 1;
  elsif v_last_date = v_today then
    v_new_streak := greatest(v_new_streak, 1);
  elsif v_last_date = (v_today - 1) then
    v_new_streak := v_new_streak + 1;
  else
    v_new_streak := 1;
  end if;

  update public.user_progress
     set xp = xp + v_xp_base,
         total_attempts = total_attempts + 1,
         correct_attempts = correct_attempts + (case when p_is_correct then 1 else 0 end),
         current_streak = v_new_streak,
         last_practice_date = v_today,
         updated_at = now()
   where user_id = p_user_id
   returning total_attempts, correct_attempts into v_total_attempts, v_correct_attempts;

  select count(*)::smallint
    into v_mastered_count
    from public.user_letter_mastery
   where user_id = p_user_id and is_mastered = true;

  select count(*)::integer
    into v_two_hands_correct
    from public.practice_attempts pa
    join public.letters l on l.letter = coalesce(pa.target_letter, pa.predicted_letter)
   where pa.user_id = p_user_id
     and pa.is_correct = true
     and l.hand_count = 2;

  -- 4. Evaluasi penyelesaian Quest aktif yang belum diselesaikan pengguna
  for v_quest in
    select q.*
      from public.quests q
     where q.is_active = true
       and not exists (
         select 1
           from public.quest_completions qc
          where qc.user_id = p_user_id and qc.quest_id = q.id
       )
     order by q.sort_order asc
  loop
    v_qualifies := false;
    if v_quest.quest_type = 'practice_count' then
      v_qualifies := (v_total_attempts >= v_quest.target_value);
    elsif v_quest.quest_type = 'correct_count' then
      v_qualifies := (v_correct_attempts >= v_quest.target_value);
    elsif v_quest.quest_type = 'master_letters' then
      v_qualifies := (v_mastered_count >= v_quest.target_value);
    elsif v_quest.quest_type = 'two_hands_correct' then
      v_qualifies := (v_two_hands_correct >= v_quest.target_value);
    elsif v_quest.quest_type = 'specific_letters' then
      v_qualifies := (
        select count(*) >= coalesce(array_length(v_quest.target_letters, 1), 1)
          from public.user_letter_mastery ulm
         where ulm.user_id = p_user_id
           and ulm.correct_attempts >= 1
           and ulm.letter = any(v_quest.target_letters)
      );
    end if;

    if v_qualifies then
      insert into public.quest_completions (user_id, quest_id)
      values (p_user_id, v_quest.id)
      on conflict (user_id, quest_id) do nothing;

      v_quest_xp := v_quest_xp + v_quest.xp_reward;
      v_completed_quests := v_completed_quests || jsonb_build_array(
        jsonb_build_object(
          'code', v_quest.code,
          'title', v_quest.title,
          'xp_reward', v_quest.xp_reward
        )
      );
    end if;
  end loop;

  -- 5. Perbarui total XP & Level (setiap 100 XP naik 1 level)
  update public.user_progress
     set xp = xp + v_quest_xp,
         level = 1 + ((xp + v_quest_xp) / 100),
         updated_at = now()
   where user_id = p_user_id
   returning xp, level into v_new_xp, v_new_level;

  -- 6. Evaluasi pemberian Badge
  for v_badge in
    select b.*
      from public.badges b
     where not exists (
       select 1
         from public.user_badges ub
        where ub.user_id = p_user_id and ub.badge_id = b.id
     )
     order by b.sort_order asc
  loop
    v_qualifies := false;
    if v_badge.code = 'first_step' and v_correct_attempts >= 1 then
      v_qualifies := true;
    elsif v_badge.code = 'vowel_explorer' and (
      select count(*) = 5
        from public.user_letter_mastery ulm
       where ulm.user_id = p_user_id
         and ulm.correct_attempts >= 1
         and ulm.letter in ('A', 'I', 'U', 'E', 'O')
    ) then
      v_qualifies := true;
    elsif v_badge.code = 'two_hands_adept' and v_two_hands_correct >= 5 then
      v_qualifies := true;
    elsif v_badge.code = 'alphabet_scholar' and v_mastered_count >= 10 then
      v_qualifies := true;
    elsif v_badge.code = 'bisindo_master' and v_mastered_count >= 26 then
      v_qualifies := true;
    end if;

    if v_qualifies then
      insert into public.user_badges (user_id, badge_id)
      values (p_user_id, v_badge.id)
      on conflict (user_id, badge_id) do nothing;

      v_earned_badges := v_earned_badges || jsonb_build_array(
        jsonb_build_object(
          'code', v_badge.code,
          'title', v_badge.title,
          'icon_key', v_badge.icon_key
        )
      );
    end if;
  end loop;

  -- 7. Sinkronkan entri leaderboard publik
  insert into public.leaderboard_entries (
    user_id, username, display_name, avatar_url, xp, level, current_streak, mastered_letters_count, updated_at
  )
  select
    p.id, p.username, p.display_name, p.avatar_url,
    v_new_xp, v_new_level, v_new_streak, v_mastered_count, now()
  from public.profiles p
  where p.id = p_user_id
  on conflict (user_id) do update
    set username = excluded.username,
        display_name = excluded.display_name,
        avatar_url = excluded.avatar_url,
        xp = excluded.xp,
        level = excluded.level,
        current_streak = excluded.current_streak,
        mastered_letters_count = excluded.mastered_letters_count,
        updated_at = now();

  return jsonb_build_object(
    'attempt_id', v_attempt_id,
    'xp_gained', v_xp_base,
    'quest_xp_gained', v_quest_xp,
    'total_xp_gained', v_xp_base + v_quest_xp,
    'new_xp', v_new_xp,
    'new_level', v_new_level,
    'leveled_up', (v_new_level > v_prev_level),
    'current_streak', v_new_streak,
    'is_letter_mastered', v_is_letter_mastered,
    'mastered_letters_count', v_mastered_count,
    'completed_quests', v_completed_quests,
    'earned_badges', v_earned_badges
  );
end;
$$;

revoke all on function private.process_practice_attempt(uuid, text, text, double precision, boolean, integer, text) from public, anon, authenticated;

-- Endpoint RPC yang dipanggil aplikasi Flutter (SECURITY INVOKER memanggil helper tervalidasi)
create or replace function public.record_practice_attempt(
  p_target_letter text default null,
  p_predicted_letter text default '',
  p_confidence double precision default 0.0,
  p_is_correct boolean default false,
  p_inference_ms integer default null,
  p_platform text default 'unknown'
)
returns jsonb
language plpgsql
security invoker
set search_path = public
as $$
declare
  v_uid uuid := (select auth.uid());
begin
  if v_uid is null then
    raise exception 'Pengguna harus login untuk mencatat hasil latihan.';
  end if;

  return private.process_practice_attempt(
    v_uid,
    p_target_letter,
    p_predicted_letter,
    p_confidence,
    p_is_correct,
    p_inference_ms,
    p_platform
  );
end;
$$;

grant execute on function public.record_practice_attempt(text, text, double precision, boolean, integer, text) to authenticated;
revoke execute on function public.record_practice_attempt(text, text, double precision, boolean, integer, text) from anon, public;

-- Grant akses tabel untuk role authenticated
grant usage on schema public to anon, authenticated;
grant select, insert, update on public.profiles to authenticated;
grant select on public.letters to authenticated;
grant select on public.learning_guides to authenticated;
grant select on public.quests to authenticated;
grant select on public.badges to authenticated;
grant select on public.user_progress to authenticated;
grant select on public.user_letter_mastery to authenticated;
grant select, insert on public.practice_attempts to authenticated;
grant select on public.quest_completions to authenticated;
grant select on public.user_badges to authenticated;
grant select on public.leaderboard_entries to authenticated;
grant select on public.leaderboard_view to authenticated;
