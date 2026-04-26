-- 러츠 proactive 이미지 저장용 public bucket

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'character-proactive-images',
  'character-proactive-images',
  true,
  10485760,
  ARRAY['image/png', 'image/jpeg', 'image/webp']
)
ON CONFLICT (id) DO UPDATE
SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS "Public can view character proactive images" ON storage.objects;
CREATE POLICY "Public can view character proactive images"
  ON storage.objects
  FOR SELECT
  USING (bucket_id = 'character-proactive-images');

DROP POLICY IF EXISTS "Service role can upload character proactive images" ON storage.objects;
CREATE POLICY "Service role can upload character proactive images"
  ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'character-proactive-images'
    AND auth.role() = 'service_role'
  );

DROP POLICY IF EXISTS "Service role can delete character proactive images" ON storage.objects;
CREATE POLICY "Service role can delete character proactive images"
  ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'character-proactive-images'
    AND auth.role() = 'service_role'
  );
