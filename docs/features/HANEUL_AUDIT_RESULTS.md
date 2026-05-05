# 하늘이 통합 — Phase 0 Audit Results

> 작성일: 2026-05-05
> Source: 4 parallel Explore agents
> 결론: **plan v4의 4개 핵심 가정이 깨짐. plan v5로 수정 필요.**

## Executive Summary

| 영역 | plan v4 가정 | 실제 코드 | 영향 |
|------|--------------|-----------|------|
| `/fortune` 페이지 | 활성 화면, redirect 신설 필요 | **이미 `<Redirect href="/chat" />` 만 있음** | PR-C 스코프 대폭 축소. 단, 인텐트 보존 redirect는 여전히 신규 작업 |
| 운세 결과 영속 | 어디 저장되는지 모름 | **이미 SQLite + Supabase 양쪽에 chat 메시지로 저장됨**. 스키마 추가 불필요 | "내 운세" vault MVP 가능 — 신규 화면 1개만 |
| Cost confirmation | 기존 패턴 재사용 | **사전 확인 모달 없음** — 침묵 차감. idempotency도 없음 | 신규 UX 작업 + idempotency 키 도입 필요 |
| Feature flag 인프라 | 기존 시스템 확장 또는 새 테이블 | **사용자 단위 flag 인프라 0**. 스티키 버킷팅 없음. analytics stub 상태 | 인프라 풀 자체 신설. 분석 파이프라인까지 만들어야 exposure 로깅 가능 |

---

## 1. `/fortune` Inbound 24-surface Audit 결과

### 1-1. 핵심 발견

**`apps/mobile-rn/app/fortune.tsx`는 이미 redirect**:
```tsx
export default function FortuneRoute() {
  return <Redirect href="/chat" />;
}
```

총 9개 활성 reference만 발견. Inbound 표면 24개 카테고리 중 **대부분 N/A** (마케팅 이메일, App Clips, Branch, Firebase Dynamic Links 등 미사용).

### 1-2. 활성 reference 9개

| # | 파일 | 라인 | 내용 |
|---|------|------|------|
| 1 | `apps/mobile-rn/app/fortune.tsx` | 1-5 | `<Redirect href="/chat" />` |
| 2 | `packages/product-contracts/src/routes.ts` | 110-117 | 라우트 정의에 `/fortune` 탭 entry 잔존 (미사용) |
| 3 | `packages/product-contracts/src/deep-links.ts` | 1-105 | `resolveDeepLink()` — `pendingFortuneTypeStorageKey: 'pending_deep_link_fortune_type'` AsyncStorage 키 |
| 4 | `apps/mobile-rn/app/onboarding/topics.tsx` | 48, 68 | `router.replace('/chat')` (코멘트만 fortune 언급, 라우트는 chat) |
| 5 | `apps/mobile-rn/src/features/ios-widgets/fortune-widgets/*.tsx` | 다수 | 운세 *type* ID 참조, `/fortune` 라우트는 미참조 |
| 6 | `lighthouserc.json` | 8 | `http://localhost:3000/#/fortune` — 옛 웹앱용 (현재 사용 안 함) |
| 7 | `playwright/tests/e2e/fortune.spec.js` | 40, 70, 141 | 테스트 아티팩트 이름만, 라우트 X |
| 8 | `CLAUDE.md` | 201, 211, 272 | 문서에 `/fortune` 탭 표기 잔존 |
| 9 | `docs/APP_ARCHITECTURE.md` | 53, 109, 138 | 아키텍처 문서 잔존 |

### 1-3. AASA / assetlinks

- `public/.well-known/apple-app-site-association` — catch-all `/*` 패턴, fortune 특정 라우팅 없음
- `public/.well-known/assetlinks.json` — `delegate_permission/common.handle_all_urls`, fortune 특정 없음

### 1-4. 푸시/Cron 메시지

- `supabase/functions/_shared/notification_push.ts` — `buildCharacterDmPayload()` 항상 `/chat?characterId=...`
- `proactive-message-dispatch/index.ts` — `/fortune` 생성 코드 0건

