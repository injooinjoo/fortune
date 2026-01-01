-- Create talent-resumes storage bucket for resume PDF uploads
-- Used by talent fortune feature for personalized analysis

-- Create the bucket (private, not public)
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'talent-resumes',
  'talent-resumes',
  false,
  5242880,  -- 5MB limit
  ARRAY['application/pdf']::text[]
)
ON CONFLICT (id) DO NOTHING;

-- RLS Policies for talent-resumes bucket

-- Users can upload their own resume
CREATE POLICY "Users can upload their own resume"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'talent-resumes'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Users can view their own resume
CREATE POLICY "Users can view their own resume"
ON storage.objects FOR SELECT
USING (
  bucket_id = 'talent-resumes'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Users can update their own resume
CREATE POLICY "Users can update their own resume"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'talent-resumes'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Users can delete their own resume
CREATE POLICY "Users can delete their own resume"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'talent-resumes'
  AND auth.uid()::text = (storage.foldername(name))[1]
);

-- Create index for faster lookups by user
CREATE INDEX IF NOT EXISTS idx_talent_resumes_user
ON storage.objects (bucket_id, (storage.foldername(name))[1])
WHERE bucket_id = 'talent-resumes';

COMMENT ON POLICY "Users can upload their own resume" ON storage.objects IS
'Allow users to upload PDF resumes to their own folder in talent-resumes bucket';
