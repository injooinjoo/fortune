-- AI 생성 부적 이미지 저장 테이블
CREATE TABLE IF NOT EXISTS talisman_images (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  category TEXT NOT NULL,
  image_url TEXT NOT NULL,
  prompt_used TEXT NOT NULL,
  characters TEXT[] NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  -- 메타데이터
  generation_time_ms INTEGER,
  model_used TEXT DEFAULT 'gemini-2.0-flash-exp',

  CONSTRAINT valid_category CHECK (category IN (
    'disease_prevention',
    'love_relationship',
    'wealth_career',
    'disaster_removal',
    'home_protection',
    'academic_success',
    'health_longevity'
  ))
);

-- 인덱스 생성
CREATE INDEX idx_talisman_images_user_id_created_at
  ON talisman_images(user_id, created_at DESC);

CREATE INDEX idx_talisman_images_category
  ON talisman_images(category);

CREATE INDEX idx_talisman_images_created_at
  ON talisman_images(created_at DESC);

-- RLS 활성화
ALTER TABLE talisman_images ENABLE ROW LEVEL SECURITY;

-- RLS 정책: 사용자는 자신의 부적만 조회 가능
CREATE POLICY "Users can view own talisman images"
  ON talisman_images FOR SELECT
  USING (auth.uid() = user_id);

-- RLS 정책: 사용자는 자신의 부적만 삽입 가능
CREATE POLICY "Users can insert own talisman images"
  ON talisman_images FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- RLS 정책: 사용자는 자신의 부적만 삭제 가능
CREATE POLICY "Users can delete own talisman images"
  ON talisman_images FOR DELETE
  USING (auth.uid() = user_id);

-- Storage Bucket 생성 (이미 존재하지 않는 경우)
INSERT INTO storage.buckets (id, name, public)
VALUES ('talisman-images', 'talisman-images', true)
ON CONFLICT (id) DO NOTHING;

-- Storage RLS 정책: 사용자는 자신의 폴더에만 업로드 가능
CREATE POLICY "Users can upload own talisman images"
  ON storage.objects FOR INSERT
  WITH CHECK (
    bucket_id = 'talisman-images' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- Storage RLS 정책: 모든 사용자는 부적 이미지 조회 가능 (public bucket)
CREATE POLICY "Anyone can view talisman images"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'talisman-images');

-- Storage RLS 정책: 사용자는 자신의 부적 이미지만 삭제 가능
CREATE POLICY "Users can delete own talisman images"
  ON storage.objects FOR DELETE
  USING (
    bucket_id = 'talisman-images' AND
    auth.uid()::text = (storage.foldername(name))[1]
  );

-- 코멘트 추가
COMMENT ON TABLE talisman_images IS 'AI 생성 부적 이미지 저장 (Gemini Imagen 3)';
COMMENT ON COLUMN talisman_images.category IS '부적 카테고리 (7종)';
COMMENT ON COLUMN talisman_images.characters IS '사용된 한자 문구 배열';
COMMENT ON COLUMN talisman_images.prompt_used IS 'Gemini Imagen 3 프롬프트 전문';
