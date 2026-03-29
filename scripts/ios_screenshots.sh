#!/bin/bash

# iOS 스크린샷 자동 촬영 스크립트
# 사용법: ./scripts/ios_screenshots.sh

set -e

# 색상 코드
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📸 iOS 스크린샷 촬영 시작${NC}"

# 스크린샷 저장 폴더
SCREENSHOT_DIR="$HOME/Desktop/Ondo_Screenshots/iOS"
mkdir -p "$SCREENSHOT_DIR"

# 시뮬레이터 디바이스 ID 찾기
DEVICE_6_7=$(xcrun simctl list devices available | grep "iPhone 15 Pro Max" | grep -v "Shutdown" | head -1 | grep -oE '\([0-9A-F-]+\)' | tr -d '()')
DEVICE_6_5=$(xcrun simctl list devices available | grep "iPhone 11 Pro Max" | grep -v "Shutdown" | head -1 | grep -oE '\([0-9A-F-]+\)' | tr -d '()')

if [ -z "$DEVICE_6_7" ]; then
    echo "⚠️  iPhone 15 Pro Max 시뮬레이터를 찾을 수 없습니다."
    echo "수동으로 시뮬레이터를 부팅해주세요."
    exit 1
fi

if [ -z "$DEVICE_6_5" ]; then
    echo "⚠️  iPhone 11 Pro Max 시뮬레이터를 찾을 수 없습니다."
    echo "수동으로 시뮬레이터를 부팅해주세요."
    exit 1
fi

# 함수: 스크린샷 촬영
take_screenshot() {
    local device_id=$1
    local filename=$2
    local description=$3

    echo -e "${GREEN}📱 촬영 중: $description${NC}"
    xcrun simctl io "$device_id" screenshot "$SCREENSHOT_DIR/$filename"
    echo "   ✅ 저장됨: $filename"
    sleep 1
}

# 6.7" 스크린샷 촬영
echo -e "\n${BLUE}=== iPhone 15 Pro Max (6.7\") 스크린샷 촬영 ===${NC}"
echo "📱 시뮬레이터에서 각 화면으로 이동 후 Enter를 누르세요..."

echo -e "\n1️⃣  랜딩 페이지로 이동 후 Enter"
read
take_screenshot "$DEVICE_6_7" "ios_6.7_landing.png" "랜딩 페이지"

echo -e "\n2️⃣  로그인 화면으로 이동 후 Enter"
read
take_screenshot "$DEVICE_6_7" "ios_6.7_login.png" "로그인 화면"

echo -e "\n3️⃣  메인 대시보드로 이동 후 Enter"
read
take_screenshot "$DEVICE_6_7" "ios_6.7_dashboard.png" "메인 대시보드"

echo -e "\n4️⃣  운세 생성 입력 화면으로 이동 후 Enter"
read
take_screenshot "$DEVICE_6_7" "ios_6.7_input.png" "운세 생성"

echo -e "\n5️⃣  운세 결과 화면으로 이동 후 Enter"
read
take_screenshot "$DEVICE_6_7" "ios_6.7_result.png" "운세 결과"

echo -e "\n6️⃣  프로필 설정 화면으로 이동 후 Enter"
read
take_screenshot "$DEVICE_6_7" "ios_6.7_profile.png" "프로필 설정"

echo -e "\n7️⃣  다크모드 전환 후 메인 화면으로 이동 후 Enter"
read
take_screenshot "$DEVICE_6_7" "ios_6.7_dark.png" "다크모드"

# 6.5" 스크린샷 촬영
echo -e "\n${BLUE}=== iPhone 11 Pro Max (6.5\") 스크린샷 촬영 ===${NC}"
echo "🔄 시뮬레이터를 iPhone 11 Pro Max로 변경 후 앱을 재실행하세요..."
echo "준비되면 Enter"
read

echo -e "\n1️⃣  랜딩 페이지로 이동 후 Enter"
read
take_screenshot "$DEVICE_6_5" "ios_6.5_landing.png" "랜딩 페이지"

echo -e "\n2️⃣  로그인 화면으로 이동 후 Enter"
read
take_screenshot "$DEVICE_6_5" "ios_6.5_login.png" "로그인 화면"

echo -e "\n3️⃣  메인 대시보드로 이동 후 Enter"
read
take_screenshot "$DEVICE_6_5" "ios_6.5_dashboard.png" "메인 대시보드"

echo -e "\n4️⃣  운세 생성 입력 화면으로 이동 후 Enter"
read
take_screenshot "$DEVICE_6_5" "ios_6.5_input.png" "운세 생성"

echo -e "\n5️⃣  운세 결과 화면으로 이동 후 Enter"
read
take_screenshot "$DEVICE_6_5" "ios_6.5_result.png" "운세 결과"

echo -e "\n6️⃣  프로필 설정 화면으로 이동 후 Enter"
read
take_screenshot "$DEVICE_6_5" "ios_6.5_profile.png" "프로필 설정"

echo -e "\n7️⃣  다크모드 전환 후 메인 화면으로 이동 후 Enter"
read
take_screenshot "$DEVICE_6_5" "ios_6.5_dark.png" "다크모드"

echo -e "\n${GREEN}✅ 모든 iOS 스크린샷 촬영 완료!${NC}"
echo -e "📂 저장 위치: $SCREENSHOT_DIR"
echo ""
ls -lh "$SCREENSHOT_DIR"

# 해상도 확인
echo -e "\n${BLUE}=== 해상도 검증 ===${NC}"
for file in "$SCREENSHOT_DIR"/*.png; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        resolution=$(sips -g pixelWidth -g pixelHeight "$file" 2>/dev/null | grep pixel | awk '{print $2}' | tr '\n' 'x' | sed 's/x$//')
        echo "$filename: $resolution"
    fi
done

echo -e "\n${GREEN}🎉 스크린샷 촬영 완료!${NC}"
echo "App Store Connect에 업로드할 준비가 되었습니다."
