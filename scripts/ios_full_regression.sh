#!/usr/bin/env bash

# iOS Full Regression Runner (env: .env.test by default)
# Runs: analyze → format check → iOS build (no codesign) → unit → widget → integration (auto-fallback simulator)
#
# Usage:
#   ./scripts/ios_full_regression.sh [SIMULATOR_NAME]
#   Defaults: SIMULATOR_NAME="iPhone 15 Pro" (fallback enabled), ENV_FILE=.env.test

set -uo pipefail

YELLOW='\033[1;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

SIM_NAME=${1:-"iPhone 15 Pro"}
ENV_FILE=${ENV_FILE:-.env.test}

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}   iOS Full Regression Runner${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "Env: ${ENV_FILE} | Simulator: ${SIM_NAME}\n"

ANALYZE=1; FORMAT=1; BUILD=1; UNIT=2; WIDGET=2; INTEG=2

# 1. Analyze
echo -e "${YELLOW}▸ Analyzing code...${NC}"
if flutter analyze; then ANALYZE=0; echo -e "${GREEN}  ✓ analyze passed${NC}"; else ANALYZE=1; echo -e "${RED}  ✗ analyze failed${NC}"; fi
echo

# 2. Format check (non-destructive)
echo -e "${YELLOW}▸ Checking format (no changes)...${NC}"
if dart format --output=none --set-exit-if-changed .; then FORMAT=0; echo -e "${GREEN}  ✓ format clean${NC}"; else FORMAT=1; echo -e "${YELLOW}  ! formatting differences found (run: dart format .)${NC}"; fi
echo

# 3. iOS build (sanity)
echo -e "${YELLOW}▸ Building iOS (no codesign)...${NC}"
if flutter build ios --no-codesign --dart-define-from-file="${ENV_FILE}" --release; then BUILD=0; echo -e "${GREEN}  ✓ iOS build ok${NC}"; else BUILD=1; echo -e "${RED}  ✗ iOS build failed${NC}"; fi
echo

# 4. Unit tests
if [ -d test/unit ]; then
  echo -e "${YELLOW}▸ Running unit tests...${NC}"
  if flutter test test/unit/ --reporter expanded; then UNIT=0; echo -e "${GREEN}  ✓ unit tests passed${NC}"; else UNIT=1; echo -e "${RED}  ✗ unit tests failed${NC}"; fi
  echo
fi

# 5. Widget tests
if [ -d test/widget ]; then
  echo -e "${YELLOW}▸ Running widget tests...${NC}"
  if flutter test test/widget/ --reporter expanded; then WIDGET=0; echo -e "${GREEN}  ✓ widget tests passed${NC}"; else WIDGET=1; echo -e "${RED}  ✗ widget tests failed${NC}"; fi
  echo
fi

# 6. Integration tests (iOS simulator)
if [ -f ./scripts/run_ios_integration_tests.sh ]; then
  echo -e "${YELLOW}▸ Running iOS integration tests...${NC}"
  ENV_FILE="${ENV_FILE}" bash ./scripts/run_ios_integration_tests.sh "${SIM_NAME}"
  INTEG_STATUS=$?
  if [ $INTEG_STATUS -eq 0 ]; then
    INTEG=0
  elif [ $INTEG_STATUS -eq 2 ]; then
    INTEG=2
    echo -e "${YELLOW}  ! iOS simulator runtime unavailable; integration tests skipped${NC}"
  else
    INTEG=1
  fi
  echo
else
  echo -e "${YELLOW}  ! helper script missing; skipping integration${NC}"
fi

# Summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}   Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

summ() { local n=$1; if [ "$n" -eq 0 ]; then echo -e "${GREEN}PASS${NC}"; elif [ "$n" -eq 2 ]; then echo -e "${YELLOW}SKIP${NC}"; else echo -e "${RED}FAIL${NC}"; fi }
echo -e "analyze     : $(summ $ANALYZE)"
echo -e "format      : $(summ $FORMAT)"
echo -e "ios build   : $(summ $BUILD)"
echo -e "unit tests  : $(summ $UNIT)"
echo -e "widget tests: $(summ $WIDGET)"
echo -e "integration : $(summ $INTEG)"

EXIT=$((ANALYZE + FORMAT + BUILD))
if [ $UNIT -eq 1 ]; then EXIT=$((EXIT + 1)); fi
if [ $WIDGET -eq 1 ]; then EXIT=$((EXIT + 1)); fi
if [ $INTEG -eq 1 ]; then EXIT=$((EXIT + 1)); fi

if [ $EXIT -eq 0 ]; then
  echo -e "${GREEN}\n✅ Full regression passed${NC}"
  exit 0
else
  echo -e "${RED}\n❌ One or more steps failed${NC}"
  exit 1
fi
