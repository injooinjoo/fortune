#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

patterns=(
  'ZPZG'
  '지피지기'
  'package:fortune/'
  'com\.beyond\.fortune'
  'group\.com\.beyond\.fortune'
  '^name:\s*fortune$'
  'FortuneWatch'
  'FortuneWidgetExtension'
)

status=0

for pattern in "${patterns[@]}"; do
  if rg -n --hidden --glob '!**/.git/**' -e "$pattern" pubspec.yaml lib test integration_test ios android macos web docs; then
    echo
    echo "[ondo-rename-audit] forbidden pattern found: $pattern"
    status=1
  fi
done

if [[ $status -eq 0 ]]; then
  echo "[ondo-rename-audit] OK"
fi

exit "$status"
