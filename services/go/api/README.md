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
- `SUPABASE_JWT_SECRET`

Use the transaction-mode pooler URL here for runtime traffic.

## Local Auth

Until full Supabase JWKS verification is added, development mode supports:

- `X-Debug-User-ID: <uuid-or-stable-id>`

If `SUPABASE_JWT_SECRET` is present, the API will also accept HS256 bearer tokens and use the `sub` claim as the authenticated user id.
