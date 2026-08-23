-- P0 하드닝 적용 검증.
--
-- supabase/migrations/20260818000100 ~ 20260818000800 과
-- 20260819100000_fortune_result_cache.sql 을 적용한 뒤 라이브 DB 에서 실행한다.
--   supabase 대시보드 SQL editor 에 붙여넣거나
--   psql "$DATABASE_URL" -f supabase/scripts/verify-p0-hardening.sql
--
-- 기대 상태: 모든 행의 status 가 'PASS'. 하나라도 'FAIL' 이면 해당 마이그레이션이
-- 적용되지 않았거나 대시보드에서 out-of-band 로 되돌려진 것이다.
--
-- 정적 검사(rls-static-audit.sh)는 마이그레이션 파일만 본다. 이 스크립트는 실제
-- 권한/제약을 본다 — 2026-08-18 조사에서 두 결과가 갈렸던 지점이 정확히 이것이다.

WITH checks AS (

  -- [1] §2.0 프로덕션 장애: consume_token_atomic 이 INSERT 하는 'consumption' 이 허용값인가
  SELECT
    '1. token_transactions CHECK allows ''consumption''' AS check_name,
    EXISTS (
      SELECT 1 FROM pg_constraint
       WHERE conrelid = 'public.token_transactions'::regclass
         AND contype = 'c'
         AND pg_get_constraintdef(oid) ILIKE '%consumption%'
    ) AS ok,
    'consume_token_atomic 이 상시 23514 로 실패해 토큰 차감이 전혀 되지 않는 상태' AS failure_meaning

  -- [2] §2.1/2.2 금전 RPC 실행 권한 회수
  UNION ALL SELECT
    '2. money RPCs blocked for anon',
    NOT EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = 'public'
         AND p.proname IN (
           'grant_purchase_tokens_atomic', 'consume_token_atomic', 'refund_token_atomic',
           'consume_chat_streak', 'expire_old_subscriptions', 'grant_initial_tokens',
           'check_duplicate_fortune'
         )
         AND has_function_privilege('anon', p.oid, 'EXECUTE')
    ),
    'anon key 만으로 토큰 발행/환불 RPC 를 직접 호출할 수 있다'

  UNION ALL SELECT
    '3. money RPCs blocked for authenticated',
    NOT EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = 'public'
         AND p.proname IN (
           'grant_purchase_tokens_atomic', 'consume_token_atomic', 'refund_token_atomic',
           'consume_chat_streak', 'expire_old_subscriptions', 'grant_initial_tokens',
           'check_duplicate_fortune'
         )
         AND has_function_privilege('authenticated', p.oid, 'EXECUTE')
    ),
    '로그인한 사용자가 자기 소비를 무한 환불할 수 있다'

  -- [3] 클라이언트가 계속 써야 하는 RPC 는 살아 있어야 한다 (회귀 검사)
  UNION ALL SELECT
    '4. enqueue_pending_reply_job still callable by authenticated',
    EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = 'public' AND p.proname = 'enqueue_pending_reply_job'
         AND has_function_privilege('authenticated', p.oid, 'EXECUTE')
    ),
    'RN 채팅의 pending reply 큐가 깨진다 (chat-screen.tsx:3674)'

  UNION ALL SELECT
    '5. merge_character_conversation_messages still callable by authenticated',
    EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = 'public' AND p.proname = 'merge_character_conversation_messages'
         AND has_function_privilege('authenticated', p.oid, 'EXECUTE')
    ),
    'character-conversation-save 가 anon key + 호출자 JWT 로 호출하므로 대화 저장이 깨진다'

  -- [4] §2.3 replay 를 user 스코프로
  UNION ALL SELECT
    '6. consume_token_atomic replay is user-scoped',
    EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = 'public' AND p.proname = 'consume_token_atomic'
         AND p.prosrc ILIKE '%AND user_id = p_user_id%'
    ),
    '타인의 멱등키로 무과금 통과가 가능하다'

  -- [5] §2.4 구독 replay 가 기간을 연장하지 않는가
  UNION ALL SELECT
    '7. subscription replay does not extend expiry',
    EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = 'public' AND p.proname = 'activate_subscription_purchase_atomic'
         AND p.prosrc ILIKE '%CROSS_PLATFORM_SUBSCRIPTION_ACTIVE%'
    ),
    '한 번의 결제로 구독을 영구 갱신할 수 있고, 타 채널 활성 구독이 조용히 만료된다'

  -- [6] expire cron 스케줄
  UNION ALL SELECT
    '8. expire-old-subscriptions cron scheduled',
    EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'expire-old-subscriptions-hourly'),
    'subscriptions.status 가 만료일이 지나도 영구히 active 로 남는다'

  -- [7] 원장 RLS
  UNION ALL SELECT
    '9. ledger tables have RLS enabled',
    NOT EXISTS (
      SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
       WHERE n.nspname = 'public'
         AND c.relname IN ('token_balance', 'token_transactions', 'verified_purchases', 'subscriptions')
         AND NOT c.relrowsecurity
    ),
    '브라우저 anon key 로 원장을 직접 읽거나 쓸 수 있다'

  -- [8] 원장 쓰기 권한 회수
  UNION ALL SELECT
    '10. ledger tables not writable by anon/authenticated',
    NOT EXISTS (
      SELECT 1
        FROM information_schema.role_table_grants g
       WHERE g.table_schema = 'public'
         AND g.table_name IN ('token_balance', 'token_transactions', 'verified_purchases', 'subscriptions')
         AND g.grantee IN ('anon', 'authenticated')
         AND g.privilege_type IN ('INSERT', 'UPDATE', 'DELETE', 'TRUNCATE')
    ),
    'TRUNCATE 는 RLS 적용 대상이 아니므로 테이블 수준 권한이 남으면 위험하다'

  -- [9] §3 과금 게이트 캐시 테이블
  UNION ALL SELECT
    '11. fortune_result_cache exists and is service_role only',
    EXISTS (
      SELECT 1 FROM pg_class c JOIN pg_namespace n ON n.oid = c.relnamespace
       WHERE n.nspname = 'public' AND c.relname = 'fortune_result_cache' AND c.relrowsecurity
    )
    AND NOT EXISTS (
      SELECT 1 FROM information_schema.role_table_grants g
       WHERE g.table_schema = 'public' AND g.table_name = 'fortune_result_cache'
         AND g.grantee IN ('anon', 'authenticated')
    ),
    '운세 결과 캐시가 브라우저에 노출되거나 존재하지 않는다'

  -- [10] profile 보너스 원자 RPC
  UNION ALL SELECT
    '12. grant_profile_completion_bonus_atomic exists',
    EXISTS (
      SELECT 1 FROM pg_proc p JOIN pg_namespace n ON n.oid = p.pronamespace
       WHERE n.nspname = 'public' AND p.proname = 'grant_profile_completion_bonus_atomic'
    ),
    '프로필 보너스가 절대값 upsert 로 결제 토큰을 덮어쓰는 레이스가 남아 있다'
)
SELECT
  CASE WHEN ok THEN 'PASS' ELSE 'FAIL' END AS status,
  check_name,
  CASE WHEN ok THEN '' ELSE failure_meaning END AS if_failing
FROM checks
ORDER BY ok, check_name;

-- 참고 쿼리 — 장애가 실제로 해소됐는지 데이터로 확인한다.
-- 마이그레이션 적용 후 앱에서 운세를 1건 실행한 뒤 실행할 것.
-- 기대: consumption 행이 1건 이상 생긴다. 0 이면 아직 과금이 안 되고 있다.
--
--   SELECT transaction_type, count(*), max(created_at)
--     FROM token_transactions GROUP BY 1 ORDER BY 1;
