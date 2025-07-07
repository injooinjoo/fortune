-- fortune_batches 테이블에 analysis_results 컬럼 추가
ALTER TABLE fortune_batches 
ADD COLUMN IF NOT EXISTS analysis_results JSONB;

-- 인덱스 추가 (JSONB 검색 성능 향상)
CREATE INDEX IF NOT EXISTS idx_analysis_results ON fortune_batches USING GIN (analysis_results);