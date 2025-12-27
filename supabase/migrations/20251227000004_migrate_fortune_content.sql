-- ============================================
-- Content Tagging System - Fortune Content Migration
-- Migrates 95+ fortune types to content_items with tag mappings
-- ============================================

-- ============================================
-- 1. Insert Fortune Content Items
-- ============================================

-- Daily Insights (일일 인사이트)
INSERT INTO content_items (content_type, content_key, display_name, category, subcategory, is_premium, route_path, edge_function) VALUES
  ('fortune', 'daily', '오늘의 메시지', '일일 인사이트', 'time-based', false, '/daily-calendar', 'fortune-daily'),
  ('fortune', 'today', '오늘의 인사이트', '일일 인사이트', 'time-based', false, '/daily-calendar', 'fortune-daily'),
  ('fortune', 'tomorrow', '내일의 인사이트', '일일 인사이트', 'time-based', false, '/daily-calendar', 'fortune-daily'),
  ('fortune', 'daily_calendar', '날짜별 인사이트', '일일 인사이트', 'time-based', false, '/daily-calendar', 'fortune-daily'),
  ('fortune', 'weekly', '주간 인사이트', '일일 인사이트', 'time-based', false, '/daily-calendar', 'fortune-daily'),
  ('fortune', 'monthly', '월간 인사이트', '일일 인사이트', 'time-based', false, '/daily-calendar', 'fortune-daily'),
  ('fortune', 'yearly', '연간 인사이트', '일일 인사이트', 'time-based', true, '/yearly', 'fortune-yearly');

-- Traditional Analysis (전통 분석)
INSERT INTO content_items (content_type, content_key, display_name, category, subcategory, is_premium, route_path, edge_function) VALUES
  ('fortune', 'traditional', '전통 분석', '전통 분석', 'traditional', true, '/traditional', 'fortune-traditional-saju'),
  ('fortune', 'saju', '생년월일 분석', '전통 분석', 'traditional', false, '/traditional-saju', 'fortune-traditional-saju'),
  ('fortune', 'traditional-saju', '전통 사주 분석', '전통 분석', 'traditional', true, '/traditional-saju', 'fortune-traditional-saju'),
  ('fortune', 'tarot', 'Insight Cards', '전통 분석', 'traditional', false, '/tarot', NULL),
  ('fortune', 'saju-psychology', '성격 심리 분석', '전통 분석', 'traditional', true, '/traditional-saju', 'fortune-traditional-saju'),
  ('fortune', 'tojeong', '전통 해석', '전통 분석', 'traditional', true, '/traditional', NULL),
  ('fortune', 'salpuli', '기운 정화', '전통 분석', 'traditional', true, '/traditional', NULL),
  ('fortune', 'palmistry', '손금 분석', '전통 분석', 'traditional', true, '/traditional', NULL),
  ('fortune', 'physiognomy', 'Face AI', '전통 분석', 'ai-analysis', false, '/face-reading', 'fortune-face-reading'),
  ('fortune', 'face-reading', 'Face AI', '전통 분석', 'ai-analysis', false, '/face-reading', 'fortune-face-reading'),
  ('fortune', 'five-blessings', '오복 분석', '전통 분석', 'traditional', true, '/traditional', NULL);

-- Personal/Character (성격/캐릭터)
INSERT INTO content_items (content_type, content_key, display_name, category, subcategory, is_premium, route_path, edge_function) VALUES
  ('fortune', 'mbti', 'MBTI 분석', '성격/캐릭터', 'personality', false, '/mbti', 'fortune-mbti'),
  ('fortune', 'personality', '성격 분석', '성격/캐릭터', 'personality', false, '/mbti', 'fortune-mbti'),
  ('fortune', 'personality-dna', '나의 성격 탐구', '성격/캐릭터', 'personality', true, '/mbti', 'fortune-mbti'),
  ('fortune', 'blood-type', '혈액형 분석', '성격/캐릭터', 'personality', false, '/fortune', NULL),
  ('fortune', 'zodiac', '별자리 분석', '성격/캐릭터', 'zodiac', false, '/daily-calendar', NULL),
  ('fortune', 'zodiac-animal', '띠별 분석', '성격/캐릭터', 'zodiac', false, '/daily-calendar', NULL),
  ('fortune', 'birth-season', '태어난 계절', '성격/캐릭터', 'personality', false, '/fortune', NULL),
  ('fortune', 'birthdate', '생일 분석', '성격/캐릭터', 'personality', false, '/fortune', NULL),
  ('fortune', 'birthstone', '탄생석 가이드', '성격/캐릭터', 'personality', false, '/fortune', NULL),
  ('fortune', 'biorhythm', '바이오리듬', '성격/캐릭터', 'biorhythm', false, '/fortune', 'fortune-biorhythm');

