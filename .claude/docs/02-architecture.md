# Clean Architecture 가이드

> 최종 업데이트: 2026.04.06

Ondo의 현재 런타임 구조를 repo truth 기준으로 정리한 문서입니다. 예전의 기능 분산형 구조를 설명하기보다, 지금 유지되는 feature slice, 화면 계층, Edge Function 경계를 단일 기준으로 고정합니다.

## 아키텍처 통계

| 항목 | 수치 |
|------|------|
| Features | 6개 |
| Edge Functions | 72개 (`fortune-*` 43 + `personality-dna` 1 + utility 28, `_shared` 제외) |
| StateNotifier 클래스 | 30개 |
| Active Agents | 5개 |

## 현재 프로젝트 구조

```text
lib/
├── core/                       # 디자인 시스템, 네트워크, 공용 서비스, 공통 위젯
├── features/                   # feature slice 6개
│   ├── character/              # 캐릭터 채팅, 프로필, 친구 생성, 결과 body 조립층
│   ├── chat/                   # 채팅 도메인 모델, 추천 칩, 채팅 결과 카드
│   ├── chat_insight/           # 인사이트 히스토리/관계 분석 보조 UI
│   ├── fortune/                # 운세 카테고리, 도메인 엔티티, 일부 프레젠테이션 위젯
│   ├── notification/           # 알림 설정 화면
│   └── policy/                 # 개인정보처리방침, 이용약관
├── screens/                    # splash, signup, onboarding, profile, premium
├── routes/                     # GoRouter 진입점과 surface route 선언
├── providers/                  # 앱 전역 Provider
└── main.dart                   # 앱 진입점
```

## Feature Slice 기준

현재 문서에서 feature는 아래 6개만 활성 구조로 본다.

| Feature | 역할 | 비고 |
|---------|------|------|
| `character` | 메인 product surface, 캐릭터 채팅/프로필/친구 생성 | 현재 사용자 경험의 중심 |
| `chat` | 채팅 메시지/추천 칩/채팅용 결과 카드 | character surface를 지원 |
| `chat_insight` | 인사이트 기록/보조 시각화 | chat/fortune 사이 보조 레이어 |
| `fortune` | 운세 카테고리/도메인 모델/일부 위젯 | Remote Config 카테고리 기준 |
| `notification` | 알림 설정 페이지 | profile 하위 surface |
| `policy` | 약관/개인정보처리방침 | 법률/정책 surface |

이전 문서에 남아 있던 다수의 세분 feature 목록은 더 이상 기준으로 사용하지 않습니다.

## 레이어 규칙

기본 의존 방향은 아래를 유지합니다.

```text
presentation -> domain <- data
```

### 허용되는 의존성
- `presentation -> domain`
- `data -> domain`
- `core -> all`
- `screens/routes -> feature presentation`

### 금지되는 의존성
- `presentation -> data`
- `domain -> presentation`
- `domain -> data`
- `feature A -> feature B` 직접 참조

## 현재 런타임 레이어

### 1. Product surface
- `/chat`, `/character/:id`, `/friends/new/*`의 실질 UI 조립층은 `features/character/presentation/`에 있습니다.
- `/splash`, `/signup`, `/onboarding`, `/profile`, `/premium` 등 앱 shell 성격 화면은 `screens/`에 유지합니다.

### 2. Shared UI system
- 범용 UI primitive는 `lib/core/design_system/`가 소스 오브 트루스입니다.
- Pencil-aligned page chrome은 `lib/core/widgets/paper_runtime_*.dart`가 담당합니다.
- 운세 결과용 공용 shell은 `lib/shared/components/cards/fortune_cards.dart`에 있습니다.

### 3. State management
- 프로젝트 표준은 수동 `StateNotifier + StateNotifierProvider`입니다.
- `@riverpod` 생성 패턴은 사용하지 않습니다.
- 문서 기준 `StateNotifier` 클래스 수는 30개입니다.

### 4. Server/runtime boundary
- 서버 함수는 `supabase/functions/`에 모여 있습니다.
- 문서 bucket은 아래를 기준으로 고정합니다.

| Bucket | 개수 | 기준 |
|--------|------|------|
| Fortune | 44 | `fortune-*` 43개 + `personality-dna` |
| Utility | 28 | 인증, 결제, 캐시, 캐릭터, 토큰, 구독, 스포츠 등 |
| Shared | 제외 | `_shared/`는 공용 모듈이므로 총량 계산에서 제외 |

## Navigation 기준

- `/` -> `/chat`
- `/home` -> `/chat`
- `/chat`은 현재 앱의 메인 진입점
- `/profile` 아래에 `edit`, `saju-summary`, `relationships`, `notifications`
- `/friends/new/*`는 `character_routes.dart`에서 관리

라우팅 상세는 [24-page-layout-reference.md](24-page-layout-reference.md)를 우선 참조합니다.

## 관련 문서

- [03-ui-design-system.md](03-ui-design-system.md)
- [05-fortune-system.md](05-fortune-system.md)
- [18-chat-first-architecture.md](18-chat-first-architecture.md)
- [24-page-layout-reference.md](24-page-layout-reference.md)
- [25-fortune-result-schemas.md](25-fortune-result-schemas.md)
