-- Create celebrity_master_list table for managing celebrity lists before detailed crawling
CREATE TABLE IF NOT EXISTS public.celebrity_master_list (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    name TEXT NOT NULL,
    name_en TEXT,
    category TEXT NOT NULL,
    subcategory TEXT,
    popularity_rank INTEGER NOT NULL,
    search_volume INTEGER,
    last_active TEXT, -- year or period when they were last active
    is_crawled BOOLEAN DEFAULT false,
    crawl_priority INTEGER DEFAULT 0,
    description TEXT,
    keywords TEXT[], -- array of search keywords
    platform TEXT, -- main platform (YouTube, Twitch, etc.)
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_celebrity_master_list_category ON public.celebrity_master_list(category);
CREATE INDEX IF NOT EXISTS idx_celebrity_master_list_subcategory ON public.celebrity_master_list(subcategory);
CREATE INDEX IF NOT EXISTS idx_celebrity_master_list_popularity_rank ON public.celebrity_master_list(popularity_rank);
CREATE INDEX IF NOT EXISTS idx_celebrity_master_list_is_crawled ON public.celebrity_master_list(is_crawled);
CREATE INDEX IF NOT EXISTS idx_celebrity_master_list_crawl_priority ON public.celebrity_master_list(crawl_priority DESC);
CREATE INDEX IF NOT EXISTS idx_celebrity_master_list_name ON public.celebrity_master_list(name);

-- Create composite index for crawling queries
CREATE INDEX IF NOT EXISTS idx_celebrity_master_list_crawl_queue 
ON public.celebrity_master_list(is_crawled, crawl_priority DESC, category);

-- Enable RLS
ALTER TABLE public.celebrity_master_list ENABLE ROW LEVEL SECURITY;

-- Create RLS policies
CREATE POLICY "Enable read access for all users" ON public.celebrity_master_list
    FOR SELECT USING (true);

CREATE POLICY "Enable insert access for authenticated users" ON public.celebrity_master_list
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Enable update access for authenticated users" ON public.celebrity_master_list
    FOR UPDATE USING (true) WITH CHECK (true);

-- Create trigger to automatically update updated_at
CREATE OR REPLACE FUNCTION update_celebrity_master_list_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_celebrity_master_list_updated_at ON public.celebrity_master_list;
CREATE TRIGGER trigger_update_celebrity_master_list_updated_at
    BEFORE UPDATE ON public.celebrity_master_list
    FOR EACH ROW EXECUTE FUNCTION update_celebrity_master_list_updated_at();

-- Create function to get category statistics
CREATE OR REPLACE FUNCTION get_celebrity_master_list_stats()
RETURNS JSON AS $$
DECLARE
    result JSON;
    total_count INTEGER;
    crawled_count INTEGER;
    category_stats JSON;
BEGIN
    -- Get total count
    SELECT COUNT(*) INTO total_count FROM public.celebrity_master_list;
    
    -- Get crawled count
    SELECT COUNT(*) INTO crawled_count 
    FROM public.celebrity_master_list 
    WHERE is_crawled = true;
    
    -- Get category statistics
    SELECT json_object_agg(category, category_data) INTO category_stats
    FROM (
        SELECT 
            category,
            json_build_object(
                'total', COUNT(*),
                'crawled', COUNT(*) FILTER (WHERE is_crawled = true),
                'avg_priority', ROUND(AVG(crawl_priority), 2)
            ) as category_data
        FROM public.celebrity_master_list
        GROUP BY category
    ) cat_stats;
    
    -- Build result JSON
    SELECT json_build_object(
        'total_celebrities', total_count,
        'crawled_celebrities', crawled_count,
        'crawling_percentage', 
            CASE 
                WHEN total_count > 0 THEN 
                    ROUND((crawled_count::NUMERIC / total_count) * 100, 2)
                ELSE 0 
            END,
        'categories', COALESCE(category_stats, '{}'::json)
    ) INTO result;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to get next celebrities to crawl
CREATE OR REPLACE FUNCTION get_next_celebrities_to_crawl(limit_count INTEGER DEFAULT 10)
RETURNS TABLE (
    id UUID,
    name TEXT,
    category TEXT,
    subcategory TEXT,
    crawl_priority INTEGER
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        cml.id,
        cml.name,
        cml.category,
        cml.subcategory,
        cml.crawl_priority
    FROM public.celebrity_master_list cml
    WHERE cml.is_crawled = false
    ORDER BY cml.crawl_priority DESC, cml.popularity_rank ASC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to mark celebrity as crawled
CREATE OR REPLACE FUNCTION mark_celebrity_as_crawled(celebrity_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
    UPDATE public.celebrity_master_list
    SET 
        is_crawled = true,
        updated_at = NOW()
    WHERE id = celebrity_id;
    
    RETURN FOUND;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to batch insert celebrities
CREATE OR REPLACE FUNCTION insert_celebrity_list_batch(celebrities_data JSONB)
RETURNS INTEGER AS $$
DECLARE
    inserted_count INTEGER := 0;
    celebrity_item JSONB;
BEGIN
    -- Loop through each celebrity in the JSON array
    FOR celebrity_item IN SELECT * FROM jsonb_array_elements(celebrities_data)
    LOOP
        INSERT INTO public.celebrity_master_list (
            name,
            name_en,
            category,
            subcategory,
            popularity_rank,
            search_volume,
            last_active,
            description,
            keywords,
            platform,
            crawl_priority
        ) VALUES (
            celebrity_item->>'name',
            celebrity_item->>'name_en',
            celebrity_item->>'category',
            celebrity_item->>'subcategory',
            (celebrity_item->>'popularity_rank')::INTEGER,
            (celebrity_item->>'search_volume')::INTEGER,
            celebrity_item->>'last_active',
            celebrity_item->>'description',
            CASE 
                WHEN celebrity_item->'keywords' IS NOT NULL THEN
                    ARRAY(SELECT jsonb_array_elements_text(celebrity_item->'keywords'))
                ELSE NULL
            END,
            celebrity_item->>'platform',
            (celebrity_item->>'crawl_priority')::INTEGER
        )
        ON CONFLICT (name, category) DO UPDATE SET
            name_en = EXCLUDED.name_en,
            subcategory = EXCLUDED.subcategory,
            popularity_rank = EXCLUDED.popularity_rank,
            search_volume = EXCLUDED.search_volume,
            last_active = EXCLUDED.last_active,
            description = EXCLUDED.description,
            keywords = EXCLUDED.keywords,
            platform = EXCLUDED.platform,
            crawl_priority = EXCLUDED.crawl_priority,
            updated_at = NOW();
        
        inserted_count := inserted_count + 1;
    END LOOP;
    
    RETURN inserted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add unique constraint to prevent duplicates
ALTER TABLE public.celebrity_master_list 
ADD CONSTRAINT unique_celebrity_name_category 
UNIQUE (name, category);

-- Add comments for documentation
COMMENT ON TABLE public.celebrity_master_list IS 'Master list of celebrities organized by category for systematic crawling';
COMMENT ON COLUMN public.celebrity_master_list.popularity_rank IS 'Rank within category (1-100)';
COMMENT ON COLUMN public.celebrity_master_list.crawl_priority IS 'Calculated priority score for crawling order';
COMMENT ON COLUMN public.celebrity_master_list.is_crawled IS 'Whether detailed information has been crawled';
COMMENT ON COLUMN public.celebrity_master_list.keywords IS 'Search keywords for matching and discovery';
COMMENT ON COLUMN public.celebrity_master_list.platform IS 'Primary platform (YouTube, Twitch, Instagram, etc.)';

COMMENT ON FUNCTION get_celebrity_master_list_stats() IS 'Returns comprehensive statistics about the celebrity master list';
COMMENT ON FUNCTION get_next_celebrities_to_crawl(INTEGER) IS 'Returns next celebrities to crawl ordered by priority';
COMMENT ON FUNCTION mark_celebrity_as_crawled(UUID) IS 'Marks a celebrity as having been crawled';
COMMENT ON FUNCTION insert_celebrity_list_batch(JSONB) IS 'Batch inserts celebrities from JSON array';