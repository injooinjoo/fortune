-- character_conversations.messages JSONB 동시 쓰기 race fix
--
-- 진단: character-conversation-save (사용자 클라) 와 deliver-due-replies (cron)
-- 가 같은 (user_id, character_id) row 의 messages JSONB 를 동시에 update/upsert
-- 할 때, 후행이 선행을 덮어쓰며 메시지 손실 가능. 1.0.11 production 에서 빠른
-- 연속 송신 5개 중 일부 누락 위험 + cron 이 user 가 막 추가한 message 를
-- 못 본 상태로 자체 array 를 덮어씀.
--
-- 해결 (메신저 앱 표준 — Signal/WhatsApp 의 "append-only + idempotent by id"):
--   1) advisory lock: (user_id, character_id) 해시로 직렬화. 다른 conversation
--      영향 없음. transaction-scoped 라 함수 종료 시 자동 해제.
--   2) 머지 by message id: 기존 messages + 신규 messages 중 id 가 기존에
--      없는 것만 append. 동일 id 는 멱등 (재전송/재시도 안전).
--   3) cap 트림 (default 200): 메신저 일반 정책 — 서버는 최근 N개만, 클라
--      SQLite 가 source of truth.
--
-- 호출자 분리:
--   - character-conversation-save: SECURITY DEFINER + auth.uid() 체크로
--     사용자가 자기 row 만 수정 가능
--   - deliver-due-replies: service_role 로 호출, auth.role() 체크 통과

CREATE OR REPLACE FUNCTION merge_character_conversation_messages(
  p_user_id UUID,
  p_character_id TEXT,
  p_incoming_messages JSONB,
  p_runtime_state JSONB DEFAULT NULL,
  p_max_messages INT DEFAULT 200
) RETURNS INT
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_lock_key BIGINT;
  v_existing JSONB;
  v_merged JSONB;
  v_count INT;
BEGIN
  -- 권한 체크: authenticated 사용자는 자기 row 만 수정 가능. service_role 은
  -- cron 이라 자유. anon/public 호출은 auth.role() 가 'anon' 이라 차단됨.
  IF auth.role() = 'authenticated' AND auth.uid() <> p_user_id THEN
    RAISE EXCEPTION 'unauthorized: cannot modify another user''s conversation'
      USING ERRCODE = '42501';
  END IF;
  IF auth.role() NOT IN ('authenticated', 'service_role') THEN
    RAISE EXCEPTION 'unauthorized: anon role not allowed'
      USING ERRCODE = '42501';
  END IF;

  IF p_incoming_messages IS NULL OR jsonb_typeof(p_incoming_messages) <> 'array' THEN
    RAISE EXCEPTION 'p_incoming_messages must be a JSONB array'
      USING ERRCODE = '22023';
  END IF;

  -- (user_id, character_id) hash 로 advisory transaction lock.
  -- hashtextextended 는 64-bit, conversation 1개당 1개 lock — 다른
  -- conversation 처리 throughput 영향 없음.
  v_lock_key := hashtextextended(p_user_id::text || ':' || p_character_id, 0);
  PERFORM pg_advisory_xact_lock(v_lock_key);

  -- 기존 messages 로드 (lock 잡힌 후라 race 없음)
  SELECT messages INTO v_existing
  FROM character_conversations
  WHERE user_id = p_user_id AND character_id = p_character_id;

  IF v_existing IS NULL THEN
    v_existing := '[]'::jsonb;
  END IF;

  -- id 머지: 기존 모든 메시지 유지 + 신규 중 id 가 기존에 없는 것만 append.
  -- 메시지 객체에 id 필드 없으면 (legacy/system) 모두 append (dedup 불가).
  WITH existing_ids AS (
    SELECT (elem->>'id') AS id
    FROM jsonb_array_elements(v_existing) elem
    WHERE elem ? 'id'
  ),
  new_messages AS (
    SELECT elem
    FROM jsonb_array_elements(p_incoming_messages) WITH ORDINALITY AS t(elem, ord)
    WHERE NOT (elem ? 'id')
       OR (elem->>'id') NOT IN (SELECT id FROM existing_ids)
    ORDER BY ord
  )
  SELECT v_existing || COALESCE((SELECT jsonb_agg(elem) FROM new_messages), '[]'::jsonb)
  INTO v_merged;

  -- max cap 트림: 오래된 것 제거하되 시간 순서 보존.
  IF jsonb_array_length(v_merged) > p_max_messages THEN
    WITH numbered AS (
      SELECT elem, ord
      FROM jsonb_array_elements(v_merged) WITH ORDINALITY AS t(elem, ord)
    ),
    keep AS (
      SELECT elem, ord
      FROM numbered
      WHERE ord > (SELECT max(ord) FROM numbered) - p_max_messages
      ORDER BY ord
    )
    SELECT jsonb_agg(elem ORDER BY ord) INTO v_merged FROM keep;
  END IF;

  v_count := jsonb_array_length(v_merged);

  INSERT INTO character_conversations (
    user_id, character_id, messages, runtime_state, last_message_at, updated_at
  ) VALUES (
    p_user_id,
    p_character_id,
    v_merged,
    COALESCE(p_runtime_state, '{}'::jsonb),
    NOW(),
    NOW()
  )
  ON CONFLICT (user_id, character_id) DO UPDATE SET
    messages = v_merged,
    runtime_state = COALESCE(p_runtime_state, character_conversations.runtime_state),
    last_message_at = NOW(),
    updated_at = NOW();

  RETURN v_count;
END;
$$;

GRANT EXECUTE ON FUNCTION merge_character_conversation_messages(
  UUID, TEXT, JSONB, JSONB, INT
) TO authenticated, service_role;

COMMENT ON FUNCTION merge_character_conversation_messages IS
'character_conversations.messages 에 advisory lock + id-dedup 머지 + cap 트림으로 동시 쓰기 race condition 차단. 클라/cron 양쪽 호출 안전. 동일 message id 재전송 시 멱등.';
