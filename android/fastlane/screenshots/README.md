# Android Screenshots Guide

이 디렉토리는 Google Play Store용 스크린샷을 저장하는 곳입니다.

## 디렉토리 구조

```
screenshots/
├── phoneScreenshots/      # 휴대전화 스크린샷
│   ├── ko-KR/            # 한국어
│   └── en-US/            # 영어
├── sevenInchScreenshots/ # 7인치 태블릿 (선택)
│   ├── ko-KR/
│   └── en-US/
└── tenInchScreenshots/   # 10인치 태블릿 (선택)
    ├── ko-KR/
    └── en-US/
```

## 스크린샷 요구사항

### 휴대전화 스크린샷 (필수)
- 최소: 320px
- 최대: 3840px
- 권장: 1080 x 1920 픽셀
- 수량: 최소 2개, 최대 8개
- 형식: JPEG 또는 24비트 PNG (알파 없음)

### 7인치 태블릿 (선택)
- 최소: 320px
- 최대: 3840px
- 권장: 1200 x 1920 픽셀

### 10인치 태블릿 (선택)
- 최소: 320px  
- 최대: 3840px
- 권장: 1600 x 2560 픽셀

## 스크린샷 생성 방법

### 1. 수동으로 생성

```bash
# Emulator 실행
emulator -avd Pixel_4_API_33

# 앱 실행
flutter run

# 스크린샷 캡처
adb shell screencap -p /sdcard/screenshot.png
adb pull /sdcard/screenshot.png ./screenshots/phoneScreenshots/ko-KR/
```

### 2. Fastlane Screengrab으로 자동 생성

```bash
cd android
fastlane screengrab
```

### 3. Flutter Driver로 자동화

```dart
// test_driver/screenshot_test.dart
import 'package:flutter_driver/flutter_driver.dart';
import 'package:test/test.dart';

void main() {
  group('Screenshots', () {
    FlutterDriver driver;

    setUpAll(() async {
      driver = await FlutterDriver.connect();
    });

    tearDownAll(() async {
      if (driver != null) {
        driver.close();
      }
    });

    test('capture screenshots', () async {
      // 메인 화면
      await driver.screenshot('01_main_screen');
      
      // 다른 화면으로 이동 후 캡처
      await driver.tap(find.byValueKey('daily_fortune_button'));
      await driver.screenshot('02_daily_fortune');
      
      // 계속...
    });
  });
}
```

## 스크린샷 네이밍 규칙

Google Play는 특별한 네이밍 규칙이 없지만, 관리를 위해 다음 규칙 권장:

- `01_main_screen.png` - 메인 화면
- `02_daily_fortune.png` - 오늘의 운세
- `03_fortune_categories.png` - 운세 카테고리
- `04_fortune_result.png` - 운세 결과
- `05_premium_features.png` - 프리미엄 기능
- `06_user_profile.png` - 사용자 프로필
- `07_compatibility.png` - 궁합 기능
- `08_lucky_items.png` - 행운 아이템

## 스크린샷 최적화 팁

### 1. 디바이스 설정
```bash
# 시간 설정 (오전 10:08)
adb shell date 1008

# 배터리 100% 설정
adb shell dumpsys battery set level 100

# Wi-Fi 연결 상태 설정
adb shell dumpsys battery set wireless 1
```

### 2. 콘텐츠 가이드라인
- 실제 사용자 정보 제거
- 데모 데이터 사용
- 광고 표시 제거 (프리미엄 버전)
- 명확한 UI 요소 표시

### 3. 이미지 최적화
```bash
# PNG 최적화
optipng -o7 screenshots/**/*.png

# JPEG 변환 (필요시)
for file in screenshots/**/*.png; do
  convert "$file" -quality 90 "${file%.png}.jpg"
done
```

## 그래픽 자산

### 기능 그래픽 (필수)
- 크기: 1024 x 500 픽셀
- 위치: `metadata/android/ko-KR/images/featureGraphic.png`

### 아이콘 (필수)
- 크기: 512 x 512 픽셀
- 위치: `metadata/android/ko-KR/images/icon.png`

### 프로모션 그래픽 (선택)
- 크기: 180 x 120 픽셀
- 위치: `metadata/android/ko-KR/images/promoGraphic.png`

### TV 배너 (TV 앱만)
- 크기: 1280 x 720 픽셀
- 위치: `metadata/android/ko-KR/images/tvBanner.png`

## 검증 체크리스트

- [ ] 모든 스크린샷이 요구 크기 충족
- [ ] 최소 2개 이상의 스크린샷 준비
- [ ] 모든 텍스트 가독성 확인
- [ ] 부적절한 콘텐츠 없음
- [ ] 최신 앱 버전 반영
- [ ] 각 언어별 스크린샷 준비
- [ ] 기능 그래픽 준비
- [ ] 고해상도 아이콘 준비

## 자동 업로드

```bash
cd android
fastlane deploy skip_upload_apk:true
```

이 명령은 메타데이터와 스크린샷만 업로드합니다.