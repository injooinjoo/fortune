-- Create user_talismans table
-- 사용자가 생성한 부적 정보 저장
CREATE TABLE public.user_talismans (
    id text PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    design_type text NOT NULL,
    category text NOT NULL,
    title text NOT NULL,
    image_url text,
    colors jsonb NOT NULL DEFAULT '{}',
    symbols jsonb NOT NULL DEFAULT '{}',
    mantra_text text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone,
    is_premium boolean DEFAULT false NOT NULL,
    effect_score integer DEFAULT 0,
    blessings jsonb NOT NULL DEFAULT '[]'
);

-- Create talisman_effects table
-- 부적 효과 추적 정보 저장
CREATE TABLE public.talisman_effects (
    id text PRIMARY KEY,
    talisman_id text NOT NULL REFERENCES public.user_talismans(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    tracking_date timestamp with time zone DEFAULT now() NOT NULL,
    daily_score integer NOT NULL,
    positive_signs jsonb DEFAULT '[]',
    challenges jsonb DEFAULT '[]',
    user_note text,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

-- Add indexes for better performance
CREATE INDEX idx_user_talismans_user_id ON public.user_talismans(user_id);
CREATE INDEX idx_user_talismans_created_at ON public.user_talismans(created_at DESC);
CREATE INDEX idx_user_talismans_category ON public.user_talismans(category);

CREATE INDEX idx_talisman_effects_talisman_id ON public.talisman_effects(talisman_id);
CREATE INDEX idx_talisman_effects_user_id ON public.talisman_effects(user_id);
CREATE INDEX idx_talisman_effects_tracking_date ON public.talisman_effects(tracking_date DESC);

-- Enable Row Level Security (RLS)
ALTER TABLE public.user_talismans ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.talisman_effects ENABLE ROW LEVEL SECURITY;

-- Create RLS policies for user_talismans
-- 사용자는 자신의 부적만 조회/생성/수정/삭제 가능
CREATE POLICY "Users can view their own talismans" ON public.user_talismans 
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own talismans" ON public.user_talismans 
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own talismans" ON public.user_talismans 
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own talismans" ON public.user_talismans 
    FOR DELETE USING (auth.uid() = user_id);

-- Create RLS policies for talisman_effects
-- 사용자는 자신의 부적 효과만 조회/생성/수정/삭제 가능
CREATE POLICY "Users can view their own talisman effects" ON public.talisman_effects 
    FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own talisman effects" ON public.talisman_effects 
    FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own talisman effects" ON public.talisman_effects 
    FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own talisman effects" ON public.talisman_effects 
    FOR DELETE USING (auth.uid() = user_id);

-- Grant necessary permissions
GRANT ALL ON public.user_talismans TO authenticated;
GRANT ALL ON public.talisman_effects TO authenticated;

-- Add comments for documentation
COMMENT ON TABLE public.user_talismans IS '사용자가 생성한 부적 정보를 저장하는 테이블';
COMMENT ON TABLE public.talisman_effects IS '부적의 효과 추적 정보를 저장하는 테이블';

COMMENT ON COLUMN public.user_talismans.design_type IS '부적 디자인 타입 (traditional, modern, minimalist, ornate, mystical)';
COMMENT ON COLUMN public.user_talismans.category IS '부적 카테고리 (wealth, love, career, health, study, relationship, goal)';
COMMENT ON COLUMN public.user_talismans.colors IS '부적의 색상 정보 (primary, secondary, accent)';
COMMENT ON COLUMN public.user_talismans.symbols IS '부적의 상징 정보 (main, secondary, elements)';
COMMENT ON COLUMN public.user_talismans.effect_score IS '부적의 효과 점수 (0-100)';
COMMENT ON COLUMN public.user_talismans.blessings IS '부적이 가져다 줄 축복들의 배열';

COMMENT ON COLUMN public.talisman_effects.daily_score IS '해당 날짜의 부적 효과 점수 (0-100)';
COMMENT ON COLUMN public.talisman_effects.positive_signs IS '긍정적인 신호들의 배열';
COMMENT ON COLUMN public.talisman_effects.challenges IS '겪은 어려움들의 배열';