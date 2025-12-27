-- ============================================
-- Content Tagging System - Core Tables
-- Purpose: Backend-only tagging for personalized recommendations
-- Frontend: Not exposed (internal use only)
-- ============================================

-- ============================================
-- 1. content_items: Unified content registry
-- ============================================
CREATE TABLE IF NOT EXISTS content_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Content identification
  content_type TEXT NOT NULL CHECK (content_type IN (
    'fortune', 'asmr', 'survey', 'worldcup', 'article', 'quiz'
  )),
  content_key TEXT NOT NULL,  -- e.g., 'daily', 'tarot', 'love'

  -- Display information (Korean)
  display_name TEXT NOT NULL,
  description TEXT,

  -- Categorization
  category TEXT NOT NULL,     -- e.g., '일일 인사이트', '연애/관계'
  subcategory TEXT,           -- e.g., 'time-based', 'traditional'

  -- Pricing/Access
  token_cost INTEGER DEFAULT 1 CHECK (token_cost >= 0),
  is_premium BOOLEAN DEFAULT false,

  -- Status
  is_active BOOLEAN DEFAULT true,
  sort_order INTEGER DEFAULT 0,

  -- Metadata
  icon_name TEXT,             -- Flutter icon name
  color_hex TEXT,             -- Brand color
  route_path TEXT,            -- Navigation route
  edge_function TEXT,         -- Associated Edge Function name

  -- Tracking
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now(),

  UNIQUE(content_type, content_key)
);

-- Indexes for fast lookups
CREATE INDEX IF NOT EXISTS idx_content_items_type ON content_items(content_type);
CREATE INDEX IF NOT EXISTS idx_content_items_category ON content_items(category);
CREATE INDEX IF NOT EXISTS idx_content_items_active ON content_items(is_active) WHERE is_active = true;

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_content_items_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_content_items_updated_at
  BEFORE UPDATE ON content_items
  FOR EACH ROW
  EXECUTE FUNCTION update_content_items_updated_at();


-- ============================================
-- 2. tags: Hierarchical tag system
-- ============================================
CREATE TABLE IF NOT EXISTS tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  -- Tag identification
  slug TEXT NOT NULL UNIQUE,           -- e.g., 'emotion-love', 'time-daily'
  name_ko TEXT NOT NULL,               -- Korean display name
  name_en TEXT,                        -- English (optional)

  -- Hierarchy
  parent_id UUID REFERENCES tags(id) ON DELETE SET NULL,
  depth INTEGER DEFAULT 0,             -- 0=root, 1=child, 2=grandchild
  path TEXT[],                         -- Materialized path for fast queries

  -- Classification
  tag_type TEXT NOT NULL CHECK (tag_type IN (
    'category',      -- 대분류: 감정, 관계, 재물
    'theme',         -- 주제: 연애, 결혼, 이별
    'mood',          -- 분위기: 긍정, 신중, 위로
    'target',        -- 대상: 20대, 여성, 직장인
    'occasion',      -- 상황: 고민중, 결정필요, 위기
    'method',        -- 방식: AI분석, 전통, 타로
    'time',          -- 시간: 일일, 주간, 월간
    'feature'        -- 기능: 프리미엄, 인기, 신규
  )),

  -- Metadata
  description TEXT,
  color_hex TEXT,
  icon_name TEXT,

  -- Weight for recommendations
  weight NUMERIC(3,2) DEFAULT 1.0,     -- 0.00 to 9.99

  -- Status
  is_active BOOLEAN DEFAULT true,

  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Indexes for hierarchy traversal
CREATE INDEX IF NOT EXISTS idx_tags_parent ON tags(parent_id);
CREATE INDEX IF NOT EXISTS idx_tags_type ON tags(tag_type);
CREATE INDEX IF NOT EXISTS idx_tags_path ON tags USING GIN(path);
CREATE INDEX IF NOT EXISTS idx_tags_slug ON tags(slug);
CREATE INDEX IF NOT EXISTS idx_tags_active ON tags(is_active) WHERE is_active = true;

-- Auto-update updated_at for tags
CREATE OR REPLACE FUNCTION update_tags_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_tags_updated_at
  BEFORE UPDATE ON tags
  FOR EACH ROW
  EXECUTE FUNCTION update_tags_updated_at();


-- ============================================
-- 3. content_tags: Many-to-many mapping
-- ============================================
CREATE TABLE IF NOT EXISTS content_tags (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  content_id UUID NOT NULL REFERENCES content_items(id) ON DELETE CASCADE,
  tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,

  -- Relationship metadata
  relevance_score NUMERIC(3,2) DEFAULT 1.0,  -- 0.00 to 9.99
  is_primary BOOLEAN DEFAULT false,          -- Primary tag for this content

  -- Admin tracking
  added_by TEXT DEFAULT 'system',            -- 'system', 'admin', 'ml'

  created_at TIMESTAMPTZ DEFAULT now(),

  UNIQUE(content_id, tag_id)
);

-- Indexes for fast joins
CREATE INDEX IF NOT EXISTS idx_content_tags_content ON content_tags(content_id);
CREATE INDEX IF NOT EXISTS idx_content_tags_tag ON content_tags(tag_id);
CREATE INDEX IF NOT EXISTS idx_content_tags_primary ON content_tags(is_primary) WHERE is_primary = true;


