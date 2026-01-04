-- =====================================================
-- Cohort 기반 Fortune Pool 최적화 시스템
-- 목표: LLM API 호출 90% 절감
-- =====================================================

-- 1. cohort_fortune_pool: 사전 생성된 운세 결과 저장
CREATE TABLE IF NOT EXISTS cohort_fortune_pool (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fortune_type TEXT NOT NULL,
  cohort_hash TEXT NOT NULL,           -- MD5(정규화된 cohort 값)
  cohort_data JSONB NOT NULL,          -- { ageGroup: "30대", gender: "남", zodiac: "용", ... }
  result_template JSONB NOT NULL,      -- LLM 생성 결과 ({{userName}} 등 플레이스홀더 포함)
  quality_score DECIMAL(3,2) DEFAULT 1.00,  -- 0.00~1.00 (품질 점수)
  usage_count INTEGER DEFAULT 0,       -- 사용 횟수
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 동일 cohort에 여러 결과 허용 (50개씩)
CREATE INDEX idx_cohort_pool_type_hash ON cohort_fortune_pool(fortune_type, cohort_hash);
CREATE INDEX idx_cohort_pool_usage ON cohort_fortune_pool(fortune_type, usage_count);
CREATE INDEX idx_cohort_pool_quality ON cohort_fortune_pool(fortune_type, quality_score DESC);

-- 2. cohort_pool_settings: 운세별 cohort 설정
CREATE TABLE IF NOT EXISTS cohort_pool_settings (
  fortune_type TEXT PRIMARY KEY,
  target_pool_size INTEGER DEFAULT 50,     -- cohort당 목표 결과 수
  max_pool_size INTEGER DEFAULT 75,        -- cohort당 최대 결과 수
  cohort_dimensions JSONB NOT NULL,        -- ["ageGroup", "gender", "zodiac"]
  dimension_values JSONB NOT NULL,         -- { ageGroup: ["10대","20대",...], gender: ["남","여","기타"], ... }
  placeholders JSONB DEFAULT '[]'::jsonb,  -- ["{{userName}}", "{{age}}"]
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 3. 초기 설정 데이터 삽입
INSERT INTO cohort_pool_settings (fortune_type, target_pool_size, cohort_dimensions, dimension_values, placeholders) VALUES

-- Daily (일일 운세): 5×12×5 = 300 cohorts
('daily', 50,
 '["period", "zodiac", "element"]'::jsonb,
 '{
   "period": ["새벽", "아침", "오후", "저녁", "밤"],
   "zodiac": ["쥐", "소", "호랑이", "토끼", "용", "뱀", "말", "양", "원숭이", "닭", "개", "돼지"],
   "element": ["목", "화", "토", "금", "수"]
 }'::jsonb,
 '["{{userName}}", "{{birthYear}}"]'::jsonb),

-- Love (연애 운세): 5×3×4×12 = 720 cohorts
('love', 50,
 '["ageGroup", "gender", "relationshipStatus", "zodiac"]'::jsonb,
 '{
   "ageGroup": ["10대", "20대", "30대", "40대", "50대+"],
   "gender": ["남", "여", "기타"],
   "relationshipStatus": ["솔로", "썸", "연애중", "기혼"],
   "zodiac": ["쥐", "소", "호랑이", "토끼", "용", "뱀", "말", "양", "원숭이", "닭", "개", "돼지"]
 }'::jsonb,
 '["{{userName}}", "{{age}}", "{{datingStyles}}", "{{charmPoints}}"]'::jsonb),

-- Compatibility (궁합): 12×12×3 = 432 cohorts
('compatibility', 50,
 '["zodiac1", "zodiac2", "genderPair"]'::jsonb,
 '{
   "zodiac1": ["쥐", "소", "호랑이", "토끼", "용", "뱀", "말", "양", "원숭이", "닭", "개", "돼지"],
   "zodiac2": ["쥐", "소", "호랑이", "토끼", "용", "뱀", "말", "양", "원숭이", "닭", "개", "돼지"],
   "genderPair": ["남녀", "남남", "여여"]
 }'::jsonb,
 '["{{person1_name}}", "{{person2_name}}", "{{person1_birth}}", "{{person2_birth}}"]'::jsonb),

