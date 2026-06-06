# BM / IAP / Revenue Security Reviewer QA Report

## Verdict
- **NO-GO**
- 핵심 리스크: 비동기 이미지 운세 큐와 광고 보상 경로에서 **토큰 차감 전/검증 전 서버 비용이 발생하거나 보상이 지급될 수 있는 수익 누수**가 있고, 구독 상품 혜택이 코드와 UI 문구가 달라 매출/정책 리스크가 큼.

## Scope / Method
- 기준 체크리스트: `docs/audits/2026-06-ondo-full-audit/checklists/01-bm-iap-revenue.md`
- 조사 범위: IAP 상품 카탈로그, 프리미엄 UX, `react-native-iap` 구매/복원 흐름, Supabase Edge Functions (`payment-verify-purchase`, `subscription-activate`, `soul-consume`, `token-balance`, `grant-ad-reward`, poster queue), DB migration 제약.
- 코드 수정 없음. 실기기/StoreKit sandbox/라이브 DB row 검증은 수행하지 않았으며, 아래 결과는 정적 코드/설정 기반 QA임.

## P0

### P0-1. 비동기 poster-guide 운세는 토큰 부족이어도 서버 OpenAI 이미지 생성이 큐에서 실행될 수 있음
- **영향**: `palm-reading`, `beauty-simulation`, `hair-style-guide`, `face-reading-guide`, `ootd-guide`, `blind-date-guide`, `past-life-guide` 등 비동기 이미지/포스터 운세에서 사용자가 토큰이 부족해도 `scheduled_poster_jobs` row가 먼저 생성되고, 이후 `process-poster-jobs`가 토큰 상태와 무관하게 `generate-poster-guide`를 호출한다. OpenAI 이미지 생성 비용이 무과금으로 발생하고 결과까지 사용자에게 전달될 수 있다.
- **증거**:
  - 클라이언트는 큐 등록을 먼저 수행: `apps/mobile-rn/src/screens/chat-screen.tsx:2217-2224` (`startAsyncPosterJob` 호출).
  - 토큰 차감은 큐 등록 성공 이후에 수행: `apps/mobile-rn/src/screens/chat-screen.tsx:2240-2249`.
  - 토큰 부족 시 안내 후 `return`하지만 job cancel/delete/status update가 없음: `apps/mobile-rn/src/screens/chat-screen.tsx:2255-2268`.
  - 코드 주석은 “cron 이 user_token_balance 도 체크”한다고 쓰지만 실제 worker에는 토큰 체크가 없음: `apps/mobile-rn/src/screens/chat-screen.tsx:2259-2260` vs `supabase/functions/process-poster-jobs/index.ts:58-63`, `86-100`, `125-141`.
  - worker는 claim 후 바로 `generate-poster-guide`를 service role로 호출: `supabase/functions/process-poster-jobs/index.ts:86-100`.
  - `generate-poster-guide`는 토큰/구독/소유자 확인 없이 OpenAI 호출: `supabase/functions/generate-poster-guide/index.ts:319-357`, `446-452`.
- **재현 단계**:
  1. 로그인 계정의 토큰 잔액을 0 또는 `past-life-guide`/poster 운세 비용 미만으로 둔다.
  2. 채팅에서 사진 기반 포스터 운세 설문을 완료한다.
  3. 비용 확인 후 진행한다.
  4. 클라이언트는 `start-poster-job`으로 `scheduled_poster_jobs.status='pending'` row를 만든 뒤 `soul-consume`에서 `INSUFFICIENT_TOKENS`를 받는다.
  5. 다음 cron에서 `process-poster-jobs`가 해당 row를 처리해 `generate-poster-guide`/OpenAI 호출 및 결과 메시지 삽입을 시도한다.
- **수정 방향**:
  - 큐 등록 전 서버에서 **토큰 reserve/차감까지 원자적으로 성공**해야 `scheduled_poster_jobs`를 insert하도록 설계 변경.
  - 또는 `start-poster-job` Edge Function 내부에서 `consume_token_atomic`을 호출하고 성공 시에만 job insert. 실패 시 402/400으로 반환.
  - 이미 insert된 job에 대해 charge 실패 시 `status='failed'` 또는 `cancelled`로 변경하고 worker가 `pending`만 claim하도록 유지.
  - `scheduled_poster_jobs`에 `charge_transaction_id`/`charge_reference_id`를 저장하고 worker가 값이 없으면 처리하지 않도록 DB-level guard 추가.
