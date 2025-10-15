#!/bin/bash

# Android 스크린샷 자동 촬영 스크립트
# 사용법: ./scripts/android_screenshots.sh

set -e

# 색상 코드
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📸 Android 스크린샷 촬영 시작${NC}"

# 스크린샷 저장 폴더
SCREENSHOT_DIR="$HOME/Desktop/Fortune_Screenshots/Android"
mkdir -p "$SCREENSHOT_DIR"

# adb 연결 확인
if ! command -v adb &> /dev/null; then
    echo "❌ adb를 찾을 수 없습니다. Android SDK를 설치해주세요."
    exit 1
fi

# 연결된 디바이스 확인
DEVICE=$(adb devices | grep -v "List" | grep "device" | awk '{print $1}' | head -1)

if [ -z "$DEVICE" ]; then
    echo "❌ 연결된 Android 에뮬레이터를 찾을 수 없습니다."
    echo "에뮬레이터를 실행 후 다시 시도해주세요."
    exit 1
fi

echo -e "${GREEN}✅ 디바이스 발견: $DEVICE${NC}"

# 함수: 스크린샷 촬영
take_screenshot() {
    local filename=$1
    local description=$2

    echo -e "${GREEN}📱 촬영 중: $description${NC}"

    # 에뮬레이터에서 스크린샷 촬영
    adb -s "$DEVICE" shell screencap -p /sdcard/temp_screenshot.png

    # PC로 다운로드
    adb -s "$DEVICE" pull /sdcard/temp_screenshot.png "$SCREENSHOT_DIR/$filename"

    # 에뮬레이터에서 임시 파일 삭제
    adb -s "$DEVICE" shell rm /sdcard/temp_screenshot.png

    echo "   ✅ 저장됨: $filename"
    sleep 1
}

# 스크린샷 촬영
echo -e "\n${BLUE}=== Android Phone 스크린샷 촬영 ===${NC}"
echo "📱 에뮬레이터에서 각 화면으로 이동 후 Enter를 누르세요..."

echo -e "\n1️⃣  랜딩 페이지로 이동 후 Enter"
read
take_screenshot "android_landing.png" "랜딩 페이지"

echo -e "\n2️⃣  로그인 화면으로 이동 후 Enter"
read
take_screenshot "android_login.png" "로그인 화면"

echo -e "\n3️⃣  메인 대시보드로 이동 후 Enter"
read
take_screenshot "android_dashboard.png" "메인 대시보드"

echo -e "\n4️⃣  운세 생성 입력 화면으로 이동 후 Enter"
read
take_screenshot "android_input.png" "운세 생성"

echo -e "\n5️⃣  운세 결과 화면으로 이동 후 Enter"
read
take_screenshot "android_result.png" "운세 결과"

echo -e "\n6️⃣  프로필 설정 화면으로 이동 후 Enter"
read
take_screenshot "android_profile.png" "프로필 설정"

echo -e "\n7️⃣  다크모드 전환 후 메인 화면으로 이동 후 Enter"
read
take_screenshot "android_dark.png" "다크모드"

echo -e "\n8️⃣  (선택) 추가 기능 화면으로 이동 후 Enter (건너뛰려면 Enter만)"
read
if [ -n "$REPLY" ]; then
    take_screenshot "android_extra.png" "추가 기능"
fi

echo -e "\n${GREEN}✅ 모든 Android 스크린샷 촬영 완료!${NC}"
echo -e "📂 저장 위치: $SCREENSHOT_DIR"
echo ""
ls -lh "$SCREENSHOT_DIR"

# 해상도 확인
echo -e "\n${BLUE}=== 해상도 검증 ===${NC}"
if command -v identify &> /dev/null; then
    for file in "$SCREENSHOT_DIR"/*.png; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            resolution=$(identify -format "%wx%h" "$file")
            echo "$filename: $resolution"
        fi
    done
else
    echo "⚠️  ImageMagick이 설치되지 않아 해상도 확인을 건너뜁니다."
    echo "설치: brew install imagemagick"
fi

# 리사이즈 필요 여부 확인
echo -e "\n${BLUE}=== 리사이즈 확인 ===${NC}"
echo "Google Play 권장 해상도: 1080×1920"
echo ""
echo "현재 스크린샷이 1080×1920보다 크다면 리사이즈가 필요할 수 있습니다."
echo "리사이즈하시겠습니까? (y/n)"
read resize_answer

if [ "$resize_answer" == "y" ]; then
    if ! command -v convert &> /dev/null; then
        echo "❌ ImageMagick이 설치되지 않았습니다."
        echo "설치: brew install imagemagick"
        exit 1
    fi

    RESIZED_DIR="$SCREENSHOT_DIR/resized"
    mkdir -p "$RESIZED_DIR"

    for file in "$SCREENSHOT_DIR"/*.png; do
        if [ -f "$file" ]; then
            filename=$(basename "$file")
            echo "리사이즈 중: $filename"
            convert "$file" -resize 1080x1920\> "$RESIZED_DIR/$filename"
        fi
    done

    echo -e "\n${GREEN}✅ 리사이즈 완료!${NC}"
    echo -e "📂 저장 위치: $RESIZED_DIR"
    ls -lh "$RESIZED_DIR"
fi

echo -e "\n${GREEN}🎉 스크린샷 촬영 완료!${NC}"
echo "Google Play Console에 업로드할 준비가 되었습니다."
