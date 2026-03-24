-- Curated talisman catalog for low-cost prebuilt mode
CREATE TABLE IF NOT EXISTS public.talisman_catalog_assets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  image_url TEXT NOT NULL,
  title TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT false,
  sort_order INTEGER NOT NULL DEFAULT 0,
  tags TEXT[] NOT NULL DEFAULT '{}',
  note TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_talisman_catalog_assets_active_sort
  ON public.talisman_catalog_assets(is_active, sort_order, created_at DESC);

ALTER TABLE public.talisman_catalog_assets ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Anyone can view active talisman catalog assets"
  ON public.talisman_catalog_assets;

CREATE POLICY "Anyone can view active talisman catalog assets"
  ON public.talisman_catalog_assets FOR SELECT
  USING (is_active = true);

COMMENT ON TABLE public.talisman_catalog_assets IS
  '서버가 관리하는 저가형 부적 카탈로그 자산';
COMMENT ON COLUMN public.talisman_catalog_assets.image_url IS
  'public talisman-images bucket 내 catalog/ prefix 자산 URL';
COMMENT ON COLUMN public.talisman_catalog_assets.tags IS
  '운영용 태그 메타데이터';
