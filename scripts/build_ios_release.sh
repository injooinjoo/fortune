#!/bin/bash

# iOS 릴리즈 빌드 자동화 스크립트
# Fortune App - iOS App Store 배포용

set -e  # 에러 발생 시 즉시 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로고
echo -e "${BLUE}"
echo "╔══════════════════════════════════════╗"
echo "║   Fortune iOS Release Build Script  ║"
echo "║          App Store Deploy            ║"
echo "╚══════════════════════════════════════╝"
echo -e "${NC}"

# 프로젝트 루트로 이동
cd "$(dirname "$0")/.."

# Step 1: 환경 확인
echo -e "${YELLOW}[1/7] 환경 확인 중...${NC}"

# Flutter 버전 확인
FLUTTER_VERSION=$(flutter --version | grep "Flutter" | awk '{print $2}')
echo -e "${GREEN}✓ Flutter version: $FLUTTER_VERSION${NC}"

# Xcode 버전 확인
XCODE_VERSION=$(xcodebuild -version | grep "Xcode" | awk '{print $2}')
echo -e "${GREEN}✓ Xcode version: $XCODE_VERSION${NC}"

# CocoaPods 버전 확인
POD_VERSION=$(pod --version)
echo -e "${GREEN}✓ CocoaPods version: $POD_VERSION${NC}"

# .env 파일 확인
if [ ! -f ".env" ]; then
    echo -e "${RED}✗ Error: .env 파일이 없습니다!${NC}"
    echo -e "${YELLOW}  .env.example을 .env로 복사하고 프로덕션 값을 입력하세요.${NC}"
    exit 1
fi
echo -e "${GREEN}✓ .env 파일 확인 완료${NC}"

# Step 2: API 키 보안 확인
echo -e "\n${YELLOW}[2/7] API 키 보안 확인 중...${NC}"

# 민감한 키들이 소스 코드에 하드코딩되어 있는지 확인
echo "Checking for hardcoded API keys..."

if grep -r "sk-proj-" lib/ --include="*.dart" 2>/dev/null; then
    echo -e "${RED}✗ Warning: OpenAI API 키가 소스 코드에 하드코딩되어 있습니다!${NC}"
    echo -e "${YELLOW}  환경 변수로 이동하세요.${NC}"
fi

if grep -r "eyJhbGciOiJIUzI1NiI" lib/ --include="*.dart" 2>/dev/null; then
    echo -e "${RED}✗ Warning: Supabase 키가 소스 코드에 하드코딩되어 있습니다!${NC}"
    echo -e "${YELLOW}  환경 변수로 이동하세요.${NC}"
fi

echo -e "${GREEN}✓ 소스 코드 보안 확인 완료${NC}"

# Step 3: 의존성 정리 및 재설치
echo -e "\n${YELLOW}[3/7] 의존성 정리 중...${NC}"

echo "Cleaning Flutter build cache..."
flutter clean

echo "Getting Flutter packages..."
flutter pub get

echo "Installing CocoaPods dependencies..."
cd ios
pod deintegrate || true
rm -f Podfile.lock
pod install
cd ..

echo -e "${GREEN}✓ 의존성 정리 완료${NC}"

# Step 4: 코드 분석
echo -e "\n${YELLOW}[4/7] 코드 분석 중...${NC}"

echo "Running flutter analyze..."
if flutter analyze; then
    echo -e "${GREEN}✓ 코드 분석 통과${NC}"
else
    echo -e "${RED}✗ Warning: 코드 분석에서 경고가 발견되었습니다.${NC}"
    echo -e "${YELLOW}  계속 진행하시겠습니까? (y/n)${NC}"
    read -r CONTINUE
    if [ "$CONTINUE" != "y" ]; then
        echo "빌드를 취소합니다."
        exit 1
    fi
fi

# Step 5: iOS 빌드 설정 확인
echo -e "\n${YELLOW}[5/7] iOS 빌드 설정 확인 중...${NC}"

