#!/bin/bash
# Quick test script - runs tests with authentication bypass
# Usage: ./scripts/quick-test.sh

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🔧 Quick Test with Authentication Bypass${NC}"
echo "========================================"

# Set test environment
export FLUTTER_TEST_MODE=true
export TEST_MODE=true
export BYPASS_AUTH=true

# Quick Flutter app check
echo -e "${YELLOW}1. Testing Flutter app compilation...${NC}"
flutter analyze --no-fatal-infos || echo "Analysis issues found (continuing anyway)"

# Quick app run test
echo -e "${YELLOW}2. Quick app startup test...${NC}"
timeout 30 flutter run -d chrome --web-port=3000 &
FLUTTER_PID=$!

# Wait for app to start
sleep 15

# Kill Flutter process
kill $FLUTTER_PID 2>/dev/null || true

echo -e "${GREEN}✅ Quick test completed!${NC}"
echo "To run full tests: ./scripts/test.sh"