# 온도 앱 QA Checklist

## QA 산출물 위치

- 원본 PNG: `docs/qa/screenshots/`
- contact sheet: `docs/qa/contact-sheet.png`
- ZIP: `docs/qa/ondo-route-audit-screenshots.zip`
- 접근 결과 표: 이 문서

> 실제 캡처는 현재 환경의 설치된 dev-client/시뮬레이터 상태에 의존한다. 자동화에서 `expo start`, `npx expo start`, `npx expo run:*`는 실행하지 않는다.

## 코드/정적 검증

| 항목 | 상태 | 증거 |
|---|---|---|
| 초기 git tree clean 확인 | 완료 | `git status --short` 초기 출력 clean |
| route 파일 인벤토리 | 완료 | `apps/mobile-rn/app` `.tsx` 45개 |
| screen 파일 인벤토리 | 완료 | `src/screens/*.tsx` 20개, 모두 route import |
| TypeScript | 완료 | `pnpm --filter @fortune/mobile-rn exec tsc --noEmit` exit 0 |
| lint | 완료 | `pnpm --filter @fortune/mobile-rn lint` exit 0, 기존 warning 61개 / error 0 |
| knip | 완료 | unused 후보 5개, unused dependency 1개, exported symbol 후보 다수. delete 확정 아님 |
| jscpd | 완료 | 444 files, 32 clones, duplicated lines 0.87%. 삭제 근거가 아니라 리팩터 후보 |
| source inventory | 차단 | `scripts/source_inventory.py` 파일 없음 |

## 실제 화면 접근 체크리스트

| 화면 | 기대 접근 경로 | 필요한 상태 | 현재 판정 | 실패 시 원인 분류 |
|---|---|---|---|---|
| 메시지 리스트 | 앱 실행 → `/splash` → `/chat?showList=1` | 게스트 허용 | 확인 필요 | dev-client/route 상태 |
| 계정 연결 | 프로필 버튼 또는 gated CTA → `/signup` | 게스트 | 확인 필요 | profile guard |
| 계정 연결 확장 | `/signup`에서 다른 방법/소셜/이메일 CTA | 게스트 | 확인 필요 | auth provider/config |
| 이메일 로그인 | `/signup` → 이메일 | 게스트 | 확인 필요 | 버튼/route |
| 전화번호 로그인 | `/signup` → 전화번호 | 게스트 | 확인 필요 | 버튼/route |
| 이메일 회원가입 | `/auth/email` | 게스트 | 확인 필요 | 실제 이메일 인증 필요 |
| 회원가입 완료 후 온보딩 | `/auth/callback` → `/onboarding/name` | 신규/미완료 계정 | 코드 Fix 완료, runtime 확인 필요 | 실제 인증 필요 |
| 온보딩 이름 | `/onboarding/name` | onboarding incomplete | 확인 필요 | route guard/state |
| 온보딩 생년월일 | name 다음 | onboarding draft | 확인 필요 | step state |
| 온보딩 MBTI | birth 다음 | onboarding draft | 확인 필요 | step state |
| 온보딩 관계 | MBTI 다음 | onboarding draft | 확인 필요 | step state |
| 온보딩 대화 톤 | relationship 다음 | onboarding draft | 확인 필요 | step state |
| 온보딩 관심사 | tone 다음 | onboarding draft | 확인 필요 | step state |
| 온보딩 완료 후 메시지 리스트 | topics 완료 | valid profile data | 확인 필요 | saveProfile/remote sync |
| 캐릭터 채팅방 | 메시지 리스트 캐릭터 row | 게스트/로그인 | 확인 필요 | data/cache |
| 캐릭터 프로필 | 채팅방 header/profile CTA | 게스트/로그인 | 확인 필요 | route params |
| 프로필 편집 | `/profile` → 프로필 수정 | 로그인 | 확인 필요 | auth 필요 |
| 알림 설정 | `/profile` → 알림 설정 | 로그인 | 확인 필요 | auth 필요 |
| 인간관계 | `/profile` → 인간관계 | 로그인 | 확인 필요 | auth 필요 |
| 내 만세력 | `/profile` → 내 만세력 | 로그인+birth data | 확인 필요 | profile data |
| 내 인사이트 | `/profile` → 내 인사이트 | 로그인 | 확인 필요 | history state |
| 프리미엄/토큰 | profile token gauge/구독 및 토큰 | 게스트는 signup returnTo, 로그인 권장 | 확인 필요 | store native module |
| 친구 생성 | 관계/FAB → `/friends/new` | 상태/feature readiness | 확인 필요 | feature flag/slot/token |
| 약관 | signup/profile → `/terms-of-service` | 게스트 허용 | 확인 필요 | legal route |
| 개인정보처리방침 | signup/profile → `/privacy-policy` | 게스트 허용 | 확인 필요 | legal route |
| EULA | profile → `/eula` | 게스트 허용 | 확인 필요 | legal route |
| 사업자 정보 | profile footer → `/business-info` | 게스트 허용 | 확인 필요 | legal route |
| 오픈소스 라이선스 | profile → `/open-source-licenses` | 게스트 허용 | 확인 필요 | legal route |
| 운세/AI 고지 | profile → `/disclaimer` | 게스트 허용 | 확인 필요 | legal route |
| 계정 삭제 | profile → 계정 삭제 | 로그인 | 확인 필요 | auth 필요 |

## 캡처 성공/실패 표

런타임 캡처 후 아래 표를 업데이트한다.

| Screen | Capture file | Result | Notes |
|---|---|---|---|
| 메시지 리스트 | `docs/qa/screenshots/01-message-list.png` | success | iPhone 17 iOS 26.4 simulator, 실제 클릭/launch flow |
| 계정 연결 | `docs/qa/screenshots/02-signup.png` | success | 비로그인 프로필 버튼 → `/signup` |
| 계정 연결 확장 | `docs/qa/screenshots/02b-signup-expanded.png` | success | “다른 방법으로 시작” expanded |
| 이메일 로그인 | `docs/qa/screenshots/03-email-auth.png` | success | signup → email auth 화면 |
| 전화번호 로그인 | `docs/qa/screenshots/04-phone-auth.png` | success | signup → phone auth 화면 |
| 온보딩 이름 | `docs/qa/screenshots/05-onboarding-name.png` | blocked | `com.beyond.fortune:///onboarding/name` direct open이 현재 message list로 수렴. 실제 신규 인증 state 필요 |
| 캐릭터 채팅방 | `docs/qa/screenshots/06-chat-room.png` | success | 메시지 리스트 → 하늘이 row 클릭 |
| 캐릭터 프로필 | `docs/qa/screenshots/07-character-profile.png` | success | 채팅방 header “하늘이 프로필 보기” 클릭 |
| 프로필/계정 연결 | `docs/qa/screenshots/08-profile-or-signup.png` | success | 비로그인 프로필 클릭 시 계정 연결으로 이동 확인 |

## 남은 수동/상태 의존 검증

- 실제 이메일/전화 인증 완료 후 `/auth/callback`이 `/onboarding/name`으로 보내는지 확인.
- 기존 onboarding completed 계정은 `/chat?showList=1`로 가는지 확인.
- production build/env에서 삭제된 `/widgets`, `/profile/dev-tools` 메뉴가 노출되지 않고 onboarding QA controls도 dev 조건에서만 노출되는지 확인.
- premium/token purchase는 실제 StoreKit/TestFlight 또는 dev-client native module 상태에서 검증.
- 친구 생성은 free/login/token/slot 정책이 확정된 상태에서 end-to-end 검증.
