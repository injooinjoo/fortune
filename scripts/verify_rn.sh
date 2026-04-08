#!/bin/bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

run_smoke=false
run_e2e=false

for arg in "$@"; do
  case "$arg" in
    --smoke)
      run_smoke=true
      ;;
    --e2e)
      run_e2e=true
      ;;
    *)
      echo "Unknown option: $arg" >&2
      echo "Usage: $0 [--smoke] [--e2e]" >&2
      exit 1
      ;;
  esac
done

cd "$ROOT_DIR"

echo "==> RN workspace typecheck"
npm run rn:typecheck

echo "==> RN workspace tests"
npm run rn:test

if [ "$run_smoke" = true ]; then
  echo "==> Playwright smoke"
  npm run test:smoke:ci
fi

if [ "$run_e2e" = true ]; then
  echo "==> Playwright E2E"
  npm run test:e2e:ci
fi
