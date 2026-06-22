# 온도 앱 Route / Screen Audit

이 문서는 `apps/mobile-rn/app`, `apps/mobile-rn/src/screens`, `apps/mobile-rn/src/features` 기준으로 작성한 UI/UX 플로우 감사 인벤토리다.

## 감사 기준

- Repo: `/Users/injoo/Desktop/Dev/fortune`
- 모바일 앱: `apps/mobile-rn`
- 라우팅: Expo Router (`apps/mobile-rn/app`)
- 실제 화면 컴포넌트: `apps/mobile-rn/src/screens`
- 정적 분석 결과: route `.tsx` 45개, `src/screens/*.tsx` 20개
- 모든 `src/screens/*.tsx`는 최소 1개 route에서 import됨.
- `knip` 후보는 삭제 확정이 아니라 dependency/reachability 후보로만 취급함.
- 실제 사용자가 들어가는 경로/버튼/자동 redirect/deep link 구분은 `docs/ROUTE_ENTRY_MAP.md`에 별도 정리함.

## 라우팅 정책 요약

```yaml
notLoggedIn:
  allowed:
    - /splash
    - /welcome
    - /chat?showList=1
    - /signup
    - /auth/email
    - /auth/phone
    - /auth/callback
    - legal pages
  redirectOthersTo:
    - /signup 또는 /chat?showList=1
  notes:
    - 게스트-first 정책 유지: 비로그인도 메시지 리스트/하늘이 핵심 경험 진입 가능
    - 최초 게스트는 welcome 확인 후 /chat?showList=1
    - 프로필/결제/개인화 기능은 계정 연결으로 유도

loggedIn + onboardingIncomplete:
  allowed:
    - /onboarding/*
    - /chat with ProfileFlowGateCard fallback
    - legal pages
  redirectOthersTo:
    - /onboarding/name after auth callback
  notes:
    - firstRunHandoffSeen, birthCompleted, interestCompleted 중 하나라도 false면 signup/auth 완료 후 onboarding으로 보냄
    - remote profile sync 후 fresh persisted onboarding progress로 판정

loggedIn + onboardingComplete:
  allowed:
    - /chat
    - /character/[id]
    - /profile/*
    - /premium
    - /friends/new/*
    - /result/[resultKind]
    - legal pages
  redirectOthersTo:
    - /chat

devOnly:
  allowed:
    - profile onboarding replay controls
  productionBehavior:
    - onboarding QA controls는 dev runtime에서만 표시
    - `/widgets`, `/profile/dev-tools` route는 삭제됨
```

## 전체 라우트 인벤토리

