-- Create fortune popularity tracking table
CREATE TABLE IF NOT EXISTS public.fortune_popularity (
    fortune_type TEXT PRIMARY KEY,
    visit_count INTEGER DEFAULT 0,
    weekly_trend FLOAT DEFAULT 0.0,
    seasonal_boost FLOAT DEFAULT 1.0,
    last_calculated TIMESTAMP DEFAULT NOW(),
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_fortune_popularity_visit_count ON public.fortune_popularity(visit_count DESC);
CREATE INDEX IF NOT EXISTS idx_fortune_popularity_weekly_trend ON public.fortune_popularity(weekly_trend DESC);

-- Create user fortune visit tracking table
CREATE TABLE IF NOT EXISTS public.user_fortune_visits (
    user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
    fortune_type TEXT NOT NULL,
    visit_count INTEGER DEFAULT 1,
    first_visited TIMESTAMP DEFAULT NOW(),
    last_visited TIMESTAMP DEFAULT NOW(),
    is_favorite BOOLEAN DEFAULT FALSE,
    PRIMARY KEY (user_id, fortune_type)
);

-- Create indexes for user fortune visits
CREATE INDEX IF NOT EXISTS idx_user_fortune_visits_user_id ON public.user_fortune_visits(user_id);
CREATE INDEX IF NOT EXISTS idx_user_fortune_visits_last_visited ON public.user_fortune_visits(last_visited DESC);
CREATE INDEX IF NOT EXISTS idx_user_fortune_visits_favorite ON public.user_fortune_visits(user_id, is_favorite) WHERE is_favorite = TRUE;

-- Create fortune visit log for analytics
CREATE TABLE IF NOT EXISTS public.fortune_visit_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id UUID REFERENCES auth.users(id) ON DELETE SET NULL,
    fortune_type TEXT NOT NULL,
    visited_at TIMESTAMP DEFAULT NOW(),
    session_id TEXT,
    referrer TEXT,
    device_type TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- Create index for analytics queries
CREATE INDEX IF NOT EXISTS idx_fortune_visit_logs_visited_at ON public.fortune_visit_logs(visited_at DESC);
CREATE INDEX IF NOT EXISTS idx_fortune_visit_logs_fortune_type ON public.fortune_visit_logs(fortune_type, visited_at DESC);
CREATE INDEX IF NOT EXISTS idx_fortune_visit_logs_user_id ON public.fortune_visit_logs(user_id, visited_at DESC);

-- Function to update user fortune visits
CREATE OR REPLACE FUNCTION update_user_fortune_visit(
    p_user_id UUID,
    p_fortune_type TEXT
) RETURNS VOID AS $$
BEGIN
    INSERT INTO public.user_fortune_visits (user_id, fortune_type, visit_count, last_visited)
    VALUES (p_user_id, p_fortune_type, 1, NOW())
    ON CONFLICT (user_id, fortune_type)
    DO UPDATE SET
        visit_count = user_fortune_visits.visit_count + 1,
        last_visited = NOW();
END;
$$ LANGUAGE plpgsql;

-- Function to update fortune popularity
CREATE OR REPLACE FUNCTION update_fortune_popularity(
    p_fortune_type TEXT
) RETURNS VOID AS $$
BEGIN
    INSERT INTO public.fortune_popularity (fortune_type, visit_count, updated_at)
    VALUES (p_fortune_type, 1, NOW())
    ON CONFLICT (fortune_type)
    DO UPDATE SET
        visit_count = fortune_popularity.visit_count + 1,
        updated_at = NOW();
END;
$$ LANGUAGE plpgsql;

-- Function to calculate weekly trends (to be run periodically)
CREATE OR REPLACE FUNCTION calculate_weekly_trends() RETURNS VOID AS $$
DECLARE
    v_fortune_type TEXT;
    v_current_week_count INTEGER;
    v_last_week_count INTEGER;
    v_trend FLOAT;
BEGIN
    FOR v_fortune_type IN (SELECT DISTINCT fortune_type FROM public.fortune_visit_logs)
    LOOP
        -- Get current week count
        SELECT COUNT(*) INTO v_current_week_count
        FROM public.fortune_visit_logs
        WHERE fortune_type = v_fortune_type
        AND visited_at >= NOW() - INTERVAL '7 days';
        
        -- Get last week count
        SELECT COUNT(*) INTO v_last_week_count
        FROM public.fortune_visit_logs
        WHERE fortune_type = v_fortune_type
        AND visited_at >= NOW() - INTERVAL '14 days'
        AND visited_at < NOW() - INTERVAL '7 days';
        
        -- Calculate trend percentage
        IF v_last_week_count > 0 THEN
            v_trend := ((v_current_week_count::FLOAT - v_last_week_count::FLOAT) / v_last_week_count::FLOAT) * 100;
        ELSE
            v_trend := 100.0; -- If no visits last week, consider it 100% growth
        END IF;
        
        -- Update fortune popularity
        UPDATE public.fortune_popularity
        SET weekly_trend = v_trend,
            last_calculated = NOW()
        WHERE fortune_type = v_fortune_type;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Trigger to log fortune visits
CREATE OR REPLACE FUNCTION log_fortune_visit() RETURNS TRIGGER AS $$
BEGIN
    -- Update fortune popularity
    PERFORM update_fortune_popularity(NEW.fortune_type);
    
    -- Update user visit if user_id is present
    IF NEW.user_id IS NOT NULL THEN
        PERFORM update_user_fortune_visit(NEW.user_id, NEW.fortune_type);
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for fortune visit logs
CREATE TRIGGER trigger_log_fortune_visit
    AFTER INSERT ON public.fortune_visit_logs
    FOR EACH ROW
    EXECUTE FUNCTION log_fortune_visit();

-- Add fortune_preferences column to user_profiles if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT column_name 
        FROM information_schema.columns 
        WHERE table_name = 'user_profiles' 
        AND column_name = 'fortune_preferences'
    ) THEN
        ALTER TABLE public.user_profiles
        ADD COLUMN fortune_preferences JSONB DEFAULT '{
            "category_weights": {},
            "visited_fortunes": {},
            "last_visited": {},
            "favorites": [],
            "excluded": [],
            "preferred_hour": null,
            "language_preference": "ko",
            "show_trending": true,
            "show_personalized": true
        }'::jsonb;
    END IF;