-- Love & Relationship (연애/관계)
INSERT INTO content_items (content_type, content_key, display_name, category, subcategory, is_premium, route_path, edge_function) VALUES
  ('fortune', 'love', '연애 분석', '연애/관계', 'romance', false, '/love', 'fortune-love'),
  ('fortune', 'marriage', '결혼 분석', '연애/관계', 'romance', true, '/compatibility', 'fortune-compatibility'),
  ('fortune', 'compatibility', '성향 매칭', '연애/관계', 'compatibility', false, '/compatibility', 'fortune-compatibility'),
  ('fortune', 'traditional-compatibility', '전통 매칭 분석', '연애/관계', 'compatibility', true, '/compatibility', 'fortune-compatibility'),
  ('fortune', 'chemistry', '케미 분석', '연애/관계', 'compatibility', false, '/compatibility', 'fortune-compatibility'),
  ('fortune', 'couple-match', '소울메이트', '연애/관계', 'compatibility', true, '/compatibility', 'fortune-compatibility'),
  ('fortune', 'ex-lover', '재회 분석', '연애/관계', 'romance', false, '/fortune', 'fortune-ex-lover'),
  ('fortune', 'blind-date', '소개팅 가이드', '연애/관계', 'romance', false, '/fortune', 'fortune-blind-date'),
  ('fortune', 'celebrity-match', '연예인 매칭', '연애/관계', 'entertainment', false, '/fortune', 'fortune-celebrity'),
  ('fortune', 'avoid-people', '관계 주의 타입', '연애/관계', 'relationship', false, '/fortune', 'fortune-avoid-people'),
  ('fortune', 'same-birthday-celebrity', '같은 생일 연예인', '연애/관계', 'entertainment', false, '/fortune', NULL);

-- Career & Business (직업/사업)
INSERT INTO content_items (content_type, content_key, display_name, category, subcategory, is_premium, route_path, edge_function) VALUES
  ('fortune', 'career', '직업 분석', '직업/사업', 'career', false, '/career', 'fortune-career'),
  ('fortune', 'employment', '취업 가이드', '직업/사업', 'career', false, '/career', 'fortune-career'),
  ('fortune', 'business', '사업 분석', '직업/사업', 'business', true, '/career', 'fortune-career'),
  ('fortune', 'startup', '창업 인사이트', '직업/사업', 'business', true, '/career', 'fortune-career'),
  ('fortune', 'lucky-job', '추천 직업', '직업/사업', 'career', false, '/career', 'fortune-career'),
  ('fortune', 'lucky-sidejob', '부업 가이드', '직업/사업', 'career', false, '/career', 'fortune-career'),
  ('fortune', 'lucky-exam', '시험 가이드', '직업/사업', 'career', false, '/fortune', NULL);

-- Wealth & Investment (재물/투자)
INSERT INTO content_items (content_type, content_key, display_name, category, subcategory, is_premium, route_path, edge_function) VALUES
  ('fortune', 'wealth', '재물 분석', '재물/투자', 'wealth', false, '/investment', 'fortune-investment'),
  ('fortune', 'investment', '투자 인사이트', '재물/투자', 'investment', true, '/investment', 'fortune-investment'),
  ('fortune', 'lucky-investment', '투자 가이드', '재물/투자', 'investment', false, '/investment', 'fortune-investment'),
  ('fortune', 'lucky-realestate', '부동산 인사이트', '재물/투자', 'investment', true, '/investment', 'fortune-investment'),
  ('fortune', 'lucky-stock', '주식 가이드', '재물/투자', 'investment', false, '/investment', 'fortune-investment'),
  ('fortune', 'lucky-crypto', '암호화폐 가이드', '재물/투자', 'investment', false, '/investment', 'fortune-investment'),
  ('fortune', 'lucky-lottery', '로또 번호 생성', '재물/투자', 'luck', false, '/fortune', NULL);

