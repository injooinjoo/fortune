# Supabase / RLS / Edge Health Reviewer QA Report

## Verdict
- **NO-GO**
- 핵심 리스크: **사용자 업로드 이미지 Storage 공개, 계정 삭제 Storage purge 실패/잔존 가능성, 일부 Edge Function의 인증·배포 상태 불일치**가 있어 개인정보/비용/데이터 격리 관점에서 출시 전 보완이 필요합니다.

## Scope / Method
- 체크리스트: `docs/audits/2026-06-ondo-full-audit/checklists/11-supabase-rls-edge-health.md`
- 프로젝트: `/Users/injoo/Desktop/Dev/fortune`
- Supabase project ref: `hayjukwfcsdmppairazc` (`ondo`)
- 코드 수정: **하지 않음**. 요청된 보고서 파일만 작성.
- 실행한 읽기 전용 검증:
  - `supabase db query --linked ...`로 RLS/Storage/policy 조회
  - `supabase functions list --project-ref hayjukwfcsdmppairazc -o json`로 배포 메타데이터 확인
  - no-auth `curl` smoke로 Gateway/함수 도달 여부 확인
  - `supabase functions download fortune-compatibility --use-api`로 production bundle과 local source 비교
- 제한:
  - `supabase db dump --linked`는 Docker daemon 미실행으로 실패했습니다. 대신 `supabase db query --linked` 단건 쿼리로 대체했습니다.
  - 설치된 Supabase CLI v2.90.0에는 `functions logs` 명령이 없어 production function log 원문 조회는 수행하지 못했습니다.
  - prod 데이터 쓰기/삭제/토큰 차감 재현은 수행하지 않았습니다.

## P0

### P0-1. 사용자 업로드 손금/포스터 이미지 버킷이 public bucket + public SELECT 정책으로 노출됨
- **영향**: 손금/포스터 가이드 사진은 사용자가 직접 업로드하는 이미지 경로입니다. 버킷과 SELECT 정책이 공개 상태라 객체 경로가 노출되면 signed URL 없이 접근될 수 있습니다. 손금 이미지는 신체/생체성 개인정보로 볼 수 있어 개인정보 및 App Store 심사 리스크가 큽니다.
- **DB evidence**:
  ```sql
  select id, public, file_size_limit, allowed_mime_types
  from storage.buckets
  where id in (
    'palm-reading-images','poster-guide-images','past-life-portraits',
    'talisman-images','profile-images','character-avatars',
    'character-proactive-images','character-audio-messages'
  )
  order by id;
  ```
  결과 요약:
  - `palm-reading-images | public=true | image/png,image/jpeg`
  - `poster-guide-images | public=true | image/png,image/jpeg`
  - `past-life-portraits | public=true`
  - `talisman-images | public=true`
  - `character-audio-messages | public=false`
  - `profile-images`는 결과에 없음
- **Storage policy evidence**:
  ```sql
  select policyname, roles, cmd, qual
  from pg_policies
  where schemaname='storage'
    and tablename='objects'
    and (policyname ilike '%public%' or qual ilike '%palm-reading%' or qual ilike '%poster-guide%')
  order by policyname;
  ```
  결과 요약:
  - `palm_reading_images_public_read | {public} | SELECT | bucket_id = 'palm-reading-images'`
  - `poster_guide_images_public_read | {public} | SELECT | bucket_id = 'poster-guide-images'`
  - `Public can view character proactive images | {public} | SELECT | bucket_id = 'character-proactive-images'`
- **UX path evidence**:
  - `apps/mobile-rn/src/features/chat-survey/registry.ts:1170-1173` — poster guide 7종, `SurveyImagePicker` 단일 이미지 업로드 UX.
  - `apps/mobile-rn/src/features/chat-results/edge-runtime.ts:227-229` — `/generate-poster-guide` 및 `past-life` 이미지 생성형 운세는 90초 timeout 경로로 분리.
  - `apps/mobile-rn/src/features/fortune-results/screens/poster-guide.tsx:2-5` — `/generate-poster-guide` 응답의 `imageUrl`을 결과 화면에 노출.
