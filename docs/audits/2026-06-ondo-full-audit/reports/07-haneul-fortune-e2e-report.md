# Haneul Fortune E2E QA Reviewer QA Report

## Verdict
- **조건부 GO / 실제 E2E는 NO-GO**
- 정적 SoT와 RN 게이트는 대체로 통과하지만, 54개 운세 전수 흐름 중 **실제 모바일 E2E(실기기/시뮬레이터 + Supabase Edge + 토큰 ledger + renderer + 재열람) 증거가 없다.** 또한 chat-addressable 타입 중 `constellation`, `lotto`가 존재하지 않는 Edge endpoint로 resolve되어 특정 진입 경로에서는 핵심 운세 생성 실패 위험이 있다.

## P0
- 없음.
  - 이번 검토 범위에서 즉시 결제/토큰 손실, 보안/개인정보, App Store 즉시 리젝에 해당하는 확정 증거는 발견하지 못했다.
  - 단, 실제 유저 토큰 DB row 검증은 수행하지 못했으므로 “토큰 손실 없음”을 확정하지 않는다.

## P1
- **[P1-1] `constellation` / `lotto`가 존재하지 않는 Edge Function으로 라우팅될 수 있음**
  - 영향: 해당 fortune type이 추천 chip, 딥링크, 기존 결과 재생성, 내부 호출 등 catalog 외 경로로 실행되면 Edge 호출 단계에서 실패한다. 체크리스트 기준 “선택한 운세 타입 전달”, “생성 흐름”, “결과 표시” 핵심 실패.
  - 증거:
    - `packages/product-contracts/src/fortunes.ts:227-230` — `constellation` endpoint가 `/fortune-constellation`으로 정의됨.
    - `packages/product-contracts/src/fortunes.ts:163-167` — `lotto` endpoint가 `/fortune-lucky-lottery`로 정의되어 있고 동시에 `isLocalOnly: true`로 표시되어 모순 상태.
    - `packages/product-contracts/src/fortunes.ts:333-344` — `resolveFortuneEndpoint()`는 `isLocalOnly`를 보지 않고 endpoint 문자열만 반환함.
    - `apps/mobile-rn/src/features/fortune-results/mapping.ts:26-29`, `:54-56` — `constellation`은 `zodiac-animal`, `lotto`는 `wealth` renderer로 매핑되어 결과 카드 렌더링 가능처럼 보임.
    - 파일 시스템 검증: `/Users/injoo/Desktop/Dev/fortune/supabase/functions/fortune-constellation/index.ts` 없음, `/Users/injoo/Desktop/Dev/fortune/supabase/functions/fortune-lucky-lottery/index.ts` 없음.
    - dry-run matrix: `artifacts/qa/haneul-fortune-e2e/edge-smoke-2026-06-05T08-03-37-745Z.md:29`, `:57`에 각각 `/fortune-constellation`, `/fortune-lucky-lottery`로 분류됨.
  - 재현 단계:
    1. `fortuneType='constellation'` 또는 `fortuneType='lotto'`로 `resolveFortuneEndpoint(type, answers)` 호출.
    2. 반환 endpoint를 `supabase/functions/<endpoint>/index.ts`와 대조.
    3. endpoint 파일이 없어 배포된 함수가 없는 상태임을 확인.
  - 수정 방향:
    - `constellation`: 실제 신규 Edge Function을 만들지 않을 계획이면 `zodiac`/`zodiac-animal`처럼 기존 endpoint로 alias하거나 catalog/추천/딥링크에서 제거한다.
    - `lotto`: `isLocalOnly: true`라면 `endpoint: null`로 맞추거나, 실제 `/fortune-lucky-lottery` Edge Function을 구현/배포한다.
    - `resolveFortuneEndpoint()`가 `isLocalOnly`를 우선해 `null`을 반환하도록 계약을 명확히 하고 product-contracts 테스트를 추가한다.
  - 검증 방법:
    - `npm run test --workspace @fortune/product-contracts`에 `constellation`, `lotto` endpoint existence/alias 테스트 추가.
    - `scripts/qa/haneul-fortune-edge-smoke.mjs` dry-run에서 missing endpoint 0건 확인.
    - 실제 앱에서 해당 type 진입 → 설문 완료 → 비용 확인 → 결과 embedded card 표시까지 확인.

