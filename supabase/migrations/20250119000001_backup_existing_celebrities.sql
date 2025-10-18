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

-- Log backup completion (migration_log 테이블이 없을 수 있으므로 제거)
-- Backup 완료는 celebrities_backup 테이블 존재로 확인 가능