- **Recommended fix**:
  1. 사용자 업로드 원본 버킷(`palm-reading-images`, `poster-guide-images`)은 private으로 전환합니다.
  2. 결과 공유가 필요한 생성 이미지와 사용자 원본 이미지를 버킷/경로로 분리합니다.
  3. 앱에는 signed URL 또는 Edge Function mediated URL만 반환하고 만료/재발급 정책을 명시합니다.
- **Verification**:
  - `storage.buckets.public=false` 확인.
  - anon/public key로 object public URL 직접 접근 시 401/403 확인.
  - 인증 사용자 A/B로 서로의 object path 접근 불가 확인.
  - 앱 경로: `/chat` → poster guide/palm-reading 이미지 업로드 → 결과 카드 이미지 정상 표시 및 앱 재시작 후 signed URL 재발급 확인.

### P0-2. 계정 삭제 함수가 존재하지 않는 `profile-images` 버킷만 purge하여 삭제 실패 또는 민감 Storage 잔존 가능
- **영향**: 계정 삭제 요청이 Storage purge 단계에서 500으로 실패하거나, 실제 사용 버킷의 사용자 이미지가 삭제되지 않고 남을 수 있습니다. App Store 계정 삭제/개인정보 삭제권 리스크입니다.
- **DB evidence**:
  - 위 storage bucket 조회 결과에 `profile-images` 버킷이 없습니다.
  - 반면 `palm-reading-images`, `poster-guide-images`, `past-life-portraits`, `character-audio-messages` 등 실제 사용자 산출물/업로드 관련 버킷은 존재합니다.
- **Code evidence**:
  - `supabase/functions/delete-account/index.ts:59-67`
    - 주석과 코드가 `profile-images` 버킷만 대상으로 합니다.
    - `const bucket = 'profile-images'`
  - `supabase/functions/delete-account/index.ts:167-184`
    - storage purge 실패 시 `500` 반환 후 `auth.admin.deleteUser`를 중단합니다.
  - `apps/mobile-rn/src/screens/account-deletion-screen.tsx:45-62`
    - 모바일 계정 삭제 화면은 60초 timeout 후 `delete-account` Edge Function을 호출합니다.
  - `apps/mobile-rn/src/screens/account-deletion-screen.tsx:75-77`
    - fcm token local cache 정리는 고려하지만 Storage 버킷별 잔존 검증은 앱 레벨에서 보이지 않습니다.
- **Recommended fix**:
  1. 실제 존재하는 사용자 데이터 버킷 목록을 delete-account purge 대상에 포함합니다: `palm-reading-images`, `poster-guide-images`, `past-life-portraits`, `character-audio-messages`, 사용자 생성 avatar류 등.
  2. 없는 버킷은 warning으로 처리하거나 manifest 기반으로 존재 여부를 먼저 확인합니다.
  3. delete audit response에 `bucket`, `prefix`, `removed`, `error`를 포함해 운영자가 실패 위치를 알 수 있게 합니다.
- **Verification**:
  - staging에서 테스트 사용자로 각 버킷 prefix에 샘플 object 생성 → `delete-account` 호출 → 모든 prefix 0건 확인.
  - 앱 경로: `/profile` → 계정 삭제 화면 → 삭제 완료/로그아웃 UX 확인.
  - App Store 심사용: 삭제 후 재로그인 불가, DB row 및 Storage object 미잔존 증거 캡처.

## P1

### P1-1. 일부 production fortune 함수가 `verify_jwt=false`로 배포되어 no-auth 요청이 함수 코드까지 도달함
- **영향**: 유효 payload가 직접 호출되면 앱 토큰 차감/세션 UX를 우회해 LLM 비용을 발생시킬 수 있습니다. 게스트 운세가 의도라면 rate limit/anonymous quota/abuse guard가 필요합니다.
- **Production metadata evidence** (`supabase functions list --project-ref hayjukwfcsdmppairazc -o json`):
  - `fortune-tarot: ACTIVE v51 verify_jwt=false updated_at=2026-05-06T08:13:04.593Z`
  - `fortune-compatibility: ACTIVE v67 verify_jwt=false updated_at=2026-05-10T10:48:54.345Z`
  - `fortune-dream: ACTIVE v70 verify_jwt=false`
  - `fortune-traditional-saju: ACTIVE v57 verify_jwt=false`
  - `fortune-face-reading: ACTIVE v64 verify_jwt=false`
  - `fortune-ootd: ACTIVE v40 verify_jwt=false`
  - `fortune-palm-reading: ACTIVE v12 verify_jwt=false`
