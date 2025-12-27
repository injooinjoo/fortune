-- ============================================
-- Content Tagging System - Initial Tag Seeding
-- Total: ~100 hierarchical tags
-- ============================================

-- ============================================
-- 1. CATEGORY Tags (대분류) - Root Level
-- ============================================

-- 감정/심리
INSERT INTO tags (slug, name_ko, name_en, tag_type, depth, path, color_hex, description)
VALUES ('category-emotion', '감정/심리', 'Emotion/Psychology', 'category', 0, ARRAY['category-emotion'], '#EC4899', '감정, 심리, 마음 관련 콘텐츠');

-- 관계
INSERT INTO tags (slug, name_ko, name_en, tag_type, depth, path, color_hex, description)
VALUES ('category-relationship', '관계', 'Relationships', 'category', 0, ARRAY['category-relationship'], '#F43F5E', '인간관계, 연애, 가족 관련 콘텐츠');

-- 재물/투자
INSERT INTO tags (slug, name_ko, name_en, tag_type, depth, path, color_hex, description)
VALUES ('category-wealth', '재물/투자', 'Wealth/Investment', 'category', 0, ARRAY['category-wealth'], '#F59E0B', '돈, 투자, 재테크 관련 콘텐츠');

-- 직업/커리어
INSERT INTO tags (slug, name_ko, name_en, tag_type, depth, path, color_hex, description)
VALUES ('category-career', '직업/커리어', 'Career', 'category', 0, ARRAY['category-career'], '#2563EB', '취업, 승진, 사업 관련 콘텐츠');

-- 건강
INSERT INTO tags (slug, name_ko, name_en, tag_type, depth, path, color_hex, description)
VALUES ('category-health', '건강', 'Health', 'category', 0, ARRAY['category-health'], '#10B981', '신체, 정신 건강 관련 콘텐츠');

-- 엔터테인먼트
INSERT INTO tags (slug, name_ko, name_en, tag_type, depth, path, color_hex, description)
VALUES ('category-entertainment', '엔터테인먼트', 'Entertainment', 'category', 0, ARRAY['category-entertainment'], '#8B5CF6', '재미, 게임, 소셜 관련 콘텐츠');

-- 영적/전통
INSERT INTO tags (slug, name_ko, name_en, tag_type, depth, path, color_hex, description)
VALUES ('category-spiritual', '영적/전통', 'Spiritual/Traditional', 'category', 0, ARRAY['category-spiritual'], '#6366F1', '사주, 타로, 전통 분석 관련 콘텐츠');

-- 라이프스타일
INSERT INTO tags (slug, name_ko, name_en, tag_type, depth, path, color_hex, description)
VALUES ('category-lifestyle', '라이프스타일', 'Lifestyle', 'category', 0, ARRAY['category-lifestyle'], '#14B8A6', '일상, 생활, 라이프 관련 콘텐츠');


-- ============================================
-- 2. THEME Tags (주제) - Under Categories
-- ============================================

-- 감정/심리 하위 테마
INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-personality', '성격분석', 'Personality', 'theme', id, 1, ARRAY['category-emotion', 'theme-personality'], 'MBTI, 성격 유형 분석'
FROM tags WHERE slug = 'category-emotion';

INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-healing', '힐링/위로', 'Healing', 'theme', id, 1, ARRAY['category-emotion', 'theme-healing'], '마음 치유, 위로가 필요할 때'
FROM tags WHERE slug = 'category-emotion';

INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-self-discovery', '자아발견', 'Self Discovery', 'theme', id, 1, ARRAY['category-emotion', 'theme-self-discovery'], '나를 알아가는 여정'
FROM tags WHERE slug = 'category-emotion';

-- 관계 하위 테마
INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-romance', '연애', 'Romance', 'theme', id, 1, ARRAY['category-relationship', 'theme-romance'], '연애, 썸, 소개팅'
FROM tags WHERE slug = 'category-relationship';

INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-marriage', '결혼', 'Marriage', 'theme', id, 1, ARRAY['category-relationship', 'theme-marriage'], '결혼, 부부 관계'
FROM tags WHERE slug = 'category-relationship';

INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-breakup', '이별/재회', 'Breakup/Reunion', 'theme', id, 1, ARRAY['category-relationship', 'theme-breakup'], '이별, 재회, 전 연인'
FROM tags WHERE slug = 'category-relationship';

INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-family', '가족', 'Family', 'theme', id, 1, ARRAY['category-relationship', 'theme-family'], '가족 관계, 부모 자녀'
FROM tags WHERE slug = 'category-relationship';

INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-friendship', '친구/지인', 'Friendship', 'theme', id, 1, ARRAY['category-relationship', 'theme-friendship'], '우정, 인간관계'
FROM tags WHERE slug = 'category-relationship';

INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-compatibility', '궁합', 'Compatibility', 'theme', id, 1, ARRAY['category-relationship', 'theme-compatibility'], '궁합, 케미, 매칭'
FROM tags WHERE slug = 'category-relationship';

-- 재물/투자 하위 테마
INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-investment', '투자', 'Investment', 'theme', id, 1, ARRAY['category-wealth', 'theme-investment'], '주식, 코인, 부동산'
FROM tags WHERE slug = 'category-wealth';

INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-luck', '행운', 'Luck', 'theme', id, 1, ARRAY['category-wealth', 'theme-luck'], '로또, 행운, 럭키 아이템'
FROM tags WHERE slug = 'category-wealth';

INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-money-management', '재테크', 'Money Management', 'theme', id, 1, ARRAY['category-wealth', 'theme-money-management'], '저축, 소비, 재정 관리'
FROM tags WHERE slug = 'category-wealth';

-- 직업/커리어 하위 테마
INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-job-search', '취업/구직', 'Job Search', 'theme', id, 1, ARRAY['category-career', 'theme-job-search'], '취업, 이직, 면접'
FROM tags WHERE slug = 'category-career';

INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-promotion', '승진/성과', 'Promotion', 'theme', id, 1, ARRAY['category-career', 'theme-promotion'], '승진, 연봉, 성과'
FROM tags WHERE slug = 'category-career';

INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-business', '창업/사업', 'Business', 'theme', id, 1, ARRAY['category-career', 'theme-business'], '창업, 사업, 프리랜서'
FROM tags WHERE slug = 'category-career';

INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-talent', '재능/적성', 'Talent', 'theme', id, 1, ARRAY['category-career', 'theme-talent'], '재능 발견, 적성 찾기'
FROM tags WHERE slug = 'category-career';

-- 건강 하위 테마
INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-physical', '신체건강', 'Physical Health', 'theme', id, 1, ARRAY['category-health', 'theme-physical'], '신체 건강, 운동'
FROM tags WHERE slug = 'category-health';

INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-mental', '정신건강', 'Mental Health', 'theme', id, 1, ARRAY['category-health', 'theme-mental'], '스트레스, 우울, 정신 건강'
FROM tags WHERE slug = 'category-health';

INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-energy', '에너지/활력', 'Energy', 'theme', id, 1, ARRAY['category-health', 'theme-energy'], '바이오리듬, 에너지, 활력'
FROM tags WHERE slug = 'category-health';

-- 엔터테인먼트 하위 테마
INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-fun', '재미/호기심', 'Fun', 'theme', id, 1, ARRAY['category-entertainment', 'theme-fun'], '재미, 호기심, 가벼운 즐거움'
FROM tags WHERE slug = 'category-entertainment';

INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-games', '게임/테스트', 'Games', 'theme', id, 1, ARRAY['category-entertainment', 'theme-games'], '심리테스트, 게임형 콘텐츠'
FROM tags WHERE slug = 'category-entertainment';

INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-social', '소셜/공유', 'Social', 'theme', id, 1, ARRAY['category-entertainment', 'theme-social'], '공유하기 좋은 콘텐츠'
FROM tags WHERE slug = 'category-entertainment';

INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-celebrity', '연예인/셀럽', 'Celebrity', 'theme', id, 1, ARRAY['category-entertainment', 'theme-celebrity'], '연예인 관련 콘텐츠'
FROM tags WHERE slug = 'category-entertainment';

-- 영적/전통 하위 테마
INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-saju', '사주/명리', 'Saju', 'theme', id, 1, ARRAY['category-spiritual', 'theme-saju'], '사주팔자, 명리학'
FROM tags WHERE slug = 'category-spiritual';

INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-tarot', '타로', 'Tarot', 'theme', id, 1, ARRAY['category-spiritual', 'theme-tarot'], '타로 카드 리딩'
FROM tags WHERE slug = 'category-spiritual';

INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-physiognomy', '관상/수상', 'Physiognomy', 'theme', id, 1, ARRAY['category-spiritual', 'theme-physiognomy'], '관상, 수상, Face AI'
FROM tags WHERE slug = 'category-spiritual';

INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-dream', '꿈해몽', 'Dream', 'theme', id, 1, ARRAY['category-spiritual', 'theme-dream'], '꿈 해석, 꿈 분석'
FROM tags WHERE slug = 'category-spiritual';

INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-zodiac', '별자리/띠', 'Zodiac', 'theme', id, 1, ARRAY['category-spiritual', 'theme-zodiac'], '별자리, 띠, 혈액형'
FROM tags WHERE slug = 'category-spiritual';

-- 라이프스타일 하위 테마
INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-daily', '일상', 'Daily', 'theme', id, 1, ARRAY['category-lifestyle', 'theme-daily'], '하루, 일상 생활'
FROM tags WHERE slug = 'category-lifestyle';

INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-moving', '이사/주거', 'Moving', 'theme', id, 1, ARRAY['category-lifestyle', 'theme-moving'], '이사, 주거 환경'
FROM tags WHERE slug = 'category-lifestyle';

INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-pet', '반려동물', 'Pet', 'theme', id, 1, ARRAY['category-lifestyle', 'theme-pet'], '반려동물, 펫'
FROM tags WHERE slug = 'category-lifestyle';

INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-parenting', '육아/자녀', 'Parenting', 'theme', id, 1, ARRAY['category-lifestyle', 'theme-parenting'], '육아, 자녀 교육'
FROM tags WHERE slug = 'category-lifestyle';

INSERT INTO tags (slug, name_ko, name_en, tag_type, parent_id, depth, path, description)
SELECT 'theme-naming', '작명', 'Naming', 'theme', id, 1, ARRAY['category-lifestyle', 'theme-naming'], '이름, 작명'
FROM tags WHERE slug = 'category-lifestyle';


-- ============================================
-- 3. MOOD Tags (분위기)
-- ============================================

INSERT INTO tags (slug, name_ko, name_en, tag_type, depth, path, description)
VALUES
  ('mood-positive', '긍정적', 'Positive', 'mood', 0, ARRAY['mood-positive'], '밝고 희망적인 분위기'),
  ('mood-careful', '신중한', 'Careful', 'mood', 0, ARRAY['mood-careful'], '조심하고 생각해볼 분위기'),
  ('mood-comforting', '위로', 'Comforting', 'mood', 0, ARRAY['mood-comforting'], '따뜻하고 위로되는 분위기'),
  ('mood-exciting', '설레는', 'Exciting', 'mood', 0, ARRAY['mood-exciting'], '두근거리고 기대되는 분위기'),
  ('mood-serious', '진지한', 'Serious', 'mood', 0, ARRAY['mood-serious'], '진지하게 고민하는 분위기'),
  ('mood-playful', '재미있는', 'Playful', 'mood', 0, ARRAY['mood-playful'], '가볍고 재미있는 분위기'),
  ('mood-mysterious', '신비로운', 'Mysterious', 'mood', 0, ARRAY['mood-mysterious'], '신비롭고 궁금한 분위기');


-- ============================================
-- 4. TARGET Tags (대상)
-- ============================================

