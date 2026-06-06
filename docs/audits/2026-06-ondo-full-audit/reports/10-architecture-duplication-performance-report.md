# Architecture / Duplication / Performance Reviewer QA Report

- 감사 대상: 온도 앱 / Fortune repo (`/Users/injoo/Desktop/Dev/fortune`)
- 체크리스트: `docs/audits/2026-06-ondo-full-audit/checklists/10-architecture-duplication-performance.md`
- 작성 시각: 2026-06-05 17:09:55 KST
- 작업 범위: 정적 코드/문서/설정/UX 경로 조사, evidence 수집, 수정 방향/검증 방법 제안
- 코드 수정: 없음. 단, 사용자 요청 결과물인 이 보고서 파일만 작성함.

## Verdict

- **조건부 GO / 유지보수 NO-GO**
- 앱 즉시 사용 불가나 명백한 P0 보안/결제 손실은 이번 정적 감사에서 확인되지 않았다.
- 다만 **전역 AppState + 결제/IAP 결합**, **채팅 메시지 비가상화 렌더**, **앱 부트스트랩 전 캐릭터 전체 대화 캐시 로드**, **결제 ProductId/토큰 지급 정책의 수동 중복**은 핵심 기능/매출/성능 회귀로 이어질 수 있어 P1로 분류한다.
- 구조적 핵심 리스크: `chat-screen.tsx`, `chat-surface.tsx`, `character-chat` Edge Function, `mobile-app-state-provider.tsx`가 각각 거대한 God object가 되어 UI/state/network/persistence/billing/LLM side-effect가 섞여 있다.

## Scope Freeze / Repository State

```text
## master...origin/master
 M CLAUDE.md
 M apps/mobile-rn/package.json
 M package.json
 M pnpm-lock.yaml
?? .githooks/
?? apps/mobile-rn/scripts/
?? docs/audits/
?? docs/development/local-native-ios-testing.md
?? scripts/verify-rn-native-patch.sh
```

- 감사 시작 시점부터 워킹트리는 dirty 상태였다.
- 이 감사에서 앱 코드 수정은 하지 않았다. 보고서 파일 작성은 사용자 요청 범위다.
- `docs/audits/` 전체가 미추적 상태이므로, 이 보고서도 동일 미추적 audit artifact 범위에 포함될 가능성이 높다.

## Executed Checks / Logs

```text
$ pnpm --filter @fortune/product-contracts test -- --run
Test Files  5 passed (5)
Tests       21 passed (21)
```

```text
대형 파일 라인 수:
apps/mobile-rn/src/screens/chat-screen.tsx: 4865 lines
apps/mobile-rn/src/features/chat-surface/chat-surface.tsx: 3660 lines
supabase/functions/character-chat/index.ts: 3896 lines
apps/mobile-rn/src/providers/mobile-app-state-provider.tsx: 1118 lines
apps/mobile-rn/src/lib/story-chat-runtime.ts: 1468 lines
apps/mobile-rn/src/lib/push-notifications.ts: 1000 lines
```

```text
Route duplicate scan:
DUP /chat
  apps/mobile-rn/app/chat.tsx
  apps/mobile-rn/app/(tabs)/chat.tsx

참고: 단순 스캐너는 _layout/+not-found를 route처럼 잡아 `/`, `/profile`, `/widgets`도 출력했으나, 실제 의미 있는 충돌 후보는 `/chat`이다.
```

```text
로컬 bundle/build surface 크기:
3.6G  apps/mobile-rn/ios/build
10M   apps/mobile-rn/.expo
15M   apps/mobile-rn/assets

assets/screenshots 후보:
apps/mobile-rn/assets/screenshots/16promax-auth-options.png
apps/mobile-rn/assets/screenshots/16promax-character-chat.png
apps/mobile-rn/assets/screenshots/16promax-chat-home.png
```

---

## P0

- **발견 없음**

이번 정적 감사 범위에서 앱 사용 불가, 즉시 결제/토큰 손실, 명백한 개인정보 노출, App Store 즉시 리젝에 해당하는 P0는 확인하지 못했다. 단, 아래 P1 결제 정책 중복은 drift가 발생하면 P0로 상승할 수 있다.

---

## P1

### P1-1. 전역 `MobileAppStateProvider`가 AppState와 billing/IAP/profile persistence/remote sync를 함께 소유함

**Checklist**: Architecture, Performance, Source of Truth  
**화면/UX 경로**: 프리미엄/토큰 충전, 복원, 프로필 저장, 채팅 설정, 앱 부트스트랩 전역 상태

#### Evidence

- `apps/mobile-rn/src/providers/mobile-app-state-provider.tsx:1-63`
  - React Context, `expo-iap`, `@fortune/product-contracts`, remote premium, storage, remote profile sync가 한 파일에 import됨.
- `apps/mobile-rn/src/providers/mobile-app-state-provider.tsx:643-687`
  - Provider 내부에서 StoreKit 연결 및 상품 fetch를 수행한다.
- `apps/mobile-rn/src/providers/mobile-app-state-provider.tsx:1068-1112` 확인 결과, 단일 Context value가 전체 `state`, store 상태, 구매 함수, profile 저장 함수 등을 함께 노출한다.
- 파일 크기: `apps/mobile-rn/src/providers/mobile-app-state-provider.tsx: 1118 lines`.

