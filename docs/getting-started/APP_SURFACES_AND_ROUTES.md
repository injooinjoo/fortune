# 현재 페이지/라우트 기준 문서

이 문서는 current-state 제품 표면과 라우트의 source of truth입니다.

현재 구현 기준 Fortune은 `AI 채팅 앱 + 2개 핵심 경험` 구조에 가깝습니다.

- `일반 채팅`: 세계관/테마가 다른 일반 캐릭터와 DM처럼 대화
- `호기심`: 운세 전문가 캐릭터와 설문 기반 대화를 진행하고 결과를 채팅형으로 소비

## 핵심 원칙

- 현재 메인 진입점은 `/chat`입니다.
- `호기심`은 별도 상위 route가 아니라 `/chat` 내부의 두 번째 경험 모드로 봅니다.
- 내부 구현의 `story` / `fortune` 분류는 사용자-facing 문서에서 `일반 채팅` / `호기심`으로 번역합니다.
- `CharacterProfilePage`는 메인 탭이 아니라 캐릭터 상세/진입 보조 페이지입니다.

## active route inventory

### 메인 표면

| 경로 | 역할 |
|------|------|
| `/chat` | 현재 앱의 메인 표면 |

### 보조 라우트

| 경로 | 역할 |
|------|------|
| `/splash` | 스플래시 |
| `/signup` | 가입 |
| `/auth/callback` | 인증 콜백 |
| `/onboarding` | 온보딩 |
| `/onboarding/toss-style` | 온보딩 변형 |
| `/character/:id` | 캐릭터 상세/채팅 진입 보조 |
| `/premium` | 프리미엄 |
| `/profile` | 프로필 허브 |
| `/profile/edit` | 프로필 편집 |
| `/profile/saju-summary` | 사주 요약 |
| `/profile/relationships` | 스토리 캐릭터 관계도 |
| `/profile/notifications` | 알림 설정 |
| `/privacy-policy` | 개인정보처리방침 |
| `/terms-of-service` | 이용약관 |
| `/account-deletion` | 회원 탈퇴 |

### redirect-only

| 경로 | 동작 |
|------|------|
| `/` | `/chat`로 이동 |
| `/home` | `/chat`로 이동 |

### current-state 기준 비활성 상위 라우트

아래 경로들은 현재 구현 기준 active route inventory에 포함하지 않습니다.

- `/fortune`
- `/trend`
- `/interactive`
- `/health-toss`
- `/exercise`
- `/sports-game`

## `/chat` 내부 표면

현재 `/chat`은 `SwipeHomeShell` 하나가 메인 표면입니다.

구성 요소:
- `CharacterListPanel`: 캐릭터 목록과 내부 분류 전환
- `CharacterChatPanel`: 대화 패널
- `SignupScreen`: 게스트 첫 진입 시 soft gate auth entry
- `OnboardingPage`: 인증 후 birth/interests/handoff 완료 전까지의 통합 온보딩

### 내부 경험 A: 일반 채팅

- 일반 캐릭터와의 관계형/세계관형 대화
- 현재 구현의 `story` 캐릭터 분류가 여기에 해당
- 별도 설문 없이 캐릭터 대화가 중심

### 내부 경험 B: 호기심

- 운세 전문가 캐릭터와의 질문형 대화
- 현재 구현의 `fortune` 캐릭터 분류가 여기에 해당
- 설문이 필요하면 채팅 안에서 단계별로 질문
- 결과는 채팅 메시지와 카드로 출력

## 딥링크와 자동 진입

- `fortuneType`이 포함된 링크는 `/chat`으로 유도됩니다.
- `FortuneChatLaunchRequest`가 쿼리 파라미터를 읽고, 해당 전문가 캐릭터를 찾아 호기심 경험으로 자동 진입시킵니다.

관련 코드:
- `lib/core/navigation/fortune_chat_route.dart`
- `lib/services/deep_link_service.dart`
- `lib/features/character/data/fortune_characters.dart`

## 문서 사용 규칙

### 이 문서를 갱신해야 하는 경우
- `lib/routes/`의 route 추가/삭제/redirect 변경
- `/chat`의 메인 표면 구성 변경
- `일반 채팅 | 호기심` 분류 기준 변경

### 이 문서보다 우선하는 것
- `lib/routes/route_config.dart`
- `lib/routes/routes/auth_routes.dart`
- `lib/routes/character_routes.dart`