-- Career (커리어): 5×3×10 = 150 cohorts
('career', 50,
 '["ageGroup", "gender", "industry"]'::jsonb,
 '{
   "ageGroup": ["10대", "20대", "30대", "40대", "50대+"],
   "gender": ["남", "여", "기타"],
   "industry": ["IT", "금융", "의료", "교육", "서비스", "제조", "예술", "공공", "스타트업", "기타"]
 }'::jsonb,
 '["{{userName}}", "{{skills}}", "{{primaryConcern}}"]'::jsonb),

-- Health (건강): 5×3×4×5 = 300 cohorts
('health', 50,
 '["ageGroup", "gender", "season", "element"]'::jsonb,
 '{
   "ageGroup": ["10대", "20대", "30대", "40대", "50대+"],
   "gender": ["남", "여", "기타"],
   "season": ["봄", "여름", "가을", "겨울"],
   "element": ["목", "화", "토", "금", "수"]
 }'::jsonb,
 '["{{userName}}", "{{concernedParts}}", "{{healthScore}}"]'::jsonb),

-- Traditional Saju (전통 사주): 10×5×5 = 250 cohorts
('traditional-saju', 50,
 '["dayMaster", "elementBalance", "questionCategory"]'::jsonb,
 '{
   "dayMaster": ["甲", "乙", "丙", "丁", "戊", "己", "庚", "辛", "壬", "癸"],
   "elementBalance": ["목과다", "화과다", "토과다", "금과다", "수과다"],
   "questionCategory": ["연애", "취업", "건강", "금전", "대인"]
 }'::jsonb,
 '["{{userName}}", "{{question}}", "{{sajuPillars}}"]'::jsonb),

-- Dream (해몽): 10×5×12 = 600 cohorts
('dream', 50,
 '["dreamCategory", "emotion", "zodiac"]'::jsonb,
 '{
   "dreamCategory": ["날기", "떨어짐", "추격", "시험", "늦음", "죽음", "돈", "동물", "물", "사람"],
   "emotion": ["공포", "불안", "기쁨", "슬픔", "중립"],
   "zodiac": ["쥐", "소", "호랑이", "토끼", "용", "뱀", "말", "양", "원숭이", "닭", "개", "돼지"]
 }'::jsonb,
 '["{{userName}}", "{{dreamContent}}", "{{specificSymbols}}"]'::jsonb),

-- Face Reading (관상): 8×3×5 = 120 cohorts
('face-reading', 50,
 '["faceShape", "gender", "ageGroup"]'::jsonb,
 '{
   "faceShape": ["타원형", "둥근형", "각진형", "긴형", "하트형", "마름모형", "삼각형", "역삼각형"],
   "gender": ["남", "여", "기타"],
   "ageGroup": ["10대", "20대", "30대", "40대", "50대+"]
 }'::jsonb,
 '["{{userName}}", "{{faceFeatures}}"]'::jsonb),

-- MBTI (이미 최적): 16 cohorts
('mbti', 50,
 '["mbti"]'::jsonb,
 '{
   "mbti": ["INTJ", "INTP", "ENTJ", "ENTP", "INFJ", "INFP", "ENFJ", "ENFP", "ISTJ", "ISFJ", "ESTJ", "ESFJ", "ISTP", "ISFP", "ESTP", "ESFP"]
 }'::jsonb,
 '["{{userName}}"]'::jsonb),

-- Lucky Items (행운 아이템): 10 cohorts
('lucky-items', 50,
 '["category"]'::jsonb,
 '{
   "category": ["work", "date", "exercise", "beauty", "digital", "fashion", "car", "hobby", "sleep", "charm"]
 }'::jsonb,
 '["{{userName}}"]'::jsonb),

