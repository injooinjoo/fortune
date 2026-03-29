#!/bin/bash

# ===========================================
# 앱 스토어 스크린샷 캡처 스크립트
# ===========================================

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 출력 디렉토리
OUTPUT_DIR="screenshots/store"
mkdir -p "$OUTPUT_DIR/ios"
mkdir -p "$OUTPUT_DIR/android"

echo -e "${BLUE}📱 앱 스토어 스크린샷 캡처 시작${NC}"
echo ""

# ===========================================
# iOS 시뮬레이터 디바이스 정의
# ===========================================
declare -A IOS_DEVICES
IOS_DEVICES=(
    ["iPhone-16-Pro-Max"]="iPhone 16 Pro Max"      # 6.9" - 1320x2868
    ["iPhone-15-Pro-Max"]="iPhone 15 Pro Max"      # 6.7" - 1290x2796
    ["iPhone-14-Plus"]="iPhone 14 Plus"            # 6.7" - 1284x2778
    ["iPhone-8-Plus"]="iPhone 8 Plus"              # 5.5" - 1242x2208
    ["iPad-Pro-13"]="iPad Pro 13-inch (M4)"        # 12.9"
)

# ===========================================
# 함수: iOS 시뮬레이터 스크린샷
# ===========================================
capture_ios_screenshot() {
    local device_name=$1
    local simulator_name=$2
    local screen_name=$3
    local delay=${4:-3}

    local filename="${OUTPUT_DIR}/ios/${device_name}_${screen_name}.png"

    echo -e "${YELLOW}📸 캡처: ${simulator_name} - ${screen_name}${NC}"

    # 스크린샷 캡처
    xcrun simctl io booted screenshot "$filename" 2>/dev/null

    if [ -f "$filename" ]; then
        echo -e "${GREEN}   ✅ 저장: $filename${NC}"
    else
        echo -e "${RED}   ❌ 실패${NC}"
    fi
}

# ===========================================
# 함수: 시뮬레이터 부팅
# ===========================================
boot_simulator() {
    local simulator_name=$1

    echo -e "${BLUE}🚀 시뮬레이터 부팅: ${simulator_name}${NC}"

    # 기존 시뮬레이터 종료
    xcrun simctl shutdown all 2>/dev/null || true
    sleep 2

    # 시뮬레이터 부팅
    xcrun simctl boot "$simulator_name" 2>/dev/null || {
        echo -e "${RED}❌ 시뮬레이터 '$simulator_name'를 찾을 수 없습니다.${NC}"
        echo -e "${YELLOW}사용 가능한 시뮬레이터 목록:${NC}"
        xcrun simctl list devices available | grep -E "iPhone|iPad"
        return 1
    }

    # 시뮬레이터 앱 열기
    open -a Simulator
    sleep 5

    echo -e "${GREEN}✅ 시뮬레이터 부팅 완료${NC}"
}

# ===========================================
# 함수: Flutter 앱 실행
# ===========================================
run_flutter_app() {
    echo -e "${BLUE}🔧 Flutter 앱 빌드 및 실행...${NC}"

    # Release 모드로 실행 (더 빠른 성능)
    flutter run --release -d booted &
    FLUTTER_PID=$!

    # 앱 로딩 대기
    echo -e "${YELLOW}⏳ 앱 로딩 대기 (30초)...${NC}"
    sleep 30

    echo -e "${GREEN}✅ 앱 실행 완료${NC}"
}

# ===========================================
# 메인: 수동 캡처 모드
# ===========================================
manual_capture_mode() {
    echo ""
    echo -e "${BLUE}===========================================
📱 수동 스크린샷 캡처 모드
===========================================${NC}"
    echo ""
    echo "사용법:"
    echo "1. 시뮬레이터에서 원하는 화면으로 이동"
    echo "2. 이 터미널에서 화면 번호 입력 후 Enter"
    echo ""
    echo "화면 번호:"
    echo "  1 = 홈/채팅 화면"
    echo "  2 = 캐릭터 선택"
    echo "  3 = 운세 결과"
    echo "  4 = 프리미엄 구독"
    echo "  5 = 프로필/설정"
    echo "  q = 종료"
    echo ""

    local device_name=$(echo "$CURRENT_DEVICE" | tr ' ' '-')

    while true; do
        read -p "화면 번호 입력: " screen_num

        case $screen_num in
            1) capture_ios_screenshot "$device_name" "$CURRENT_DEVICE" "01_home" ;;
            2) capture_ios_screenshot "$device_name" "$CURRENT_DEVICE" "02_characters" ;;
            3) capture_ios_screenshot "$device_name" "$CURRENT_DEVICE" "03_fortune_result" ;;
            4) capture_ios_screenshot "$device_name" "$CURRENT_DEVICE" "04_premium" ;;
            5) capture_ios_screenshot "$device_name" "$CURRENT_DEVICE" "05_profile" ;;
            q|Q)
                echo -e "${GREEN}✅ 캡처 완료${NC}"
                break
                ;;
            *) echo -e "${RED}잘못된 입력${NC}" ;;
        esac
    done
}

