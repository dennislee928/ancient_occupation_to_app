#!/bin/sh
set -eu

if [ -z "${DATABASE_URL:-}" ]; then
  echo "DATABASE_URL is required"
  exit 1
fi

psql "$DATABASE_URL" -v ON_ERROR_STOP=1 <<'SQL'
create table if not exists public.schema_migrations (
  filename text primary key,
  applied_at timestamptz not null default now()
);
SQL

for file in /workspace/db/migrations/*.up.sql; do
  [ -e "$file" ] || continue

  filename=$(basename "$file")
  already_applied=$(psql "$DATABASE_URL" -Atqc "select 1 from public.schema_migrations where filename = '$filename' limit 1")

  if [ "$already_applied" = "1" ]; then
    echo "Skipping $filename"
    continue
  fi

  echo "Applying $filename"
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -f "$file"
  psql "$DATABASE_URL" -v ON_ERROR_STOP=1 -c "insert into public.schema_migrations (filename) values ('$filename')"
done