| 화면 이름 | 파일 경로 | 라우트 경로 | 실제 진입 가능 여부 | 진입 방법 | 연결된 버튼/메뉴/CTA | 로그인 필요 여부 | 회원가입 완료 필요 여부 | 온보딩 완료 필요 여부 | 현재 사용 여부 | 중복 가능성 | 삭제 가능성 | 비고 |
|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 앱 루트 | `apps/mobile-rn/app/index.tsx` | `/` | 가능 | 앱 첫 실행/root | 자동 redirect | 불필요 | 불필요 | 불필요 | 사용 | 없음 | 불가 | `/splash`로 redirect |
| 전역 레이아웃 | `apps/mobile-rn/app/_layout.tsx` | root stack | 가능 | 앱 shell | Provider/Stack | 불필요 | 불필요 | 불필요 | 사용 | 없음 | 불가 | AppBootstrap, MobileAppState, Onboarding/Friend/Social providers |
| 스플래시/라우팅 게이트 | `apps/mobile-rn/app/splash.tsx`, `src/screens/splash-screen.tsx` | `/splash` | 가능 | `/` redirect | 자동 | 불필요 | 불필요 | 상태별 | 사용 | 없음 | 불가 | guest welcome, profile-flow, ready 분기 |
| 웰컴 온보딩 | `apps/mobile-rn/app/welcome.tsx`, `src/screens/welcome-screen.tsx` | `/welcome` | 가능 | 최초 게스트, dev QA replay | 시작 CTA | 불필요 | 불필요 | 불필요 | 사용 | 온보딩과 목적 분리 | 불가 | 완료 후 `/chat?showList=1` |
| 계정 연결/회원가입 | `apps/mobile-rn/app/signup.tsx`, `src/screens/signup-screen.tsx` | `/signup` | 가능 | 프로필/프리미엄/게이트 CTA | Apple/Google/이메일/전화 | 불필요 | 불필요 | 불필요 | 사용 | auth wrapper | 불가 | 약관 링크 포함 |
| 이메일 로그인/가입 | `apps/mobile-rn/app/auth/email.tsx`, `src/screens/email-auth-screen.tsx` | `/auth/email` | 가능 | signup의 이메일 CTA | 이메일 계속하기 | 불필요 | 불필요 | 불필요 | 사용 | 없음 | 불가 | 성공 후 `/auth/callback` |
| 전화번호 로그인 | `apps/mobile-rn/app/auth/phone.tsx`, `src/screens/phone-auth-screen.tsx` | `/auth/phone` | 가능 | signup의 전화 CTA | 전화번호 계속하기 | 불필요 | 불필요 | 불필요 | 사용 | 없음 | 불가 | 성공 후 `/auth/callback` |
| 인증 콜백 | `apps/mobile-rn/app/auth/callback.tsx`, `src/screens/auth-callback-screen.tsx` | `/auth/callback` | 가능 | OAuth/email/phone callback | 자동 | 인증 진행 중 | 필요 | 상태별 | 사용 | 없음 | 불가 | incomplete onboarding이면 `/onboarding/name` |
| 채팅/메시지 리스트 | `apps/mobile-rn/app/(tabs)/chat.tsx`, `src/screens/chat-screen.tsx` | `/chat` | 가능 | 앱 메인, 하단/redirect/deeplink | 메시지 리스트, 캐릭터 row | 게스트 허용 | 불필요 | 불필요/게이트 카드 | 핵심 사용 | `app/chat.tsx` alias | 불가 | 핵심 IA |
| 채팅 alias | `apps/mobile-rn/app/chat.tsx` | `/chat` alias to `/(tabs)/chat` | 가능 | legacy/internal `/chat` | 자동 redirect | 게스트 허용 | 불필요 | 불필요 | 사용 | 실제 tab route와 중복 | 보류 | external/deeplink 호환 alias라 유지 |
| 프로필 stack layout | `apps/mobile-rn/app/(tabs)/profile/_layout.tsx` | `/profile/*` layout | 가능 | profile stack | 자동 guard | 로그인 필요 | 필요 | 불필요 | 사용 | 없음 | 불가 | 비로그인은 `/signup` |
| 프로필/설정 | `apps/mobile-rn/app/(tabs)/profile/index.tsx`, `src/screens/profile-screen.tsx` | `/profile` | 가능 | 프로필 버튼 | 프로필 수정, 설정, 법적 링크 | 로그인 필요 | 필요 | 불필요 | 사용 | settings hub | 불가 | 비로그인은 `/signup` |
| 프로필 편집 | `apps/mobile-rn/app/(tabs)/profile/edit.tsx`, `src/screens/profile-edit-screen.tsx` | `/profile/edit` | 가능 | 프로필 수정 버튼 | 저장/취소 | 로그인 필요 | 필요 | 불필요 | 사용 | 없음 | 불가 | 사주 요약에서도 진입 |
| 알림 설정 | `apps/mobile-rn/app/(tabs)/profile/notifications.tsx`, `src/screens/profile-notifications-screen.tsx` | `/profile/notifications` | 가능 | 프로필 > 알림 설정 | 알림 설정 tile | 로그인 필요 | 필요 | 불필요 | 사용 | 없음 | 불가 | notification preferences |
| 인간관계 | `apps/mobile-rn/app/(tabs)/profile/relationships.tsx`, `src/screens/profile-relationships-screen.tsx` | `/profile/relationships` | 가능 | 프로필 > 인간관계 | 캐릭터/친구 목록 | 로그인 필요 | 필요 | 불필요 | 사용 | 친구 생성과 연결 | 불가 | `/character/[id]`, `/friends/new` 진입 |
| 내 만세력 | `apps/mobile-rn/app/(tabs)/profile/saju-summary.tsx`, `src/screens/profile-saju-summary-screen.tsx` | `/profile/saju-summary` | 가능 | 프로필 > 내 만세력 | 프로필 수정 CTA | 로그인 필요 | 필요 | 일부 데이터 필요 | 사용 | 없음 | 불가 | birth profile dependency |
| 내 인사이트 | `apps/mobile-rn/app/profile/my-fortunes.tsx`, `src/screens/my-fortunes-screen.tsx` | `/profile/my-fortunes` | 가능 | 프로필 > 내 인사이트 | saved result row | 로그인 필요 | 필요 | 불필요 | 사용 | 없음 | 불가 | `/result/[resultKind]`로 연결 |
| 구독/토큰 | `apps/mobile-rn/app/premium.tsx`, `src/screens/premium-screen.tsx` | `/premium` | 가능 | token gauge, profile, chat paywall | 구독 및 토큰 CTA | 게스트는 signup returnTo | 계정 필요 | 불필요 | 사용 | 없음 | 삭제 불가/보류 | 결제/토큰 기능이라 삭제 금지 |
| 계정 삭제 | `apps/mobile-rn/app/account-deletion.tsx`, `src/screens/account-deletion-screen.tsx` | `/account-deletion` | 가능 | 프로필 하단 계정 삭제 | 삭제 확인 | 로그인 필요 | 필요 | 불필요 | 사용 | 없음 | 삭제 금지 | 법적/계정 필수 |
| 캐릭터 프로필 | `apps/mobile-rn/app/character/[id].tsx`, `src/screens/character-profile-screen.tsx` | `/character/[id]` | 가능 | 채팅방 헤더/관계 목록 | 캐릭터 프로필 | 게스트/로그인 상태별 | 불필요 | 불필요 | 사용 | 없음 | 불가 | 하늘이 프로필 확인됨 |
| 친구 생성 시작 | `apps/mobile-rn/app/friends/new/index.tsx`, `src/screens/friend-picker-screen.tsx` | `/friends/new` | 가능/상태 의존 | 메시지 리스트 FAB, 관계 화면 | 친구 만들기 | 기능상 로그인/토큰 상태 영향 | 보통 필요 | 불필요 | 출시 기능 | 다단계 flow | Hide 검토 | 현재 연결됨, 삭제 금지 |
| 친구 생성 기본정보 | `apps/mobile-rn/app/friends/new/basic.tsx`, `src/screens/friend-creation-screen.tsx` | `/friends/new/basic` | 가능/flow state | picker 다음 | 다음 | 상태 의존 | 필요 가능 | 불필요 | 사용 | 같은 screen 파일 공유 | 불가 | draft guard |
| 친구 생성 페르소나 | `apps/mobile-rn/app/friends/new/persona.tsx`, `src/screens/friend-creation-screen.tsx` | `/friends/new/persona` | 가능/flow state | basic 다음 | 다음 | 상태 의존 | 필요 가능 | 불필요 | 사용 | 같은 screen 파일 공유 | 불가 | missing basic이면 basic |
| 친구 생성 스토리 | `apps/mobile-rn/app/friends/new/story.tsx`, `src/screens/friend-creation-screen.tsx` | `/friends/new/story` | 가능/flow state | persona 다음 | 다음 | 상태 의존 | 필요 가능 | 불필요 | 사용 | 같은 screen 파일 공유 | 불가 | missing step guard |
| 친구 생성 검토 | `apps/mobile-rn/app/friends/new/review.tsx`, `src/screens/friend-creation-screen.tsx` | `/friends/new/review` | 가능/flow state | story/avatar 이후 | 생성 CTA | 상태 의존 | 필요 가능 | 불필요 | 사용 | 같은 screen 파일 공유 | 불가 | flow gate |
| 친구 생성 아바타 | `apps/mobile-rn/app/friends/new/avatar.tsx`, `src/screens/friend-creation-screen.tsx` | `/friends/new/avatar` | 가능/flow state | review/avatar step | 아바타 선택 | 상태 의존 | 필요 가능 | 불필요 | 사용 | 같은 screen 파일 공유 | 불가 | flow gate |
| 친구 생성 중/완료 | `apps/mobile-rn/app/friends/new/creating.tsx`, `src/screens/friend-creation-screen.tsx` | `/friends/new/creating` | 가능/flow state | 생성 CTA | 완료 후 chat | 상태 의존 | 필요 가능 | 불필요 | 사용 | 같은 screen 파일 공유 | 불가 | 성공 후 `/chat?characterId=...` |
| 온보딩 entry | `apps/mobile-rn/app/onboarding/index.tsx` | `/onboarding` | 가능 | auth/profile-flow/직접 | 자동 redirect | 로그인 후 핵심 | 필요 | 미완료만 | 사용 | 없음 | 삭제 금지 | `/onboarding/name` |
| 온보딩 이름 | `apps/mobile-rn/app/onboarding/name.tsx` | `/onboarding/name` | 가능 | signup/auth 완료 후 | 이름 입력 다음 | 로그인 후 핵심 | 필요 | 미완료 | 사용 | 없음 | 삭제 금지 | step 1 |
| 온보딩 생년월일 | `apps/mobile-rn/app/onboarding/birth.tsx` | `/onboarding/birth` | 가능 | name 다음 | 날짜 다음 | 로그인 후 핵심 | 필요 | 미완료 | 사용 | 없음 | 삭제 금지 | step 2 |
| 온보딩 MBTI | `apps/mobile-rn/app/onboarding/mbti.tsx` | `/onboarding/mbti` | 가능 | birth 다음 | MBTI 다음 | 로그인 후 핵심 | 필요 | 미완료 | 사용 | 없음 | 삭제 금지 | step 3 |
| 온보딩 관계 | `apps/mobile-rn/app/onboarding/relationship.tsx` | `/onboarding/relationship` | 가능 | MBTI 다음 | 관계 카드 | 로그인 후 핵심 | 필요 | 미완료 | 사용 | 없음 | 삭제 금지 | step 4 |
| 온보딩 대화 톤 | `apps/mobile-rn/app/onboarding/tone.tsx` | `/onboarding/tone` | 가능 | relationship 다음 | 톤 slider | 로그인 후 핵심 | 필요 | 미완료 | 사용 | 없음 | 삭제 금지 | step 5 |
| 온보딩 관심사 | `apps/mobile-rn/app/onboarding/topics.tsx` | `/onboarding/topics` | 가능 | tone 다음 | 완료 CTA | 로그인 후 핵심 | 필요 | 미완료 | 사용 | 없음 | 삭제 금지 | saveProfile + completeOnboarding |
| fortune legacy route | `apps/mobile-rn/app/fortune.tsx` | `/fortune` | 직접/외부 가능 | legacy/widget/deeplink | flag redirect | 게스트 허용 | 불필요 | 불필요 | 호환 | `/chat` redirect | 삭제 금지/보류 | feature flag `fortune_route_behavior` |
| 결과 상세 | `apps/mobile-rn/app/result/[resultKind].tsx` | `/result/[resultKind]` | 가능 | 내 인사이트/결과 card | 결과 보기 | 상태별 | 불필요 | 불필요 | 사용 | 없음 | 불가 | invalid kind는 error card |
| 위젯 deeplink | `apps/mobile-rn/app/widget.tsx` | `/widget` | 가능 | iOS widget/native | 자동 chat rewrite | 게스트 허용 | 불필요 | 불필요 | 사용 | `/widgets`와 다름 | 삭제 금지 | app.config/native refs |
| 개인정보처리방침 | `apps/mobile-rn/app/privacy-policy.tsx`, `src/screens/legal-screen.tsx` | `/privacy-policy` | 가능 | signup/profile/legal | legal tile | 불필요 | 불필요 | 불필요 | 필수 | LegalScreen 공유 | 삭제 금지 | 법적 페이지 |
| 이용약관 | `apps/mobile-rn/app/terms-of-service.tsx`, `src/screens/legal-screen.tsx` | `/terms-of-service` | 가능 | signup/profile/legal | legal tile | 불필요 | 불필요 | 불필요 | 필수 | LegalScreen 공유 | 삭제 금지 | 법적 페이지 |
| EULA | `apps/mobile-rn/app/eula.tsx`, `src/screens/legal-screen.tsx` | `/eula` | 가능 | profile/legal | legal tile | 불필요 | 불필요 | 불필요 | 필수 | LegalScreen 공유 | 삭제 금지 | App Store/UGC compliance |
| 운세/AI 면책 고지 | `apps/mobile-rn/app/disclaimer.tsx`, `src/screens/legal-screen.tsx` | `/disclaimer` | 가능 | profile/legal | 면책 조항 tile | 불필요 | 불필요 | 불필요 | 필수 | LegalScreen 공유 | 삭제 금지 | 운세/AI 고지 |
| 사업자 정보 | `apps/mobile-rn/app/business-info.tsx`, `src/screens/legal-screen.tsx` | `/business-info` | 가능 | profile footer | 사업자 정보 링크 | 불필요 | 불필요 | 불필요 | 필수 | LegalScreen 공유 | 삭제 금지 | 전자상거래법 접근성 |
| 오픈소스 라이선스 | `apps/mobile-rn/app/open-source-licenses.tsx`, `src/screens/legal-screen.tsx` | `/open-source-licenses` | 가능 | profile/legal | legal tile | 불필요 | 불필요 | 불필요 | 필수 | LegalScreen 공유 | 삭제 금지 | OSS notice |
| not-found | `apps/mobile-rn/app/+not-found.tsx`, `src/screens/route-screen.tsx` | unknown route | 가능 | invalid path | chat CTA | 불필요 | 불필요 | 불필요 | 사용 | 없음 | 불가 | disabled `/fortune` fallback |

