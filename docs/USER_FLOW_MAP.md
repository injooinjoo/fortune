# 온도 앱 User Flow Map

## 1. 비로그인 유저 플로우

### 의도한 정책

- 온도는 App Store guest-first 정책을 유지한다.
- 비로그인 유저도 첫 가치 경험인 메시지 리스트/하늘이 진입은 가능하다.
- 프로필, 클라우드 동기화, 구매/복원, 개인화 저장이 필요한 지점에서 계정 연결을 유도한다.

### 현재/정리 후 플로우

1. 앱 실행 → `/` → `/splash`
2. Supabase session 없음 + welcome 미완료
   - `/welcome`
   - 완료 CTA → `markWelcomeSeen()` → `/chat?showList=1`
3. Supabase session 없음 + welcome 완료
   - `/chat?showList=1`
4. 메시지 리스트에서 캐릭터 row 선택
   - 하늘이 채팅방 진입 가능
5. 비로그인 상태에서 프로필 접근
   - profile stack guard → `/signup`
6. `/signup`
   - Apple 로그인
   - Google 로그인
   - 이메일 로그인/가입: `/auth/email`
   - 전화번호 로그인: `/auth/phone`
   - 법적 링크 접근 가능: 개인정보처리방침, 이용약관, EULA 등
7. 로그인 실패/취소
   - `/auth/callback` error/timeout UI에서 다시 시도 → `/signup`
8. 로그인 성공
   - `/auth/callback`에서 fresh onboarding progress 확인
   - onboarding incomplete → `/onboarding/name`
   - onboarding complete → `returnTo` 또는 `/chat?showList=1`

### 비로그인 접근 가능 법적 페이지

- `/privacy-policy`
- `/terms-of-service`
- `/eula`
- `/disclaimer`
- `/business-info`
- `/open-source-licenses`

## 2. 신규 회원가입 유저 플로우

### 목표 플로우

1. `/signup`
2. 이메일/전화번호/소셜 인증 완료
3. `/auth/callback`
4. `markAuthComplete()`
5. `syncRemoteProfile()`
6. `getUnifiedOnboardingProgress()`로 최신 persisted progress 재확인
7. 아래 중 하나라도 false면 `/onboarding/name`
   - `firstRunHandoffSeen`
   - `birthCompleted`
   - `interestCompleted`
8. 온보딩 단계 진행
   - 이름: `/onboarding/name`
   - 생년월일: `/onboarding/birth`
   - MBTI: `/onboarding/mbti`
   - 관계: `/onboarding/relationship`
   - 대화 톤: `/onboarding/tone`
   - 관심사: `/onboarding/topics`
9. `/onboarding/topics`에서 `saveProfile()` + `updateOnboardingProgress()` + `completeOnboarding()`
10. 완료 후 `/chat`

### 중간 이탈/재진입

- 현재 구조는 `OnboardingFlowProvider`가 in-memory step 데이터를 들고 있고, 최종 topics 단계에서 profile 저장을 완료한다.
- auth callback과 splash/profile-flow는 onboarding incomplete 유저를 `/onboarding` 또는 `/onboarding/name`으로 복귀시킨다.
- 세부 step resume은 아직 완전한 persisted step index가 아니라 첫 단계 복귀에 가깝다. 다만 user flow가 끊기지는 않도록 redirect 정책을 정리했다.

### 이미 완료한 유저

- remote profile `onboarding_completed === true` 또는 remote fortune preferences에 interest weights가 있으면 `interestCompleted: true`와 `firstRunHandoffSeen: true`로 local progress를 동기화한다.
- 이미 완료한 유저는 auth callback에서 onboarding으로 돌아가지 않고 `returnTo` 또는 `/chat?showList=1`로 이동한다.

## 3. 기존 로그인 유저 플로우

1. 앱 실행 → `/splash`
2. `AppBootstrapProvider`가 SecureStore progress, pending fortune, cached conversations, Supabase session 로드
3. session 있음
   - `authCompleted: true`, `softGateCompleted: true`
   - 이전 user id와 다르면 onboarding progress 일부 reset
   - push token register, pending replies resume
4. `resolveChatOnboardingGate()`
   - complete: `ready` → `/chat`
   - incomplete: `profile-flow` → `/onboarding`
