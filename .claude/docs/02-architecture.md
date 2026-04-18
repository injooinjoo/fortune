# 아키텍처 가이드 (React Native)

> 최종 업데이트: 2026.04.17

Ondo의 현재 런타임 구조를 repo truth 기준으로 정리한 문서입니다. Flutter 코드는 제거되었고, 활성 트리는 `apps/mobile-rn/` (Expo SDK + TypeScript) 하나만 기준으로 고정합니다. 레거시 `lib/` 디렉터리에 남은 파편은 참조하지 않습니다.

## 아키텍처 통계

| 항목 | 수치 |
|------|------|
| Mobile features | 5개 (`chat-surface`, `chat-survey`, `chat-results`, `fortune-results`, `fortune-cookie`) |
| Fortune result screens | 12개 (batch-a~e, birthstone, celebrity, face-reading, lucky-items, moving, naming, pet-compatibility) |
| App providers | 4개 (`app-bootstrap`, `mobile-app-state`, `social-auth`, `friend-creation`) |
| Edge Functions | 79개 (`fortune-*` 45 + `personality-dna` 1 + utility 33, `_shared` 제외) |
| Workspace packages | 2개 (`@fortune/product-contracts`, `@fortune/design-tokens`) |

## 현재 프로젝트 구조

```text
apps/mobile-rn/
├── app/                          # expo-router 파일 기반 라우트 (진입점)
│   ├── _layout.tsx               # 루트 Provider 조립 (Bootstrap → SocialAuth → MobileAppState)
│   ├── index.tsx, splash.tsx     # 부트 진입 + 스플래시
│   ├── (tabs)/                   # 탭 셸 (chat / profile)
│   ├── auth/                     # 이메일·전화 인증 라우트
│   ├── onboarding/               # 신규 가입 플로우 (toss-style 포함)
│   ├── character/[id].tsx        # 캐릭터 프로필 동적 라우트
│   ├── friends/new/*             # 친구 생성 다단계 라우트 (basic/persona/avatar/review/story/creating)
│   ├── result/[resultKind].tsx   # 운세 결과 동적 라우트
│   └── chat.tsx, fortune.tsx, trend.tsx, premium.tsx, signup.tsx, ...
├── src/
│   ├── features/                 # 도메인 UI 슬라이스 (아래 "Feature Slice" 참고)
│   ├── providers/                # 전역 상태 Provider (React Context)
│   ├── screens/                  # 라우트가 소비하는 상위 화면 컴포넌트
│   ├── components/               # 범용 UI primitive (chip, card, screen, buttons 등)
│   └── lib/                      # 도메인 로직, 클라이언트, 스토리지, 테마
└── assets/, ios/, android/, ...

packages/
├── product-contracts/            # @fortune/product-contracts (routes, fortunes, products, 딥링크, Zod normalizer)
└── design-tokens/                # @fortune/design-tokens (컬러/타입 토큰)

supabase/
└── functions/                    # Edge Functions 79개 (_shared 제외)
```

## 레이어 개요

의존 방향은 `app → screens → features → providers → lib → components` 순서로 흐릅니다. 반대 방향 import는 금지합니다.

### 1. `app/` — Routing Shell (expo-router)
- 파일명이 곧 URL 경로입니다. `app/chat.tsx`는 `/chat`, `app/(tabs)/profile/edit.tsx`는 탭 셸 하위 `/profile/edit`로 매핑됩니다.
- 각 라우트는 얇은 wrapper로 두고, 실제 화면 조립은 `src/screens/`나 `src/features/*`로 위임합니다.
- `app/_layout.tsx`에서 전역 Provider 트리를 조립합니다.

### 2. `src/screens/` — 라우트 소비자
- `chat-screen.tsx`, `profile-screen.tsx`, `friend-creation-screen.tsx`, `premium-screen.tsx` 등 라우트에서 직접 참조하는 상위 컴포넌트 계층입니다.
- 여러 feature slice를 엮고, 라우트 파라미터를 풀고, provider 값을 소비합니다.