-- Health & Life (건강/라이프)
INSERT INTO content_items (content_type, content_key, display_name, category, subcategory, is_premium, route_path, edge_function) VALUES
  ('fortune', 'health', '건강 체크', '건강/라이프', 'health', false, '/health-toss', 'fortune-health'),
  ('fortune', 'moving', '이사 가이드', '건강/라이프', 'moving', false, '/fortune', 'fortune-moving'),
  ('fortune', 'moving-date', '이사 날짜 추천', '건강/라이프', 'moving', false, '/fortune', 'fortune-moving'),
  ('fortune', 'moving-unified', '이사 플래너', '건강/라이프', 'moving', true, '/fortune', 'fortune-moving');

-- Lucky Items (행운의 아이템)
INSERT INTO content_items (content_type, content_key, display_name, category, subcategory, is_premium, route_path, edge_function) VALUES
  ('fortune', 'lucky-color', '오늘의 색깔', '럭키 아이템', 'lucky', false, '/fortune', 'fortune-lucky-items'),
  ('fortune', 'lucky-number', '행운 숫자', '럭키 아이템', 'lucky', false, '/fortune', 'fortune-lucky-items'),
  ('fortune', 'lucky-items', '럭키 아이템', '럭키 아이템', 'lucky', false, '/fortune', 'fortune-lucky-items'),
  ('fortune', 'lucky-food', '추천 음식', '럭키 아이템', 'lucky', false, '/fortune', 'fortune-lucky-items'),
  ('fortune', 'lucky-place', '추천 장소', '럭키 아이템', 'lucky', false, '/fortune', 'fortune-lucky-items'),
  ('fortune', 'lucky-outfit', '스타일 가이드', '럭키 아이템', 'lucky', false, '/fortune', 'fortune-lucky-items'),
  ('fortune', 'lucky-series', '럭키 시리즈', '럭키 아이템', 'lucky', false, '/fortune', 'fortune-lucky-items');

-- Sports & Activities (스포츠/활동)
INSERT INTO content_items (content_type, content_key, display_name, category, subcategory, is_premium, route_path, edge_function) VALUES
  ('fortune', 'lucky-baseball', '야구 가이드', '스포츠/활동', 'sports', false, '/fortune', NULL),
  ('fortune', 'lucky-golf', '골프 가이드', '스포츠/활동', 'sports', false, '/fortune', NULL),
  ('fortune', 'lucky-tennis', '테니스 가이드', '스포츠/활동', 'sports', false, '/fortune', NULL),
  ('fortune', 'lucky-running', '런닝 가이드', '스포츠/활동', 'sports', false, '/fortune', NULL),
  ('fortune', 'lucky-cycling', '사이클링 가이드', '스포츠/활동', 'sports', false, '/fortune', NULL),
  ('fortune', 'lucky-swim', '수영 가이드', '스포츠/활동', 'sports', false, '/fortune', NULL),
  ('fortune', 'lucky-fishing', '낚시 가이드', '스포츠/활동', 'sports', false, '/fortune', NULL),
  ('fortune', 'lucky-hiking', '등산 가이드', '스포츠/활동', 'sports', false, '/fortune', NULL),
  ('fortune', 'lucky-fitness', '피트니스 가이드', '스포츠/활동', 'sports', false, '/fortune', NULL),
  ('fortune', 'lucky-yoga', '요가 가이드', '스포츠/활동', 'sports', false, '/fortune', NULL),
  ('fortune', 'lucky-esports', 'e스포츠 가이드', '스포츠/활동', 'esports', false, '/fortune', NULL),
  ('fortune', 'lucky-lck', 'LCK 가이드', '스포츠/활동', 'esports', false, '/fortune', NULL),
  ('fortune', 'lucky-soccer', '축구 가이드', '스포츠/활동', 'sports', false, '/fortune', NULL),
  ('fortune', 'lucky-basketball', '농구 가이드', '스포츠/활동', 'sports', false, '/fortune', NULL);