## `src/screens` reachability

| Screen file | 연결 route | 판정 |
|---|---|---|
| `account-deletion-screen.tsx` | `/account-deletion` | Keep |
| `auth-callback-screen.tsx` | `/auth/callback` | Fix 적용 |
| `character-profile-screen.tsx` | `/character/[id]` | Keep |
| `chat-screen.tsx` | `/chat` | Keep |
| `email-auth-screen.tsx` | `/auth/email` | Keep |
| `friend-creation-screen.tsx` | `/friends/new/*` | Keep, route-step 분리 후보 |
| `friend-picker-screen.tsx` | `/friends/new` | Keep |
| `legal-screen.tsx` | legal pages | Keep, 정상 공유 |
| `my-fortunes-screen.tsx` | `/profile/my-fortunes` | Keep |
| `phone-auth-screen.tsx` | `/auth/phone` | Keep |
| `premium-screen.tsx` | `/premium` | Keep/feature flag 검토 |
| `profile-edit-screen.tsx` | `/profile/edit` | Keep |
| `profile-notifications-screen.tsx` | `/profile/notifications` | Keep |
| `profile-relationships-screen.tsx` | `/profile/relationships` | Keep |
| `profile-saju-summary-screen.tsx` | `/profile/saju-summary` | Keep |
| `profile-screen.tsx` | `/profile` | Fix/Delete cleanup 적용 |
| `route-screen.tsx` | `+not-found` | Keep |
| `signup-screen.tsx` | `/signup` | Keep |
| `splash-screen.tsx` | `/splash` | Fix 적용 |
| `welcome-screen.tsx` | `/welcome` | Keep |

## 정적 분석 주의 후보

삭제 후보였던 `/home`, `/trend`, `/onboarding/toss-style`, `/widgets`, `/profile/dev-tools`, `speaker-button`은 실제 삭제했다. 남은 후보는 아래처럼 false-positive 가능성이 높아 유지한다.

- `babel.config.js`, Expo plugin, Expo deps: `knip` false-positive 가능. 삭제 금지.
