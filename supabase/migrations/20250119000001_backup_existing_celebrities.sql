-- Backup existing celebrities data before schema migration
-- Created: 2025-01-19

-- Create backup table with existing structure
CREATE TABLE IF NOT EXISTS public.celebrities_backup AS
SELECT * FROM public.celebrities;

-- Add comment to backup table
COMMENT ON TABLE public.celebrities_backup IS 'Backup of celebrities data before schema migration to new structure';

-- Create index for easier lookup during migration
CREATE INDEX IF NOT EXISTS idx_celebrities_backup_id ON public.celebrities_backup(id);
CREATE INDEX IF NOT EXISTS idx_celebrities_backup_category ON public.celebrities_backup(category);

-- Log backup completion
INSERT INTO public.migration_log (migration_name, status, message, created_at)
VALUES (
  'backup_existing_celebrities',
  'completed',
  'Successfully backed up ' || (SELECT COUNT(*) FROM public.celebrities_backup) || ' celebrity records',
  NOW()
) ON CONFLICT DO NOTHING;