-- Special Features (특별 기능)
INSERT INTO content_items (content_type, content_key, display_name, category, subcategory, is_premium, route_path, edge_function) VALUES
  ('fortune', 'destiny', '인생 분석', '특별 기능', 'special', true, '/fortune', NULL),
  ('fortune', 'past-life', '전생 이야기', '특별 기능', 'special', true, '/fortune', NULL),
  ('fortune', 'talent', '재능 발견', '특별 기능', 'special', false, '/fortune', 'fortune-talent'),
  ('fortune', 'wish', '소원 분석', '특별 기능', 'special', false, '/fortune', NULL),
  ('fortune', 'timeline', '인생 타임라인', '특별 기능', 'special', true, '/fortune', NULL),
  ('fortune', 'talisman', '행운 카드', '특별 기능', 'special', false, '/fortune', NULL),
  ('fortune', 'new-year', '새해 인사이트', '특별 기능', 'special', false, '/fortune', NULL),
  ('fortune', 'celebrity', '유명인 분석', '특별 기능', 'entertainment', false, '/fortune', 'fortune-celebrity'),
  ('fortune', 'network-report', '네트워크 리포트', '특별 기능', 'special', true, '/fortune', NULL),
  ('fortune', 'dream', '꿈 분석', '특별 기능', 'special', false, '/interactive/dream', 'fortune-dream'),
  ('fortune', 'time', '시간대별 인사이트', '특별 기능', 'time-based', false, '/fortune', 'fortune-time');

-- Pet & Family (반려/육아)
INSERT INTO content_items (content_type, content_key, display_name, category, subcategory, is_premium, route_path, edge_function) VALUES
  ('fortune', 'pet', '반려동물 분석', '반려/육아', 'pet', false, '/fortune', 'fortune-pet-compatibility'),
  ('fortune', 'pet-dog', '반려견 가이드', '반려/육아', 'pet', false, '/fortune', 'fortune-pet-compatibility'),
  ('fortune', 'pet-cat', '반려묘 가이드', '반려/육아', 'pet', false, '/fortune', 'fortune-pet-compatibility'),
  ('fortune', 'pet-compatibility', '반려동물 매칭', '반려/육아', 'pet', false, '/fortune', 'fortune-pet-compatibility'),
  ('fortune', 'children', '자녀 분석', '반려/육아', 'family', true, '/fortune', 'fortune-family-children'),
  ('fortune', 'parenting', '육아 가이드', '반려/육아', 'family', false, '/fortune', 'fortune-family-children'),
  ('fortune', 'pregnancy', '태교 가이드', '반려/육아', 'family', true, '/fortune', NULL),
  ('fortune', 'family-harmony', '가족 화합 가이드', '반려/육아', 'family', false, '/fortune', 'fortune-family-harmony'),
  ('fortune', 'naming', '이름 분석', '반려/육아', 'naming', false, '/naming', 'fortune-naming');


-- ============================================
-- 2. Map Content to Tags (content_tags)
-- ============================================

-- Helper function to map content to tags
CREATE OR REPLACE FUNCTION map_content_to_tag(
  p_content_key TEXT,
  p_tag_slug TEXT,
  p_is_primary BOOLEAN DEFAULT false,
  p_relevance NUMERIC DEFAULT 1.0
) RETURNS VOID AS $$
BEGIN
  INSERT INTO content_tags (content_id, tag_id, is_primary, relevance_score, added_by)
  SELECT ci.id, t.id, p_is_primary, p_relevance, 'migration'
  FROM content_items ci, tags t
  WHERE ci.content_key = p_content_key
    AND ci.content_type = 'fortune'
    AND t.slug = p_tag_slug
  ON CONFLICT (content_id, tag_id) DO NOTHING;
END;
$$ LANGUAGE plpgsql;


-- ============================================
-- Daily Insights Tags
-- ============================================
SELECT map_content_to_tag('daily', 'time-daily', true, 1.0);
SELECT map_content_to_tag('daily', 'category-emotion', false, 0.8);
SELECT map_content_to_tag('daily', 'mood-positive', false, 0.7);
SELECT map_content_to_tag('daily', 'method-ai', false, 0.6);
SELECT map_content_to_tag('daily', 'feature-popular', false, 0.9);

SELECT map_content_to_tag('today', 'time-daily', true, 1.0);
SELECT map_content_to_tag('today', 'category-emotion', false, 0.8);

SELECT map_content_to_tag('tomorrow', 'time-daily', true, 1.0);
SELECT map_content_to_tag('tomorrow', 'category-emotion', false, 0.8);

SELECT map_content_to_tag('weekly', 'time-weekly', true, 1.0);
SELECT map_content_to_tag('weekly', 'category-emotion', false, 0.8);

SELECT map_content_to_tag('monthly', 'time-monthly', true, 1.0);
SELECT map_content_to_tag('monthly', 'category-emotion', false, 0.8);

SELECT map_content_to_tag('yearly', 'time-yearly', true, 1.0);
SELECT map_content_to_tag('yearly', 'category-emotion', false, 0.8);
SELECT map_content_to_tag('yearly', 'feature-premium', false, 0.9);
SELECT map_content_to_tag('yearly', 'mood-serious', false, 0.6);


