# 웹 우선(Web-first) 사업 개편 계획

> 작성: 2026-08-18 · 상태: **초안 — `/codex challenge` 2~3회 필요** · 대상 브랜치: `claude/webpage-business-overhaul-75db1e`
>
> 이 문서는 13개 에이전트가 리포를 직접 읽어 만든 리서치 4종 + 설계 4종 + 적대적 리뷰 3종을 통합하고,
> 리뷰가 제기한 치명적 반박을 **저장소에서 직접 재검증**한 뒤 그 결과로 설계를 수정한 결과다.
> 검증 명령과 결과는 각 항목에 인용했다.

---

## 0. 결론 요약

| 항목 | 결정 |
|---|---|
| 방향 | **웹 = 획득 + 운세 + 결제의 메인 채널.** 앱 = 관계형 채팅 + 리텐션 채널로 잔류 |
| 스택 | `apps/web` 신규 Next.js 15 App Router, 기존 89개 Edge Function 재사용 |
| 결제 | 토스페이먼츠 단독, 표시가 앱과 패리티 + 웹 전용 토큰 +20% 보너스 |
| 착수 조건 | **§2 보안 4건 + §3 과금 게이트가 끝나기 전에는 공개 웹 오리진을 열지 않는다** |
| 첫 증명 | M1 수요 프로브 20페이지 → **3주 오가닉 노출 실측** → 통과해야 M2 착수 |
| 총 공수 | **59 dev-day ≈ 솔로 12주** (프로브 관찰 3주는 M2 게이트로 병행) |

### 0.1 구현 현황 (2026-08-18 기준)

| 항목 | 상태 | 배포 |
|---|---|---|
| **P0-A** 원장·권한 하드닝 (§2) | ✅ 마이그레이션 8종 + 감사 스크립트 강화 + 배포검증 SQL | ❌ 미적용 |
| **P0-B** 서버측 과금 게이트 (§3) | ✅ 43/45 fortune 함수 + 캐시 테이블 + 이중과금 마커 | ❌ 미배포 |
| **M1** `apps/web` 스캐폴드 | ✅ 빌드/타입체크 green, 8 라우트 | ❌ 미배포 |
| M1 나머지 (한글 slug 20페이지, 게스트 퍼널, `seo_content` cron, GSC/GA4) | ⬜ 미착수 | — |
| M2 이후 | ⬜ 미착수 | — |

**통과한 게이트**: `rls-static-audit.sh` exit 0 · `rn:typecheck` exit 0 · `rn:test` exit 0 ·
`deno check` fortune-* **28 PASS / 17 FAIL — HEAD 베이스라인과 실패 집합이 완전히 동일**(신규 에러 0) ·
`_shared/fortune_charge.ts` PASS · `web typecheck` exit 0 · `web build` exit 0 · `check:edge-pricing` 소스↔생성 동기.

**통과하지 못한 것 (환경 문제, 코드 결함 아님)**: `npm run test:web:ci` 4개 스펙 중 **1개만 통과**했다.
webServer(`next build && next start`)는 정상 기동했고 request 기반 `robots.txt` 스펙은 통과했지만,
브라우저 기반 3개는 이 머신에서 Playwright 크로미움 바이너리 다운로드가 끝나지 않아 실행되지 못했다
(`Executable doesn't exist at .../chromium_headless_shell-1217`). CI 스텝은
`npx playwright install --with-deps chromium chromium-headless-shell` 로 두 변종을 모두 받도록 지정해 뒀다.
로컬 재현: 다운로드 완료 후 `npm run test:web:ci` 재실행.

**배포는 하나도 하지 않았다.** `supabase db push`, `supabase functions deploy`, Vercel 배포 전부 오너 승인 사항이다.
적용 순서는 §3.3 하단의 강제 순서를 따른다.

---

**이 계획이 이전 초안과 다른 점 (적대적 리뷰 반영):**

1. 웹 채팅(9d)을 **맨 뒤로** 옮겼다. 가장 큰 덩어리인데 웹에 리텐션 장치가 없어 성과 판정이 오염된다.
2. 서버측 토큰 과금이 **존재하지 않는다는 사실**을 확인하고, 이를 웹 착수의 하드 선행조건으로 승격했다.
3. 토큰 발행 RPC 3종의 **실행 권한 구멍**을 확인하고 P0 로 분리했다. 이건 웹과 무관하게 지금 뚫려 있다.
4. URL 스킴·SKU 네임스페이스·Node 버전·페이지 수 등 초안 내부의 **상호모순 6건**을 하나씩 확정했다.
5. 광고 매출이 사라지는 **웹 Free 티어 손익**을 별도 항목으로 만들었다.

---

## 1. 시작 전에 오너만 답할 수 있는 것

### 1.1 즉시 필요 — 이게 없으면 §8 동결 결정을 내릴 수 없다

현재 앱 실적 6개 숫자. 리포 어디에도 없고 추정으로 대체 불가하다.

| 지표 | 값 |
|---|---|
| MAU / DAU | |
| 월 총매출 (스토어 실수령) | |
| 유료 전환율 | |
| 유기 설치 비중 | |
| D30 리텐션 | |
| 현재 오가닉 웹 유입 (zpzg.co.kr) | |

이 값이 0에 가까우면 네이티브 동결 비용은 0이고 웹 피벗은 명백히 옳다.
실제 매출이 나오고 있다면 "유일한 수익 채널을 12주 방치"가 되므로 §8 의 동결 범위를 좁혀야 한다.

### 1.2 착수일(D0)에 바로 시작해야 하는 외부 절차

| # | 항목 | 이유 | 리드타임 |
|---|---|---|---|
| 1 | **통신판매업 신고** (서초구청) | 저장된 사업자 정보에는 "현재 대상 아님"으로 되어 있으나 이는 **앱스토어 대행판매 기준**이었다. 자사 웹 직접 결제는 전제가 바뀐다: 비욘드는 **일반과세자**라 전자상거래법 시행령 제6조 면제요건(간이과세자 + 연 50회 미만)을 충족하지 못한다 | 1~2주 |
| 2 | **토스페이먼츠 가맹점 계약** | 위 신고에 필요한 **구매안전서비스 이용 확인증**을 PG 가 발급 → 두 절차가 맞물린다. `.env.example:34-44` 에 키 **이름**만 있고 값이 없어 실계정 여부 확인 필요 | 사업자 심사 1~3주 |
| 3 | Supabase 대시보드 — **Anonymous sign-ins 활성화 + CAPTCHA(Turnstile) 설정** | 둘 다 `supabase/config.toml` 로 표현 불가한 프로젝트 설정이다(현재 파일은 66줄 `verify_jwt` 오버라이드뿐, `[auth]` 블록 없음). 게스트 퍼널의 하드 선행조건 | 즉시 |
| 4 | Vercel — `ondo-web` 신규 프로젝트 + 기존 `zpzg-landing` 의 Git 연결 상태 확인 | 라이브 `/privacy` 5,555B vs master `public/privacy.html` 5,797B 로 **이미 드리프트**. 배포 워크플로가 리포에 0건이라 마지막 배포가 수동이었다는 뜻 | 즉시 |
| 5 | Kakao Developers 웹 플랫폼 등록 + **JavaScript 키** | `apps/mobile-rn/src/lib/env.ts:34` 의 `kakaoAppKey` 는 네이티브 앱 키라 웹에서 못 쓴다 | 즉시 |
| 6 | **이메일 발송 서비스 계정** (Resend 등) | 웹의 유일한 리텐션 채널 + 결제 영수증 + 자동갱신 사전고지에 필수 (§7.4) | 즉시 |
| 7 | ZEN SERIF **웹 임베딩** 라이선스 확인 | `apps/mobile-rn/assets/fonts/` 에 라이선스 파일이 없다. 웹 서빙은 앱 임베딩과 다른 권리 | M2 전 |

---

## 2. P0 — 웹과 무관하게 지금 뚫려 있는 결함

> 초안에서는 마이그레이션 파일만 근거였다. 이후 **라이브 DB(project `hayjukwfcsdmppairazc`)를
> 읽기 전용으로 introspect** 해 전부 재확인했고, 그 과정에서 초안이 몰랐던 프로덕션 장애 1건(§2.0)을 찾았다.
> 이 항목들은 웹 계획의 일부가 아니라 **현재 프로덕션의 상태**다. 웹이 브라우저에 anon key 를 배포하는 순간
> "앱 디컴파일 필요"에서 "devtools 열면 끝"으로 난이도가 떨어진다. 웹 착수 여부와 무관하게 먼저 고친다.

### 2.0 🔴 토큰 차감이 프로덕션에서 한 번도 성공한 적이 없다

라이브 실측:

| 확인 | 결과 |
|---|---|
| `token_transactions` CHECK | `transaction_type IN ('earn','spend','purchase','refund')`, `convalidated = true` |
| `consume_token_atomic` 본문 (`pg_proc.prosrc`) | 마지막에 `transaction_type = 'consumption'` 을 INSERT |
| `'consumption' = ANY(ARRAY['earn','spend','purchase','refund'])` | **false** |
| `token_transactions` 실제 값 분포 | purchase 17 / earn 8 / refund 6 · **consumption 0 · spend 0** |
| `token_transactions` 트리거 | 없음 (값을 변환하는 경로 없음) |

즉 `consume_token_atomic` 은 INSERT 지점에서 **항상 SQLSTATE 23514 로 실패**하고, 같은 트랜잭션의
`UPDATE token_balance`(잔액 차감)도 함께 롤백된다. replay 분기는 기존 `'consumption'` 행을 찾아야 하는데
그런 행이 0건이므로 우회로도 없다.

파급 경로 (전부 코드로 확인):

```
consume_token_atomic → 23514
  ↓
_shared/token_charge.ts chargeTokens  — P0001(잔액부족)만 처리하고 나머지는 throw
  ↓
soul-consume/index.ts:203            — 500 'Failed to consume token'
  ↓
apps/mobile-rn/.../chat-screen.tsx:2215
   captureError(...) 후 shouldRenderResult = isCurrentFortuneGeneration(...)  ← true 유지
  ↓
운세 결과를 그대로 렌더한다 (fail-open)
```

