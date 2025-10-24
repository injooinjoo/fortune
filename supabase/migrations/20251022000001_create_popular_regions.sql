-- popular_regions 테이블 생성
CREATE TABLE IF NOT EXISTS public.popular_regions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  city TEXT NOT NULL,
  district TEXT NOT NULL,
  display_name TEXT NOT NULL,
  usage_count INTEGER DEFAULT 0,
  is_featured BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_popular_regions_usage_count
  ON public.popular_regions(usage_count DESC);

CREATE INDEX IF NOT EXISTS idx_popular_regions_featured
  ON public.popular_regions(is_featured, usage_count DESC);

-- RLS 활성화
ALTER TABLE public.popular_regions ENABLE ROW LEVEL SECURITY;

-- 모든 사용자가 읽기 가능
CREATE POLICY IF NOT EXISTS "Anyone can read popular regions"
  ON public.popular_regions
  FOR SELECT
  USING (true);

-- 서비스 롤만 쓰기 가능
CREATE POLICY IF NOT EXISTS "Service role can insert"
  ON public.popular_regions
  FOR INSERT
  WITH CHECK (auth.role() = 'service_role');

CREATE POLICY IF NOT EXISTS "Service role can update"
  ON public.popular_regions
  FOR UPDATE
  USING (auth.role() = 'service_role');

-- 초기 데이터 삽입 (서울 주요 지역)
INSERT INTO public.popular_regions (city, district, display_name, is_featured, usage_count)
VALUES
  ('서울시', '강남구', '서울시 강남구', true, 100),
  ('서울시', '서초구', '서울시 서초구', true, 95),
  ('서울시', '송파구', '서울시 송파구', true, 90),
  ('서울시', '강서구', '서울시 강서구', false, 85),
  ('서울시', '마포구', '서울시 마포구', false, 80),
  ('서울시', '영등포구', '서울시 영등포구', false, 75),
  ('서울시', '용산구', '서울시 용산구', false, 70),
  ('서울시', '성동구', '서울시 성동구', false, 65),
  ('서울시', '광진구', '서울시 광진구', false, 60),
  ('서울시', '동작구', '서울시 동작구', false, 55)
ON CONFLICT DO NOTHING;