#### Impact

- 결제 상태 변경, 프로필 저장, 설정 저장 같은 작은 변경도 broad context consumer 전체에 전파될 수 있다.
- 결제/IAP는 매출과 사용자 신뢰에 직결되므로, AppState refactor나 profile persistence 변경이 결제 플로우를 깨뜨릴 blast radius가 크다.
- selector가 없는 전역 Context는 채팅/리스트 같은 고비용 화면 리렌더를 유발할 수 있다.

#### Suspected Root Cause

- 앱 초기 MVP 단계의 편의적 전역 Provider가 결제, profile sync, storage, onboarding, settings까지 계속 흡수하면서 책임 경계가 사라졌다.

#### Recommended Fix

1. `BillingProvider` 또는 `useBillingStore`를 분리해 IAP listener/product fetch/purchase/restore만 담당하게 한다.
2. `ProfileStateProvider`, `SettingsProvider`, `PremiumEntitlementProvider`를 분리하거나 `useMobileAppStateSelector(selector)`를 도입한다.
3. `MobileAppStateProvider`는 composition/root orchestration만 유지한다.
4. 결제 side-effect는 product-contracts 기반 policy service를 통해서만 접근하도록 한다.

#### Validation

- `npm run typecheck` 또는 repo 표준 RN typecheck.
- iOS sandbox purchase/restore 회귀 테스트.
- React DevTools Profiler로 `storeStatus`, `isPurchasePending`, `profile` 변경 시 `ChatSurface`/프리미엄 화면의 불필요한 리렌더 감소 확인.
- 구매 성공/실패/복원/취소/네트워크 실패별 smoke test.

---

### P1-2. 채팅 메시지 렌더가 비가상화 + 매 렌더 O(n log n)/O(n) 계산

**Checklist**: Performance, UI Duplication  
**화면/UX 경로**: `/chat` → 캐릭터 대화방 → 메시지 많은 스레드, TTS/typing/새 메시지 수신

#### Evidence

- `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx:73-83`
  - `sortMessagesByTimestamp()`가 `map → sort → map`을 수행한다.
- `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx:3304-3315`
  - `visibleMessages`, `heroReplyMessages`, `renderItems`, `hasEmbeddedResult`가 컴포넌트 렌더마다 재계산된다.
- `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx:3409-3432`
  - `renderItems.map(...)`으로 전체 메시지를 `<View>` 안에 직접 렌더한다. `FlatList`/`FlashList`/windowing이 없다.
- 파일 크기: `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx: 3660 lines`.

#### Impact

- 메시지가 100/500/1000개로 늘면 입력 1글자, TTS 상태 변화, typing 상태 변화, 새 메시지 수신 때마다 전체 메시지 배열 정렬/빌드/렌더 비용이 증가한다.
- 장기 사용자일수록 채팅방 진입/스크롤/입력 지연으로 핵심 UX 신뢰가 저하될 수 있다.

#### Suspected Root Cause

- 채팅 메시지 렌더링이 초기에 단순 map 기반으로 구현된 뒤, time divider/hero overlay/TTS/embedded result가 같은 render path에 누적되었다.

#### Recommended Fix

1. `visibleMessages`, `heroReplyMessages`, `renderItems`, `hasEmbeddedResult`를 `useMemo`로 묶는다.
2. 메시지 리스트를 `FlatList` 또는 `FlashList`로 전환한다.
3. `ChatThreadMessage`를 `React.memo`로 감싸고, TTS props는 `isTtsActive`, `ttsErrorForThisMessage`처럼 최소 primitive로 내린다.
4. time divider build도 pure selector로 분리해 입력/typing 변경과 독립시킨다.

#### Validation

- React DevTools Profiler/Flipper로 메시지 100/500/1000개 synthetic thread에서 commit time 측정.
- 입력 1글자, TTS 시작/정지, 새 메시지 append, hero overlay replay 각각의 `ChatThreadMessage` render count 비교.
- iOS Simulator에서 긴 대화방 스크롤 FPS/JS frame time 측정.

---

### P1-3. 앱 bootstrap이 모든 캐릭터 대화 캐시 로드를 `ready` 전에 기다림

**Checklist**: Performance, SQLite/SecureStore/AsyncStorage bottleneck, 초기 로딩 병목  
**화면/UX 경로**: 앱 cold start → splash/bootstrap → 초기 `/chat` 진입

#### Evidence

- `apps/mobile-rn/src/providers/app-bootstrap-provider.tsx:240-255`
  - `chatCharacters.map((c) => c.id)` 전체 캐릭터 ID에 대해 `loadCachedCharacterMessagesBatch(characterIds)`를 `Promise.all`에 포함한다.
- `apps/mobile-rn/src/providers/app-bootstrap-provider.tsx:276-292`
  - 이후 `Linking.getInitialURL()`과 Supabase `getSession()`까지 처리한다.
- `apps/mobile-rn/src/providers/app-bootstrap-provider.tsx:349-352`
  - `finally`에서야 `setStatus('ready')`가 호출된다.

#### Impact

- 대화량이 늘거나 SQLite/SecureStore migration이 느려지면 첫 화면 ready 시간이 길어진다.
- 모든 캐릭터의 전체 캐시를 로드하는 방식은 사용자 눈에 필요한 “현재/최근 캐릭터 preview”보다 훨씬 무거울 가능성이 높다.

