-- Add crawling metadata columns to celebrities table
ALTER TABLE public.celebrities 
ADD COLUMN IF NOT EXISTS crawled_at TIMESTAMP WITH TIME ZONE,
ADD COLUMN IF NOT EXISTS source_url TEXT,
ADD COLUMN IF NOT EXISTS last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Create index for crawling queries
CREATE INDEX IF NOT EXISTS idx_celebrities_crawled_at ON public.celebrities(crawled_at);
CREATE INDEX IF NOT EXISTS idx_celebrities_last_updated ON public.celebrities(last_updated);

-- Update trigger to automatically set last_updated
CREATE OR REPLACE FUNCTION update_celebrities_last_updated()
RETURNS TRIGGER AS $$
BEGIN
    NEW.last_updated = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trigger_update_celebrities_last_updated ON public.celebrities;
CREATE TRIGGER trigger_update_celebrities_last_updated
    BEFORE UPDATE ON public.celebrities
    FOR EACH ROW EXECUTE FUNCTION update_celebrities_last_updated();

-- Create crawling log table for tracking crawling history
CREATE TABLE IF NOT EXISTS public.crawling_logs (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    celebrity_id UUID REFERENCES public.celebrities(id) ON DELETE CASCADE,
    celebrity_name TEXT NOT NULL,
    status TEXT NOT NULL CHECK (status IN ('success', 'failed', 'skipped')),
    message TEXT,
    crawled_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    processing_time_ms INTEGER,
    source_url TEXT,
    data_updated BOOLEAN DEFAULT false
);

-- Enable RLS on crawling_logs
ALTER TABLE public.crawling_logs ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for crawling_logs
CREATE POLICY "Enable read access for all users" ON public.crawling_logs
    FOR SELECT USING (true);

CREATE POLICY "Enable insert access for authenticated users" ON public.crawling_logs
    FOR INSERT WITH CHECK (true);

-- Create indexes for crawling_logs
CREATE INDEX IF NOT EXISTS idx_crawling_logs_celebrity_id ON public.crawling_logs(celebrity_id);
CREATE INDEX IF NOT EXISTS idx_crawling_logs_status ON public.crawling_logs(status);
CREATE INDEX IF NOT EXISTS idx_crawling_logs_crawled_at ON public.crawling_logs(crawled_at);

-- Create function to get crawling statistics
CREATE OR REPLACE FUNCTION get_crawling_statistics()
RETURNS JSON AS $$
DECLARE
    result JSON;
    total_celebrities INTEGER;
    crawled_celebrities INTEGER;
    last_crawl_time TIMESTAMP;
    success_rate NUMERIC;
BEGIN
    -- Get total celebrities count
    SELECT COUNT(*) INTO total_celebrities FROM public.celebrities;
    
    -- Get crawled celebrities count (those with crawled_at not null)
    SELECT COUNT(*) INTO crawled_celebrities 
    FROM public.celebrities 
    WHERE crawled_at IS NOT NULL;
    
    -- Get last crawl time
    SELECT MAX(crawled_at) INTO last_crawl_time 
    FROM public.celebrities 
    WHERE crawled_at IS NOT NULL;
    
    -- Calculate success rate from logs (last 100 attempts)
    SELECT 
        CASE 
            WHEN COUNT(*) > 0 THEN
                ROUND((COUNT(*) FILTER (WHERE status = 'success')::NUMERIC / COUNT(*)) * 100, 2)
            ELSE 0
        END INTO success_rate
    FROM (
        SELECT status 
        FROM public.crawling_logs 
        ORDER BY crawled_at DESC 
        LIMIT 100
    ) recent_logs;
    
    -- Build result JSON
    SELECT json_build_object(
        'total_celebrities', total_celebrities,
        'crawled_celebrities', crawled_celebrities,
        'crawling_percentage', 
            CASE 
                WHEN total_celebrities > 0 THEN 
                    ROUND((crawled_celebrities::NUMERIC / total_celebrities) * 100, 2)
                ELSE 0 
            END,
        'last_crawl_time', last_crawl_time,
        'recent_success_rate', COALESCE(success_rate, 0)
    ) INTO result;
    
    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to clean old crawling logs (keep last 1000 entries)
CREATE OR REPLACE FUNCTION cleanup_old_crawling_logs()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    WITH logs_to_keep AS (
        SELECT id 
        FROM public.crawling_logs 
        ORDER BY crawled_at DESC 
        LIMIT 1000
    )
    DELETE FROM public.crawling_logs 
    WHERE id NOT IN (SELECT id FROM logs_to_keep);
    
    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Add comments for documentation
COMMENT ON COLUMN public.celebrities.crawled_at IS 'Timestamp when celebrity data was last crawled from external source';
COMMENT ON COLUMN public.celebrities.source_url IS 'URL of the external source where data was crawled from';
COMMENT ON COLUMN public.celebrities.last_updated IS 'Timestamp when celebrity data was last updated';

COMMENT ON TABLE public.crawling_logs IS 'Log table for tracking celebrity data crawling history and results';
COMMENT ON FUNCTION get_crawling_statistics() IS 'Returns JSON with comprehensive crawling statistics';
COMMENT ON FUNCTION cleanup_old_crawling_logs() IS 'Cleans up old crawling logs, keeping only the most recent 1000 entries';