- **HTTP smoke evidence**:
  ```text
  POST /functions/v1/fortune-tarot {"healthCheck":true}
  => 400 {"success":false,"error":"필수 필드 누락: selectedCards"}

  POST /functions/v1/fortune-compatibility {"healthCheck":true}
  => 500 {"success":false,"data":{},"error":"두 사람의 이름을 모두 입력해주세요."}
  ```
  Gateway 401이 아니라 함수 로직까지 도달했습니다.
- **Code evidence**:
  - `supabase/functions/fortune-tarot/index.ts:420-422`
    - body `userId` 미신뢰는 좋지만 인증 없는 요청을 `anonymous`로 처리합니다.
  - `supabase/functions/fortune-compatibility/index.ts:224-238`
    - CORS 후 바로 `req.json()` 파싱. `deriveUserIdFromJwt`/`authenticateUser` 사용이 보이지 않습니다.
  - `supabase/functions/fortune-compatibility/index.ts:269-270`
    - no-auth healthCheck payload도 일반 validation으로 들어가 500을 반환합니다.
- **Recommended fix**:
  1. 토큰 차감/유료 기능은 `authenticateUser` 필수로 통일합니다.
  2. 게스트 허용 함수는 명시적으로 `anonymous quota`, IP/device rate limit, idempotency, cost cap을 둡니다.
  3. 함수별 public/private manifest를 만들고 `supabase/config.toml`에 모든 예외를 명시합니다.
- **Verification**:
  - no-auth 유효 payload가 401 또는 quota-limited response를 반환하는지 확인.
  - 인증 사용자 호출은 정상 동작하고 token ledger/idempotency가 기록되는지 확인.
  - GitHub QA health check는 `healthCheck=true`에 대해 비용성 LLM 호출 없이 200을 반환해야 합니다.

### P1-2. Edge Function 중 body `userId`를 신뢰하거나 JWT user와 비교하지 않는 패턴이 남아 있음
- **영향**: 인증된 사용자가 body의 `userId`를 다른 사용자 UUID로 위조하면 service role 경로를 통해 타 사용자 캐시/사용량/결정 기록을 오염하거나 조회 시도할 수 있습니다.
- **Code evidence**:
  - 정상 가이드: `supabase/functions/_shared/auth.ts:4-10`
    - “`body.userId / body.user_id` 류 클라이언트 식별자를 절대 신뢰하지 말 것.”
  - `supabase/functions/fortune-love/index.ts:635-655`
    - `requestBody`에서 `userId` 필수 검증 후 `getCachedFortune(params.userId, params)` 호출.
  - `supabase/functions/fortune-decision/index.ts:180-195`
    - request body에서 `userId`를 destructuring하고 `getCoachPreferences(userId)` 호출.
  - `supabase/functions/fortune-decision/index.ts:325-333`
    - service role client로 `decision_receipts.user_id = userId` insert.
- **Recommended fix**:
  1. 모든 사용자 식별은 `authenticateUser(req)` 또는 `deriveUserIdFromJwt(req)` 결과로 통일합니다.
  2. body `userId`가 필요한 legacy API는 JWT user와 일치할 때만 허용하고 mismatch는 403으로 차단합니다.
  3. service role DB write 전 `effectiveUserId` 출처를 로그/테스트로 고정합니다.
- **Verification**:
  - staging에서 사용자 A JWT + body `userId=userB` 요청 → 403 확인.
  - 정상 사용자 A 요청 → row `user_id=A`로만 생성 확인.
  - 전역 검색: `userId` destructuring/requiredFields에 body userId가 남아 있지 않은지 확인.

