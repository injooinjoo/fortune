#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BASELINE_FILE="${ROOT_DIR}/scripts/code_consistency_baseline.env"
STRICT_MODE=false
UPDATE_BASELINE=false
SHOW_MATCHES=false
MAX_MATCHES=20

usage() {
  cat <<'EOF'
Usage: ./scripts/check_code_consistency.sh [options]

Options:
  --strict              Fail when any check count is greater than 0.
  --update-baseline     Overwrite baseline file with current counts.
  --show-matches        Show sample matches for non-zero checks.
  --baseline <path>     Use a custom baseline file.
  --max-matches <n>     Max lines shown per check in --show-matches mode.
  -h, --help            Show this help message.
EOF
}

while [ $# -gt 0 ]; do
  case "$1" in
    --strict)
      STRICT_MODE=true
      shift
      ;;
    --update-baseline)
      UPDATE_BASELINE=true
      shift
      ;;
    --show-matches)
      SHOW_MATCHES=true
      shift
      ;;
    --baseline)
      BASELINE_FILE="$2"
      shift 2
      ;;
    --max-matches)
      MAX_MATCHES="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      exit 1
      ;;
  esac
done

cd "$ROOT_DIR"

COMMON_GLOBS=(
  --glob '!**/*.g.dart'
  --glob '!**/*.freezed.dart'
  --glob '!**/*.md'
)

count_lines() {
  wc -l | tr -d ' '
}

rg_count() {
  local pattern="$1"
  shift
  { rg -n "$pattern" "$@" || true; } | count_lines
}

presentation_to_data_count() {
  local absolute_count relative_count
  absolute_count=$(
    {
      rg -n "import\\s+['\"][^'\"]*features/[^/]+/data/" "${COMMON_GLOBS[@]}" lib/features || true
    } | {
      rg '/presentation/' || true
    } | count_lines
  )
  relative_count=$(
    {
      rg -n "import\\s+['\"][^'\"]*(\\.\\./)+data/" "${COMMON_GLOBS[@]}" lib/features || true
    } | {
      rg '/presentation/' || true
    } | count_lines
  )
  echo $((absolute_count + relative_count))
}

show_matches_for_check() {
  local key="$1"
  case "$key" in
    HARD_CODED_COLOR_LITERAL)
      { rg -n 'Color\(0x[0-9A-Fa-f]{6,8}\)' "${COMMON_GLOBS[@]}" --glob '!lib/core/design_system/tokens/**' --glob '!lib/core/theme/**' lib || true; } | head -n "$MAX_MATCHES"
      ;;
    DIRECT_WHITE_BLACK_COLOR)
      { rg -n '\bColors\.(white|black)\b' "${COMMON_GLOBS[@]}" lib || true; } | head -n "$MAX_MATCHES"
      ;;
    RAW_FONT_SIZE_USAGE)
      { rg -n 'fontSize\s*:' "${COMMON_GLOBS[@]}" --glob '!lib/core/theme/**' --glob '!lib/shared/widgets/typography/**' lib || true; } | head -n "$MAX_MATCHES"
      ;;
    ARROW_BACK_MATERIAL_ICON)
      { rg -n 'Icons\.arrow_back\b' "${COMMON_GLOBS[@]}" lib || true; } | head -n "$MAX_MATCHES"
      ;;
    PRINT_CALL_USAGE)
      { rg -n '^\s*print\(' "${COMMON_GLOBS[@]}" lib || true; } | head -n "$MAX_MATCHES"
      ;;
    RIVERPOD_ANNOTATION_USAGE)
      { rg -n '@riverpod' "${COMMON_GLOBS[@]}" lib || true; } | head -n "$MAX_MATCHES"
      ;;
    PRESENTATION_TO_DATA_IMPORT_USAGE)
      {
        rg -n "import\\s+['\"][^'\"]*features/[^/]+/data/" "${COMMON_GLOBS[@]}" lib/features || true
        rg -n "import\\s+['\"][^'\"]*(\\.\\./)+data/" "${COMMON_GLOBS[@]}" lib/features || true
      } | {
        rg '/presentation/' || true
      } | head -n "$MAX_MATCHES"
      ;;
    EMPTY_CATCH_BLOCK_USAGE)
      { rg -n -U 'catch\s*\([^\)]*\)\s*\{\s*\}' "${COMMON_GLOBS[@]}" lib || true; } | head -n "$MAX_MATCHES"
      ;;
  esac
}

