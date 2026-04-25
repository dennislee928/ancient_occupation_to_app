create table if not exists public.people_cards (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid not null,
  name text not null,
  affiliation text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists people_cards_owner_user_id_idx
  on public.people_cards (owner_user_id, updated_at desc);

create table if not exists public.encounter_sessions (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid not null,
  companion_user_id uuid,
  person_card_id uuid not null references public.people_cards(id) on delete cascade,
  context_label text,
  status text not null default 'active' check (status in ('active', 'archived')),
  created_at timestamptz not null default now()
);

create index if not exists encounter_sessions_owner_user_id_idx
  on public.encounter_sessions (owner_user_id, created_at desc);

create index if not exists encounter_sessions_companion_user_id_idx
  on public.encounter_sessions (companion_user_id, created_at desc);

create table if not exists public.prompt_messages (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.encounter_sessions(id) on delete cascade,
  sender_user_id uuid not null,
  body text not null,
  delivery_mode text not null default 'manual' check (delivery_mode in ('manual', 'quiet', 'urgent')),
  created_at timestamptz not null default now()
);

create index if not exists prompt_messages_session_id_idx
  on public.prompt_messages (session_id, created_at asc);
