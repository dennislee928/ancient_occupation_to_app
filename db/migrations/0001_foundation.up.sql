create extension if not exists pgcrypto;

create table if not exists public.profiles (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique,
  display_name text,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.user_devices (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  platform text not null check (platform in ('ios', 'android')),
  push_token text not null,
  push_provider text not null check (push_provider in ('apns', 'fcm')),
  app_version text,
  last_seen_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index if not exists user_devices_push_token_idx
  on public.user_devices (push_token);

create index if not exists user_devices_user_id_idx
  on public.user_devices (user_id);

create table if not exists public.audit_events (
  id uuid primary key default gen_random_uuid(),
  actor_user_id uuid,
  action text not null,
  entity_type text not null,
  entity_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists audit_events_actor_user_id_idx
  on public.audit_events (actor_user_id, created_at desc);
