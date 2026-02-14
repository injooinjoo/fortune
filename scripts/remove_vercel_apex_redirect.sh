#!/usr/bin/env bash
set -euo pipefail

if [ "${VERCEL_TOKEN:-}" = "" ]; then
  echo "ERROR: VERCEL_TOKEN is required."
  echo "export VERCEL_TOKEN=... (from https://vercel.com/account/tokens)"
  exit 1
fi

if [ "${VERCEL_PROJECT:-}" = "" ]; then
  echo "ERROR: VERCEL_PROJECT is required."
  echo "export VERCEL_PROJECT=zpzg-landing"
  exit 1
fi

DOMAIN="${1:-zpzg.co.kr}"
ENDPOINT="https://api.vercel.com/v9/projects/${VERCEL_PROJECT}/domains/${DOMAIN}"

if [ "${VERCEL_TEAM_ID:-}" != "" ]; then
  ENDPOINT="${ENDPOINT}?teamId=${VERCEL_TEAM_ID}"
fi

echo "=== Current domain config ==="
curl -sS -H "Authorization: Bearer ${VERCEL_TOKEN}" "${ENDPOINT}" | cat
echo
echo "=== Patch: remove redirect ==="
curl -sS -X PATCH \
  -H "Authorization: Bearer ${VERCEL_TOKEN}" \
  -H "Content-Type: application/json" \
  "${ENDPOINT}" \
  -d '{"redirect":null,"redirectStatusCode":null,"gitBranch":null}'
echo