### 3. `src/features/` — Feature Slice (도메인 UI)
- 각 feature는 자기 UI + 로컬 로직을 같은 폴더에 캡슐화합니다. 공용 유틸은 `src/lib/`로 끌어올립니다.
- feature 간 직접 import는 금지합니다. 재사용이 필요하면 `lib` 또는 `components`로 이동시킵니다.

| Feature | 역할 | 주요 파일 |
|---------|------|-----------|
| `chat-surface` | 채팅 렌더링 셸 | `chat-surface.tsx` |
| `chat-survey` | 대화형 설문 위젯 + 레지스트리 | `registry.ts`, `tarot-draw-widget.tsx`, `types.ts` |
| `chat-results` | 채팅에 임베드되는 운세 카드 | `adapter.ts`, `edge-runtime.ts`, `embedded-result-card.tsx`, `fixtures.ts` |
| `fortune-results` | 전체 화면 운세 결과 (12 screens) | `registry.tsx`, `mapping.ts`, `use-result-data.ts`, `screens/*.tsx` |
| `fortune-cookie` | 포춘쿠키/사주 프리뷰 카드 | `fortune-cookie-card.tsx`, `saju-preview-card.tsx` |

### 4. `src/providers/` — 전역 상태
- React Context + `useReducer`/`useState` 조합만 사용합니다. Redux, Zustand, MobX, Jotai는 도입하지 않습니다.
- Provider 간 의존은 `app/_layout.tsx`의 조립 순서로 고정하고, 하위 Provider가 `useXxx()` 훅으로 상위 값을 읽습니다.

| Provider | 책임 |
|----------|------|
| `app-bootstrap-provider` | 앱 부트 상태, Supabase 세션/디바이스 식별, 스플래시 게이트 |
| `mobile-app-state-provider` | `MobileAppState` 영속화, IAP 상태, 원격 프리미엄 스냅샷, 알림 설정 |
| `social-auth-provider` | Apple/Google/이메일/전화 인증 플로우 |
| `friend-creation-provider` | `/friends/new/*` 다단계 폼 상태 |

### 5. `src/lib/` — 도메인 로직·클라이언트
- UI 없는 TypeScript 모듈만 둡니다. 예: `chat-shell.ts`, `story-chat-runtime.ts`, `character-details.ts`, `saju-remote.ts`, `manseryeok-local.ts`, `supabase.ts`, `theme.ts`, `haptics.ts`, `storage.ts`.
- 외부 서비스 경계(Supabase, IAP, Secure Store, Sentry)는 여기서만 건드립니다. feature에서 직접 호출하지 않습니다.

### 6. `src/components/` — UI Primitive
- `screen.tsx`, `card.tsx`, `chip.tsx`, `primary-button.tsx`, `voice-text-input.tsx`, `survey-composer.tsx` 등 범용 컴포넌트입니다.
- 도메인 지식은 가지지 않고, theme 토큰만 소비합니다.

## 허용 / 금지 의존성

### 허용
- `app/* → screens/*, features/*, providers/*`
- `screens/* → features/*, providers/*, lib/*, components/*`
- `features/* → lib/*, components/*, providers/*` (훅 형태)
- `providers/* → lib/*`
- `lib/* → (외부 SDK + @fortune/* 패키지)`

### 금지
- `features/A → features/B` 직접 import
- `lib/* → components/*` 또는 `features/*` 역참조
- `components/* → features/*, providers/*`
- `app/*`에 비즈니스 로직 삽입 (라우트 wrapper로만 유지)

## 상태 관리 (React Context + Reducer 패턴)

프로젝트 표준은 **React Context + `useReducer`/`useState`**입니다. 추가 상태 라이브러리(Redux, Zustand, Recoil, MobX)는 도입하지 않습니다.