surface 이름 자체가 `chat:fortune-charge-after-success` 다 — LLM 이 이미 돌았으니 결과를 버리지 않겠다는
의도인데, RPC 가 상시 실패하는 상태와 결합해 **유료 운세가 과금 없이 제공되어 왔다**.
`token_balance.total_spent` 합계 775(4명)는 `_shared/auth.ts` `deductTokens` 의 레거시 직접 쓰기 경로에서
나온 값이며 거래 이력이 없다.

> 로그로는 재현을 확인하지 못했다 — 최근 24시간 `function_logs`/`postgres_logs` 에 토큰 과금 시도가
> 성공·실패 모두 0건이다(실사용 트래픽이 사실상 없다). 위 결론은 CHECK 제약 · 함수 본문 · 원장 데이터
> 세 가지의 정적 증거에 근거한다.

**수정**: `supabase/migrations/20260818000100_fix_token_transaction_type_check.sql` —
허용값에 `'consumption'`(장애 원인)과 `'chargeback'`(웹 환불용 예약)을 추가한다. RPC 쪽을 `'spend'` 로
바꾸지 않는 이유는 `refund_token_atomic` / `soul-refund` / `token_charge.ts` 가 전부 `'consumption'` 을
조회 기준으로 삼고 있어 값을 바꾸면 환불 경로가 같이 깨지기 때문이다.

> ⚠ **배포 시 행동 변화**: 이 마이그레이션이 적용되는 순간 토큰 차감이 실제로 작동하기 시작한다.
> 지금까지 무과금으로 이용하던 사용자가 잔액 부족을 만나게 된다. 의도된 정상화지만 사용자 영향이 있는
> 변경이므로 배포 시점은 오너가 정한다.

### 2.1 `grant_purchase_tokens_atomic` 이 PUBLIC 실행 가능 — 토큰 무한 발행

```bash
grep -rn -E "(GRANT|REVOKE).*grant_purchase_tokens_atomic" supabase/migrations/
# → 20260515044600_purchase_iap_grant_permissions.sql:1: GRANT EXECUTE ... TO service_role  (REVOKE 없음)
cat supabase/migrations/20260606143000_harden_atomic_rpc_execute_grants.sql
# → SELECT 1;      ← 하드닝 마이그레이션이 비어 있다
```

`20260515044500` 이 `CREATE OR REPLACE` 로 새로 만들었으므로 PostgreSQL 기본값인 **PUBLIC EXECUTE** 가 그대로 남아 있고,
`anon` / `authenticated` 가 이를 상속한다. 함수는 `SECURITY DEFINER` 이며 `p_user_id`, `p_base_amount` 를 인자로 받고
`auth.uid()` 검사를 하지 않는다. 즉 anon key 하나로:

```
POST /rest/v1/rpc/grant_purchase_tokens_atomic
{ "p_user_id": "<본인 uid>", "p_base_amount": 999999, "p_reference_id": "<random>" }
```

가 성립하고 50% 첫구매 보너스까지 얹힌다. 2026-06 하드닝 스윕(`143001`/`143020`/`143040`/`143060`)은
`grant_ad_reward` · `activate_subscription` · `schedule_poster_job` · `claim_poster_job` 만 덮었고 이 함수를 빠뜨렸다.

**라이브 ACL 실측** (`pg_proc.proacl` + `has_function_privilege`, 2026-08-18) — 마이그레이션 추론이 아니라 실제 권한:

| 함수 | SECURITY DEFINER | anon | authenticated | 조치 |
|---|:---:|:---:|:---:|---|
| `grant_purchase_tokens_atomic` | ✔ | **실행 가능** | **실행 가능** | 회수 |
| `consume_token_atomic` | ✔ | **실행 가능** | **실행 가능** | 회수 |
| `refund_token_atomic` | ✔ | **실행 가능** | **실행 가능** | 회수 |
| `consume_chat_streak` | ✘ | 실행 가능 | 실행 가능 | 회수 |
| `expire_old_subscriptions` | ✔ | 실행 가능 | 실행 가능 | 회수 |
| `grant_initial_tokens` | ✔ | 실행 가능 | 실행 가능 | 회수 |
| `check_duplicate_fortune` | ✔ | 실행 가능 | 실행 가능 | 회수 (호출부 0건) |
| `merge_character_conversation_messages` | ✔ | 실행 가능 | 실행 가능 | anon 만 회수 — 본문에 `auth.uid() <> p_user_id → 42501` 가드가 이미 있고, `character-conversation-save` 가 authenticated 로 호출한다 |
| `enqueue_pending_reply_job` | ✔ | 실행 가능 | 실행 가능 | anon 만 회수 — RN 클라이언트가 직접 호출 |
| `activate_subscription_purchase_atomic` | ✔ | 차단됨 | 차단됨 | (6월 스윕에서 처리됨) |
| `grant_ad_reward_atomic` | ✔ | 차단됨 | 차단됨 | (동일) |
| `schedule_poster_job_with_charge` | ✔ | 차단됨 | 차단됨 | (동일) |
| `claim_next_poster_job` | ✔ | 차단됨 | 차단됨 | (동일) |

회수 대상 6종은 전부 service_role 클라이언트에서만 호출된다는 것을 호출부 grep 으로 확인했다
(`payment-verify-purchase`, `soul-consume`, `soul-refund`, `_shared/token_charge.ts` 를 쓰는
`character-chat`/`generate-friend-avatar`/`generate-character-proactive-image`, `fortune-tarot` 의 `supabaseAdmin`).

### 2.2 `consume_token_atomic` / `refund_token_atomic` 이 `authenticated` 에 직접 GRANT — 환불 파밍

```bash
sed -n '130,136p;225,232p' supabase/migrations/20260505150000_token_atomic_rpcs_and_text_reference.sql
# → GRANT EXECUTE ON FUNCTION refund_token_atomic(...)  TO service_role, authenticated;
# → GRANT EXECUTE ON FUNCTION consume_token_atomic(...) TO service_role, authenticated;
grep -n "REVOKE" supabase/migrations/20260505200100_atomic_token_rpcs.sql
# → REVOKE EXECUTE ... FROM PUBLIC;   ← 명명된 롤 grant 는 제거되지 않는다
```

`REVOKE ... FROM PUBLIC` 은 `authenticated` 에 직접 준 권한을 회수하지 못하고,
`CREATE OR REPLACE FUNCTION` 은 기존 ACL 을 보존한다(두 파일의 시그니처 동일). 결과적으로 **로그인한 브라우저가
자기 소비를 그대로 환불**할 수 있다 — `referenceId` 는 클라이언트가 `soul-consume` 에 보낸 값이라 이미 알고 있다.

### 2.3 클라이언트가 고정한 멱등키가 무료 생성 경로가 된다

`consume_token_atomic` 의 replay 조회가 `WHERE idempotency_key = p_idempotency_key AND transaction_type='consumption'`
로 **user_id 스코프가 없고**, `_shared/token_charge.ts` 의 `chargeTokens` 는 replay 를 `charged: true` 로 반환한다.
호출부는 전부 `!charged` 만 본다. 즉 키를 하나로 고정하면 **첫 호출만 과금되고 이후는 무료로 LLM 이 계속 돈다.**

### 2.4 만료된 구독을 같은 결제로 무한 재활성화

`subscription-activate/index.ts:70` 은 `{productId, purchaseId, platform}` + JWT 만 받고 영수증을 재검증하지 않는다
(`verified_purchases` 행 존재에만 의존). `activate_subscription_purchase_atomic` 의 replay 분기는
`IF v_expires_at <= now() OR status <> 'active' THEN v_expires_at := GREATEST(v_expires_at, now() + p_duration_days)`
로 **기간을 연장**한다. `verified_purchases_self_read` 정책이 본인 `verified_transaction_id` 읽기를 허용하므로,
구독 → 해지 → 만료 후 같은 purchaseId 재전송 = 한 번의 결제로 영구 갱신.

### 2.5 조치 (P0-A) — **작성 완료, 미배포**

| 산출물 | 내용 | 상태 |
|---|---|---|
| `20260818000100_fix_token_transaction_type_check.sql` | §2.0 장애 수정 — CHECK 에 `consumption`/`chargeback` 추가 | ✅ 작성 |
| `20260818000200_revoke_money_rpc_execute.sql` | 위 ACL 표의 회수 6종 + anon-only 회수 2종 | ✅ 작성 |
| `20260818000300_token_rpc_replay_user_scope.sql` | `consume_token_atomic` / `refund_token_atomic` replay 조회에 `AND user_id = p_user_id` | ✅ 작성 |
| `20260818000400_subscription_replay_and_cross_platform_guard.sql` | replay 분기의 기간 연장 제거 + 타 채널 활성 구독 시 `CROSS_PLATFORM_SUBSCRIPTION_ACTIVE` (술어 `status='active' AND expires_at > now()`) | ✅ 작성 |
| `20260818000500_schedule_expire_old_subscriptions.sql` | `expire_old_subscriptions()` 매시 정각 cron | ✅ 작성 |
| `20260818000600_profile_completion_bonus_atomic.sql` | 절대값 upsert → 상대 증분 원자 RPC. `profile-completion-bonus/index.ts` 도 RPC 호출로 교체 | ✅ 작성 |
| `20260818000700_codify_money_tables.sql` | 원장 4테이블 DDL·RLS 성문화 + 클라이언트 쓰기 권한 회수 | ✅ 작성 |
| `20260818000800_close_static_audit_gaps.sql` | 감사 게이트가 찾은 잔여 4건 (`korean_holidays`/`auspicious_days` RLS 성문화, `check_duplicate_fortune` 회수) | ✅ 작성 |
| `supabase/scripts/rls-static-audit.sh` | 추출기가 비수식 `CREATE TABLE` 도 매칭(26개 → 전체) + **SECURITY DEFINER × `p_user_id` RPC 의 REVOKE 여부** 게이트 신설 | ✅ 수정 |

**검증 완료**:
- `bash supabase/scripts/rls-static-audit.sh` → **exit 0** (두 게이트 모두 OK)
- `deno check ./profile-completion-bonus/index.ts` → 통과

