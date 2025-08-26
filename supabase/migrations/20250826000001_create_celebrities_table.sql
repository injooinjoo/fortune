-- Create celebrities table
CREATE TABLE IF NOT EXISTS public.celebrities (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    name_en TEXT,
    category TEXT NOT NULL CHECK (category IN ('politician', 'actor', 'singer', 'sports', 'pro_gamer', 'streamer', 'youtuber', 'business_leader', 'entertainer', 'athlete')),
    gender TEXT NOT NULL CHECK (gender IN ('male', 'female', 'other')),
    birth_date DATE NOT NULL,
    birth_time TIME,
    profile_image_url TEXT,
    description TEXT,
    keywords TEXT[] DEFAULT '{}',
    nationality TEXT DEFAULT '한국',
    additional_info JSONB DEFAULT '{}',
    popularity_score INTEGER DEFAULT 0,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Create indexes for better query performance
CREATE INDEX idx_celebrities_category ON public.celebrities(category);
CREATE INDEX idx_celebrities_name ON public.celebrities(name);
CREATE INDEX idx_celebrities_name_en ON public.celebrities(name_en);
CREATE INDEX idx_celebrities_birth_date ON public.celebrities(birth_date);
CREATE INDEX idx_celebrities_popularity ON public.celebrities(popularity_score DESC);
CREATE INDEX idx_celebrities_is_active ON public.celebrities(is_active);
CREATE INDEX idx_celebrities_keywords ON public.celebrities USING GIN(keywords);

-- Create full text search index for Korean and English names
CREATE INDEX idx_celebrities_name_search ON public.celebrities USING GIN(to_tsvector('simple', name || ' ' || COALESCE(name_en, '')));

-- Add trigger to update updated_at column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = TIMEZONE('utc', NOW());
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_celebrities_updated_at BEFORE UPDATE
    ON public.celebrities FOR EACH ROW
    EXECUTE PROCEDURE update_updated_at_column();

-- Add RLS (Row Level Security) policies
ALTER TABLE public.celebrities ENABLE ROW LEVEL SECURITY;

-- Allow public read access
CREATE POLICY "Anyone can view celebrities" ON public.celebrities
    FOR SELECT USING (is_active = true);

-- Allow authenticated users to insert/update (for admin features later)
CREATE POLICY "Authenticated users can insert celebrities" ON public.celebrities
    FOR INSERT WITH CHECK (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users can update celebrities" ON public.celebrities
    FOR UPDATE USING (auth.role() = 'authenticated');

-- Create function to search celebrities
CREATE OR REPLACE FUNCTION search_celebrities(search_query TEXT)
RETURNS SETOF celebrities AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM celebrities
    WHERE is_active = true
    AND (
        name ILIKE '%' || search_query || '%'
        OR name_en ILIKE '%' || search_query || '%'
        OR search_query = ANY(keywords)
        OR description ILIKE '%' || search_query || '%'
    )
    ORDER BY popularity_score DESC, name;
END;
$$ LANGUAGE plpgsql;

-- Create function to get celebrities by category
CREATE OR REPLACE FUNCTION get_celebrities_by_category(category_name TEXT)
RETURNS SETOF celebrities AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM celebrities
    WHERE is_active = true
    AND category = category_name
    ORDER BY popularity_score DESC, name;
END;
$$ LANGUAGE plpgsql;

-- Create function to get popular celebrities
CREATE OR REPLACE FUNCTION get_popular_celebrities(limit_count INTEGER DEFAULT 10)
RETURNS SETOF celebrities AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM celebrities
    WHERE is_active = true
    ORDER BY popularity_score DESC, name
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Create function to get random celebrities
CREATE OR REPLACE FUNCTION get_random_celebrities(limit_count INTEGER DEFAULT 10, category_filter TEXT DEFAULT NULL)
RETURNS SETOF celebrities AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM celebrities
    WHERE is_active = true
    AND (category_filter IS NULL OR category = category_filter)
    ORDER BY RANDOM()
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Add comment to table
COMMENT ON TABLE public.celebrities IS '유명인 정보를 저장하는 테이블';
COMMENT ON COLUMN public.celebrities.category IS '유명인 카테고리: politician(정치인), actor(배우), singer(가수), sports(스포츠스타), pro_gamer(프로게이머), streamer(스트리머), youtuber(유튜버), business_leader(경영인), entertainer(방송인), athlete(운동선수)';
COMMENT ON COLUMN public.celebrities.gender IS '성별: male(남성), female(여성), other(기타)';
COMMENT ON COLUMN public.celebrities.popularity_score IS '인기도 점수 (높을수록 인기 많음)';
COMMENT ON COLUMN public.celebrities.is_active IS '활성 상태 (false면 표시하지 않음)';