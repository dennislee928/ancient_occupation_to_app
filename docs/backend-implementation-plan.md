# Backend Implementation Plan

## Short Answer

This project does **not** need a backend to remain a single-phone prototype.

This project **does** need a backend if you want any of the following:

- accounts and login
- cross-device sync
- multi-user flows between friends or teammates
- push notifications
- read-once or expiring content
- audit trails, consent records, and trust settings
- shared event feeds or realtime updates

Given the five concepts already in the app, a backend is the correct next step if the product is moving beyond demo status.

## Why A Backend Is Needed Here

All five concepts become real products only when state leaves the device:

- `Whipping Boy`: pact records, partner consent, missed check-ins, and notification fan-out
- `Royal Taster`: queued message triage, proxy assignments, summaries, and access control
- `Sin Eater`: one-time delivery, read receipts, deletion lifecycle, and audit logs
- `Nomenclator`: shared people cards, live prompt sessions, and companion presence
- `Moirologist`: support squads, distress events, response fan-out, and message playback history

Without a backend, the current Flutter app remains a local simulation.

## Recommended Stack

Use four layers:

1. Flutter app as the only mobile client
2. Go API as the primary product backend
3. Ruby service for jobs, admin, and operations tooling
4. Supabase for Auth, Postgres, Storage, and optional Realtime

## Service Split

### Go API

Use Go for the user-facing product API:

- REST or JSON-over-HTTP endpoints for the Flutter app
- JWT verification for Supabase Auth tokens
- request validation and authorization rules
- core domain logic for pacts, prompts, confessions, squads, and message triage state
- idempotent write paths
- read APIs optimized for mobile latency

Recommended packages:

- router: `chi` or `gin`
- database: `pgx`
- config: env-based
- auth: Supabase JWT validation via JWKS

### Ruby Service

Use Ruby for async and operational work:

- scheduled reminder jobs
- push notification fan-out
- cleanup and expiry jobs
- admin review tools
- moderation or support tooling
- CSV export and internal ops scripts

Keep Ruby off the mobile hot path. Ruby should own background work and internal tooling, not the primary app API.

## Supabase Role

Use Supabase for:

- `auth.users` and sign-in flows
- Postgres as the system of record
- Storage for optional voice notes, attachments, and exported media
- Realtime only where it clearly helps, such as live prompt feeds

Use Supabase pooler mode for application traffic.

Operational rule:

- runtime app services connect through Supavisor transaction mode
- migrations and long-running admin tasks use a direct or session-mode connection

Reason:

- transaction mode is appropriate for app traffic and autoscaling
- transaction mode does not support prepared statements, so both Go and Ruby database clients must disable them

## Proposed Runtime Architecture

```text
Flutter App
  -> Go API
     -> Supabase Auth token verification
     -> Supabase Postgres via pooler
     -> Supabase Storage
     -> optional Supabase Realtime
  -> APNs / FCM device registration through Go API

Ruby Worker/Admin
  -> Supabase Postgres via pooler for short jobs
  -> direct or session connection for migrations / long admin tasks
  -> APNs / FCM fan-out
```

## Repo Layout To Add

```text
services/
  go/api/
    cmd/api/
    internal/
      auth/
      config/
      db/
      features/
      notifications/
      http/
    Dockerfile
  ruby/ops/
    app/
    config/
    lib/
    scripts/
    Dockerfile
infra/
  docker-compose.yml
  env/
db/
  migrations/
docs/
  backend-implementation-plan.md
```

## Core Domain Model

Start with shared tables before feature-specific ones.

### Shared Tables

- `profiles`
- `user_devices`
- `trust_relationships`
- `contacts`
- `notification_targets`
- `notification_events`
- `audit_events`
- `feature_memberships`

### Whipping Boy

- `whipping_pacts`
- `whipping_participants`
- `whipping_checkins`
- `whipping_consequences`

### Royal Taster

- `taster_threads`
- `taster_assignments`
- `taster_messages`
- `taster_summaries`

### Sin Eater

- `burdens`
- `burden_recipients`
- `burden_reads`
- `burden_purges`

### Nomenclator

- `people_cards`
- `encounter_sessions`
- `prompt_messages`

### Moirologist

- `support_squads`
- `support_squad_members`
- `distress_events`
- `support_replies`

## Security Model

Use a backend-first security model.

- Flutter should never connect directly to Postgres.
- Flutter authenticates with Supabase Auth and sends the JWT to Go.
- Go authorizes every domain action.
- Supabase service-role secrets stay server-side only.
- Enable RLS on app-owned tables even if most access goes through the backend.
- Treat `Sin Eater` data as the strictest boundary in the system.

Special handling for `Sin Eater`:

- encrypted-at-rest payload column or application-layer encryption for message content
- one-time read token semantics
- hard expiry timestamps
- deletion audit rows that retain metadata but not payload content

## API Shape

Build the API around feature slices, not around generic CRUD.

### Foundation Endpoints

- `POST /v1/devices/register`
- `GET /v1/me`
- `PATCH /v1/me`
- `GET /v1/feed`
- `GET /v1/notifications`

### Whipping Boy