### 1-5. plan 영향

- **PR-C 대폭 축소** — 이미 redirect 상태. PR-C는 "redirect를 *intent 보존*하는 redirect로 업그레이드 + flag로 토글"로 변경
- **outbound 제거 작업 거의 없음** — 인앱 CTA가 이미 정리돼있음. PR-B의 "인앱 `/fortune` CTA 제거" 항목은 routes.ts 정의 하나만
- **deep link 키 재사용** — `pendingFortuneTypeStorageKey` 가 이미 `chat?fortuneType=X` 흐름을 지원. 인텐트 보존 인프라가 일부 존재
- **문서 업데이트 필요** — CLAUDE.md, APP_ARCHITECTURE.md, routes.ts에서 `/fortune` 탭 entry 제거

---

## 2. Fortune Result Persistence 추적 결과

### 2-1. 영속 구조

**3-layer**:
1. **In-memory cache** — `fortuneResultCache` Map, 30분 TTL, max 50 entries (`features/chat-results/edge-runtime.ts:30-77`)
2. **로컬 SQLite** (Native) — `chat-db.ts`, `chat_messages.payload_json` 컬럼에 `ChatShellEmbeddedResultMessage` 직렬화 저장
3. **Supabase** (`character_conversations.messages` JSONB) — chat 동기화 시 사본 저장

### 2-2. 결과 생성 흐름 (sync, e.g. daily)

```
chat-screen.tsx handleCharacterActionPress()
  → resolveFortuneResultMessage()
  → fetchEmbeddedEdgeResultPayload() [edge-runtime.ts:79-199]
    → 클라 캐시 확인 → 미스 시 supabase.functions.invoke('fortune-{type}')
  → buildEmbeddedResultPayloadFromNormalizedResult() [adapter.ts:126-211]
  → buildEmbeddedResultMessageFromPayload() [chat-shell.ts:671-685]
  → appendMessages() → message-store → SQLite + Supabase
  → EmbeddedResultCard 렌더 (chat 스레드 안)
```

### 2-3. 결과 생성 흐름 (async, tarot/dream/compatibility/traditional-saju)

```
chat-screen.tsx [1817-1896]
  → startAsyncLongRunningJob() → Supabase 'start-long-running-job'
  → consumeRemoteTokens() (queue 후 차감)
  → buildProgressMessage() chat 삽입
  → 백그라운드: cron → process-long-running-jobs → push 알림
  → onForegroundReceive → message-store 업데이트
```

### 2-4. `/result/[resultKind]` 라우트

- 풀스크린 viewer
- `EmbeddedResultCard` 탭 시 push (`apps/mobile-rn/app/result/[resultKind].tsx`)
- `payload` 쿼리 파람으로 카드의 데이터 그대로 전달 — 새 fetch 안 함
- `payload` 없으면 메타데이터만으로 fallback 렌더

### 2-5. `features/fortune-results/` registry

- `mapping.ts` — `fortuneTypeToResultKind` 64라인, `resultMetadataByKind` 411라인 (메타데이터)
- `types.ts` — 41개 ResultKind 유니언
- `registry.tsx` — 119라인, ResultKind → React 컴포넌트 디스패치
- `screens/ondo-batch.tsx` — Ondo* 30+ 결과 컴포넌트 (legacy hero-less)
- `screens/palm-reading.tsx`, `poster-guide.tsx` — 이미지 결과 전용
- `heroes/hero-*.tsx` — Phase 3b 애니메이션 hero 컴포넌트

### 2-6. plan 영향 — "내 운세" 보관함은 **이미 가능**

**쿼리 경로**: `chat_messages WHERE kind='embedded-result'` (SQLite) 또는 `character_conversations.messages` JSONB filter (Supabase). **스키마 변경 0개**.