#### Suspected Root Cause

- 첫 화면에서 채팅 리스트 preview와 캐릭터별 메시지 접근을 즉시 보장하려고 전체 캐릭터 hydration을 bootstrap 필수 경로에 넣었다.

#### Recommended Fix

1. bootstrap 필수 데이터와 비필수 conversation hydration을 분리한다.
2. 최근/선택 캐릭터, unread/preview summary만 우선 로드한다.
3. 나머지 캐릭터 메시지는 idle/background hydration으로 이동한다.
4. chat list preview는 lightweight summary 테이블/스토어를 별도 source로 만든다.

#### Validation

- `app_open → bootstrap ready` 시간 계측 추가.
- 캐릭터 수 × 메시지 수 0/100/500개 synthetic DB에서 TTI 비교.
- 초기 진입 직후 채팅 목록 preview/last seen 누락 여부 regression test.

---

### P1-4. 진행 카드 self-polling이 카드마다 3초 주기 × 2개 테이블 조회

**Checklist**: Performance, polling/retry 과다  
**화면/UX 경로**: `/chat` → 운세 생성/포스터 생성 등 progress card가 표시되는 경로

#### Evidence

- `apps/mobile-rn/src/features/chat-surface/progress-message-card.tsx:32-40`
  - progress card가 mount된 동안 `useSelfReconcile(...)`로 직접 polling한다.
- `apps/mobile-rn/src/features/chat-surface/progress-message-card.tsx:184-217`
  - `long_running_jobs`, `scheduled_poster_jobs` 두 테이블을 순차 조회한다.
- `apps/mobile-rn/src/features/chat-surface/progress-message-card.tsx:236-238`
  - 즉시 1회 실행 후 `setInterval(..., 3000)`을 등록한다.

#### Impact

- progress card가 여러 개 있으면 네트워크/DB 요청이 카드 수에 선형 증가한다.
- 약한 네트워크, background 전환, 오래 걸리는 작업에서 배터리/데이터/Supabase quota 부담이 커질 수 있다.

#### Suspected Root Cause

- Realtime/provider-level tracked jobs가 누락될 때 무한 stuck되는 문제를 해결하기 위해 component-local fallback polling을 추가했으나, job별 polling manager로 중앙화되지 않았다.

#### Recommended Fix

1. 화면/캐릭터 단위 polling manager를 만들고 active job ids를 batch 조회한다.
2. Supabase Realtime을 1차, centralized polling을 fallback으로 둔다.
3. AppState/background/visibility 기반으로 polling 중지 또는 backoff를 적용한다.
4. 완료/실패 상태에 대한 idempotent reconcile contract를 문서화한다.

#### Validation

- progress card 1/3/5개 동시 표시 후 1분간 Supabase 요청 수 측정.
- foreground/background 전환 시 interval 해제 여부 확인.
- Realtime 누락, network 실패, done/failed row 각각에서 카드 제거 + 결과 hydrate가 동작하는지 테스트.

---

### P1-5. 결제 ProductId / 지급 토큰 수량이 `product-contracts`와 Edge Function에 수동 중복됨

**Checklist**: Source of Truth, Mapping Duplication, billing policies  
**화면/UX 경로**: 프리미엄/토큰 충전 → App Store purchase → `payment-verify-purchase` → 토큰 지급/복원

#### Evidence

- `packages/product-contracts/src/products.ts:1-22`
  - `ProductId` union 정의.
- `packages/product-contracts/src/products.ts:37-60` 등
  - `productCatalog`에 `points`, 가격, 구독 여부가 정의됨.
- `supabase/functions/payment-verify-purchase/index.ts:453-475`
  - `PRODUCT_TOKENS`가 하드코딩되어 있다.
- `supabase/functions/payment-verify-purchase/index.ts:477-503`
  - `ALLOWED_PRODUCT_IDS`도 하드코딩되어 있고, 주석에 `packages/product-contracts/src/products.ts 의 allProductIds 와 동기화 필수`라고 명시한다.
- 검증 로그: `pnpm --filter @fortune/product-contracts test -- --run`은 21 tests passed. 하지만 이는 fortune pricing consistency를 검증하며, Edge `PRODUCT_TOKENS`/`ALLOWED_PRODUCT_IDS` generated sync guard는 확인되지 않았다.

#### Impact

- product-contracts에는 상품을 추가했지만 Edge whitelist/토큰 지급 맵을 누락하면 결제 검증이 차단되거나 잘못된 토큰이 지급될 수 있다.
- 결제/복원 장애는 매출/환불/CS 리스크로 이어진다.

#### Suspected Root Cause

- `fortune-pricing`은 generated sync 패턴이 생겼지만, App Store product catalog와 Edge purchase verification policy는 아직 동일한 generated SoT 구조로 승격되지 않았다.

#### Recommended Fix

1. `packages/product-contracts/src/products.ts`를 결제 ProductId/points SoT로 확정한다.
2. Edge용 generated 파일 예: `supabase/functions/_shared/products-generated.ts`를 생성한다.
3. `payment-verify-purchase`는 generated의 `allProductIds`, `productCatalog`, `points`를 참조한다.
4. 수동 `PRODUCT_TOKENS`, `ALLOWED_PRODUCT_IDS`를 제거하거나 generated에서 파생한다.