# ===========================================
# 메인: 디바이스 선택
# ===========================================
select_device() {
    echo ""
    echo -e "${BLUE}===========================================
📱 스크린샷 캡처할 디바이스 선택
===========================================${NC}"
    echo ""
    echo "1. iPhone 16 Pro Max (6.9\" - 1320x2868) ⭐ 추천"
    echo "2. iPhone 15 Pro Max (6.7\" - 1290x2796)"
    echo "3. iPhone 14 Plus (6.7\" - 1284x2778)"
    echo "4. iPhone 8 Plus (5.5\" - 1242x2208)"
    echo "5. iPad Pro 13\" (12.9\" - 2048x2732)"
    echo "6. 현재 실행 중인 시뮬레이터 사용"
    echo ""

    read -p "선택 (1-6): " choice

    case $choice in
        1) CURRENT_DEVICE="iPhone 16 Pro Max" ;;
        2) CURRENT_DEVICE="iPhone 15 Pro Max" ;;
        3) CURRENT_DEVICE="iPhone 14 Plus" ;;
        4) CURRENT_DEVICE="iPhone 8 Plus" ;;
        5) CURRENT_DEVICE="iPad Pro 13-inch (M4)" ;;
        6)
            CURRENT_DEVICE=$(xcrun simctl list devices booted | grep -oE "iPhone[^)]+|iPad[^)]+" | head -1)
            if [ -z "$CURRENT_DEVICE" ]; then
                echo -e "${RED}❌ 실행 중인 시뮬레이터가 없습니다.${NC}"
                exit 1
            fi
            echo -e "${GREEN}✅ 현재 디바이스: $CURRENT_DEVICE${NC}"
            ;;
        *)
            echo -e "${RED}잘못된 선택${NC}"
            exit 1
            ;;
    esac
}

# ===========================================
# 메인: 빠른 캡처 (현재 화면)
# ===========================================
quick_capture() {
    local screen_name=${1:-"screenshot"}
    local device_name=$(xcrun simctl list devices booted | grep -oE "iPhone[^)]+|iPad[^)]+" | head -1 | tr ' ' '-')

    if [ -z "$device_name" ]; then
        echo -e "${RED}❌ 실행 중인 시뮬레이터가 없습니다.${NC}"
        exit 1
    fi

    local filename="${OUTPUT_DIR}/ios/${device_name}_${screen_name}_$(date +%H%M%S).png"

    xcrun simctl io booted screenshot "$filename"
    echo -e "${GREEN}✅ 저장: $filename${NC}"
}

# ===========================================
# Android 스크린샷 (adb 사용)
# ===========================================
capture_android_screenshot() {
    local screen_name=$1
    local filename="${OUTPUT_DIR}/android/android_${screen_name}_$(date +%H%M%S).png"

    echo -e "${YELLOW}📸 Android 캡처: ${screen_name}${NC}"

    adb shell screencap -p /sdcard/screenshot.png
    adb pull /sdcard/screenshot.png "$filename"
    adb shell rm /sdcard/screenshot.png

    echo -e "${GREEN}✅ 저장: $filename${NC}"
}

# ===========================================
# 스크립트 시작
# ===========================================
echo ""
echo -e "${BLUE}===========================================
🎯 Ondo 앱 스토어 스크린샷 도우미
===========================================${NC}"
echo ""
echo "모드 선택:"
echo "1. iOS 시뮬레이터 수동 캡처 (추천)"
echo "2. 빠른 캡처 (현재 화면 즉시 캡처)"
echo "3. Android 캡처 (adb 필요)"
echo ""

read -p "선택 (1-3): " mode

case $mode in
    1)
        select_device
        if [ "$choice" != "6" ]; then
            boot_simulator "$CURRENT_DEVICE"
            echo ""
            echo -e "${YELLOW}⏳ Flutter 앱을 수동으로 실행해주세요:${NC}"
            echo "   flutter run --release"
            echo ""
            read -p "앱 실행 후 Enter를 누르세요..."
        fi
        manual_capture_mode
        ;;
    2)
        read -p "화면 이름 (예: home, premium): " screen_name
        quick_capture "$screen_name"
        ;;
    3)
        read -p "화면 이름 (예: home, premium): " screen_name
        capture_android_screenshot "$screen_name"
        ;;
    *)
        echo -e "${RED}잘못된 선택${NC}"
        exit 1
        ;;
esac

echo ""
echo -e "${GREEN}===========================================
✅ 스크린샷 캡처 완료!
===========================================${NC}"
echo ""
echo "저장 위치: $OUTPUT_DIR"
echo ""
ls -la "$OUTPUT_DIR/ios/" 2>/dev/null || true
ls -la "$OUTPUT_DIR/android/" 2>/dev/null || true
