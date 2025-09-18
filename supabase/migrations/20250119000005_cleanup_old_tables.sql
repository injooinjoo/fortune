-- Cleanup old celebrity-related tables and data after migration
-- Created: 2025-01-19

-- Drop old celebrity-related tables that are no longer needed
-- Note: Keep celebrities_backup for safety, but drop other legacy tables

-- Drop old celebrity master list table if exists
DROP TABLE IF EXISTS public.celebrity_master_list CASCADE;

-- Drop old celebrity saju tables if they exist (data already migrated to notes/profession_data)
DROP TABLE IF EXISTS public.celebrity_saju CASCADE;

-- Drop any old celebrity metadata tables
DROP TABLE IF EXISTS public.celebrity_metadata CASCADE;

-- Clean up old indexes that may conflict (these were recreated with new structure)
DROP INDEX IF EXISTS public.idx_celebrities_category;
DROP INDEX IF EXISTS public.idx_celebrities_name_en;
DROP INDEX IF EXISTS public.idx_celebrities_popularity;
DROP INDEX IF EXISTS public.idx_celebrities_is_active;
DROP INDEX IF EXISTS public.idx_celebrities_keywords;
DROP INDEX IF EXISTS public.idx_celebrities_name_search;

-- Drop old functions that are no longer compatible
DROP FUNCTION IF EXISTS public.get_celebrities_by_category(TEXT);
DROP FUNCTION IF EXISTS public.get_popular_celebrities(INTEGER);
DROP FUNCTION IF EXISTS public.get_random_celebrities(INTEGER, TEXT);

-- Update any existing policies to ensure they work with new schema
DROP POLICY IF EXISTS "Authenticated users can insert celebrities" ON public.celebrities;
DROP POLICY IF EXISTS "Authenticated users can update celebrities" ON public.celebrities;

-- Recreate policies with updated logic
CREATE POLICY "Authenticated users can insert celebrities" ON public.celebrities
    FOR INSERT WITH CHECK (auth.role() = 'authenticated' OR auth.jwt() ->> 'role' = 'service_role');

CREATE POLICY "Authenticated users can update celebrities" ON public.celebrities
    FOR UPDATE USING (auth.role() = 'authenticated' OR auth.jwt() ->> 'role' = 'service_role');

-- Add new policy for delete operations (admin only)
CREATE POLICY "Service role can delete celebrities" ON public.celebrities
    FOR DELETE USING (auth.jwt() ->> 'role' = 'service_role');

-- Clean up any orphaned data or inconsistencies
-- Update any null values to appropriate defaults
UPDATE public.celebrities
SET
    aliases = '{}' WHERE aliases IS NULL,
    languages = '{"한국어"}' WHERE languages IS NULL OR languages = '{}',
    external_ids = '{}' WHERE external_ids IS NULL,
    profession_data = '{}' WHERE profession_data IS NULL;

-- Ensure all required fields have valid values
UPDATE public.celebrities
SET nationality = '한국' WHERE nationality IS NULL OR nationality = '';

UPDATE public.celebrities
SET birth_time = '12:00' WHERE birth_time IS NULL;

-- Add constraints to ensure data integrity
ALTER TABLE public.celebrities
ADD CONSTRAINT check_non_empty_name CHECK (length(trim(name)) > 0);

ALTER TABLE public.celebrities
ADD CONSTRAINT check_valid_birth_date CHECK (birth_date > '1900-01-01' AND birth_date <= CURRENT_DATE);

ALTER TABLE public.celebrities
ADD CONSTRAINT check_valid_birth_time CHECK (birth_time >= '00:00' AND birth_time <= '23:59');

-- Create a summary view for analytics
CREATE OR REPLACE VIEW celebrity_analytics AS
SELECT
    celebrity_type,
    COUNT(*) as total_count,
    COUNT(DISTINCT nationality) as unique_nationalities,
    ROUND(AVG(EXTRACT(YEAR FROM birth_date)), 1) as avg_birth_year,
    MIN(birth_date) as oldest_birth_date,
    MAX(birth_date) as youngest_birth_date,
    COUNT(*) FILTER (WHERE gender = 'male') as male_count,
    COUNT(*) FILTER (WHERE gender = 'female') as female_count,
    COUNT(*) FILTER (WHERE gender = 'other') as other_count,
    COUNT(*) FILTER (WHERE external_ids != '{}') as with_external_links,
    COUNT(*) FILTER (WHERE agency_management IS NOT NULL AND agency_management != '') as with_agency
FROM public.celebrities
GROUP BY celebrity_type
ORDER BY total_count DESC;

-- Grant appropriate permissions for the view
GRANT SELECT ON public.celebrity_analytics TO anon, authenticated;

-- Add comments for the new view
COMMENT ON VIEW public.celebrity_analytics IS '유명인 데이터의 통계 정보를 제공하는 뷰';

-- Create a function to validate profession data structure
CREATE OR REPLACE FUNCTION validate_profession_data(
    cel_type TEXT,
    prof_data JSONB
)
RETURNS BOOLEAN AS $$
BEGIN
    CASE cel_type
        WHEN 'pro_gamer' THEN
            RETURN prof_data ? 'game_title' AND prof_data ? 'team';
        WHEN 'streamer' THEN
            RETURN prof_data ? 'main_platform';
        WHEN 'politician' THEN
            RETURN prof_data ? 'party';
        WHEN 'business' THEN
            RETURN prof_data ? 'company_name';
        WHEN 'idol_member' THEN
            RETURN prof_data ? 'group_name';
        WHEN 'solo_singer' THEN
            RETURN prof_data ? 'debut_date';
        WHEN 'actor' THEN
            RETURN prof_data ? 'specialties';
        WHEN 'athlete' THEN
            RETURN prof_data ? 'sport';
        ELSE
            RETURN TRUE; -- Allow any structure for unknown types
    END CASE;
END;
$$ LANGUAGE plpgsql;

-- Log completion of cleanup
INSERT INTO public.migration_log (migration_name, status, message, created_at)
VALUES (
    'cleanup_old_tables',
    'completed',
    'Successfully cleaned up old celebrity tables and optimized new schema',
    NOW()
) ON CONFLICT DO NOTHING;

-- Final verification query (commented out for actual migration)
-- SELECT 'Migration Complete' as status, COUNT(*) as total_celebrities FROM public.celebrities;