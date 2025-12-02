-- ============================================================================
-- user_saju 테이블 v2.0 컬럼 추가
-- 기존 데이터 유지하면서 십신, 12운성, 신살, 지장간 등 추가
-- ============================================================================

-- 오행 개별 컬럼 추가
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'element_wood') THEN
    ALTER TABLE user_saju ADD COLUMN element_wood INTEGER DEFAULT 0;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'element_fire') THEN
    ALTER TABLE user_saju ADD COLUMN element_fire INTEGER DEFAULT 0;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'element_earth') THEN
    ALTER TABLE user_saju ADD COLUMN element_earth INTEGER DEFAULT 0;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'element_metal') THEN
    ALTER TABLE user_saju ADD COLUMN element_metal INTEGER DEFAULT 0;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'element_water') THEN
    ALTER TABLE user_saju ADD COLUMN element_water INTEGER DEFAULT 0;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'weak_element') THEN
    ALTER TABLE user_saju ADD COLUMN weak_element TEXT;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'strong_element') THEN
    ALTER TABLE user_saju ADD COLUMN strong_element TEXT;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'enhancement_method') THEN
    ALTER TABLE user_saju ADD COLUMN enhancement_method TEXT;
  END IF;
END $$;

-- 십신 컬럼 추가 (주별)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'tenshin_year') THEN
    ALTER TABLE user_saju ADD COLUMN tenshin_year JSONB;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'tenshin_month') THEN
    ALTER TABLE user_saju ADD COLUMN tenshin_month JSONB;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'tenshin_day') THEN
    ALTER TABLE user_saju ADD COLUMN tenshin_day JSONB;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'tenshin_hour') THEN
    ALTER TABLE user_saju ADD COLUMN tenshin_hour JSONB;
  END IF;
END $$;

-- 지장간 컬럼 추가
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'jijanggan_year') THEN
    ALTER TABLE user_saju ADD COLUMN jijanggan_year JSONB;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'jijanggan_month') THEN
    ALTER TABLE user_saju ADD COLUMN jijanggan_month JSONB;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'jijanggan_day') THEN
    ALTER TABLE user_saju ADD COLUMN jijanggan_day JSONB;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'jijanggan_hour') THEN
    ALTER TABLE user_saju ADD COLUMN jijanggan_hour JSONB;
  END IF;
END $$;

-- 12운성 컬럼 추가
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'twelve_stages') THEN
    ALTER TABLE user_saju ADD COLUMN twelve_stages JSONB;
  END IF;
END $$;

-- 대운 상세 컬럼 추가
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'daewoon_direction') THEN
    ALTER TABLE user_saju ADD COLUMN daewoon_direction TEXT;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'daewoon_start_age') THEN
    ALTER TABLE user_saju ADD COLUMN daewoon_start_age INTEGER;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'daewoon_list') THEN
    ALTER TABLE user_saju ADD COLUMN daewoon_list JSONB;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'current_daewoon') THEN
    ALTER TABLE user_saju ADD COLUMN current_daewoon JSONB;
  END IF;
END $$;

-- 합충형파해 관계 컬럼 추가
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'relations') THEN
    ALTER TABLE user_saju ADD COLUMN relations JSONB;
  END IF;
END $$;

-- 신살 컬럼 추가 (길신/흉신 분리)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'sinsal_gilsin') THEN
    ALTER TABLE user_saju ADD COLUMN sinsal_gilsin JSONB;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'sinsal_hyungsin') THEN
    ALTER TABLE user_saju ADD COLUMN sinsal_hyungsin JSONB;
  END IF;
END $$;

-- 공망 컬럼 추가
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'gongmang') THEN
    ALTER TABLE user_saju ADD COLUMN gongmang JSONB;
  END IF;
END $$;

-- 납음오행 컬럼 추가
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'napeum_year') THEN
    ALTER TABLE user_saju ADD COLUMN napeum_year TEXT;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'napeum_month') THEN
    ALTER TABLE user_saju ADD COLUMN napeum_month TEXT;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'napeum_day') THEN
    ALTER TABLE user_saju ADD COLUMN napeum_day TEXT;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'napeum_hour') THEN
    ALTER TABLE user_saju ADD COLUMN napeum_hour TEXT;
  END IF;
END $$;

-- LLM 분석 결과 컬럼 추가 (기존과 다른 이름)
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'personality_traits') THEN
    ALTER TABLE user_saju ADD COLUMN personality_traits TEXT;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'fortune_summary') THEN
    ALTER TABLE user_saju ADD COLUMN fortune_summary TEXT;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'career_fortune') THEN
    ALTER TABLE user_saju ADD COLUMN career_fortune TEXT;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'wealth_fortune') THEN
    ALTER TABLE user_saju ADD COLUMN wealth_fortune TEXT;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'love_fortune') THEN
    ALTER TABLE user_saju ADD COLUMN love_fortune TEXT;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'health_fortune') THEN
    ALTER TABLE user_saju ADD COLUMN health_fortune TEXT;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'yearly_forecast') THEN
    ALTER TABLE user_saju ADD COLUMN yearly_forecast TEXT;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'life_advice') THEN
    ALTER TABLE user_saju ADD COLUMN life_advice TEXT;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'gpt_analysis') THEN
    ALTER TABLE user_saju ADD COLUMN gpt_analysis JSONB;
  END IF;
END $$;

-- 메타데이터 컬럼 추가
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'calculation_version') THEN
    ALTER TABLE user_saju ADD COLUMN calculation_version TEXT DEFAULT 'v1.0';
  END IF;

  IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_name = 'user_saju' AND column_name = 'birth_time_type') THEN
    ALTER TABLE user_saju ADD COLUMN birth_time_type TEXT;
  END IF;
END $$;

-- 기존 데이터에서 오행 개별 컬럼 업데이트
UPDATE user_saju
SET
  element_wood = COALESCE((element_balance->>'목')::int, 0),
  element_fire = COALESCE((element_balance->>'화')::int, 0),
  element_earth = COALESCE((element_balance->>'토')::int, 0),
  element_metal = COALESCE((element_balance->>'금')::int, 0),
  element_water = COALESCE((element_balance->>'수')::int, 0),
  weak_element = lacking_element,
  strong_element = dominant_element,
  calculation_version = 'v1.0'
WHERE element_wood IS NULL OR element_wood = 0;

-- 기존 ten_gods를 tenshin 형식으로 변환
UPDATE user_saju
SET
  tenshin_year = jsonb_build_object('cheongan', ten_gods->'year'->0),
  tenshin_month = jsonb_build_object('cheongan', ten_gods->'month'->0),
  tenshin_hour = jsonb_build_object('cheongan', ten_gods->'hour'->0)
WHERE ten_gods IS NOT NULL AND tenshin_year IS NULL;

-- 기존 spirits를 sinsal 형식으로 변환
UPDATE user_saju
SET sinsal_gilsin = to_jsonb(spirits)
WHERE spirits IS NOT NULL AND array_length(spirits, 1) > 0 AND sinsal_gilsin IS NULL;

-- 인덱스 추가
CREATE INDEX IF NOT EXISTS idx_user_saju_calculation_version ON user_saju(calculation_version);
CREATE INDEX IF NOT EXISTS idx_user_saju_day_stem ON user_saju(day_stem);

COMMENT ON TABLE user_saju IS 'v2.0 - 사용자 사주팔자 분석 데이터 (십신, 12운성, 신살, 지장간 등 추가)';
