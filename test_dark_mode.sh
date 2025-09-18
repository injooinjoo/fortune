#!/bin/bash

# Fortune 다크모드 테스트 자동화 스크립트
# iPhone 15 Pro 시뮬레이터를 통한 다크모드 테스트

set -e  # 오류 발생 시 스크립트 중단

# 설정
SIMULATOR_ID="34784C26-75DC-4B12-B31F-69FF944B7487"  # iPhone 15 Pro
SCREENSHOTS_DIR="./screenshots"
TIMESTAMP=$(date "+%Y%m%d_%H%M%S")

echo "🚀 Fortune 다크모드 테스트 시작..."
echo "⏰ 테스트 시간: $(date)"
echo "📱 시뮬레이터: iPhone 15 Pro ($SIMULATOR_ID)"
echo ""

# 스크린샷 폴더 생성
mkdir -p "$SCREENSHOTS_DIR"

# 테스트 함수들
check_simulator_running() {
    echo "🔍 시뮬레이터 상태 확인..."
    if xcrun simctl list devices | grep -q "Booted"; then
        echo "✅ 시뮬레이터가 실행 중입니다"
        return 0
    else
        echo "❌ 시뮬레이터가 실행되지 않았습니다"
        return 1
    fi
}

capture_screenshot() {
    local filename="$1"
    local description="$2"
    local full_path="$SCREENSHOTS_DIR/${TIMESTAMP}_${filename}"

    echo "📸 스크린샷 캡처: $description"
    if xcrun simctl io "$SIMULATOR_ID" screenshot "$full_path"; then
        echo "✅ 저장됨: $full_path"
        return 0
    else
        echo "❌ 스크린샷 캡처 실패"
        return 1
    fi
}

set_appearance() {
    local mode="$1"  # light 또는 dark
    echo "🎨 외관 모드 변경: $mode"
    if xcrun simctl ui "$SIMULATOR_ID" appearance "$mode"; then
        echo "✅ $mode 모드로 설정됨"
        sleep 3  # 테마 변경 애니메이션 대기
        return 0
    else
        echo "❌ 외관 모드 변경 실패"
        return 1
    fi
}

wait_for_app() {
    echo "⏳ 앱 로딩 대기 중..."
    sleep 5
}

# 메인 테스트 시작
echo "1️⃣ 시뮬레이터 상태 확인"
if ! check_simulator_running; then
    echo "시뮬레이터를 먼저 실행해주세요: flutter run -d $SIMULATOR_ID"
    exit 1
fi

echo ""
echo "2️⃣ 라이트모드 테스트"
set_appearance "light"
wait_for_app
capture_screenshot "01_light_mode_landing.png" "랜딩페이지 라이트모드"

echo ""
echo "3️⃣ 다크모드 테스트"
set_appearance "dark"
wait_for_app
capture_screenshot "02_dark_mode_landing.png" "랜딩페이지 다크모드"

echo ""
echo "4️⃣ 라이트모드로 복원"
set_appearance "light"
wait_for_app
capture_screenshot "03_light_mode_restored.png" "라이트모드 복원"

echo ""
echo "5️⃣ 테스트 결과 분석"

# 스크린샷 파일 목록
echo "📋 생성된 스크린샷 파일:"
ls -la "$SCREENSHOTS_DIR"/${TIMESTAMP}_*.png | while read line; do
    filename=$(basename "$line")
    size=$(echo "$line" | awk '{print $5}')
    echo "  📁 $filename ($size bytes)"
done

echo ""
echo "✅ 다크모드 테스트 완료!"
echo "📸 스크린샷 저장 위치: $SCREENSHOTS_DIR"
echo "🔍 스크린샷을 직접 확인하여 다음 사항을 검증하세요:"
echo "  - 로고가 다크모드에서 흰색으로 잘 보이는지"
echo "  - 텍스트 가독성이 충분한지"
echo "  - 버튼과 UI 요소들이 적절한 대비를 가지는지"
echo "  - 전체적인 UI 일관성이 유지되는지"

echo ""
echo "🔧 추가 테스트를 위한 명령어:"
echo "  🖼️  스크린샷 보기: open $SCREENSHOTS_DIR"
echo "  ⚡ 라이트모드: xcrun simctl ui $SIMULATOR_ID appearance light"
echo "  🌙 다크모드: xcrun simctl ui $SIMULATOR_ID appearance dark"
echo "  📱 상태바 설정: xcrun simctl status_bar $SIMULATOR_ID override --time '9:41' --batteryLevel 100"

echo ""
echo "⏰ 테스트 완료 시간: $(date)"