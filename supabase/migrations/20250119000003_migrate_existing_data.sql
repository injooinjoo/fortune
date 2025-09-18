-- Migrate existing celebrity data to new schema
-- Created: 2025-01-19

-- Function to determine celebrity type based on existing category and name
CREATE OR REPLACE FUNCTION determine_celebrity_type(category TEXT, name TEXT)
RETURNS TEXT AS $$
BEGIN
    -- Check for idol groups/members first
    IF category = 'singer' THEN
        -- Known groups (add more as needed)
        IF name IN ('BTS', '블랙핑크', '트와이스', '소녀시대', '빅뱅', '슈퍼주니어', '샤이니', '레드벨벳', '에스파', '뉴진스', '르세라핌', '아이브') THEN
            RETURN 'idol_member';
        -- Solo artists
        ELSE
            RETURN 'solo_singer';
        END IF;
    -- Map other categories directly
    ELSIF category = 'politician' THEN
        RETURN 'politician';
    ELSIF category = 'actor' THEN
        RETURN 'actor';
    ELSIF category = 'athlete' OR category = 'sports' THEN
        RETURN 'athlete';
    ELSIF category = 'business_leader' THEN
        RETURN 'business';
    ELSIF category = 'streamer' THEN
        RETURN 'streamer';
    ELSIF category = 'pro_gamer' THEN
        RETURN 'pro_gamer';
    ELSIF category = 'entertainer' THEN
        -- Entertainer could be actor or solo_singer, default to actor
        RETURN 'actor';
    ELSE
        -- Default fallback
        RETURN 'actor';
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Function to convert existing additional_info to profession_data
CREATE OR REPLACE FUNCTION convert_to_profession_data(
    category TEXT,
    additional_info JSONB,
    saju_data TEXT DEFAULT NULL
)
RETURNS JSONB AS $$
DECLARE
    result JSONB := '{}';
BEGIN
    -- Add saju data if exists (for compatibility)
    IF saju_data IS NOT NULL AND saju_data != '' THEN
        result := result || jsonb_build_object('legacy_saju_data', saju_data);
    END IF;

    -- Convert existing additional_info if exists
    IF additional_info IS NOT NULL THEN
        result := result || additional_info;
    END IF;

    -- Add category-specific default structure
    CASE category
        WHEN 'pro_gamer' THEN
            result := result || jsonb_build_object(
                'game_title', COALESCE(result->>'game_title', ''),
                'primary_role', COALESCE(result->>'primary_role', ''),
                'team', COALESCE(result->>'team', ''),
                'league_region', COALESCE(result->>'league_region', ''),
                'jersey_number', COALESCE(result->>'jersey_number', ''),
                'career_highlights', COALESCE(result->'career_highlights', '[]'::jsonb),
                'ign', COALESCE(result->>'ign', ''),
                'pro_debut', COALESCE(result->>'pro_debut', ''),
                'retired', COALESCE((result->>'retired')::boolean, false)
            );
        WHEN 'streamer' THEN
            result := result || jsonb_build_object(
                'main_platform', COALESCE(result->>'main_platform', 'twitch'),
                'channel_url', COALESCE(result->>'channel_url', ''),
                'affiliation', COALESCE(result->>'affiliation', ''),
                'content_genres', COALESCE(result->'content_genres', '[]'::jsonb),
                'stream_schedule', COALESCE(result->>'stream_schedule', ''),
                'first_stream_date', COALESCE(result->>'first_stream_date', ''),
                'avg_viewers_bucket', COALESCE(result->>'avg_viewers_bucket', 'small')
            );
        WHEN 'politician' THEN
            result := result || jsonb_build_object(
                'party', COALESCE(result->>'party', ''),
                'current_office', COALESCE(result->>'current_office', ''),
                'constituency', COALESCE(result->>'constituency', ''),
                'term_start', COALESCE(result->>'term_start', ''),
                'term_end', COALESCE(result->>'term_end', ''),
                'previous_offices', COALESCE(result->'previous_offices', '[]'::jsonb),
                'ideology_tags', COALESCE(result->'ideology_tags', '[]'::jsonb)
            );
        WHEN 'business' THEN
            result := result || jsonb_build_object(
                'company_name', COALESCE(result->>'company_name', ''),
                'title', COALESCE(result->>'title', ''),
                'industry', COALESCE(result->>'industry', ''),
                'founded_year', COALESCE(result->>'founded_year', ''),
                'board_memberships', COALESCE(result->'board_memberships', '[]'::jsonb),
                'notable_ventures', COALESCE(result->'notable_ventures', '[]'::jsonb)
            );
        WHEN 'solo_singer' THEN
            result := result || jsonb_build_object(
                'debut_date', COALESCE(result->>'debut_date', ''),
                'label', COALESCE(result->>'label', ''),
                'genres', COALESCE(result->'genres', '[]'::jsonb),
                'fandom_name', COALESCE(result->>'fandom_name', ''),
                'vocal_range', COALESCE(result->>'vocal_range', ''),
                'notable_tracks', COALESCE(result->'notable_tracks', '[]'::jsonb)
            );
        WHEN 'idol_member' THEN
            result := result || jsonb_build_object(
                'group_name', COALESCE(result->>'group_name', ''),
                'position', COALESCE(result->'position', '[]'::jsonb),
                'debut_date', COALESCE(result->>'debut_date', ''),
                'label', COALESCE(result->>'label', ''),
                'fandom_name', COALESCE(result->>'fandom_name', ''),
                'sub_units', COALESCE(result->'sub_units', '[]'::jsonb),
                'solo_activities', COALESCE(result->'solo_activities', '[]'::jsonb)
            );
        WHEN 'actor' THEN
            result := result || jsonb_build_object(
                'acting_debut', COALESCE(result->>'acting_debut', ''),
                'agency', COALESCE(result->>'agency', ''),
                'specialties', COALESCE(result->'specialties', '["film","tv"]'::jsonb),
                'notable_works', COALESCE(result->'notable_works', '[]'::jsonb),
                'awards', COALESCE(result->'awards', '[]'::jsonb)
            );
        WHEN 'athlete' THEN
            result := result || jsonb_build_object(
                'sport', COALESCE(result->>'sport', ''),
                'position_role', COALESCE(result->>'position_role', ''),
                'team', COALESCE(result->>'team', ''),
                'league', COALESCE(result->>'league', ''),
                'dominant_hand_foot', COALESCE(result->>'dominant_hand_foot', 'right'),
                'pro_debut', COALESCE(result->>'pro_debut', ''),
                'career_highlights', COALESCE(result->'career_highlights', '[]'::jsonb),
                'records_personal_bests', COALESCE(result->'records_personal_bests', '[]'::jsonb)
            );
    END CASE;

    RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Insert migrated data from backup