5. 메시지 리스트에서 하늘이/캐릭터 진입
6. 채팅방 헤더/관계 목록에서 캐릭터 프로필 진입
7. push/deeplink는 `/chat?characterId=...`로 정규화

## 4. 프로필/설정 플로우

### 프로필 hub

- `/profile`
- 비로그인 직접 진입 시 `/signup`
- 로그인 후 사용 가능 메뉴:
  - 프로필 수정: `/profile/edit`
  - 내 만세력: `/profile/saju-summary`
  - 내 인사이트: `/profile/my-fortunes`
  - 인간관계: `/profile/relationships`
  - 알림 설정: `/profile/notifications`
  - 구독 및 토큰: `/premium`
  - 구매 복원
  - 구독 관리 external URL
  - 로그아웃
  - 계정 삭제: `/account-deletion`
  - 법적/정보 페이지

### 법적/정보 플로우

- 개인정보처리방침: `/privacy-policy`
- 이용약관: `/terms-of-service`
- 사용자 라이선스(EULA): `/eula`
- 면책 조항/운세·AI 고지: `/disclaimer`
- 오픈소스 라이선스: `/open-source-licenses`
- 사업자 정보: `/business-info`

삭제하지 않는다.

### Dev/QA 플로우

- `/profile/dev-tools` route는 삭제했다.
- profile 화면의 온보딩 replay control은 dev runtime 조건 + onboarding QA email 조건에서만 표시한다.

## 5. 수익화/프리미엄 플로우

### 존재/진입

- route: `/premium`
- screen: `src/screens/premium-screen.tsx`
- profile token gauge, profile 구독 및 토큰 tile, chat/token 부족 상황, friend creation gating에서 진입한다.

### 판단

- 결제/토큰 관련 화면은 삭제 대상이 아니다.
- 기능 미구현 또는 스토어 unavailable 상태는 screen 내부 UX/feature guard로 처리한다.
- 현재 route 자체는 실제 서비스 플로우에 포함되어 있으므로 Keep.

## 6. 친구/캐릭터 생성 플로우

### 존재/진입

- `/friends/new`: 친구 생성 시작/선택
- `/friends/new/basic`: 기본 정보
- `/friends/new/persona`: 페르소나
- `/friends/new/story`: 스토리
- `/friends/new/review`: 검토
- `/friends/new/avatar`: 아바타
- `/friends/new/creating`: 생성 중/완료

### 연결

- `ProfileRelationshipsScreen`에서 `/friends/new` 진입 가능.
- 메시지 리스트 FAB에서도 진입하는 구조로 설계되어 있다.
- 생성 완료 후 `/chat?characterId=...` 또는 `returnTo`로 이동한다.

### 판단

- 다단계가 모두 `friend-creation-screen.tsx`를 공유하므로 파일 단위로는 중복처럼 보이나 route-state flow다.
- 삭제보다 출시 정책에 따라 feature flag/hide 검토가 맞다.
- 현재 감사에서는 삭제하지 않았다.

## 7. 위젯 플로우

- `/widget`: iOS widget/native deep link handler. 실제 기능 route라 Keep.
- `/widgets`: 내부 showcase/prototype route였으므로 삭제했다. 실제 iOS widget deep link와 무관하다.

## 8. 실패/취소/중간 이탈 플로우

| 상황 | 현재 처리 |
|---|---|
| OAuth callback error | `/auth/callback`에서 로그인 실패 UI → `/signup` 재시도 |
| callback session timeout | 30초 후 timeout UI → `/signup` 재시도 |
| welcome 완료 | `/chat?showList=1` |
| onboarding 완료 | `/chat` |
| onboarding incomplete auth 완료 | `/onboarding/name` |
| profile 직접 접근 비로그인 | `/signup` |
| unknown route | `+not-found` screen → `/chat` CTA |

## 9. 실제 클릭 기준 확인 필요 상태

시뮬레이터에서 실제 버튼 클릭으로 확인해야 하는 항목은 `docs/QA_CHECKLIST.md`에 정리했다. 인증/실계정/스토어/native dev-client 상태가 필요한 화면은 “코드상 존재하지만 상태 의존”으로 분류한다.
