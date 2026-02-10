-- 신규 사용자 초기 토큰 지급 (30토큰)
-- 로그인 전 (anonymous 포함) 모든 신규 유저에게 자동 지급

-- 1. 신규 사용자 토큰 지급 함수
CREATE OR REPLACE FUNCTION grant_initial_tokens()
RETURNS TRIGGER AS $$
DECLARE
  v_initial_tokens INT := 30; -- 초기 지급 토큰
BEGIN
  -- token_balance에 초기 토큰 지급
  INSERT INTO token_balance (user_id, balance, total_earned, created_at, updated_at)
  VALUES (NEW.id, v_initial_tokens, v_initial_tokens, NOW(), NOW())
  ON CONFLICT (user_id) DO NOTHING; -- 이미 있으면 무시 (중복 방지)

  RAISE LOG '[grant_initial_tokens] Granted % tokens to new user: %', v_initial_tokens, NEW.id;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 2. auth.users INSERT 트리거 생성
DROP TRIGGER IF EXISTS on_auth_user_created_grant_tokens ON auth.users;

CREATE TRIGGER on_auth_user_created_grant_tokens
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION grant_initial_tokens();

-- 3. 기존 사용자 중 토큰이 없는 유저에게 초기 토큰 지급 (백필)
INSERT INTO token_balance (user_id, balance, total_earned, created_at, updated_at)
SELECT
  u.id,
  30, -- 초기 토큰
  30,
  NOW(),
  NOW()
FROM auth.users u
LEFT JOIN token_balance tb ON u.id = tb.user_id
WHERE tb.user_id IS NULL;

COMMENT ON FUNCTION grant_initial_tokens() IS '신규 사용자에게 30토큰 자동 지급';