- 전역 상태가 필요하면 `src/providers/`에 Context + Provider 컴포넌트를 만듭니다.
- 영속화는 `src/lib/storage.ts` (AsyncStorage wrapper) 또는 `secure-store-storage.ts`를 경유합니다.
- 원격 상태(프리미엄/프로필)는 `lib/*-remote.ts`에서 비동기 함수로 노출하고, Provider가 마운트 시점에 hydrate합니다.
- 컴포넌트 내부 상태는 `useState`/`useReducer`로 충분할 때 Context로 끌어올리지 않습니다.

## 라우트 등록 (expo-router)

expo-router는 `app/` 디렉터리 구조를 그대로 라우트 트리로 읽습니다. 별도의 라우터 선언 파일은 없습니다.

- 정적 라우트: `app/chat.tsx` → `/chat`
- 탭 그룹: `app/(tabs)/_layout.tsx` + 하위 라우트들
- 동적 라우트: `app/character/[id].tsx` → `/character/:id`
- 중첩 레이아웃: `app/friends/new/_layout.tsx` (필요 시)
- 딥링크 규약은 `@fortune/product-contracts/deep-links`에서 관리하며, 라우트 key가 이곳의 타입과 일치해야 합니다.

네비게이션 매핑 상세는 [24-page-layout-reference.md](24-page-layout-reference.md)를 우선 참조합니다.

## 공용 워크스페이스 패키지

Monorepo는 npm workspaces 기반이며, 공용 타입/토큰은 `packages/` 아래에서 소비합니다.

| 패키지 | 역할 |
|--------|------|
| `@fortune/product-contracts` | Fortune type ID, 라우트 key, IAP product catalog, 딥링크 파서, Zod 기반 result normalizer, 온보딩/분석 계약 |
| `@fortune/design-tokens` | 색상·타입·스페이싱 토큰 (`src/theme.ts`가 소비) |

두 패키지 모두 Edge Function(`supabase/functions/`)에서도 공유해서 mobile ↔ server 계약을 단일 소스로 유지합니다.

## Server / Runtime Boundary

서버 경계는 `supabase/functions/` 하나로 고정합니다. 모바일은 Edge Function을 직접 호출합니다.

```ts
import { supabase } from '@/lib/supabase'

const { data, error } = await supabase.functions.invoke('fortune-daily', {
  body: { fortuneTypeId, payload },
})
```

- Edge Function 내부에서는 `_shared/` 모듈(LLMFactory, middleware, validation)을 경유합니다. OpenAI/Gemini 직접 호출은 금지입니다.
- 문서 bucket 기준:

| Bucket | 개수 | 기준 |
|--------|------|------|
| Fortune | 46 | `fortune-*` 45개 + `personality-dna` |
| Utility | 33 | 인증, 결제, 캐시, 캐릭터 채팅, 토큰, 구독, 스포츠 등 |
| Shared | 제외 | `_shared/`는 공용 모듈이므로 총량 계산에서 제외 |

- 모바일 측 호출 어댑터는 `src/lib/*-remote.ts`와 `src/features/chat-results/edge-runtime.ts`로 고정합니다. feature나 screen이 `supabase.functions.invoke`를 직접 부르지 않습니다.

## 네비게이션 기본 규칙

- `/` → `/chat` redirect
- `/home` → `/chat` (레거시 별칭)
- `/chat`이 메인 진입점
- `/profile` 아래 `edit`, `saju-summary`, `relationships`, `notifications`
- `/friends/new/*`는 `app/friends/new/` 디렉터리에서 6단계 관리 (basic → persona → avatar → review → story → creating)
- `/result/[resultKind]`는 fortune-results registry가 resolver 역할

## 관련 문서

- [03-ui-design-system.md](03-ui-design-system.md)
- [05-fortune-system.md](05-fortune-system.md)
- [18-chat-first-architecture.md](18-chat-first-architecture.md)
- [24-page-layout-reference.md](24-page-layout-reference.md)
- [25-fortune-result-schemas.md](25-fortune-result-schemas.md)
- [26-widget-component-catalog.md](26-widget-component-catalog.md)
