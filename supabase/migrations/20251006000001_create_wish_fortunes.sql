-- 소원빌기 결과를 저장하는 테이블
CREATE TABLE IF NOT EXISTS wish_fortunes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,

  -- 소원 입력 정보
  wish_text TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('사랑', '돈', '건강', '성공', '가족', '학업', '기타')),
  urgency INTEGER NOT NULL CHECK (urgency BETWEEN 1 AND 5),

  -- AI 응답 필드들
  overall_score INTEGER CHECK (overall_score BETWEEN 0 AND 100),
  divine_message TEXT,
  wish_analysis JSONB DEFAULT '{}'::jsonb,
  realization JSONB DEFAULT '{}'::jsonb,
  lucky_elements JSONB DEFAULT '{}'::jsonb,
  warnings TEXT[] DEFAULT ARRAY[]::TEXT[],
  action_plan TEXT[] DEFAULT ARRAY[]::TEXT[],
  spiritual_message TEXT,
  statistics JSONB DEFAULT '{}'::jsonb,

  -- 메타데이터
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  is_shared BOOLEAN DEFAULT FALSE,
  share_count INTEGER DEFAULT 0
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_wish_fortunes_user_id ON wish_fortunes(user_id);
CREATE INDEX IF NOT EXISTS idx_wish_fortunes_created_at ON wish_fortunes(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_wish_fortunes_category ON wish_fortunes(category);

-- RLS 정책 활성화
ALTER TABLE wish_fortunes ENABLE ROW LEVEL SECURITY;

-- 사용자 본인만 자신의 소원 결과를 볼 수 있음
CREATE POLICY "Users can view their own wish fortunes"
  ON wish_fortunes FOR SELECT
  USING (auth.uid() = user_id);

-- 사용자 본인만 소원 결과를 생성할 수 있음
CREATE POLICY "Users can insert their own wish fortunes"
  ON wish_fortunes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 사용자 본인만 자신의 소원 결과를 업데이트할 수 있음 (공유 상태 변경 등)
CREATE POLICY "Users can update their own wish fortunes"
  ON wish_fortunes FOR UPDATE
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- 사용자 본인만 자신의 소원 결과를 삭제할 수 있음
CREATE POLICY "Users can delete their own wish fortunes"
  ON wish_fortunes FOR DELETE
  USING (auth.uid() = user_id);

-- 코멘트 추가
COMMENT ON TABLE wish_fortunes IS '소원빌기 운세 결과를 저장하는 테이블';
COMMENT ON COLUMN wish_fortunes.wish_analysis IS '소원 분석 결과: keywords, emotion_level, sincerity_score 등';
COMMENT ON COLUMN wish_fortunes.realization IS '실현 가능성: probability, conditions, timeline 등';
COMMENT ON COLUMN wish_fortunes.lucky_elements IS '행운 요소: color, direction, time 등';
COMMENT ON COLUMN wish_fortunes.statistics IS '유사 소원 통계: similar_wishes, success_rate 등';
