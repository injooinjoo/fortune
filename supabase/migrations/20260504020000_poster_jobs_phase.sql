-- scheduled_poster_jobs phase 추가 — 사용자에게 진행단계 실시간 노출용.
--
-- 기존 status (pending/processing/done/failed) 는 4단계 머신 상태 (cron 픽업
-- 가능 여부 결정용). phase 는 status='processing' 내부의 더 세밀한 단계를
-- 사용자 가시 라벨로 표시한다.
--
-- 단계 의미 (poster-guide / gpt-image-2 기준):
--   queued       INSERT 직후 cron 대기 중 (status='pending')
--   preparing    cron 픽업, generate-poster-guide 호출 직전 (template fetch 등)
--   rendering    gpt-image-2 호출 in-flight — 30~90초 lifecycle 대부분
--   finalizing   결과 image_url 받음, 메시지 INSERT + push 발송 중
--   completed    status='done' 동시에 phase='completed'
--   failed       status='failed' 동시에 phase='failed'
--
-- 클라이언트는 Supabase Realtime 으로 본 row 의 UPDATE 이벤트 구독 (RLS 가
-- 자기 user_id 만 SELECT 허용 → realtime 도 동일 정책 적용). phase 변화 시
-- progress 카드의 phase/currentStepIndex 갱신.

ALTER TABLE scheduled_poster_jobs
  ADD COLUMN IF NOT EXISTS phase TEXT NOT NULL DEFAULT 'queued'
    CHECK (phase IN ('queued', 'preparing', 'rendering', 'finalizing', 'completed', 'failed'));

ALTER TABLE scheduled_poster_jobs
  ADD COLUMN IF NOT EXISTS phase_updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- 기존 row 의 phase 를 현재 status 와 정합. ADD COLUMN 이 모두 'queued' 로 채웠는데
-- status='done' 인 row 가 'queued' 로 박히면 클라이언트 정렬상 어색하고 향후
-- realtime UPDATE 가 (cron 이 done 으로 다시 mark 하지 않으므로) 발생 안 해서
-- 영원히 queued 로 남는다. 멱등 — 기본값 그대로인 row 만 갱신.
UPDATE scheduled_poster_jobs
  SET phase = 'completed', phase_updated_at = COALESCE(completed_at, NOW())
  WHERE status = 'done' AND phase = 'queued';

UPDATE scheduled_poster_jobs
  SET phase = 'failed', phase_updated_at = COALESCE(completed_at, NOW())
  WHERE status = 'failed' AND phase = 'queued';

UPDATE scheduled_poster_jobs
  SET phase = 'rendering', phase_updated_at = COALESCE(started_at, NOW())
  WHERE status = 'processing' AND phase = 'queued';

-- Realtime publication 등록. supabase_realtime publication 은 Supabase 가
-- 기본 생성하며, 여기에 테이블을 add 해야 postgres_changes 이벤트가 발생.
-- 멱등 처리: 이미 publication 에 들어있으면 ALTER 가 에러를 던지므로 skip.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM pg_publication_tables
    WHERE pubname = 'supabase_realtime'
      AND schemaname = 'public'
      AND tablename = 'scheduled_poster_jobs'
  ) THEN
    EXECUTE 'ALTER PUBLICATION supabase_realtime ADD TABLE scheduled_poster_jobs';
  END IF;
END
$$;

COMMENT ON COLUMN scheduled_poster_jobs.phase IS
  'Fine-grained progress label within status=processing — surfaced to client '
  'progress card via realtime. queued|preparing|rendering|finalizing|completed|failed.';
