-- Slice 2: Stage 2 reveal idempotency.
-- Stage 1 = proactive hooking 텍스트 발송 (proactive_message_log row + meta.hookForReveal=true)
-- Stage 2 = 유저 응답 시 character-chat 이 직전 hook을 claim 해서 사진 reveal.
--
-- 두 번 호출 (네트워크 retry / 빠른 연속 응답) 시 reveal 사진 중복 발송 방지를 위해
-- claim 패턴 사용:
--   UPDATE proactive_message_log SET revealed_at = now()
--   WHERE id = $1 AND revealed_at IS NULL
--   RETURNING *
-- 두 번째 호출은 빈 결과 → 일반 응답 경로.
--
-- 24h 윈도우 검사 + fast-path 인덱스를 함께 잡는다.

ALTER TABLE proactive_message_log
  ADD COLUMN IF NOT EXISTS revealed_at TIMESTAMPTZ NULL;

-- partial index: hook이고 아직 reveal 안 된 row만 — character-chat fast-path lookup 가속.
-- WHERE 절에 시간 비교 안 넣음 (시간은 쿼리 단계에서). created_at DESC 인덱스로 직전 hook 빠르게 찾기.
CREATE INDEX IF NOT EXISTS idx_proactive_log_unrevealed_hook
  ON proactive_message_log (user_id, character_id, scheduled_at DESC)
  WHERE meta->>'hookForReveal' = 'true' AND revealed_at IS NULL;

COMMENT ON COLUMN proactive_message_log.revealed_at IS
  'Stage 2 reveal claim 시점. NULL = 아직 reveal 안 됨. claim 패턴으로 idempotency 보장.';