#### Validation

- product-contracts test 추가:
  - `allProductIds`와 `productCatalog` keys 일치.
  - 모든 consumable/subscription의 `points`가 Edge generated와 일치.
  - non-consumable entitlement policy가 명시됨.
- `deno check supabase/functions/payment-verify-purchase/index.ts`.
- starter/basic/popular/heavy/lite/pro/max/monthly/lifetime purchase verification fixture 테스트.

---

## P2

### P2-1. `chat-screen.tsx`가 4,865라인 God Screen으로 UI/state/network/persistence/billing을 과도하게 결합

**Checklist**: Architecture, 거대한 screen/component, hook/service 책임 과도

#### Evidence

- 파일 크기: `apps/mobile-rn/src/screens/chat-screen.tsx: 4865 lines`.
- `apps/mobile-rn/src/screens/chat-screen.tsx:1-164`
  - UI 컴포넌트, survey registry, Edge runtime, product contracts, SecureStore, Supabase, chat provider, message store, push, premium token consume, social auth, haptics, voice input, rewarded ads 등 다수 책임 import.
- `apps/mobile-rn/src/screens/chat-screen.tsx:345-480`
  - active fortune/provider/auth/drafts/survey/image/audio/persona/selected character/tab 등 다수 UI/domain state를 한 컴포넌트에서 관리.
- `apps/mobile-rn/src/screens/chat-screen.tsx:532-568`, `575-606`
  - MessageStore snapshot을 local `messagesByCharacterId` state로 mirror하고 lastSeen 처리까지 담당한다.

#### Impact

- 작은 상태 변경이 큰 screen 전체를 다시 평가한다.
- MessageStore와 local mirror가 분리되어 push/list/room canonical store mismatch 회귀 가능성이 커진다.

#### Recommended Fix

- `useChatScreenController`, `useSurveyRuntime`, `useFortuneGeneration`, `useChatAttachments`, `useChatNavigation` 등으로 관심사를 분리한다.
- MessageStore를 단일 source로 점진 전환하고 local mirror를 줄인다.

#### Validation

- 캐릭터 전환, push 수신, pending reply resume, survey submit, token 부족/paywall, audio/image send smoke test.
- 분리 전후 render count 및 e2e snapshot 비교.

---

### P2-2. `chat-surface.tsx`가 3,660라인 God Surface이며 cross-feature UI를 직접 import

**Checklist**: Architecture, UI Duplication, Performance

#### Evidence

- 파일 크기: `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx: 3660 lines`.
- `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx:45-55`
  - `message-report-sheet`, `chat-results`, `story-chat-animations`, `fortune-cookie`, `chat-survey`, `haneul` 등 여러 feature를 직접 import.
- `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx:57-103`
  - canonical message sorting logic이 UI surface 파일에 위치.
- `apps/mobile-rn/src/features/chat-surface/chat-surface.tsx:3304-3432`
  - message selection, hero overlay selection, time divider build, message rendering이 한 렌더 경로에 모여 있다.

#### Impact

- feature 간 경계가 흐려지고, fortune result / haneul / story reveal 변경이 chat surface 전체 회귀로 번질 수 있다.

#### Recommended Fix

- `MessageList`, `Composer`, `AttachmentPicker`, `HeroOverlay`, `SurveyFooter`, `ReportSheet`로 분리한다.
- result/fortune-cookie/haneul 렌더는 slot/renderer registry로 분리한다.
- canonical visible message selector를 pure utility로 이동한다.

#### Validation

- Chat surface visual regression.
- React Profiler로 message append 시 리렌더 범위 확인.
- chat result/fortune cookie/saju preview/story reveal 각각 smoke test.

---

### P2-3. Circular dependency 3건 확인

**Checklist**: Architecture, circular dependency, import direction

#### Evidence

- `apps/mobile-rn/src/features/fortune-results/types.ts:3`
  - `import type { EmbeddedResultPayload } from '../chat-results/types';`
- `apps/mobile-rn/src/features/chat-results/types.ts:4`
  - `import type { MetricTileData, ResultKind } from '../fortune-results/types';`
- `apps/mobile-rn/src/hooks/use-saju-interpretation.ts:19`
  - `import { generateFallbackInterpretation } from '../lib/saju-interpretation-fallback';`
- `apps/mobile-rn/src/lib/saju-interpretation-fallback.ts:15`
  - `import type { SajuInterpretationData } from '../hooks/use-saju-interpretation';`
- `apps/mobile-rn/src/lib/chat-provider.ts:12`
  - `import { OnDeviceChatProvider } from './on-device-chat-provider';`
- `apps/mobile-rn/src/lib/on-device-chat-provider.ts:11`
  - `import { type ChatProviderOptions, type IChatProvider } from './chat-provider';`

#### Impact

- Type-only cycle은 당장 장애 가능성이 낮지만, runtime import cycle은 HMR/테스트/초기화 순서에 따라 undefined export나 subtle runtime bug를 만들 수 있다.

#### Recommended Fix

- 공통 type/interface를 별도 파일로 추출한다.
  - 예: `features/result-contracts/types.ts`, `lib/chat-provider-types.ts`, `lib/saju-interpretation-types.ts`.
- hook 파일은 hook만 export하고 domain DTO export를 중지한다.
- provider interface와 구현체를 분리한다.