**MVP 보관함 화면**:
- 모든 캐릭터의 모든 embedded-result 메시지 모음
- `fortuneType` 별 그룹 또는 시간 역순
- 탭 시 `/result/[resultKind]?payload=...` 재사용 (기존 viewer)
- 빈 상태: 신규 사용자 — 프로필에서 "내 운세" 항목 hide
- **삭제/공유/북마크 = out of MVP** (Round 3 verdict 따름)

---

## 3. Cost Confirmation 패턴 조사 결과

### 3-1. 핵심 발견 — **사전 확인 모달 없음**

현재는 사용자가 운세 시작 → **침묵 차감** → 실패 시 chat에 텍스트 메시지로 통보.

```ts
// chat-screen.tsx:1647-1657
if (chargeError instanceof RemoteTokenConsumeError &&
    chargeError.code === 'INSUFFICIENT_TOKENS') {
  appendMessages(character, [
    buildAssistantTextMessage('토큰이 부족해요. 토큰을 충전한 뒤 다시 시도해주세요.')
  ]);
  return;
}
```

### 3-2. 비용 정의

- `supabase/functions/_shared/types.ts:36-174`
- `FORTUNE_POINT_COSTS` 6-tier (0/1/5/12/25/50), 80+ 운세 타입
- `normalizeFortuneType()` 으로 input 정규화

### 3-3. 차감 / 환불 / Daily 무료

| 동작 | 위치 | 비고 |
|------|------|------|
| 차감 | `supabase/functions/soul-consume/index.ts:180-241` | upsert `token_balance` + insert `token_transactions`. 두 작업 비원자적 (race window) |
| 환불 | `supabase/functions/soul-refund/index.ts:135-185` | 명시 호출 필요. 자동 invoke 코드 없음 |
| Daily 무료 | `soul-consume/index.ts:106-153` | `daily_free_fortune` 테이블 사용, 1일 1회 무료 |

### 3-4. 미해결 위험 (plan v4가 미인지)

1. **No idempotency** — 클라가 네트워크 실패 후 재시도하면 이중 과금
2. **자동 환불 미구현** — soul-refund 호출 코드가 chat-screen에 없음. 운세 생성 실패 시 토큰 사라짐
3. **비원자적 deduct** — upsert + insert 분리, 부분 실패 시 잔액-거래내역 불일치 가능
4. **Cron 잔액 재검증** — `process-long-running-jobs`가 잔액 검증, 부족 시 처리 skip → 토큰 차감했는데 처리 안 됨

### 3-5. plan 영향 — Cost confirmation은 **신규 UX 작업**

PR-B에 추가:
- 신규 `<CostConfirmationSheet>` 컴포넌트
- 운세 시작 직전 표시 ("타로 1회 = 5 포인트, 진행할까요?")
- 확인 시 → `consumeRemoteTokens()` 호출
- 취소 시 → 운세 생성 안 함

PR-A에 추가:
- `consumeRemoteTokens()` wrapper에 idempotency key (e.g., `${fortuneType}:${jobId || timestamp}`)
- soul-consume Edge Function에 `idempotency_key` 컬럼 + 중복 검사

PR-B에 추가:
- 운세 생성 실패 catch에서 자동 `soul-refund` 호출 (idempotency key 같이)

**스코프 경고**: idempotency key 도입은 DB 마이그레이션 + Edge Function 변경 + 클라 변경 동반. plan v4는 이걸 단순 "재사용"으로 가정했음 — 실제는 새 작업.

---

## 4. Feature Flag 인프라 Audit 결과

### 4-1. 핵심 발견 — **사용자 단위 flag 인프라 0**

| 항목 | 상태 |
|------|------|
| `userSession` 안의 flag 필드 | 없음 (Supabase auth Session 그대로) |
| 사용자별 sticky flag 테이블 | 없음 |
| 외부 framework (PostHog/GrowthBook/LaunchDarkly/Unleash) | 미통합 |
| 환경변수 게이트 | 일부 (dev-only, 프로덕션 무관) |
| 분석 / exposure logging | `analytics.ts` 는 stub 상태 (dev console.info 만) |

### 4-2. 일부 존재하지만 부적합