-- ============================================
-- Traditional Analysis Tags
-- ============================================
SELECT map_content_to_tag('saju', 'theme-saju', true, 1.0);
SELECT map_content_to_tag('saju', 'category-spiritual', false, 0.9);
SELECT map_content_to_tag('saju', 'method-saju', false, 0.9);
SELECT map_content_to_tag('saju', 'method-traditional', false, 0.8);

SELECT map_content_to_tag('traditional-saju', 'theme-saju', true, 1.0);
SELECT map_content_to_tag('traditional-saju', 'method-saju', false, 0.9);
SELECT map_content_to_tag('traditional-saju', 'feature-premium', false, 0.8);
SELECT map_content_to_tag('traditional-saju', 'feature-detailed', false, 0.9);

SELECT map_content_to_tag('tarot', 'theme-tarot', true, 1.0);
SELECT map_content_to_tag('tarot', 'category-spiritual', false, 0.9);
SELECT map_content_to_tag('tarot', 'method-tarot', false, 0.9);
SELECT map_content_to_tag('tarot', 'mood-mysterious', false, 0.8);
SELECT map_content_to_tag('tarot', 'feature-popular', false, 0.8);

SELECT map_content_to_tag('face-reading', 'theme-physiognomy', true, 1.0);
SELECT map_content_to_tag('face-reading', 'method-face-ai', false, 0.9);
SELECT map_content_to_tag('face-reading', 'method-ai', false, 0.8);
SELECT map_content_to_tag('face-reading', 'category-entertainment', false, 0.7);
SELECT map_content_to_tag('face-reading', 'feature-popular', false, 0.9);

SELECT map_content_to_tag('physiognomy', 'theme-physiognomy', true, 1.0);
SELECT map_content_to_tag('physiognomy', 'method-face-ai', false, 0.9);


-- ============================================
-- Personality/Character Tags
-- ============================================
SELECT map_content_to_tag('mbti', 'theme-personality', true, 1.0);
SELECT map_content_to_tag('mbti', 'method-mbti', false, 0.9);
SELECT map_content_to_tag('mbti', 'category-emotion', false, 0.8);
SELECT map_content_to_tag('mbti', 'target-age-20s', false, 0.7);
SELECT map_content_to_tag('mbti', 'feature-popular', false, 0.9);
SELECT map_content_to_tag('mbti', 'feature-shareable', false, 0.8);

SELECT map_content_to_tag('biorhythm', 'theme-energy', true, 1.0);
SELECT map_content_to_tag('biorhythm', 'method-biorhythm', false, 0.9);
SELECT map_content_to_tag('biorhythm', 'category-health', false, 0.7);
SELECT map_content_to_tag('biorhythm', 'time-daily', false, 0.8);

SELECT map_content_to_tag('zodiac', 'theme-zodiac', true, 1.0);
SELECT map_content_to_tag('zodiac', 'category-spiritual', false, 0.7);

SELECT map_content_to_tag('zodiac-animal', 'theme-zodiac', true, 1.0);
SELECT map_content_to_tag('zodiac-animal', 'category-spiritual', false, 0.7);


-- ============================================
-- Love & Relationship Tags
-- ============================================
SELECT map_content_to_tag('love', 'theme-romance', true, 1.0);
SELECT map_content_to_tag('love', 'category-relationship', false, 0.9);
SELECT map_content_to_tag('love', 'mood-exciting', false, 0.8);
SELECT map_content_to_tag('love', 'target-single', false, 0.7);
SELECT map_content_to_tag('love', 'feature-popular', false, 0.9);

SELECT map_content_to_tag('compatibility', 'theme-compatibility', true, 1.0);
SELECT map_content_to_tag('compatibility', 'category-relationship', false, 0.9);
SELECT map_content_to_tag('compatibility', 'mood-exciting', false, 0.7);
SELECT map_content_to_tag('compatibility', 'feature-popular', false, 0.8);

SELECT map_content_to_tag('ex-lover', 'theme-breakup', true, 1.0);
SELECT map_content_to_tag('ex-lover', 'category-relationship', false, 0.9);
SELECT map_content_to_tag('ex-lover', 'mood-comforting', false, 0.8);
SELECT map_content_to_tag('ex-lover', 'occasion-worried', false, 0.7);

