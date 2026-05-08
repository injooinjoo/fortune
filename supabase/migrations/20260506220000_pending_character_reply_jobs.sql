-- =============================================================================
-- pending_character_reply_jobs: 캐릭터 답장 생성 큐
-- =============================================================================
-- 기존 scheduled_character_replies 는 "이미 생성된 답장"의 발송 큐.
-- 이 테이블은 그 앞 단계 — "유저 메시지 발신됨, 아직 LLM 답장 생성 안 함" 큐.
--
-- 흐름:
--   1. 클라이언트 send 시 enqueue_pending_reply_job RPC 로 row INSERT (pending).
--      같은 (user, character) 의 pending row 는 cancel-and-replace.
--   2. 클라이언트가 character-chat Edge Function 을 jobId 와 함께 호출
--      (fire-and-forget + 10s timeout). 정상이면 함수가 claim_pending_reply_job_by_id
--      로 pending → processing 후 LLM 호출 → scheduled_character_replies INSERT.
--   3. 1-2 사이 앱 죽으면 process-pending-reply-jobs cron(1분 주기)이 30초 grace
--      후 claim_next_pending_reply_job 으로 픽업 → character-chat 호출.
--
-- 왜 grace 30초:
--   foreground 정상 흐름이 client 측 invoke 만으로 처리되는 시간을 양보.
--   30초 안에 client invoke 가 도달하면 cron 은 같은 row 못 가져감 (FOR UPDATE
--   SKIP LOCKED + status='pending' 체크).
-- =============================================================================

CREATE TABLE IF NOT EXISTS pending_character_reply_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  character_id TEXT NOT NULL,
  character_name TEXT NOT NULL,
  -- 클라이언트가 부여한 메시지 식별자. (user, character, user_message_id) 유니크 →
  -- 자동 재개 useEffect 가 같은 메시지로 재호출해도 중복 INSERT 방지.
  user_message_id TEXT NOT NULL,
  user_message TEXT NOT NULL,
  -- character-chat Edge Function 이 받는 body 와 동일한 JSON. cron 이 클라
  -- 없이도 동일 호출을 재현하기 위해 저장. system_prompt 는 stale 위험 있어
  -- 가능하면 client 가 매번 최신을 보내고 cron 은 받은 그대로 사용.
  request_payload JSONB NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'processing', 'done', 'failed', 'canceled')),
  attempt_count INT NOT NULL DEFAULT 0,
  -- retry backoff 용. 처음에는 created_at 과 같음.
  next_attempt_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  error_message TEXT,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ
);

-- cron pickup: 가장 오래된 pending + next_attempt_at 도래.
CREATE INDEX IF NOT EXISTS idx_pending_reply_jobs_pickup
  ON pending_character_reply_jobs (next_attempt_at)
  WHERE status = 'pending';

-- idempotency: 같은 user_message 로 재호출되어도 단일 row.
CREATE UNIQUE INDEX IF NOT EXISTS idx_pending_reply_jobs_user_message
  ON pending_character_reply_jobs (user_id, character_id, user_message_id);

-- enqueue 시 prior pending cancel 쿼리 가속.
CREATE INDEX IF NOT EXISTS idx_pending_reply_jobs_user_char_active
  ON pending_character_reply_jobs (user_id, character_id)
  WHERE status IN ('pending', 'processing');

-- updated_at 자동 갱신 트리거 (cleanup 기준 컬럼).
CREATE OR REPLACE FUNCTION pending_character_reply_jobs_set_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at := now();
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_pending_reply_jobs_updated_at
  ON pending_character_reply_jobs;
CREATE TRIGGER trg_pending_reply_jobs_updated_at
  BEFORE UPDATE ON pending_character_reply_jobs
  FOR EACH ROW EXECUTE FUNCTION pending_character_reply_jobs_set_updated_at();

-- RLS: 사용자는 자기 row 만 조회 (디버깅용). INSERT/UPDATE 는 service_role 또는
-- SECURITY DEFINER RPC 만. 클라가 직접 INSERT 못 하게 해서 cron LLM 비용 abuse 차단.
ALTER TABLE pending_character_reply_jobs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_select_own_pending_reply_jobs"
  ON pending_character_reply_jobs FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "service_role_full_access_pending_reply_jobs"
  ON pending_character_reply_jobs FOR ALL
  USING (auth.role() = 'service_role')
  WITH CHECK (auth.role() = 'service_role');

COMMENT ON TABLE pending_character_reply_jobs IS
  '캐릭터 답장 생성 대기 큐. enqueue_pending_reply_job RPC 로 INSERT, '
  'character-chat 또는 process-pending-reply-jobs cron 이 처리. '
  '앱 lifecycle 과 독립적으로 답장 생성 보장.';
