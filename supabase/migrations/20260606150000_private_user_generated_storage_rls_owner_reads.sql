-- Follow-up privacy hardening for user-generated storage buckets.
-- The bucket public flag alone does not revoke existing storage.objects SELECT
-- policies, so remove legacy public-read policies and add owner-scoped reads for
-- buckets whose object paths start with the Supabase user id.

UPDATE storage.buckets
   SET public = false
 WHERE id IN (
   'profile-images',
   'palm-reading-images',
   'poster-guide-images',
   'past-life-portraits',
   'talisman-images',
   'yearly-encounter-images',
   'friend-avatars',
   'character-audio-messages'
 );

DROP POLICY IF EXISTS "Public access to profile images" ON storage.objects;
DROP POLICY IF EXISTS "palm_reading_images_public_read" ON storage.objects;
DROP POLICY IF EXISTS "poster_guide_images_public_read" ON storage.objects;
DROP POLICY IF EXISTS "Anyone can view talisman images" ON storage.objects;
DROP POLICY IF EXISTS "Public can view friend avatars" ON storage.objects;

DROP POLICY IF EXISTS "Users can view own palm reading images" ON storage.objects;
CREATE POLICY "Users can view own palm reading images"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'palm-reading-images'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

DROP POLICY IF EXISTS "Users can view own poster guide images" ON storage.objects;
CREATE POLICY "Users can view own poster guide images"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'poster-guide-images'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

DROP POLICY IF EXISTS "Users can view own past life portraits" ON storage.objects;
CREATE POLICY "Users can view own past life portraits"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'past-life-portraits'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

DROP POLICY IF EXISTS "Users can view own yearly encounter images" ON storage.objects;
CREATE POLICY "Users can view own yearly encounter images"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'yearly-encounter-images'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

DROP POLICY IF EXISTS "Users can view own generated talisman images" ON storage.objects;
CREATE POLICY "Users can view own generated talisman images"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'talisman-images'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );

-- New friend-avatar uploads use <userId>/custom/... so RLS and delete-account
-- cleanup can be owner-scoped. Legacy custom/<name>/... paths are intentionally
-- not public-readable after this migration.
DROP POLICY IF EXISTS "Users can view own friend avatars" ON storage.objects;
CREATE POLICY "Users can view own friend avatars"
  ON storage.objects FOR SELECT
  TO authenticated
  USING (
    bucket_id = 'friend-avatars'
    AND auth.uid()::text = (storage.foldername(name))[1]
  );