- **[P1-2] 하늘이 운세 전수 E2E 미검증: 현재 증거는 dry-run/static + RN gates 수준**
  - 영향: 체크리스트의 “실제 유저가 운세를 끝까지 받을 수 있는지”, “토큰/상태 안전성”, “fullscreen/result/재열람/앱 재시작 유지”를 완료 판정할 수 없다.
  - 증거:
    - smoke 결과 `artifacts/qa/haneul-fortune-e2e/edge-smoke-2026-06-05T08-03-37-745Z.md:3-7` — `live: false`, `total: 54`, `DRY_RUN:43`, `SKIP_LOCAL:4`, `SKIP_ASYNC_BY_DEFAULT:7`.
    - 이번 실행 로그 `/tmp/ondo-haneul-dry-run-20260605.log` — `DRY_RUN 43 / SKIP_LOCAL 4 / SKIP_ASYNC_BY_DEFAULT 7`만 산출, 실제 Supabase 호출 없음.
    - 체크리스트 `docs/audits/2026-06-ondo-full-audit/checklists/07-haneul-fortune-e2e.md:8-10` — 문서/코드 불일치 시 실제 동작 우선, 시뮬레이터 성공을 실기기 성공으로 간주하지 않음, 서버 작업 완료를 유저 화면 성공으로 간주하지 않음.
  - 수정 방향:
    - QA 단계 분리: (1) static matrix, (2) live Edge sync-only smoke, (3) async poster queue/worker/push smoke, (4) iOS simulator UI E2E, (5) 실기기 E2E.
    - live smoke에는 실제 테스트 유저 JWT와 유효 UUID, 토큰 잔액, realistic image fixture를 사용한다.
  - 검증 방법:
    - 54개 중 catalog-visible 48개를 실제 화면 경로에서 선택해 survey → cost sheet → confirm/cancel → result → reopen → restart restore까지 기록.
    - 각 type별 DB row: token ledger/reference id, conversation row/message id, async job row를 함께 저장.

## P2
- **[P2-1] 비용 확인 sheet의 “오늘 무료” 모드가 실제 chat screen에서 전달되지 않음**
  - 영향: `CostConfirmationSheet`는 daily 1일 1회 무료 UX를 지원하지만, chat screen에서 `freeForDaily` prop을 넘기지 않아 daily도 항상 `1 포인트 차감`으로 보일 가능성이 높다. “비용 표시가 명확한가 / 무료·유료 구분이 명확한가” 항목에서 혼란.
  - 증거:
    - `apps/mobile-rn/src/features/fortune-results/cost-confirmation-sheet.tsx:40-41`, `:59-64`, `:115-122`, `:171` — `freeForDaily`일 때 “오늘 무료”, “무료로 시작” 표시 가능.
    - `apps/mobile-rn/src/screens/chat-screen.tsx:4853-4862` — sheet 렌더 시 `visible`, `entry`, `currentBalance`, `isUnlimited`, `onConfirm`, `onCancel`, `onTopUpRequest`만 전달하고 `freeForDaily` 누락.
    - `packages/product-contracts/src/fortune-pricing.ts:24-27` — `daily: 1`, `daily-calendar: 1`로 가격 SoT는 1P.
  - 재현 단계:
    1. 오늘 처음 `daily` 운세를 선택한다.
    2. 설문 완료 후 cost sheet를 확인한다.
    3. “오늘 무료” 대신 `1 포인트 차감`으로 표시되는지 확인한다.
  - 수정 방향:
    - daily free 상태 source(`daily_free_fortune` 또는 token policy)를 chat screen에서 계산/조회해 `freeForDaily`에 전달한다.
    - 무료 처리와 실제 token consume skip/ledger가 같은 source를 보도록 product-contracts/Edge 계약을 맞춘다.
  - 검증 방법:
    - 오늘 첫 daily: cost sheet “오늘 무료” + confirm 후 token ledger 차감 없음.
    - 같은 날 두 번째 daily: `1 포인트 차감` + ledger 1P 차감.

