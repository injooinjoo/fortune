-- Create storage buckets and policies for KAN-76 (스토리지 버킷 권한 문제 해결)
-- This migration creates the required storage buckets and RLS policies

-- Create profile-images bucket if it doesn't exist
DO $$
BEGIN
    -- Check if bucket already exists
    IF NOT EXISTS (
        SELECT 1 FROM storage.buckets
        WHERE id = 'profile-images'
    ) THEN
        -- Create the bucket
        INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
        VALUES (
            'profile-images',
            'profile-images',
            true,
            5242880, -- 5MB limit
            ARRAY['image/jpeg', 'image/jpg', 'image/png', 'image/webp']
        );
    END IF;
END $$;

-- Enable RLS on storage.objects table (should be enabled by default, but ensuring it)
ALTER TABLE storage.objects ENABLE ROW LEVEL SECURITY;

-- Create policy for users to view their own profile images
DROP POLICY IF EXISTS "Users can view own profile images" ON storage.objects;
CREATE POLICY "Users can view own profile images" ON storage.objects
    FOR SELECT
    USING (
        bucket_id = 'profile-images'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- Create policy for users to upload their own profile images
DROP POLICY IF EXISTS "Users can upload own profile images" ON storage.objects;
CREATE POLICY "Users can upload own profile images" ON storage.objects
    FOR INSERT
    WITH CHECK (
        bucket_id = 'profile-images'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- Create policy for users to update their own profile images
DROP POLICY IF EXISTS "Users can update own profile images" ON storage.objects;
CREATE POLICY "Users can update own profile images" ON storage.objects
    FOR UPDATE
    USING (
        bucket_id = 'profile-images'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- Create policy for users to delete their own profile images
DROP POLICY IF EXISTS "Users can delete own profile images" ON storage.objects;
CREATE POLICY "Users can delete own profile images" ON storage.objects
    FOR DELETE
    USING (
        bucket_id = 'profile-images'
        AND auth.uid()::text = (storage.foldername(name))[1]
    );

-- Create policy for public access to profile images (since bucket is public)
DROP POLICY IF EXISTS "Public access to profile images" ON storage.objects;
CREATE POLICY "Public access to profile images" ON storage.objects
    FOR SELECT
    USING (bucket_id = 'profile-images');

-- Grant necessary permissions to authenticated users
GRANT SELECT ON storage.buckets TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON storage.objects TO authenticated;

-- Create a function to validate file uploads
CREATE OR REPLACE FUNCTION validate_profile_image_upload()
RETURNS TRIGGER AS $$
BEGIN
    -- Check file size (5MB limit)
    IF NEW.metadata->>'size' IS NOT NULL AND (NEW.metadata->>'size')::bigint > 5242880 THEN
        RAISE EXCEPTION 'File size exceeds 5MB limit';
    END IF;

    -- Check file type
    IF NEW.metadata->>'mimetype' IS NOT NULL AND
       NEW.metadata->>'mimetype' NOT IN ('image/jpeg', 'image/jpg', 'image/png', 'image/webp') THEN
        RAISE EXCEPTION 'Invalid file type. Only JPEG, PNG, and WebP images are allowed';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for file validation
DROP TRIGGER IF EXISTS validate_profile_image_trigger ON storage.objects;
CREATE TRIGGER validate_profile_image_trigger
    BEFORE INSERT OR UPDATE ON storage.objects
    FOR EACH ROW
    WHEN (NEW.bucket_id = 'profile-images')
    EXECUTE FUNCTION validate_profile_image_upload();

-- Add helpful comments
COMMENT ON POLICY "Users can view own profile images" ON storage.objects IS
'Allows authenticated users to view their own profile images';

COMMENT ON POLICY "Users can upload own profile images" ON storage.objects IS
'Allows authenticated users to upload profile images to their own folder';

COMMENT ON POLICY "Users can update own profile images" ON storage.objects IS
'Allows authenticated users to update their own profile images';

COMMENT ON POLICY "Users can delete own profile images" ON storage.objects IS
'Allows authenticated users to delete their own profile images';

COMMENT ON POLICY "Public access to profile images" ON storage.objects IS
'Allows public access to profile images since the bucket is public';