### P1-3. `fortune_cache` 정책이 `user_id IS NULL` public write/update/delete를 허용할 수 있음
- **영향**: 현재 public cache row는 0건이지만, `user_id IS NULL` row가 생성되면 public role에서 조회/수정/삭제 가능한 정책 조건이 있습니다. 캐시 무결성/운세 결과 오염 리스크입니다.
- **DB evidence**:
  ```sql
  select policyname, roles, cmd, qual, with_check
  from pg_policies
  where schemaname='public' and tablename='fortune_cache'
  order by policyname;
  ```
  결과 요약:
  - `Public can view fortune cache | {public} | SELECT | (user_id IS NULL OR auth.uid() = user_id)`
  - `Users can update own fortune cache | {public} | UPDATE | (auth.uid() = user_id OR user_id IS NULL)`
  - `Users can delete own fortune cache | {public} | DELETE | (auth.uid() = user_id OR user_id IS NULL)`
  - `Authenticated users can insert fortune cache | {public} | INSERT | auth.uid() = user_id OR user_id IS NULL`
  - `select count(*) from public.fortune_cache where user_id is null;` → `0`
- **Recommended fix**:
  1. public/shared cache와 user-private cache를 별도 테이블 또는 별도 policy로 분리합니다.
  2. public role에는 SELECT만 허용하고 INSERT/UPDATE/DELETE는 service role/RPC 전용으로 제한합니다.
- **Verification**:
  - anon key로 `user_id=null` insert/update/delete가 실패하는지 staging에서 확인.
  - 앱 fortune result 캐시 hit/miss가 정상인지 회귀 테스트.

### P1-4. `character-chat` production `verify_jwt=true`와 내부 worker service-role invoke 경로 충돌 가능
- **영향**: pending reply worker가 `character-chat`을 호출할 때 Supabase Gateway가 service role Authorization을 JWT 검증에서 거부하면 선톡/지연 답장/큐 처리 경로가 실패할 수 있습니다.
- **Production metadata evidence**:
  - `character-chat: ACTIVE v118 verify_jwt=true updated_at=2026-05-10T14:25:48.828Z`
  - `process-pending-reply-jobs: ACTIVE v13 verify_jwt=false updated_at=2026-05-11T05:48:54.293Z`
- **HTTP smoke evidence**:
  - no-auth `POST /character-chat` → `401 {"code":"UNAUTHORIZED_NO_AUTH_HEADER","message":"Missing authorization header"}`
  - no-auth `POST /process-pending-reply-jobs` → `401 {"success":false,"error":"Unauthorized","reason":"missing_authorization_header"}` (worker 자체 방어는 정상)
- **Code evidence**:
  - `supabase/functions/_shared/auth.ts:26-40` — service role token + `X-Internal-User-Id`일 때 internal user id를 인정하는 패턴.
  - worker가 service role로 function invoke하는 구조는 checklist상 실제 production invoke 성공 로그 확인이 필요합니다.
- **Recommended fix**:
  1. production에서 `process-pending-reply-jobs` → `character-chat` service role invoke가 실제 성공하는 synthetic 안전 테스트를 추가합니다.
  2. Gateway가 service role JWT를 거부하는 환경이면 `character-chat`를 `verify_jwt=false`로 두고 함수 내부에서 user JWT/service role/worker secret을 엄격히 분기 검증하는 구조로 통일합니다.
- **Verification**:
  - 테스트 pending job 1건 생성 → worker 실행 → `character-chat` response persisted row 확인.
  - `scheduled_character_replies`/`pending_character_reply_jobs` row id, message id, timestamps로 증거화.

## P2

### P2-1. local source와 production bundle drift: `fortune-compatibility` healthCheck가 production에 미반영
- **영향**: repo 기준으로는 healthCheck가 있으나 production은 다른 bundle이어서 QA health 결과가 코드 리뷰와 불일치합니다. shared module/health fix가 배포되지 않았을 때 운영자가 잘못된 결론을 낼 수 있습니다.
- **Local code evidence**:
  - `supabase/functions/fortune-compatibility/index.ts:240-256` — `requestData.healthCheck === true`면 200 healthy 반환.
- **Production evidence**:
  - `supabase functions download fortune-compatibility --project-ref hayjukwfcsdmppairazc --use-api` 비교:
    - local bytes: `27407`, `has_healthCheck=True`
    - downloaded production bytes: `26921`, `has_healthCheck=False`, `equal_local=False`
  - no-auth `POST /fortune-compatibility {"healthCheck":true}` → `500`, `두 사람의 이름을 모두 입력해주세요.`
