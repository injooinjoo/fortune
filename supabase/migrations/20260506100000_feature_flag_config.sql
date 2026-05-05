-- PR-0b: Feature Flag config — 사용자 단위 sticky ramp + per-flag TTL/safety class.
--
-- 디자인:
-- - 클라/Edge 양쪽이 동일 sticky-ramp 알고리즘 (sha1(flag:userId) % 10000 < ramp*100)
-- - 사용자가 ramp 안 → target_value, 밖 → default_value
-- - config_version: P0 takedown 시 클라/Edge 즉시 무효화 채널 (kill_switch_epoch)
-- - safety_class: 'visibility' | 'safety' | 'route' — 클라가 TTL/캐시 결정에 사용
-- - 4 flag 모두 default 값 + ramp_pct=0 으로 시드 — 사용자 영향 zero
--
-- 호환성: 새 테이블이라 기존 코드 영향 없음.

CREATE TABLE IF NOT EXISTS feature_flag_config (
  flag_name VARCHAR(50) PRIMARY KEY,
  ramp_pct INTEGER NOT NULL DEFAULT 0 CHECK (ramp_pct BETWEEN 0 AND 100),
  default_value JSONB NOT NULL,
  target_value JSONB NOT NULL,
  safety_class VARCHAR(20) NOT NULL CHECK (safety_class IN ('visibility', 'safety', 'route')),
  config_version BIGINT NOT NULL DEFAULT 1,
  description TEXT,
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE feature_flag_config IS
  'PR-0b: 사용자 단위 sticky ramp 기반 feature flag. config_version 이 변경되면 클라/Edge 캐시 즉시 무효화.';
COMMENT ON COLUMN feature_flag_config.ramp_pct IS
  '0~100. sha1(flag_name:userId) % 10000 < ramp_pct*100 인 사용자가 target_value 받음.';
COMMENT ON COLUMN feature_flag_config.default_value IS
  'ramp 밖 사용자가 받는 값. JSON literal (e.g. false, "legacy").';
COMMENT ON COLUMN feature_flag_config.target_value IS
  'ramp 안 사용자가 받는 값. JSON literal (e.g. true, "redirect_to_haneul").';
COMMENT ON COLUMN feature_flag_config.safety_class IS
  'visibility = UX 표시. safety = 결제/생성 게이팅. route = 라우팅. 클라 TTL 결정에 사용.';
COMMENT ON COLUMN feature_flag_config.config_version IS
  'P0 takedown용. 변경 시 클라/Edge 캐시 즉시 무효화 (kill_switch_epoch 역할).';

-- updated_at 자동 갱신 트리거 (옛 row 가 새 ramp_pct 받을 때 캐시 무효화 채널).
-- config_version 도 변경 마다 +1 — 명시적 INCREMENT 필요. 별도 RPC 또는 SQL 로 갱신.
CREATE OR REPLACE FUNCTION feature_flag_config_touch()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.updated_at := NOW();
  IF NEW.config_version = OLD.config_version THEN
    NEW.config_version := OLD.config_version + 1;
  END IF;
  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS feature_flag_config_touch_trg ON feature_flag_config;
CREATE TRIGGER feature_flag_config_touch_trg
  BEFORE UPDATE ON feature_flag_config
  FOR EACH ROW EXECUTE FUNCTION feature_flag_config_touch();

-- 4개 flag 시드 — 모두 default_value 로 사용자 영향 zero. 점진 ramp 는 운영 시 UPDATE.
INSERT INTO feature_flag_config (flag_name, ramp_pct, default_value, target_value, safety_class, description) VALUES
  ('haneul_enabled', 0, 'false'::jsonb, 'true'::jsonb, 'visibility',
    '하늘이 캐릭터 가시성. PR-B 머지 후 ramp.'),
  ('haneul_fortune_enabled', 0, 'false'::jsonb, 'true'::jsonb, 'safety',
    '하늘이 운세 메뉴/결과 응답. cost gate 더블체크. haneul_enabled 의존.'),
  ('direct_chips_enabled', 0, 'false'::jsonb, 'true'::jsonb, 'safety',
    '하늘이 direct value chip. cost confirmation 우회 위험 시 끄기. haneul_fortune_enabled 의존.'),
  ('fortune_route_behavior', 0, '"legacy"'::jsonb, '"redirect_to_haneul"'::jsonb, 'route',
    '/fortune 라우트 동작: legacy | redirect_to_haneul | disabled. PR-C 머지 후 ramp.')
ON CONFLICT (flag_name) DO NOTHING;

-- ─────────────────────────────────────────────────────────────────────────────
-- 권한
-- ─────────────────────────────────────────────────────────────────────────────
-- - service_role: 전체 (Edge Function 이 INSERT/UPDATE 가능 — 운영 console 또는 cron)
-- - authenticated/anon: SELECT 만 (클라가 직접 읽을 수 있어야 sticky ramp 자체 평가)
ALTER TABLE feature_flag_config ENABLE ROW LEVEL SECURITY;

CREATE POLICY feature_flag_config_read_all
  ON feature_flag_config
  FOR SELECT
  USING (true);

-- INSERT/UPDATE/DELETE 는 service_role 만 (RLS bypass 함). 명시적 정책 안 만듦.

GRANT SELECT ON feature_flag_config TO authenticated, anon;
GRANT ALL ON feature_flag_config TO service_role;