- **[P2-2] 일부 catalog 카드의 무료/유료 표시가 유료만 보여주고 무료는 시각 표시가 없음**
  - 영향: 선택 전 목록에서 `costPoints > 0`인 경우에만 `P` pill을 노출하고, 0P/무료인 경우 별도 “무료” badge가 없다. 현재 pricing상 catalog 대부분이 1P 이상이라 즉시 큰 문제는 아니지만, free promotion/무료 정책이 들어오면 사용자가 선택 전 비용 차이를 인지하기 어렵다.
  - 증거:
    - `apps/mobile-rn/src/features/haneul/all-fortunes-sheet.tsx:767-775` — accessibilityLabel에는 무료/포인트 정보가 들어감.
    - `apps/mobile-rn/src/features/haneul/all-fortunes-sheet.tsx:902-919` — 시각 badge는 `entry.costPoints > 0`일 때만 렌더, 0P일 때 null.
  - 수정 방향:
    - `costPoints === 0` 또는 daily free 상태가 있을 때 작은 “무료” badge를 카드 하단에 렌더한다.
  - 검증 방법:
    - VoiceOver label과 시각 badge가 모두 비용 정책과 일치하는지 snapshot/실기기에서 확인.

- **[P2-3] async poster 7종은 queue 등록 이후 billing/placeholder/worker/push 경로가 별도 E2E 필요**
  - 영향: `palm-reading`, `beauty-simulation`, `hair-style-guide`, `face-reading-guide`, `ootd-guide`, `blind-date-guide`, `past-life-guide`는 일반 sync Edge와 달리 `start-poster-job` → token consume → progress card → worker/push → 재진입 result 카드 흐름이다. dry-run에서는 전부 skip되어 실제 장시간 생성/앱 종료/방 나가기 안전성을 확인하지 못했다.
  - 증거:
    - `packages/product-contracts/src/fortunes.ts:87-120` — 7개 타입이 `/generate-poster-guide` endpoint를 사용.
    - `apps/mobile-rn/src/screens/chat-screen.tsx:2042-2044` — async poster type은 `handleAsyncPosterFortune()`로 분기.
    - `apps/mobile-rn/src/screens/chat-screen.tsx:2208-2224` — queue 등록 전 cost confirm 후 `startAsyncPosterJob()` 호출.
    - `apps/mobile-rn/src/screens/chat-screen.tsx:2236-2249` — queue 성공 후 cancel 불가 상태로 전환하고 token consume.
    - `apps/mobile-rn/src/screens/chat-screen.tsx:2279-2291` — progress message만 append, 실제 결과는 worker/push/hydrate 경로 의존.
    - smoke 결과 `artifacts/qa/haneul-fortune-e2e/edge-smoke-2026-06-05T08-03-37-745Z.md:17-23` — 7종 `SKIP_ASYNC_BY_DEFAULT`.
  - 수정 방향:
    - 일반 sync smoke와 분리된 poster E2E harness를 유지: realistic image fixture, `posterType`, queue row, worker completion, push receipt, result image URL load까지 확인.
  - 검증 방법:
    - 각 7종에 대해 `pending_poster_jobs`/long-running job row, token ledger row, progress card, push/foreground alert, 재진입 result image render 스크린샷을 확보.

