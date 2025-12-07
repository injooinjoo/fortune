-- ============================================================================
-- Enable RLS on fortune_cache table
-- 정책은 이미 존재하지만 RLS가 비활성화되어 있음
-- ============================================================================

-- fortune_cache 테이블에 RLS 활성화
ALTER TABLE public.fortune_cache ENABLE ROW LEVEL SECURITY;

-- 확인용 (주석)
-- SELECT tablename, rowsecurity FROM pg_tables WHERE tablename = 'fortune_cache';