#### Validation

- `madge --circular apps/mobile-rn/src` 또는 dependency-cruiser CI guard 도입.
- `npm run typecheck`.
- app cold start / on-device provider fallback / saju fallback smoke test.

---

### P2-4. `character-chat` Edge Function이 3,896라인으로 LLM, memory, moderation, push, queue, DB persistence를 모두 처리

**Checklist**: Architecture, Edge Function handler, Mapping Duplication

#### Evidence

- 파일 크기: `supabase/functions/character-chat/index.ts: 3896 lines`.
- `supabase/functions/character-chat/index.ts:24-75`
  - LLMFactory, UsageLogger, reply delay, prompts, moderation, tone guard, preferences, Supabase client, push, memory, pilot registry, mood analyzer, persona 등이 한 파일에 결합.
- `supabase/functions/character-chat/index.ts:106-160`
  - request shape에 image, push, model preference, profile, affinity, romance state, proactive id, pending job id 등 다수 도메인 concern 포함.
- `supabase/functions/character-chat/index.ts:2626-2726`, `2957-3056`, `3701-3752`
  - proactive claim/push, pending job, scheduled reply persistence/push가 같은 handler에 존재.

#### Impact

- 핵심 서버 채팅 경로의 blast radius가 크다.
- proactive/scheduled/immediate reply, push, usage logging, token/billing 연동 변경이 서로 영향을 줄 수 있다.

#### Recommended Fix

- handler는 request validation/auth/orchestration만 유지한다.
- `chat_generation_service`, `affinity_service`, `proactive_reveal_service`, `pending_reply_job_service`, `usage_logging_service`, `scheduled_reply_service`, `push_service`로 분리한다.
- usage logging은 wrapper/middleware로 중앙화한다.

#### Validation

- Deno typecheck/test.
- Edge Function local invoke tests.
- pending reply / proactive reveal / scheduled reply / push / usage log integration test.

---

### P2-5. LLM 모델명 SoT가 있음에도 일부 Edge Function이 모델명을 직접 하드코딩함

**Checklist**: Source of Truth, model names 중복

#### Evidence

- 중앙 SoT 후보:
  - `supabase/functions/_shared/llm/models.ts:12-48` — `GEMINI_MODEL_CATALOG`, default model constants.
  - `supabase/functions/_shared/llm/config.ts:18` — `FORTUNE_SPECIFIC_MODELS`.
- 하드코딩 사용:
  - `supabase/functions/generate-character-proactive-image/index.ts:13` — `LLMFactory.create("gemini", "gemini-2.5-flash-image")`.
  - `supabase/functions/generate-character-proactive-image/index.ts:385` — meta에 `"gemini-2.5-flash-image"` 기록.
  - `supabase/functions/fortune-recommend/index.ts:254`, `271` — `gemini-2.0-flash-lite` 하드코딩.
  - `supabase/functions/fortune-past-life/index.ts:2995` — `gemini-2.0-flash` 하드코딩.

#### Impact

- 모델 교체/가격 변경/preview→GA 전환 시 일부 function이 중앙 설정을 따르지 않는다.
- monitoring meta와 실제 호출 모델이 불일치할 수 있어 비용/품질 분석이 왜곡된다.

#### Recommended Fix

- image/text/chat 모델 모두 `models.ts` export 또는 `LLM_GLOBAL_CONFIG`/feature config를 통해 참조한다.
- logging meta는 실제 factory 결과의 model 값을 기록한다.
- Edge function 본문에서 모델 literal 사용을 allowlist 기반 lint로 제한한다.

#### Validation

- repo-wide regex guard: `gemini-`, `gpt-`, `claude-` literal 사용 위치 allowlist.
- env override 변경 시 proactive image/recommend/past-life function이 설정 모델을 사용하는지 unit test.

---

### P2-6. Result type 계층이 `ResultKind`, mapping, registry, hero map으로 분산됨

**Checklist**: Mapping Duplication, Source of Truth, mobile catalog/result renderer/docs

#### Evidence

- `apps/mobile-rn/src/features/fortune-results/types.ts:9-53`
  - `resultKinds` 수동 배열.
- `apps/mobile-rn/src/features/fortune-results/types.ts:103-105`
  - `FortuneTypeToResultKind = Partial<Record<FortuneTypeId, ResultKind>>`로 누락 허용.
- `apps/mobile-rn/src/features/fortune-results/mapping.ts`
  - fortune type → result kind/metadata 수동 매핑.
- `apps/mobile-rn/src/features/fortune-results/registry.tsx:50-94`
  - `Record<ResultKind, ComponentType<...>>` renderer registry.
- `apps/mobile-rn/src/features/chat-results/embedded-result-card.tsx:36-39`
  - hero result kind map이 별도 partial map.

#### Impact

- 새 fortune type 추가 시 catalog에는 보이지만 result route/metadata/hero/renderer가 누락될 수 있다.
- `Partial` 매핑은 누락을 컴파일에서 막지 못한다.

#### Recommended Fix

- `@fortune/product-contracts` fortune catalog entry에 `resultKind` 또는 `rendererKind`를 포함해 SoT화한다.
- mobile mapping/registry는 catalog-derived map으로 생성 또는 검증한다.
- 의도적으로 result가 없는 type은 `resultKind: null`처럼 명시한다.