- **검증 방법**:
  - DB에 토큰 0 테스트 유저 생성 → poster 운세 요청 → `scheduled_poster_jobs` row가 생성되지 않거나 `cancelled/failed`인지 확인.
  - `process-poster-jobs` 호출 후에도 `generate-poster-guide` 로그/OpenAI 호출/결과 카드가 없어야 함.
  - 정상 잔액 유저는 `token_transactions.transaction_type='consume'` row와 `scheduled_poster_jobs.charge_transaction_id`가 같은 요청에 남고 결과가 도착해야 함.

### P0-2. 광고 보상 POST fallback은 광고 시청 증명 없이 JWT만으로 토큰 지급 가능
- **영향**: 로그인 JWT만 있으면 클라이언트/스크립트가 `grant-ad-reward` POST를 직접 호출해 하루 5토큰까지 광고를 실제로 보지 않고 받을 수 있다. 대량 계정/자동화 시 토큰 구매를 대체하는 수익 누수와 abuse가 가능하다.
- **증거**:
  - 주석상 POST는 “RN 클라이언트 self-attestation fallback”: `supabase/functions/grant-ad-reward/index.ts:3-7`, `193-215`.
  - POST 경로는 `authenticateUser(req)`만 통과하면 body의 `adUnit/ssvSignature`를 검증하지 않고 `grantTokensForUser` 호출: `supabase/functions/grant-ad-reward/index.ts:193-215`.
  - `grantTokensForUser`는 일일 count만 확인하고 `token_balance` upsert + `token_transactions` insert + `ad_reward_log` insert 수행: `supabase/functions/grant-ad-reward/index.ts:45-103`.
  - 클라이언트도 `EARNED_REWARD` 이후 POST 호출만 수행하며 SSV transaction id/idempotency를 전달하지 않음: `apps/mobile-rn/src/lib/ad-rewards.ts:205-230`.
- **재현 단계**:
  1. 로그인 세션 access token 확보.
  2. 광고 SDK 없이 `POST /functions/v1/grant-ad-reward`에 Authorization Bearer와 `{ "adUnit": "x" }` 전송.
  3. 하루 5회까지 `token_balance.balance` 증가 및 `ad_reward_log` row 생성 가능.
- **수정 방향**:
  - 운영 빌드에서는 POST fallback 비활성화 또는 feature flag로 dev/test에서만 허용.
  - AdMob SSV GET만 지급 경로로 사용하고, `transaction_id`를 `ad_reward_log`에 저장해 unique index로 중복 방지.
  - POST를 유지해야 한다면 서버 발급 nonce + AdMob SSV 검증 완료 row와 매칭될 때만 지급.
- **검증 방법**:
  - JWT만 가진 curl POST가 403/400으로 거부되는지 확인.
  - 실제 AdMob SSV GET callback은 서명 검증 후 1회만 지급되는지 확인.

## P1

### P1-1. 활성 구독 하나만 있으면 모든 `soul-consume` 비용이 무제한 면제됨 — 상품 문구와 불일치
- **영향**: `라이트 구독` UI/카탈로그는 “매월 200 토큰 + 광고 제거”, `프로 구독`은 “매월 500 토큰 + 캐릭터 무제한 + 메모리 확장”인데, 서버는 모든 활성 구독을 `hasUnlimitedAccess=true`로 취급해 모든 운세/이미지/채팅 토큰 차감을 건너뛴다. 라이트/프로 구독자가 고비용 운세까지 무제한 사용 가능해 BM과 실제 비용 구조가 어긋난다.
- **증거**:
  - 상품 문구/포인트: `packages/product-contracts/src/products.ts:75-92` (`lite` 200, `pro` 500), `174-182` (`max` 2000).
  - 프리미엄 UX도 구독 플랜 설명을 product description으로 표시: `apps/mobile-rn/src/screens/premium-screen.tsx:661-684`.
  - `soul-consume`은 어떤 active subscription이든 찾으면 비용 계산/RPC 차감 전에 무제한으로 return: `supabase/functions/soul-consume/index.ts:160-190`.
  - `token-balance`도 active subscription 존재 여부만으로 `isUnlimited=true`: `supabase/functions/token-balance/index.ts:107-123`.
