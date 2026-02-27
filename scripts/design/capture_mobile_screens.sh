#!/usr/bin/env bash

set -u

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
MANIFEST_PATH="$REPO_ROOT/artifacts/design/mobile/manifest.json"
RAW_DIR="$REPO_ROOT/artifacts/design/mobile/raw"
BLOCKED_PATH="$RAW_DIR/blocked.ndjson"
CAPTURE_LOG_PATH="$RAW_DIR/capture_log.ndjson"

THEMES="light,dark"
WAIT_SECONDS=2.5
RETRY_COUNT=2
LIMIT=0
UDID=""

usage() {
  cat <<'USAGE'
Usage:
  bash scripts/design/capture_mobile_screens.sh [options]

Options:
  --udid <udid>             Target simulator UDID (default: first booted iPhone)
  --themes <light,dark>     Comma-separated themes (default: light,dark)
  --wait-seconds <float>    Wait time after deep link (default: 2.5)
  --retry-count <int>       Retries on failure (default: 2)
  --limit <int>             Capture first N screens only (default: 0 = all)
  -h, --help                Show help
USAGE
}

log() { printf '%s\n' "$*"; }
warn() { printf 'WARN: %s\n' "$*" >&2; }
err() { printf 'ERROR: %s\n' "$*" >&2; }

json_escape() {
  node -e "process.stdout.write(JSON.stringify(process.argv[1] ?? '').slice(1,-1))" "$1"
}

url_encode() {
  node -e "process.stdout.write(encodeURIComponent(process.argv[1] ?? ''))" "$1"
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --udid)
        UDID="${2:-}"
        shift 2
        ;;
      --themes)
        THEMES="${2:-}"
        shift 2
        ;;
      --wait-seconds)
        WAIT_SECONDS="${2:-}"
        shift 2
        ;;
      --retry-count)
        RETRY_COUNT="${2:-}"
        shift 2
        ;;
      --limit)
        LIMIT="${2:-}"
        shift 2
        ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        err "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
  done
}

detect_udid() {
  if [[ -n "$UDID" ]]; then
    return
  fi

  UDID="$(xcrun simctl list devices booted 2>/dev/null | grep -E 'iPhone' | head -1 | grep -oE '[0-9A-F-]{36}' || true)"
  if [[ -z "$UDID" ]]; then
    UDID="$(xcrun simctl list devices booted 2>/dev/null | head -1 | grep -oE '[0-9A-F-]{36}' || true)"
  fi
}

validate_tools() {
  command -v node >/dev/null 2>&1 || { err "node not found"; exit 1; }
  command -v idb >/dev/null 2>&1 || { err "idb not found"; exit 1; }
  command -v xcrun >/dev/null 2>&1 || { err "xcrun not found"; exit 1; }
}

prepare_manifest() {
  if [[ ! -f "$MANIFEST_PATH" ]]; then
    log "Manifest missing. Building..."
    node "$REPO_ROOT/scripts/design/build_mobile_manifest.js" || exit 1
  fi
}

init_outputs() {
  mkdir -p "$RAW_DIR"
  : > "$BLOCKED_PATH"
  : > "$CAPTURE_LOG_PATH"
}

set_appearance() {
  local theme="$1"
  xcrun simctl ui "$UDID" appearance "$theme" >/dev/null 2>&1 || {
    warn "Failed to set appearance to $theme"
  }
}

is_screen_stable() {
  local tmp_file
  tmp_file="$(mktemp)"
  if ! idb ui describe-all --udid "$UDID" --json >"$tmp_file" 2>/dev/null; then
    rm -f "$tmp_file"
    return 1
  fi
  local size
  size="$(wc -c <"$tmp_file" | tr -d ' ')"
  rm -f "$tmp_file"
  [[ "${size:-0}" -gt 100 ]]
}

append_blocked() {
  local screen_id="$1"
  local theme="$2"
  local reason="$3"
  local path="$4"
  local escaped_reason
  escaped_reason="$(json_escape "$reason")"
  printf '{"screen_id":"%s","theme":"%s","path":"%s","reason":"%s","timestamp":"%s"}\n' \
    "$screen_id" "$theme" "$path" "$escaped_reason" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$BLOCKED_PATH"
}

