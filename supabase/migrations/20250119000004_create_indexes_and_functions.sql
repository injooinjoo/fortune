-- Create additional indexes and helper functions for celebrity management
-- Created: 2025-01-19

-- Create migration log table if it doesn't exist
CREATE TABLE IF NOT EXISTS public.migration_log (
    id SERIAL PRIMARY KEY,
    migration_name TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('started', 'completed', 'failed')),
    message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create comprehensive profession-specific search functions

-- Function to get pro gamers by game
CREATE OR REPLACE FUNCTION get_pro_gamers_by_game(
    game_title TEXT,
    limit_count INTEGER DEFAULT 50
)
RETURNS SETOF celebrities AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM celebrities
    WHERE celebrity_type = 'pro_gamer'
    AND profession_data->>'game_title' ILIKE '%' || game_title || '%'
    ORDER BY name
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Function to get streamers by platform
CREATE OR REPLACE FUNCTION get_streamers_by_platform(
    platform TEXT,
    limit_count INTEGER DEFAULT 50
)
RETURNS SETOF celebrities AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM celebrities
    WHERE celebrity_type = 'streamer'
    AND profession_data->>'main_platform' = platform
    ORDER BY name
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Function to get politicians by party
CREATE OR REPLACE FUNCTION get_politicians_by_party(
    party_name TEXT,
    limit_count INTEGER DEFAULT 50
)
RETURNS SETOF celebrities AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM celebrities
    WHERE celebrity_type = 'politician'
    AND profession_data->>'party' ILIKE '%' || party_name || '%'
    ORDER BY name
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Function to get business leaders by industry
CREATE OR REPLACE FUNCTION get_business_leaders_by_industry(
    industry_name TEXT,
    limit_count INTEGER DEFAULT 50
)
RETURNS SETOF celebrities AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM celebrities
    WHERE celebrity_type = 'business'
    AND profession_data->>'industry' ILIKE '%' || industry_name || '%'
    ORDER BY name
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Function to get idol members by group
CREATE OR REPLACE FUNCTION get_idol_members_by_group(
    group_name TEXT,
    limit_count INTEGER DEFAULT 50
)
RETURNS SETOF celebrities AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM celebrities
    WHERE celebrity_type = 'idol_member'
    AND profession_data->>'group_name' ILIKE '%' || group_name || '%'
    ORDER BY name
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Function to get solo singers by genre
CREATE OR REPLACE FUNCTION get_solo_singers_by_genre(
    genre TEXT,
    limit_count INTEGER DEFAULT 50
)
RETURNS SETOF celebrities AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM celebrities
    WHERE celebrity_type = 'solo_singer'
    AND profession_data->'genres' ? genre
    ORDER BY name
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Function to get actors by specialty
CREATE OR REPLACE FUNCTION get_actors_by_specialty(
    specialty TEXT,
    limit_count INTEGER DEFAULT 50
)
RETURNS SETOF celebrities AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM celebrities
    WHERE celebrity_type = 'actor'
    AND profession_data->'specialties' ? specialty
    ORDER BY name
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Function to get athletes by sport
CREATE OR REPLACE FUNCTION get_athletes_by_sport(
    sport_name TEXT,
    limit_count INTEGER DEFAULT 50
)
RETURNS SETOF celebrities AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM celebrities
    WHERE celebrity_type = 'athlete'
    AND profession_data->>'sport' ILIKE '%' || sport_name || '%'
    ORDER BY name
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Function to get celebrities by birth year range
CREATE OR REPLACE FUNCTION get_celebrities_by_birth_year_range(
    start_year INTEGER,
    end_year INTEGER,
    celebrity_type_filter TEXT DEFAULT NULL,
    limit_count INTEGER DEFAULT 50
)
RETURNS SETOF celebrities AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM celebrities
    WHERE EXTRACT(YEAR FROM birth_date) BETWEEN start_year AND end_year
    AND (celebrity_type_filter IS NULL OR celebrity_type = celebrity_type_filter)
    ORDER BY birth_date DESC, name
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Function to get celebrities with external links
CREATE OR REPLACE FUNCTION get_celebrities_with_external_links(
    platform TEXT,
    limit_count INTEGER DEFAULT 50
)
RETURNS SETOF celebrities AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM celebrities
    WHERE external_ids ? platform
    AND external_ids->>platform IS NOT NULL
    AND external_ids->>platform != ''
    ORDER BY name
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Function to update external ID for a celebrity
CREATE OR REPLACE FUNCTION update_celebrity_external_id(
    celebrity_id TEXT,
    platform TEXT,
    url TEXT
)
RETURNS BOOLEAN AS $$
BEGIN
    UPDATE celebrities
    SET external_ids = external_ids || jsonb_build_object(platform, url),
        updated_at = NOW()
    WHERE id = celebrity_id;

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- Function to add profession data field
CREATE OR REPLACE FUNCTION update_celebrity_profession_data(
    celebrity_id TEXT,
    data_key TEXT,
    data_value TEXT
)
RETURNS BOOLEAN AS $$
BEGIN
    UPDATE celebrities
    SET profession_data = profession_data || jsonb_build_object(data_key, data_value),
        updated_at = NOW()
    WHERE id = celebrity_id;

    RETURN FOUND;
