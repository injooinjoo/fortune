#!/usr/bin/env bash
# Fortune 가격 SoT → Edge generated 파일 동기화.
#
# Source: packages/product-contracts/src/fortune-pricing.ts (SoT)
# Output: supabase/functions/_shared/fortune-pricing-generated.ts
#
# 실행: pnpm sync:edge-pricing  (root package.json)
# CI/precommit hook 가 generated 파일이 SoT 와 sync 되어 있는지 검증.

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOT="$ROOT/packages/product-contracts/src/fortune-pricing.ts"
OUT="$ROOT/supabase/functions/_shared/fortune-pricing-generated.ts"

if [ ! -f "$SOT" ]; then
  echo "ERROR: SoT 파일 없음: $SOT" >&2
  exit 1
fi

mkdir -p "$(dirname "$OUT")"

# 헤더 + SoT 본문 그대로 복사.
# SoT 파일은 self-contained 여야 함 (import 금지). 본 스크립트는 단순 텍스트 복사.
{
  cat <<'HEADER'
// AUTO-GENERATED FILE — DO NOT EDIT DIRECTLY.
//
// Source: packages/product-contracts/src/fortune-pricing.ts
// Regenerate: pnpm sync:edge-pricing
//
// 본 파일을 직접 수정하면 precommit / CI 가 fail. 가격 변경은 SoT 에서.
HEADER
  echo
  cat "$SOT"
} > "$OUT"

echo "✓ Synced: $OUT"