- **재현 단계**:
  1. `com.beyond.fortune.subscription.lite` 활성 구독 row를 가진 유저로 로그인.
  2. 25/50 토큰 고비용 운세 또는 character-chat 반복 호출.
  3. `soul-consume` 응답은 `hasUnlimitedAccess: true`, `token_transactions` consume row 미생성.
- **수정 방향**:
  - 구독 SKU별 entitlement를 분리: `lite=월 200 토큰+광고 제거`, `pro=캐릭터 채팅 한정 무제한/월 500`, `max=정의된 무제한 범위`처럼 서버에서 product_id별 정책 적용.
  - `subscriptions`만으로 무제한 처리하지 말고 `entitlements`/`monthly_token_grants`를 별도 테이블로 관리.
  - UI 문구와 서버 권한을 product-contract SoT로 통합.
- **검증 방법**:
  - lite 구독자가 5/25/50 토큰 운세 사용 시 token balance가 차감되거나 월 지급 토큰이 소모되는지 확인.
  - pro 구독자는 “캐릭터 무제한” 범위만 면제되고 이미지/헤비 운세는 차감되는지 확인.

### P1-2. 광고 보상 지급이 원자적이지 않아 동시 호출로 일일 한도/잔액이 깨질 수 있음
- **영향**: `ad_reward_log` count 조회 → `token_balance` 조회/upsert → `token_transactions` insert → `ad_reward_log` insert가 별도 쿼리로 실행된다. 동시 POST/SSV 호출 시 모두 `usedToday < 5`로 판단해 5회 한도를 초과하거나, balance lost update/transaction log 불일치가 생길 수 있다.
- **증거**:
  - count 기반 한도 확인: `supabase/functions/grant-ad-reward/index.ts:45-66`.
  - balance read-modify-write가 lock/RPC 없이 수행: `supabase/functions/grant-ad-reward/index.ts:68-86`.
  - transaction/log insert도 별도: `supabase/functions/grant-ad-reward/index.ts:88-103`.
  - DB migration은 `(user_id, reward_date)` index만 있고 unique/idempotency가 없음: `supabase/migrations/20260503193000_ad_reward_log.sql:4-16`.
- **재현 단계**:
  1. 동일 JWT로 `grant-ad-reward` POST 10개를 병렬 전송.
  2. `ad_reward_log` count, `token_transactions` earn count, `token_balance.balance`가 5회 한도와 일치하는지 확인.
- **수정 방향**:
  - `grant_ad_reward_atomic(p_user_id, p_ad_transaction_id, p_reward_date)` RPC로 row lock + count + balance update + transaction insert를 단일 DB transaction으로 처리.
  - SSV `transaction_id` 또는 서버 nonce에 unique index 추가.
  - `(user_id, reward_date, reward_sequence)` 또는 daily counter row를 `FOR UPDATE`로 잠그기.
- **검증 방법**:
  - 병렬 10회 호출 시 성공 5회/실패 5회, balance 증가 5, transaction row 5개로 고정되는지 확인.

### P1-3. Restore Purchases가 소모성 토큰 상품을 복구하지 않아 사용자 손실/CS 리스크가 있음
- **영향**: `restorePurchases`는 subscription과 non-consumable만 처리하고 consumable token 상품은 무시한다. 미완료/pending consumable transaction이 `getAvailablePurchases`에 남아 복구 경로로 들어온 경우 토큰 지급/finish가 되지 않을 수 있다.
- **증거**:
  - restore loop에서 subscription은 `activateRemoteSubscription`, non-consumable은 local `applyProductPurchase`; consumable branch 없음: `apps/mobile-rn/src/providers/mobile-app-state-provider.tsx:1018-1040`.
  - 일반 구매 listener는 consumable을 `verifyRemotePurchase` 후 `finishStoreTransaction({ isConsumable: true })` 처리: `apps/mobile-rn/src/providers/mobile-app-state-provider.tsx:761-785`.
  - 프리미엄/프로필에 복구 버튼 노출: `apps/mobile-rn/src/screens/premium-screen.tsx:390-396`, `861-866`; `apps/mobile-rn/src/screens/profile-screen.tsx:109`, `210`.
