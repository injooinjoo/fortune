-- 사용자 소유 LLM 키(BYOK) 저장소.
--
-- ⚠️ 이 테이블은 **서드파티 자격증명**을 담는다. 사용자가 자기 OpenAI / Gemini /
-- Anthropic / Grok / OpenRouter 키를 연결하면 그 사용자의 운세는 그 키로 생성된다.
-- 키가 새면 피해는 우리 서비스가 아니라 **사용자 결제 계정**에 직접 발생한다.
--
-- 그래서 다음 세 가지를 스키마 수준에서 못 박는다:
--
--  1. 평문을 저장하지 않는다. Edge Function(_shared/llm/crypto.ts)이 AES-GCM 256
--     으로 봉인한 ciphertext + 레코드별 random 12바이트 IV 만 들어온다.
--     복호화 키(BYOK_ENCRYPTION_KEY)는 DB 가 아니라 함수 런타임 env 에 있으므로
--     DB 덤프 하나만으로는 키를 복원할 수 없다.
--     pgsodium / Vault 는 쓰지 않는다 — 이 프로젝트에서 확장 가용성이 미검증이다.
--
--  2. 클라이언트가 이 테이블에 **직접 닿을 수 있는 경로를 만들지 않는다.**
--     RLS 를 켜되 anon / authenticated 정책은 하나도 만들지 않고, 테이블 권한도
--     전부 회수한다. service_role 은 RLS 를 우회하므로 별도 정책이 필요 없다.
--     (fortune_result_cache 는 service_role 정책을 명시했지만 여기서는 일부러
--      정책을 0개로 둔다 — "정책이 하나도 없다" 가 감사 시 가장 읽기 쉬운 상태다.)
--
--  3. **ciphertext / iv 를 클라이언트가 읽을 수 있는 경로는 앞으로도 추가 금지.**
--     사용자가 자기 키에 대해 알 수 있는 것은 user-llm-key Edge Function 이
--     돌려주는 메타데이터(provider, last4, model, is_active, verified_at,
--     created_at)뿐이다. "본인 키니까 본인은 볼 수 있어야 한다" 는 요구가 와도
--     안 된다 — 한 번 쓰면 다시 읽히지 않는 것이 이 설계의 전부다.
--     SELECT 정책 추가, view 노출, PostgREST RPC 반환, 어느 쪽도 허용하지 않는다.
--
-- 계정 삭제 시: auth.users FK ON DELETE CASCADE 로 자동 회수된다.
-- delete-account/index.ts 의 DELETE_TARGETS 목록에 없어도 자격증명이 남지 않도록
-- 명시 삭제가 아니라 FK 로 보장한다.

CREATE TABLE IF NOT EXISTS user_llm_keys (
  user_id     UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  provider    TEXT NOT NULL
                CHECK (provider IN ('openai','gemini','anthropic','grok','openrouter')),
  ciphertext  TEXT NOT NULL,              -- base64 AES-GCM 암호문
  iv          TEXT NOT NULL,              -- base64 12바이트 IV (레코드마다 새로 뽑음)
  last4       TEXT NOT NULL,              -- UI 표시용 뒤 4자리. 키 복원 불가.
  model       TEXT,                       -- 사용자가 고른 모델 (없으면 서버 기본값)
  is_active   BOOLEAN NOT NULL DEFAULT true,
  verified_at TIMESTAMPTZ,                -- provider 실호출 검증 성공 시각
  created_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at  TIMESTAMPTZ NOT NULL DEFAULT now(),
  PRIMARY KEY (user_id, provider)
);

-- 조회는 항상 user_id 로 시작한다 → PK 선행 컬럼으로 커버되므로 추가 인덱스 없음.

ALTER TABLE user_llm_keys ENABLE ROW LEVEL SECURITY;

-- 정책 0개 = anon / authenticated 는 RLS 로 전부 막힌다.
-- service_role 만 RLS 를 우회해 접근한다 (user-llm-key Edge Function).

-- ── 테이블 권한 회수 (RLS 하나에만 의존하지 않는다) ─────────────────────────
-- TRUNCATE 는 RLS 적용 대상이 아니므로 권한 자체를 남겨두면 안 된다.
REVOKE ALL ON TABLE user_llm_keys FROM anon, authenticated;
GRANT ALL ON TABLE user_llm_keys TO service_role;

COMMENT ON TABLE user_llm_keys IS
  '사용자 소유 LLM API 키 (BYOK). AES-GCM 암호문만 저장하며 service_role 전용이다. 클라이언트가 ciphertext/iv 를 읽을 수 있는 경로(정책/뷰/RPC)를 추가하지 말 것.';
