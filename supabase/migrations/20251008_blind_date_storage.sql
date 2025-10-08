-- Create blind_date_photos storage bucket
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'blind_date_photos',
  'blind_date_photos',
  false,  -- Private bucket
  5242880,  -- 5MB max file size
  ARRAY['image/jpeg', 'image/png', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- RLS Policy: Users can upload their own photos
CREATE POLICY IF NOT EXISTS "Users can upload blind date photos"
ON storage.objects FOR INSERT
TO authenticated
WITH CHECK (
  bucket_id = 'blind_date_photos' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- RLS Policy: Users can view their own photos
CREATE POLICY IF NOT EXISTS "Users can view their own blind date photos"
ON storage.objects FOR SELECT
TO authenticated
USING (
  bucket_id = 'blind_date_photos' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- RLS Policy: Users can delete their own photos
CREATE POLICY IF NOT EXISTS "Users can delete their own blind date photos"
ON storage.objects FOR DELETE
TO authenticated
USING (
  bucket_id = 'blind_date_photos' AND
  auth.uid()::text = (storage.foldername(name))[1]
);

-- Extend fortune_history table for blind date analysis
ALTER TABLE fortune_history
ADD COLUMN IF NOT EXISTS analysis_type TEXT,
ADD COLUMN IF NOT EXISTS photo_urls JSONB,
ADD COLUMN IF NOT EXISTS chat_content TEXT,
ADD COLUMN IF NOT EXISTS chat_platform TEXT;

-- Index for faster lookups
CREATE INDEX IF NOT EXISTS idx_fortune_history_analysis_type
ON fortune_history(analysis_type);

COMMENT ON COLUMN fortune_history.analysis_type IS 'Type of blind date analysis: basic, photos, chat, comprehensive';
COMMENT ON COLUMN fortune_history.photo_urls IS 'URLs of uploaded photos for analysis';
COMMENT ON COLUMN fortune_history.chat_content IS 'Chat conversation content (encrypted)';
COMMENT ON COLUMN fortune_history.chat_platform IS 'Platform where chat occurred: kakao, sms, instagram, other';
