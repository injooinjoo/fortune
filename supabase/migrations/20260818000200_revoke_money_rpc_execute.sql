-- P0 보안: SECURITY DEFINER 금전 RPC 가 anon / authenticated 에게 열려 있다.
--
-- 라이브 ACL 실측 (2026-08-18, pg_proc.proacl + has_function_privilege):
--   grant_purchase_tokens_atomic   anon=X authenticated=X   ← 토큰 무한 발행
--   consume_token_atomic           anon=X authenticated=X
--   refund_token_atomic            anon=X authenticated=X   ← 환불 파밍
--   consume_chat_streak            anon=X authenticated=X
--   expire_old_subscriptions       anon=X authenticated=X
--   grant_initial_tokens           anon=X authenticated=X
--
-- 2026-06 하드닝 스윕(20260606143001/143020/143040/143060)은 grant_ad_reward_atomic,
-- activate_subscription_purchase_atomic, schedule_poster_job_with_charge,
-- claim_next_poster_job 네 개만 잠갔다. 20260606143000_harden_atomic_rpc_execute_grants.sql
-- 은 내용이 `SELECT 1` 한 줄뿐이라 아무것도 하지 않았다.
--
-- grant_purchase_tokens_atomic 이 특히 위험하다 — SECURITY DEFINER 이고 p_user_id 와
-- p_base_amount 를 인자로 받으며 auth.uid() 검사가 없다. anon key 만으로
-- POST /rest/v1/rpc/grant_purchase_tokens_atomic 을 호출해 임의 수량을 발행할 수 있고
-- 50% 첫구매 보너스까지 얹힌다. anon key 는 앱 번들에 이미 실려 있고, 웹을 열면
-- 브라우저 devtools 로 즉시 접근 가능해진다.
--
-- 호출부 확인 — 아래 6개 함수는 전부 service_role 클라이언트에서만 호출된다:
--   grant_purchase_tokens_atomic : payment-verify-purchase (SERVICE_ROLE_KEY)
--   consume_token_atomic         : soul-consume, _shared/token_charge.ts(character-chat /
--                                  generate-friend-avatar / generate-character-proactive-image,
--                                  전부 SERVICE_ROLE_KEY), fortune-tarot(supabaseAdmin)
--   refund_token_atomic          : soul-refund, _shared/token_charge.ts, process-poster-jobs
--   consume_chat_streak          : character-chat (SERVICE_ROLE_KEY)
--   expire_old_subscriptions     : 호출부 없음 (cron 전용, 20260818000500 에서 스케줄)
--   grant_initial_tokens         : auth.users AFTER INSERT 트리거 전용
--
-- 아래 2개는 클라이언트가 authenticated 로 직접 호출하므로 authenticated 를 유지한다:
--   merge_character_conversation_messages : character-conversation-save 가 anon key +
--     호출자 Authorization 으로 호출 → authenticated 롤로 실행된다. 함수 본문에 이미
--     `auth.role()='authenticated' AND auth.uid() <> p_user_id → 42501` 가드가 있어
--     타인 대화 덮어쓰기는 막혀 있다. anon 만 회수한다.
--   enqueue_pending_reply_job : RN 클라이언트가 직접 호출
--     (chat-screen.tsx:3674, story-chat-runtime.ts:1279). anon 만 회수한다.

-- ── 완전 잠금 (service_role 전용) ────────────────────────────────────────────

REVOKE ALL ON FUNCTION public.grant_purchase_tokens_atomic(UUID, INTEGER, TEXT, TEXT, TEXT, TEXT)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.grant_purchase_tokens_atomic(UUID, INTEGER, TEXT, TEXT, TEXT, TEXT)
  TO service_role;

REVOKE ALL ON FUNCTION public.consume_token_atomic(UUID, INTEGER, TEXT, TEXT, TEXT, TEXT)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.consume_token_atomic(UUID, INTEGER, TEXT, TEXT, TEXT, TEXT)
  TO service_role;

REVOKE ALL ON FUNCTION public.refund_token_atomic(UUID, TEXT, TEXT, TEXT, TEXT)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.refund_token_atomic(UUID, TEXT, TEXT, TEXT, TEXT)
  TO service_role;

REVOKE ALL ON FUNCTION public.consume_chat_streak(UUID)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.consume_chat_streak(UUID)
  TO service_role;

REVOKE ALL ON FUNCTION public.expire_old_subscriptions()
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.expire_old_subscriptions()
  TO service_role;

REVOKE ALL ON FUNCTION public.grant_initial_tokens()
  FROM PUBLIC, anon, authenticated;

-- ── anon 만 회수 (authenticated 는 실사용 경로가 있어 유지) ──────────────────

REVOKE ALL ON FUNCTION public.merge_character_conversation_messages(UUID, TEXT, JSONB, JSONB, INTEGER)
  FROM PUBLIC, anon;

REVOKE ALL ON FUNCTION public.enqueue_pending_reply_job(TEXT, TEXT, TEXT, TEXT, JSONB)
  FROM PUBLIC, anon;
