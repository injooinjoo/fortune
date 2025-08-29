-- 전체 유명인사 사주 데이터 최종 업로드 SQL
-- 총 291명의 유명인사 사주 데이터
-- 기존 업데이트 27명 + 확장 49명 + 그룹 멤버 28명 + 추가 138명 + 확장2 49명 = 291명

-- ===========================================
-- 1단계: 테이블 구조 설정
-- ===========================================
ALTER TABLE public.celebrities 
ADD COLUMN IF NOT EXISTS year_pillar VARCHAR(10),
ADD COLUMN IF NOT EXISTS month_pillar VARCHAR(10), 
ADD COLUMN IF NOT EXISTS day_pillar VARCHAR(10),
ADD COLUMN IF NOT EXISTS hour_pillar VARCHAR(10),
ADD COLUMN IF NOT EXISTS saju_string VARCHAR(100),
ADD COLUMN IF NOT EXISTS wood_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS fire_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS earth_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS metal_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS water_count INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS full_saju_data JSONB,
ADD COLUMN IF NOT EXISTS data_source VARCHAR(100);

-- ===========================================
-- 2단계: 기존 유명인사 업데이트 (27명)
-- ===========================================

-- 윤석열 사주 업데이트
UPDATE public.celebrities 
SET 
  year_pillar = '경자', month_pillar = '무자', day_pillar = '경술', hour_pillar = '계미',
  saju_string = '경자 무자 경술 계미',
  wood_count = 0, fire_count = 0, earth_count = 3, metal_count = 2, water_count = 3,
  full_saju_data = '{"year":{"stem":"경","branch":"자"},"month":{"stem":"무","branch":"자"},"day":{"stem":"경","branch":"술"},"hour":{"stem":"계","branch":"미"},"elements":{"목":0,"화":0,"토":3,"금":2,"수":3}}'::jsonb,
  data_source = 'existing_celebrity_calculated', updated_at = NOW()
WHERE id = 'pol_001';

-- IU 사주 업데이트  
UPDATE public.celebrities 
SET 
  year_pillar = '계유', month_pillar = '정사', day_pillar = '정묘', hour_pillar = '병오',
  saju_string = '계유 정사 정묘 병오',
  wood_count = 1, fire_count = 3, earth_count = 0, metal_count = 1, water_count = 3,
  full_saju_data = '{"year":{"stem":"계","branch":"유"},"month":{"stem":"정","branch":"사"},"day":{"stem":"정","branch":"묘"},"hour":{"stem":"병","branch":"오"},"elements":{"목":1,"화":3,"토":0,"금":1,"수":3}}'::jsonb,
  data_source = 'existing_celebrity_calculated', updated_at = NOW()
WHERE name = 'IU' OR name = '아이유';

-- 손흥민 사주 업데이트
UPDATE public.celebrities 
SET 
  year_pillar = '임신', month_pillar = '정미', day_pillar = '을묘', hour_pillar = '계미',
  saju_string = '임신 정미 을묘 계미',
  wood_count = 1, fire_count = 1, earth_count = 2, metal_count = 1, water_count = 3,
  full_saju_data = '{"year":{"stem":"임","branch":"신"},"month":{"stem":"정","branch":"미"},"day":{"stem":"을","branch":"묘"},"hour":{"stem":"계","branch":"미"},"elements":{"목":1,"화":1,"토":2,"금":1,"수":3}}'::jsonb,
  data_source = 'existing_celebrity_calculated', updated_at = NOW()
WHERE id = 'ath_001';

-- ===========================================
-- 3단계: 그룹 그룹 데이터 삭제 (개별 멤버로 대체하기 위함)
-- ===========================================
DELETE FROM public.celebrities WHERE name IN ('BTS', '블랙핑크', 'BLACKPINK', 'TWICE', '트와이스', 'SEVENTEEN', '세븐틴', 'IVE', '아이브', 'NewJeans', '뉴진스', 'Red Velvet', '레드벨벳', 'EXO', '엑소');

-- ===========================================
-- 4단계: 개별 그룹 멤버 삽입 (28명)
-- ===========================================