INSERT INTO tags (slug, name_ko, name_en, tag_type, depth, path, description)
VALUES
  -- 연령대
  ('target-age-10s', '10대', 'Teens', 'target', 0, ARRAY['target-age-10s'], '10대 청소년'),
  ('target-age-20s', '20대', '20s', 'target', 0, ARRAY['target-age-20s'], '20대'),
  ('target-age-30s', '30대', '30s', 'target', 0, ARRAY['target-age-30s'], '30대'),
  ('target-age-40plus', '40대+', '40+', 'target', 0, ARRAY['target-age-40plus'], '40대 이상'),
  -- 성별
  ('target-female', '여성', 'Female', 'target', 0, ARRAY['target-female'], '여성 대상'),
  ('target-male', '남성', 'Male', 'target', 0, ARRAY['target-male'], '남성 대상'),
  -- 상태
  ('target-single', '미혼', 'Single', 'target', 0, ARRAY['target-single'], '미혼/솔로'),
  ('target-dating', '연애중', 'Dating', 'target', 0, ARRAY['target-dating'], '연애 중'),
  ('target-married', '기혼', 'Married', 'target', 0, ARRAY['target-married'], '결혼함'),
  -- 직업
  ('target-student', '학생', 'Student', 'target', 0, ARRAY['target-student'], '학생'),
  ('target-worker', '직장인', 'Worker', 'target', 0, ARRAY['target-worker'], '직장인'),
  ('target-jobseeker', '취준생', 'Job Seeker', 'target', 0, ARRAY['target-jobseeker'], '취업 준비생'),
  ('target-parent', '부모', 'Parent', 'target', 0, ARRAY['target-parent'], '자녀가 있는 부모');


-- ============================================
-- 5. METHOD Tags (방식)
-- ============================================

INSERT INTO tags (slug, name_ko, name_en, tag_type, depth, path, description)
VALUES
  ('method-ai', 'AI분석', 'AI Analysis', 'method', 0, ARRAY['method-ai'], 'AI 기반 분석'),
  ('method-traditional', '전통분석', 'Traditional', 'method', 0, ARRAY['method-traditional'], '전통적인 분석 방법'),
  ('method-saju', '사주기반', 'Saju Based', 'method', 0, ARRAY['method-saju'], '사주/명리학 기반'),
  ('method-tarot', '타로기반', 'Tarot Based', 'method', 0, ARRAY['method-tarot'], '타로 카드 기반'),
  ('method-face-ai', '관상AI', 'Face AI', 'method', 0, ARRAY['method-face-ai'], 'AI 관상 분석'),
  ('method-mbti', 'MBTI기반', 'MBTI Based', 'method', 0, ARRAY['method-mbti'], 'MBTI 성격 유형 기반'),
  ('method-biorhythm', '바이오리듬', 'Biorhythm', 'method', 0, ARRAY['method-biorhythm'], '바이오리듬 분석');


-- ============================================
-- 6. TIME Tags (시간)
-- ============================================

INSERT INTO tags (slug, name_ko, name_en, tag_type, depth, path, description)
VALUES
  ('time-daily', '일일', 'Daily', 'time', 0, ARRAY['time-daily'], '하루 단위'),
  ('time-weekly', '주간', 'Weekly', 'time', 0, ARRAY['time-weekly'], '일주일 단위'),
  ('time-monthly', '월간', 'Monthly', 'time', 0, ARRAY['time-monthly'], '한달 단위'),
  ('time-yearly', '연간', 'Yearly', 'time', 0, ARRAY['time-yearly'], '일년 단위'),
  ('time-specific', '특정일', 'Specific Date', 'time', 0, ARRAY['time-specific'], '특정 날짜 지정'),
  ('time-realtime', '실시간', 'Realtime', 'time', 0, ARRAY['time-realtime'], '실시간/시간대별');


-- ============================================
-- 7. OCCASION Tags (상황)
-- ============================================

INSERT INTO tags (slug, name_ko, name_en, tag_type, depth, path, description)
VALUES
  ('occasion-decision', '결정필요', 'Decision Needed', 'occasion', 0, ARRAY['occasion-decision'], '중요한 결정이 필요할 때'),
  ('occasion-crisis', '위기', 'Crisis', 'occasion', 0, ARRAY['occasion-crisis'], '어려운 상황, 위기'),
  ('occasion-new-start', '새출발', 'New Start', 'occasion', 0, ARRAY['occasion-new-start'], '새로운 시작, 변화'),
  ('occasion-celebration', '축하', 'Celebration', 'occasion', 0, ARRAY['occasion-celebration'], '기쁜 일, 축하할 일'),
  ('occasion-routine', '일상', 'Routine', 'occasion', 0, ARRAY['occasion-routine'], '평범한 일상'),
  ('occasion-worried', '고민중', 'Worried', 'occasion', 0, ARRAY['occasion-worried'], '고민이 있을 때'),
  ('occasion-curious', '궁금함', 'Curious', 'occasion', 0, ARRAY['occasion-curious'], '단순히 궁금할 때');


