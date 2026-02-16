#!/usr/bin/env bash

# iOS Integration Test Runner
# - Detects/boots iPhone Simulator
# - Runs Flutter integration tests with `.env.test` (fallback if unsupported)
#
# Usage:
#   ./scripts/run_ios_integration_tests.sh [SIMULATOR_NAME]
#   SIMULATOR_NAME default: "iPhone 15 Pro"
#   ENV_FILE override: export ENV_FILE=.env.test

set -uo pipefail

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

SIM_NAME=${1:-"iPhone 15 Pro"}
ENV_FILE=${ENV_FILE:-.env.test}

find_udid_by_name() {
  local target_name="$1"
  xcrun simctl list devices available |
    sed -n "s/^\\s*${target_name} (\\([0-9A-F-]\\{36\\}\\)).*/\\1/p" |
    head -n1
}

find_first_available_simulator() {
  xcrun simctl list devices available |
    sed -n 's/^\s*\(iPhone[^()]*\|iPad[^()]*\) (\([0-9A-F-]\{36\}\)).*/\1|\2/p' |
    head -n1
}

echo -e "${BLUE}▸ iOS Integration Test Runner${NC}"
echo -e "${BLUE}   Target: ${SIM_NAME} | Env: ${ENV_FILE}${NC}"

# Preconditions
command -v flutter >/dev/null 2>&1 || { echo -e "${RED}Flutter not found in PATH${NC}"; exit 1; }
command -v xcrun >/dev/null 2>&1 || { echo -e "${RED}Xcode command line tools not found${NC}"; exit 1; }

if [ ! -f "$ENV_FILE" ]; then
  echo -e "${YELLOW}Warning: ${ENV_FILE} not found. Continuing without file check.${NC}"
fi

# Find simulator UDID by name
UDID=$(find_udid_by_name "${SIM_NAME}")

if [ -z "$UDID" ]; then
  FALLBACK=$(find_first_available_simulator)
  if [ -n "$FALLBACK" ]; then
    SIM_NAME=$(echo "$FALLBACK" | cut -d'|' -f1)
    UDID=$(echo "$FALLBACK" | cut -d'|' -f2)
    echo -e "${YELLOW}Simulator fallback:${NC} requested device not found, using '${SIM_NAME}' (${UDID})"
  else
    echo -e "${RED}No available iPhone/iPad simulator found.${NC}"
    echo -e "${YELLOW}Tip:${NC} Open Xcode > Settings > Platforms and install an iOS runtime."
    echo -e "${YELLOW}Tip:${NC} Check available devices: 'xcrun simctl list devices available'"
    # Exit 2 = skipped (environment missing simulator runtime)
    exit 2
  fi
fi

# Boot if needed
STATE_LINE=$(xcrun simctl list devices | grep -n "$UDID" || true)
if ! echo "$STATE_LINE" | grep -q "(Booted)"; then
  echo -e "${YELLOW}▸ Booting simulator ${SIM_NAME} (${UDID})...${NC}"
  xcrun simctl boot "$UDID" >/dev/null 2>&1 || true
  open -a Simulator >/dev/null 2>&1 || true
  # Wait for boot
  for i in {1..30}; do
    if xcrun simctl list devices | grep -q "$UDID.*(Booted)"; then
      break
    fi
    sleep 2
  done
fi

echo -e "${GREEN}▸ Simulator ready: ${SIM_NAME} (${UDID})${NC}"

# Determine if flutter test supports --dart-define-from-file
if flutter test -h 2>&1 | rg -q "dart-define-from-file"; then
  DEFINE_ARGS=("--dart-define-from-file=${ENV_FILE}")
else
  echo -e "${YELLOW}Note:${NC} '--dart-define-from-file' not supported by this Flutter; running without defines."
  DEFINE_ARGS=()
fi

echo -e "${BLUE}▸ Running integration tests...${NC}"
set +e
flutter test integration_test/ -d "$UDID" --reporter expanded "${DEFINE_ARGS[@]}"
STATUS=$?
set -e

if [ $STATUS -eq 0 ]; then
  echo -e "${GREEN}✅ Integration tests PASSED${NC}"
  exit 0
else
  echo -e "${RED}❌ Integration tests FAILED (exit $STATUS)${NC}"
  echo -e "${YELLOW}Check simulator logs (Cmd+/, in Simulator) and Flutter output above.${NC}"
  exit $STATUS
fi