# Bundle ID 확인
BUNDLE_ID=$(grep -A 1 "PRODUCT_BUNDLE_IDENTIFIER" ios/Runner.xcodeproj/project.pbxproj | grep "com.beyond.fortune" | head -1 | awk '{print $3}' | tr -d ';')
echo -e "${GREEN}✓ Bundle ID: $BUNDLE_ID${NC}"

# Team ID 확인
TEAM_ID=$(grep -A 1 "DEVELOPMENT_TEAM" ios/Runner.xcodeproj/project.pbxproj | grep "5F7CN7Y54D" | head -1 | awk '{print $3}' | tr -d ';')
echo -e "${GREEN}✓ Team ID: $TEAM_ID${NC}"

# 앱 버전 확인
APP_VERSION=$(grep "version:" pubspec.yaml | awk '{print $2}')
echo -e "${GREEN}✓ App Version: $APP_VERSION${NC}"

# Step 6: iOS 릴리즈 빌드
echo -e "\n${YELLOW}[6/7] iOS 릴리즈 빌드 시작...${NC}"
echo -e "${BLUE}이 단계는 5-10분 정도 소요될 수 있습니다.${NC}"

# 빌드 시작 시간 기록
BUILD_START=$(date +%s)

# IPA 빌드 (App Store 배포용)
if flutter build ipa --release; then
    BUILD_END=$(date +%s)
    BUILD_TIME=$((BUILD_END - BUILD_START))
    echo -e "${GREEN}✓ iOS 릴리즈 빌드 성공! (소요 시간: ${BUILD_TIME}초)${NC}"
else
    echo -e "${RED}✗ iOS 빌드 실패!${NC}"
    exit 1
fi

# Step 7: 빌드 결과 확인
echo -e "\n${YELLOW}[7/7] 빌드 결과 확인 중...${NC}"

# IPA 파일 확인
if [ -f "build/ios/ipa/fortune.ipa" ]; then
    IPA_SIZE=$(du -h "build/ios/ipa/fortune.ipa" | awk '{print $1}')
    echo -e "${GREEN}✓ IPA 파일 생성 완료: build/ios/ipa/fortune.ipa (${IPA_SIZE})${NC}"
else
    echo -e "${RED}✗ IPA 파일을 찾을 수 없습니다!${NC}"
    exit 1
fi

# Archive 파일 확인
if [ -d "build/ios/archive/Runner.xcarchive" ]; then
    ARCHIVE_SIZE=$(du -sh "build/ios/archive/Runner.xcarchive" | awk '{print $1}')
    echo -e "${GREEN}✓ Archive 파일 생성 완료: build/ios/archive/Runner.xcarchive (${ARCHIVE_SIZE})${NC}"
else
    echo -e "${YELLOW}⚠ Archive 파일을 찾을 수 없습니다.${NC}"
fi

# 최종 결과
echo -e "\n${GREEN}╔══════════════════════════════════════╗${NC}"
echo -e "${GREEN}║     iOS 릴리즈 빌드 완료!           ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"

echo -e "\n${BLUE}다음 단계:${NC}"
echo -e "1. ${YELLOW}IPA 파일 업로드${NC}"
echo -e "   - Apple Transporter 앱 사용 (권장)"
echo -e "   - 또는 Xcode Organizer 사용"
echo -e "   - 파일 위치: build/ios/ipa/fortune.ipa"
echo -e ""
echo -e "2. ${YELLOW}App Store Connect 설정${NC}"
echo -e "   - https://appstoreconnect.apple.com"
echo -e "   - 앱 정보, 스크린샷, 설명 입력"
echo -e ""
echo -e "3. ${YELLOW}TestFlight 베타 테스트${NC}"
echo -e "   - 내부 테스터 추가"
echo -e "   - 피드백 수집 및 버그 수정"
echo -e ""
echo -e "4. ${YELLOW}심사 제출${NC}"
echo -e "   - 모든 정보 입력 완료 후 Submit for Review"
echo -e ""
echo -e "${BLUE}자세한 가이드:${NC}"
echo -e "docs/deployment/IOS_LAUNCH_GUIDE.md 참고"
echo -e ""
echo -e "${GREEN}✓ 빌드 스크립트 완료${NC}"
