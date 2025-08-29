-- Create accurate celebrities table for accurate birth dates and genders
-- Drop existing table if it exists and recreate with proper schema

DROP TABLE IF EXISTS public.celebrities CASCADE;

-- Create celebrities table with proper schema for accurate data
CREATE TABLE public.celebrities (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    name_en TEXT DEFAULT '',
    birth_date TEXT NOT NULL,
    birth_time TEXT DEFAULT '12:00',
    gender TEXT NOT NULL CHECK (gender IN ('male', 'female', 'mixed')),
    birth_place TEXT DEFAULT '',
    category TEXT NOT NULL CHECK (category IN ('politician', 'actor', 'singer', 'streamer', 'business_leader', 'entertainer', 'athlete')),
    agency TEXT DEFAULT '',
    year_pillar TEXT DEFAULT '',
    month_pillar TEXT DEFAULT '',
    day_pillar TEXT DEFAULT '',
    hour_pillar TEXT DEFAULT '',
    saju_string TEXT DEFAULT '',
    wood_count INTEGER DEFAULT 0,
    fire_count INTEGER DEFAULT 0,
    earth_count INTEGER DEFAULT 0,
    metal_count INTEGER DEFAULT 0,
    water_count INTEGER DEFAULT 0,
    full_saju_data TEXT DEFAULT '',
    data_source TEXT DEFAULT 'accurate_manual',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Create indexes for better query performance
CREATE INDEX idx_celebrities_category ON public.celebrities(category);
CREATE INDEX idx_celebrities_name ON public.celebrities(name);
CREATE INDEX idx_celebrities_birth_date ON public.celebrities(birth_date);
CREATE INDEX idx_celebrities_gender ON public.celebrities(gender);
CREATE INDEX idx_celebrities_data_source ON public.celebrities(data_source);

-- Create full text search index for Korean and English names
CREATE INDEX idx_celebrities_name_search ON public.celebrities USING GIN(to_tsvector('simple', name || ' ' || COALESCE(name_en, '')));

-- Enable Row Level Security
ALTER TABLE public.celebrities ENABLE ROW LEVEL SECURITY;

-- Allow public read access
CREATE POLICY "Anyone can view celebrities" ON public.celebrities
    FOR SELECT USING (true);

-- Allow service role to insert/update/delete
CREATE POLICY "Service role can manage celebrities" ON public.celebrities
    FOR ALL USING (auth.jwt() ->> 'role' = 'service_role');

-- Create function to search celebrities
CREATE OR REPLACE FUNCTION search_celebrities(search_query TEXT)
RETURNS SETOF celebrities AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM celebrities
    WHERE (
        name ILIKE '%' || search_query || '%'
        OR name_en ILIKE '%' || search_query || '%'
    )
    ORDER BY name;
END;
$$ LANGUAGE plpgsql;

-- Create function to get celebrities by category
CREATE OR REPLACE FUNCTION get_celebrities_by_category(category_name TEXT)
RETURNS SETOF celebrities AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM celebrities
    WHERE category = category_name
    ORDER BY name;
END;
$$ LANGUAGE plpgsql;

-- Add comment to table
COMMENT ON TABLE public.celebrities IS '유명인 정보를 저장하는 테이블 (정확한 생년월일과 성별)';
COMMENT ON COLUMN public.celebrities.category IS '유명인 카테고리: politician(정치인), actor(배우), singer(가수), streamer(스트리머), business_leader(경영인), entertainer(방송인), athlete(운동선수)';
COMMENT ON COLUMN public.celebrities.gender IS '성별: male(남성), female(여성), mixed(혼성그룹)';
COMMENT ON COLUMN public.celebrities.data_source IS '데이터 출처: accurate_manual(수동으로 정확하게 입력된 데이터)';