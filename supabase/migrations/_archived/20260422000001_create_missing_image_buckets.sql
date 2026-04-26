-- =====================================================
-- 누락된 이미지 생성 버킷 생성/복원
-- =====================================================
-- generate-friend-avatar / generate-character-proactive-image / OOTD-fashion
-- 세 Edge Function 이 호출하는 storage 버킷이 실제로 존재하지 않아 업로드 단계에서
-- "Bucket not found" 로 실패하던 것을 한 번에 생성한다.
--
-- character-proactive-images / fashion-images 는 과거 migration 기록은 있지만
-- 실제 storage.buckets 에는 없는 상태였음 (수동 삭제 또는 INSERT 누락 추정).
-- INSERT ... ON CONFLICT 로 idempotent.
-- =====================================================

-- 1) friend-avatars — generate-friend-avatar 가 'custom/{name}/{ts}.png' 로 업로드
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'friend-avatars',
  'friend-avatars',
  true,
  5242880, -- 5MB
  ARRAY['image/png', 'image/jpeg', 'image/webp']
)
ON CONFLICT (id) DO UPDATE
SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS "Public can view friend avatars" ON storage.objects;
CREATE POLICY "Public can view friend avatars"
  ON storage.objects
  FOR SELECT
  USING (bucket_id = 'friend-avatars');

DROP POLICY IF EXISTS "Service role can upload friend avatars" ON storage.objects;
CREATE POLICY "Service role can upload friend avatars"
  ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'friend-avatars'
    AND auth.role() = 'service_role'
  );

DROP POLICY IF EXISTS "Service role can delete friend avatars" ON storage.objects;
CREATE POLICY "Service role can delete friend avatars"
  ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'friend-avatars'
    AND auth.role() = 'service_role'
  );

-- 2) character-proactive-images — generate-character-proactive-image 용 (10MB 허용)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'character-proactive-images',
  'character-proactive-images',
  true,
  10485760, -- 10MB
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

-- 3) fashion-images — OOTD/패션 결과 이미지
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'fashion-images',
  'fashion-images',
  true,
  5242880, -- 5MB
  ARRAY['image/png', 'image/jpeg', 'image/webp']
)
ON CONFLICT (id) DO UPDATE
SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS "Public can view fashion images" ON storage.objects;
CREATE POLICY "Public can view fashion images"
  ON storage.objects
  FOR SELECT
  USING (bucket_id = 'fashion-images');

DROP POLICY IF EXISTS "Service role can upload fashion images" ON storage.objects;
CREATE POLICY "Service role can upload fashion images"
  ON storage.objects
  FOR INSERT
  WITH CHECK (
    bucket_id = 'fashion-images'
    AND auth.role() = 'service_role'
  );

DROP POLICY IF EXISTS "Service role can delete fashion images" ON storage.objects;
CREATE POLICY "Service role can delete fashion images"
  ON storage.objects
  FOR DELETE
  USING (
    bucket_id = 'fashion-images'
    AND auth.role() = 'service_role'
  );
