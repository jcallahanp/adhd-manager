-- M1-01: core tables for "sort a thought" (D-006), with row-level security on every table.
-- Clients (role authenticated) only touch their own rows and only the columns granted below.
-- The worker uses service_role, which bypasses RLS. anon gets nothing.

create type public.bucket as enum (
  'tool_can_do', 'do_now', 'quick_task', 'long_term_goal', 'learning', 'idea_note', 'parked'
);
create type public.capture_status as enum ('queued', 'needs_key', 'processing', 'done', 'failed');
create type public.item_status as enum ('filed', 'needs_answer');

create function public.set_updated_at() returns trigger
language plpgsql set search_path = '' as $$
begin
  new.updated_at := now();
  return new;
end;
$$;
revoke execute on function public.set_updated_at() from public, anon, authenticated;

-- profiles: one row per auth user, made by a trigger
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text check (char_length(display_name) <= 100),
  created_at timestamptz not null default now()
);

create function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  insert into public.profiles (id) values (new.id);
  return new;
end;
$$;
revoke execute on function public.handle_new_user() from public, anon, authenticated;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- api_keys: the user's own Anthropic key, encrypted by the server. Clients never read ciphertext.
create table public.api_keys (
  user_id uuid primary key default auth.uid() references auth.users (id) on delete cascade,
  ciphertext text not null,
  last4 text not null check (char_length(last4) = 4),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- captures: the original text, saved untouched before any Claude call. id is made by the client.
create table public.captures (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  raw_text text not null check (char_length(raw_text) between 1 and 20000),
  status public.capture_status not null default 'queued',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id, user_id)
);
create index captures_user_created on public.captures (user_id, created_at desc);

-- items: one per thought Claude found in a capture. Same owner as the capture (composite key).
create table public.items (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  capture_id uuid not null,
  source_span text not null,
  title text not null check (char_length(title) between 1 and 500),
  bucket public.bucket not null,
  confidence numeric(4, 3) not null check (confidence between 0 and 1),
  alt_bucket public.bucket,
  due_date date,
  due_inferred boolean not null default false,
  status public.item_status not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (id, user_id),
  foreign key (capture_id, user_id) references public.captures (id, user_id) on delete cascade
);
create index items_user_created on public.items (user_id, created_at desc);
create index items_capture on public.items (capture_id);

-- triage_corrections: the user moved an item; kept for future prompt examples.
create table public.triage_corrections (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null default auth.uid() references auth.users (id) on delete cascade,
  item_id uuid not null,
  from_bucket public.bucket not null,
  to_bucket public.bucket not null,
  created_at timestamptz not null default now(),
  foreign key (item_id, user_id) references public.items (id, user_id) on delete cascade
);
create index triage_corrections_item on public.triage_corrections (item_id);

create trigger set_updated_at before update on public.api_keys
  for each row execute function public.set_updated_at();
create trigger set_updated_at before update on public.captures
  for each row execute function public.set_updated_at();
create trigger set_updated_at before update on public.items
  for each row execute function public.set_updated_at();

-- Row-level security on every table
alter table public.profiles enable row level security;
alter table public.api_keys enable row level security;
alter table public.captures enable row level security;
alter table public.items enable row level security;
alter table public.triage_corrections enable row level security;

-- Grants: replace Supabase's default "all to anon, authenticated" with the minimum.
revoke all on public.profiles, public.api_keys, public.captures, public.items, public.triage_corrections
  from anon, authenticated;

grant select, update (display_name) on public.profiles to authenticated;
grant select (user_id, last4, created_at, updated_at),
      insert (user_id, ciphertext, last4),
      update (ciphertext, last4),
      delete
  on public.api_keys to authenticated;
grant select, insert (id, user_id, raw_text, status) on public.captures to authenticated;
grant select, update (bucket, status) on public.items to authenticated;
grant select, insert (item_id, user_id, from_bucket, to_bucket) on public.triage_corrections to authenticated;

create policy "own profile" on public.profiles for select to authenticated
  using (id = (select auth.uid()));
create policy "own profile update" on public.profiles for update to authenticated
  using (id = (select auth.uid())) with check (id = (select auth.uid()));

create policy "own key" on public.api_keys for select to authenticated
  using (user_id = (select auth.uid()));
create policy "own key insert" on public.api_keys for insert to authenticated
  with check (user_id = (select auth.uid()));
create policy "own key update" on public.api_keys for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
create policy "own key delete" on public.api_keys for delete to authenticated
  using (user_id = (select auth.uid()));

create policy "own captures" on public.captures for select to authenticated
  using (user_id = (select auth.uid()));
create policy "own captures insert" on public.captures for insert to authenticated
  with check (user_id = (select auth.uid()) and status = 'queued');

create policy "own items" on public.items for select to authenticated
  using (user_id = (select auth.uid()));
create policy "own items update" on public.items for update to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

create policy "own corrections" on public.triage_corrections for select to authenticated
  using (user_id = (select auth.uid()));
create policy "own corrections insert" on public.triage_corrections for insert to authenticated
  with check (user_id = (select auth.uid()));
