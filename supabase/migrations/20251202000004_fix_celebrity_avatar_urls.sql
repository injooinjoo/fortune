-- ============================================================================
-- Fix Celebrity Avatar URLs
-- celebrity_type → avatar filename 매핑 수정
-- ============================================================================

-- 매핑 규칙:
-- idol_member, solo_singer → singer
-- pro_gamer → progamer
-- streamer → youtuber
-- actor, athlete, business, politician → 그대로
-- gender='other' → male

UPDATE public.celebrities
SET character_image_url =
    'https://hayjukwfcsdmppairazc.supabase.co/storage/v1/object/public/celebrities/avatars/' ||
    CASE celebrity_type
        WHEN 'idol_member' THEN 'singer'
        WHEN 'solo_singer' THEN 'singer'
        WHEN 'pro_gamer' THEN 'progamer'
        WHEN 'streamer' THEN 'youtuber'
        ELSE celebrity_type
    END ||
    '_' ||
    CASE WHEN gender = 'other' THEN 'male' ELSE gender END ||
    '.png'
WHERE celebrity_type IS NOT NULL
  AND gender IS NOT NULL;

-- 업데이트 결과 확인용 (주석)
-- SELECT
--     celebrity_type,
--     gender,
--     COUNT(*) as cnt,
--     character_image_url
-- FROM public.celebrities
-- WHERE character_image_url IS NOT NULL
-- GROUP BY celebrity_type, gender, character_image_url
-- ORDER BY celebrity_type, gender;