- **Recommended fix**:
  1. function deploy manifest에 source commit/version mapping을 남깁니다.
  2. `_shared` 또는 function source 변경 후 importing function 재배포 체크를 CI에 넣습니다.
  3. healthCheck는 validation/LLM/DB보다 먼저 return하도록 모든 function에 통일합니다.
- **Verification**:
  - deploy 후 `functions download` 재비교: `healthCheck=True`, local/prod hash 일치.
  - `POST {"healthCheck":true}`가 200 healthy 반환.

### P2-2. `supabase/config.toml`의 `verify_jwt` 선언이 일부 함수만 포함해 production auth 정책이 manifest로 완전히 관리되지 않음
- **영향**: 재배포/대시보드 변경/CLI 옵션에 따라 public/private 함수 경계가 바뀔 수 있습니다.
- **Code/config evidence**:
  - `supabase/config.toml:16-31` — worker/cron 함수 verify_jwt=false.
  - `supabase/config.toml:33-55` — 일부 `fortune-*` 함수 verify_jwt=false와 내부 auth 주석.
  - `character-chat`, `claim-scheduled-reply`, `payment-verify-purchase`, `soul-consume`, `soul-refund`, `token-balance`, `delete-account`, `grant-ad-reward` 등 checklist 핵심 함수는 config에 명시되지 않았거나 production 상태만으로 확인됩니다.
- **Production metadata examples**:
  - `claim-scheduled-reply verify_jwt=true`
  - `payment-verify-purchase verify_jwt=true`
  - `soul-consume verify_jwt=true`
  - `soul-refund verify_jwt=true`
  - `grant-ad-reward verify_jwt=false`
  - `delete-account verify_jwt=true`
- **Recommended fix**:
  1. checklist 대상 함수 전체에 대해 `verify_jwt` intent table을 문서화합니다.
  2. deploy 전 `supabase functions list`와 manifest diff를 CI에서 실패 처리합니다.
- **Verification**:
  - manifest vs production list가 0 diff인지 확인.

### P2-3. production-only/stale 함수가 많아 repo checklist 밖 운영 surface가 큼
- **영향**: local repo에 없는 production 함수는 RLS/JWT/CORS/health 상태가 현재 체크리스트와 코드 리뷰에서 빠질 수 있습니다.
- **Evidence**:
  - sub-audit 기준 local function dirs: `89`, production functions: `178`.
  - production-only 예: `fortune-today`, `fortune-weekly`, `fortune-yearly`, `character-follow-up`, `character-voice`, `fortune-batch` 등.
- **Recommended fix**:
  1. production-only 함수를 active/legacy/delete 후보로 분류합니다.
  2. legacy endpoint에 대해 no-auth smoke, JWT policy, traffic/log 유무를 확인 후 폐기 또는 repo 복원합니다.
- **Verification**:
  - `supabase functions list`와 `supabase/functions/*` directory diff가 의도된 예외만 남는지 확인.

### P2-4. `fcm_tokens` RLS는 SELECT만 존재해 클라이언트 직접 insert/update 경로가 있으면 실패 가능
- **영향**: 현재는 `sync-notification-device` Edge Function 경유라면 정상일 수 있으나, 클라이언트 SDK 직접 upsert 경로가 남아 있으면 푸시 토큰 등록 실패/알림 누락이 생길 수 있습니다.
- **DB evidence**:
  ```sql
  select policyname, cmd, qual, with_check
  from pg_policies
  where schemaname='public' and tablename='fcm_tokens';
  ```
  결과:
  - `Users can view own fcm tokens | SELECT | auth.uid() = user_id`
- **Recommended fix**:
  - 앱의 모든 푸시 토큰 등록 경로가 `sync-notification-device`만 쓰는지 고정하고, SDK direct insert/update 코드는 제거합니다.
- **Verification**:
  - 앱 로그인/권한 허용/토큰 refresh → `sync-notification-device` 호출 로그 및 `fcm_tokens` row 갱신 확인.

## P3

### P3-1. CORS가 전반적으로 `Access-Control-Allow-Origin: *`로 넓음
- **영향**: 모바일 전용 API라면 허용 가능하지만, 웹/브라우저 bearer token 사용 경로가 생기면 origin 제한 부재가 리스크가 됩니다.
- **Code evidence**:
  - `supabase/functions/_shared/cors.ts:1-5`
    - `Access-Control-Allow-Origin: '*'`
    - `Access-Control-Allow-Headers: authorization, x-client-info, apikey, content-type`
    - `Access-Control-Allow-Methods: POST, GET, OPTIONS`
  - `supabase/functions/fortune-compatibility/index.ts:224-233` — function-local CORS도 `*`, `POST`.
