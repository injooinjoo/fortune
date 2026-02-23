#!/usr/bin/env bash
set -euo pipefail

BRANCH="${1:-$(git rev-parse --abbrev-ref HEAD)}"
LIMIT="${2:-5}"
WATCH="${3:-false}"

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI is not installed."
  exit 1
fi

echo "== GitHub Actions (branch: ${BRANCH}) =="
gh run list --branch "${BRANCH}" --limit "${LIMIT}"

LATEST_RUN_ID="$(gh run list --branch "${BRANCH}" --limit 1 --json databaseId --jq '.[0].databaseId // empty')"
if [[ -z "${LATEST_RUN_ID}" ]]; then
  echo "No workflow runs found for branch ${BRANCH}."
  exit 0
fi

echo "Latest run id: ${LATEST_RUN_ID}"
if [[ "${WATCH}" == "true" ]]; then
  gh run watch "${LATEST_RUN_ID}" --exit-status
fi