- `supabase/migrations/.../create_llm_model_config.sql` — `llm_model_config` 테이블 + `ab_test_percentage`, `ab_test_model` 컬럼
- `supabase/functions/_shared/llm/config-service.ts:172` — `Math.random() * 100 < effectiveAbPct` (**sticky 아님**)
- 5분 in-memory cache 패턴은 참고 가능

### 4-3. 분석 인프라

- `apps/mobile-rn/src/lib/analytics.ts:5-12`:
  ```ts
  export async function trackEvent(eventName, params = {}) {
    if (!appEnv.isAnalyticsConfigured && __DEV__) {
      console.info('[analytics]', eventName, params);
    }
  }
  ```
- `packages/product-contracts/src/analytics.ts:1-28` — 이벤트 이름 contract 만 (`ab_test_exposure` 등). 구현 0
- 백엔드 분석 endpoint 없음, 이벤트 집계 없음

### 4-4. plan 영향 — flag 인프라는 **풀 신축** + 분석 파이프라인까지

PR-A에서 만들어야 하는 것:

1. **DB 테이블** (Supabase migration):
   ```sql
   CREATE TABLE feature_flag_config (
     flag_name VARCHAR(50) PRIMARY KEY,
     ramp_pct INTEGER NOT NULL DEFAULT 0 CHECK (ramp_pct BETWEEN 0 AND 100),
     value_type VARCHAR(20) NOT NULL DEFAULT 'boolean', -- boolean | string
     value JSONB NOT NULL DEFAULT 'false',
     config_version INTEGER NOT NULL DEFAULT 1,
     updated_at TIMESTAMPTZ DEFAULT NOW()
   );

   CREATE TABLE feature_flag_exposures (
     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
     user_id UUID NOT NULL,
     install_id TEXT,
     flag_name VARCHAR(50) NOT NULL,
     resolved_value JSONB NOT NULL,
     ramp_pct INTEGER NOT NULL,
     surface VARCHAR(50) NOT NULL, -- chat_open | menu_render | cost_modal | generation | route_redirect
     evaluated_at TIMESTAMPTZ DEFAULT NOW()
   );

   CREATE INDEX feature_flag_exposures_user_flag_idx ON feature_flag_exposures(user_id, flag_name, evaluated_at DESC);
   ```

2. **Sticky 버킷 알고리즘** (클라/Edge 동일):
   ```ts
   // packages/product-contracts/src/feature-flags.ts
   import { createHash } from 'crypto'; // Edge
   // 클라는 expo-crypto 또는 js sha1
   export function isInRamp(
     flagName: FlagId,
     rampPct: number,
     identifier: string, // userId 우선, 없으면 installId
   ): boolean {
     const h = sha1(`${flagName}:${identifier}`);
     const bucket = parseInt(h.substring(0, 8), 16) % 10000;
     return bucket < rampPct * 100;
   }
   ```

3. **클라 hook**:
   - `useFeatureFlag(id, opts?)` — 캐시 (visibility=30min, safety=60sec, route=60sec)
   - 새로고침 트리거: `app_foreground`, `route_entry`, `pre_paid_action`, `config_version_bump`
   - fetch 실패 시 fail-closed (visibility만 last-known sticky)

4. **Edge 헬퍼**:
   - `getFeatureFlag(name, ctx)` — Supabase client, TTL 캐시 + bypass on `kill_switch_epoch` 변경
   - 5분 TTL이지만 P0 시 즉시 무효화 채널 — `feature_flag_config.updated_at`을 `kill_switch_epoch`로 사용

5. **Exposure dispatcher**:
   - `logExposure(flagName, surface, resolvedValue, rampPct)` — 5개 surface에서 호출
   - 백엔드 endpoint `/log-flag-exposure` (Edge Function) → `feature_flag_exposures` insert
   - 배치 buffering (e.g. 10 events 또는 30sec) 으로 네트워크 비용 절감

6. **분석 파이프라인 백본**:
   - 현재 `trackEvent()` stub을 끝까지 구현 (Edge Function endpoint 신설)
   - 또는 exposure 전용 단일 endpoint
   - 프로덕션에서 작동하는 첫 분석 이벤트 (이전엔 dev console만)

