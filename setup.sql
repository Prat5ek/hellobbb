-- Run this entire script in Supabase SQL Editor (one click)
-- Dashboard > SQL Editor > New query > paste this > Run

-- 1. Users table
create table if not exists public.users (
  id           uuid primary key,
  email        text unique not null,
  display_name text,
  joined_at    timestamptz default now(),
  user_number  int
);

-- 2. Messages table
create table if not exists public.messages (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid references auth.users(id),
  sender_email text not null,
  sender_name  text,
  text         text not null,
  created_at   timestamptz default now()
);

-- 3. Enable realtime on messages
alter publication supabase_realtime add table public.messages;

-- 4. Row Level Security
alter table public.users    enable row level security;
alter table public.messages enable row level security;

-- 5. Policies for users table
create policy "Users can read all users"
  on public.users for select
  using (auth.role() = 'authenticated');

create policy "Users can insert their own record"
  on public.users for insert
  with check (auth.uid() = id);

-- 6. Policies for messages table
create policy "Authenticated users can read messages"
  on public.messages for select
  using (auth.role() = 'authenticated');

create policy "Authenticated users can insert messages"
  on public.messages for insert
  with check (auth.role() = 'authenticated');
