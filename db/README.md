# Database

This directory holds SQL migrations for the Supabase Postgres database.

Current Phase 1 coverage:

- `profiles`
- `user_devices`
- `audit_events`

## Runtime Connection Rules

- app services use the Supavisor transaction pooler URL
- migrations use a direct or session-mode URL
- do not run migrations through the transaction pooler
