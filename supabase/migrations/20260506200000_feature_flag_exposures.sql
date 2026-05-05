-- PR-0c: Feature Flag exposure logging — 어느 사용자/install 이 어떤 surface 에서
-- 어떤 flag 값을 받았는지 기록. ramp 의사결정 / 사용자 컴플레인 디버깅 / 안전성
-- 검증의 기반.
--
-- 디자인:
-- - 5개 surface 에서 발행: chat_open / menu_render / cost_modal / generation /
--   route_redirect
-- - flag 별 4 row (4 flag) 가 한 surface 호출 시 발행 — 평균적으로 표 row 가 빠르게 쌓임
-- - 운영: 30일 보존 정책 (별도 cron). 본 PR 은 보존 자체는 강제 안 함
-- - 개인정보: user_id (Supabase UUID 그대로) + install_id. 운세 컨텐츠/대화 X
-- - 인덱스: 사용자별 trace, flag 별 ramp 분석 양쪽 지원

CREATE TABLE IF NOT EXISTS feature_flag_exposures (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID,
  install_id TEXT NOT NULL,
  flag_name VARCHAR(50) NOT NULL,
  resolved_value JSONB NOT NULL,
  ramp_pct INTEGER NOT NULL,
  config_version BIGINT NOT NULL,
  surface VARCHAR(50) NOT NULL,
  evaluated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  -- 클라이언트 batch buffer 가 도착한 시각 (서버 receipt time)
  ingested_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE feature_flag_exposures IS
  'PR-0c: feature flag exposure log. ramp 분석 + 사용자 컴플레인 디버깅용.';
COMMENT ON COLUMN feature_flag_exposures.user_id IS
  '로그인 사용자 — Supabase auth.users.id. anon 사용자는 NULL.';
COMMENT ON COLUMN feature_flag_exposures.install_id IS
  '클라 디바이스 단위 ID — anon 사용자도 sticky bucket 추적 가능.';
COMMENT ON COLUMN feature_flag_exposures.surface IS
  'flag 평가 surface: chat_open | menu_render | cost_modal | generation | route_redirect.';
COMMENT ON COLUMN feature_flag_exposures.evaluated_at IS
  '클라/Edge 가 flag 평가한 시각. 디바이스 시계 기준이라 부정확 가능.';
COMMENT ON COLUMN feature_flag_exposures.ingested_at IS
  '서버 INSERT 시각. 정확한 시간 분석에 사용.';

-- 사용자/install 별 trace — 컴플레인 디버깅 ("나 하늘이 안 보임")
CREATE INDEX IF NOT EXISTS idx_feature_flag_exposures_user_flag_time
  ON feature_flag_exposures (user_id, flag_name, evaluated_at DESC)
  WHERE user_id IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_feature_flag_exposures_install_flag_time
  ON feature_flag_exposures (install_id, flag_name, evaluated_at DESC);

-- flag 별 ramp 분석 — 시간대별 노출 rate
CREATE INDEX IF NOT EXISTS idx_feature_flag_exposures_flag_time
  ON feature_flag_exposures (flag_name, evaluated_at DESC);

-- ─────────────────────────────────────────────────────────────────────────────
-- RLS — service_role 만 INSERT/SELECT. 클라/anon 직접 접근 차단.
-- (analytics 데이터에 접근하려면 Edge Function 거쳐야)
-- ─────────────────────────────────────────────────────────────────────────────
ALTER TABLE feature_flag_exposures ENABLE ROW LEVEL SECURITY;

-- 명시적 정책 안 만들면 anon/authenticated 는 SELECT/INSERT 모두 거부 (RLS 기본)

GRANT SELECT, INSERT ON feature_flag_exposures TO service_role;

-- ─────────────────────────────────────────────────────────────────────────────
-- 보존 정책 — 별도 cron 으로 처리. 본 마이그레이션에서는 가이드만 주석으로.
-- ─────────────────────────────────────────────────────────────────────────────
-- DELETE FROM feature_flag_exposures WHERE ingested_at < NOW() - INTERVAL '30 days';
-- 운영: 일일 cron 으로 30일 이전 row 삭제. 분석은 30일 윈도우에 충분.
