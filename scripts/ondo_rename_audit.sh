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
  'Fortune 앱'
  'Fortune Flutter App'
  'Fortune - AI'
  'Beyond Fortune'
  'Fortune 개발팀'
  'Launching Fortune'
  '\[Fortune\]'
  'Fortune_Screenshots'
  'fortune-flutter-tests'
  'Fortune Icon Processor'
  '\bFortuneWidgetBundle\b'
  '\bFortuneOverallWidget\b'
  '\bFortuneCategoryWidget\b'
  '\bFortuneTimeSlotWidget\b'
  '\bFortuneLottoWidget\b'
  'struct FortuneWidget: Widget'
  'struct LoveFortuneWidget: Widget'
  'struct LockScreenFortuneWidget: Widget'
  'struct FavoritesFortuneWidget: Widget'
  '"FortuneWidget"'
  '"LoveFortuneWidget"'
  '"LockScreenFortuneWidget"'
  '"FavoritesFortuneWidget"'
)

status=0

search_targets=(
  AGENTS.md
  pubspec.yaml
  package.json
  package-lock.json
  node_modules/.package-lock.json
  CLAUDE.md
  flutter_log.txt
  .lcovrc
  .claude/agents
  .claude/docs
  .claude/plans
  .agents
  artifacts/design/mobile/v2/live_inventory.json
  lib
  test
  integration_test
  testsprite_tests
  playwright
  ios
  android
  macos
  web
  public
  docs
  scripts
  supabase
)

for pattern in "${patterns[@]}"; do
  if rg -n --hidden --glob '!**/.git/**' --glob '!scripts/ondo_rename_audit.sh' -e "$pattern" "${search_targets[@]}"; then
    echo
    echo "[ondo-rename-audit] forbidden pattern found: $pattern"
    status=1
  fi
done

if [[ $status -eq 0 ]]; then
  echo "[ondo-rename-audit] OK"
fi

exit "$status"