-- Talent (재능): 5×3×8 = 120 cohorts
('talent', 50,
 '["ageGroup", "gender", "talentArea"]'::jsonb,
 '{
   "ageGroup": ["10대", "20대", "30대", "40대", "50대+"],
   "gender": ["남", "여", "기타"],
   "talentArea": ["예술", "기술", "리더십", "분석", "창의", "사회", "실무", "학문"]
 }'::jsonb,
 '["{{userName}}", "{{concerns}}", "{{interests}}"]'::jsonb),

-- Investment (투자): 5×3×5 = 75 cohorts
('investment', 50,
 '["ageGroup", "riskTolerance", "element"]'::jsonb,
 '{
   "ageGroup": ["10대", "20대", "30대", "40대", "50대+"],
   "riskTolerance": ["보수적", "중립", "공격적"],
   "element": ["목", "화", "토", "금", "수"]
 }'::jsonb,
 '["{{userName}}", "{{investmentGoal}}"]'::jsonb),

-- Ex-lover (전연인): 5×4×3 = 60 cohorts
('ex-lover', 50,
 '["emotionState", "timeElapsed", "contactStatus"]'::jsonb,
 '{
   "emotionState": ["미련", "분노", "무덤덤", "그리움", "혼란"],
   "timeElapsed": ["1개월내", "1-6개월", "6-12개월", "1년이상"],
   "contactStatus": ["연락중", "연락끊김", "차단"]
 }'::jsonb,
 '["{{userName}}", "{{exName}}"]'::jsonb),

-- Blind Date (소개팅): 5×3×3 = 45 cohorts
('blind-date', 50,
 '["ageGroup", "gender", "dateGoal"]'::jsonb,
 '{
   "ageGroup": ["10대", "20대", "30대", "40대", "50대+"],
   "gender": ["남", "여", "기타"],
   "dateGoal": ["진지한만남", "가벼운만남", "친구먼저"]
 }'::jsonb,
 '["{{userName}}", "{{preferences}}"]'::jsonb)

ON CONFLICT (fortune_type) DO UPDATE SET
  target_pool_size = EXCLUDED.target_pool_size,
  cohort_dimensions = EXCLUDED.cohort_dimensions,
  dimension_values = EXCLUDED.dimension_values,
  placeholders = EXCLUDED.placeholders,
  updated_at = NOW();

-- 4. Helper Functions

-- 4.1 Pool 크기 조회
CREATE OR REPLACE FUNCTION get_cohort_pool_size(
  p_fortune_type TEXT,
  p_cohort_hash TEXT
) RETURNS INTEGER AS $$
BEGIN
  RETURN (
    SELECT COUNT(*)::INTEGER
    FROM cohort_fortune_pool
    WHERE fortune_type = p_fortune_type
      AND cohort_hash = p_cohort_hash
  );
END;
$$ LANGUAGE plpgsql;

-- 4.2 랜덤 결과 선택
CREATE OR REPLACE FUNCTION get_random_cohort_result(
  p_fortune_type TEXT,
  p_cohort_hash TEXT
) RETURNS JSONB AS $$
DECLARE
  v_result JSONB;
  v_id UUID;
BEGIN
  SELECT id, result_template INTO v_id, v_result
  FROM cohort_fortune_pool
  WHERE fortune_type = p_fortune_type
    AND cohort_hash = p_cohort_hash
    AND quality_score >= 0.5  -- 품질 낮은 결과 제외
  ORDER BY RANDOM()
  LIMIT 1;

  -- 사용 횟수 증가
  IF v_id IS NOT NULL THEN
    UPDATE cohort_fortune_pool
    SET usage_count = usage_count + 1,
        updated_at = NOW()
    WHERE id = v_id;
  END IF;

  RETURN v_result;
END;
$$ LANGUAGE plpgsql;

