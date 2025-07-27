-- Create celebrity_profiles table
CREATE TABLE IF NOT EXISTS public.celebrity_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    name_en TEXT NOT NULL,
    category TEXT NOT NULL,
    gender TEXT NOT NULL,
    birth_date DATE NOT NULL,
    birth_time TIME,
    profile_image_url TEXT,
    description TEXT,
    keywords TEXT[],
    nationality TEXT DEFAULT '한국',
    metadata JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for faster searches
CREATE INDEX idx_celebrity_profiles_category ON public.celebrity_profiles(category);
CREATE INDEX idx_celebrity_profiles_name ON public.celebrity_profiles(name);
CREATE INDEX idx_celebrity_profiles_keywords ON public.celebrity_profiles USING GIN(keywords);

-- Create celebrity_daily_fortunes table
CREATE TABLE IF NOT EXISTS public.celebrity_daily_fortunes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    celebrity_id UUID NOT NULL REFERENCES public.celebrity_profiles(id) ON DELETE CASCADE,
    date DATE NOT NULL,
    fortune_data JSONB NOT NULL,
    generated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(celebrity_id, date)
);

-- Create index for faster lookups
CREATE INDEX idx_celebrity_daily_fortunes_date ON public.celebrity_daily_fortunes(date);
CREATE INDEX idx_celebrity_daily_fortunes_celebrity_id ON public.celebrity_daily_fortunes(celebrity_id);

-- Create user_celebrity_fortune_history table
CREATE TABLE IF NOT EXISTS public.user_celebrity_fortune_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    celebrity_id UUID NOT NULL REFERENCES public.celebrity_profiles(id),
    fortune_data JSONB NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create index for user history
CREATE INDEX idx_user_celebrity_fortune_history_user_id ON public.user_celebrity_fortune_history(user_id);
CREATE INDEX idx_user_celebrity_fortune_history_created_at ON public.user_celebrity_fortune_history(created_at);

-- Enable Row Level Security
ALTER TABLE public.celebrity_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.celebrity_daily_fortunes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_celebrity_fortune_history ENABLE ROW LEVEL SECURITY;

-- Policies for celebrity_profiles (read-only for all users)
CREATE POLICY "Celebrity profiles are viewable by everyone" ON public.celebrity_profiles
    FOR SELECT USING (true);

-- Policies for celebrity_daily_fortunes (read-only for all users)
CREATE POLICY "Celebrity daily fortunes are viewable by everyone" ON public.celebrity_daily_fortunes
    FOR SELECT USING (true);

-- Policies for user_celebrity_fortune_history
CREATE POLICY "Users can view their own fortune history" ON public.user_celebrity_fortune_history
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own fortune history" ON public.user_celebrity_fortune_history
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Trigger to automatically update updated_at
CREATE TRIGGER update_celebrity_profiles_updated_at BEFORE UPDATE ON public.celebrity_profiles
    FOR EACH ROW EXECUTE PROCEDURE update_updated_at_column();

-- Function to clean up old fortune data (keep last 30 days)
CREATE OR REPLACE FUNCTION cleanup_old_celebrity_fortunes()
RETURNS void AS $$
BEGIN
    DELETE FROM public.celebrity_daily_fortunes
    WHERE date < CURRENT_DATE - INTERVAL '30 days';
END;
$$ LANGUAGE plpgsql;

-- Sample celebrity data insertion
INSERT INTO public.celebrity_profiles (id, name, name_en, category, gender, birth_date, birth_time, profile_image_url, description, keywords) VALUES
-- Politicians
('pol_001', '윤석열', 'Yoon Suk-yeol', 'politician', 'male', '1960-12-18', NULL, 'https://example.com/yoon.jpg', '대한민국 제20대 대통령', ARRAY['대통령', '정치인', '검찰총장']),
('pol_002', '이재명', 'Lee Jae-myung', 'politician', 'male', '1964-12-22', NULL, 'https://example.com/lee.jpg', '더불어민주당 대표', ARRAY['정치인', '경기도지사', '성남시장']),

-- Actors
('act_001', '송중기', 'Song Joong-ki', 'actor', 'male', '1985-09-19', '08:00', 'https://example.com/sjk.jpg', '대표작: 태양의 후예, 빈센조', ARRAY['배우', '태양의후예', '빈센조']),
('act_002', '송혜교', 'Song Hye-kyo', 'actor', 'female', '1981-11-22', NULL, 'https://example.com/shk.jpg', '대표작: 태양의 후예, 더 글로리', ARRAY['배우', '태양의후예', '더글로리']),
('act_003', '이정재', 'Lee Jung-jae', 'actor', 'male', '1972-12-15', NULL, 'https://example.com/ljj.jpg', '대표작: 오징어 게임, 신세계', ARRAY['배우', '오징어게임', '신세계']),

-- K-pop singers
('singer_001', 'IU', 'IU', 'singer', 'female', '1993-05-16', '06:00', 'https://example.com/iu.jpg', '가수 겸 배우', ARRAY['가수', '아이유', '배우']),
('singer_002', 'G-Dragon', 'G-Dragon', 'singer', 'male', '1988-08-18', NULL, 'https://example.com/gd.jpg', 'BIGBANG 리더', ARRAY['가수', '빅뱅', 'GD']),
('singer_003', '정국', 'Jungkook', 'singer', 'male', '1997-09-01', '15:00', 'https://example.com/jk.jpg', 'BTS 멤버', ARRAY['가수', 'BTS', '방탄소년단']),

-- Sports stars
('sports_001', '손흥민', 'Son Heung-min', 'sports', 'male', '1992-07-08', NULL, 'https://example.com/son.jpg', '토트넘 축구선수', ARRAY['축구', '손흥민', '토트넘']),
('sports_002', '김연아', 'Kim Yuna', 'sports', 'female', '1990-09-05', NULL, 'https://example.com/yuna.jpg', '피겨스케이팅 올림픽 금메달리스트', ARRAY['피겨', '김연아', '올림픽']),

-- YouTubers
('yt_001', '펭수', 'Pengsoo', 'youtuber', 'other', '2019-04-25', NULL, 'https://example.com/pengsoo.jpg', 'EBS 캐릭터 유튜버', ARRAY['펭수', 'EBS', '유튜버']),
('yt_002', '쯔양', 'Tzuyang', 'youtuber', 'female', '1996-11-16', NULL, 'https://example.com/tzuyang.jpg', '먹방 유튜버', ARRAY['쯔양', '먹방', '유튜버'])

ON CONFLICT (id) DO NOTHING;