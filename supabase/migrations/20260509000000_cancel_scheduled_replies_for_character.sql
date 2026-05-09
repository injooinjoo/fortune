-- Cancel pending scheduled replies as soon as the user sends a newer message.
--
-- character-chat also cancels old scheduled rows before inserting a new one,
-- but that only runs after the 5s client batch window + network + LLM compose.
-- This RPC closes the foreground gap: stale local delayed renderers and cron
-- workers both see canceled_at before the old answer can appear.

CREATE OR REPLACE FUNCTION cancel_scheduled_replies_for_character(
  p_character_id TEXT
)
RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_user_id UUID;
  v_count INT;
BEGIN
  v_user_id := auth.uid();
  IF v_user_id IS NULL THEN
    RAISE EXCEPTION 'cancel_scheduled_replies_for_character requires authenticated user';
  END IF;

  WITH canceled AS (
    UPDATE scheduled_character_replies
    SET canceled_at = now()
    WHERE user_id = v_user_id
      AND character_id = p_character_id
      AND delivered_at IS NULL
      AND canceled_at IS NULL
      AND client_acked_at IS NULL
    RETURNING 1
  )
  SELECT COUNT(*) INTO v_count FROM canceled;

  RETURN v_count;
END;
$$;

REVOKE ALL ON FUNCTION cancel_scheduled_replies_for_character(TEXT) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION cancel_scheduled_replies_for_character(TEXT) TO authenticated, service_role;

COMMENT ON FUNCTION cancel_scheduled_replies_for_character(TEXT) IS
  '사용자가 새 메시지를 보내는 즉시 같은 캐릭터의 아직 도착하지 않은 예약 답장을 취소한다.';