**미검증 (배포 전 필수)**: 위 SQL 은 **어떤 DB 에서도 실행되지 않았다.** 프로덕션에 직접 DDL 을 적용하는 것은
배포 행위이므로 하지 않았다. `supabase db push --include-all` 은 오너가 실행하거나 명시 승인해야 하며,
적용 순서는 파일명 타임스탬프 순서(000100 → 000800)를 그대로 따른다.
`20260819100000_fortune_result_cache.sql` 은 §3 산출물이라 그 뒤에 온다.

**CLAUDE.md 규칙상 이 묶음은 `/ultrareview` 자동 트리거 대상이다** (토큰 grant · RLS · 결제 로직 · 마이그레이션).

---

## 3. P0 — 서버측 토큰 과금이 존재하지 않는다 (웹의 하드 선행조건)

### 3.1 사실 확인

```bash
ls -d supabase/functions/fortune-*/ | wc -l          # 45
grep -l -E 'chargeTokens|consume_token_atomic|soul-consume' supabase/functions/fortune-*/index.ts
# → fortune-tarot/index.ts   (1개)
grep -n "anonymous" supabase/functions/fortune-daily/index.ts
# → 368: const userId = (await deriveUserIdFromJwt(req)) ?? 'anonymous'
grep -rn "consumeRemoteTokens" apps/mobile-rn/src
# → chat-screen.tsx:2190 → premium-remote.ts:338 → POST /soul-consume
```

**45개 fortune 함수 중 44개는 토큰을 과금하지 않는다.** 과금은 RN **클라이언트**가 별도로 `soul-consume` 을 호출해
수행하며, 그 호출은 `if (session && !tokensConsumedForResult)` 로만 보호된다.
`_shared/auth.ts:19-53` 의 `deriveUserIdFromJwt` 는 bearer 가 anon key 일 때 `null` 을 반환하고,
`fortune-daily` 는 그것을 `'anonymous'` 로 흘려보낸다.

→ **브라우저에 anon key 를 배포하는 순간, 공개된 키 하나로 44종의 유료 운세가 무제한 무료가 된다.**
`supabase/config.toml` 의 `verify_jwt=false` 7개 fortune 함수는 키조차 필요 없다.
Turnstile 이나 IP 리밋은 이 경로를 막지 못한다 — 세션이 아예 필요 없기 때문이다.

이건 초안 3개 섹션이 모두 참으로 가정했던 명제("모든 fortune 함수가 서버에서 과금한다")를 정면으로 반증하며,
어떤 마일스톤에도 이 작업이 잡혀 있지 않았다.

### 3.2 설계 — `fortune-tarot` 패턴을 전 함수로 확장 (P0-B, 6 dev-day)

`fortune-tarot/index.ts:97-107` 이 이미 정답 형태다: 클라 `clientChargeId` 를 **JWT uid 로 네임스페이스**해 멱등키를 만들고
서버에서 `chargeTokens` 를 호출한다. 이걸 공용 헬퍼로 승격해 나머지에 적용한다.

```
supabase/functions/_shared/fortune_charge.ts (신규)

export async function requirePaidFortuneCaller(req, fortuneType, requestBody) {
  const userId = await deriveUserIdFromJwt(req)
  if (!userId) return { error: 401, code: 'AUTH_REQUIRED' }        // 'anonymous' 폴백 제거

  // 멱등키는 서버가 파생한다 — 클라가 고정한 키로 무료 생성되는 §2.3 경로 차단
  const key = `fortune:${userId}:${fortuneType}:${await sha256(canonicalize(requestBody))}:${bucket15min()}`

  const cached = await readResultCache(key)                        // replay = 이전 결과 반환, LLM 재실행 금지
  if (cached) return { userId, replayed: true, cached }

  const charge = await chargeTokens({ userId, fortuneType, idempotencyKey: key })
  if (!charge.charged) return { error: 402, code: 'INSUFFICIENT_TOKENS' }
  return { userId, key }
}
```

**신규 테이블** `fortune_result_cache(idempotency_key PK, user_id, fortune_type, payload jsonb, created_at)`,
TTL 24h, service_role only. replay 시 payload 를 그대로 반환한다.

**네이티브를 깨뜨리지 않는 이유**: RN 클라이언트는 계속 `soul-consume` 을 호출하지만,
`consume_token_atomic` 이 멱등이므로 **동일 키면 이중 과금이 발생하지 않는다**.
→ RN 은 `clientChargeId` 를 요청 body 에 실어 보내고 서버가 그 값을 키 파생에 포함시키는 방식으로 한 번에 맞춘다.
RN 의 독립 `soul-consume` 호출 제거는 그 다음 OTA 에서 별도 처리한다(제거 전이라도 안전).

### 3.3 적용 결과 — **구현 완료, 미배포**

| 산출물 | 상태 |
|---|---|
| `supabase/functions/_shared/fortune_charge.ts` | ✅ `requirePaidFortuneCaller` / `storeFortuneResult` / `refundFortuneCharge` / `withTokenCharge` |
| `supabase/migrations/20260819100000_fortune_result_cache.sql` | ✅ service_role 전용 캐시 테이블 + pg_cron 일일 정리 |
| 게이트 적용 | ✅ **45개 중 43개.** 미적용 2개는 `fortune-tarot`(이미 서버 과금 중) 과 `fortune-recommend`(무료 추천기) |
| `?? 'anonymous'` 폴백 | ✅ 전부 제거 (`fortune-daily`, `fortune-wealth`) |

**게이트 배치 위치가 중요하다**: 입력 검증 **뒤**, cohort-pool 조회·레거시 `fortune_cache` 조회·LLM 호출
**앞**. 검증 실패는 과금하지 않고, 캐시에서 서빙하는 것도 유료 상품을 서빙하는 것이므로 과금한다
(`fortune-tarot` 과 동일한 판단). 브라우저가 캐시 친화적 파라미터로 무료 파밍하는 경로를 막는다.

#### 🔴 검증 과정에서 잡은 영구 무료 구멍 (수정 완료)

최초 구현은 멱등키를 `fortune:<uid>:<type>:<bodyHash>` 로 만들고 "TTL 이 유일한 시간 축"이라고 봤다.
**틀렸다.** `consume_token_atomic` 은 같은 키에 대해 **영원히** `replayed=true` 를 돌려주고
`token_charge.ts` 는 그것을 `charged:true` 로 매핑한다. 반면 캐시 row 는 24h 뒤 사라진다:

```
1회 과금 → 24h 대기 → 캐시 미스 + 차감 replay → LLM 무료 실행 → 무한 반복
```

**수정**: 키에 24h 윈도우 인덱스를 붙이고(`...:<floor(now/24h)>`), `storeFortuneResult` 가
`expires_at` 을 그 윈도우 종료 시각으로 명시해 키와 캐시의 수명을 일치시켰다.

**잔여(경계 있음)**: 같은 윈도우 안에서 캐시 저장이 실패했거나 생성 실패 후 환불된 요청을 재시도하면
1회 무료 생성이 가능하다. 원장이 "환불된 consume"을 구분하지 못해 스키마 변경 없이는 못 막는다.
발생 시 `[fortune_charge] 차감 replay (무차감 생성)` 경고가 함수 로그에 남는다.

#### 🔴 이중 과금 (수정 완료, 앱 OTA 불필요)

서버가 과금하기 시작하면 RN 클라이언트의 기존 `soul-consume` 호출과 겹쳐 **매 운세가 2배 청구**된다.
앱을 고치지 않고 해결했다 — 이미 배포된 앱 빌드에도 적용된다:

```
Edge 응답 최상위 tokenCharge
  → edge-runtime.ts 가 payload.serverTokenCharge 로 복사
  → chat-screen.tsx:2179  tokensConsumedForResult = Boolean(serverTokenCharge) = true
  → 클라이언트가 자체 soul-consume 호출을 건너뛴다
```

`fortune-tarot`(index.ts:731, 810)이 원래부터 쓰던 계약이다. 43개 함수의 모든 200 응답에
`tokenCharge: { cost, balance, consumeTransactionId, replayed }` 를 싣도록 배선했다
(캐시 replay 응답 포함 — 없으면 replay 때 클라가 과금한다). 저장되는 캐시 payload 에는 넣지 않는다
(balance 가 곧 낡기 때문에 응답 시점에만 부착).

#### 가격 드리프트 1건 수정

`fortune-family-change` 가 5토큰이 아니라 1토큰을 걷고 있었다 — `getFortuneCostPoints` 는 미등록 키에
1을 폴백하는데 `'family-change'` 가 `packages/product-contracts/src/fortune-pricing.ts` 에 빠져 있었다
(형제 4종은 전부 5). 클라이언트는 `resolveFamilyApiType` 로 `'family'`(=5) 를 통해 이 엔드포인트에
도달하므로 서버와 클라이언트가 어긋난 상태였다. `'family-change': 5` 추가 + `sync:edge-pricing` 재생성.

**검증 완료**: `deno check ./_shared/fortune_charge.ts` 통과 · 43개 함수 전부 HEAD 대비 **신규 타입 에러 0**
(17개 파일의 121개 에러는 전부 pre-existing, 오류 집합이 HEAD 와 byte-identical) ·
`canonicalJson`/`sha256Hex`/키 윈도우 동작 11개 단언 통과 · `npm run check:edge-pricing` 소스↔생성 파일 동기.

**미검증**: Edge Function 은 배포되지 않았고 실제 요청으로 과금이 일어나는 것은 확인하지 못했다.
`supabase/scripts/verify-p0-hardening.sql` 하단의 참고 쿼리로 배포 후 `consumption` 행 발생을 확인해야 한다.

> ⚠ **배포 순서 강제**: `fortune_result_cache` 마이그레이션이 **함수 배포보다 먼저** 적용돼야 한다.
> 함수가 먼저 뜨면 캐시 SELECT 가 실패하고, 게이트는 사용자를 막지 않도록 경고만 남기고 통과시키므로
> 과금은 되지만 **멱등/재생 보호가 조용히 사라지고 모든 재시도가 재과금**된다.

**이것이 배포되기 전에는 `apps/web` 을 공개 도메인에 붙이지 않는다.** M1 개발은 preview 도메인에서 병행 가능하다.

---

