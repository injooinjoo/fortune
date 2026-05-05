#!/bin/bash
#
# Stop hook entrypoint — Claude Code 가 한 턴 종료할 때마다 호출되어,
# 그 턴에서 발생한 변경을 "분석 + 검증 + 다음 단계 안내" 하는 리뷰 게이트.
#
# 정책 (2026-05-03 갱신, feedback_deploy_to_phone.md):
#   "코드 변경 후 자동 배포 X. 변경 요약 + tsc 검증 + 다음 명령 안내만.
#    실제 배포(supabase functions deploy / eas update)는 사용자가 직접
#    트리거하거나 명시적으로 '배포해' 라고 요청했을 때만 수행."
#
# 모드:
#   기본 (리뷰 모드)    : 분석 + tsc + 명령 안내, 실제 배포 X
#   자동 배포 모드      : AUTO_DEPLOY_ON=1 또는 .claude/.auto-deploy-on 존재 시
#                          — 기존 동작 (Edge Function + OTA 자동 푸시)
#   완전 OFF           : AUTO_DEPLOY_OFF=1 또는 .claude/.auto-deploy-off 존재 시 — no-op
#
# 분기:
#   1) Working tree clean ............................. → no-op
#   2) Marker hash == current diff hash ................ → no-op (이미 보고됨)
#   3) Native 영역 변경 감지 ........................... → ❌ EAS build 필요 안내
#   4) supabase/migrations 변경 ....................... → ⚠️ supabase db push 필요
#   5) supabase/functions 변경 ......................... → 배포 후보 목록 + 명령 안내
#                                                          (auto-on 시 실제 배포)
#   6) JS/TSX 변경 .................................... → tsc 검증 + OTA 명령 안내
#                                                          (auto-on 시 실제 OTA)
#
# 항상 exit 0 — Stop hook 이 비정상 종료하면 Claude Code 메인 루프가 막힌다.

set +e
cd "$(dirname "$0")/.." || exit 0
REPO_ROOT="$(pwd)"
MARKER="$REPO_ROOT/.claude/.last-deploy-hash"

ts() { date '+%Y-%m-%d %H:%M:%S'; }
log() { printf '\n[review-gate %s] %s\n' "$(ts)" "$*"; }

# 완전 OFF 스위치
if [ -n "$AUTO_DEPLOY_OFF" ] || [ -f "$REPO_ROOT/.claude/.auto-deploy-off" ]; then
  log "⏸  AUTO_DEPLOY_OFF — 분석/안내 모두 건너뜀."
  exit 0
fi

# 자동 배포 옵트인 — 기본은 false (리뷰 모드)
AUTO_ON=0
if [ -n "$AUTO_DEPLOY_ON" ] || [ -f "$REPO_ROOT/.claude/.auto-deploy-on" ]; then
  AUTO_ON=1
fi

# ───────────────────────────────────────────────────────────────────
# 0) git 저장소 확인
# ───────────────────────────────────────────────────────────────────
if ! git -C "$REPO_ROOT" rev-parse --git-dir >/dev/null 2>&1; then
  exit 0
fi

# ───────────────────────────────────────────────────────────────────
# 1) 변경 영역 파악 (uncommitted + untracked)
# ───────────────────────────────────────────────────────────────────
DIFF_PATHS=$(
  {
    git -C "$REPO_ROOT" diff --name-only HEAD -- \
      apps/mobile-rn/ \
      supabase/functions/ \
      supabase/migrations/ \
      packages/
    git -C "$REPO_ROOT" ls-files --others --exclude-standard \
      apps/mobile-rn/ \
      supabase/functions/ \
      supabase/migrations/ \
      packages/
  } | sort -u
)

if [ -z "$DIFF_PATHS" ]; then
  exit 0   # working tree clean — 보고할 게 없음
fi

CURRENT_HASH=$(printf '%s' "$DIFF_PATHS" | shasum | cut -c1-12)
LAST_HASH=$(cat "$MARKER" 2>/dev/null)

