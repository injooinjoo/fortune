# 하늘이 통합 운세 캐릭터 plan

> v1: 2026-05-05 draft
> v2: Round 1 반영
> v3: Round 2 반영
> v4: Round 3 반영
> v5: Phase 0 audit 반영, 4 PR 분할
> **v6: Round 4 반영, PR-0를 0a/0b/0c로 쪼갬, 결제 안전성 우선 — 이 문서**
> 상태: 1개 비즈니스 결정 후 PR-0a 구현 진입

## 목표

운세 진입점을 **하늘이 캐릭터 1명**으로 통합한다.

**핵심 인사이트 누적**:
- 사용자 진입 습관 + 유료 히스토리 + 외부 링크 + **과금 세만틱**의 마이그레이션 (R2)
- PR 경계는 hope가 아니라 **gate** (R2)
- Flag 계약은 **typed dependency graph + safety 세만틱** (R3)
- `/fortune`는 이미 dumb redirect — 인프라 0 (Audit)
- **결제 안전성 먼저** — idempotency + atomic 차감이 cost confirmation/재시도/direct chips/async generation의 토대 (R4)

## 컨셉 (변동 없음)

스토리 탭에 하늘이 1명 추가, sticky pinned. 운세 카탈로그는 하늘이 채팅 안에서 정적 렌더. 자동인사 X, 추천 칩 + cost modal. "내 운세" 화면은 기존 chat_messages 데이터 재사용.

## 핵심 결정 (변동 — R4 반영)

| 결정 | 선택 |
|------|------|
| 운세 capability 부착 모델 | 하늘이 단독 |
| 메뉴 카드 생성 | 클라이언트 정적 카탈로그 |
| LLM 호출 범위 | 하늘이 멘트만 + 출력 경계 |
| 첫 진입 칩 구성 | meta + 2~4 direct |
| 하늘이 가시화 | default-off flag 뒤, 점진 ramp |
| `/fortune` 라우트 | flag 가드 redirect (intent 보존은 audit 후 결정) |
| 레거시 결과 | "내 운세" 신규 화면 (기존 데이터 재사용) |
| 하늘이 위치 | 캐릭터 리스트 stable pinned, 시각 분리 X |
| **운세 비용 정책** | **유료 운세 = cost modal + idempotency + atomic 차감 + 자동 환불**. **daily 무료는 유지** (TBD — 비즈니스 결정) |
| Ramp 단위 | sticky per-user hash |
| Flag 의존 그래프 | `haneul_enabled` → `haneul_fortune_enabled` → `direct_chips_enabled` → `fortune_route_behavior` |
| **PR 분할** | **6 PR**: PR-0a (결제) → PR-0b (flag) → PR-0c (분석) → PR-A (타입) → PR-B (핵심+UI) → PR-C (route) |

## 핵심 비즈니스 결정 (사용자 확인 필요)

### Daily fortune 정책 충돌

- 현재: `daily_free_fortune` 테이블 사용, 1일 1회 무료
- plan v5: "모든 운세 유료 + cost modal"
- 충돌 — 결정 필요

**권장안: daily 무료 유지**
- 이유: 사용자 retention 패턴 변경 = 비즈니스 정책 마이그레이션, 이번 plan 범위 밖
- 동작: daily 첫 사용 = 무료, modal 없음 (또는 "오늘 무료" 안내 modal). 두 번째 시도부터 또는 다른 fortune type은 cost modal
- 영향: cost modal flow에 무료 분기 추가

→ **이 plan은 권장안 채택으로 작성됨**. 사용자가 "전체 유료 전환"을 원하면 v7에서 비즈니스 임팩트 분석 별도 추가.

## Audit 결과 요약

`docs/features/HANEUL_AUDIT_RESULTS.md` 참조. 핵심:
1. `/fortune`는 이미 `<Redirect href="/chat" />` 만 함
2. 운세 결과는 SQLite + Supabase 양쪽 chat 메시지로 저장 (스키마 0 변경)
3. **Cost confirmation 모달 자체가 없음** — 침묵 차감, idempotency 0, 자동환불 0, 비원자적 deduct
4. **Feature flag 인프라 0** — `llm_model_config` (non-sticky)만 존재
5. `pendingFortuneTypeStorageKey` AsyncStorage 키가 fortune type 보존 인프라로 일부 존재

## 중요 위험 (R4 발견)