## 4. 제품 형태 — 웹이 가져가는 것과 앱에 남기는 것

리뷰의 가장 강한 사업적 반박: 웹으로 **무게중심을 통째로** 옮기면, push 에 종단이 걸린 리텐션 루프
(`deliver-due-replies`, `proactive-message-dispatch`, `character-chat` 의 `delaySec`/`scheduledId`/`deliverAt`)가
웹에서 통째로 빠지는데 대체재가 없다. 그 상태로 "웹 리텐션이 낮으니 웹이 안 된다"고 판정하면
**리텐션 장치 없이 배포한 결과를 채널 탓으로 오독**하게 된다.

**결정: 이중 채널.**

| | 웹 (`apps/web`) | 앱 (`apps/mobile-rn`) |
|---|---|---|
| 역할 | 획득 · 운세 · 결제 | 관계형 채팅 · 리텐션 |
| 핵심 자산 | 검색 유입, `/사주` 만세력 계산기, 웹 결제(수수료 3% 대 15~30%) | 푸시 선톡, 카메라 운세, 리워드 광고 |
| v1 채팅 | **M5 로 후순위** (조건부) | 유지 |
| 리텐션 채널 | 이메일 다이제스트 (§7.4) — 채팅과 **동시** 출시 | Expo push |

웹 채팅(9d, 단일 최대 덩어리)은 M1~M4 지표가 정당화한 뒤에만 착수한다.

---

## 5. 아키텍처 — `apps/web`

### 5.1 확정 결정

| # | 질문 | 결정 | 근거 |
|---|---|---|---|
| A-1 | 프레임워크 | Next.js 15.5 App Router, **react/react-dom 19.1.0 핀** | root `package.json` 이 19.1.0 을 pin 하고 `.npmrc` 가 `node-linker=hoisted` — 불일치 시 React 2벌 |
| A-2 | Vercel | **신규 프로젝트 `ondo-web`, Root = `apps/web`.** 기존 `zpzg-landing` 은 롤백용 30일 보존 | 같은 프로젝트에서 Root 를 옮기면 root `vercel.json` 의 AASA/assetlinks Content-Type 과 `/privacy` rewrite 가 동시에 죽는다 |
| A-3 | Edge 호출 | 브라우저에서 `supabase.functions.invoke` 직접 호출 기본. Route Handler 는 5개 예외만 | `_shared/cors.ts` 가 이미 `'*'` + supabase-js 가 보내는 정확히 그 4개 헤더 허용 → 백엔드 수정 0 |
| A-4 | 커스텀 헤더 | **`x-request-id` 를 절대 보내지 않는다** | `free-chat/index.ts:231` 등이 읽지만 어떤 `Access-Control-Allow-Headers` 목록에도 없어 preflight 실패 |
| A-5 | 인증 | `@supabase/ssr` 쿠키 세션 + PKCE, Bearer access token 계약은 모바일과 동일 | 89개 함수 전부 `supabase.auth.getUser(token)` 로 서버측 uid 유도 — transport 무관 |
| A-6 | 인가 위치 | `middleware.ts` 는 **세션 리프레시만**, 인가는 `app/app/layout.tsx` 의 `getUser()` | middleware 는 쿠키만 보고 서명 검증을 하지 않아 게이트로 신뢰 불가 |
| A-7 | 게스트 | `signInAnonymously()` + **`grant_initial_tokens` 분기 마이그레이션 선행 필수** | `20260503192000_signup_bonus_50.sql:11` 이 `v_initial_tokens INT := 50` 무조건, 트리거는 `AFTER INSERT ON auth.users` → **익명도 50토큰**. 시크릿창 = Heavy 티어 사주 4회 무료 |
| A-8 | 스트리밍 | **v1 없음.** `segments[]` + `delaySec` 순차 렌더 | 89개 함수 전체에 `text/event-stream`/`ReadableStream` 0건이고, 끊어 보내는 페이싱이 제품 컨셉 자체 |
| A-9 | 렌더 계약 | 신규 패키지 `packages/fortune-render-contracts` 로 RN-free 순수 TS 승격, mobile 은 re-export shim | 복붙하면 `manseryeok-interpret/types.ts` 하드코딩 중복이 3벌로 늘어난다 |
| A-10 | 테마 | **웹도 dark-only.** `[data-theme]` 블록 미생성 | `createFortuneTheme('light')` 호출부 0건, `fortuneReadingPalette`(23곳)에 light 대응 없음 |
| A-11 | 비동기 job | **v1 에서 사용하지 않음. `job-status` 폴링 엔드포인트를 만들지 않는다** | `start-long-running-job` 은 RN 앱도 호출하지 않는다(grep 0건). 타로는 `edge-runtime.ts:308` 에서 동기 `/fortune-tarot` 로 나간다 — 존재하지 않는 경로를 위한 신규 함수는 낭비 |
| A-12 | Node | **20.x 유지.** 토큰 codegen 은 타입 스트리핑 없는 `.mjs` 로 작성 | `.github/workflows/ci.yml:27,59` 가 `'20.x'`. `--experimental-strip-types` 는 22.6+ → CI 게이트가 첫날 깨진다 |

### 5.2 URL 스킴 — 한글 slug 확정, 앱 서피스는 **실제 경로 접두사**

```
✅ /운세/오늘 · /운세/오늘/띠별/호랑이 · /사주 · /궁합/띠/호랑이-토끼
❌ /fortunes/daily/zodiac/tiger
```

제품이 한국어 전용이고(48개 카탈로그 항목 전부 한국어, `<html lang="ko">`), SERP 볼드 하이라이팅과
카카오 링크 프리뷰에 직접 기여한다. 로마자 slug 는 어떤 쿼리와도 매칭되지 않는다.

**초안 오류 수정 — 라우트 그룹은 URL 에 나타나지 않는다.**
`app/(app)/chat/page.tsx` 는 `/chat` 으로 서빙되므로 `robots.txt` 의 `Disallow: /app/*` 가 아무것도 매칭하지 않는다.
→ 인증 서피스는 **실제 경로 세그먼트**를 쓴다: `app/app/chat/page.tsx` → `/app/chat`.

### 5.3 디렉토리 (요약)

```
apps/web/
  next.config.ts        transpilePackages 4종 + .well-known Content-Type headers()
  middleware.ts         updateSession 만
  public/.well-known/   AASA · assetlinks (public/ 에서 바이트 동일 복사)
  public/fonts/         ZenSerif subset woff2 + NotoSerifKR 한자 ~60자 subset
  src/styles/tokens.css ← codegen 산출물, 직접 편집 금지
  app/
    (marketing)/  운세/… 사주/ 궁합/ 가격/ 다운로드/      ← SSG, 인덱싱 대상
    (legal)/      privacy terms support 사업자정보         ← docs/legal/*.md 단일 소스 렌더
    app/          chat/ f/[fortuneType]/ 결과/ 마이/ 결제/  ← 실제 /app/* 경로, noindex
    auth/callback/route.ts
    api/ guest/start · checkout/session · webhooks/payments · flags · signout
    sitemap.ts robots.ts opengraph-image.tsx
```

### 5.4 모노레포 배선 (전부 M1 PR 안에서)

| 파일 | 변경 | 근거 |
|---|---|---|
| `apps/web/tsconfig.json` | `moduleResolution: "bundler"` + `allowImportingTsExtensions: true` | `saju-engine` 은 `'./types.ts'` 확장자 import, `product-contracts` 는 확장자 없는 import — 이 조합만 둘 다 통과 |
| `apps/web/next.config.ts` | `transpilePackages` 4개 | 4개 패키지 모두 `main`/`types` 가 raw `./src/index.ts`, build script·exports 맵 없음 |
| `pnpm-lock.yaml` | 같은 PR 에서 재생성 | 모든 CI job 이 `--frozen-lockfile` |
| `apps/mobile-rn/metro.config.js` | `blockList` 에 `apps/web/.next`, `apps/web/node_modules` | `watchFolders: [workspaceRoot]` 라 Metro 가 크롤 |
| `.easignore` | `apps/web` 추가 | 현재 미제외 → EAS 빌드마다 업로드 |
| `.vercelignore` (신규) | `namuwiki*.7z`(88MB/38MB) 제외 | |
| `scripts/sync-web-tokens.mjs` (신규) | `packages/design-tokens/src/css.ts` → `apps/web/src/styles/tokens.css`. `check:web-tokens` 를 CI 게이트로 | `check:edge-pricing` 과 동일 사상. **`.mjs` 인 이유는 A-12** |
| `playwright.web.config.js` (신규) | port **3100**, `testDir: playwright/tests/web` | 3000 은 `rn:web:export` 전용 — 기존 게이트를 건드리지 않는다 |
| `firebase.json` | 삭제 | `.firebaserc` 없음, 배포 워크플로 없음, SPA catch-all `** → /index.html` 이 Next 에 유해 |
| `.github/workflows/playwright.disabled` | 삭제 | RN 이전 시대 Next 파이프라인 잔재 |

**철칙: `SUPABASE_SERVICE_ROLE_KEY` 를 `apps/web` / Vercel 에 절대 두지 않는다.** 모든 권한 작업은 Edge Function 에 남는다.

### 5.5 스타일 — 웹 전용 보정

| 항목 | 조치 |
|---|---|
| `fontFamily: 'System'` (`app-text.tsx:29`) | RN sentinel 이라 CSS 에서 무의미. `'Pretendard Variable', -apple-system, 'Apple SD Gothic Neo', 'Noto Sans KR', sans-serif` 로 교체 |
| **ZenSerif 한자 커버리지 0** | cmap 11,942자 중 U+4E00–9FFF **0개**. 만세력 도장(甲丙子午)·오행(木火土金水)이 브라우저별 fallback 으로 깨진다 → 천간10+지지12+오행5+여분 ≈60자 Noto Serif KR 서브셋 동봉. **OG 이미지 렌더러에도 동일 적용** |
| ZenSerif 단일 굵기(400) | `oracleTitle`(700) 등이 가짜 볼드 → **웹은 serif 계열에서 700 이상을 쓰지 않는다**. 크기·자간으로 위계 |
| `caption` 11px / `bodySmall` 14px | 데스크톱 가독성 하한 미만 → `@media (min-width: 768px)` 로 12/15px, line-height 1.6 |
| `fortuneShadows` | 변환하지 않는다 (RN 전용 키, 소비자 0건). 웹 그림자는 새로 디자인 |

