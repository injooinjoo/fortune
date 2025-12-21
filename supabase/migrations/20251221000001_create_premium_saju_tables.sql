-- ============================================================================
-- 프리미엄 사주명리서 테이블 생성
-- 215페이지급 상세 사주 분석 (₩39,000 일회성 결제)
-- ============================================================================

-- 1. 프리미엄 사주 결과 메인 테이블
CREATE TABLE IF NOT EXISTS premium_saju_results (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  -- 생년월일시 정보
  birth_date DATE NOT NULL,
  birth_time TIME,
  is_lunar BOOLEAN DEFAULT false,
  gender VARCHAR(10) NOT NULL CHECK (gender IN ('male', 'female')),
  timezone TEXT DEFAULT 'Asia/Seoul',

  -- ============================================================================
  -- 사주 기초 데이터 (계산된 값, 캐시용)
  -- ============================================================================
  saju_pillars JSONB NOT NULL,
  -- {
  --   "yearPillar": {"heavenlyStem": "갑", "earthlyBranch": "자", "element": "목", "yinYang": "양"},
  --   "monthPillar": {...},
  --   "dayPillar": {...},
  --   "hourPillar": {...}
  -- }

  element_distribution JSONB NOT NULL,
  -- {"wood": 2, "fire": 1, "earth": 2, "metal": 1, "water": 2, "dominant": "목", "lacking": "화"}

  format_analysis JSONB NOT NULL,
  -- {"format": "정재격", "formatType": "정격", "strength": "신강", "description": "..."}

  yongshin_analysis JSONB NOT NULL,
  -- {"yongshin": "화", "heeshin": "토", "gishin": "수", "chousin": "금", "method": "억부법", "description": "..."}

  -- 대운 데이터 (6대운, 60년)
  grand_luck_cycles JSONB,
  -- [{order: 1, startAge: 3, endAge: 12, heavenlyStem: "을", earthlyBranch: "축", ...}, ...]

  -- 신살 데이터
  shin_sal_list JSONB,
  -- [{"name": "천을귀인", "type": "길신", "position": "년주", "description": "...", "effect": "..."}]

  -- ============================================================================
  -- 구매 정보
  -- ============================================================================
  transaction_id VARCHAR(255) UNIQUE NOT NULL,
  product_id VARCHAR(100) NOT NULL DEFAULT 'com.fortune.premium_saju_lifetime',
  price DECIMAL(10,2) NOT NULL DEFAULT 39000,
  currency VARCHAR(3) DEFAULT 'KRW',
  purchased_at TIMESTAMPTZ NOT NULL,
  is_lifetime_ownership BOOLEAN DEFAULT true,

  -- ============================================================================
  -- 생성 상태
  -- ============================================================================
  generation_status JSONB NOT NULL DEFAULT '{
    "totalChapters": 21,
    "completedChapters": 0,
    "currentChapterIndex": 0,
    "isComplete": false
  }',

  -- ============================================================================
  -- 읽기 진행도
  -- ============================================================================
  reading_progress JSONB DEFAULT '{
    "currentChapter": 0,
    "currentSection": 0,
    "scrollPosition": 0,
    "totalReadingTimeSeconds": 0
  }',

  -- ============================================================================
  -- 메타데이터
  -- ============================================================================
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. 프리미엄 사주 챕터 테이블 (증분 생성용)
CREATE TABLE IF NOT EXISTS premium_saju_chapters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  result_id UUID NOT NULL REFERENCES premium_saju_results(id) ON DELETE CASCADE,

  -- 챕터 정보
  part_number INT NOT NULL CHECK (part_number BETWEEN 1 AND 6),
  chapter_number INT NOT NULL,
  chapter_index INT NOT NULL,  -- 전체 순서 (0-20)
  title VARCHAR(255) NOT NULL,
  emoji VARCHAR(10),

  -- 상태
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'generating', 'completed', 'error')),

  -- 콘텐츠 (섹션 배열)
  sections JSONB,
  -- [{
  --   "id": "uuid",
  --   "title": "섹션 제목",
  --   "type": "template|llm|hybrid",
  --   "content": "마크다운 콘텐츠",
  --   "subsectionTitles": ["소제목1", "소제목2"],
  --   "isGenerated": true,
  --   "generatedAt": "2024-..."
  -- }]

  -- 메타데이터
  estimated_pages INT DEFAULT 0,
  word_count INT DEFAULT 0,
  generated_at TIMESTAMPTZ,
  error_message TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),

  -- 유니크 제약조건
  CONSTRAINT unique_chapter_per_result UNIQUE(result_id, chapter_index)
);