- **[P2-4] survey 입력과 Edge required field 일치성은 static으로 일부만 확인됨**
  - 영향: 설문 registry는 1-question/1-concept에 가까운 구조지만, Edge required field와 app payload transform이 전수 대조되지 않으면 특정 운세에서 survey 완료 후 400/500이 날 수 있다.
  - 증거:
    - `apps/mobile-rn/src/features/chat-survey/registry.ts:123-151` — compatibility survey는 `partnerName`, `partnerBirth`, `relationship`만 수집.
    - `apps/mobile-rn/src/features/chat-results/edge-runtime.ts:820-829` — profile fields를 payload에 복사.
    - `apps/mobile-rn/src/features/chat-results/edge-runtime.ts:862-893` — tarot slot을 Edge-compatible `selectedCards` 형태로 변환하는 별도 로직 존재.
    - 과거 live smoke artifact 요약: `artifacts/qa/haneul-fortune-e2e/edge-smoke-2026-05-10T19-49-20-614Z.json`에서 fixture mismatch로 `naming`, `love`, `compatibility`, `ex-lover`, `yearly-encounter` 실패가 있었음. 이는 실제 앱 payload 실패로 단정할 수 없지만 required field drift 위험 신호다.
  - 수정 방향:
    - smoke fixture를 survey raw값이 아니라 `buildResultContext()`/edge-runtime transform 이후 payload로 캡처해 Edge에 보내도록 개선.
    - 각 Edge Function의 required field schema를 product-contracts에 끌어올려 테스트로 잠근다.
  - 검증 방법:
    - 48 catalog-visible types 전체에 대해 app UI로 survey 완료 후 실제 request payload를 capture하고 2xx + renderer payload normalize까지 확인.

## P3
- **[P3-1] lint warning 129건으로 QA 신호 대비 잡음이 큼**
  - 영향: 현재 lint는 exit 0이지만 unused/import/deps/array-type warning이 많아 실제 신규 문제 탐지가 어려워진다.
  - 증거: `/tmp/ondo-mobile-lint-20260605.log` — `✖ 129 problems (0 errors, 129 warnings)`.
  - 수정 방향: 하늘이/fortune-results 관련 warning부터 별도 cleanup issue로 분리. 특히 `chat-screen.tsx`의 hook dependency warning은 QA flake 원인이 될 수 있어 우선 정리.
  - 검증 방법: `npm run lint --workspace @fortune/mobile-rn` warning baseline 감소 또는 warning budget 도입.

- **[P3-2] fullscreen result / 긴 결과 읽기 UX는 코드상 renderer만 확인했고 화면 증거가 없음**
  - 영향: registry에 renderer는 등록되어 있으나, fullscreen reading player와 긴 결과 가독성은 실제 스크린샷/동영상 없이는 판정 불가.
  - 증거:
    - `apps/mobile-rn/src/features/fortune-results/registry.tsx:50-94` — 43개 result renderer 등록.
    - 이번 QA에서는 iOS simulator/실기기 화면 캡처 미실행.
  - 수정 방향: 대표 8종(사주/타로/연애/재물/관상/손금/전생/코칭)으로 fullscreen open/close, scroll, section collapse 여부를 visual QA.
  - 검증 방법: 작은 화면(iPhone SE급), 기본 iPhone, 다크모드 screenshots와 accessibility label 점검.

## Evidence
- 체크리스트 원문:
  - `docs/audits/2026-06-ondo-full-audit/checklists/07-haneul-fortune-e2e.md:53-103` — 진입/선택/설문/생성/결과/특수 케이스 기준.
