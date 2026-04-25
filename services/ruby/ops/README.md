# Ruby Ops

Operational backend service for background and admin concerns.

Current Phase 1 scope:

- boot a lightweight HTTP health server
- expose `/healthz`
- expose `/readyz`
- verify Supabase Postgres connectivity
- provide a simple worker heartbeat script

## Environment

- `APP_ENV`
- `OPS_PORT`
- `LOG_LEVEL`
- `SUPABASE_DATABASE_URL`

Use the transaction-mode pooler URL here for short-lived worker traffic.