---

## 6. 운세 서피스

### 6.1 SEO 공개 vs 게이팅

| 구분 | 처리 |
|---|---|
| 공개 SSG | 입력이 **공개 열거값**이고 개인정보 0인 것만: 띠 12 · 별자리 12 · MBTI 16 · 혈액형 4 · 일주 60갑자 · 궁합(띠/별자리) |
| 카탈로그 랜딩 | `FORTUNE_CATALOG` **48개** (`sed -n '69,144p' packages/product-contracts/src/fortune-catalog.ts \| grep -c "^  { id:"` = 48. 초안의 59는 그룹 11개를 포함한 오류) |
| 게이팅 + noindex | 생년월일시·성별·사진이 입력인 나머지 전부. `/app/*` 전 라우트 |

**`/사주` 만세력 계산기가 전략적으로 가장 중요하다.** `packages/saju-engine`(런타임 의존성 0)을 Next 서버에서 직접
실행하면 **LLM 비용 0 · 토큰 0 · 로그인 0** 으로 진짜 4주를 뽑는다. Deno Edge Function 은 이 패키지를 import 할 수
없어 타입을 손으로 복제하고 있다(`manseryeok-interpret/types.ts:4` 에 명시) — **웹만 가진 능력이자 백링크가 붙는
유일한 페이지 유형**이다.

### 6.2 v1 포팅 범위 — 동기 · 비이미지 12종

`daily`, `traditional-saju`, `love`, `compatibility`, `tarot`, `dream`, `zodiac-animal`, `mbti`, `wealth`, `career`, `biorhythm`, `lucky-series`

**명시적 컷 (v1 제외)**: `inputKind:'image'` 10개 스텝 전부 + `OndoPosterGuideResult` 포스터형 6종
(beauty-simulation / hair-style-guide / face-reading-guide / ootd-guide / blind-date-guide / past-life-guide)
+ palm-reading / face-reading / ootd-evaluation. 카메라 의존 + 25~50 토큰 최고가 티어 + 완료 통보가 push 전용.
이 9종을 빼면 **비동기 job 경로 자체가 v1 범위에서 사라진다**(A-11).

### 6.3 프로그래매틱 콘텐츠 — 단계 발행

초안은 544페이지 일괄 발행이었다. Google 의 대규모 콘텐츠 남용 정책 대상이고,
**같은 도메인에 스토어 심사 URL(`/privacy`, `/support`)과 `.well-known/AASA` 가 함께 산다** — 도메인 단위
수동조치가 들어오면 딥링크 검증과 스토어 메타데이터까지 반경에 들어간다.

**결정: 50 → 150 → 300 단계 발행.** 각 단계마다 GSC 색인/노출 추이를 확인한 뒤 다음 단계로 간다.

품질 게이트 5종(전부 강제):
1. **요청당 LLM 호출 금지.** `seo_content(slug, content_date, …)` 테이블 + `seo-daily-content` cron(`worker_auth`)이
   `(slug, date)` 단위 1회 생성, Next 는 ISR 로 읽기만 → 방문자당 LLM 원가 0
2. 페이지 차별화는 LLM 문장이 아니라 **saju-engine 결정론적 계산 블록 3종**(오늘 일진 60갑자 / 오행 상생상극 / 30일 흐름)
3. 형제 페이지와 trigram 중복률 > 0.6 이면 재생성, 2회 실패 시 **발행하지 않고 cron 을 실패시킨다**
4. 페이지마다 변하지 않는 **사람이 쓴 설명 축 ≈300자**
5. 당일 row 가 없거나 2일 이상 stale 이면 `noindex`

**금지: `Review` / `AggregateRating` JSON-LD.** 실제 리뷰가 없다 — 구조화 데이터 수동조치 위험.

---

## 7. 수익 모델 · 결제

### 7.1 PG — 토스페이먼츠 단독

개인사업자 단독 계약 가능 + 결제위젯 하나로 카드/계좌이체/간편결제 커버 + **빌링키(자동결제)가 1급 기능**.
Stripe 는 Phase 2 해외카드 전용(*확인 필요: 2026 현재 한국 사업자 정식 지원 여부*).
포트원은 PG 2곳 이상일 때 가치가 나오는 중간 레이어 — 단일 PG 런칭에서는 장애 지점만 늘린다.

### 7.2 통합 원장 — SKU 네임스페이스 분리하지 않는다

**초안 3개 섹션이 서로 다른 답을 냈던 항목. 확정: 기존 `com.beyond.fortune.*` 를 웹에서도 그대로 쓰고 `platform` 컬럼이 채널을 구분한다.**
웹 전용 SKU 를 만들면 `packages/product-contracts/src/subscription-iap-contract.test.ts:44` 의
`com.beyond.fortune.` 접두 정규식이 웹 SKU 를 조용히 무시해 **화이트리스트 드리프트 가드가 죽는다**.

단, 그 테스트는 `payment-verify-purchase/index.ts` 와 `subscription-activate/index.ts` **두 파일만** 읽으므로,
신규 웹 함수를 커버하도록 확장해야 한다 — "웹 함수는 `product-catalog-generated.ts` 만 import 하고 자체 상품/토큰 맵을 선언하지 않는다"를 단언.

| 웹 결제 | 기록 | RPC | reference_id | idempotency_key |
|---|---|---|---|---|
| 토큰 패키지 | `verified_purchases(platform='web')` → `token_transactions` | `grant_purchase_tokens_atomic` | Toss `paymentKey` | `purchase:web:<paymentKey>` |
| 구독 최초 | + `subscriptions` | `activate_subscription_purchase_atomic(p_platform='web')` | 1회차 `paymentKey` | `subscription:web:<paymentKey>` |
| 정기 갱신 | 동일 row 연장 | **신규** `renew_web_subscription_atomic` | 회차 `paymentKey` | `subscription:web:<cyclePaymentKey>` |
| 환불/차지백 | 보상 트랜잭션 | **신규** `revoke_purchase_tokens_atomic` | 원 `paymentKey` | `chargeback:web:<paymentKey>` |

기존 인덱스가 그대로 replay 를 막는다: `idx_token_transactions_purchase_global_unique`,
`idx_verified_purchases_global_replay` (둘 다 `20260515044500_purchase_iap_global_idempotency.sql`).

**하드 선행조건**: `20260505130000_verified_purchases.sql` 의 `CHECK (platform IN ('ios','android'))` →
`('ios','android','web')`. 안 고치면 `activate_subscription_purchase_atomic` 이 `VERIFIED_PURCHASE_NOT_FOUND` 를
raise 하므로 **웹 구독이 물리적으로 불가능**하다.

### 7.3 신규 Edge Function 4종

| 함수 | 인증 | 책임 |
|---|---|---|
| `payment-web-checkout` | JWT | **금액 권한을 서버가 독점** — `web_payment_orders` 에 서버가 읽은 가격으로 INSERT. 클라는 금액을 보내지 않는다. 구독이면 `status='active' AND expires_at > now()` 인 타 platform 구독 존재 시 409 |
| `payment-web-confirm` | JWT | 저장 금액과 불일치 시 400 → Toss `/v1/payments/confirm` → `verified_purchases` INSERT → 기존 RPC 호출 |
| `payment-web-webhook` | `verify_jwt=false` | **body 를 절대 신뢰하지 않는다.** body 는 트리거로만 쓰고 `GET /v1/payments/{paymentKey}` 재조회 결과만 권위. `web_payment_webhook_events(event_id PK)` 로 멱등 |
| `subscription-web-renew` | `worker_auth` | pg_cron 03:00 KST. `next_charge_at = expires_at - 3d` 로 D-3 선결제 → 3일 유예를 구조적으로 확보. dunning 상태는 `subscriptions.status` 가 아니라 `web_billing_subscriptions.retry_count` 에만 둔다(readers 가 `.eq('status','active')` 를 쓰므로) |

`web_billing_subscriptions` 는 **self-read RLS 를 주지 않는다** (service_role only) — 빌링키는 클라이언트에 절대 노출 금지.

**추가로 필요 — 스토어 환불 핸들러 (초안 누락).** App Store Server Notifications v2 / Google RTDN 핸들러가
리포에 0건이다. 웹과 IAP 가 **하나의 잔액**을 공유하는 순간 "IAP 로 사서 → 소비 → Apple 환불 → 잔액 유지"가
세탁 경로가 된다. `revoke_purchase_tokens_atomic` 을 호출하는 스토어 알림 핸들러를 §9 M3 에 포함한다.

### 7.4 웹 가격 — 표시가 패리티 + 토큰 +20%

**가격을 낮추지 않는다.** 웹 표시가를 10% 내리면 ₩9,900 상품 기준 ₩990 손실이지만,
같은 체감가치를 토큰 +20%(80토큰)로 주면 COGS 는 80 × ₩1.13 = **₩90** — **11배 저렴한 레버**.
동시에 anti-steering 리스크가 0 이 되고 앱 사용자가 "속았다"고 느낄 여지도 없앤다.

| 상품 | 표시가 | iOS 실수령 | Web 실수령 | 웹 보너스 | 보너스 후 |
|---|---:|---:|---:|---:|---:|
| Starter 30 | ₩1,100 | ₩850 | ₩964 | +6 | ₩957 |
| Basic 150 | ₩4,400 | ₩3,400 | ₩3,855 | +30 | ₩3,821 |
| Popular 400 | ₩9,900 | ₩7,650 | ₩8,673 | +80 | ₩8,583 |
| Heavy 1000 | ₩22,000 | ₩17,000 | ₩19,274 | +200 | ₩19,048 |
| Pro 구독/월 | ₩9,900 | ₩7,650 | ₩8,673 | — | ₩8,673 |
| **Pro 연간 (웹 전용)** | ₩99,000 | — | ₩86,734 | — | ₩86,734 |

전제: iOS = 표시가 ÷ 1.1 × 0.85(Small Business) = ×0.7727 / Web = ÷1.1 − 3.3% PG = ×0.8761 → **웹 +13.4%**.
토큰 COGS ₩1.13 (`.claude/docs/22-business-model.md` 의 "200토큰 ≈ ₩226").