#### Validation

- catalog의 launchable fortune type이 모두 `resolveResultKindFromFortuneType`에서 null이 아닌지 test.
- 모든 `resultKind`가 renderer registry와 metadata map에 존재하는지 test.

---

### P2-7. `/chat` route가 alias와 tabs screen으로 중복 정의됨

**Checklist**: Source of Truth, route names 중복

#### Evidence

- `apps/mobile-rn/app/chat.tsx:1-14`
  - `ChatAliasRoute`가 `Redirect`로 `pathname: '/(tabs)/chat'` 이동.
- `apps/mobile-rn/app/(tabs)/chat.tsx:1-5`
  - 실제 `ChatScreen` 렌더.
- duplicate route scan 결과:

```text
DUP /chat
  apps/mobile-rn/app/chat.tsx
  apps/mobile-rn/app/(tabs)/chat.tsx
```

#### Impact

- Expo Router에서 route group `(tabs)`는 URL path에서 제거되므로, route manifest/deep link/static export에서 `/chat` 충돌 가능성이 있다.
- `/chat`는 핵심 진입점이라 deep link/notification/widget entry에서 잘못된 screen 선택 리스크가 있다.

#### Recommended Fix

- canonical route를 하나로 정한다.
- alias가 필요하면 Expo Router 공식 권장 패턴으로 충돌 없는 경로를 사용한다.
- deep-link normalization은 product-contracts/deep-link resolver나 navigation helper에서 처리한다.

#### Validation

- Expo route manifest/typed routes 생성 결과에서 `/chat`가 1개만 존재하는지 확인.
- `com.beyond.fortune://chat`, widget deep link, push notification tap smoke test.

---

### P2-8. SecureStore chunking에 큰 `MobileAppState` 전체를 저장하는 broad state persistence

**Checklist**: Performance, SQLite/SecureStore/AsyncStorage 병목, Source of Truth

#### Evidence

- `apps/mobile-rn/src/lib/storage.ts:106-134`
  - 전체 `MobileAppState`를 `JSON.stringify(state)` 후 SecureStore에 저장한다.
- `apps/mobile-rn/src/lib/secure-store-storage.ts:6-11`
  - SecureStore 키당 크기 제한으로 1800 bytes chunk 사용.
- `apps/mobile-rn/src/lib/secure-store-storage.ts:217-272`
  - multi-chunk write 시 chunk별 `SecureStore.setItemAsync` 반복 + active pointer swap.
- `apps/mobile-rn/src/providers/mobile-app-state-provider.tsx:444-450`
  - persist 시 `getMobileAppState → recipe → saveMobileAppState → setState` 흐름.

#### Impact

- profile/settings/premium/chat 관련 작은 변경도 전체 앱 상태 read/write를 유발한다.
- SecureStore는 민감 정보 저장소라 큰 일반 상태의 빈번한 저장에는 latency와 chunk cleanup 비용이 크다.

#### Recommended Fix

- 민감정보와 비민감 UI 상태를 분리한다.
- 비민감 설정/캐시는 AsyncStorage/SQLite/MMKV 계열로 이동한다.
- `premium`, `profile`, `settings`, `chat intent` 등을 key 단위로 분리 저장하고 write debounce를 적용한다.

#### Validation

- `saveSettings`, `recordChatIntent`, `saveProfile` 호출별 SecureStore operation 수/소요 시간 계측.
- 1KB/5KB/20KB 상태 크기별 cold read/write benchmark.
- 앱 강제 종료 중 write interrupt 복구 테스트.

---

### P2-9. Bottom sheet/modal 구현 중복 및 접근성/스타일 drift 위험

**Checklist**: UI Duplication — modal, bottom sheet, loading/error state

#### Evidence

- `apps/mobile-rn/src/features/fortune-results/cost-confirmation-sheet.tsx:67-95`
  - `Modal + dim overlay + bottom container` 직접 구현.
- `apps/mobile-rn/src/features/chat-surface/message-report-sheet.tsx:99-120`
  - 동일 bottom sheet 패턴을 별도 구현.
- `apps/mobile-rn/src/features/haneul/all-fortunes-sheet.tsx:426-455`
  - 또 다른 sheet 구현.
- `apps/mobile-rn/src/features/fortune-results/primitives/term-info-sheet.tsx:463-467`
  - term info sheet도 별도 modal.

#### Impact

- overlay alpha, radius, handle, safe area, dismiss gesture, `onRequestClose`, accessibility focus 정책이 화면마다 달라질 수 있다.
- sheet 접근성/keyboard/safe area 버그 수정 시 여러 파일을 수정해야 한다.

#### Recommended Fix

- 공통 `BottomSheetModal` primitive를 만들고 overlay, safe-area, radius, close affordance, handle, `accessibilityViewIsModal`, `onRequestClose`를 통일한다.
- 내부 content만 slot으로 분리한다.

#### Validation

- VoiceOver focus trap, hardware back, overlay tap, safe-area bottom, 작은 화면 스크롤 QA.
- snapshot/visual regression으로 sheet chrome 일관성 확인.

---

### P2-10. Build/watch surface가 workspace 전체로 넓음

**Checklist**: Bundle/Build Surface, generated/design/artifact 폴더 active scan 포함 여부

#### Evidence

