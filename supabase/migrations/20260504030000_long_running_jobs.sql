-- long_running_jobs: 30s+ Edge Function 작업 (사주/타로/해몽/궁합 등) 를 위한
-- 범용 비동기 큐. scheduled_poster_jobs 는 image-gen 전용 (palm-reading 등)
-- 으로 남겨두고, 본 테이블은 LLM-text 무거운 fortune 들을 메신저 패턴으로
-- 일반화해 받는다.
--
-- scheduled_poster_jobs 와의 관계:
--   - 두 테이블 모두 같은 cron-driven 처리 패턴 (claim → process → push → done).
--   - 두 테이블 모두 supabase_realtime publication 등록 → RN 클라가 동시 구독.
--   - 향후 단계 (out of scope of Phase C) 에서 scheduled_poster_jobs 를 본
--     테이블로 통합 가능 — `job_type = 'poster-guide'` + payload.poster_type
--     을 추가하면 되도록 schema 가 호환되게 설계.
--
-- 흐름:
--   1. Edge Function (예: start-tarot-job) → INSERT row (status=pending)
--   2. process-long-running-jobs cron (1분 간격) → 가장 오래된 pending 픽업
--      → status=processing → job_type 별 worker dispatch (LLMFactory 등)
--      → 성공: result JSONB 저장, status=done, 카드 메시지 INSERT, push 발송
--      → 실패: status=failed, error_message 기록, 재시도 X
--   3. 클라는 realtime 으로 row 변경 구독 → progress 카드 phase 갱신.
--
-- 동시성: 단일 cron 1회당 1 job 픽업 — LLM provider rate limit 회피.

CREATE TABLE IF NOT EXISTS long_running_jobs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  character_id TEXT NOT NULL,
  character_name TEXT NOT NULL,
  -- job_type: 어떤 종류의 long-running 작업인지. process-long-running-jobs 워커가
  -- dispatch 키로 사용. 예: 'tarot' | 'dream' | 'compatibility' | 'traditional-saju'
  -- | 'poster-guide'(향후 통합 시).
  job_type TEXT NOT NULL,
  -- payload: 작업에 필요한 입력 (survey 답변, 컨텍스트 텍스트 등). worker 가 해석.
  payload JSONB NOT NULL DEFAULT '{}'::jsonb,
  status TEXT NOT NULL DEFAULT 'pending'
    CHECK (status IN ('pending', 'processing', 'done', 'failed')),
  -- phase: status='processing' 내부 사용자 가시 단계.
  -- queued        — INSERT 직후 (status='pending')
  -- preparing     — claim 직후, worker 시작 전 (선택적)
  -- analyzing     — LLM 호출 in-flight (text-fortune 의 메인 단계)
  -- finalizing    — 결과 받음, 메시지 INSERT + push 직전
  -- completed     — status='done' 동시에
  -- failed        — status='failed' 동시에
  phase TEXT NOT NULL DEFAULT 'queued'
    CHECK (phase IN ('queued', 'preparing', 'analyzing', 'finalizing', 'completed', 'failed')),
  phase_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  -- result: 완료 시 worker 가 반환하는 결과. Edge Function 응답 JSON 그대로 저장
  -- (메시지 envelope 은 별도로 character_conversations 에 INSERT 됨).
  result JSONB,
  error_message TEXT,
  retry_count INT NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  started_at TIMESTAMPTZ,
  completed_at TIMESTAMPTZ
);

-- cron pickup 인덱스 — 가장 오래된 pending 부터.
CREATE INDEX IF NOT EXISTS idx_long_running_jobs_pending
  ON long_running_jobs (created_at)
  WHERE status = 'pending';

-- user 별 진행상황 조회 (UI / 디버깅 / cold-start hydration).
CREATE INDEX IF NOT EXISTS idx_long_running_jobs_user_status
  ON long_running_jobs (user_id, status, created_at DESC);

-- RLS: 사용자는 자기 job 만 조회 가능. service_role (cron) 은 전체 접근.
-- Realtime 도 SELECT RLS 를 honor 하므로 본 정책이 곧 realtime 권한 게이트.
ALTER TABLE long_running_jobs ENABLE ROW LEVEL SECURITY;

-- DROP IF EXISTS + CREATE — 멱등 (재배포/롤포워드 시 동일 정책 재생성).
DROP POLICY IF EXISTS "users_can_select_own_long_running_jobs"
  ON long_running_jobs;
CREATE POLICY "users_can_select_own_long_running_jobs"
  ON long_running_jobs FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "service_role_full_access_long_running_jobs"
  ON long_running_jobs;
CREATE POLICY "service_role_full_access_long_running_jobs"
  ON long_running_jobs FOR ALL
  USING (auth.role() = 'service_role')
  WITH CHECK (auth.role() = 'service_role');

-- Realtime publication 등록 — 클라가 phase/status UPDATE 이벤트 수신.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND schemaname = 'public'
      AND tablename = 'long_running_jobs'
  ) THEN
    EXECUTE 'ALTER PUBLICATION supabase_realtime ADD TABLE long_running_jobs';
  END IF;
END
$$;

COMMENT ON TABLE long_running_jobs IS
  'Generic async queue for 30s+ LLM-driven fortune jobs (tarot/dream/compatibility/saju/etc.). '
  'Decouples slow LLM generation from user request lifecycle — user gets push notification '
  'when ready (messenger pattern). Parallel to scheduled_poster_jobs (image-gen specific).';
