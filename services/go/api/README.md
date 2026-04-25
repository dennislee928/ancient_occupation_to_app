# Go API

Primary backend service for the Flutter app.

Current Phase 1 scope:

- boot HTTP server
- expose `/healthz`
- expose `/readyz`
- connect to Supabase Postgres through the pooler URL
- disable prepared statements for Supavisor transaction mode compatibility

## Environment

- `APP_ENV`
- `API_PORT`
- `LOG_LEVEL`
- `SUPABASE_DATABASE_URL`

Use the transaction-mode pooler URL here for runtime traffic.
