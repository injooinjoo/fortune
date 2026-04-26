-- =============================================================================
-- 캐릭터 답장 지연 발송 스케줄 테이블
-- =============================================================================
-- character-chat Edge Function 이 LLM 응답을 즉시 클라이언트에 반환하지 않고,
-- 감정 기반 delaySec 만큼 미래 시각으로 deliver_at 을 잡아 row 에 저장.
--
-- 두 경로 중 먼저 도착한 쪽이 처리:
--   1. 클라이언트 foreground: setTimeout 만료 시 ack-scheduled-reply 호출 →
--      client_acked_at + delivered_at 마킹. cron 은 스킵.
--   2. 클라이언트 백그라운드: pg_cron 매분 deliver-due-replies 호출 →
--      character_conversations 에 append + push 발송 + delivered_at 마킹.
--
-- 사용자 후속 메시지: 같은 (user_id, character_id) 의 pending row 는
-- canceled_at 으로 마킹되어 cron 에서 스킵됨. character-chat 이 새 LLM 호출로
-- 합쳐진 답장을 다시 스케줄.
-- =============================================================================

CREATE TABLE IF NOT EXISTS scheduled_character_replies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  character_id TEXT NOT NULL,
  character_name TEXT NOT NULL,

  -- LLM 이 이미 생성해둔 답장 본문. 클라/cron 어느 쪽이 처리하든 같은 텍스트.
  content TEXT NOT NULL,
  segments JSONB NOT NULL DEFAULT '[]'::jsonb,
  emotion_tag TEXT,

  -- 스케줄링
  delay_sec INTEGER NOT NULL,
  deliver_at TIMESTAMPTZ NOT NULL,

  -- 처리 상태 (각 컬럼이 NULL/NOT NULL 로 단계 식별):
  --   client_acked_at: foreground 클라이언트가 렌더 + ack 호출 완료
  --   push_sent_at:    cron 이 push 발송 완료
  --   delivered_at:    최종 처리 완료 (ack 또는 cron 둘 중 하나가 set)
  --   canceled_at:     후속 메시지 도착으로 취소됨
  client_acked_at TIMESTAMPTZ,
  push_sent_at TIMESTAMPTZ,
  delivered_at TIMESTAMPTZ,
  canceled_at TIMESTAMPTZ,

  created_at TIMESTAMPTZ DEFAULT now()
);

-- cron worker 의 핵심 쿼리: deliver_at <= now() AND 셋 다 NULL
-- partial index 로 처리 대상만 빠르게 스캔.
CREATE INDEX IF NOT EXISTS idx_scheduled_replies_pending
  ON scheduled_character_replies (deliver_at)
  WHERE delivered_at IS NULL AND canceled_at IS NULL AND client_acked_at IS NULL;

-- character-chat 의 후속 메시지 cancel 쿼리:
-- WHERE user_id = ? AND character_id = ? AND delivered_at IS NULL AND canceled_at IS NULL
CREATE INDEX IF NOT EXISTS idx_scheduled_replies_user_char_pending
  ON scheduled_character_replies (user_id, character_id)
  WHERE delivered_at IS NULL AND canceled_at IS NULL;

-- =============================================================================
-- RLS
-- =============================================================================
-- 클라이언트는 자신의 row 만 SELECT/UPDATE (ack 용). INSERT 는 service role
-- (Edge Function) 만. cron worker 도 service role 로 동작하므로 자동 통과.

ALTER TABLE scheduled_character_replies ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own scheduled replies"
  ON scheduled_character_replies FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can ack own scheduled replies"
  ON scheduled_character_replies FOR UPDATE
  USING (auth.uid() = user_id);

-- INSERT 정책 없음 → 클라이언트가 직접 row 못 만듦. character-chat Edge
-- Function 이 service role 로 INSERT.

-- =============================================================================
-- pg_cron: 매분 deliver-due-replies 호출
-- =============================================================================
-- 기존 proactive-message-dispatch-5min 과 동일한 vault secret 재사용.
-- 새 환경에서 적용 시 vault 에 'proactive_dispatch_anon_key' 등록 선행 필수.
-- (production 에는 이미 등록돼있음 — 20260426000004 참고)

DO $$
BEGIN
  IF EXISTS (SELECT 1 FROM cron.job WHERE jobname = 'deliver-due-replies-1min') THEN
    PERFORM cron.unschedule('deliver-due-replies-1min');
  END IF;
  PERFORM cron.schedule(
    'deliver-due-replies-1min',
    '* * * * *',
    $cron$
    SELECT net.http_post(
      url := 'https://hayjukwfcsdmppairazc.supabase.co/functions/v1/deliver-due-replies',
      headers := jsonb_build_object(
        'Authorization', 'Bearer ' || (SELECT decrypted_secret FROM vault.decrypted_secrets WHERE name = 'proactive_dispatch_anon_key'),
        'Content-Type', 'application/json'
      ),
      body := '{}'::jsonb,
      timeout_milliseconds := 30000
    ) AS request_id;
    $cron$
  );
END $$;

-- =============================================================================
-- 코멘트
-- =============================================================================
COMMENT ON TABLE scheduled_character_replies IS
  '캐릭터 답장 지연 발송 큐. character-chat 이 INSERT, ack-scheduled-reply 또는 deliver-due-replies 가 처리.';
COMMENT ON COLUMN scheduled_character_replies.deliver_at IS
  'LLM compose 시각 + delay_sec. 클라 setTimeout 와 cron 모두 이 시각 기준.';
COMMENT ON COLUMN scheduled_character_replies.client_acked_at IS
  'foreground 클라이언트가 렌더 완료를 알린 시각. cron 은 이 컬럼 NOT NULL 이면 스킵.';
COMMENT ON COLUMN scheduled_character_replies.canceled_at IS
  '같은 user+character 에 새 메시지 도착 시 character-chat 이 set. cron 스킵.';