- **재현 단계**:
  1. 토큰 상품 결제 후 앱이 `purchaseUpdatedListener` 처리 전에 종료/네트워크 실패 상태를 만든다.
  2. 재설치/재로그인 후 “구매 복원” 실행.
  3. 해당 consumable purchase가 available list에 있더라도 restore loop에서 무시되는지 확인.
- **수정 방향**:
  - 복구 경로에서도 consumable pending transaction은 `verifyRemotePurchase`를 호출하고, 서버 idempotency로 이미 지급된 건 replay 처리 후 `finishTransaction` 수행.
  - 단, Apple 정책상 consumable은 일반적인 “복원” 대상이 아니므로 버튼 문구/설명은 “미완료 구매 확인”과 구분.
- **검증 방법**:
  - StoreKit interrupted purchase 시나리오에서 restore/미완료 구매 확인 후 `verified_purchases`, `token_transactions.purchase`, `finishTransaction`이 모두 1회씩 완료되는지 확인.

### P1-4. `generate-poster-guide`는 요청 userId를 인증 사용자와 매칭하지 않고 고비용 OpenAI 호출 가능
- **영향**: 함수 자체는 body의 `userId` UUID 형식만 검증하고 Authorization/JWT의 사용자와 매칭하지 않는다. Supabase function gateway JWT 설정에 의존하더라도, 로그인 유저가 임의 userId로 고비용 poster generation을 호출할 수 있는 비용/저장 경로 오염 위험이 있다.
- **증거**:
  - handler에서 method/env/body/posterType/userId UUID만 검증: `supabase/functions/generate-poster-guide/index.ts:319-357`.
  - 이후 바로 이미지 검증/템플릿 fetch/OpenAI 호출: `supabase/functions/generate-poster-guide/index.ts:363-452`.
  - Supabase `config.toml`에 `generate-poster-guide` 전용 내부 worker-only 설정/명시적 auth 정책이 없음. worker 함수 `process-poster-jobs`는 `verify_jwt=false`: `supabase/config.toml:16-22`.
- **재현 단계**:
  1. 로그인 JWT 또는 function 호출 권한을 가진 클라이언트에서 `generate-poster-guide`에 임의 UUID `userId`와 base64 이미지를 POST.
  2. 토큰 차감/큐/소유자 확인 없이 OpenAI 호출 및 storage upload 시도 여부 확인.
- **수정 방향**:
  - `generate-poster-guide`를 worker-only로 만들고 `CRON_SECRET`/service-role/internal header 검증을 강제.
  - 직접 호출을 허용해야 한다면 JWT user id를 derive해서 body.userId와 일치해야만 진행.
  - 토큰 차감/entitlement 확인을 이 함수 내부에서도 방어적으로 검증.
- **검증 방법**:
  - anon/일반 JWT 직접 호출은 401/403, `process-poster-jobs` service call만 성공해야 함.

## P2

### P2-1. 구독 활성화 상품 메타데이터가 최신 SKU와 drift되어 있음
- **영향**: `subscription-activate`의 `SUBSCRIPTION_PRODUCTS`에는 `lite/pro`가 없고 `monthly/yearly/max`만 명시되어 있다. 현재는 알 수 없는 상품을 30일로 default 처리해 동작은 하지만, period/혜택/만료 계산이 product-contract와 분리되어 추후 결제/정책 오류가 반복될 가능성이 높다.
- **증거**:
  - 서버 구독 상품 map: `supabase/functions/subscription-activate/index.ts:10-18`.
  - storefront 구독 SKU는 `lite/pro/max`: `packages/product-contracts/src/products.ts:228-244`.
  - unknown product fallback 30일: `supabase/functions/subscription-activate/index.ts:23-33`.
- **수정 방향**: product-contract에서 Edge용 subscription entitlement/period generated file을 만들고 `subscription-activate`가 import하도록 통합.
- **검증 방법**: `lite/pro/max/monthly` 각각 activate 시 period, entitlement, UI 표시가 기대값과 일치하는 unit/integration test 추가.

