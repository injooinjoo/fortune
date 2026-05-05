-- ============================================================================
-- Character Avatars Storage
--
-- 푸시 알림 richContent.image 에 사용할 캐릭터 아바타 공개 호스팅.
-- 앱 번들 안의 webp 와 동일 파일을 동일 파일명(<characterId>.webp)으로
-- 이 버킷에 업로드한다. Edge Function (notification_push.ts) 이 characterId
-- 를 그대로 URL path 에 박아 쓰므로 파일명을 유지하는 것이 critical.
--
-- 업로드는 scripts/upload-character-avatars.ts 가 service role key 로 일괄
-- 처리. 이 마이그레이션은 버킷과 RLS 만 셋업.
-- ============================================================================

DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM storage.buckets WHERE id = 'character-avatars'
    ) THEN
        INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
        VALUES (
            'character-avatars',
            'character-avatars',
            true, -- 공개: 푸시 NSE 가 익명으로 다운로드해야 함
            2097152, -- 2MB
            ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
        );
    END IF;
END $$;

DROP POLICY IF EXISTS "Public can view character avatars" ON storage.objects;
CREATE POLICY "Public can view character avatars" ON storage.objects
    FOR SELECT
    USING (bucket_id = 'character-avatars');
