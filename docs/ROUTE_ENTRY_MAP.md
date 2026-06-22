# 온도 앱 Route Entry Map

목적: `apps/mobile-rn/app`의 각 route가 **실제로 어떤 UI/자동 라우팅/딥링크를 통해 들어갈 수 있는지**를 정리한다. 이번 정리에서 버튼 없는 legacy/prototype route는 삭제했고, 남은 route만 기준으로 기록한다.

## 기준

- Route source: `apps/mobile-rn/app/**`
- Navigation evidence: `router.push`, `router.replace`, `Redirect`, `href`, 주요 screen CTA 확인
- 현재 route 파일 수: 45개
- 삭제됨: `/home`, `/trend`, `/onboarding/toss-style`, `/widgets`, `/profile/dev-tools`, `speaker-button` component

## 판정 범례

- **버튼 있음**: 일반 사용자가 앱 UI에서 누를 수 있는 CTA/menu/row가 있음.
- **자동**: 앱 부팅, 인증 콜백, flow 완료 등 코드가 자동 이동함.
- **순차 flow**: 이전 step의 다음 버튼으로만 진입하는 route.
- **상태 의존**: 로그인, 온보딩 진행 상태, draft state 등이 필요.
- **딥링크/호환**: UI 버튼은 없거나 제한적이지만 native/push/widget/legacy 처리를 위해 유지.

## 핵심 사용자 플로우별 실제 진입 루트

### 1. 앱 시작 / 게스트-first

| Route | 실제 진입 루트 | 버튼/CTA | 판정 | 메모 |
|---|---|---|---|---|
| `/` | 앱 cold start / root open | 없음 | 자동 | `app/index.tsx`에서 `/splash`로 redirect |
| `/splash` | `/` redirect, 앱 부팅 gate | “시작하기/계속하기” 성격 CTA | 자동 + 버튼 | auth/session/onboarding/welcome 상태 계산 |
| `/welcome` | 최초 게스트, QA replay | 시작 CTA | 버튼 있음 | 완료 후 `/chat?showList=1` |
| `/chat` | splash/welcome 완료, tab route, push/widget rewrite | 메시지 리스트 row, header/profile, chat CTA | 버튼 있음 + 자동 | 핵심 landing. `app/chat.tsx` alias는 유지 |

### 2. 계정 연결 / 인증

| Route | 실제 진입 루트 | 버튼/CTA | 판정 | 메모 |
|---|---|---|---|---|
| `/signup` | 비로그인 profile 접근, chat gate/account CTA, premium returnTo | Apple/Google/이메일/전화/법적 링크 | 버튼 있음 | 계정 연결 hub |
| `/auth/email` | signup의 이메일 CTA, chat account gate | 이메일 계속하기 | 버튼 있음 | 성공 후 `/auth/callback` |
| `/auth/phone` | signup의 전화번호 CTA, chat account gate | 전화번호 계속하기 | 버튼 있음 | 성공 후 `/auth/callback` |
| `/auth/callback` | OAuth/email/phone 성공 redirect | 실패 시 signup 재시도 CTA | 자동 | 인증 결과 처리 route |

### 3. 신규 회원 온보딩

| Route | 실제 진입 루트 | 버튼/CTA | 판정 | 메모 |
|---|---|---|---|---|
| `/onboarding` | auth callback/splash/profile-flow에서 incomplete 상태일 때 | 없음 | 자동 | `/onboarding/name`으로 redirect |
| `/onboarding/name` | `/onboarding` redirect, auth 완료 후 incomplete 상태 | 다음 | 순차 flow | step 1 |
| `/onboarding/birth` | name step 다음 | 다음 | 순차 flow | step 2 |
| `/onboarding/mbti` | birth step 다음 | 다음 | 순차 flow | step 3 |
| `/onboarding/relationship` | MBTI step 다음 | 관계 카드 | 순차 flow | step 4 |
| `/onboarding/tone` | relationship step 다음 | 톤 선택/다음 | 순차 flow | step 5 |
| `/onboarding/topics` | tone step 다음 | 완료 CTA | 순차 flow | 최종 저장 후 `/chat` |

### 4. 프로필 / 설정

| Route | 실제 진입 루트 | 버튼/CTA | 판정 | 메모 |
|---|---|---|---|---|
| `/profile` | chat list header profile, fallback back target | 프로필 메뉴 tile들 | 버튼 있음 | 비로그인 direct 접근은 `/signup` |
| `/profile/edit` | profile의 프로필 수정, saju summary 수정 CTA | 저장/취소 | 버튼 있음 | 실제 연결됨 |
| `/profile/saju-summary` | profile의 내 만세력 tile | 프로필 수정 CTA | 버튼 있음 | 실제 연결됨 |
| `/profile/my-fortunes` | profile의 내 인사이트 tile | saved result row | 버튼 있음 | result detail로 연결 |
| `/profile/relationships` | profile의 인간관계 tile | 캐릭터 row, 친구 만들기 | 버튼 있음 | character/friends flow 진입 |
| `/profile/notifications` | profile의 알림 설정 tile | 알림 설정 controls | 버튼 있음 | 실제 연결됨 |