### P2-2. 프리미엄 화면의 사용 가능 횟수 preview가 실제 가격 SoT와 불일치할 수 있음
- **영향**: top-up UX는 “긴 답변=토큰/5, 심층 분석=토큰/30”으로 고정 계산하지만 실제 가격 SoT는 1/5/12/25/50 계층이다. 특히 25/50 토큰 이미지/Ultra 상품에서 기대 사용 횟수가 오해될 수 있다.
- **증거**:
  - preview 계산: `apps/mobile-rn/src/screens/premium-screen.tsx:111-115`.
  - 실제 가격 계층: `supabase/functions/_shared/fortune-pricing-generated.ts:15-23`, `31-164`.
- **수정 방향**: preview도 가격 SoT에서 대표 SKU/운세별 실제 비용으로 계산하거나 “예: 5토큰 운세 기준”처럼 명시.
- **검증 방법**: 30/400/1000 토큰 패키지 선택 시 표시 횟수와 대표 운세 비용이 일치하는지 snapshot/UI test.

### P2-3. 구매 복원 성공 UI가 명확하지 않음
- **영향**: restore 실패는 Alert가 있지만 성공 시에는 `syncRemoteProfile` 이후 별도 성공 Alert/토스트가 없다. 사용자는 복원이 되었는지 알기 어렵고 반복 탭으로 support burden이 늘 수 있다.
- **증거**:
  - `handleRestore`는 성공 branch에서 아무 메시지 없음: `apps/mobile-rn/src/screens/premium-screen.tsx:254-270`.
  - provider restore는 count 증가/sync만 수행: `apps/mobile-rn/src/providers/mobile-app-state-provider.tsx:1042-1050`.
- **수정 방향**: 복원 성공/복원할 구매 없음/미완료 구매 처리 완료를 구분한 Alert/Toast 제공.
- **검증 방법**: no purchase, active subscription, pending consumable 세 케이스에서 사용자 메시지가 각각 올바른지 QA.

## P3

### P3-1. App Store 구독 정책 문구는 기본 요소가 있으나 가격/기간 자동 갱신 설명을 더 명확히 할 필요
- **증거**:
  - 구독 자동 갱신/해지 문구와 약관/개인정보 링크 존재: `apps/mobile-rn/src/screens/premium-screen.tsx:794-817`.
  - 다만 화면에는 “월 {가격}” 표시가 상품 row에만 있고, 무료 체험/갱신 가격/구독 기간 세부 고지가 App Store metadata와 완전히 일치하는지 실기기 확인 필요: `apps/mobile-rn/src/screens/premium-screen.tsx:671-684`, `800-803`.
- **수정 방향**: Apple subscription disclosure 체크리스트 기준으로 상품명, 기간, 가격, 자동 갱신, 해지 위치, 약관/개인정보 링크를 한 카드 안에서 재검수.
- **검증 방법**: 실기기 StoreKit sandbox에서 가격 locale 표시, CTA 직전 disclosure, 링크 정상 오픈 확인.

### P3-2. 라이브 운영 로그/DB evidence가 보고서에 자동 첨부되지 않음
- **증거**: 이번 QA는 로컬 코드/마이그레이션 정적 분석으로 수행. 실제 `verified_purchases`, `token_transactions`, `ad_reward_log`, `scheduled_poster_jobs` row 샘플은 조회하지 못함.
- **수정 방향**: 다음 QA run에는 Supabase read-only SQL 스크립트를 만들어 최근 7일 결제/보상/환불/큐 anomaly를 자동 수집.
- **검증 방법**: report artifact에 SQL output 또는 redacted CSV 포함.

## Evidence