- `POST /v1/whipping-boy/pacts`
- `POST /v1/whipping-boy/pacts/{id}/accept`
- `POST /v1/whipping-boy/pacts/{id}/checkins`

### Royal Taster

- `POST /v1/royal-taster/threads`
- `POST /v1/royal-taster/threads/{id}/messages`
- `POST /v1/royal-taster/threads/{id}/summaries`

### Sin Eater

- `POST /v1/sin-eater/burdens`
- `POST /v1/sin-eater/burdens/{id}/open`
- `POST /v1/sin-eater/burdens/{id}/purge`

### Nomenclator

- `POST /v1/nomenclator/sessions`
- `POST /v1/nomenclator/sessions/{id}/prompts`
- `GET /v1/nomenclator/sessions/{id}/stream`

### Moirologist

- `POST /v1/moirologist/events`
- `POST /v1/moirologist/events/{id}/reply`
- `GET /v1/moirologist/events/{id}`

## Implementation Order

### Phase 0: Foundation Decisions

- freeze the Flutter app as the primary client
- choose Go framework and Ruby framework
- decide whether Ruby admin is Rails-based or a lighter Sinatra/Roda app
- decide whether live updates use Supabase Realtime, SSE from Go, or polling

Recommended choice:

- Go: `chi` + `pgx`
- Ruby: Rails for admin and job scripts, but keep it operational, not user-facing
- realtime: start with polling, add SSE or Supabase Realtime only for `Nomenclator`

### Phase 1: Platform Foundation

- add `services/go/api`
- add `services/ruby/ops`
- add Dockerfiles for both services
- add `docker-compose.yml` for local orchestration
- add shared env templates
- add DB migration tooling
- add health checks and structured logs

Deliverable:

- `GET /healthz`
- verified Supabase connectivity from both services
- first migration applied successfully

### Phase 2: Identity And Devices

- integrate Supabase Auth
- create `profiles` and `user_devices`
- add device registration API for APNs and FCM tokens
- store notification preferences

Deliverable:

- users can sign in
- devices are registered
- one backend-authenticated endpoint works end to end

### Phase 3: First Real Feature Slice

Build `Nomenclator` first.

Reason:

- it proves accounts, shared data, sessions, and prompt delivery
- it is less privacy-sensitive than `Sin Eater`
- it exercises realtime patterns needed by the rest of the app

Deliverable:

- create people cards
- start an encounter session
- send prompt messages from one device/account to another

### Phase 4: Notification Backbone

- Ruby service polls notification outbox rows
- send APNs and FCM pushes
- add retry, dead-letter, and idempotency keys
- add quiet hours and rate limits

Deliverable:

- `Whipping Boy` reminders
- `Moirologist` distress fan-out
- prompt nudges for `Nomenclator`

### Phase 5: Remaining Feature Backends

Order:

1. `Whipping Boy`
2. `Moirologist`
3. `Royal Taster`
4. `Sin Eater`

Reason:

- `Whipping Boy` and `Moirologist` are straightforward event systems
- `Royal Taster` needs delegated access patterns
- `Sin Eater` has the hardest privacy and lifecycle requirements

### Phase 6: Hardening

- observability
- request tracing
- audit event viewer
- abuse controls
- admin tooling
- backups and restore drills
- load testing on pooler connections

## Supabase Pooler Notes

Follow these constraints in implementation:

- use transaction mode for runtime service connections
- disable prepared statements in Go and Ruby clients
- do not run schema migrations through transaction-pooled app connections
- keep long-running maintenance work off transaction mode

For this project, that means:

- Go API uses transaction mode for normal requests
- Ruby worker uses transaction mode for short jobs
- migration runner uses direct or session mode

## Docker Plan

Create two service Dockerfiles and one compose file.

### Go Dockerfile

- multi-stage build
- static binary output
- non-root runtime user

### Ruby Dockerfile

- bundle install layer caching
- non-root runtime user
- separate entrypoints for worker and admin

### Compose Services

- `go-api`
- `ruby-ops`
- optional `mailpit` for local email tests

Supabase itself remains hosted, not containerized locally.

## CI/CD Plan

Add backend pipelines after the mobile pipeline is stable.

### Go CI

- format
- lint
- unit tests
- build container image

### Ruby CI

- bundle audit
- tests
- build container image

### Deployment Strategy

- deploy Go API and Ruby ops separately
- inject Supabase pooler URLs and service credentials via secrets
- run migrations as a dedicated job before app rollout

## Risks

The main architectural risks are:

- overusing Supabase direct client access from mobile and bypassing backend rules
- pushing too much product logic into Ruby jobs instead of Go domain services
- trying to build `Sin Eater` before auth, audit, and deletion semantics are proven
- using transaction pooler connections with prepared statements still enabled
- letting every feature invent its own notification flow instead of using one outbox model

## Recommended Next Step

Do this next:

1. approve the stack split: Flutter + Go API + Ruby ops + Supabase
2. choose `Nomenclator` as the first backend-backed feature
3. scaffold `services/go/api`, `services/ruby/ops`, `db/migrations`, and `infra/docker-compose.yml`
4. implement auth, profiles, devices, and one end-to-end prompt session flow