append_capture_log() {
  local screen_id="$1"
  local theme="$2"
  local status="$3"
  local path="$4"
  local attempts="$5"
  printf '{"screen_id":"%s","theme":"%s","path":"%s","status":"%s","attempts":%s,"timestamp":"%s"}\n' \
    "$screen_id" "$theme" "$path" "$status" "$attempts" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$CAPTURE_LOG_PATH"
}

capture_one() {
  local screen_id="$1"
  local route_path="$2"
  local deeplink_screen="$3"
  local theme="$4"
  local max_attempts=$((RETRY_COUNT + 1))
  local attempt=1
  local out_dir="$RAW_DIR/$screen_id"
  local out_path="$out_dir/${theme}.png"

  mkdir -p "$out_dir"
  while [[ "$attempt" -le "$max_attempts" ]]; do
    local encoded_screen
    encoded_screen="$(url_encode "$deeplink_screen")"
    local uri="com.beyond.fortune://deeplink?screen=${encoded_screen}"

    xcrun simctl openurl "$UDID" "$uri" >/dev/null 2>&1 || true
    sleep "$WAIT_SECONDS"

    if ! is_screen_stable; then
      attempt=$((attempt + 1))
      continue
    fi

    if idb screenshot --udid "$UDID" "$out_path" >/dev/null 2>&1; then
      append_capture_log "$screen_id" "$theme" "captured" "$route_path" "$attempt"
      return 0
    fi
    attempt=$((attempt + 1))
  done

  append_capture_log "$screen_id" "$theme" "blocked" "$route_path" "$max_attempts"
  append_blocked "$screen_id" "$theme" "capture_failed_after_retries" "$route_path"
  return 1
}

iterate_manifest() {
  node - <<'NODE' "$MANIFEST_PATH" "$LIMIT"
const fs = require('fs');
const manifestPath = process.argv[2];
const limit = Number(process.argv[3] || 0);
const manifest = JSON.parse(fs.readFileSync(manifestPath, 'utf8'));
const screens = limit > 0 ? manifest.screens.slice(0, limit) : manifest.screens;
for (const s of screens) {
  process.stdout.write(`${s.screen_id}|${s.path}|${s.deeplink_screen}\n`);
}
NODE
}

summarize() {
  node - <<'NODE' "$CAPTURE_LOG_PATH" "$BLOCKED_PATH"
const fs = require('fs');
const [logPath, blockedPath] = process.argv.slice(2);
const logLines = fs.existsSync(logPath)
  ? fs.readFileSync(logPath, 'utf8').trim().split('\n').filter(Boolean).map(JSON.parse)
  : [];
const blocked = fs.existsSync(blockedPath)
  ? fs.readFileSync(blockedPath, 'utf8').trim().split('\n').filter(Boolean).map(JSON.parse)
  : [];
const captured = logLines.filter((x) => x.status === 'captured').length;
const report = {
  generated_at: new Date().toISOString(),
  captured,
  blocked: blocked.length,
  total_attempted: logLines.length,
};
fs.writeFileSync(
  require('path').join(require('path').dirname(logPath), 'capture_summary.json'),
  JSON.stringify(report, null, 2) + '\n'
);
console.log(JSON.stringify(report, null, 2));
NODE
}

main() {
  parse_args "$@"
  validate_tools
  prepare_manifest
  detect_udid
  init_outputs

  if [[ -z "$UDID" ]]; then
    err "No booted simulator found. Boot iPhone 16 Pro Max and run app first."
    exit 1
  fi

  log "Using simulator UDID: $UDID"
  log "Themes: $THEMES"
  log "Limit: ${LIMIT:-0}"

  IFS=',' read -r -a theme_list <<< "$THEMES"

  for theme in "${theme_list[@]}"; do
    set_appearance "$theme"
    while IFS= read -r row; do
      [[ -z "$row" ]] && continue
      IFS='|' read -r screen_id route_path deeplink_screen <<< "$row"
      log "Capturing [$theme] $screen_id ($route_path)"
      capture_one "$screen_id" "$route_path" "$deeplink_screen" "$theme" || true
    done < <(iterate_manifest)
  done

  summarize
}

main "$@"