-- ============================================
-- 4. tag_synonyms: Alternative names for tags
-- ============================================
CREATE TABLE IF NOT EXISTS tag_synonyms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

  tag_id UUID NOT NULL REFERENCES tags(id) ON DELETE CASCADE,
  synonym TEXT NOT NULL,
  language TEXT DEFAULT 'ko',  -- 'ko', 'en'

  created_at TIMESTAMPTZ DEFAULT now(),

  UNIQUE(tag_id, synonym, language)
);

CREATE INDEX IF NOT EXISTS idx_tag_synonyms_synonym ON tag_synonyms(synonym);
CREATE INDEX IF NOT EXISTS idx_tag_synonyms_tag ON tag_synonyms(tag_id);


-- ============================================
-- 5. Helper Functions
-- ============================================

-- Function to get all child tags (recursive)
CREATE OR REPLACE FUNCTION get_tag_descendants(parent_slug TEXT)
RETURNS TABLE(id UUID, slug TEXT, name_ko TEXT, depth INTEGER) AS $$
  WITH RECURSIVE tag_tree AS (
    SELECT t.id, t.slug, t.name_ko, t.depth
    FROM tags t WHERE t.slug = parent_slug
    UNION ALL
    SELECT c.id, c.slug, c.name_ko, c.depth
    FROM tags c
    JOIN tag_tree p ON c.parent_id = p.id
  )
  SELECT * FROM tag_tree;
$$ LANGUAGE SQL STABLE;

-- Function to get content by tag slug
CREATE OR REPLACE FUNCTION get_content_by_tag(tag_slug TEXT)
RETURNS TABLE(
  content_id UUID,
  content_type TEXT,
  content_key TEXT,
  display_name TEXT,
  relevance_score NUMERIC
) AS $$
  SELECT
    ci.id,
    ci.content_type,
    ci.content_key,
    ci.display_name,
    ct.relevance_score
  FROM content_items ci
  JOIN content_tags ct ON ci.id = ct.content_id
  JOIN tags t ON ct.tag_id = t.id
  WHERE t.slug = tag_slug AND ci.is_active = true
  ORDER BY ct.relevance_score DESC, ct.is_primary DESC;
$$ LANGUAGE SQL STABLE;

-- Function to get tags for a content item
CREATE OR REPLACE FUNCTION get_content_tags(p_content_type TEXT, p_content_key TEXT)
RETURNS TABLE(
  tag_id UUID,
  slug TEXT,
  name_ko TEXT,
  tag_type TEXT,
  is_primary BOOLEAN,
  relevance_score NUMERIC
) AS $$
  SELECT
    t.id,
    t.slug,
    t.name_ko,
    t.tag_type,
    ct.is_primary,
    ct.relevance_score
  FROM tags t
  JOIN content_tags ct ON t.id = ct.tag_id
  JOIN content_items ci ON ct.content_id = ci.id
  WHERE ci.content_type = p_content_type
    AND ci.content_key = p_content_key
    AND t.is_active = true
  ORDER BY ct.is_primary DESC, ct.relevance_score DESC;
$$ LANGUAGE SQL STABLE;


-- ============================================
-- 6. RLS Policies (Backend-only management)
-- ============================================

-- Enable RLS
ALTER TABLE content_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE tag_synonyms ENABLE ROW LEVEL SECURITY;

-- Public read for active content/tags (no user modification)
CREATE POLICY "Public read active content_items" ON content_items
  FOR SELECT USING (is_active = true);

CREATE POLICY "Public read active tags" ON tags
  FOR SELECT USING (is_active = true);

CREATE POLICY "Public read content_tags" ON content_tags
  FOR SELECT USING (true);

CREATE POLICY "Public read tag_synonyms" ON tag_synonyms
  FOR SELECT USING (true);

-- Service role can do everything (for Edge Functions)
CREATE POLICY "Service role full access content_items" ON content_items
  FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

CREATE POLICY "Service role full access tags" ON tags
  FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

CREATE POLICY "Service role full access content_tags" ON content_tags
  FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

CREATE POLICY "Service role full access tag_synonyms" ON tag_synonyms
  FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');


-- ============================================
-- Comments for documentation
-- ============================================
COMMENT ON TABLE content_items IS 'Unified content registry for fortune, ASMR, surveys, etc. Backend-only.';
COMMENT ON TABLE tags IS 'Hierarchical tag system for content categorization. Backend-only.';
COMMENT ON TABLE content_tags IS 'Many-to-many mapping between content and tags.';
COMMENT ON TABLE tag_synonyms IS 'Alternative names for tags to improve search.';

COMMENT ON COLUMN content_items.content_type IS 'Type: fortune, asmr, survey, worldcup, article, quiz';
COMMENT ON COLUMN content_items.content_key IS 'Unique key within type (e.g., daily, love, tarot)';
COMMENT ON COLUMN tags.tag_type IS 'Classification: category, theme, mood, target, occasion, method, time, feature';
COMMENT ON COLUMN tags.path IS 'Materialized path array for fast hierarchy queries';
COMMENT ON COLUMN content_tags.is_primary IS 'Primary tag for this content (for display prioritization)';