- **Recommended fix**:
  - 웹 노출 함수는 allowed origin allowlist를 적용하고 worker-only 함수는 CORS를 최소화합니다.
- **Verification**:
  - OPTIONS preflight matrix: mobile/native, web allowed origin, disallowed origin.

### P3-2. 관측성은 일부 함수에 latency/error 로그가 있으나 request/message/result/idempotency 표준 필드는 함수별로 불균일
- **영향**: 장애 시 user id, request id, message id, fortune result id, idempotency key를 한 번에 추적하기 어렵습니다.
- **Evidence**:
  - `supabase/functions/fortune-love/index.ts:515` — LLM provider/model latency 로그 있음.
  - `supabase/functions/fortune-decision/index.ts:284` — LLM provider/model latency 로그 있음.
  - `supabase/functions/fortune-family-health/index.ts:317` — LLM provider/model latency 로그 있음.
  - 반면 검색 결과상 requestId/messageId/idempotency 표준 로깅은 모든 함수에 일관되게 강제되어 있지 않습니다.
- **Recommended fix**:
  - Edge 공통 middleware에 `requestId`, `userId hash`, `function`, `messageId/resultId`, `latencyMs`, `errorCode`, `idempotencyKey` 필드를 표준화합니다.
- **Verification**:
  - 각 핵심 UX 경로에서 하나의 requestId로 mobile log → function log → DB row를 연결할 수 있는지 확인.

### P3-3. 주요 RLS 테이블은 활성화되어 있으나 중복/레거시 정책이 많아 감사 난이도가 높음
- **Positive evidence**:
  ```sql
  select c.relname as table_name, c.relrowsecurity as rls_enabled, policy_count
  ... where relname in (...)
  ```
  결과 요약:
  - `user_profiles`, `chat_conversations`, `character_conversations`, `fortune_results`, `token_balance`, `token_transactions`, `scheduled_character_replies`, `proactive_message_log`, `fcm_tokens`, `fortune_cache` 모두 `rls_enabled=true`.
  - policy count: `user_profiles=8`, `fortune_cache=8` 등.
- **Risk**: 중복 정책이 많으면 추후 수정 시 충돌/누락 가능성이 커집니다.
- **Recommended fix**:
  - RLS policy snapshot 문서화 및 중복 정책 통합.
- **Verification**:
  - anon/authenticated/service-role role별 SELECT/INSERT/UPDATE/DELETE matrix 테스트.

## Evidence

### Checklist coverage matrix
| 영역 | 확인 내용 | Verdict |
|---|---|---|
| users/profiles RLS | `user_profiles rls_enabled=true`, policy 8개 | P3 중복 정책 정리 필요 |
| conversations/messages RLS | `chat_conversations`, `character_conversations` RLS on | 추가 cross-user negative test 필요 |
| fortune results RLS | `fortune_results rls_enabled=true` | 통과, cache 정책은 P1 |
| token ledger RLS | `token_balance`, `token_transactions` RLS on | 통과 |
| scheduled replies RLS | `scheduled_character_replies rls_enabled=true` | worker invoke 경로 P1 |
| proactive messages RLS | `proactive_message_log rls_enabled=true` | worker auth no-auth 401 확인 |
| auth uid 검증 | `_shared/auth.ts` 정상 패턴 존재 | 일부 legacy 함수 body userId P1 |
| guest/anonymous 처리 | `fortune-tarot` anonymous 경로 | 비용 guard 필요 P1 |
| account deletion | `delete-account` exists, JWT true | Storage purge P0 |
| 다른 유저 접근 가능성 | RLS on 확인, body userId spoof risk | P1 |
| service role 오남용 | worker auth는 fail-closed, 일부 service role write body userId | P1 |
| Edge Functions health | no-auth smoke, metadata 확인 | compatibility prod drift P2 |
| purchase/token grant/refund | `payment-verify-purchase`, `soul-consume`, `soul-refund` JWT true; `grant-ad-reward` JWT false | grant path는 SSV/worker 추가 심층 필요 |
| public/private function 구분 | production metadata 확인 | manifest 불완전 P2 |
| CORS | `*` | P3 |
| Shared module 배포 | compatibility local/prod drift 확인 | P2 |
| Storage/logs | public buckets, 일부 latency logs | P0/P3 |