- `apps/mobile-rn/metro.config.js:4-11`
  - `workspaceRoot = ../..`, `config.watchFolders`에 workspace root 전체 추가.
- `apps/mobile-rn/tsconfig.json:13-18`
  - `include`가 `**/*.ts`, `**/*.tsx`, `.expo/types/**/*.ts`로 넓다.
- 로컬 audit artifact 상태:
  - `docs/audits/`가 미추적이고 workspace root 하위에 존재한다.
  - `apps/mobile-rn/ios/build`가 로컬 기준 3.6G.

#### Impact

- Metro watcher가 monorepo 전체 변경, docs/audits/artifacts/packages 변경까지 감시할 수 있다.
- local build outputs/docs가 IDE indexing, search, watchman invalidation, agent scan surface를 오염시킬 수 있다.

#### Recommended Fix

- `watchFolders`를 실제 dependency가 있는 package 디렉터리로 축소 검토한다.
- `blockList`로 `docs/`, `artifacts/`, audit folders, native build outputs를 명시 제외한다.
- TS include를 `app`, `src`, `plugins`, `targets`, `expo-env.d.ts` 등으로 구체화한다.

#### Validation

- Metro cold start time, file map size, watchman recrawl 로그 비교.
- `expo start --clear` 후 번들 완료 시간 측정.
- docs/audit 파일 변경 시 Metro invalidation 발생 여부 확인.

---

## P3

### P3-1. CTA/Button 구현 중복

**Evidence**

- Canonical 버튼: `apps/mobile-rn/src/components/primary-button.tsx:15-24`, `64-118`.
- Social auth 별도 pill 버튼: `apps/mobile-rn/src/components/social-auth-pill-button.tsx:29-63`, `78-138`.
- Survey composer send/mic 버튼 직접 구현: `apps/mobile-rn/src/components/survey-composer.tsx:160-206`.
- Cost sheet CTA 직접 구현: `apps/mobile-rn/src/features/fortune-results/cost-confirmation-sheet.tsx:136-173`.

**Impact**

- loading/disabled/pressed/haptic/accessibility/hit area 정책이 분산된다.

**Fix / Validation**

- `ButtonBase` 또는 `PrimaryButton` variants로 통합한다.
- disabled/loading/pressed/accessibility snapshot test를 추가한다.

---

### P3-2. Card/list item 구현 중복

**Evidence**

- 기본 카드 primitive: `apps/mobile-rn/src/components/card.tsx:7-28`.
- CharacterCard 자체 카드 style: `apps/mobile-rn/src/components/character-card.tsx:54-70`, `110-116`.
- RelationshipCard 자체 카드 style: `apps/mobile-rn/src/components/relationship-card.tsx:68-82`.
- ResultCardFrame 별도 카드 chrome: `apps/mobile-rn/src/features/fortune-results/primitives/result-card-frame.tsx:141-150`.

**Impact**

- radius/padding/border/background/pressed state가 feature별로 drift된다.

**Fix / Validation**

- `SelectableCard` 또는 `CardPressable` primitive 도입.
- 주요 카드 visual regression으로 token 변경 시 일관성 확인.

---

### P3-3. Premium screen 추천 top-up ProductId subset과 label/purpose가 화면에 하드코딩됨

**Evidence**

- `apps/mobile-rn/src/screens/premium-screen.tsx:79-85`
  - `strongFitTopUpProductIds`, `strongFitRecommendedProductId` 직접 정의.
- `apps/mobile-rn/src/screens/premium-screen.tsx:87-103`
  - productId별 label/purpose 조건문.
- 같은 파일 `apps/mobile-rn/src/screens/premium-screen.tsx:5-10`, `171-178`은 `productCatalog`, storefront IDs를 이미 사용한다.

**Impact**

- product-contracts에 신규 token package를 추가해도 추천 UI merchandising은 자동 반영되지 않는다.

**Fix / Validation**

- `products.ts` 또는 product-contracts 내 `premiumMerchandisingConfig`로 `recommended`, `shortLabel`, `purpose`를 이동한다.
- strong-fit IDs가 `storefrontConsumableProductIds` subset인지 test한다.

---

### P3-4. Dev reset storage key 하드코딩

**Evidence**

- 중앙화된 키:
  - `apps/mobile-rn/src/lib/storage.ts:8`, `16` — onboarding/app state key import.
  - `apps/mobile-rn/src/lib/welcome-state.ts:20-21` — welcome key.
- 하드코딩 중복:
  - `apps/mobile-rn/src/lib/dev-factory-reset.ts:12` — `fortune.disclaimer-accepted.v1`.
  - `apps/mobile-rn/src/lib/dev-factory-reset.ts:64-65` — `unified_onboarding_progress_v1`.
  - `apps/mobile-rn/src/lib/dev-factory-reset.ts:74-79` — mobile app state key 수동 생성.
  - `apps/mobile-rn/src/lib/dev-factory-reset.ts:82` — `fortune.last-auth-user-id.v1`.

**Impact**

- QA 초기화가 실제 storage key 변경을 따라가지 못하면 “클린 설치” 재현이 실패할 수 있다.

**Fix / Validation**

- storage key resolver/export를 확대하고 dev reset은 helper만 사용한다.
- factory reset e2e: 로그인/온보딩/웰컴/앱 설정 저장 후 reset → 재시작 시 신규 설치 상태 확인.

---