- SoT 코드:
  - `packages/product-contracts/src/fortune-catalog.ts:1-15` — 하늘이 카탈로그 SoT 설명, 54개 중 48개 노출.
  - `packages/product-contracts/src/fortune-catalog.ts:69-139` — catalog-visible 48개 entry.
  - `packages/product-contracts/src/fortune-pricing.ts:1-21`, `:24-157` — 가격 SoT와 가격 tier.
  - `packages/product-contracts/src/fortunes.ts:1-57` — `FortuneTypeId` union.
  - `packages/product-contracts/src/fortunes.ts:333-344` — endpoint resolver.
  - `apps/mobile-rn/src/features/fortune-results/mapping.ts:9-64` — fortune type → result kind mapping 54개.
  - `apps/mobile-rn/src/features/fortune-results/registry.tsx:50-94` — result kind → renderer registry 43개.
  - `apps/mobile-rn/src/features/chat-survey/registry.ts:16-260` 등 — survey definitions.
  - `apps/mobile-rn/src/features/chat-results/edge-runtime.ts:862-893` — tarot app payload transform.
  - `apps/mobile-rn/src/screens/chat-screen.tsx:2047-2063`, `:2069-2128` — sync fortune cost confirm → Edge resolve → token consume → embedded result append.
  - `apps/mobile-rn/src/screens/chat-screen.tsx:2208-2291` — async poster queue/token/progress flow.
  - `apps/mobile-rn/src/screens/chat-screen.tsx:2294-2320`, `:2719-2737` — 과거 결과 재열람/reopen routing.
- 실행 로그:
  - `npx tsx scripts/qa/haneul-fortune-edge-smoke.mjs --timeout-ms=1000` → `/tmp/ondo-haneul-dry-run-20260605.log`, artifact `artifacts/qa/haneul-fortune-e2e/edge-smoke-2026-06-05T08-03-37-745Z.md/json`.
  - `npm run rn:test` → `/tmp/ondo-rn-test-20260605.log`: 5 files / 21 tests passed.
  - `npm run typecheck --workspace @fortune/mobile-rn` → `/tmp/ondo-mobile-typecheck-20260605.log`: exit 0.
  - `npm run lint --workspace @fortune/mobile-rn` → `/tmp/ondo-mobile-lint-20260605.log`: exit 0, 129 warnings.
- 환경/범위 제한:
  - 코드 수정 없음.
  - live Supabase 호출, DB row 검증, iOS simulator/실기기 화면 QA, push receipt 확인은 수행하지 않음.
  - 현재 git tree는 사전 변경분이 존재: `CLAUDE.md`, `apps/mobile-rn/package.json`, `package.json`, `pnpm-lock.yaml`, `.githooks/`, `apps/mobile-rn/scripts/`, `docs/audits/`, `docs/development/local-native-ios-testing.md`, `scripts/verify-rn-native-patch.sh` 등. 이번 작업은 보고서 파일 작성만 수행.

## Recommended Fix Order
1. **Endpoint contract 정리:** `constellation`, `lotto`의 endpoint/localOnly/alias 정책을 결정하고 product-contracts 테스트로 고정한다.
2. **Live sync-only smoke:** 실제 테스트 유저 JWT/토큰으로 async 제외 43개 Edge path를 실행해 2xx, payload normalize, token ledger를 검증한다.
3. **Async poster 7종 분리 QA:** realistic image fixture로 queue 등록 → token charge → worker completion → push/re-entry/result image load를 검증한다.
4. **Daily/free cost UX 검증:** `freeForDaily` prop/state/ledger 일치 여부를 확인하고 첫 daily 무료 정책이 있다면 sheet와 ledger를 맞춘다.
5. **Simulator/실기기 UI 전수:** catalog-visible 48개를 화면에서 selection → survey → cost confirm/cancel → result/reopen/restart restore까지 캡처한다.
6. **Lint warning budget:** 하늘이/fortune-results 영역 warning부터 줄여 QA 신호를 선명하게 만든다.

## Open Questions
- `constellation`은 독립 Edge Function을 만들 계획인가, 아니면 `zodiac-animal`/`daily` alias로 확정할 계획인가?
- `lotto`는 local-only UX로 남길 것인가, 실제 `/fortune-lucky-lottery` Edge/로또 기능과 연결할 것인가?
- daily 1일 1회 무료 정책은 현재 production 정책인가? 그렇다면 free state의 단일 source(DB/Edge/client)는 어디인가?
- 이번 감사에서 실기기 E2E까지 이어갈 테스트 계정/JWT/토큰 충전 상태를 제공할 수 있는가?