if [ "$CURRENT_HASH" = "$LAST_HASH" ]; then
  exit 0   # 이번 턴에 추가 변경 없음 → 직전 보고 그대로 유효
fi

# ───────────────────────────────────────────────────────────────────
# 2) 변경 분류
# ───────────────────────────────────────────────────────────────────
NATIVE_CHANGE=$(
  printf '%s\n' "$DIFF_PATHS" | grep -E '^(apps/mobile-rn/(app\.config\.ts|app\.json|plugins/|targets/|ios/|android/))' || true
)

if printf '%s\n' "$DIFF_PATHS" | grep -q '^apps/mobile-rn/package\.json$'; then
  DEP_DIFF=$(
    git -C "$REPO_ROOT" diff -- apps/mobile-rn/package.json 2>/dev/null \
      | grep -E '^[+-][[:space:]]+"(expo-|react-native-|@expo/|@react-native)' || true
  )
  if [ -n "$DEP_DIFF" ]; then
    NATIVE_CHANGE=$(printf '%s\napps/mobile-rn/package.json (네이티브 의존성 변경)\n' "$NATIVE_CHANGE")
  fi
fi

MIGRATION_CHANGE=$(printf '%s\n' "$DIFF_PATHS" | grep -E '^supabase/migrations/' || true)

