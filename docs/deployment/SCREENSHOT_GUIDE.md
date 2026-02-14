# 📸 ZPZG 스크린샷 촬영 완전 가이드

**최종 업데이트**: 2025-01-15
**목적**: iOS App Store와 Google Play Store용 스크린샷 촬영 완벽 가이드

---

## 목차

1. [iOS 스크린샷 촬영 가이드](#ios-스크린샷-촬영-가이드)
2. [Android 스크린샷 촬영 가이드](#android-스크린샷-촬영-가이드)
3. [촬영해야 할 화면 리스트](#촬영해야-할-화면-리스트)
4. [스크린샷 편집 팁](#스크린샷-편집-팁)
5. [자동화 스크립트](#자동화-스크립트)

---

## iOS 스크린샷 촬영 가이드

### 📱 필수 디바이스 크기

Apple은 **2가지 디바이스 크기**의 스크린샷을 필수로 요구합니다:

#### 1. iPhone 6.7" (iPhone 14 Pro Max, 15 Pro Max, 15 Plus)
```yaml
해상도: 1290×2796 pixels (세로), 2796×1290 pixels (가로)
비율: 9:19.5
포맷: PNG 또는 JPG
최소 개수: 1개
권장 개수: 5-7개
최대 개수: 10개
```

#### 2. iPhone 6.5" (iPhone 11 Pro Max, XS Max)
```yaml
해상도: 1242×2688 pixels (세로), 2688×1242 pixels (가로)
비율: 9:19.5
포맷: PNG 또는 JPG
최소 개수: 1개
권장 개수: 5-7개
최대 개수: 10개
```

#### 선택사항: iPad Pro 12.9"
```yaml
해상도: 2048×2732 pixels (세로), 2732×2048 pixels (가로)
비율: 3:4
포맷: PNG 또는 JPG
권장: iPad 앱을 별도로 홍보하려는 경우에만
```

---

### 🖥️ 시뮬레이터 설정 방법

#### STEP 1: 시뮬레이터 열기

```bash
# Xcode 시뮬레이터 열기
open -a Simulator
```

#### STEP 2: 올바른 디바이스 선택

**방법 1: Xcode에서 선택**
1. Xcode 열기
2. 상단 바에서 디바이스 선택 드롭다운 클릭
3. "iPhone 15 Pro Max" 또는 "iPhone 14 Pro Max" 선택

**방법 2: 시뮬레이터 메뉴에서 선택**
```
Simulator → File → Open Simulator → iOS 17.x → iPhone 15 Pro Max
```

**권장 시뮬레이터 2개:**
```
1. iPhone 15 Pro Max (6.7" 스크린샷용)
2. iPhone 11 Pro Max (6.5" 스크린샷용)
```

#### STEP 3: 시뮬레이터 설정

**외관 설정:**
```
Simulator → Features → Appearance → Light/Dark
```
- Light Mode로 기본 스크린샷 촬영
- Dark Mode 스크린샷도 1-2개 추가 권장

**상태바 정리:**
```
Simulator → Features → Toggle Status Bar Time
```
- 시간을 9:41 AM으로 설정 (Apple 권장)
- 배터리는 풀 차지 상태로
- Wi-Fi 신호 최대로

**언어 설정:**
```
Settings → General → Language & Region → Korean
```

#### STEP 4: 앱 실행

```bash
# Fortune 앱 시뮬레이터에서 실행
flutter run -d "iPhone 15 Pro Max"

# 또는 릴리즈 모드로 (프로덕션 빌드)
flutter run --release -d "iPhone 15 Pro Max"
```

**시뮬레이터 ID 확인:**
```bash
# 사용 가능한 시뮬레이터 목록
xcrun simctl list devices available

# 예시 출력:
# iPhone 15 Pro Max (5A8E4D2F-1234-5678-90AB-CDEF12345678) (Booted)
```

#### STEP 5: 스크린샷 촬영

**방법 1: 단축키 (가장 간단)**
```
Command (⌘) + S
```
- 자동으로 바탕화면에 저장됨
- 파일명: `Screenshot 2025-01-15 at 10.30.45 AM.png`

**방법 2: 메뉴 바**
```
Simulator → File → Save Screen
```

**방법 3: 명령어 (자동화용)**
```bash
# 현재 부팅된 시뮬레이터의 스크린샷
xcrun simctl io booted screenshot ~/Desktop/fortune_screenshot_1.png

# 특정 시뮬레이터의 스크린샷
xcrun simctl io <UDID> screenshot ~/Desktop/fortune_screenshot_1.png
```

#### STEP 6: 해상도 확인

```bash
# 스크린샷 해상도 확인
sips -g pixelWidth -g pixelHeight ~/Desktop/fortune_screenshot_1.png

# 예상 출력:
# pixelWidth: 1290
# pixelHeight: 2796
```

---

### 📋 iOS 스크린샷 촬영 체크리스트

#### iPhone 15 Pro Max (6.7") - 1290×2796

- [ ] **스크린샷 1: 랜딩 페이지**
  - 시뮬레이터: iPhone 15 Pro Max
  - 화면: 로그인 전 첫 화면
  - 파일명: `ios_6.7_landing.png`

- [ ] **스크린샷 2: 로그인 화면**
  - 시뮬레이터: iPhone 15 Pro Max
  - 화면: 소셜 로그인 옵션 표시
  - 파일명: `ios_6.7_login.png`

- [ ] **스크린샷 3: 메인 대시보드**
  - 시뮬레이터: iPhone 15 Pro Max
  - 화면: 로그인 후 운세 카테고리 화면
  - 파일명: `ios_6.7_dashboard.png`

- [ ] **스크린샷 4: 운세 생성**
  - 시뮬레이터: iPhone 15 Pro Max
  - 화면: 생년월일/시간 입력 화면
  - 파일명: `ios_6.7_input.png`

- [ ] **스크린샷 5: 운세 결과**
  - 시뮬레이터: iPhone 15 Pro Max
  - 화면: AI 분석 결과 표시
  - 파일명: `ios_6.7_result.png`

- [ ] **스크린샷 6: 프로필 설정**
  - 시뮬레이터: iPhone 15 Pro Max
  - 화면: 사용자 프로필 화면
  - 파일명: `ios_6.7_profile.png`

- [ ] **스크린샷 7: 다크모드**
  - 시뮬레이터: iPhone 15 Pro Max (Dark Mode)
  - 화면: 메인 대시보드 or 운세 결과
  - 파일명: `ios_6.7_dark.png`

#### iPhone 11 Pro Max (6.5") - 1242×2688

**동일한 화면을 다른 해상도로 촬영:**

- [ ] **스크린샷 1: 랜딩 페이지** → `ios_6.5_landing.png`
- [ ] **스크린샷 2: 로그인 화면** → `ios_6.5_login.png`
- [ ] **스크린샷 3: 메인 대시보드** → `ios_6.5_dashboard.png`
- [ ] **스크린샷 4: 운세 생성** → `ios_6.5_input.png`
- [ ] **스크린샷 5: 운세 결과** → `ios_6.5_result.png`
- [ ] **스크린샷 6: 프로필 설정** → `ios_6.5_profile.png`
- [ ] **스크린샷 7: 다크모드** → `ios_6.5_dark.png`

---

### 🚀 iOS 스크린샷 촬영 자동화 스크립트

**`scripts/ios_screenshots.sh`**

```bash
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
SCREENSHOT_DIR="$HOME/Desktop/Fortune_Screenshots/iOS"
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
```

**실행 방법:**
```bash
chmod +x scripts/ios_screenshots.sh
./scripts/ios_screenshots.sh
```

---

## Android 스크린샷 촬영 가이드

### 📱 필수 디바이스 크기

Google Play는 **Phone 스크린샷 최소 2개**를 필수로 요구합니다:

#### Phone (필수)
```yaml
최소 해상도: 320px (짧은 쪽) ~ 3840px (긴 쪽)
권장 해상도: 1080×1920 pixels (세로), 1920×1080 pixels (가로)
비율: 16:9 또는 9:16
포맷: PNG 또는 JPG (24-bit, RGB)
최소 개수: 2개
권장 개수: 5-8개
최대 개수: 8개
최대 파일 크기: 8MB
```

#### 7" Tablet (선택사항)
```yaml
권장 해상도: 1200×1920 pixels
비율: 16:9 또는 9:16
포맷: PNG 또는 JPG
```

#### 10" Tablet (선택사항)
```yaml
권장 해상도: 1536×2048 pixels
비율: 3:4 또는 4:3
포맷: PNG 또는 JPG
```

---

### 🖥️ 에뮬레이터 설정 방법

#### STEP 1: Android 에뮬레이터 열기

```bash
# Android Studio 에뮬레이터 실행
# Android Studio → Tools → Device Manager → 디바이스 선택 → Play 버튼
```

**또는 명령어로:**
```bash
# 사용 가능한 에뮬레이터 목록
emulator -list-avds

# 특정 에뮬레이터 실행
emulator -avd Pixel_6_Pro_API_34 &
```

#### STEP 2: 올바른 디바이스 선택/생성

**권장 에뮬레이터:**

1. **Pixel 6 Pro (Phone 스크린샷용)**
   - 해상도: 1440×3120 (실제 기기)
   - 스크린샷 저장 시: 1080×1920 (다운스케일)
   - Android 버전: 12 (API 31) 이상

2. **Pixel 4 XL**
   - 해상도: 1440×3040
   - 스크린샷 저장 시: 1080×1920
   - Android 버전: 11 (API 30) 이상

**새 에뮬레이터 생성 (필요시):**

1. Android Studio → Tools → Device Manager
2. "Create Device" 클릭
3. Category: Phone
4. 디바이스: Pixel 6 Pro 선택
5. System Image: Android 12 (API 31) 다운로드 및 선택
6. AVD Name: `Fortune_Screenshots_Pixel6Pro`
7. Graphics: Hardware - GLES 2.0
8. "Finish" 클릭

#### STEP 3: 에뮬레이터 설정

**언어 설정:**
```
Settings → System → Languages & input → Languages → Add Korean
```

**상태바 정리:**
1. 시간: 오전 10:00 정도
2. 배터리: 풀 차지
3. Wi-Fi: 연결됨
4. 알림: 모두 지우기

**다크모드:**
```
Settings → Display → Dark theme (ON/OFF)
```

#### STEP 4: 앱 실행

```bash
# Fortune 앱 에뮬레이터에서 실행
flutter run -d emulator-5554

# 또는 릴리즈 모드로
flutter run --release -d emulator-5554
```

**에뮬레이터 ID 확인:**
```bash
# 연결된 디바이스 목록
adb devices

# 예시 출력:
# emulator-5554  device
```

#### STEP 5: 스크린샷 촬영

**방법 1: adb 명령어 (권장)**
```bash
# 스크린샷 촬영 후 PC로 다운로드
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png ~/Desktop/fortune_android_1.png
adb shell rm /sdcard/screenshot.png
```

**방법 2: Android Studio**
```
1. Device Manager에서 실행 중인 에뮬레이터 옆 카메라 아이콘 클릭
2. "Save" 버튼으로 저장
```

**방법 3: 에뮬레이터 툴바**
```
에뮬레이터 우측 툴바 → 카메라 아이콘 (Screenshot) 클릭
```

#### STEP 6: 해상도 조정

Google Play는 1080×1920 권장이므로 다운스케일이 필요할 수 있습니다:

```bash
# ImageMagick 설치 (Mac)
brew install imagemagick

# 1080x1920으로 리사이즈
convert fortune_android_1.png -resize 1080x1920 fortune_android_1_resized.png

# 또는 비율 유지하며 리사이즈
convert fortune_android_1.png -resize 1080x1920\> fortune_android_1_resized.png
```

#### STEP 7: 해상도 확인

```bash
# 이미지 정보 확인
identify fortune_android_1.png

# 예상 출력:
# fortune_android_1.png PNG 1080x1920 8-bit sRGB
```

---

### 📋 Android 스크린샷 촬영 체크리스트

#### Phone (1080×1920) - 필수

- [ ] **스크린샷 1: 랜딩 페이지**
  - 에뮬레이터: Pixel 6 Pro
  - 화면: 로그인 전 첫 화면
  - 파일명: `android_landing.png`

- [ ] **스크린샷 2: 로그인 화면**
  - 에뮬레이터: Pixel 6 Pro
  - 화면: 소셜 로그인 옵션 표시
  - 파일명: `android_login.png`

- [ ] **스크린샷 3: 메인 대시보드**
  - 에뮬레이터: Pixel 6 Pro
  - 화면: 로그인 후 운세 카테고리 화면
  - 파일명: `android_dashboard.png`

- [ ] **스크린샷 4: 운세 생성**
  - 에뮬레이터: Pixel 6 Pro
  - 화면: 생년월일/시간 입력 화면
  - 파일명: `android_input.png`

- [ ] **스크린샷 5: 운세 결과**
  - 에뮬레이터: Pixel 6 Pro
  - 화면: AI 분석 결과 표시
  - 파일명: `android_result.png`

- [ ] **스크린샷 6: 프로필 설정**
  - 에뮬레이터: Pixel 6 Pro
  - 화면: 사용자 프로필 화면
  - 파일명: `android_profile.png`

- [ ] **스크린샷 7: 다크모드**
  - 에뮬레이터: Pixel 6 Pro (Dark Mode)
  - 화면: 메인 대시보드 or 운세 결과
  - 파일명: `android_dark.png`

- [ ] **스크린샷 8: 추가 기능** (선택)
  - 에뮬레이터: Pixel 6 Pro
  - 화면: 타로, 궁합 등 특별한 기능
  - 파일명: `android_extra.png`

---

### 🚀 Android 스크린샷 촬영 자동화 스크립트

**`scripts/android_screenshots.sh`**

```bash
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
if [ "$REPLY" != "" ]; then
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
```

**실행 방법:**
```bash
chmod +x scripts/android_screenshots.sh
./scripts/android_screenshots.sh
```

---

## 촬영해야 할 화면 리스트

### 1. 랜딩 페이지 (Landing Page)
```yaml
목적: 앱의 첫인상 전달
포함 요소:
  - 앱 로고/브랜딩
  - 메인 캐치프레이즈
  - "시작하기" 버튼
상태: 비로그인 상태
```

### 2. 로그인 화면 (Login Screen)
```yaml
목적: 간편한 로그인 옵션 강조
포함 요소:
  - 소셜 로그인 버튼 (Google, Apple, Kakao, Naver)
  - 깔끔한 UI
상태: 로그인 전
```

### 3. 메인 대시보드 (Main Dashboard)
```yaml
목적: 다양한 운세 카테고리 표시
포함 요소:
  - 오늘의 운세, 사주, 타로, 궁합 등 카드
  - 네비게이션 바
  - 사용자 프로필 아이콘
상태: 로그인 후
```

### 4. 운세 생성 화면 (Fortune Input)
```yaml
목적: 개인 맞춤 정보 입력 과정
포함 요소:
  - 생년월일 입력
  - 시간 선택
  - 위치 정보 (선택)
  - "운세 보기" 버튼
상태: 운세 생성 시작
```

### 5. 운세 결과 화면 (Fortune Result)
```yaml
목적: AI 분석 결과의 품질 강조
포함 요소:
  - 운세 제목/카테고리
  - 상세한 AI 분석 내용
  - 행운의 색깔/숫자 등
  - 공유 버튼
상태: 운세 생성 완료
```

### 6. 프로필 설정 (Profile)
```yaml
목적: 개인화 기능 및 설정 표시
포함 요소:
  - 사용자 정보
  - 저장된 운세 기록
  - 설정 옵션
상태: 로그인 후
```

### 7. 다크모드 (Dark Mode)
```yaml
목적: 다크모드 지원 강조
포함 요소:
  - 메인 화면 or 운세 결과 (다크 테마)
  - 부드러운 색상 전환
상태: 다크모드 활성화
```

### 8. 추가 기능 (Optional)
```yaml
목적: 특별한 기능 강조
예시:
  - 타로 카드 선택 화면
  - 궁합 분석 결과
  - 건강운 그래프
  - 위젯 화면
상태: 해당 기능 사용 중
```

---

## 스크린샷 편집 팁

### 필수 요소 제거

**제거해야 할 것:**
- ❌ 개인 정보 (실제 이름, 이메일, 전화번호)
- ❌ 디버그 정보/개발자 메뉴
- ❌ 에러 메시지
- ❌ 테스트 계정 정보

**유지해야 할 것:**
- ✅ 상태바 (시간, 배터리, 신호)
- ✅ 네비게이션 바
- ✅ 실제 콘텐츠
- ✅ 브랜딩 요소

### 텍스트 오버레이 추가 (선택사항)

각 스크린샷에 설명 텍스트를 추가하면 전환율이 높아집니다:

**도구:**
- Figma (무료)
- Canva (무료)
- Adobe Photoshop
- Sketch (Mac)

**템플릿 예시:**

```
┌─────────────────────────┐
│                         │
│   [스크린샷 이미지]      │
│                         │
│                         │
│   ▼ 텍스트 오버레이      │
│   ━━━━━━━━━━━━━━━━━━━  │
│   🔮 AI가 분석하는      │
│      나만의 운세         │
│                         │
└─────────────────────────┘
```

**권장 텍스트:**
1. "AI 기반 개인 맞춤형 운세"
2. "소셜 로그인으로 간편하게"
3. "다양한 운세 카테고리"
4. "생년월일 기반 정확한 분석"
5. "매일 업데이트되는 운세"
6. "깔끔한 UI/UX"
7. "다크모드 지원"

### 이미지 최적화

**파일 크기 줄이기:**

```bash
# PNG 최적화 (Mac)
brew install pngquant

# 파일 크기 줄이기 (품질 유지)
pngquant --quality=80-100 --ext .png --force screenshot.png

# JPG 변환 (더 작은 파일 크기)
convert screenshot.png -quality 90 screenshot.jpg
```

**배치 처리:**
```bash
# 모든 PNG 파일 최적화
for file in *.png; do
    pngquant --quality=80-100 --ext .png --force "$file"
done
```

---

## 자동화 스크립트

### 통합 스크린샷 촬영 스크립트

**`scripts/take_all_screenshots.sh`**

```bash
#!/bin/bash

# 통합 스크린샷 촬영 스크립트
# iOS와 Android 스크린샷을 순차적으로 촬영

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}📸 ZPZG 스크린샷 촬영 마스터${NC}"
echo ""
echo "이 스크립트는 다음을 수행합니다:"
echo "1. iOS 스크린샷 촬영 (iPhone 15 Pro Max, iPhone 11 Pro Max)"
echo "2. Android 스크린샷 촬영 (Pixel 6 Pro)"
echo ""
echo -e "${YELLOW}⚠️  시작하기 전에:${NC}"
echo "  - iOS 시뮬레이터를 준비하세요"
echo "  - Android 에뮬레이터를 준비하세요"
echo "  - Flutter 앱이 빌드 가능한 상태인지 확인하세요"
echo ""
read -p "계속하시겠습니까? (y/n) " -n 1 -r
echo

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 0
fi

# iOS 스크린샷
echo -e "\n${BLUE}=== 1단계: iOS 스크린샷 촬영 ===${NC}"
if [ -f "scripts/ios_screenshots.sh" ]; then
    ./scripts/ios_screenshots.sh
else
    echo "❌ ios_screenshots.sh를 찾을 수 없습니다."
fi

# Android 스크린샷
echo -e "\n${BLUE}=== 2단계: Android 스크린샷 촬영 ===${NC}"
if [ -f "scripts/android_screenshots.sh" ]; then
    ./scripts/android_screenshots.sh
else
    echo "❌ android_screenshots.sh를 찾을 수 없습니다."
fi

echo -e "\n${GREEN}🎉 모든 스크린샷 촬영 완료!${NC}"
echo ""
echo "📂 저장 위치:"
echo "  - iOS: ~/Desktop/Fortune_Screenshots/iOS/"
echo "  - Android: ~/Desktop/Fortune_Screenshots/Android/"
echo ""
echo "다음 단계:"
echo "  1. 스크린샷 품질 확인"
echo "  2. 필요시 텍스트 오버레이 추가"
echo "  3. App Store Connect 및 Google Play Console에 업로드"
```

**실행:**
```bash
chmod +x scripts/take_all_screenshots.sh
./scripts/take_all_screenshots.sh
```

---

## 체크리스트: 스크린샷 준비 완료

### iOS

- [ ] iPhone 15 Pro Max (6.7") 스크린샷 5-7개 촬영
- [ ] iPhone 11 Pro Max (6.5") 스크린샷 5-7개 촬영
- [ ] 해상도 확인: 1290×2796, 1242×2688
- [ ] 파일 포맷: PNG 또는 JPG
- [ ] 개인정보 제거 확인
- [ ] 다크모드 스크린샷 1-2개 포함

### Android

- [ ] Phone 스크린샷 5-8개 촬영
- [ ] 해상도 확인: 1080×1920 권장
- [ ] 파일 포맷: PNG 또는 JPG
- [ ] 파일 크기: 8MB 이하
- [ ] 개인정보 제거 확인
- [ ] 다크모드 스크린샷 1-2개 포함

### 공통

- [ ] 모든 화면 고품질 촬영 (흐릿하지 않음)
- [ ] 상태바 정리됨 (시간 9:41, 배터리 풀)
- [ ] 텍스트 오버레이 추가 (선택사항)
- [ ] 파일명 명확하게 지정
- [ ] 백업 완료

---

## 다음 단계

스크린샷 촬영 완료 후:

1. **App Store Connect**: https://appstoreconnect.apple.com
   - My Apps → [Your App] → App Store → Screenshots
   - 각 디바이스 크기별로 업로드

2. **Google Play Console**: https://play.google.com/console
   - Store presence → Main store listing → Graphics
   - Phone screenshots에 업로드

---

**문서 버전**: 1.0
**최종 업데이트**: 2025-01-15
**작성자**: Fortune Development Team
