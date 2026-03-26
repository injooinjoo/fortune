# Fortune 아키텍처 문서

현재 구현 기준으로 이 저장소는 `/chat` 중심의 AI 채팅 앱입니다. 사용자에게 보이는 핵심 경험은 `일반 채팅`과 `호기심` 두 가지이며, 둘 다 현재는 별도 상위 탭이 아니라 같은 메인 표면 안에서 동작합니다.

current-state 제품 표면과 라우트의 source of truth는 아래 순서를 따릅니다.

1. `lib/routes/route_config.dart`
2. `lib/routes/routes/auth_routes.dart`
3. `lib/routes/character_routes.dart`
4. `docs/getting-started/APP_SURFACES_AND_ROUTES.md`

## 1. 아키텍처 요약

### 제품 표면
- 메인 표면: `/chat`
- 보조 표면: 온보딩, 인증, 캐릭터 상세, 프리미엄, 정책, 계정 관리
- redirect-only: `/`, `/home`

### 사용자 경험 축
- `일반 채팅`: 일반 캐릭터와의 DM형 대화
- `호기심`: 전문가 캐릭터와의 설문 기반 대화 및 결과 소비

### 내부 구현 용어
- `story`: 사용자-facing 문서에서는 `일반 채팅`
- `fortune`: 사용자-facing 문서에서는 `호기심`

## 2. 라우팅 구조

### 활성 라우트

| 경로 | 역할 |
|------|------|
| `/chat` | 현재 앱의 메인 표면 |
| `/character/:id` | 캐릭터 상세/진입 보조 페이지 |
| `/onboarding` | 온보딩 |
| `/onboarding/toss-style` | 부분 완료 포함 온보딩 변형 |
| `/signup` | 가입 |
| `/auth/callback` | 인증 콜백 |
| `/splash` | 스플래시 |
| `/premium` | 프리미엄 |
| `/privacy-policy` | 개인정보처리방침 |
| `/terms-of-service` | 이용약관 |
| `/account-deletion` | 회원 탈퇴 |

### redirect-only

| 경로 | 동작 |
|------|------|
| `/` | `/chat`로 이동 |
| `/home` | `/chat`로 이동 |

### current-state 기준 비활성 상위 라우트
- `/fortune`
- `/trend`
- `/profile`
- `/interactive`
- `/health-toss`
- `/exercise`
- `/sports-game`

이 경로들은 current-state active route inventory에 포함하지 않습니다.

## 3. 메인 표면 구성

### `/chat`

`/chat`은 `SwipeHomeShell`로 구성되며, 현재 구현상 별도 탭 라우트보다 단일 표면에 가깝습니다.

구성 요소:
- `CharacterListPanel`: 캐릭터 목록과 내부 모드 전환
- `CharacterChatPanel`: 실제 대화 패널
- `SignupScreen`: 게스트 첫 진입 soft gate auth entry
- `OnboardingPage`: 인증 후 birth/interests/handoff를 처리하는 통합 first-run flow

동작 원리:
- 사용자는 첫 진입 시 `/chat` 내부 unified onboarding gate를 먼저 통과합니다.
- 게스트는 `SignupScreen` soft gate에서 둘러보기를 선택하거나 인증을 시작할 수 있습니다.
- 인증된 사용자는 `OnboardingPage`에서 birth, interest, handoff를 완료한 뒤 채팅 쉘로 진입합니다.
- 이후 사용자는 캐릭터 목록에서 일반 캐릭터 또는 전문가 캐릭터를 선택합니다.
- 일반 캐릭터를 선택하면 `일반 채팅` 경험으로 진입합니다.
- 전문가 캐릭터를 선택하거나 `fortuneType` 쿼리로 진입하면 `호기심` 경험으로 진입합니다.
- 결과는 별도 결과 페이지보다 채팅 안에서 메시지와 카드로 표시됩니다.

## 4. 모듈 책임

```text
lib/
├── core/                          # 디자인 시스템, 공통 서비스, 유틸
├── routes/                        # GoRouter 정의
├── features/
│   ├── character/                 # 현재 메인 표면, 캐릭터 목록/대화/상세
│   ├── chat/                      # 설문 모델, 입력 위젯, 결과 카드
│   ├── fortune/                   # 호기심 타입, 카테고리, 결과 도메인
│   ├── notification/              # 알림 설정 페이지
│   └── policy/                    # 법률 문서 페이지
├── screens/                       # 인증, 온보딩, 프리미엄, 계정 탈퇴
└── services/                      # 딥링크, 저장소, 푸시, 외부 연동
```

### `features/character`
- `/chat`의 현재 주 표면을 담당합니다.
- 일반 캐릭터와 전문가 캐릭터 목록을 관리합니다.
- 캐릭터 상세 페이지와 캐릭터 채팅 상태를 보유합니다.

### `features/chat`
- 설문 위젯, 입력 컴포넌트, 결과 카드 같은 채팅 공용 부품을 제공합니다.
- 호기심 경험에서 필요한 질문/응답 UI를 재사용합니다.

### `features/fortune`
- 호기심 카테고리와 canonical 타입 정의를 담당합니다.
- 전문가 캐릭터가 소비하는 인사이트 타입과 엔드포인트 매핑을 관리합니다.

## 5. 데이터 흐름

### 일반 채팅
1. 사용자가 일반 캐릭터를 선택합니다.
2. `selectedCharacterProvider`와 관련 채팅 상태가 설정됩니다.
3. `CharacterChatPanel`이 열리고 대화가 이어집니다.

### 호기심
1. 사용자가 전문가 캐릭터를 선택하거나 `fortuneType` 기반 딥링크로 진입합니다.
2. `FortuneChatLaunchRequest`가 쿼리 파라미터를 해석합니다.
3. `findFortuneExpert`가 해당 타입의 전문가 캐릭터를 찾습니다.
4. 채팅 내부에서 설문이 진행되고 결과를 요청합니다.
5. 결과는 채팅 메시지나 임베디드 카드로 출력됩니다.

## 6. 기술 스택

- Flutter 3.5.3+
- Riverpod StateNotifier
- GoRouter 15.x
- Supabase Auth / Database / Edge Functions
- Firebase Cloud Messaging

## 7. 설계 가드레일

- current-state 설명은 실제 코드와 1:1로 맞아야 합니다.
- 미래형 탭 구조나 별도 `/fortune`, `/trend`, `/profile`, `/interactive`, `/health-toss`, `/exercise`, `/sports-game` 설계는 source of truth가 아닙니다.
- 제품 IA 문서가 필요하면 먼저 `docs/getting-started/APP_SURFACES_AND_ROUTES.md`를 갱신합니다.
