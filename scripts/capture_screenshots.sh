#!/bin/bash
# Ondo Screenshot Capture Script
# 시뮬레이터에서 앱을 실행하고 스크린샷을 캡처합니다.
#
# 사용법:
# 1. 앱을 시뮬레이터에서 실행: flutter run -d "iPhone 15 Pro"
# 2. 원하는 페이지로 이동
# 3. 이 스크립트 실행: ./scripts/capture_screenshots.sh <page_name>
#
# 예시:
# ./scripts/capture_screenshots.sh chat_home
# ./scripts/capture_screenshots.sh fortune_list

set -e

# 설정
SCREENSHOT_DIR="integration_test/screenshots"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
PAGE_NAME="${1:-screenshot}"

# 디렉토리 생성
mkdir -p "$SCREENSHOT_DIR/light"
mkdir -p "$SCREENSHOT_DIR/dark"

# 시뮬레이터 UDID 가져오기
SIMULATOR_UDID=$(xcrun simctl list devices booted | grep -E "iPhone|iPad" | head -1 | grep -oE "[0-9A-F-]{36}")

if [ -z "$SIMULATOR_UDID" ]; then
    echo "❌ 실행 중인 시뮬레이터가 없습니다."
    echo "💡 먼저 앱을 실행하세요: flutter run -d 'iPhone 15 Pro'"
    exit 1
fi

echo "📸 Capturing screenshot for: $PAGE_NAME"
echo "📱 Simulator: $SIMULATOR_UDID"

# 스크린샷 캡처
OUTPUT_FILE="$SCREENSHOT_DIR/${PAGE_NAME}_${TIMESTAMP}.png"
xcrun simctl io "$SIMULATOR_UDID" screenshot "$OUTPUT_FILE"

echo "✅ Saved: $OUTPUT_FILE"
echo ""
echo "📋 다음 페이지를 캡처하려면:"
echo "   1. 앱에서 다음 페이지로 이동"
echo "   2. ./scripts/capture_screenshots.sh <page_name>"
