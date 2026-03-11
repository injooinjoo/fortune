DROP POLICY IF EXISTS "Enable read access for all users" ON public.crawling_logs;
DROP POLICY IF EXISTS "Enable insert access for authenticated users" ON public.crawling_logs;

DROP TABLE IF EXISTS public.crawling_logs;

DROP FUNCTION IF EXISTS public.get_crawling_statistics();
DROP FUNCTION IF EXISTS public.cleanup_old_crawling_logs();

DROP TRIGGER IF EXISTS trigger_update_celebrities_last_updated ON public.celebrities;
DROP FUNCTION IF EXISTS public.update_celebrities_last_updated();

DROP INDEX IF EXISTS public.idx_celebrities_crawled_at;
DROP INDEX IF EXISTS public.idx_celebrities_last_updated;

ALTER TABLE public.celebrities
DROP COLUMN IF EXISTS crawled_at,
DROP COLUMN IF EXISTS source_url,
DROP COLUMN IF EXISTS last_updated;