### P3-5. 로컬 native/build artifact와 screenshots가 repo scan surface를 키움

**Evidence**

- 로컬 크기:
  - `apps/mobile-rn/ios/build`: 3.6G
  - `apps/mobile-rn/.expo`: 10M
  - `apps/mobile-rn/assets`: 15M
- screenshot files:
  - `apps/mobile-rn/assets/screenshots/16promax-auth-options.png`
  - `apps/mobile-rn/assets/screenshots/16promax-character-chat.png`
  - `apps/mobile-rn/assets/screenshots/16promax-chat-home.png`
- ignore 확인:
  - `apps/mobile-rn/.gitignore:39-41`는 generated native `/ios`, `/android`를 ignore한다.
  - root `.gitignore`는 `apps/mobile-rn/screenshots/`를 ignore하지만 `apps/mobile-rn/assets/screenshots/`와는 경로가 다르다.

**Impact**

- Git에는 대체로 제외되더라도 local search/IDE indexing/agent scan/backup 표면이 커진다.
- `assets/screenshots`가 production bundle에 실수 포함될 위험이 있다.

**Fix / Validation**

- QA/App Store screenshots를 runtime `assets/` 밖의 `docs/evidence` 또는 `artifacts`로 분리한다.
- production asset manifest 또는 `expo export` 결과에서 screenshots 포함 여부 확인.
- `git check-ignore -v`로 native/build artifact ignore 확인.

---

## Evidence Matrix by Checklist

| Checklist | Evidence | Severity |
|---|---|---|
| UI/state/network/domain/persistence/billing 책임 혼재 | `mobile-app-state-provider.tsx`, `chat-screen.tsx`, `character-chat/index.ts` | P1/P2 |
| 거대한 screen/component | chat-screen 4865 lines, chat-surface 3660 lines, Edge handler 3896 lines | P2 |
| circular dependency | `fortune-results ↔ chat-results`, `saju hook ↔ fallback`, `chat-provider ↔ on-device` | P2 |
| route names 중복 | `/chat` alias + tabs route | P2 |
| product ids/token grants 중복 | `products.ts` vs `payment-verify-purchase` hardcoded maps | P1 |
| model names 중복 | Edge functions hardcoded `gemini-*` literals despite `_shared/llm` SoT | P2 |
| result renderer mapping 중복 | `resultKinds`, `mapping.ts`, `registry.tsx`, hero map | P2 |
| button/card/modal 중복 | primary/social/survey/cost CTA, multiple bottom sheets/cards | P2/P3 |
| chat list/message list re-render | non-windowed `renderItems.map`, render-time sort/build | P1 |
| initial loading bottleneck | all-character conversation cache before `ready` | P1 |
| polling/retry 과다 | progress card per-card 3s polling × 2 tables | P1 |
| SecureStore bottleneck | broad `MobileAppState` JSON chunking | P2 |
| generated/artifact build surface | workspace watchFolders, local `ios/build`, `assets/screenshots` | P2/P3 |

## Recommended Fix Order

1. **P1 결제 ProductId/토큰 지급 SoT 정리**
   - `products.ts` → Edge generated sync 구조로 전환.
   - 결제 검증 fixture와 Deno check 추가.
2. **P1 채팅 렌더 성능 개선**
   - `useMemo` + `FlatList`/`FlashList` + memoized message row.
   - 긴 대화 synthetic profiler 기준 수립.
3. **P1 앱 bootstrap lazy hydration**
   - 현재/최근 캐릭터 summary만 ready 전 로드, 전체 메시지는 idle/background.
4. **P1/P2 AppState/Billing Provider 분리**
   - 결제/IAP listener와 profile/settings persistence를 분리해 리렌더/회귀 범위 축소.
5. **P2 circular dependency 제거**
   - shared type/interface 추출 후 CI cycle guard 도입.
6. **P2 chat-screen/chat-surface/character-chat decomposition**
   - UI/controller/service/Edge side-effect boundary를 단계적으로 분리.
7. **P2/P3 UI primitive 통합 및 build surface 축소**
   - BottomSheet/Button/Card primitive 도입, Metro/TS watch surface 제한.

## Open Questions

- 팀 기준의 large file threshold를 정할지? 예: screen 500~800 lines, service 700 lines, Edge handler 800~1200 lines.
- `@fortune/product-contracts`가 result renderer kind, product merchandising, Edge generated policy까지 모두 소유하는 방향에 동의하는지?
- `/chat` alias route가 실제로 필요한 legacy deep link 대응인지, 아니면 제거 가능한 임시 alias인지 확인 필요.
- Progress card polling은 Realtime 실패 fallback을 위해 남겨야 할 수 있다. 중앙 polling manager로 전환할 때 허용 가능한 최대 지연/요청량 기준이 필요하다.

## Notes / Non-Goals

- DB row 직접 조회는 수행하지 않았다. 이번 체크리스트는 architecture/duplication/performance 중심이며, DB row evidence가 필요한 결제/채팅 런타임 장애 재현은 별도 QA에서 수행해야 한다.
- iOS Simulator/실기기 실행은 수행하지 않았다. 성능 항목은 정적 구조상 병목 후보이며, fix 전후 Profiler/Simulator/real-device 측정이 필요하다.
- 서버 배포/EAS OTA/코드 수정은 하지 않았다.