HARD_CODED_COLOR_LITERAL=$(rg_count 'Color\(0x[0-9A-Fa-f]{6,8}\)' "${COMMON_GLOBS[@]}" --glob '!lib/core/design_system/tokens/**' --glob '!lib/core/theme/**' lib)
DIRECT_WHITE_BLACK_COLOR=$(rg_count '\bColors\.(white|black)\b' "${COMMON_GLOBS[@]}" lib)
RAW_FONT_SIZE_USAGE=$(rg_count 'fontSize\s*:' "${COMMON_GLOBS[@]}" --glob '!lib/core/theme/**' --glob '!lib/shared/widgets/typography/**' lib)
ARROW_BACK_MATERIAL_ICON=$(rg_count 'Icons\.arrow_back\b' "${COMMON_GLOBS[@]}" lib)
PRINT_CALL_USAGE=$(rg_count '^\s*print\(' "${COMMON_GLOBS[@]}" lib)
RIVERPOD_ANNOTATION_USAGE=$(rg_count '@riverpod' "${COMMON_GLOBS[@]}" lib)
PRESENTATION_TO_DATA_IMPORT_USAGE=$(presentation_to_data_count)
EMPTY_CATCH_BLOCK_USAGE=$(rg_count 'catch\s*\([^\)]*\)\s*\{\s*\}' -U "${COMMON_GLOBS[@]}" lib)

CHECK_KEYS=(
  HARD_CODED_COLOR_LITERAL
  DIRECT_WHITE_BLACK_COLOR
  RAW_FONT_SIZE_USAGE
  ARROW_BACK_MATERIAL_ICON
  PRINT_CALL_USAGE
  RIVERPOD_ANNOTATION_USAGE
  PRESENTATION_TO_DATA_IMPORT_USAGE
  EMPTY_CATCH_BLOCK_USAGE
)

CHECK_LABELS=(
  'Color literal usage outside token/theme layers'
  'Direct Colors.white/black usage'
  'Raw fontSize usage outside theme/typography layers'
  'Material back icon usage (prefer Icons.arrow_back_ios)'
  'print() usage in Dart source'
  '@riverpod annotation usage'
  'presentation -> data direct imports'
  'Empty catch block usage'
)

CHECK_COUNTS=(
  "$HARD_CODED_COLOR_LITERAL"
  "$DIRECT_WHITE_BLACK_COLOR"
  "$RAW_FONT_SIZE_USAGE"
  "$ARROW_BACK_MATERIAL_ICON"
  "$PRINT_CALL_USAGE"
  "$RIVERPOD_ANNOTATION_USAGE"
  "$PRESENTATION_TO_DATA_IMPORT_USAGE"
  "$EMPTY_CATCH_BLOCK_USAGE"
)

if [ "$UPDATE_BASELINE" = true ]; then
  {
    echo '# Auto-generated by scripts/check_code_consistency.sh --update-baseline'
    echo "# Updated at: $(date -u '+%Y-%m-%dT%H:%M:%SZ')"
    for i in "${!CHECK_KEYS[@]}"; do
      echo "${CHECK_KEYS[$i]}=${CHECK_COUNTS[$i]}"
    done
  } > "$BASELINE_FILE"
  echo "Baseline updated: $BASELINE_FILE"
fi

if [ ! -f "$BASELINE_FILE" ]; then
  echo "Baseline file not found: $BASELINE_FILE" >&2
  echo "Run with --update-baseline once to create it." >&2
  exit 1
fi

# shellcheck disable=SC1090
source "$BASELINE_FILE"

echo '=============================================='
echo 'Code Consistency Guard'
echo "Baseline: $BASELINE_FILE"
echo '=============================================='

REGRESSION_COUNT=0
STRICT_VIOLATION_COUNT=0
IMPROVEMENT_COUNT=0

for i in "${!CHECK_KEYS[@]}"; do
  key="${CHECK_KEYS[$i]}"
  label="${CHECK_LABELS[$i]}"
  current="${CHECK_COUNTS[$i]}"
  baseline="${!key-}"

  if [ -z "$baseline" ]; then
    baseline='N/A'
    status='NO_BASELINE'
  elif [ "$current" -gt "$baseline" ]; then
    status='REGRESSION'
    REGRESSION_COUNT=$((REGRESSION_COUNT + 1))
  elif [ "$current" -lt "$baseline" ]; then
    status='IMPROVED'
    IMPROVEMENT_COUNT=$((IMPROVEMENT_COUNT + 1))
  else
    status='OK'
  fi

  if [ "$STRICT_MODE" = true ] && [ "$current" -gt 0 ]; then
    STRICT_VIOLATION_COUNT=$((STRICT_VIOLATION_COUNT + 1))
  fi

  printf '%-45s current=%-6s baseline=%-6s status=%s\n' "$label" "$current" "$baseline" "$status"

  if [ "$SHOW_MATCHES" = true ] && [ "$current" -gt 0 ]; then
    echo "  sample matches (${key}):"
    show_matches_for_check "$key" | sed 's/^/    /'
  fi
done

echo '----------------------------------------------'
echo "Regressions : $REGRESSION_COUNT"
echo "Improvements: $IMPROVEMENT_COUNT"

if [ "$STRICT_MODE" = true ]; then
  echo "Strict violations: $STRICT_VIOLATION_COUNT"
fi

if [ "$REGRESSION_COUNT" -gt 0 ]; then
  echo '❌ Consistency regression detected.'
  exit 1
fi

if [ "$STRICT_MODE" = true ] && [ "$STRICT_VIOLATION_COUNT" -gt 0 ]; then
  echo '❌ Strict mode failed (non-zero rule counts).'
  exit 1
fi

echo '✅ Consistency guard passed.'