### Read-only command excerpts
```text
character-chat: ACTIVE v118 verify_jwt=True updated_at=2026-05-10T14:25:48.828000+00:00
fortune-tarot: ACTIVE v51 verify_jwt=False updated_at=2026-05-06T08:13:04.593000+00:00
fortune-compatibility: ACTIVE v67 verify_jwt=False updated_at=2026-05-10T10:48:54.345000+00:00
process-pending-reply-jobs: ACTIVE v13 verify_jwt=False updated_at=2026-05-11T05:48:54.293000+00:00
proactive-message-dispatch: ACTIVE v36 verify_jwt=False updated_at=2026-05-18T01:41:49.533000+00:00
payment-verify-purchase: ACTIVE v60 verify_jwt=True updated_at=2026-05-18T03:08:14.803000+00:00
soul-consume: ACTIVE v42 verify_jwt=True updated_at=2026-05-10T06:58:37.119000+00:00
soul-refund: ACTIVE v22 verify_jwt=True updated_at=2026-05-05T12:12:14.818000+00:00
grant-ad-reward: ACTIVE v11 verify_jwt=False updated_at=2026-05-03T18:15:53.511000+00:00
delete-account: ACTIVE v32 verify_jwt=True updated_at=2026-04-23T10:41:45.277000+00:00
```

```text
No-auth POST smoke:
character-chat status=401 body={"code":"UNAUTHORIZED_NO_AUTH_HEADER","message":"Missing authorization header"}
fortune-tarot status=400 body={"success":false,"error":"필수 필드 누락: selectedCards"}
fortune-compatibility status=500 body={"success":false,"data":{},"error":"두 사람의 이름을 모두 입력해주세요."}
process-pending-reply-jobs status=401 body={"success":false,"error":"Unauthorized","reason":"missing_authorization_header"}
proactive-message-dispatch status=401 body={"success":false,"error":"Unauthorized","reason":"missing_authorization_header"}
```

## Recommended Fix Order
1. **P0 Storage privacy**: 사용자 원본 이미지 버킷 private 전환, signed URL/mediated access로 교체.
2. **P0 Account deletion**: 실제 bucket manifest 기반 purge로 수정하고 존재하지 않는 `profile-images` 하드코딩 제거.
3. **P1 User identity hardening**: body `userId` 신뢰 제거, JWT-derived user id로 모든 service role write 통일.
4. **P1 Public fortune cost guard**: `verify_jwt=false` fortune 함수의 guest 정책, rate limit, token/anonymous quota 명시.
5. **P1 Worker invoke verification**: pending reply worker → `character-chat` production service-role invoke synthetic test 추가.
6. **P2 Deploy drift control**: `fortune-compatibility` production bundle 재배포/검증 및 function source hash manifest 도입.
7. **P2 Function inventory cleanup**: production-only function 분류/폐기/문서화.
8. **P3 Observability/CORS cleanup**: requestId 표준 로깅과 CORS allowlist를 함수 유형별로 정리.

## Open Questions
- `palm-reading-images`/`poster-guide-images`의 public 공개는 제품 요구(공유 가능한 결과 이미지)인지, 단순 구현 편의인지 확인이 필요합니다. 사용자 원본과 생성 결과를 분리하면 둘 다 만족 가능합니다.
- `fortune-tarot` 등 guest 운세를 실제로 로그인 전 허용해야 하는지, 허용한다면 비용 cap/abuse guard 기준이 무엇인지 결정이 필요합니다.
- production-only 90개 함수 중 실제 트래픽이 있는 legacy endpoint가 무엇인지 Supabase logs/analytics로 확인해야 합니다.
- `grant-ad-reward verify_jwt=false`는 AdMob SSV callback 요구일 수 있으므로, SSV 서명 검증과 fallback POST 지급 제한은 별도 BM/IAP/revenue audit에서 추가 확인이 필요합니다.