-- 3. 프리미엄 사주 북마크 테이블
CREATE TABLE IF NOT EXISTS premium_saju_bookmarks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  result_id UUID NOT NULL REFERENCES premium_saju_results(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,

  chapter_index INT NOT NULL,
  section_index INT NOT NULL,
  title VARCHAR(255) NOT NULL,
  note TEXT,

  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 4. 프리미엄 사주 템플릿 테이블 (관리자용)
CREATE TABLE IF NOT EXISTS premium_saju_templates (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  section_id VARCHAR(100) UNIQUE NOT NULL,
  chapter_index INT NOT NULL,
  part_number INT NOT NULL,

  template_type VARCHAR(20) NOT NULL CHECK (template_type IN ('markdown', 'json', 'html')),
  variables TEXT[] NOT NULL,  -- ['dominant', 'secondary', 'lacking', ...]
  base_content TEXT NOT NULL,

  is_active BOOLEAN DEFAULT true,
  version INT DEFAULT 1,

  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================================
-- 인덱스 생성
-- ============================================================================
CREATE INDEX IF NOT EXISTS idx_premium_saju_results_user_id ON premium_saju_results(user_id);
CREATE INDEX IF NOT EXISTS idx_premium_saju_results_transaction ON premium_saju_results(transaction_id);
CREATE INDEX IF NOT EXISTS idx_premium_saju_chapters_result_id ON premium_saju_chapters(result_id);
CREATE INDEX IF NOT EXISTS idx_premium_saju_chapters_status ON premium_saju_chapters(status);
CREATE INDEX IF NOT EXISTS idx_premium_saju_bookmarks_result ON premium_saju_bookmarks(result_id);
CREATE INDEX IF NOT EXISTS idx_premium_saju_bookmarks_user ON premium_saju_bookmarks(user_id);
CREATE INDEX IF NOT EXISTS idx_premium_saju_templates_section ON premium_saju_templates(section_id);

-- ============================================================================
-- RLS (Row Level Security) 활성화
-- ============================================================================

-- premium_saju_results
ALTER TABLE premium_saju_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own premium saju"
  ON premium_saju_results FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own premium saju"
  ON premium_saju_results FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own premium saju"
  ON premium_saju_results FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Service role has full access to premium saju"
  ON premium_saju_results FOR ALL
  USING (auth.jwt() ->> 'role' = 'service_role');

-- premium_saju_chapters
ALTER TABLE premium_saju_chapters ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own chapters"
  ON premium_saju_chapters FOR SELECT
  USING (
    EXISTS (
      SELECT 1 FROM premium_saju_results psr
      WHERE psr.id = premium_saju_chapters.result_id
      AND psr.user_id = auth.uid()
    )
  );

CREATE POLICY "Service role has full access to chapters"
  ON premium_saju_chapters FOR ALL
  USING (auth.jwt() ->> 'role' = 'service_role');

-- premium_saju_bookmarks
ALTER TABLE premium_saju_bookmarks ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can manage own bookmarks"
  ON premium_saju_bookmarks FOR ALL
  USING (auth.uid() = user_id);

-- premium_saju_templates (관리자만)
ALTER TABLE premium_saju_templates ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Service role has full access to templates"
  ON premium_saju_templates FOR ALL
  USING (auth.jwt() ->> 'role' = 'service_role');

CREATE POLICY "Anyone can read templates"
  ON premium_saju_templates FOR SELECT
  USING (is_active = true);

-- ============================================================================
-- updated_at 자동 업데이트 트리거
-- ============================================================================
CREATE OR REPLACE FUNCTION update_premium_saju_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_premium_saju_results_updated_at
  BEFORE UPDATE ON premium_saju_results
  FOR EACH ROW
  EXECUTE FUNCTION update_premium_saju_updated_at();

CREATE TRIGGER trigger_premium_saju_chapters_updated_at
  BEFORE UPDATE ON premium_saju_chapters
  FOR EACH ROW
  EXECUTE FUNCTION update_premium_saju_updated_at();

CREATE TRIGGER trigger_premium_saju_templates_updated_at
  BEFORE UPDATE ON premium_saju_templates
  FOR EACH ROW
  EXECUTE FUNCTION update_premium_saju_updated_at();

-- ============================================================================
-- 코멘트
-- ============================================================================
COMMENT ON TABLE premium_saju_results IS '프리미엄 사주명리서 결과 (215페이지, ₩39,000)';
COMMENT ON TABLE premium_saju_chapters IS '프리미엄 사주 챕터 (21개, 증분 생성)';
COMMENT ON TABLE premium_saju_bookmarks IS '프리미엄 사주 북마크';
COMMENT ON TABLE premium_saju_templates IS '프리미엄 사주 템플릿 (관리자용)';
