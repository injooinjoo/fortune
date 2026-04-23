# W9 — Push 권한 JIT 정책

## 변경
`apps/mobile-rn/src/lib/push-notifications.ts` `registerPushTokenForSignedInUser`가 이제 옵션 `{ promptIfNotGranted: boolean }` 지원. 기본값 `false` — cold-start 호출은 권한이 이미 허용된 경우에만 토큰 등록, 미허용 시 silent skip (OS 프롬프트 안 띄움). 기존 호출자(앱 부트스트랩, `onAuthStateChange`)는 파라미터 없이 호출 → 기본 false 동작 → **JIT 준수**.

## 효과
- App Store 리뷰어가 앱을 처음 켤 때 "알림 허용" 프롬프트가 뜨지 않음. 관련 경고 제거.
- 권한이 이미 허용된 유저 경험은 동일 (silent register).

## 필요 후속 작업 (W9 Part 2, 별도 스프린트)
**명시적 opt-in UI**. 현재 코드에 "알림 받기" 토글/버튼이 없으므로, 유저가 푸시를 한 번도 허용한 적 없다면 영영 못 켬.

### 권장 구현
1. `apps/mobile-rn/src/screens/profile-screen.tsx`에 "알림 받기" Switch 추가
   - 상태: `Notifications.getPermissionsAsync()` + `user_notification_preferences.push_enabled`
   - ON 액션: `registerPushTokenForSignedInUser({ promptIfNotGranted: true })` → token 저장 + pref ON
   - OFF 액션: edge function `sync-notification-device` 로 token 비활성화 + pref OFF
2. 또는 `apps/mobile-rn/src/screens/onboarding-screen.tsx` 마지막 단계에 "알림 허용" 카드 추가 (이미 건너뜀 가능)
3. 또는 첫 AI 캐릭터 응답 수신 시 inline banner — "알림을 켜면 답장이 빨라요 [허용]"

### 참고 테이블
- `user_notification_preferences.push_enabled` 컬럼이 이미 존재 (migrations 확인)

## 리젝 리스크 평가
- **W9 단독**: 기본 false 만으로 ASC 리뷰어가 cold-start prompt 가 없다는 사실 확인 가능. iOS 시뮬레이터/TestFlight 에서 콜드스타트 → 프롬프트 안 뜸 → 정상. **리젝 블로커 아님**.
- **W9 Part 2 (opt-in UI)**: 푸시 기능이 실제로 동작하는지 평가할 때 문제. 심사는 통과하지만 "왜 알림 안 뜨지?" UX 문제.