**⚠ 이 +13.4% 는 "웹 체크아웃 전환율이 앱 IAP 와 동등"을 암묵 가정한다.**
앱은 Face ID 한 번, 웹은 카드 입력 + 3DS + 청약철회 동의 체크박스 2개다.
**웹 체크아웃 전환율이 앱 대비 약 12% 낮아지면 +13.4% 우위는 전부 사라진다.**
→ M3 직후 실측 검증 항목으로 등록한다. 토큰 +20% 보너스는 이 완충을 더 깎으므로, 전환율 실측 후 재조정한다.

**BM 문서 불일치**: `.claude/docs/22-business-model.md` §2 의 iOS 실수령(Lite ₩3,749 / Pro ₩7,574 / Max ₩15,224)이
위 계산(₩3,400 / ₩7,650 / ₩14,681)과 어긋난다. 어느 쪽이 맞는지 확정해 한 값으로 통일한다.

### 7.5 웹 Free 티어 손익 — 부호가 뒤집힌다 (초안 누락)

`.claude/docs/22-business-model.md` §3 은 Free 티어가 흑자라고 명시한다 —
"1K DAU 기준 광고 매출 +₩636K vs LLM 비용 ₩94K = **+₩542K 흑자**".
**그 흑자의 원천은 전액 AdMob 이고, 웹에는 리워드 광고가 없다.**
즉 앱 무료 유저는 순매출 +, **웹 무료 유저는 100% 순비용**이다.

**결정:**

| 항목 | 웹 정책 | 강제 방법 |
|---|---|---|
| 익명 게스트 초기 토큰 | **5** (정회원 50) | `grant_initial_tokens()` 를 `NEW.is_anonymous` 로 분기. Mid 티어(5) 1회 = 타로/연애/궁합 — 유입 의도 최상위 3종. Heavy(12)/Premium(25)/Ultra(50) 는 게스트가 도달 불가 → **이미지 생성 비용이 게스트에게 새지 않는다** |
| 게스트 → 정회원 전환 | +45 보정 (합계 50) | `AFTER UPDATE OF is_anonymous` 트리거 + `idempotency_key = 'conversion:<uid>'` |
| 익명 게스트의 캐릭터 채팅 | **금지** | `is_anonymous` 기준 서버측 차단. 스트릭 사다리(30/100/200/400 msg/일)는 광고가 비용을 대는 네이티브 전제이며, 클라가 보내는 채널 값은 위조 가능해 플랫폼별 게이트는 강제 불가 — `is_anonymous` 만이 서버에서 검증 가능한 경계다 |
| 정회원 스트릭 채팅 | 웹/앱 동일 | 같은 사용자를 채널로 나눌 정직한 방법이 없다. **대신 월간 무료 LLM 비용 예산 알람을 걸고 임계 초과 시 재검토** |
| 고아 익명 계정 | **주 1회 정리 cron** | 게스트 클릭마다 `auth.users` + `token_balance` 행이 영구 생성된다. 미전환 + 7일 무활동 익명 계정을 삭제. `kakao-oauth/index.ts:145` 가 `auth.admin.listUsers()` 전수 스캔이라 방치하면 **웹 트래픽이 네이티브 카카오 로그인을 느리게 만든다** |

**추가 산출물**: `.claude/docs/22-business-model.md` 에 **광고 매출 0 을 가정한 웹 Free 손익 컬럼**을 신설하고,
"웹 무료 1인 월 LLM 비용 × 무료:유료 비율"이 웹 결제 매출을 넘지 않는 무료 한도를 명시한다.

### 7.6 한국 법령

