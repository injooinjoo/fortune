-- Create new celebrity schema with profession-specific data
-- Created: 2025-01-19
-- Based on: Enhanced celebrity schema with common fields + profession-specific JSON data

-- Drop existing celebrities table and related objects
DROP TABLE IF EXISTS public.celebrities CASCADE;

-- Create the new celebrities table with comprehensive schema
CREATE TABLE public.celebrities (
    -- Core identity fields (required)
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,                           -- 활동명 (required)
    birth_date DATE NOT NULL,                     -- 생년월일 (required)
    gender TEXT NOT NULL CHECK (gender IN ('male', 'female', 'other')), -- 성별 (required)

    -- Extended identity fields (optional)
    stage_name TEXT,                              -- 예명 (name과 다르면)
    legal_name TEXT,                              -- 본명
    aliases TEXT[] DEFAULT '{}',                  -- 다른 표기/닉네임
    nationality TEXT DEFAULT '한국',               -- 국적
    birth_place TEXT,                             -- 출생지 (점성용)
    birth_time TIME DEFAULT '12:00',              -- 출생시각 (점성 정확도용)

    -- Professional information
    celebrity_type TEXT NOT NULL CHECK (celebrity_type IN (
        'pro_gamer', 'streamer', 'politician', 'business',
        'solo_singer', 'idol_member', 'actor', 'athlete'
    )),
    active_from INTEGER,                          -- 데뷔/프로 전향 연도
    agency_management TEXT,                       -- 소속 (엔터/에이전시/매니지먼트)
    languages TEXT[] DEFAULT '{"한국어"}',         -- 사용 언어

    -- External references
    external_ids JSONB DEFAULT '{}',              -- 외부 참조 (wikipedia, imdb, youtube, twitch, instagram, x)

    -- Profession-specific data (stored as JSON for flexibility)
    profession_data JSONB DEFAULT '{}',           -- 직군별 특화 정보

    -- General fields
    notes TEXT,                                   -- 비고

    -- System fields
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Create indexes for better query performance
CREATE INDEX idx_celebrities_name ON public.celebrities(name);
CREATE INDEX idx_celebrities_celebrity_type ON public.celebrities(celebrity_type);
CREATE INDEX idx_celebrities_birth_date ON public.celebrities(birth_date);
CREATE INDEX idx_celebrities_gender ON public.celebrities(gender);
CREATE INDEX idx_celebrities_nationality ON public.celebrities(nationality);
CREATE INDEX idx_celebrities_active_from ON public.celebrities(active_from);

-- Create GIN indexes for array and JSONB fields
CREATE INDEX idx_celebrities_aliases ON public.celebrities USING GIN(aliases);
CREATE INDEX idx_celebrities_languages ON public.celebrities USING GIN(languages);
CREATE INDEX idx_celebrities_external_ids ON public.celebrities USING GIN(external_ids);
CREATE INDEX idx_celebrities_profession_data ON public.celebrities USING GIN(profession_data);

-- Create full text search index
CREATE INDEX idx_celebrities_search ON public.celebrities USING GIN(
    to_tsvector('simple', name || ' ' || COALESCE(stage_name, '') || ' ' || COALESCE(legal_name, '') || ' ' || array_to_string(aliases, ' '))
);

-- Add trigger to update updated_at column
CREATE OR REPLACE FUNCTION update_celebrities_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc', NOW());
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_celebrities_updated_at
    BEFORE UPDATE ON public.celebrities
    FOR EACH ROW
    EXECUTE FUNCTION update_celebrities_updated_at();

-- Enable Row Level Security
ALTER TABLE public.celebrities ENABLE ROW LEVEL SECURITY;

-- Allow public read access
CREATE POLICY "Anyone can view celebrities" ON public.celebrities
    FOR SELECT USING (true);

-- Allow service role to manage celebrities
CREATE POLICY "Service role can manage celebrities" ON public.celebrities
    FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

-- Create comprehensive search function
CREATE OR REPLACE FUNCTION search_celebrities(
    search_query TEXT DEFAULT NULL,
    celebrity_type_filter TEXT DEFAULT NULL,
    gender_filter TEXT DEFAULT NULL,
    nationality_filter TEXT DEFAULT NULL,
    limit_count INTEGER DEFAULT 50
)
RETURNS SETOF celebrities AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM celebrities
    WHERE (
        search_query IS NULL OR (
            name ILIKE '%' || search_query || '%' OR
            stage_name ILIKE '%' || search_query || '%' OR
            legal_name ILIKE '%' || search_query || '%' OR
            search_query = ANY(aliases)
        )
    )
    AND (celebrity_type_filter IS NULL OR celebrity_type = celebrity_type_filter)
    AND (gender_filter IS NULL OR gender = gender_filter)
    AND (nationality_filter IS NULL OR nationality = nationality_filter)
    ORDER BY name
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Create function to get celebrities by type
CREATE OR REPLACE FUNCTION get_celebrities_by_type(
    type_name TEXT,
    limit_count INTEGER DEFAULT 50
)
RETURNS SETOF celebrities AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM celebrities
    WHERE celebrity_type = type_name
    ORDER BY name
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Create function to get random celebrities
CREATE OR REPLACE FUNCTION get_random_celebrities(
    limit_count INTEGER DEFAULT 10,
    type_filter TEXT DEFAULT NULL
)
RETURNS SETOF celebrities AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM celebrities
    WHERE (type_filter IS NULL OR celebrity_type = type_filter)
    ORDER BY RANDOM()
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Add table and column comments
COMMENT ON TABLE public.celebrities IS '유명인 정보를 저장하는 새로운 테이블 (2025년 리뉴얼)';
COMMENT ON COLUMN public.celebrities.celebrity_type IS '직업 유형: pro_gamer(프로게이머), streamer(스트리머), politician(정치인), business(기업인), solo_singer(솔로가수), idol_member(아이돌멤버), actor(배우), athlete(운동선수)';
COMMENT ON COLUMN public.celebrities.profession_data IS '직업별 특화 정보를 JSON 형태로 저장';
COMMENT ON COLUMN public.celebrities.external_ids IS '외부 서비스 참조 링크 (wikipedia, imdb, youtube, twitch, instagram, x)';

-- Create migration log entry
INSERT INTO public.migration_log (migration_name, status, message, created_at)
VALUES (
    'create_new_celebrity_schema',
    'completed',
    'Successfully created new celebrity schema with profession-specific data support',
    NOW()
) ON CONFLICT DO NOTHING;