-- ============================================
-- 8. FEATURE Tags (기능)
-- ============================================

INSERT INTO tags (slug, name_ko, name_en, tag_type, depth, path, description, weight)
VALUES
  ('feature-premium', '프리미엄', 'Premium', 'feature', 0, ARRAY['feature-premium'], '유료 프리미엄 콘텐츠', 1.5),
  ('feature-popular', '인기', 'Popular', 'feature', 0, ARRAY['feature-popular'], '인기 있는 콘텐츠', 1.3),
  ('feature-new', '신규', 'New', 'feature', 0, ARRAY['feature-new'], '새로 추가된 콘텐츠', 1.2),
  ('feature-trending', '트렌딩', 'Trending', 'feature', 0, ARRAY['feature-trending'], '요즘 뜨는 콘텐츠', 1.4),
  ('feature-recommended', '추천', 'Recommended', 'feature', 0, ARRAY['feature-recommended'], '추천 콘텐츠', 1.3),
  ('feature-shareable', '공유용', 'Shareable', 'feature', 0, ARRAY['feature-shareable'], '공유하기 좋은 콘텐츠', 1.1),
  ('feature-quick', '간단', 'Quick', 'feature', 0, ARRAY['feature-quick'], '빠르게 볼 수 있는 콘텐츠', 1.0),
  ('feature-detailed', '상세', 'Detailed', 'feature', 0, ARRAY['feature-detailed'], '상세하고 깊은 분석', 1.2);


-- ============================================
-- 9. Tag Synonyms (동의어)
-- ============================================

INSERT INTO tag_synonyms (tag_id, synonym, language)
SELECT id, '사랑', 'ko' FROM tags WHERE slug = 'theme-romance'
UNION ALL
SELECT id, '연인', 'ko' FROM tags WHERE slug = 'theme-romance'
UNION ALL
SELECT id, '썸', 'ko' FROM tags WHERE slug = 'theme-romance'
UNION ALL
SELECT id, '소개팅', 'ko' FROM tags WHERE slug = 'theme-romance'
UNION ALL
SELECT id, '돈', 'ko' FROM tags WHERE slug = 'category-wealth'
UNION ALL
SELECT id, '금전', 'ko' FROM tags WHERE slug = 'category-wealth'
UNION ALL
SELECT id, '재산', 'ko' FROM tags WHERE slug = 'category-wealth'
UNION ALL
SELECT id, '직장', 'ko' FROM tags WHERE slug = 'category-career'
UNION ALL
SELECT id, '회사', 'ko' FROM tags WHERE slug = 'category-career'
UNION ALL
SELECT id, '일', 'ko' FROM tags WHERE slug = 'category-career'
UNION ALL
SELECT id, '오늘', 'ko' FROM tags WHERE slug = 'time-daily'
UNION ALL
SELECT id, '하루', 'ko' FROM tags WHERE slug = 'time-daily'
UNION ALL
SELECT id, '데일리', 'ko' FROM tags WHERE slug = 'time-daily'
UNION ALL
SELECT id, '마음', 'ko' FROM tags WHERE slug = 'category-emotion'
UNION ALL
SELECT id, '심리', 'ko' FROM tags WHERE slug = 'category-emotion'
UNION ALL
SELECT id, '감정', 'ko' FROM tags WHERE slug = 'category-emotion'
UNION ALL
SELECT id, 'MBTI', 'ko' FROM tags WHERE slug = 'method-mbti'
UNION ALL
SELECT id, '엠비티아이', 'ko' FROM tags WHERE slug = 'method-mbti'
UNION ALL
SELECT id, '16유형', 'ko' FROM tags WHERE slug = 'method-mbti'
UNION ALL
SELECT id, '관상', 'ko' FROM tags WHERE slug = 'theme-physiognomy'
UNION ALL
SELECT id, '수상', 'ko' FROM tags WHERE slug = 'theme-physiognomy'
UNION ALL
SELECT id, '얼굴', 'ko' FROM tags WHERE slug = 'theme-physiognomy';


-- ============================================
-- Summary: Total tags seeded
-- ============================================
-- Categories: 8
-- Themes: ~30
-- Moods: 7
-- Targets: 13
-- Methods: 7
-- Times: 6
-- Occasions: 7
-- Features: 8
-- Total: ~86 tags + ~20 synonyms
