# Plan: Fortune 가격 SoT codegen 통합

> 생성: 2026-05-06
> 트리거: `/gstack` 하늘이 UIUX 테스트 진행 중 발견된 카탈로그 vs Edge 가격 9개 drift + Edge 미정의 3개
> 게이트: CLAUDE.md "큰 작업" (결제 코드) + `/ultrareview` 자동 트리거 (FORTUNE_POINT_COSTS)

## 문제 정의

`packages/product-contracts/src/fortune-catalog.ts` 의 `costPoints` (클라이언트 cost confirm modal 표시용) 와 `supabase/functions/_shared/types.ts` 의 `FORTUNE_POINT_COSTS` (Edge 실제 차감 SoT) 가 **수동 동기화** 의존이고 실제로 drift.

### 현재 drift 13개 카탈로그 중 9개

| FortuneTypeId | 카탈로그 표시 (P) | Edge 실제 차감 (P) | 갭 |
|---|---|---|---|
| daily | 1 | 1 | ✅ |
| tarot | 5 | 5 | ✅ |
| traditional-saju | 12 | 12 | ✅ |
| **health** | **3** | **5** | -2 |
| **biorhythm** | **3** | **5** | -2 |
| **match-insight** | **3** | **5** | -2 |
| **game-enhance** | **3** | **5** | -2 |
| **breathing** | **3** | (키 없음 → fallback 1) | -2 |
| **personality-dna** | **4** | **5** | -1 |
| **mbti** | **3** | **1** | +2 |
| **coaching** | **3** | (키 없음 → fallback 1) | -2 |
| **daily-review** | **3** | (키 없음 → fallback 1) | -2 |
| **past-life** | **10** | **50** | -40 |

### 영향
- 사용자가 본 cost ≠ 실제 차감. health/past-life 등은 더 비싸게 차감 (사용자 클레임 사안). mbti 는 더 저렴하게 차감 (회사 손실).
- past-life: 사용자 본 10P → 실제 50P (5배 차이). 잔액 부족 시 unexpected fail / 환불 대응 필요할 가능성.
- breathing/coaching/daily-review: Edge `FORTUNE_TOKEN_COSTS[fortuneType] ?? 1` 폴백이라 1P 차감. 카탈로그 3P 표시는 거짓.

### 검증 부재
- 코드 주석: `feature-flag-catalog-consistency.test.ts` 에서 검증된다고 적혀있으나 **그 파일 미존재**.
- 현재 테스트(`fortune-catalog.test.ts`)는 양의 정수 여부만 검사. SoT 비교 없음.
- 결과: 9개 drift 가 typecheck/test 통과한 채 production 도달.

## 목표 (검증 가능)

1. `packages/product-contracts` 가 가격 SoT. Edge 가 generated 파일을 import. `costPoints` 가 SoT lookup 으로 자동 채워짐.
2. CI / pre-commit 가 generated 파일 sync 강제. 누가 SoT 만 수정하고 generated 안 푸시하면 fail.
3. 9개 drift 자동 해소 (manual fix 0).
4. Edge 미정의 3개 (`breathing/coaching/daily-review`) 의 가격 결정 + SoT 등록.
5. consistency test 가 catalog `costPoints` ≡ SoT[id] 강제. drift 회귀 봉쇄.

## 비목표
- FORTUNE_CATALOG 의 13개 → 54개 entry 확장 (별도 PR — Step 2).
- soul-consume / payment-verify-purchase 의 차감 로직 변경 (가격 lookup 만 단일화).

## 설계 — B 방식 (codegen)

### 디렉토리
```
packages/product-contracts/src/
  fortune-pricing.ts        ← SoT (FORTUNE_POINT_COSTS, FortunePointCost 타입)
  fortune-catalog.ts        ← lookup: costPoints = FORTUNE_POINT_COSTS[id]
  fortune-pricing.test.ts   ← consistency test
  index.ts                  ← re-export

scripts/
  sync-edge-pricing.ts      ← codegen entry

supabase/functions/_shared/
  fortune-pricing-generated.ts  ← codegen 출력 (commit, CI 검증)
  types.ts                  ← FORTUNE_POINT_COSTS 를 generated 에서 import 하여 re-export
```

### 데이터 흐름
```
[SoT] fortune-pricing.ts
  ├─→ [클라] fortune-catalog.ts (costPoints lookup)
  └─→ [codegen] sync-edge-pricing.ts
        └─→ fortune-pricing-generated.ts (commit)
              └─→ [Edge] _shared/types.ts (re-export FORTUNE_POINT_COSTS)
                    └─→ soul-consume, payment-verify-purchase ...
```

### codegen 동작
- 입력: `packages/product-contracts/src/fortune-pricing.ts`
- 출력: `supabase/functions/_shared/fortune-pricing-generated.ts` (Deno 호환 TS, header 에 `// AUTO-GENERATED — do not edit`)
- 트리거: `pnpm sync:edge-pricing`. precommit hook + CI.
- 검증: `git diff --exit-code supabase/functions/_shared/fortune-pricing-generated.ts` 가 fail 이면 push 차단.