1. **token_balance upsert + token_transactions insert 비원자적** — 부분 실패 시 잔액-거래내역 불일치
2. **idempotency 도입 자체가 결제 race 악화 가능** — 안전 마이그레이션 패턴 필수
3. **`/fortune` intent param 보존 — 실제 producer 미증명** — 가상 케이스에 코드 작성하면 dead code
4. **routes.ts entry 제거는 runtime 위험** — registry iterator 깨질 수 있음
5. **FORTUNE_CATALOG vs fortuneTypeToResultKind 이중 SoT** — drift 위험
6. **iOS 위젯의 실제 라우팅** — "app launch with data passing" 의미 미증명. 위젯 탭이 `/fortune` 거치는지 모름

## Atomic Token Consume RPC (R4 핵심)

PR-0a에서 신축. 현재 비원자 패턴 → DB transaction 안에서 atomic.

```sql
CREATE OR REPLACE FUNCTION consume_token_atomic(
  p_user_id UUID,
  p_fortune_type TEXT,
  p_cost INT,
  p_idempotency_key TEXT,
  p_reference_id TEXT
) RETURNS JSONB AS $$
DECLARE
  v_existing token_transactions%ROWTYPE;
  v_balance INT;
  v_new_balance INT;
BEGIN
  -- Idempotency 체크 (차감 전)
  IF p_idempotency_key IS NOT NULL THEN
    SELECT * INTO v_existing
      FROM token_transactions
     WHERE idempotency_key = p_idempotency_key;
    IF FOUND THEN
      RETURN jsonb_build_object(
        'balance', v_existing.balance_after,
        'replayed', true,
        'transaction_id', v_existing.id
      );
    END IF;
  END IF;

  -- 잔액 row lock
  SELECT balance INTO v_balance
    FROM token_balance
   WHERE user_id = p_user_id
     FOR UPDATE;

  IF v_balance IS NULL OR v_balance < p_cost THEN
    RAISE EXCEPTION 'INSUFFICIENT_TOKENS' USING ERRCODE = 'P0001';
  END IF;

  v_new_balance := v_balance - p_cost;

  -- 차감 + 거래 기록 동일 트랜잭션
  UPDATE token_balance
     SET balance = v_new_balance,
         total_spent = total_spent + p_cost,
         updated_at = NOW()
   WHERE user_id = p_user_id;

  INSERT INTO token_transactions (
    user_id, transaction_type, amount, balance_after,
    description, reference_type, reference_id, idempotency_key
  ) VALUES (
    p_user_id, 'consumption', -p_cost, v_new_balance,
    p_fortune_type || ' 운세 이용', 'fortune', p_reference_id, p_idempotency_key
  );

  RETURN jsonb_build_object('balance', v_new_balance, 'replayed', false);
END;
$$ LANGUAGE plpgsql;
```

`refund_token_atomic` 도 동일 패턴.

## 변경 범위 — 6 PR 분할

### PR-0a: 결제 안전성 (먼저, 단독)

**이게 모든 것의 토대. 실패하면 cost modal/재시도/direct chips/async generation 전부 unsafe.**

**작업**:
- DB 마이그레이션:
  - `ALTER TABLE token_transactions ADD COLUMN idempotency_key TEXT;`
  - `CREATE UNIQUE INDEX token_transactions_idempotency_key_uidx ON token_transactions (idempotency_key) WHERE idempotency_key IS NOT NULL;` (partial)
  - `consume_token_atomic` RPC, `refund_token_atomic` RPC
- Edge Function 수정:
  - `soul-consume/index.ts` — 비원자적 코드 제거, RPC 호출. `idempotency_key` 파람 옵션
  - `soul-refund/index.ts` — 동일 패턴, `idempotency_key`로 중복 방지
- 클라:
  - `apps/mobile-rn/src/lib/premium-remote.ts:consumeRemoteTokens()` — `idempotency_key` 옵션 인자 추가
  - `chat-screen.tsx`의 fortune generation flow — 자동 idempotency_key 생성 (`${characterId}:${fortuneType}:${jobIdOrTimestamp}`)
  - 자동 환불: 운세 생성 실패 catch에서 `consumeRemoteTokens()`로 받은 transaction_id를 `refund_token_atomic`에 전달
- 회귀 테스트:
  - 같은 idempotency_key로 2회 호출 → 1회 차감 + 같은 transaction_id 반환
  - INSUFFICIENT_TOKENS 시 잔액/거래기록 둘 다 변동 0
  - Race: 동시 2 차감 → 락으로 하나만 성공
- **NO 하늘이 코드, NO flag, NO 분석**

**호환성**:
- `idempotency_key` 컬럼은 nullable — 옛 클라 (key 미전송) 정상
- Partial unique index — NULL 충돌 없음
- 옛 비원자 코드 경로는 새 RPC로 위임. 결과 호환