EDGE_FUNCS=$(
  printf '%s\n' "$DIFF_PATHS" \
    | grep -E '^supabase/functions/' \
    | grep -v -E '^supabase/functions/_shared/' \
    | awk -F/ '{print $3}' \
    | sort -u
)
SHARED_CHANGE=$(printf '%s\n' "$DIFF_PATHS" | grep -E '^supabase/functions/_shared/' || true)
if [ -n "$SHARED_CHANGE" ] && [ -z "$EDGE_FUNCS" ]; then
  EDGE_FUNCS=$(
    grep -rl '_shared/' supabase/functions/*/index.ts 2>/dev/null \
      | awk -F/ '{print $3}' \
      | sort -u
  )
fi

RN_JS_CHANGE=$(
  printf '%s\n' "$DIFF_PATHS" \
    | grep -E '^(apps/mobile-rn/(app|src|assets)/|packages/)' || true
)

# ───────────────────────────────────────────────────────────────────
# 3) Native 변경 → 무조건 안내만 (EAS build 필요)
# ───────────────────────────────────────────────────────────────────
if [ -n "$NATIVE_CHANGE" ] && [ "$NATIVE_CHANGE" != "$(printf '\n')" ]; then
  log "❌ Native 영역 변경 — OTA 불가, EAS build 필요."
  printf '   변경된 native 경로:\n'
  printf '%s\n' "$NATIVE_CHANGE" | grep -v '^$' | sed 's/^/     - /'
  printf '\n   👉 다음 명령 (사용자 직접 실행):\n'
  printf '     cd apps/mobile-rn && pnpm deploy:native\n\n'
  exit 0
fi

# ───────────────────────────────────────────────────────────────────
# 4) DB 마이그레이션 → 안내만 (destructive 위험)
# ───────────────────────────────────────────────────────────────────
if [ -n "$MIGRATION_CHANGE" ]; then
  log "⚠️  DB 마이그레이션 변경 — 사용자 컨펌 후 적용."
  printf '   변경된 마이그레이션:\n'
  printf '%s\n' "$MIGRATION_CHANGE" | sed 's/^/     - /'
  printf '\n   👉 다음 명령 (사용자 직접 실행):\n'
  printf '     supabase db push --include-all\n\n'
  exit 0
fi

# ───────────────────────────────────────────────────────────────────
# 5) RN JS 변경 — tsc 검증은 항상 수행 (검증은 안전, 배포만 게이트)
# ───────────────────────────────────────────────────────────────────
TSC_OK=1
if [ -n "$RN_JS_CHANGE" ]; then
  log "🧪 npx tsc --noEmit (검증)"
  if ! (cd apps/mobile-rn && npx tsc --noEmit 2>&1 | tail -10); then
    TSC_OK=0
    log "❌ TypeScript 에러 — 배포 전 수정 필요."
  else
    printf '   ✅ tsc 통과\n'
  fi
fi

# ───────────────────────────────────────────────────────────────────
# 6) 자동 배포 모드면 실제 실행 (옵트인 경로)
# ───────────────────────────────────────────────────────────────────
if [ "$AUTO_ON" = "1" ] && [ "$TSC_OK" = "1" ]; then
  if [ -n "$EDGE_FUNCS" ]; then
    log "📦 [auto-on] Edge Function 배포: $EDGE_FUNCS"
    for fn in $EDGE_FUNCS; do
      printf '   • supabase functions deploy %s\n' "$fn"
      if ! supabase functions deploy "$fn" --project-ref hayjukwfcsdmppairazc 2>&1 | tail -3; then
        log "❌ $fn 배포 실패 — 중단."
        exit 0
      fi
    done
  fi

  if [ -n "$RN_JS_CHANGE" ]; then
    MSG=$(git -C "$REPO_ROOT" log -1 --format=%s 2>/dev/null | head -c 80)
    [ -z "$MSG" ] && MSG="auto: $(printf '%s\n' "$DIFF_PATHS" | head -1)"
    log "🚀 [auto-on] eas update --branch production"
    if ! (cd apps/mobile-rn && eas update --branch production --message "$MSG" --non-interactive 2>&1 | tail -15); then
      log "❌ eas update 실패."
      exit 0
    fi
  fi

  mkdir -p "$(dirname "$MARKER")"
  printf '%s' "$CURRENT_HASH" > "$MARKER"
  log "✅ [auto-on] 자동 배포 사이클 완료."
  exit 0
fi

# ───────────────────────────────────────────────────────────────────
# 7) 리뷰 모드 (기본): 변경 요약 + 다음 단계 안내만
# ───────────────────────────────────────────────────────────────────
log "📝 변경 요약 (리뷰 모드 — 자동 배포 OFF)"
printf '   변경 파일 %s건:\n' "$(printf '%s\n' "$DIFF_PATHS" | wc -l | tr -d ' ')"
printf '%s\n' "$DIFF_PATHS" | head -20 | sed 's/^/     - /'
extra=$(printf '%s\n' "$DIFF_PATHS" | tail -n +21 | wc -l | tr -d ' ')
if [ "$extra" -gt 0 ]; then
  printf '     ... 외 %s건\n' "$extra"
fi

printf '\n   다음 단계 — 사용자 검토 후 직접 실행:\n'

if [ -n "$EDGE_FUNCS" ]; then
  printf '\n     [Edge Function 배포 후보]\n'
  for fn in $EDGE_FUNCS; do
    printf '       supabase functions deploy %s\n' "$fn"
  done
fi

if [ -n "$RN_JS_CHANGE" ]; then
  if [ "$TSC_OK" = "1" ]; then
    printf '\n     [RN OTA 후보]  (tsc ✅ 통과)\n'
    printf '       cd apps/mobile-rn && eas update --branch production\n'
  else
    printf '\n     [RN OTA] tsc 실패 — 위 에러를 먼저 수정해야 합니다.\n'
  fi
fi

printf '\n     [멀티 에이전트 리뷰 추천]\n'
printf '       /review              # diff 안전성 (SQL/LLM trust/side effects)\n'
printf '       /codex               # 독립 2차 의견\n'
if [ -n "$RN_JS_CHANGE" ]; then
  printf '       iOS Simulator MCP   # 동작 확인 스크린샷\n'
fi
if [ -n "$EDGE_FUNCS" ] || [ -n "$MIGRATION_CHANGE" ]; then
  printf '       /security-review    # Edge Function/DB 변경 보안 점검\n'
fi
printf '\n     [한 번에 다 처리]\n'
printf '       /ship                # CHANGELOG + commit + push + PR (배포는 머지 후)\n\n'

# 마커 갱신 — 같은 변경에 대해 다시 보고하지 않음
mkdir -p "$(dirname "$MARKER")"
printf '%s' "$CURRENT_HASH" > "$MARKER"
exit 0