### Edge 미정의 3개 처리
| FortuneTypeId | 현재 카탈로그 | 권장 Edge SoT 추가 | 사유 |
|---|---|---|---|
| breathing | 3P | **3P (Mid 5? Light 1? — 사용자 결정)** | meditation 단일 LLM call. light 가 합리. CEO/eng review 에서 결정. |
| coaching | 3P | **3P 또는 5P (career-coaching 5P 와 동일?)** | chat-insight 와 동일 ResultKind. mid 가 합리. |
| daily-review | 3P | **3P 또는 5P (weekly-review 5P 와 동일?)** | weekly-review 5P 인데 daily 가 더 비싸면 어색. 1P/3P 고려. |

→ `/autoplan` CEO/eng review 에서 가격 정렬 결정.

## 구현 단계

### Step 1.1 — SoT 파일 신규 생성
- `packages/product-contracts/src/fortune-pricing.ts`: Edge 의 `FORTUNE_POINT_COSTS` 80+ 키 그대로 이전. 단 키 타입은 `FortuneTypeId` (or 확장 union — 일부 키는 메타).
- `index.ts` re-export.
- 검증: `pnpm --filter @fortune/product-contracts typecheck`.

### Step 1.2 — catalog 가 SoT lookup
- `fortune-catalog.ts` 의 13개 entry `costPoints: 5` → 헬퍼 `pricePoints('health')` 사용 또는 build 시 lookup.
- 검증: `pnpm --filter @fortune/product-contracts test` 가 9개 drift 자동 해소된 값으로 통과.

### Step 1.3 — codegen 스크립트
- `scripts/sync-edge-pricing.ts` (bun 또는 tsx 실행 가능).
- root `package.json` 에 `"sync:edge-pricing"` 스크립트.

### Step 1.4 — Edge 가 generated 파일 import
- `supabase/functions/_shared/fortune-pricing-generated.ts` 첫 생성 (commit).
- `supabase/functions/_shared/types.ts` 의 `FORTUNE_POINT_COSTS` 정의를 generated 파일 import + re-export 로 교체.
- 검증: `cd supabase/functions && deno check _shared/types.ts soul-consume/index.ts payment-verify-purchase/index.ts`.

### Step 1.5 — consistency test + CI hook
- `fortune-pricing.test.ts`: catalog 의 모든 id 가 SoT 에 존재 + costPoints 일치.
- precommit hook (Husky 또는 직접 git hook): `sync:edge-pricing` 실행 후 generated diff 가 있으면 fail.
- CI workflow: 동일 검증 추가.

### Step 1.6 — Edge 미정의 3개 SoT 등록
- breathing / coaching / daily-review 가격 결정 (CEO/eng review).
- SoT 추가 → codegen 재실행 → Edge 자동 동기화.

## 리스크 / 미검증

| 리스크 | 완화 |
|--------|------|
| codegen 출력 generated 파일을 사람이 직접 수정 | 헤더 `// AUTO-GENERATED` + precommit 에서 git diff 검사 + CI 동일. PR description 에서도 안내. |
| Deno 가 generated TS 파일 import 시 타입 불일치 | 단순 const + as const 로 출력. Edge `_shared/types.ts` 가 import 하면 Deno 가 직접 type infer. |
| sync 안 한 채로 SoT 만 변경 | precommit + CI 가 막음. 로컬 자동 sync 옵션 (`postedit` hook 등) 추가 검토. |
| Edge 미정의 3개 가격을 잘못 결정 → 실가격 변경 | CEO/eng review + /codex challenge × 2~3 → 사용자 승인 게이트. /ultrareview FORTUNE_POINT_COSTS 변경 자동 트리거. |
| past-life 등 큰 갭 fix 시 사용자 본 화면이 갑자기 5배 비싸짐 | UX/공지 검토 — 가격 표시 fix 는 Edge 와 일치시키는 거지만 사용자 입장엔 인상으로 보임. 이전 표시값으로 사용자가 이용한 이력 분석 + 공지 또는 grandfather 정책 검토. |

## 회귀 테스트

1. `pnpm --filter @fortune/product-contracts test` — fortune-catalog + fortune-pricing 일관성.
2. `cd supabase/functions && deno check $(find . -name "index.ts" -not -path "./_shared/*")` — Edge 모두 컴파일.
3. 시뮬레이터 (빌드 후): 13개 entry 각각 cost confirm 모달 표시값이 새 가격 맞는지 + 실제 차감 후 잔액 확인.
4. `/codex review` Step 1.1 ~ 1.6 각 단계.
5. `/ultrareview` 최종 (FORTUNE_POINT_COSTS 변경).

## 배포 순서

1. PR 머지 후 OTA — generated 파일은 Edge 코드라 OTA 가 아니라 `supabase functions deploy soul-consume payment-verify-purchase` 등 모든 Edge 재배포.
2. 클라 OTA 는 별도 (`eas update --branch production`). 단 Edge 와 클라가 잠깐 다른 가격 보면 안 됨 — Edge 먼저 배포 후 클라.
3. 사용자 잔액/차감 모니터링 (Supabase logs).

## GSTACK REVIEW REPORT

(예정 — `/autoplan` 호출 시 채워짐)