INSERT INTO public.celebrities (
    id,
    name,
    birth_date,
    gender,
    celebrity_type,
    birth_time,
    nationality,
    agency_management,
    external_ids,
    profession_data,
    notes,
    created_at,
    updated_at
)
SELECT
    b.id,
    b.name,
    CASE
        WHEN b.birth_date ~ '^\d{4}-\d{2}-\d{2}$' THEN b.birth_date::DATE
        ELSE '1990-01-01'::DATE  -- fallback for invalid dates
    END as birth_date,
    CASE
        WHEN b.gender = 'mixed' THEN 'other'
        ELSE b.gender
    END as gender,
    determine_celebrity_type(b.category, b.name) as celebrity_type,
    COALESCE(b.birth_time::TIME, '12:00'::TIME) as birth_time,
    COALESCE(b.nationality, '한국') as nationality,
    COALESCE(b.agency, '') as agency_management,
    '{}' as external_ids,  -- Empty for now, can be populated later
    convert_to_profession_data(
        determine_celebrity_type(b.category, b.name),
        b.additional_info,
        b.full_saju_data
    ) as profession_data,
    CASE
        WHEN b.full_saju_data IS NOT NULL AND b.full_saju_data != '' THEN
            '사주 데이터 포함: ' || b.saju_string
        ELSE NULL
    END as notes,
    COALESCE(b.created_at, NOW()) as created_at,
    NOW() as updated_at
FROM public.celebrities_backup b
WHERE b.id IS NOT NULL AND b.name IS NOT NULL;

-- Drop the helper functions after migration
DROP FUNCTION IF EXISTS determine_celebrity_type(TEXT, TEXT);
DROP FUNCTION IF EXISTS convert_to_profession_data(TEXT, JSONB, TEXT);

-- Create migration log entry
INSERT INTO public.migration_log (migration_name, status, message, created_at)
VALUES (
    'migrate_existing_data',
    'completed',
    'Successfully migrated ' || (SELECT COUNT(*) FROM public.celebrities) || ' celebrity records to new schema',
    NOW()
) ON CONFLICT DO NOTHING;