END $$;

-- Create index on fortune_preferences
CREATE INDEX IF NOT EXISTS idx_user_profiles_fortune_preferences ON public.user_profiles USING GIN (fortune_preferences);

-- Insert initial popularity data for all fortune types
INSERT INTO public.fortune_popularity (fortune_type, visit_count, seasonal_boost)
VALUES
    ('love', 1000, 1.0),
    ('career', 900, 1.0),
    ('money', 850, 1.0),
    ('daily', 1200, 1.0),
    ('tarot', 800, 1.2),
    ('saju', 700, 1.0),
    ('health', 600, 1.0),
    ('personality', 550, 1.1),
    ('compatibility', 750, 1.0),
    ('dream', 500, 1.0),
    ('lucky_items', 450, 1.0),
    ('biorhythm', 400, 1.0),
    ('traditional', 650, 1.0),
    ('time', 1100, 1.0),
    ('chemistry', 600, 1.0),
    ('marriage', 700, 1.0),
    ('ex-lover', 550, 1.1),
    ('investment', 800, 1.0),
    ('fortune-cookie', 400, 1.2),
    ('celebrity', 450, 1.2),
    ('pet', 350, 1.1),
    ('family', 400, 1.0),
    ('study', 500, 1.0),
    ('business', 600, 1.0)
ON CONFLICT (fortune_type) DO NOTHING;

-- Grant permissions
GRANT SELECT ON public.fortune_popularity TO authenticated;
GRANT SELECT, INSERT, UPDATE ON public.user_fortune_visits TO authenticated;
GRANT INSERT ON public.fortune_visit_logs TO authenticated;

-- Enable RLS
ALTER TABLE public.user_fortune_visits ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fortune_visit_logs ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Users can view their own fortune visits"
    ON public.user_fortune_visits
    FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own fortune visits"
    ON public.user_fortune_visits
    FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own fortune visits"
    ON public.user_fortune_visits
    FOR UPDATE
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can insert fortune visit logs"
    ON public.fortune_visit_logs
    FOR INSERT
    WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

-- Add comment for documentation
COMMENT ON TABLE public.fortune_popularity IS 'Tracks overall popularity metrics for each fortune type';
COMMENT ON TABLE public.user_fortune_visits IS 'Tracks individual user visits to fortune types';
COMMENT ON TABLE public.fortune_visit_logs IS 'Detailed log of all fortune visits for analytics';
COMMENT ON COLUMN public.user_profiles.fortune_preferences IS 'User preferences for fortune recommendations';