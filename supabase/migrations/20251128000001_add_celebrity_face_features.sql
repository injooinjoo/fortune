-- Add face features and character image for physiognomy matching
-- Created: 2025-11-28
-- Purpose: 관상 운세에서 연예인 유사도 매칭을 위한 컬럼 추가

-- Add face_features JSONB column for physiognomy analysis data
ALTER TABLE public.celebrities
ADD COLUMN IF NOT EXISTS face_features JSONB DEFAULT NULL;

-- Add character_image_url for Notion-style avatar (copyright-free)
ALTER TABLE public.celebrities
ADD COLUMN IF NOT EXISTS character_image_url TEXT DEFAULT NULL;

-- Create GIN index for efficient JSONB queries
CREATE INDEX IF NOT EXISTS idx_celebrities_face_features
ON public.celebrities USING GIN(face_features);

-- Create index for face_shape quick lookup
CREATE INDEX IF NOT EXISTS idx_celebrities_face_shape
ON public.celebrities ((face_features->>'face_shape'));

-- Create composite index for gender + face_shape combo queries
CREATE INDEX IF NOT EXISTS idx_celebrities_gender_face_shape
ON public.celebrities (gender, (face_features->>'face_shape'));

-- Add column comments
COMMENT ON COLUMN public.celebrities.face_features IS '관상 특징 데이터 (face_shape, eyes, eyebrows, nose, mouth, jawline, overall_impression)';
COMMENT ON COLUMN public.celebrities.character_image_url IS '노션 스타일 캐릭터 이미지 URL (Supabase Storage)';

-- Create function to find similar celebrities based on face features
CREATE OR REPLACE FUNCTION find_similar_celebrities(
    user_features JSONB,
    user_gender TEXT DEFAULT NULL,
    min_score INTEGER DEFAULT 50,
    limit_count INTEGER DEFAULT 3
)
RETURNS TABLE (
    celebrity_id TEXT,
    celebrity_name TEXT,
    celebrity_type TEXT,
    character_image_url TEXT,
    similarity_score INTEGER,
    matched_features TEXT[]
) AS $$
DECLARE
    score INTEGER;
    matched TEXT[];
BEGIN
    RETURN QUERY
    WITH scored_celebrities AS (
        SELECT
            c.id,
            c.name,
            c.celebrity_type AS c_type,
            c.character_image_url AS img_url,
            c.face_features,
            -- Face shape matching (25 points)
            CASE
                WHEN c.face_features->>'face_shape' = user_features->>'face_shape' THEN 25
                WHEN c.face_features->>'face_shape' IN (
                    SELECT value FROM jsonb_array_elements_text(
                        CASE user_features->>'face_shape'
                            WHEN 'oval' THEN '["oblong", "heart"]'::jsonb
                            WHEN 'round' THEN '["square", "diamond"]'::jsonb
                            WHEN 'square' THEN '["round", "diamond"]'::jsonb
                            WHEN 'oblong' THEN '["oval", "heart"]'::jsonb
                            WHEN 'heart' THEN '["oval", "diamond"]'::jsonb
                            WHEN 'diamond' THEN '["heart", "square"]'::jsonb
                            ELSE '[]'::jsonb
                        END
                    )
                ) THEN 15
                ELSE 5
            END AS face_shape_score,
            -- Eye similarity (20 points)
            CASE
                WHEN c.face_features->'eyes'->>'shape' = user_features->'eyes'->>'shape'
                    AND c.face_features->'eyes'->>'size' = user_features->'eyes'->>'size' THEN 20
                WHEN c.face_features->'eyes'->>'shape' = user_features->'eyes'->>'shape' THEN 15
                WHEN c.face_features->'eyes'->>'size' = user_features->'eyes'->>'size' THEN 10
                ELSE 5
            END AS eye_score,
            -- Nose similarity (15 points)
            CASE
                WHEN c.face_features->'nose'->>'bridge' = user_features->'nose'->>'bridge'
                    AND c.face_features->'nose'->>'tip' = user_features->'nose'->>'tip' THEN 15
                WHEN c.face_features->'nose'->>'bridge' = user_features->'nose'->>'bridge' THEN 10
                ELSE 5
            END AS nose_score,
            -- Mouth similarity (10 points)
            CASE
                WHEN c.face_features->'mouth'->>'size' = user_features->'mouth'->>'size'
                    AND c.face_features->'mouth'->>'lips' = user_features->'mouth'->>'lips' THEN 10
                WHEN c.face_features->'mouth'->>'size' = user_features->'mouth'->>'size' THEN 7
                ELSE 3
            END AS mouth_score,
            -- Jawline similarity (15 points)
            CASE
                WHEN c.face_features->'jawline'->>'shape' = user_features->'jawline'->>'shape' THEN 15
                ELSE 5
            END AS jawline_score,
            -- Overall impression overlap (15 points max, 5 per match)
            LEAST(15, (
                SELECT COUNT(*) * 5
                FROM jsonb_array_elements_text(COALESCE(c.face_features->'overall_impression', '[]'::jsonb)) AS ci
                WHERE ci.value = ANY(
                    ARRAY(SELECT jsonb_array_elements_text(COALESCE(user_features->'overall_impression', '[]'::jsonb)))
                )
            )::INTEGER) AS impression_score
        FROM celebrities c
        WHERE
            c.face_features IS NOT NULL
            AND (user_gender IS NULL OR c.gender = user_gender)
    )
    SELECT
        sc.id,
        sc.name,
        sc.c_type,
        sc.img_url,
        (sc.face_shape_score + sc.eye_score + sc.nose_score + sc.mouth_score + sc.jawline_score + sc.impression_score)::INTEGER AS total_score,
        ARRAY_REMOVE(ARRAY[
            CASE WHEN sc.face_shape_score >= 15 THEN '얼굴형' END,
            CASE WHEN sc.eye_score >= 15 THEN '눈' END,
            CASE WHEN sc.nose_score >= 10 THEN '코' END,
            CASE WHEN sc.mouth_score >= 7 THEN '입' END,
            CASE WHEN sc.jawline_score >= 15 THEN '턱선' END,
            CASE WHEN sc.impression_score >= 10 THEN '분위기' END
        ], NULL) AS matched
    FROM scored_celebrities sc
    WHERE (sc.face_shape_score + sc.eye_score + sc.nose_score + sc.mouth_score + sc.jawline_score + sc.impression_score) >= min_score
    ORDER BY (sc.face_shape_score + sc.eye_score + sc.nose_score + sc.mouth_score + sc.jawline_score + sc.impression_score) DESC
    LIMIT limit_count;
END;
$$ LANGUAGE plpgsql;

-- Add comment for the function
COMMENT ON FUNCTION find_similar_celebrities IS '사용자 관상 특징과 유사한 연예인을 찾는 함수 (최소 50점 이상 매칭)';

-- Create migration log entry
INSERT INTO public.migration_log (migration_name, status, message, created_at)
VALUES (
    'add_celebrity_face_features',
    'completed',
    'Added face_features JSONB column and find_similar_celebrities function for physiognomy matching',
    NOW()
) ON CONFLICT DO NOTHING;
