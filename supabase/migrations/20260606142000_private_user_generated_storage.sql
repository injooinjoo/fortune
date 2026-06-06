-- P0 privacy: user-generated/result image buckets should not be public.
-- Static template/product buckets stay public intentionally.

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
