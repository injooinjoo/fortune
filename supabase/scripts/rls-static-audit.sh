#!/usr/bin/env bash
#
# Static RLS audit: scans every migration under supabase/migrations/ to flag
# tables declared via CREATE TABLE that never receive ENABLE ROW LEVEL SECURITY
# in any migration. This is a fast, offline check that catches the most common
# pattern of "new table shipped without RLS".
#
# Complementary to rls-audit.sql which inspects the LIVE database.
#
# Exits non-zero when any unprotected tables are found, so it can be wired into
# CI as a pre-merge gate.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../migrations" && pwd)"

if [ ! -d "$ROOT" ]; then
  echo "error: migrations directory not found at $ROOT" >&2
  exit 2
fi

tables="$(grep -ih 'CREATE TABLE.*public\.' "$ROOT"/*.sql \
  | sed -E 's/.*CREATE TABLE (IF NOT EXISTS )?public\.([a-z_][a-z0-9_]*).*/\2/' \
  | sort -u)"

if [ -z "$tables" ]; then
  echo "No public.* tables found in migrations."
  exit 0
fi

unprotected=()
while IFS= read -r table; do
  if [ -z "$table" ]; then
    continue
  fi
  # A table is considered protected if any migration contains
  # `ALTER TABLE ... $table ... ENABLE ROW LEVEL SECURITY`.
  hit="$(grep -l "ALTER TABLE.*$table.*ENABLE ROW LEVEL SECURITY" "$ROOT"/*.sql 2>/dev/null || true)"
  if [ -z "$hit" ]; then
    hit2="$(grep -l "ALTER TABLE public.$table ENABLE ROW LEVEL SECURITY" "$ROOT"/*.sql 2>/dev/null || true)"
    if [ -z "$hit2" ]; then
      unprotected+=("$table")
    fi
  fi
done <<EOF
$tables
EOF

if [ "${#unprotected[@]}" -eq 0 ]; then
  echo "OK: every public table found in migrations has RLS enabled somewhere."
  exit 0
fi

echo "UNPROTECTED tables (no ENABLE ROW LEVEL SECURITY found in migrations):"
for t in "${unprotected[@]}"; do
  echo "  - $t"
done

echo ""
echo "Add a migration with 'ALTER TABLE public.<table> ENABLE ROW LEVEL SECURITY;'"
echo "and an appropriate policy for each. Then re-run this script."
exit 1
