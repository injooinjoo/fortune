-- 유명인 테이블 스키마 확장
-- 추가: mbti, blood_type, is_group_member, group_name, legal_name

-- 새 컬럼 추가
ALTER TABLE public.celebrities
ADD COLUMN IF NOT EXISTS mbti TEXT,
ADD COLUMN IF NOT EXISTS blood_type TEXT,
ADD COLUMN IF NOT EXISTS is_group_member BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS group_name TEXT,
ADD COLUMN IF NOT EXISTS legal_name TEXT;

-- CHECK 제약조건: MBTI 유효값
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'chk_celebrities_mbti'
    ) THEN
        ALTER TABLE public.celebrities
        ADD CONSTRAINT chk_celebrities_mbti CHECK (
            mbti IS NULL OR mbti IN (
                'INTJ', 'INTP', 'ENTJ', 'ENTP',
                'INFJ', 'INFP', 'ENFJ', 'ENFP',
                'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
                'ISTP', 'ISFP', 'ESTP', 'ESFP'
            )
        );
    END IF;
END $$;

-- CHECK 제약조건: 혈액형 유효값
DO $$
BEGIN
    IF NOT EXISTS (
        SELECT 1 FROM pg_constraint WHERE conname = 'chk_celebrities_blood_type'
    ) THEN
        ALTER TABLE public.celebrities
        ADD CONSTRAINT chk_celebrities_blood_type CHECK (
            blood_type IS NULL OR blood_type IN ('A', 'B', 'O', 'AB')
        );
    END IF;
END $$;

-- 인덱스 추가
CREATE INDEX IF NOT EXISTS idx_celebrities_mbti
    ON public.celebrities(mbti) WHERE mbti IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_celebrities_blood_type
    ON public.celebrities(blood_type) WHERE blood_type IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_celebrities_group_name
    ON public.celebrities(group_name) WHERE group_name IS NOT NULL;
CREATE INDEX IF NOT EXISTS idx_celebrities_is_group_member
    ON public.celebrities(is_group_member) WHERE is_group_member = true;
CREATE INDEX IF NOT EXISTS idx_celebrities_legal_name
    ON public.celebrities(legal_name) WHERE legal_name IS NOT NULL;

-- 복합 인덱스: MBTI + 혈액형 성격 검색용
CREATE INDEX IF NOT EXISTS idx_celebrities_mbti_blood
    ON public.celebrities(mbti, blood_type)
    WHERE mbti IS NOT NULL AND blood_type IS NOT NULL;

-- 그룹별 멤버 조회 함수
CREATE OR REPLACE FUNCTION get_celebrities_by_group(p_group_name TEXT)
RETURNS SETOF celebrities AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM celebrities
    WHERE is_active = true
    AND is_group_member = true
    AND group_name = p_group_name
    ORDER BY name;
END;
$$ LANGUAGE plpgsql;

-- MBTI별 유명인 조회 함수
CREATE OR REPLACE FUNCTION get_celebrities_by_mbti(p_mbti TEXT, p_limit INTEGER DEFAULT 50)
RETURNS SETOF celebrities AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM celebrities
    WHERE is_active = true
    AND mbti = p_mbti
    ORDER BY popularity_score DESC, name
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- 혈액형별 유명인 조회 함수
CREATE OR REPLACE FUNCTION get_celebrities_by_blood_type(p_blood_type TEXT, p_limit INTEGER DEFAULT 50)
RETURNS SETOF celebrities AS $$
BEGIN
    RETURN QUERY
    SELECT * FROM celebrities
    WHERE is_active = true
    AND blood_type = p_blood_type
    ORDER BY popularity_score DESC, name
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- 컬럼 코멘트 추가
COMMENT ON COLUMN public.celebrities.mbti IS 'MBTI 성격 유형 (16가지)';
COMMENT ON COLUMN public.celebrities.blood_type IS '혈액형 (A, B, O, AB)';
COMMENT ON COLUMN public.celebrities.is_group_member IS '그룹 멤버 여부 (아이돌 등)';
COMMENT ON COLUMN public.celebrities.group_name IS '소속 그룹명 (BTS, BLACKPINK 등)';
COMMENT ON COLUMN public.celebrities.legal_name IS '본명 (활동명과 다를 경우)';
