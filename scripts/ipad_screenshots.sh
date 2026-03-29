#!/bin/bash

# iPad 스크린샷 자동 촬영 스크립트
# 사용법: ./scripts/ipad_screenshots.sh

set -e

# 색상 코드
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}📸 iPad 스크린샷 촬영 시작${NC}"

# 스크린샷 저장 폴더
SCREENSHOT_DIR="$HOME/Desktop/Ondo_Screenshots/iPad"
mkdir -p "$SCREENSHOT_DIR"

# iPad Pro 13" 디바이스 ID
IPAD_DEVICE="E07CDE02-FA41-4D14-A186-97C2CCB8ABE6"

# 함수: 스크린샷 촬영
take_screenshot() {
    local filename=$1
    local description=$2

    echo -e "${GREEN}📱 촬영 중: $description${NC}"
    xcrun simctl io "$IPAD_DEVICE" screenshot "$SCREENSHOT_DIR/$filename"
    echo "   ✅ 저장됨: $filename"
    sleep 1
}

echo -e "\n${BLUE}=== iPad Pro 13\" 스크린샷 촬영 (13개 필요) ===${NC}"
echo "📱 시뮬레이터에서 각 화면으로 이동 후 Enter를 누르세요..."

echo -e "\n1️⃣  랜딩 페이지로 이동 후 Enter"
read
take_screenshot "ipad_01_landing.png" "랜딩 페이지"

echo -e "\n2️⃣  로그인 화면으로 이동 후 Enter"
read
take_screenshot "ipad_02_login.png" "로그인 화면"

echo -e "\n3️⃣  메인 대시보드로 이동 후 Enter"
read
take_screenshot "ipad_03_dashboard.png" "메인 대시보드"

echo -e "\n4️⃣  운세 카테고리 선택 화면으로 이동 후 Enter"
read
take_screenshot "ipad_04_categories.png" "운세 카테고리"

echo -e "\n5️⃣  운세 생성 입력 화면으로 이동 후 Enter"
read
take_screenshot "ipad_05_input.png" "운세 생성"

echo -e "\n6️⃣  운세 결과 화면 (1번째) 이동 후 Enter"
read
take_screenshot "ipad_06_result1.png" "운세 결과 1"

echo -e "\n7️⃣  운세 결과 화면 (2번째) 이동 후 Enter"
read
take_screenshot "ipad_07_result2.png" "운세 결과 2"

echo -e "\n8️⃣  운세 히스토리 화면으로 이동 후 Enter"
read
take_screenshot "ipad_08_history.png" "운세 히스토리"

echo -e "\n9️⃣  프로필 설정 화면으로 이동 후 Enter"
read
take_screenshot "ipad_09_profile.png" "프로필 설정"

echo -e "\n🔟  설정 화면으로 이동 후 Enter"
read
take_screenshot "ipad_10_settings.png" "설정"

echo -e "\n1️⃣1️⃣  다크모드 전환 후 메인 화면으로 이동 후 Enter"
read
take_screenshot "ipad_11_dark.png" "다크모드"

echo -e "\n1️⃣2️⃣  다크모드에서 운세 결과 화면으로 이동 후 Enter"
read
take_screenshot "ipad_12_dark_result.png" "다크모드 운세"

echo -e "\n1️⃣3️⃣  다크모드에서 프로필 화면으로 이동 후 Enter"
read
take_screenshot "ipad_13_dark_profile.png" "다크모드 프로필"

echo -e "\n${GREEN}✅ 모든 iPad 스크린샷 촬영 완료!${NC}"
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
