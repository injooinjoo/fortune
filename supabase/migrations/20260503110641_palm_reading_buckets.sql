-- 손금가이드 (palm-reading) Storage 버킷 + RLS 정책
-- - palm-reading-images: 사용자가 만든 결과 이미지 저장. user_id 폴더 격리.
-- - palm-reading-assets: 정적 reference (template/example) 보관. service role 만 INSERT.
-- 둘 다 public read (이미지 URL 직접 노출).
-- 마이그레이션은 idempotent: bucket 존재 시 INSERT 생략, 정책은 DROP IF EXISTS 후 CREATE.

-- =====================================================
-- 1. Buckets (idempotent INSERT)
-- =====================================================
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'palm-reading-images') THEN
        INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
        VALUES (
            'palm-reading-images',
            'palm-reading-images',
            true,
            10485760, -- 10MB (gpt-image-2 출력 portrait PNG 여유)
            ARRAY['image/png', 'image/jpeg']
        );
    END IF;

    IF NOT EXISTS (SELECT 1 FROM storage.buckets WHERE id = 'palm-reading-assets') THEN
        INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
        VALUES (
            'palm-reading-assets',
            'palm-reading-assets',
            true,
            10485760,
            ARRAY['image/png', 'image/jpeg']
        );
    END IF;
END $$;

-- (RLS 는 storage.objects 에 기본 활성화되어 있음. ALTER 시 권한 에러 발생하므로 생략)

-- =====================================================
-- 2. palm-reading-images 정책
--    - SELECT: public (bucket public=true 와 별개로 정책 명시)
--    - INSERT/UPDATE/DELETE: 인증 사용자가 자기 user_id 폴더에서만
-- =====================================================
DROP POLICY IF EXISTS "palm_reading_images_public_read" ON storage.objects;
CREATE POLICY "palm_reading_images_public_read" ON storage.objects
    FOR SELECT
    USING (bucket_id = 'palm-reading-images');

DROP POLICY IF EXISTS "palm_reading_images_user_insert" ON storage.objects;
CREATE POLICY "palm_reading_images_user_insert" ON storage.objects
    FOR INSERT
    TO authenticated
    WITH CHECK (
        bucket_id = 'palm-reading-images'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

DROP POLICY IF EXISTS "palm_reading_images_user_update" ON storage.objects;
CREATE POLICY "palm_reading_images_user_update" ON storage.objects
    FOR UPDATE
    TO authenticated
    USING (
        bucket_id = 'palm-reading-images'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

DROP POLICY IF EXISTS "palm_reading_images_user_delete" ON storage.objects;
CREATE POLICY "palm_reading_images_user_delete" ON storage.objects
    FOR DELETE
    TO authenticated
    USING (
        bucket_id = 'palm-reading-images'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- =====================================================
-- 3. palm-reading-assets 정책
--    - SELECT: public (template/example 누구나 읽기)
--    - INSERT/UPDATE/DELETE: 정책 만들지 않음 → service role 만 통과 (관리자 업로드)
-- =====================================================
DROP POLICY IF EXISTS "palm_reading_assets_public_read" ON storage.objects;
CREATE POLICY "palm_reading_assets_public_read" ON storage.objects
    FOR SELECT
    USING (bucket_id = 'palm-reading-assets');

-- 주석:
-- palm-reading-assets 의 INSERT/UPDATE/DELETE 는 정책 없음 → 일반 인증 사용자 차단.
-- service_role 키는 RLS 우회하므로 관리자(개발자)가 Supabase Studio / CLI 로 업로드 가능.
COMMENT ON POLICY "palm_reading_images_user_insert" ON storage.objects IS
'인증 사용자는 palm-reading-images/{user_id}/... 경로에만 INSERT 가능';

COMMENT ON POLICY "palm_reading_assets_public_read" ON storage.objects IS
'palm-reading-assets 의 정적 template/example PNG 는 누구나 읽기 가능';
