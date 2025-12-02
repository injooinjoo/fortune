-- ============================================================================
-- Celebrity Avatars Storage Setup
-- Notion 스타일 연예인 아바타 이미지 저장 및 URL 업데이트
-- ============================================================================

-- ============================================================================
-- 1. celebrities 스토리지 버킷 생성
-- ============================================================================

DO $$
BEGIN
    -- 버킷이 없으면 생성
    IF NOT EXISTS (
        SELECT 1 FROM storage.buckets
        WHERE id = 'celebrities'
    ) THEN
        INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
        VALUES (
            'celebrities',
            'celebrities',
            true,  -- 공개 버킷 (누구나 읽기 가능)
            2097152, -- 2MB limit (아바타는 작은 이미지)
            ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
        );
        RAISE NOTICE 'Created celebrities storage bucket';
    END IF;
END $$;

-- ============================================================================
-- 2. 스토리지 정책 설정
-- ============================================================================

-- 모든 사용자가 읽기 가능 (공개 이미지)
DROP POLICY IF EXISTS "Public can view celebrity avatars" ON storage.objects;
CREATE POLICY "Public can view celebrity avatars" ON storage.objects
    FOR SELECT
    USING (bucket_id = 'celebrities');

-- 관리자만 업로드/수정/삭제 가능 (일반적으로 직접 업로드하므로 생략 가능)
-- Supabase Dashboard 또는 API 키로 업로드

-- ============================================================================
-- 3. character_image_url 일괄 업데이트
-- ============================================================================

-- Supabase Storage URL 기본 경로
-- https://hayjukwfcsdmppairazc.supabase.co/storage/v1/object/public/celebrities/avatars/

-- 카테고리 + 성별 기반 아바타 URL 매핑
UPDATE public.celebrities
SET character_image_url =
    'https://hayjukwfcsdmppairazc.supabase.co/storage/v1/object/public/celebrities/avatars/' ||
    category || '_' || gender || '.png'
WHERE character_image_url IS NULL
  AND category IS NOT NULL
  AND gender IS NOT NULL;

-- ============================================================================
-- 4. 확인용 쿼리 (주석 처리)
-- ============================================================================

-- 업데이트 결과 확인
-- SELECT category, gender, COUNT(*) as count,
--        character_image_url
-- FROM public.celebrities
-- WHERE character_image_url IS NOT NULL
-- GROUP BY category, gender, character_image_url
-- ORDER BY category, gender;

-- ============================================================================
-- 5. 코멘트 추가
-- ============================================================================

COMMENT ON COLUMN public.celebrities.character_image_url IS
'Notion 스타일 미니멀 아바타 이미지 URL (성별×카테고리 16종)';
