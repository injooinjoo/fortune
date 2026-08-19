#!/usr/bin/env bash
#
# Static security audit over supabase/migrations/. Two gates:
#
#   [1] RLS      — tables declared via CREATE TABLE that never receive
#                  ENABLE ROW LEVEL SECURITY in any migration.
#   [2] RPC ACL  — SECURITY DEFINER functions that take a p_user_id argument
#                  (i.e. can act on an arbitrary user) but are never revoked
#                  from PUBLIC/anon/authenticated in any migration.
#
# Gate [2] exists because the 2026-06 hardening sweep only covered 4 of the
# money RPCs. Live introspection on 2026-08-18 found grant_purchase_tokens_atomic,
# consume_token_atomic and refund_token_atomic still executable by anon — a
# public token-minting endpoint. No script in this repo checked function ACLs.
#
# Complementary to rls-audit.sql which inspects the LIVE database.
# Exits non-zero when either gate fails, so it can be wired into CI.

set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../migrations" && pwd)"

if [ ! -d "$ROOT" ]; then
  echo "error: migrations directory not found at $ROOT" >&2
  exit 2
fi

# ---------------------------------------------------------------------------
# [1] RLS gate
# ---------------------------------------------------------------------------
#
# The previous extractor required a `public.` prefix:
#   grep -ih 'CREATE TABLE.*public\.'
# Most tables in this repo are declared unqualified (`CREATE TABLE IF NOT EXISTS
# verified_purchases`), so it inspected only ~26 of ~100 tables and silently
# skipped verified_purchases, daily_free_fortune, long_running_jobs, fcm_tokens
# and every other unqualified declaration. Both forms are matched now.

tables="$(grep -ihE 'CREATE TABLE( IF NOT EXISTS)? +(public\.)?[a-z_][a-z0-9_]*' "$ROOT"/*.sql \
  | sed -E 's/.*CREATE TABLE( IF NOT EXISTS)? +(public\.)?([a-z_][a-z0-9_]*).*/\3/I' \
  | sort -u)"

unprotected=()
if [ -n "$tables" ]; then
  while IFS= read -r table; do
    [ -z "$table" ] && continue
    hit="$(grep -lE "ALTER TABLE.*(public\.)?$table.* ENABLE ROW LEVEL SECURITY" "$ROOT"/*.sql 2>/dev/null || true)"
    if [ -z "$hit" ]; then
      unprotected+=("$table")
    fi
  done <<EOF
$tables
EOF
fi

# ---------------------------------------------------------------------------
# [2] SECURITY DEFINER RPC ACL gate
# ---------------------------------------------------------------------------
#
# Scope: functions that accept p_user_id. Those can operate on a caller-supplied
# identity, so leaving them executable by anon/authenticated is a privilege
# escalation regardless of table RLS (SECURITY DEFINER bypasses it).
#
# A function is considered locked down if any migration REVOKEs it. Functions
# intentionally callable by authenticated (e.g. those with an internal
# auth.uid() = p_user_id guard) still need at least a REVOKE ... FROM PUBLIC,
# which this check accepts.

sec_def_fns="$(awk '
  /CREATE (OR REPLACE )?FUNCTION/ { fn=""; if (match($0, /FUNCTION +(public\.)?[a-zA-Z_][a-zA-Z0-9_]*/)) {
      fn=substr($0, RSTART, RLENGTH); sub(/FUNCTION +(public\.)?/, "", fn); current=fn; hasuser=0; secdef=0 } }
  /p_user_id/ { hasuser=1 }
  /SECURITY DEFINER/ { secdef=1 }
  /\$\$;|\$function\$;/ { if (current != "" && hasuser == 1 && secdef == 1) print current; current=""; hasuser=0; secdef=0 }
' "$ROOT"/*.sql | sort -u)"

unrevoked=()
if [ -n "$sec_def_fns" ]; then
  while IFS= read -r fn; do
    [ -z "$fn" ] && continue
    # Satisfied by a literal REVOKE, or by an explicit ack marker for cases where
    # the REVOKE has to be emitted dynamically (function may not exist in every
    # environment, so a plain REVOKE would abort the migration):
    #   -- audit-ack: <fn> — <reason>
    hit="$(grep -lE "REVOKE .*(public\.)?$fn *\(" "$ROOT"/*.sql 2>/dev/null || true)"
    if [ -z "$hit" ]; then
      hit="$(grep -lE "^-- audit-ack: *$fn( |$)" "$ROOT"/*.sql 2>/dev/null || true)"
    fi
    if [ -z "$hit" ]; then
      unrevoked+=("$fn")
    fi
  done <<EOF
$sec_def_fns
EOF
fi

# ---------------------------------------------------------------------------
# Report
# ---------------------------------------------------------------------------

status=0

if [ "${#unprotected[@]}" -eq 0 ]; then
  echo "OK [1/2] RLS: every table found in migrations has RLS enabled somewhere."
else
  status=1
  echo "FAIL [1/2] UNPROTECTED tables (no ENABLE ROW LEVEL SECURITY in migrations):"
  for t in "${unprotected[@]}"; do
    echo "  - $t"
  done
  echo ""
  echo "  Fix: add 'ALTER TABLE public.<table> ENABLE ROW LEVEL SECURITY;' plus a policy."
fi

echo ""

if [ "${#unrevoked[@]}" -eq 0 ]; then
  echo "OK [2/2] RPC ACL: every SECURITY DEFINER function taking p_user_id is revoked somewhere."
else
  status=1
  echo "FAIL [2/2] SECURITY DEFINER functions with p_user_id and no REVOKE:"
  for f in "${unrevoked[@]}"; do
    echo "  - $f"
  done
  echo ""
  echo "  Fix: add 'REVOKE ALL ON FUNCTION public.<fn>(<args>) FROM PUBLIC, anon, authenticated;'"
  echo "       followed by 'GRANT EXECUTE ... TO service_role;' if a worker needs it."
  echo "  NOTE: this is a static check over migrations. It cannot see grants made"
  echo "        out-of-band in the dashboard — verify with rls-audit.sql against live."
fi

exit $status