### 4-5. 인프라 신축 부담 평가

PR-A는 **인프라 PR**이며 다음을 포함:
- DB 마이그레이션 2개
- Edge Function 2개 (flag 조회 + exposure 로깅)
- 클라 hook + Edge 헬퍼
- exposure dispatcher
- typed contract

이게 plan v4의 PR-A 스코프보다 큼. PR-A 자체를 더 작게 쪼개거나, audit 인프라 PR을 별도(PR-0)로 분리하는 안 검토 필요.

---

## 5. Plan v5에서 수정 필요한 항목

### 5-1. 핵심 가정 변경

| Plan v4 | Plan v5 |
|---------|---------|
| "기존 `/fortune` 화면을 read-only "내 운세"로 재활용" (Round 3 채택) | **"내 운세" 보관함 신규 화면 신축** — `chat_messages WHERE kind='embedded-result'` 쿼리. 스키마 변경 없음 |
| Cost confirmation 모달 = 기존 패턴 재사용 | **신규 컴포넌트 + idempotency key 인프라 신설** |
| Flag 인프라 = "기존 시스템 확장 또는 새 테이블 — Phase 0 audit 후 결정" | **풀 신축** (DB 마이그레이션 2개, Edge Function 2개, 클라/Edge 헬퍼, exposure 분석 파이프라인) |
| PR-C = `/fortune` redirect 신설 | **PR-C = 기존 dumb redirect를 intent-preserving redirect로 업그레이드 + flag 가드** |

### 5-2. PR 분할 재고

PR-A의 작업량 상승으로 추가 분할 검토:

**옵션 1 — 4 PR**:
- **PR-0 (인프라)**: feature flag 인프라 + 분석 파이프라인 + idempotency 인프라. 운세/하늘이 코드 0
- **PR-A (데이터/타입)**: fortune-catalog SoT, 하늘이 페르소나, chat-shell kind, "내 운세" 화면 placeholder
- **PR-B**: 운세 흐름 통합 + 페르소나 invariants + cost confirmation modal + 인앱 정리
- **PR-C**: `/fortune` redirect 업그레이드 + flag 가드

**옵션 2 — 3 PR (v4 유지, PR-A 부풀림)**:
- 위 PR-A + PR-0을 합쳐 한 PR. 리뷰 부담 큼

권장: **옵션 1** (4 PR) — 인프라가 도메인 변경과 분리돼있어 회귀 안전.

### 5-3. "내 운세" MVP 정의

- 위치: 프로필 탭 → "내 운세" 항목 (조건: 사용자가 1개 이상 결과 보유 시만 표시)
- 데이터: `chat_messages WHERE kind='embedded-result'` (모든 캐릭터 통합)
- 정렬: 시간 역순
- 진입: 탭 → 기존 `/result/[resultKind]?payload=...` 재사용
- Out of MVP: 삭제, 공유, 북마크, 카테고리 필터

### 5-4. 신규 위험

1. **Idempotency key 도입은 micro-migration**. 기존 token_transactions 데이터와 호환 필요. → 별도 검토
2. **Exposure 분석 파이프라인 신설**. 첫 프로덕션 분석 이벤트 — 측정 가능성 검증 필요
3. **soul-refund 자동 호출 코드 신설**. 현재 0. 재진입성 / dead-letter 처리 결정 필요

---

## 6. Plan v5 진입 결정

**Status: NOT READY for PR implementation**

다음 단계:
1. plan v4 → v5 업데이트 (위 5-1 ~ 5-4 반영)
2. 옵션 1 (4 PR 분할) 사용자 확인
3. plan v5 기준으로 PR-0 (인프라) 구현 진입

특히 다음 결정은 plan v5에 박혀야 함:
- **PR-0 분리 OK?**
- **idempotency 키 마이그레이션 별도 plan? 또는 PR-0 안에?**
- **"내 운세" MVP 스코프 OK? 또는 더 줄임?**
