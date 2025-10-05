-- 기존 테이블 드롭
DROP TABLE IF EXISTS wish_fortunes CASCADE;

-- 소원빌기 결과 테이블 재설계 (공감/희망/조언/응원 중심)
CREATE TABLE wish_fortunes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,

  -- 소원 입력 정보
  wish_text TEXT NOT NULL,
  category TEXT NOT NULL CHECK (category IN ('사랑', '돈', '건강', '성공', '가족', '학업', '기타')),
  urgency INTEGER NOT NULL CHECK (urgency BETWEEN 1 AND 5),

  -- AI 응답 (공감/희망/조언/응원 구조)
  empathy_message TEXT,           -- 공감 메시지 (150자)
  hope_message TEXT,               -- 희망과 격려 (200자)
  advice TEXT[] DEFAULT ARRAY[]::TEXT[],  -- 구체적 조언 3개
  encouragement TEXT,              -- 응원 메시지 (100자)
  special_words TEXT,              -- 신의 한마디 (50자)

  -- 메타데이터
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  wish_date DATE DEFAULT CURRENT_DATE,

  -- 하루 1회 제한 (같은 사용자가 같은 날짜에 중복 불가)
  CONSTRAINT one_wish_per_day UNIQUE (user_id, wish_date)
);

-- 인덱스 생성
CREATE INDEX idx_wish_fortunes_user_date ON wish_fortunes(user_id, wish_date DESC);
CREATE INDEX idx_wish_fortunes_category ON wish_fortunes(category);

-- RLS 정책 활성화
ALTER TABLE wish_fortunes ENABLE ROW LEVEL SECURITY;

-- 사용자 본인만 자신의 소원 결과를 볼 수 있음
CREATE POLICY "Users can view own wishes"
  ON wish_fortunes FOR SELECT
  USING (auth.uid() = user_id);

-- 사용자 본인만 소원 결과를 생성할 수 있음
CREATE POLICY "Users can insert own wishes"
  ON wish_fortunes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- 사용자 본인만 자신의 소원 결과를 삭제할 수 있음
CREATE POLICY "Users can delete own wishes"
  ON wish_fortunes FOR DELETE
  USING (auth.uid() = user_id);

-- 코멘트 추가
COMMENT ON TABLE wish_fortunes IS '소원빌기 결과 (공감/희망/조언/응원 중심)';
COMMENT ON COLUMN wish_fortunes.empathy_message IS '소원에 대한 깊은 공감과 이해';
COMMENT ON COLUMN wish_fortunes.hope_message IS '희망적이고 격려하는 메시지';
COMMENT ON COLUMN wish_fortunes.advice IS '실용적이고 구체적인 조언 3개';
COMMENT ON COLUMN wish_fortunes.encouragement IS '따뜻한 응원 메시지';
COMMENT ON COLUMN wish_fortunes.special_words IS '신이 전하는 특별한 한마디';
COMMENT ON COLUMN wish_fortunes.wish_date IS '소원을 빈 날짜 (하루 1회 제한용)';