END;
$$ LANGUAGE plpgsql;

-- Function to get celebrity statistics by type
CREATE OR REPLACE FUNCTION get_celebrity_statistics()
RETURNS TABLE(
    celebrity_type TEXT,
    count BIGINT,
    avg_birth_year NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.celebrity_type,
        COUNT(*) as count,
        ROUND(AVG(EXTRACT(YEAR FROM c.birth_date)), 1) as avg_birth_year
    FROM celebrities c
    GROUP BY c.celebrity_type
    ORDER BY count DESC;
END;
$$ LANGUAGE plpgsql;

-- Create additional optimized indexes
CREATE INDEX IF NOT EXISTS idx_celebrities_birth_year ON public.celebrities(EXTRACT(YEAR FROM birth_date));
CREATE INDEX IF NOT EXISTS idx_celebrities_profession_data_keys ON public.celebrities USING GIN((profession_data ? ARRAY['game_title', 'main_platform', 'party', 'industry', 'group_name', 'sport']));

-- Create composite indexes for common query patterns
CREATE INDEX IF NOT EXISTS idx_celebrities_type_birth_date ON public.celebrities(celebrity_type, birth_date);
CREATE INDEX IF NOT EXISTS idx_celebrities_type_name ON public.celebrities(celebrity_type, name);
CREATE INDEX IF NOT EXISTS idx_celebrities_nationality_type ON public.celebrities(nationality, celebrity_type);

-- Add helpful views for common queries
CREATE OR REPLACE VIEW celebrity_summary AS
SELECT
    id,
    name,
    celebrity_type,
    gender,
    EXTRACT(YEAR FROM birth_date) as birth_year,
    nationality,
    agency_management,
    CASE
        WHEN celebrity_type = 'pro_gamer' THEN profession_data->>'game_title'
        WHEN celebrity_type = 'streamer' THEN profession_data->>'main_platform'
        WHEN celebrity_type = 'politician' THEN profession_data->>'party'
        WHEN celebrity_type = 'business' THEN profession_data->>'company_name'
        WHEN celebrity_type = 'idol_member' THEN profession_data->>'group_name'
        WHEN celebrity_type = 'solo_singer' THEN profession_data->>'label'
        WHEN celebrity_type = 'actor' THEN profession_data->>'agency'
        WHEN celebrity_type = 'athlete' THEN profession_data->>'sport'
        ELSE NULL
    END as primary_info
FROM celebrities
ORDER BY name;

-- Create migration log entry
INSERT INTO public.migration_log (migration_name, status, message, created_at)
VALUES (
    'create_indexes_and_functions',
    'completed',
    'Successfully created additional indexes and helper functions for celebrity management',
    NOW()
) ON CONFLICT DO NOTHING;