**머지 후**: 사용자 체감 zero. 결제 path만 안전화.

### PR-0b: Feature Flag config + resolve

**작업**:
- DB 마이그레이션:
  - `feature_flag_config` 테이블 (flag_name PK, ramp_pct, value_type, value JSONB, config_version, updated_at)
- Edge Function 신규:
  - `feature-flags-resolve` — Supabase 조회, 클라가 sticky ramp 알고리즘으로 자체 평가하거나 서버 평가 받기
- 클라:
  - `packages/product-contracts/src/feature-flags.ts` — typed contract + sticky ramp 알고리즘
  - `apps/mobile-rn/src/lib/feature-flags.ts` — `useFeatureFlag(id)` hook (TTL 캐시, refresh trigger)
- 시드: 4개 flag 모두 `false`/`legacy`
- exposure logging은 PR-0c에서 — 이 PR은 분석 의존성 없음
- 회귀 테스트:
  - flag fetch 실패 → fail-closed (visibility만 last-known)
  - sticky ramp: 같은 user, 같은 flag → 항상 같은 결과
  - kill switch: config_version bump 시 즉시 재조회

**머지 후**: 모든 flag false라 사용자 체감 zero. 하늘이 코드 없음.

### PR-0c: Exposure logging + 분석 백본

**작업**:
- DB 마이그레이션:
  - `feature_flag_exposures` 테이블 (user_id, install_id, flag_name, resolved_value, ramp_pct, surface, evaluated_at)
  - 인덱스: `(user_id, flag_name, evaluated_at DESC)`, `(flag_name, evaluated_at DESC)`
  - 보존 정책: 30일 후 cron으로 정리 (선택, separate)
- Edge Function 신규:
  - `feature-flag-exposure-log` — batch insert, 사이즈 제한 100/req
- 클라:
  - `apps/mobile-rn/src/lib/feature-flag-exposure.ts` — batch dispatcher (10 events 또는 30sec)
  - `apps/mobile-rn/src/lib/analytics.ts` — stub 끝까지 구현. 첫 프로덕션 이벤트
- 운영 도구:
  - SQL verification query 문서화
  - Edge Function 로그 모니터링 (Supabase logs)
  - daily ingest 카운트 SQL alert (수동)
- 개인정보:
  - `user_id` 그대로 저장 (Supabase 내부 UUID, 외부 노출 없음)
  - 운세 컨텐츠/대화/이름/생년월일 등 절대 미저장
- Fail open:
  - exposure logging 실패는 flag 평가/유료 액션 절대 차단 안 함
- 회귀 테스트:
  - 동시 batch insert 1000건 정상
  - 네트워크 단절 시 buffer drop OK (ramp 분석용으로 acceptable)

**머지 후**: 사용자 체감 zero. 하늘이 ramp 분석 가능 상태.

### PR-A: 데이터/타입 (사용자 노출 X)

- `packages/product-contracts/src/fortune-catalog.ts` — `FORTUNE_CATALOG` SoT
  - **dual SoT 회피**: catalog 엔트리에 `resultKind` 직접 참조. 또는 `fortuneTypeToResultKind`에서 catalog 를 generate
  - 일관성 테스트: 모든 fortune-type id가 catalog와 mapping에서 정확히 한 번씩 등장
- `apps/mobile-rn/src/lib/chat-characters.ts` — 하늘이 페르소나 추가, `haneul_enabled=false` 시 필터아웃
- `apps/mobile-rn/src/lib/chat-shell.ts` — `kind: 'fortune-menu'` 추가
- "내 운세" 화면 placeholder
- 문서 업데이트: CLAUDE.md, APP_ARCHITECTURE.md 에서 `/fortune` 탭 entry 제거
- **routes.ts entry 제거 — registry iterator 회귀 테스트 추가**:
  - 탭 레이아웃 (현재 chat + profile만), onboarding 라우팅, deep-link resolution, 사이트맵류 모두 영향 없는지 unit test

**머지 후**: 사용자 체감 zero.

### PR-B: 핵심 로직 + UI

- `supabase/functions/character-chat/index.ts` — 하늘이 분기 (페르소나 + 출력 경계 guard)
- `features/chat-results/edge-runtime.ts` — `fortune-menu` kind handler
- `features/fortune-results/fortune-menu-card.tsx` 신규
- `chat-surface.tsx` — `SegmentedPills` 제거, 하늘이 stable pinned
- 추천 칩 컴포넌트 (cold-start vs returning)
- **`<CostConfirmationSheet>` 신규** — PR-0a의 idempotency_key 인프라 사용
  - daily fortune 첫 사용은 modal 생략 또는 "오늘 무료" 안내