-- 4.3 Cohort별 통계
CREATE OR REPLACE FUNCTION get_cohort_pool_stats(
  p_fortune_type TEXT DEFAULT NULL
) RETURNS TABLE (
  fortune_type TEXT,
  total_cohorts BIGINT,
  total_results BIGINT,
  avg_pool_size NUMERIC,
  min_pool_size BIGINT,
  max_pool_size BIGINT
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    cp.fortune_type,
    COUNT(DISTINCT cp.cohort_hash) as total_cohorts,
    COUNT(*) as total_results,
    ROUND(COUNT(*)::NUMERIC / NULLIF(COUNT(DISTINCT cp.cohort_hash), 0), 2) as avg_pool_size,
    MIN(sub.pool_size) as min_pool_size,
    MAX(sub.pool_size) as max_pool_size
  FROM cohort_fortune_pool cp
  JOIN (
    SELECT fortune_type, cohort_hash, COUNT(*) as pool_size
    FROM cohort_fortune_pool
    GROUP BY fortune_type, cohort_hash
  ) sub ON cp.fortune_type = sub.fortune_type AND cp.cohort_hash = sub.cohort_hash
  WHERE p_fortune_type IS NULL OR cp.fortune_type = p_fortune_type
  GROUP BY cp.fortune_type;
END;
$$ LANGUAGE plpgsql;

-- 4.4 부족한 Cohort 목록 조회
CREATE OR REPLACE FUNCTION get_underfilled_cohorts(
  p_fortune_type TEXT,
  p_threshold INTEGER DEFAULT 25  -- 50의 절반 미만이면 부족
) RETURNS TABLE (
  cohort_hash TEXT,
  cohort_data JSONB,
  current_count BIGINT,
  needed_count INTEGER
) AS $$
DECLARE
  v_target INTEGER;
BEGIN
  SELECT target_pool_size INTO v_target
  FROM cohort_pool_settings
  WHERE fortune_type = p_fortune_type;

  RETURN QUERY
  SELECT
    cp.cohort_hash,
    cp.cohort_data,
    COUNT(*) as current_count,
    (v_target - COUNT(*)::INTEGER) as needed_count
  FROM cohort_fortune_pool cp
  WHERE cp.fortune_type = p_fortune_type
  GROUP BY cp.cohort_hash, cp.cohort_data
  HAVING COUNT(*) < p_threshold
  ORDER BY COUNT(*) ASC;
END;
$$ LANGUAGE plpgsql;

-- 5. RLS 정책 (읽기만 허용)
ALTER TABLE cohort_fortune_pool ENABLE ROW LEVEL SECURITY;
ALTER TABLE cohort_pool_settings ENABLE ROW LEVEL SECURITY;

-- 모든 인증된 사용자가 읽기 가능
CREATE POLICY "Anyone can read cohort pool" ON cohort_fortune_pool
  FOR SELECT USING (true);

CREATE POLICY "Anyone can read cohort settings" ON cohort_pool_settings
  FOR SELECT USING (true);

-- 서비스 역할만 쓰기 가능
CREATE POLICY "Service role can insert cohort pool" ON cohort_fortune_pool
  FOR INSERT WITH CHECK (auth.role() = 'service_role');

CREATE POLICY "Service role can update cohort pool" ON cohort_fortune_pool
  FOR UPDATE USING (auth.role() = 'service_role');

-- 6. 트리거: updated_at 자동 갱신
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_cohort_fortune_pool_updated_at
  BEFORE UPDATE ON cohort_fortune_pool
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cohort_pool_settings_updated_at
  BEFORE UPDATE ON cohort_pool_settings
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- 7. 완료 확인
COMMENT ON TABLE cohort_fortune_pool IS 'Cohort 기반 사전 생성 운세 결과 풀 (API 90% 절감 목표)';
COMMENT ON TABLE cohort_pool_settings IS '운세별 Cohort 설정 (dimensions, values, placeholders)';
