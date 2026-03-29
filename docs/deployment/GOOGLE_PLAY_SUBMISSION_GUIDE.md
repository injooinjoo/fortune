# Google Play Submission Guide

최종 업데이트: 2026-03-18

## 1. 릴리스 산출물
- Release bundle: `build/app/outputs/bundle/release/app-release.aab`
- 검증 명령:
  - `flutter build appbundle --release`
  - `flutter analyze`
  - `flutter test`

## 2. 공개 URL
- Privacy Policy: `https://zpzg.co.kr/privacy`
- Terms: `https://zpzg.co.kr/terms`
- Support: `https://zpzg.co.kr/support.html`
- Asset Links: `https://zpzg.co.kr/.well-known/assetlinks.json`

## 3. Android 권한 기준

Manifest source:
- `android/app/src/main/AndroidManifest.xml`

현재 제출 기준 권한:
- `com.android.vending.BILLING`
- `android.permission.INTERNET`
- `android.permission.POST_NOTIFICATIONS`
- `android.permission.VIBRATE`
- `android.permission.RECEIVE_BOOT_COMPLETED`
- `android.permission.WAKE_LOCK`
- `android.permission.RECORD_AUDIO`
- `android.permission.READ_CALENDAR`
- `android.permission.WRITE_CALENDAR`
- `android.permission.ACCESS_FINE_LOCATION`
- `android.permission.ACCESS_COARSE_LOCATION`

보수 제출에서 제거한 항목:
- `READ_MEDIA_IMAGES`
- app links `autoVerify`
- 광고/추적 관련 설명

## 4. Data Safety 입력 기준

### Collected
- Personal info
  - Email address
  - Account management, customer support

- Photos and videos
  - User-selected photos only
  - App functionality

- Audio
  - Voice input content when feature is used
  - App functionality

- Location
  - Approximate / coarse location
  - App functionality

- Financial info / purchases
  - Purchase history for subscription/token entitlement verification
  - App functionality

- App activity
  - Product interaction / in-app activity
  - Analytics, app functionality

- Device or other IDs
  - User ID / app-scoped identifiers
  - Account management, app functionality

### Not collected / not declared
- Advertising ID
- Crashlytics-specific crash sharing declaration
- Broad photo library access

### Policy answers
- Data is encrypted in transit: Yes
- Users can request deletion: Yes
- Data is sold: No
- Data is shared for advertising: No

## 5. App Links / `.well-known`
- `assetlinks.json`는 공개 경로에 배포되어야 함
- 현재 릴리스는 `autoVerify`를 꺼 둔 보수 설정
- live endpoint가 200 + JSON + 올바른 SHA-256을 만족한 뒤에만 App Links를 재활성화

주의:
- `assetlinks.json`의 SHA-256은 현재 로컬 업로드 키 기준
- Play App Signing 사용 시 Console의 App Signing certificate fingerprint와 다를 수 있으므로 반드시 최종 확인

## 6. 스토어 등록 정보 체크
- App name: `Ondo`
- Category: `Lifestyle`
- Short/full description은 토큰 소비 모델과 현재 기능 범위를 벗어나지 않게 유지
- 의료·법률·재무 조언처럼 오해될 표현 금지

메타데이터 소스:
- `android/fastlane/metadata/android/ko-KR/full_description.txt`
- `android/fastlane/metadata/android/en-US/full_description.txt`

## 7. 제출 전 콘솔 작업
- Data Safety form 실제 입력
- Photos/Video declaration 확인
- Content rating / app content questionnaire 확인
- Internal testing 또는 closed testing track에서 install/open/deep link 수동 확인

## 8. 외부 확인이 필요한 항목
- Play App Signing certificate SHA-256
- live `assetlinks.json` 응답 상태
- Play Console pre-launch report 결과
