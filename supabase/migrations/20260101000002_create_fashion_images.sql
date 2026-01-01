-- =====================================================
-- Fashion Images Table for NanoBanana Generated Images
-- =====================================================
-- 패션 이미지 생성 기록 저장
-- Cost: 35 souls per image
-- =====================================================

-- 1. Create fashion_images table
CREATE TABLE IF NOT EXISTS fashion_images (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  style_type VARCHAR(50) NOT NULL,
  gender VARCHAR(10) NOT NULL CHECK (gender IN ('male', 'female')),
  image_url TEXT NOT NULL,
  prompt_used TEXT,
  outfit_data JSONB NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_fashion_images_user
  ON fashion_images(user_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_fashion_images_style
  ON fashion_images(style_type);

-- 3. Enable RLS
ALTER TABLE fashion_images ENABLE ROW LEVEL SECURITY;

-- 4. RLS Policies
-- Users can view their own images
CREATE POLICY "Users can view own fashion images"
  ON fashion_images
  FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own images
CREATE POLICY "Users can insert own fashion images"
  ON fashion_images
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Service role can do everything (for Edge Functions)
CREATE POLICY "Service role has full access to fashion images"
  ON fashion_images
  FOR ALL
  USING (auth.role() = 'service_role');

-- 5. Create Storage bucket for fashion images
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'fashion-images',
  'fashion-images',
  true,
  5242880, -- 5MB limit
  ARRAY['image/png', 'image/jpeg', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- 6. Storage bucket policies
-- Anyone can view fashion images (public bucket)
CREATE POLICY "Public can view fashion images"
  ON storage.objects
  FOR SELECT
  USING (bucket_id = 'fashion-images');

-- Service role can upload fashion images
CREATE POLICY "Service role can upload fashion images"
  ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'fashion-images'
    AND auth.role() = 'service_role'
  );

-- Service role can delete fashion images
CREATE POLICY "Service role can delete fashion images"
  ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'fashion-images'
    AND auth.role() = 'service_role'
  );

-- 7. Add comment for documentation
COMMENT ON TABLE fashion_images IS 'NanoBanana generated fashion outfit images. Cost: 35 souls per image.';
COMMENT ON COLUMN fashion_images.style_type IS 'Fashion style: hip, neat, sexy, intellectual, natural, romantic, sporty';
COMMENT ON COLUMN fashion_images.outfit_data IS 'JSONB containing top, bottom, shoes, outer, accessories details';