### 5. 프리미엄 / 토큰

| Route | 실제 진입 루트 | 버튼/CTA | 판정 | 메모 |
|---|---|---|---|---|
| `/premium` | profile 구독/토큰 tile, token gauge, chat paywall/top-up, friend creation gating | 구독/토큰 CTA, 결제/복원 | 버튼 있음 + 상태 의존 | 결제/토큰 핵심 route라 삭제 금지 |

### 6. 친구/캐릭터 생성

| Route | 실제 진입 루트 | 버튼/CTA | 판정 | 메모 |
|---|---|---|---|---|
| `/friends/new` | chat list FAB, profile relationships 친구 만들기 | 친구 만들기/선택 | 버튼 있음 | 시작점 |
| `/friends/new/basic` | picker 다음 | 다음 | 순차 flow | draft state 의존 |
| `/friends/new/persona` | basic 다음 | 다음 | 순차 flow | missing basic이면 basic으로 guard |
| `/friends/new/story` | persona 다음 | 다음 | 순차 flow | missing step guard |
| `/friends/new/review` | story/avatar 이후 | 생성 CTA | 순차 flow | 최종 검토 |
| `/friends/new/avatar` | review/avatar step | 아바타 선택 | 순차 flow | draft state 의존 |
| `/friends/new/creating` | review 생성 CTA | 완료 후 chat | 순차 flow | 성공 후 `/chat?characterId=...` |

### 7. 캐릭터 / 결과

| Route | 실제 진입 루트 | 버튼/CTA | 판정 | 메모 |
|---|---|---|---|---|
| `/character/[id]` | chat room header, relationships 캐릭터 row | 캐릭터 프로필 | 버튼 있음 | id 필요 |
| `/result/[resultKind]` | my fortunes saved result row, result card/detail CTA | 결과 보기 | 버튼 있음 + 상태 의존 | resultKind 유효성 필요 |

### 8. 법적/정보 페이지

| Route | 실제 진입 루트 | 버튼/CTA | 판정 | 메모 |
|---|---|---|---|---|
| `/privacy-policy` | signup 약관 링크, profile legal tile | 개인정보처리방침 | 버튼 있음 | 법적 필수 |
| `/terms-of-service` | signup 약관 링크, profile legal tile | 이용약관 | 버튼 있음 | 법적 필수 |
| `/eula` | profile legal tile | 사용자 라이선스 | 버튼 있음 | App Store/UGC compliance |
| `/disclaimer` | profile legal tile | 면책 조항 | 버튼 있음 | 운세/AI 고지 |
| `/business-info` | profile footer | 사업자 정보 | 버튼 있음 | 전자상거래법 접근성 |
| `/open-source-licenses` | profile legal tile | 오픈소스 라이선스 | 버튼 있음 | OSS notice |
| `/account-deletion` | profile 하단 계정 삭제 | 삭제 확인 | 버튼 있음 | 계정/법적 필수. 로그인 필요 |

### 9. Widget / legacy / fallback

| Route | 실제 진입 루트 | 버튼/CTA | 판정 | 메모 |
|---|---|---|---|---|
| `/widget` | iOS widget/native deep link | 없음 | 딥링크/호환 | 실제 native widget handler라 유지 |
| `/fortune` | legacy/feature-flag 직접 접근 가능 | 없음 | 딥링크/호환 | `fortune_route_behavior` 처리 route라 이번 삭제 범위 밖 |
| unknown route | invalid path | chat CTA | fallback | `+not-found` screen |

## 버튼이 없지만 남겨둔 route

| Route | 유지 이유 |
|---|---|
| `/` | 앱 root라 버튼 대상 아님 |
| `/splash` | cold-start gate |
| `/auth/callback` | 인증 provider callback |
| `/onboarding` | incomplete onboarding 자동 entry |
| `/widget` | iOS widget/native deep link handler |
| `/fortune` | feature flag/legacy fortune 처리 route |
| `+not-found` | fallback |

## 요약

- 일반 사용자가 앱 UI에서 직접 들어갈 수 있는 주요 route: `/chat`, `/profile`, `/profile/*`, `/premium`, `/friends/new`, `/character/[id]`, `/result/[resultKind]`, legal/account pages.
- 버튼 없이 자동으로만 들어가는 route: `/`, `/splash`, `/auth/callback`, `/onboarding`.
- 버튼 없이도 유지하는 deep link/호환 route: `/widget`, `/fortune`.
- 삭제한 route/prototype: `/home`, `/trend`, `/onboarding/toss-style`, `/widgets`, `/profile/dev-tools`.
