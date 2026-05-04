-- scheduled_poster_jobs: 비동기 poster-guide (palm-reading 등) 생성 큐.
--
-- 흐름:
--   1. 클라이언트 → start-poster-job edge function → 행 INSERT (status=pending)
--   2. process-poster-jobs cron (1분 간격) → 가장 오래된 pending 픽업
--      → status=processing → OpenAI gpt-image-2 호출 (~30-90s)
--      → 성공: 결과 image_url 저장, status=done, 메시지 INSERT, push 발송
--      → 실패: status=failed, error_message 기록, 재시도 X (사용자가 다시 시도)
--
-- 단일 user 동시 큐: 별도 락 없이 처리. 한 사용자가 여러 손금 동시 신청해도
-- cron 이 순차적으로 처리 (1번 1개씩, gpt-image-2 의 OpenAI rate limit 회피).

CREATE TABLE IF NOT EXISTS scheduled_poster_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  character_id TEXT NOT NULL,
  character_name TEXT NOT NULL,
  poster_type TEXT NOT NULL,              -- 'palm-reading' | 'beauty-simulation' | ...
  image_base64 TEXT,                       -- 사용자 사진 (필요 시)
  context_text TEXT,                       -- 추가 컨텍스트 (past-life 등)
  status TEXT NOT NULL DEFAULT 'pending'   -- 'pending' | 'processing' | 'done' | 'failed'
    CHECK (status IN ('pending', 'processing', 'done', 'failed')),
  result_image_url TEXT,                   -- 완료 시 storage public URL
  error_message TEXT,                      -- 실패 사유
  retry_count INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  started_at TIMESTAMPTZ,                  -- processing 진입 시각
  completed_at TIMESTAMPTZ                 -- done 또는 failed 진입 시각
);

-- cron pickup 인덱스 — 가장 오래된 pending 부터.
CREATE INDEX IF NOT EXISTS idx_poster_jobs_pending
  ON scheduled_poster_jobs (created_at)
  WHERE status = 'pending';

-- user 별 조회 (디버깅, 사용자 진행상태 표시용).
CREATE INDEX IF NOT EXISTS idx_poster_jobs_user_status
  ON scheduled_poster_jobs (user_id, status, created_at DESC);

-- RLS: 사용자는 자기 job 만 조회 가능. service_role (cron) 은 전체 접근.
ALTER TABLE scheduled_poster_jobs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "users_can_select_own_poster_jobs"
  ON scheduled_poster_jobs FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "service_role_full_access_poster_jobs"
  ON scheduled_poster_jobs FOR ALL
  USING (auth.role() = 'service_role')
  WITH CHECK (auth.role() = 'service_role');

COMMENT ON TABLE scheduled_poster_jobs IS
  'Async queue for gpt-image-2 based poster-guide generation (palm-reading, etc.). '
  'Decouples slow image generation from user request lifecycle — user gets push '
  'notification when ready (messenger pattern).';
