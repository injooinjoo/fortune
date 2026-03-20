# App Store Connect Submission Info

최종 업데이트: 2026-03-20

## 1. 공개 URL
- Privacy Policy: `https://zpzg.co.kr/privacy`
- Terms of Use (EULA): `https://zpzg.co.kr/terms`
- Support URL: `https://zpzg.co.kr/support.html`

현재 저장소 기준 공개 자산 소스:
- `public/privacy.html`
- `public/terms.html`
- `public/support.html`
- `public/.well-known/apple-app-site-association`

## 2. 앱 기본 정보
- App Name: `ZPZG`
- Category: `Lifestyle`
- Copyright:
  - `© 2026 ZPZG. All rights reserved.`

## 3. App Privacy 입력 기준

### 수집하는 데이터
- Contact Info
  - Email Address
  - 목적: Account Management, Customer Support
  - Linked to User: Yes
  - Used for Tracking: No

- User Content
  - Photos or Videos
  - 목적: Face/photo based features only when user selects or captures media
  - Linked to User: No
  - Used for Tracking: No

- Identifiers
  - User ID
  - 목적: Account Management, App Functionality
  - Linked to User: Yes
  - Used for Tracking: No

- Purchases
  - Purchase History
  - 목적: Subscription and token entitlement validation
  - Linked to User: Yes
  - Used for Tracking: No

- Location
  - Coarse Location
  - 목적: App Functionality
  - Linked to User: No
  - Used for Tracking: No

- Usage Data
  - Product Interaction
  - 목적: Analytics, App Functionality
  - Linked to User: No
  - Used for Tracking: No

### 추적 관련 답변
- ATT prompt: 사용 안 함
- IDFA: 사용 안 함
- Third-party tracking domains: 없음
- `NSPrivacyTracking`: `false`

## 4. 권한 서술 기준
- Camera: 사용자가 직접 얼굴 사진을 촬영할 때만 요청
- Photos: 사용자가 직접 선택한 사진만 업로드
- Microphone / Speech Recognition: 음성 입력 기능에서만 요청
- Location When In Use: 날씨/지역 기반 인사이트에서만 요청
- Calendar: 일정 저장 기능에서만 요청
- Push Notifications: 앱 시작 시 자동 요청하지 않고 `Profile > Notification Settings` 또는 테스트 알림 액션에서만 요청

검토 기준 파일:
- `ios/Runner/Info.plist`
- `ios/Runner/PrivacyInfo.xcprivacy`

## 5. 리뷰 노트 체크
- 리뷰 계정 및 비밀번호는 아래 파일 기준으로 유지
  - `metadata/review_information/demo_user.txt`
  - `metadata/review_information/demo_password.txt`
  - `ios/fastlane/metadata/review_information/review_demo_user.txt`
  - `ios/fastlane/metadata/review_information/review_demo_password.txt`
- 리뷰 노트는 아래 파일 기준
  - `metadata/review_information/notes.txt`
  - `ios/fastlane/metadata/review_information/review_notes.txt`

노트에 반드시 포함할 내용:
- 앱은 오락/웰빙 참고용 서비스이며 진단·치료 대체가 아님
- 토큰/구독 정책은 앱 내 결제 화면 기준
- 계정 삭제는 앱 내 설정 화면에서 가능
- 푸시 알림 권한은 설정 화면 또는 테스트 알림 액션에서만 요청
- Universal Links는 AASA live endpoint 검증 후에만 재활성화

## 6. 제출 전 수동 확인
- App Store Connect의 Privacy Policy URL, Support URL, App Privacy questionnaire, Age Rating는 inflight version에서 2026-03-20 기준 확인 완료
- App Review notes는 `ios/fastlane/metadata/review_information/review_notes.txt` 기준으로 2026-03-20 기준 ASC에 저장 완료
- Content Rights / Sign-In requirements는 제출 직전 최종 확인
- TestFlight 또는 archive validation에서 privacy manifest validation 확인

## 7. 이번 보수 제출에서 제거/비활성화한 항목
- ATT usage description 제거
- 앱 시작 직후 푸시 알림 자동 요청 제거
- SKAdNetwork declarations 제거
- Associated Domains entitlement 제거
- 광고/추적 기반 심사 서술 제거

## 8. 남은 외부 콘솔/실기기 작업
- Content Rights / Sign-In requirements 제출 직전 최종 확인
- 실기기 IAP 성공/취소/복원 및 권한 노출 타이밍 증빙 확보
- AASA live 200 확인 후 Universal Links 재활성화 여부 결정