| 항목 | 조치 |
|---|---|
| **통신판매업 신고** | §1.2-1. 웹 결제의 하드 선행조건 |
| **전자상거래법 제10·13조 표시사항** | 신규 `/사업자정보` 페이지 + 전 페이지 푸터: 상호(비욘드) / 대표(김인주) / 주소(서울 서초구 효령로23길 54-6, 201호) / 이메일 / 사업자등록번호(552-20-02389) / **통신판매업신고번호** / 개인정보보호책임자 / 호스팅 제공자. 현재 `public/*.html` 어디에도 없다 |
| **청약철회 (제17조)** | `docs/legal/TERMS_OF_SERVICE_CONTENT.md:76` 의 "구매한 토큰은 환불되지 않습니다"는 **무효 소지**. 제6항상 ①제한 사실 명시 ②시험 사용 기회 없이는 제한이 성립하지 않는다 |
| ↳ **원장으로 평가 가능한 규칙으로 재작성** | 초안의 "해당 구매분 토큰 미사용"은 **현재 원장으로 계산 불가**하다 — 소비 트랜잭션이 어느 구매분에서 나갔는지 태깅하지 않는다. → **"결제 후 잔액이 한 번도 구매 수량 아래로 내려간 적이 없으면 전액 환불, 내려갔으면 최저점 기준 사용분 차감"**. `token_transactions.balance_after` 이력으로 계산 가능 |
| 결제 화면 필수 체크박스 2개 | (1) 주문내용 확인·결제 동의 (2) 디지털콘텐츠 즉시 이용 개시 및 청약철회 제한 동의 |
| **자동갱신 사전고지** | `PRIVACY_POLICY_CONTENT.md:275` 의 "24시간 전"은 Apple 규칙을 옮긴 값. 한국 콘텐츠이용자보호지침 권고는 **7일 전** → D-7 이메일 + D-0 영수증 |
| **개인정보처리방침** | 수탁자에 **토스페이먼츠(주)** 추가, 처리항목에 결제정보(카드사명/승인번호/결제수단/금액/**빌링키 식별자**) 추가, 카드번호 원문 미보관 명시 |
| 영수증 | 카드는 매출전표 갈음. **계좌이체·가상계좌는 현금영수증 발급 필요** — 토스 API 자동발급 켜고 마이페이지에 신청 경로 |
| **법률 문서 파편화 정리** | 현재 5곳(`public/*.html` 라이브·stale / `docs/*.html` / `docs/legal/*.md` / `legal-pages` Edge Function / RN 화면)에 흩어져 **이미 서로 다르다**. `docs/legal/*.md` 를 단일 원본으로 확정하고 `apps/web` 이 렌더, 나머지는 리다이렉트/삭제. 부수: `TERMS_OF_SERVICE_CONTENT.md:95,195` 의 `supportsupport@zpzg.co.kr` 오타 수정 |

### 7.7 Apple / Google anti-steering

- (확실) 2025-04-30 Epic v. Apple contempt 판결의 무수수료 링크아웃은 **미국 스토어프론트 한정**. 한국 미적용.
- (확실) 한국 전기통신사업법의 **앱 내 제3자 결제**는 Apple 26% / Google UCB 로, 현재 적용 중인 Small Business 15% 보다 **불리하므로 추진하지 않는다**.
- (확실) Guideline 3.1.3(b) Multiplatform Services 는 "다른 곳에서 구매한 콘텐츠를 앱에서 이용"을 허용한다.
- (**확인 필요**) 2026 시점 Apple 의 미국 규칙이 KR 스토어프론트로 확장됐는지 / Google Play 의 KR 링크아웃 정책 현황.

**RN 앱이 지켜야 할 최소선 (엔타이틀먼트 신청 없이 안전):**
허용 — 웹 구매분을 앱에서 사용, `token-balance`/`subscription-status` 를 채널 표시 없이 노출, 웹 → 앱 유도.
**금지 — `premium-screen.tsx`/`premium.tsx` 에 웹 가격·"웹이 더 저렴"·`zpzg.co.kr/pricing` 링크·외부 브라우저 오픈 버튼.
앱 내 행동에서 파생된 푸시로 웹 결제 유도. 스토어 설명·스크린샷의 웹 가격 언급.**

→ **설계 함의: 획득 퍼널 전량을 웹 자체(검색/SNS/광고)에서 만들어야 한다.** 이것이 §6.3 SEO 선투자를 정당화한다.

---

## 8. 획득 퍼널

### 8.1 첫 방문 — 30초 안에 가치

```
[SSG 페이지 도착]              인증 0 · LLM 0 · 즉시 읽을 콘텐츠 존재
   ↓
[3필드 입력]                  생년월일(필수) / 태어난 시간(선택, 기본 "모름") / 성별(선택)
   ↓                          ← 이 3개가 profile-completion-bonus(+5) 조건을 동시에 선충족
[익명 세션 + 무료 daily 결과]   soul-consume(daily) 무료 경로 재사용   ★ <30s 지점
   ↓
[결과 카드 하단 2 CTA]  ┬ 「결과 저장 + 내일 알림」 → 가입 벽 A
                        └ 「다른 운세 보기」        → 가입 벽 B
   ↓
[가입 = linkIdentity(kakao) — 같은 user.id 유지, 잔액·이력 승계]
   ↓
[+45 전환 보정 → 50토큰] → Mid 티어 체험 → 결제 벽
```

**무료 훅은 `daily` 고정**: `soul-consume/index.ts:113-157` 이 `daily_free_fortune`(UNIQUE(user_id, used_at))로
**서버에 이미 존재하는 유일한 무과금 경로**이고, 원가 1토큰 최저 티어이며, `birthDate` 하나로 결과가 난다.

**가입 벽은 첫 결과 뒤**: `resolveChatOnboardingGate` 가 비로그인에 무조건 `'ready'` 를 주고 그 위에
"Apple Guideline 5.1.1(v)" 주석이 달려 있다. 웹이 이 정책을 깨면 네이티브/웹 정책이 갈라지고 심사 포지션이 흔들린다.

**전환이 무손실인 이유**: `updateUser({email})` / `linkIdentity()` 는 `auth.users.id` 를 보존한다.
`token_balance`·`token_transactions`·`character_conversations` 가 전부 `user_id` 로 묶여 있어 **마이그레이션 코드 0줄로 승계**된다.

**익명 파밍 방어**: (1) Turnstile — Supabase Auth CAPTCHA(대시보드 설정, §1.2-3),
(2) `/api/guest/start` 서버 choke point 에서 IP 해시 스로틀(1시간 5회, `guest_signup_throttle`),
(3) 게스트 5토큰 상한, (4) §3 의 서버측 과금. **(4) 가 없으면 (1)(2)(3) 은 전부 무의미하다** — 세션 없이도 뚫린다.

### 8.2 검색 채널 — 명시적 전제

**이 SEO 계획은 Google 유입만 대상으로 하며 네이버 유입은 0 으로 가정한다.**
운세/사주는 네이버 SERP 상단을 네이버 자체 서비스와 광고가 점유하는 카테고리이고, 외부 도메인 문서가 그 자리를
가져가는 경로는 Google 과 완전히 다르다. 네이버는 서치어드바이저 등록만 하고 별도 트랙으로 다루지 않는다.
네이버 유입이 필요하다고 판단되면 **별도 계획이 필요하다**(네이버 내부 서피스 활용).

**M1 착수 전 1페이지 경쟁 점검 (필수)**: 목표 키워드 상위 10개("오늘의 운세", "무료 사주", "궁합", "띠별 운세" 등)의
현재 1페이지 점유자, 그들의 도메인 나이·브랜드 검색량 대비 우리 차별점(만세력 결정론 계산)이 실제 순위 요인이 되는지.
결과로 **경쟁 불가 키워드군을 페이지 목록에서 제거**한다. zpzg.co.kr 은 백링크·브랜드 검색량이 사실상 0인 신규 도메인이다.

### 8.3 손익분기 트래픽 (초안 누락)

퍼널 목표를 곱하면 랜딩→유료 = 25% × 90% × 12% × 2% = **0.054%**.
웹 실수령 ₩8,673(Popular) 기준 월 유료 100명 = 월 ₩867K → 필요 랜딩 세션 **월 약 18.5만**.

**이 숫자를 M1 프로브의 판정 기준으로 쓴다.** 20페이지 3주 실측에서 페이지당 월 세션 하한이
이 궤도에 오르지 못하면 SEO 가 아닌 다른 획득 채널로 계획을 다시 짠다.

### 8.4 웹 리텐션 채널 — 채팅과 **동시** 출시 (초안 누락)

웹에는 사용자를 다시 부르는 장치가 0개다(push 종단이 전부 Expo). 이 상태로 리텐션 기반 킬스위치를 돌리면
"웹이 안 된다"인지 "리텐션 장치 없이 배포했다"인지 구분할 수 없다.

**v1 최소안: 이메일 다이제스트 ("내일의 운세")** — Resend 등 발송 서비스 필요(§1.2-6).
결제 영수증·자동갱신 D-7 고지와 같은 인프라를 쓰므로 어차피 필요하다.
카카오 알림톡/친구톡(비즈메시지)은 한국 웹에서 실질적으로 작동하는 후보이나 별도 심사가 필요해 v1 이후.

**웹 푸시는 도입하지 않는다**: `_shared/notification_push.ts` 가 모든 토큰을 `exp.host` 로 보내므로
브라우저 PushSubscription 을 `fcm_tokens` 에 넣으면 쓰레기를 전송한다.

### 8.5 계측

| 소스 | 담당 |
|---|---|
| GA4 + GSC | 획득 표면만 (pageview / scroll / CTA 클릭). GSC 연동이 오가닉 쿼리→랜딩을 잇는 유일한 무료 경로 |
| **서버측** `analytics_events` + `analytics-ingest` | 토큰·결제·가입. **브라우저 SDK 를 진실의 원천으로 두지 않는다** (광고 차단 유실 + 조작 가능) |

Mixpanel 은 채택하지 않는다 — 배선만 되고 `analytics.ts:trackEvent` 가 no-op 이라 매몰비용 0.

필수 신규 이벤트: `web_landing_view`, `web_input_submit`, `anon_session_created`, `first_result_view`,
`signup_wall_view`, `identity_linked`, `profile_bonus_granted`, `paywall_view`, `checkout_start`,
`share_click`, `share_view`. 기존 `sign_up`/`token_consumed`/`purchase` 에 props 추가.

**계약 변경 (전부 additive)**: `packages/product-contracts/src/analytics.ts` 의 `analyticsEventNames` 확장,
`feature-flag-exposure-log/index.ts:26-38` 의 `ALLOWED_SURFACES` 에 `web_landing`/`web_result`/`web_paywall` 추가
— **없으면 웹 플래그 노출 로그가 에러 없이 `invalid` 로 조용히 버려진다**(A/B 결과가 통째로 사라진다).

---

## 9. 통합 로드맵 — 단일 백로그, 단일 일정

> 이전 초안은 growth W1–W12 와 migration M0–M7 이 **같은 캘린더를 서로 다른 작업으로 이중예약**했다.
> 아래가 유일한 일정이며, 두 초안의 산출물을 모두 포함한다.

| # | 마일스톤 | 공수 | 게이트 |
|---|---|---:|---|
| **P0-A** | 원장·권한 하드닝 (§2) | **4d** | 감사 스크립트 exit 0 + 함수 ACL 단언 + `authenticated` 로 세 RPC 호출 시 42501 |
| **P0-B** | 서버측 과금 게이트 (§3) | **6d** | anon key 직접 호출 401 · 동일 요청 2회에 과금 1회 + 캐시 반환 · RN 회귀 없음 |
| **M1** | 수요 프로브 + 웹 기반 | **10d** | `verify_deep_links.sh` PASS(라이브) · 20 URL 200 · GSC 소유확인 · 랜딩→결과 p75 ≤30s 실측 |
| ↳ | **3주 오가닉 관찰** | — | **노출이 붙지 않으면 M2 착수하지 않고 획득 채널 재설계** |
| **M2** | 운세 확장 12종 + 결과 카드 | **8d** | 12종 table-driven 렌더 spec |
| **M3** | 웹 결제 + 법률 페이지 | **10d** | 샌드박스 E2E · 웹훅 2회 replay 시 잔액 불변 · 타 계정 paymentKey 재사용 거부 |
| **M4** | 공유 루프 + 이메일 리텐션 + 초대 | **6d** | 카카오 실기기 카드 2버튼 · 동일 초대 2회 클레임 차단 |
| **M5** | 웹 채팅 (**조건부**) | **9d** | 전송→답장→새로고침 히스토리 유지 + 토큰 1 차감 |
| **M6** | 하드닝 | **6d** | 비허용 Origin 차단 · 환불/차지백 시나리오 spec |
| | **합계** | **59d ≈ 솔로 12주** | |

### M1 — 수요 프로브 + 웹 기반 (10d)

**가장 불확실한 가정을 가장 먼저 검증한다.** 이전 초안은 31 dev-day 를 쓴 뒤에야 "검색으로 사람이 오는가"를
시험했고, 킬스위치가 M6+30일(전액 소진 후)이라 사후 부검이었다.

산출물:
- `apps/web` 스캐폴드 (§5.4 배선 전부 포함, 같은 PR)
- 한글 slug 라우터 + **20페이지**: `/운세/오늘`, 띠별 12, `/사주` 만세력 계산기, 랜딩, 가격, 법률 4
- `.well-known` 이관 + `next.config.ts` `headers()` Content-Type 재선언
- 3필드 게스트 훅 + `signInAnonymously` + Turnstile + IP 스로틀 + `soul-consume(daily)` + `fortune-daily` + 결과 카드
- `grant_initial_tokens` is_anonymous 분기 마이그레이션 + 전환 보정 트리거 + 고아 계정 정리 cron
- `analytics_events` + `analytics-ingest` + 퍼널 이벤트
- GSC / 네이버 서치어드바이저 / GA4 등록
- **도메인 컷오버**: apex + www DNS → `ondo-web`. `zpzg-landing` 30일 보존

⚠ **apex/www 리다이렉트를 도입하지 않는다.** `scripts/verify_deep_links.sh` 는 어떤 리다이렉트도 하드 실패시키고
`assetlinks.json` 에 `application/json` 을 요구한다(`scripts/remove_vercel_apex_redirect.sh` 가 존재하는 이유).
canonical 은 `<link rel="canonical">` 로 apex 지정. www→apex 301 을 원하면 `/.well-known/*` 예외를 정확히 구현해야 한다.

### M2 — 운세 확장 (8d)
12종 결과 카드. `react-native-svg` 사용 hero(`hero-saju`/`hero-love`/`hero-line`/`hero-zodiac`/`hero-gauge`/`score-dial`)는
`Svg/Path/Circle/G` → `svg/path/circle/g` 1:1 치환. `result-card-frame.tsx`(659 LOC, 4-phase reveal)는 CSS `@keyframes` 재작성.
`seo_content` cron + 계산 블록 3종 + trigram 게이트 → 50페이지 발행.

### M3 — 웹 결제 (10d, PG 승인 선행)
§7.3 의 4개 함수 + 스토어 환불 핸들러 + 신규 마이그레이션 + §7.6 법률 페이지 전부.
`sync-edge-products.sh` + 계약 테스트 확장. 통신판매업 신고번호가 나와야 법률 페이지가 완성된다.

### M4 — 공유 + 리텐션 (6d)
`shared_results` + `/공유/{id}`(경로에 id — 카카오 스크래퍼가 URL 단위로 OG 를 공격적 캐싱) + OG `ImageResponse`
(한자 서브셋 폰트 embed) + Kakao JS SDK(결과/공유 화면에서만 `defer`, SSG 페이지에는 금지 — LCP 보호)
+ 이메일 다이제스트 + `referrals` + `grant_referral_tokens_atomic`(+5/+5, 피초대자 프로필 완성 게이트).
**초대 리워드는 신규 토큰 faucet 이므로 `/ultrareview` 필수.**

### M5 — 웹 채팅 (9d, 조건부)
착수 조건: M1~M4 의 웹 가입·결제 지표가 §10 임계값을 넘을 것.

- 히스토리는 `character-conversation-load`/`save` 만 사용. `chat-db.ts`(expo-sqlite, "native 전용" 명시)는 포팅 금지
- `merge_character_conversation_messages`(`20260504000001`)가 advisory lock + message id dedup + cap 트림이라
  **웹/폰 동시 사용이 안전하고 히스토리가 자동 통합된다. 네이티브 수정 불필요**
- **자동 재시도 금지** — `character-chat` 은 멱등키를 받지 않는다. 브라우저는 탭 전환/백그라운드 종료가 잦아 RN 보다 위험
- ⚠ **`CHARACTER_CHAT_SCHEDULED_REPLIES_ENABLED` 는 웹 트랙 수명 동안 `false` 를 유지한다.**
  `character-chat/index.ts:3818-3874` 는 이 플래그가 `true` 면 `scheduled_character_replies` 행을 쓰고 즉시 푸시를
  억제하지만 **인라인 `response` 는 그대로 반환한다** → 즉시 렌더하는 웹은 cron 이 같은 텍스트를 배달하는 순간
  **메시지가 중복**된다. 플래그를 켜려면 웹이 `ack-scheduled-reply` 를 보내야 한다
- ⚠ `character-chat` 은 `characterId`/`systemPrompt`/`userMessage` 가 없으면 400 이고, 페르소나 텍스트는
  **클라이언트가 조립한다**(`chat-screen.tsx:3645-3665` + `story-romance-pilots.ts` 604 LOC + `character-persona-store.ts`
  + `character-details.ts` + `story-chat-runtime.ts`). 파일 1개(`system-prompt.ts`)로 끝나지 않는다 — 9d 의 상당 부분이 여기다
- ⚠ `chat-screen.tsx:3673-3690` 의 `enqueue_pending_reply_job` RPC 가 **클라이언트가 죽어도 답장이 살아남는 유일한 장치**다.
  재시도를 금지하면서 이 큐를 포팅하지 않으면 브라우저에서 답장 유실이 RN 보다 잦아진다

### M6 — 하드닝 (6d)
CORS origin lock(`_shared/cors.ts` 에 `buildCorsHeaders(req)` 추가 → **웹이 실제 호출하는 ~20개 함수만** 이관.
나머지 ~50개 인라인 사본 일괄 수정은 웹 전환에 기여하지 않는 낭비) · `Access-Control-Max-Age: 86400`
(현재 리포 전체 0건 → 모든 POST 가 매번 OPTIONS 왕복) · user-id 슬라이딩 윈도우 rate limit ·
환불/차지백 · `@sentry/nextjs` · P0-B 잔여 32종 마무리.

---

## 10. 롤백 / 킬스위치

**되돌릴 수 있는 것**: DNS 복귀(10분, `zpzg-landing` 30일 보존) · Vercel Instant Rollback(5분) ·
`web_checkout_enabled` feature flag 로 결제 CTA → "앱 다운로드" 전환(즉시, 배포 없음) · `apps/web` 디렉토리 삭제(1시간, 네이티브 영향 0)

**되돌릴 수 없는 것 (one-way door)**
1. 실제 발생한 웹 결제 — 웹 UI 를 죽여도 `payment-web-*` 는 계속 살아 있어야 한다
2. 활성 웹 구독의 빌링키 — 웹을 접으려면 전 구독 능동 해지 + 잔여기간 정산
3. `verified_purchases` CHECK 확장
4. 스토어 메타데이터 URL 변경 (`metadata/ko/privacy_url.txt` 등) — 되돌리려면 새 심사
5. `associatedDomains` 를 넣은 네이티브 빌드 — OTA 불가, 새 빌드+심사
6. 웹으로 생성된 계정

**판정 시점 2개 (초안은 M6+30일 1개뿐이었다):**

| 게이트 | 시점 | 기준 | 미달 시 |
|---|---|---|---|
| **조기 게이트** | M1 + 3주 | 20페이지 GSC 노출/클릭이 0 에 수렴하지 않을 것 | M2~M5 착수하지 않음. 획득 채널 재설계 (총 20 dev-day 소진, 39d 절약) |
| 본 게이트 | M4 + 30일 | 웹 가입→첫 운세 ≥40% · 웹 가입→유료 ≥1.5% · 유기 웹 가입 ≥30/일 | M5 착수 중단, `apps/web` 을 SEO 랜딩 + 앱 다운로드 퍼널로 강등(`web_checkout_enabled=false`). 결제 사용자는 계속 서비스 |

---

## 11. 의도적 제외 (v1 범위 밖)

카메라 운세 9종 · Expo push / 웹 푸시 · 선톡 배달 · TTS/STT · 온디바이스 LLM(`AiMode='cloud'` 고정) ·
리워드 광고 · iOS 위젯 44파일 · 햅틱 · 네이버 웹 로그인(Supabase 내장 제공자에 없음 → 이메일 OTP 로 동일 계정 진입) ·
`character-chat` SSE 스트리밍 · `job-status` 폴링 엔드포인트(A-11) · `react-native-web` 도입 ·
`_shared/cors.ts` 미사용 ~50개 함수의 origin lock.

---

## 12. 미해결 / 확인 필요

### 12.1 라이브 introspection 으로 해소된 항목 (2026-08-18)

| 항목 | 결과 | 계획에 미치는 영향 |
|---|---|---|
| `auth.users.is_anonymous` 컬럼 | **존재함** (`information_schema.columns` 확인) | §8.1 게스트 퍼널과 `grant_initial_tokens` is_anonymous 분기 설계가 그대로 유효 |
| `token_balance` / `token_transactions` RLS | **RLS ON, 정책은 SELECT 1개씩** (`user_id = auth.uid()`). INSERT/UPDATE/DELETE 정책 없음 → 클라이언트 직접 쓰기는 RLS 가 이미 차단 | "anon key 배포 즉시 잔액 조작" 시나리오는 **성립하지 않는다.** 다만 테이블 수준 GRANT 가 남아 있어 `20260818000700` 에서 회수했다 (TRUNCATE 는 RLS 대상이 아니므로) |
| `balance >= 0` CHECK | **존재하지 않음** (`token_balance` 의 CHECK 제약 0건) | §7.3 차지백의 음수 잔액 설계가 스키마 변경 없이 가능 |
| `token_transactions` CHECK 실제 값 | `earn / spend / purchase / refund` — **`consumption` 이 빠져 있어 §2.0 장애 발생** | 초안이 몰랐던 항목. 최우선 수정 |
| `auth.users` 트리거 | `on_auth_user_created`, `on_auth_user_created_grant_tokens` | 익명 가입에도 50토큰이 나간다는 §7.5 전제 확인 |
| 클라이언트 직접 테이블 접근 | `premium-remote.ts:164` 의 `subscriptions` SELECT 1건뿐 | 원장 4테이블의 쓰기 권한 회수가 회귀를 일으키지 않음 |

### 12.2 남은 미해결

| # | 항목 | 확인처 | 블로킹 |
|---|---|---|---|
| 4 | 토스페이먼츠 실제 계약 수수료율 | PG 계약서. 5% 대면 웹 우위가 +13.4% → +9% 대로 축소 | M3 가격 확정 |
| 5 | 토스 V2 웹훅 서명 헤더 명세 | 토스 문서. 재조회 전략으로 우회했으나 있으면 추가 검증층 | M3 |
| 6 | Apple 무수수료 링크아웃의 KR 확장 여부 / Google Play KR 링크아웃 정책 | App Store Review Guidelines 3.1.1(a) + External Purchase Link Entitlement 지원 목록 | §7.7 |
| 7 | Stripe 한국 사업자 정식 지원 | Stripe 문서 | Phase 2 |
| 8 | 전자상거래법 자동갱신 다크패턴 조항 시행 여부·고지 시점 | 공정위 | M3 법률 페이지 |
| 9 | 네이버 가입자의 이메일이 `auth.users` 에 실제 저장되는가 | `naver-oauth` 동작 확인. 안 되면 네이버 가입자는 웹 진입 경로가 없다 | M1 |
| 10 | `packages/saju-engine` `solar-lunar.ts` 의 "만세력 ±1~2일 오차" + `LUNAR_NEW_YEAR` 2030 종료 | 웹이 공개 검색 채널이 되면 이 근사 오차가 노출 규모만큼 커진다 | M2 (`/사주` 페이지가 핵심 자산이므로) |

---

## 13. 알려진 위험 (설계로 제거하지 못한 것)

- **웹 UI 재사용 코드가 사실상 0**: `apps/mobile-rn` 의 206개 tsx 중 168개가 `react-native` import, 41개가 `Animated`.
  M2 8d / M5 9d 는 "12종만, hero 를 DOM/SVG 로 재작성" 전제이며 **시각 품질 기준을 앱과 동일하게 잡으면 초과**한다.
- **회귀 안전망 부재**: `apps/mobile-rn` 의 UI 테스트는 6개뿐이고 컴포넌트를 렌더하는 것은 0개다.
  `packages/fortune-render-contracts` 승격이 mobile 파일 9개를 건드리는데 파리티 검증이 육안 대조에 의존한다.
- **익명 가입은 근본적으로 시크릿창으로 재발급 가능**하다. IP 해시 스로틀은 완화일 뿐 VPN/모바일 IP 로테이션을 막지 못한다.
  실질 방어선은 게스트 1인당 노출을 5토큰(≈₩5.7)으로 묶은 것과 §3 의 서버측 과금이다.
- **`Access-Control-Allow-Origin: '*'` 가 ~70개 파일에 리터럴로 박혀 있다.** 공개 브라우저 오리진을 열면
  유출된 JWT 를 아무 사이트에서나 재생할 수 있다. M6 에서 웹이 쓰는 ~20개만 잠근다.
- **PG 가맹점 심사가 M3 의 캘린더 임계 경로**다. D0 신청이 늦어질수록 리스크가 커진다.
- **`.claude/docs/24-page-layout-reference.md` 와 `26-widget-component-catalog.md` 가 이 워크트리에 없다**
  (CLAUDE.md 문서 표에서 참조만 됨). 포팅 대조 기준 문서가 없어 인벤토리를 코드에서 직접 유도해야 한다.

---

## 14. 다음 단계

1. §1.1 앱 베이스라인 6개 숫자 입력 → §8 동결 범위 확정
2. §1.2 외부 절차 1·2 착수 (리드타임이 가장 길다)
3. 이 문서로 **`/codex challenge` 2~3회** (CLAUDE.md 큰 작업 워크플로우)
4. P0-A 착수 — 웹 착수 여부와 무관하게 지금 뚫려 있다. `/ultrareview` 필수
