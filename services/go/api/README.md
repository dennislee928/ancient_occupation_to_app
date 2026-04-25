# Go API

Primary backend service for the Flutter app.

Current Phase 1 scope:

- boot HTTP server
- expose `/healthz`
- expose `/readyz`
- connect to Supabase Postgres through the pooler URL
- disable prepared statements for Supavisor transaction mode compatibility

Current Phase 2 slice:

- `GET /v1/me`
- `PATCH /v1/me`
- `POST /v1/devices/register`
- `GET /v1/nomenclator/people`
- `POST /v1/nomenclator/people`
- `POST /v1/nomenclator/sessions`
- `GET /v1/nomenclator/sessions/{sessionID}`
- `POST /v1/nomenclator/sessions/{sessionID}/prompts`

Layering:

- `dto`: incoming request payloads
- `vto`: outgoing response views

## Environment

- `APP_ENV`
- `API_PORT`
- `LOG_LEVEL`
- `SUPABASE_DATABASE_URL`
- `SUPABASE_URL`
- `SUPABASE_API_KEY`
- `SUPABASE_JWT_SECRET`

Use the transaction-mode pooler URL here for runtime traffic.

## Local Auth

Auth verification order:

1. Supabase JWKS from `SUPABASE_URL/auth/v1/.well-known/jwks.json`
2. Supabase Auth server fallback via `GET /auth/v1/user` using `SUPABASE_API_KEY`
3. Legacy HS256 verification via `SUPABASE_JWT_SECRET`

Development mode still supports:

- `X-Debug-User-ID: <uuid-or-stable-id>`

This header is only accepted outside production.
