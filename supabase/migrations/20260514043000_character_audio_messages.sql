-- Character chat voice-message assets.
-- Message text/metadata remains in character_conversations; binary audio is kept in
-- private Supabase Storage for 90 days so another device can restore playback.

CREATE TABLE IF NOT EXISTS character_audio_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  character_id TEXT NOT NULL,
  message_id TEXT NOT NULL,
  storage_path TEXT NOT NULL,
  mime_type TEXT NOT NULL DEFAULT 'audio/mp4',
  duration_millis INTEGER,
  size_bytes INTEGER,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL DEFAULT (NOW() + INTERVAL '90 days'),
  deleted_at TIMESTAMPTZ,
  CONSTRAINT character_audio_messages_user_message_unique UNIQUE (user_id, message_id),
  CONSTRAINT character_audio_messages_storage_path_unique UNIQUE (storage_path),
  CONSTRAINT character_audio_messages_storage_path_scope CHECK (
    storage_path LIKE ('users/' || user_id::text || '/characters/%')
  )
);

CREATE INDEX IF NOT EXISTS idx_character_audio_messages_user_character_created
  ON character_audio_messages(user_id, character_id, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_character_audio_messages_expired_active
  ON character_audio_messages(expires_at)
  WHERE deleted_at IS NULL;

ALTER TABLE character_audio_messages ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Users can view own character audio messages" ON character_audio_messages;
CREATE POLICY "Users can view own character audio messages"
  ON character_audio_messages FOR SELECT
  USING (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can insert own character audio messages" ON character_audio_messages;
CREATE POLICY "Users can insert own character audio messages"
  ON character_audio_messages FOR INSERT
  WITH CHECK (auth.uid() = user_id);

DROP POLICY IF EXISTS "Users can update own character audio messages" ON character_audio_messages;
CREATE POLICY "Users can update own character audio messages"
  ON character_audio_messages FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'character-audio-messages',
  'character-audio-messages',
  false,
  10485760,
  ARRAY['audio/mp4', 'audio/m4a', 'audio/aac', 'audio/mpeg', 'audio/wav']
)
ON CONFLICT (id) DO UPDATE SET
  public = EXCLUDED.public,
  file_size_limit = EXCLUDED.file_size_limit,
  allowed_mime_types = EXCLUDED.allowed_mime_types;

DROP POLICY IF EXISTS "Users can upload own character audio" ON storage.objects;
CREATE POLICY "Users can upload own character audio"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'character-audio-messages'
    AND (storage.foldername(name))[1] = 'users'
    AND auth.uid()::text = (storage.foldername(name))[2]
  );

DROP POLICY IF EXISTS "Users can update own character audio" ON storage.objects;
CREATE POLICY "Users can update own character audio"
  ON storage.objects FOR UPDATE
  USING (
    bucket_id = 'character-audio-messages'
    AND (storage.foldername(name))[1] = 'users'
    AND auth.uid()::text = (storage.foldername(name))[2]
  )
  WITH CHECK (
    bucket_id = 'character-audio-messages'
    AND (storage.foldername(name))[1] = 'users'
    AND auth.uid()::text = (storage.foldername(name))[2]
  );

DROP POLICY IF EXISTS "Users can read own character audio" ON storage.objects;
CREATE POLICY "Users can read own character audio"
  ON storage.objects FOR SELECT
  USING (
    bucket_id = 'character-audio-messages'
    AND (storage.foldername(name))[1] = 'users'
    AND auth.uid()::text = (storage.foldername(name))[2]
  );

DROP POLICY IF EXISTS "Users can delete own character audio" ON storage.objects;
CREATE POLICY "Users can delete own character audio"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'character-audio-messages'
    AND (storage.foldername(name))[1] = 'users'
    AND auth.uid()::text = (storage.foldername(name))[2]
  );

CREATE OR REPLACE FUNCTION cleanup_expired_character_audio_messages(p_limit INTEGER DEFAULT 500)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, storage
AS $$
DECLARE
  removed_count INTEGER := 0;
  candidate RECORD;
BEGIN
  FOR candidate IN
    SELECT id, storage_path
      FROM character_audio_messages
     WHERE deleted_at IS NULL
       AND expires_at <= NOW()
     ORDER BY expires_at ASC
     LIMIT p_limit
  LOOP
    DELETE FROM storage.objects
     WHERE bucket_id = 'character-audio-messages'
       AND name = candidate.storage_path;

    UPDATE character_audio_messages
       SET deleted_at = NOW()
     WHERE id = candidate.id
       AND deleted_at IS NULL;

    removed_count := removed_count + 1;
  END LOOP;

  RETURN removed_count;
END;
$$;

CREATE EXTENSION IF NOT EXISTS pg_cron;

DO $$
BEGIN
  PERFORM cron.unschedule('cleanup-expired-character-audio-daily');
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END $$;

SELECT cron.schedule(
  'cleanup-expired-character-audio-daily',
  '17 19 * * *', -- 04:17 KST daily
  $$ SELECT public.cleanup_expired_character_audio_messages(1000); $$
);

COMMENT ON TABLE character_audio_messages IS 'Character chat voice message storage metadata; binary files are retained for 90 days in private Storage.';
COMMENT ON FUNCTION cleanup_expired_character_audio_messages(INTEGER) IS 'Deletes expired character voice-message objects and marks their metadata deleted.';