COMMENT ON COLUMN user_llm_keys.ciphertext IS
  'base64 AES-GCM 암호문. 복호화 키는 Edge Function env 의 BYOK_ENCRYPTION_KEY.';
COMMENT ON COLUMN user_llm_keys.iv IS
  'base64 12바이트 IV. 레코드마다 새로 생성한다 (GCM 에서 IV 재사용은 치명적).';
COMMENT ON COLUMN user_llm_keys.last4 IS
  '사용자가 어느 키를 연결했는지 알아보기 위한 뒤 4자리. 이것만으로 키 복원 불가.';
COMMENT ON COLUMN user_llm_keys.verified_at IS
  'provider 에 실제 호출을 보내 인증에 성공한 시각. NULL 이면 운세 생성에 쓰지 않는다.';

-- ── 키 검증 시도 레이트 리밋 ─────────────────────────────────────────────────
--
-- user-llm-key 의 POST 는 사용자가 준 문자열을 다섯 개 provider 에 실제로 보내
-- "이 키가 유효한가" 를 알려준다. 제한이 없으면 그 자체가 **훔친 API 키 검증기**로
-- 쓰일 수 있다 (우리 Supabase egress IP 로, 우리 프로젝트 이름을 달고).
-- 그래서 저장 시도 자체를 사용자별/IP별 슬라이딩 윈도로 센다.
--
-- 이 테이블도 service_role 전용이다. 카운터가 클라이언트에 보이면 우회 힌트가 된다.

CREATE TABLE IF NOT EXISTS user_llm_key_attempts (
  -- 'user:<uuid>' 또는 'ip:<addr>'. auth.users FK 를 걸지 않는 이유는 IP 버킷도
  -- 같은 테이블을 쓰기 때문이다.
  bucket_key        TEXT PRIMARY KEY,
  window_started_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  attempt_count     INTEGER NOT NULL DEFAULT 0
);

ALTER TABLE user_llm_key_attempts ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE user_llm_key_attempts FROM anon, authenticated;
GRANT ALL ON TABLE user_llm_key_attempts TO service_role;

COMMENT ON TABLE user_llm_key_attempts IS
  'user-llm-key POST(키 검증) 시도 카운터. 사용자/IP 버킷별 슬라이딩 윈도. service_role 전용.';

-- 증가 + 판정을 한 문장으로 처리한다. Edge Function 에서 SELECT 후 UPDATE 로
-- 나누면 동시 요청이 같은 카운트를 읽어 상한을 넘길 수 있다.
CREATE OR REPLACE FUNCTION public.record_user_llm_key_attempt(
  p_bucket_key     TEXT,
  p_window_seconds INTEGER,
  p_max_attempts   INTEGER
)
RETURNS TABLE (allowed BOOLEAN, retry_after_seconds INTEGER)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_now          TIMESTAMPTZ := now();
  v_window_start TIMESTAMPTZ;
  v_count        INTEGER;
BEGIN
  INSERT INTO user_llm_key_attempts AS a (bucket_key, window_started_at, attempt_count)
  VALUES (p_bucket_key, v_now, 1)
  ON CONFLICT (bucket_key) DO UPDATE
    SET window_started_at = CASE
          WHEN a.window_started_at < v_now - make_interval(secs => p_window_seconds)
            THEN v_now
          ELSE a.window_started_at
        END,
        attempt_count = CASE
          WHEN a.window_started_at < v_now - make_interval(secs => p_window_seconds)
            THEN 1
          ELSE a.attempt_count + 1
        END
  RETURNING a.window_started_at, a.attempt_count
  INTO v_window_start, v_count;

  RETURN QUERY SELECT
    v_count <= p_max_attempts,
    GREATEST(
      0,
      CEIL(
        EXTRACT(EPOCH FROM (v_window_start + make_interval(secs => p_window_seconds) - v_now))
      )::INTEGER
    );
END;
$$;

-- SECURITY DEFINER 함수는 기본적으로 PUBLIC 실행 권한이 붙는다. 반드시 회수한다.
REVOKE ALL ON FUNCTION public.record_user_llm_key_attempt(TEXT, INTEGER, INTEGER)
  FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.record_user_llm_key_attempt(TEXT, INTEGER, INTEGER)
  TO service_role;

COMMENT ON FUNCTION public.record_user_llm_key_attempt(TEXT, INTEGER, INTEGER) IS
  '키 검증 시도를 한 문장으로 증가시키고 상한 초과 여부를 돌려준다. service_role 전용.';