### 핵심 파일/라인
- 체크리스트: `docs/audits/2026-06-ondo-full-audit/checklists/01-bm-iap-revenue.md:63-96`
- 상품 카탈로그: `packages/product-contracts/src/products.ts:37-203`, storefront ids `205-254`
- 가격 SoT: `supabase/functions/_shared/fortune-pricing-generated.ts:31-164`
- 구매 처리: `apps/mobile-rn/src/providers/mobile-app-state-provider.tsx:732-799`, `923-1066`
- 프리미엄 UX: `apps/mobile-rn/src/screens/premium-screen.tsx:254-333`, `661-866`
- 결제 검증/중복 방지: `supabase/functions/payment-verify-purchase/index.ts:453-475`, `721-954`
- 구독 활성화: `supabase/functions/subscription-activate/index.ts:10-18`, `135-267`
- 토큰 소비: `supabase/functions/soul-consume/index.ts:113-195`, `197-275`
- 토큰 잔액/무제한 판정: `supabase/functions/token-balance/index.ts:107-140`
- 광고 보상: `apps/mobile-rn/src/lib/ad-rewards.ts:78-115`, `190-235`; `supabase/functions/grant-ad-reward/index.ts:38-114`, `124-215`
- 비동기 poster queue: `apps/mobile-rn/src/screens/chat-screen.tsx:2208-2268`; `supabase/functions/start-poster-job/index.ts:91-146`; `supabase/functions/process-poster-jobs/index.ts:58-144`; `supabase/functions/generate-poster-guide/index.ts:319-452`
- DB 제약:
  - purchase replay global unique: `supabase/migrations/20260515044500_purchase_iap_global_idempotency.sql:8-13`
  - purchase per-user legacy unique: `supabase/migrations/20260505120000_token_transactions_purchase_unique.sql:11-16`
  - ad reward log lacks uniqueness/idempotency: `supabase/migrations/20260503193000_ad_reward_log.sql:4-16`

### 긍정 확인 사항
- Apple/Google purchase verification은 서버 함수 `payment-verify-purchase`에서 수행되고, 클라이언트는 `verifyRemotePurchase`를 통해 호출한다: `apps/mobile-rn/src/lib/premium-remote.ts:267-304`.
- verified transaction id global replay 방지 unique index가 존재한다: `supabase/migrations/20260515044500_purchase_iap_global_idempotency.sql:8-13`.
- token purchase grant는 `grant_purchase_tokens_atomic` RPC로 balance update와 transaction insert를 원자화하려는 구조가 있다: `supabase/migrations/20260515044500_purchase_iap_global_idempotency.sql:21-160`.
- 일반 character/story chat은 로그인 + cloud provider 경로에서 LLM 호출 전 토큰 차감을 시도한다: `apps/mobile-rn/src/screens/chat-screen.tsx:2983-2992`, `3543-3551`.
- 프리미엄 화면에 구매 복원 버튼과 구독 약관/개인정보 링크가 존재한다: `apps/mobile-rn/src/screens/premium-screen.tsx:390-396`, `794-817`, `861-866`.

## Recommended Fix Order
1. **P0-1 poster queue billing gate 수정**: `start-poster-job` 안에서 atomic consume + job insert를 한 트랜잭션성 흐름으로 묶고, charge 없는 pending job은 worker가 처리하지 못하게 DB/worker guard 추가.
2. **P0-2 광고 POST fallback 제거/잠금**: 운영에서 self-attestation POST 비활성화, SSV transaction-id 기반 atomic reward RPC 도입.
3. **P1-1 구독 entitlement 재정의**: SKU별 혜택을 서버 SoT로 만들고 `soul-consume`/`token-balance`의 “모든 구독=무제한” 판정을 제거.
4. **P1-2 광고 보상 원자화**: daily cap + balance + transaction + log를 단일 RPC로 처리하고 병렬 호출 테스트 추가.
5. **P1-3 restore/missing consumable 처리**: 미완료 consumable 구매 확인 경로를 별도 구현하고 restore UX 문구 정리.
6. **P1-4 `generate-poster-guide` 내부 인증/worker-only guard** 추가.
7. P2/P3 UX·카탈로그 문구 정합성 및 실기기 StoreKit sandbox QA.

## Open Questions
- 실제 App Store Connect / Google Play Console에 등록된 SKU 목록과 `packages/product-contracts/src/products.ts`의 storefront/legacy 구성이 1:1로 일치하는가?
- 현재 운영 AdMob SSV callback이 활성화되어 있는가? 활성화되어 있다면 POST fallback과 SSV GET이 동시에 지급되는 중복 사례가 있는가?
- 구독 BM의 의도는 “월 토큰 지급”인가, “전체 무제한”인가, “캐릭터 채팅 한정 무제한”인가? 현재 코드와 UI가 서로 다른 메시지를 준다.
- `generate-poster-guide`는 외부 직접 호출을 허용해야 하는 API인가, worker-only 내부 API인가?
- 실기기 StoreKit sandbox에서 interrupted consumable purchase가 `purchaseUpdatedListener` 재emit으로 처리되는지, restore button으로도 보완해야 하는지 확인 필요.