SELECT map_content_to_tag('blind-date', 'theme-romance', true, 1.0);
SELECT map_content_to_tag('blind-date', 'category-relationship', false, 0.9);
SELECT map_content_to_tag('blind-date', 'mood-exciting', false, 0.8);
SELECT map_content_to_tag('blind-date', 'target-single', false, 0.9);

SELECT map_content_to_tag('celebrity-match', 'theme-celebrity', true, 1.0);
SELECT map_content_to_tag('celebrity-match', 'category-entertainment', false, 0.9);
SELECT map_content_to_tag('celebrity-match', 'theme-fun', false, 0.8);
SELECT map_content_to_tag('celebrity-match', 'feature-shareable', false, 0.9);


-- ============================================
-- Career & Wealth Tags
-- ============================================
SELECT map_content_to_tag('career', 'category-career', true, 1.0);
SELECT map_content_to_tag('career', 'theme-job-search', false, 0.8);
SELECT map_content_to_tag('career', 'occasion-decision', false, 0.7);
SELECT map_content_to_tag('career', 'target-worker', false, 0.6);

SELECT map_content_to_tag('investment', 'theme-investment', true, 1.0);
SELECT map_content_to_tag('investment', 'category-wealth', false, 0.9);
SELECT map_content_to_tag('investment', 'mood-careful', false, 0.8);
SELECT map_content_to_tag('investment', 'feature-premium', false, 0.8);


-- ============================================
-- Health & Lifestyle Tags
-- ============================================
SELECT map_content_to_tag('health', 'category-health', true, 1.0);
SELECT map_content_to_tag('health', 'theme-physical', false, 0.8);

SELECT map_content_to_tag('moving', 'theme-moving', true, 1.0);
SELECT map_content_to_tag('moving', 'category-lifestyle', false, 0.9);
SELECT map_content_to_tag('moving', 'occasion-new-start', false, 0.8);


-- ============================================
-- Lucky Items Tags
-- ============================================
SELECT map_content_to_tag('lucky-items', 'theme-luck', true, 1.0);
SELECT map_content_to_tag('lucky-items', 'category-wealth', false, 0.7);
SELECT map_content_to_tag('lucky-items', 'time-daily', false, 0.8);
SELECT map_content_to_tag('lucky-items', 'feature-quick', false, 0.9);
SELECT map_content_to_tag('lucky-items', 'mood-positive', false, 0.8);


-- ============================================
-- Special Features Tags
-- ============================================
SELECT map_content_to_tag('dream', 'theme-dream', true, 1.0);
SELECT map_content_to_tag('dream', 'category-spiritual', false, 0.8);
SELECT map_content_to_tag('dream', 'mood-mysterious', false, 0.7);
SELECT map_content_to_tag('dream', 'occasion-curious', false, 0.6);

SELECT map_content_to_tag('talent', 'theme-talent', true, 1.0);
SELECT map_content_to_tag('talent', 'theme-self-discovery', false, 0.9);
SELECT map_content_to_tag('talent', 'category-career', false, 0.7);

SELECT map_content_to_tag('celebrity', 'theme-celebrity', true, 1.0);
SELECT map_content_to_tag('celebrity', 'category-entertainment', false, 0.9);
SELECT map_content_to_tag('celebrity', 'theme-fun', false, 0.8);


-- ============================================
-- Pet & Family Tags
-- ============================================
SELECT map_content_to_tag('pet', 'theme-pet', true, 1.0);
SELECT map_content_to_tag('pet', 'category-lifestyle', false, 0.8);

SELECT map_content_to_tag('pet-compatibility', 'theme-pet', true, 1.0);
SELECT map_content_to_tag('pet-compatibility', 'theme-compatibility', false, 0.8);

SELECT map_content_to_tag('family-harmony', 'theme-family', true, 1.0);
SELECT map_content_to_tag('family-harmony', 'category-relationship', false, 0.8);
SELECT map_content_to_tag('family-harmony', 'target-parent', false, 0.7);

SELECT map_content_to_tag('naming', 'theme-naming', true, 1.0);
SELECT map_content_to_tag('naming', 'category-lifestyle', false, 0.8);
SELECT map_content_to_tag('naming', 'occasion-new-start', false, 0.7);


-- ============================================
-- Cleanup: Drop helper function
-- ============================================
DROP FUNCTION IF EXISTS map_content_to_tag(TEXT, TEXT, BOOLEAN, NUMERIC);


-- ============================================
-- Summary
-- ============================================
-- Total content items: ~95
-- Total tag mappings: ~150+