- "내 운세" 본구현 — `chat_messages WHERE kind='embedded-result'` 쿼리
- 프로필 탭 항목 추가 (조건 표시)
- 펼침 애니메이션 (240ms × 60ms stagger × max 4행 × reduced motion)
- Exposure logging 5 surface wired up
- **iOS 위젯 회귀 테스트** (PR-C가 아니라 여기) — 위젯 탭이 fortune flow 어디로 가는지 audit + 정상 동작 확인. 만약 `/fortune` 통과한다면 PR-C 라우트 변경 시 영향 받음

**머지 후 ramp 순서**:
1. `haneul_enabled` 1% → 100%
2. `haneul_fortune_enabled` 1% → 100%
3. `direct_chips_enabled` 1% → 100%

### PR-C: `/fortune` redirect 업그레이드

**Pre-condition (R4)**: PR-A/B 진행 중 audit — 실제로 `/fortune?type=...` URL을 producing 하는 inbound이 존재하는지 확인.

- 존재 0건 시: `app/fortune.tsx`는 `<Redirect href="/chat" />` 그대로 두고 PR-C 폐기. flag도 불필요
- 존재 시: 그 producer가 어떻게 type을 인코딩하는지(`pendingFortuneTypeStorageKey` 거치는지) 확인 후 일관 동작

**작업 (존재 케이스)**:
- `app/fortune.tsx` flag 분기:
  - `legacy`: 기존 dumb redirect
  - `redirect_to_haneul`: query param 보존하여 `/chat?character=haneul_oracle&fortuneType=...&source=fortune_redirect`. 단 `haneul_fortune_enabled=false`면 legacy 다운그레이드
  - `disabled`: 404
- `pendingFortuneTypeStorageKey` 흐름 통합 — 새 path 발명 X
- exposure logging

**머지 후**:
- flag `legacy` 유지 (zero impact)
- `redirect_to_haneul` 1% → 100% (의존: `haneul_fortune_enabled=true`)
- `disabled` 전환은 zero inbound + 6~12개월 후 별도 PR

### (옵셔널, 한참 후): `/fortune` 코드 완전 제거

## 에러/엣지 (변동 없음)

## 테스트

자동: `npx tsc --noEmit`, `deno check`

페르소나 회귀: 9 케이스 (v4와 동일)

시스템 회귀:
- 기존 8명 캐릭터 한 턴 이상
- 토큰 잔액 변동 정상 + idempotency 검증 (PR-0a 회귀)
- "내 운세" 진입 — 기존 결과 표시
- iOS 위젯 탭 → 정상 도착

Flag 매트릭스 (의존 그래프 valid 조합) (v5와 동일)

Exposure logging 검증

플랫폼: iOS Simulator MCP, Android 수동, cold launch deep link

시나리오: 14개 (v5와 동일)

## High blast radius / `/ultrareview`

- **PR-0a**: 결제 코드 + DB 마이그레이션 → `/ultrareview` (필수)
- **PR-0b**: DB 마이그레이션 + 클라/Edge contract → `/ultrareview`
- **PR-0c**: 분석 파이프라인 첫 도입 → `/ultrareview` (필수)
- **PR-A**: SoT 변경 + routes 변경 → `/ultrareview`
- **PR-B**: Edge Function 스키마 + 채팅 코어 + cost modal → `/ultrareview` (필수)
- **PR-C**: 라우팅 + 외부 inbound → `/ultrareview` (필수)

## Round 5 (필요 시)

R4가 매우 깊었음. 다음 라운드는 PR-0a 코드 완성 후 그 diff 자체에 `/codex review`로 충분할 것 — plan-level adversarial 라운드 추가 효용 낮음.

## 진행 순서

1-9. ✅ v1~v5 + Round 1~3 + audit
10. ✅ Round 4
11. ✅ plan v6 (이 문서)
12. **사용자 daily fortune 권장안 확인**
13. ⏳ PR-0a 구현 → `/codex review` → `/ultrareview` → 사용자 승인 → 머지
14. PR-0b → 검토 → 머지
15. PR-0c → 검토 → 머지
16. PR-A → 검토 → 머지
17. PR-B → 검토 + iOS Simulator 캡처 → 머지 → flag ramp 1·2·3
18. PR-C audit (실제 producer 존재 확인)
19. PR-C 구현 (필요 시) → 검토 → 머지 → flag ramp 4
