-- ============================================
-- 트렌드 콘텐츠 시스템 테이블 생성
-- 심리테스트, 이상형 월드컵, 밸런스 게임
-- ============================================

-- ============================================
-- 1. 트렌드 콘텐츠 공통 메타데이터 테이블
-- ============================================
CREATE TABLE public.trend_contents (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    type text NOT NULL CHECK (type IN ('psychology_test', 'ideal_worldcup', 'balance_game')),
    title text NOT NULL,
    subtitle text,
    description text,
    thumbnail_url text,
    category text NOT NULL CHECK (category IN ('love', 'personality', 'lifestyle', 'entertainment', 'food', 'animal', 'work', 'travel')),
    view_count integer DEFAULT 0,
    participant_count integer DEFAULT 0,
    like_count integer DEFAULT 0,
    share_count integer DEFAULT 0,
    is_active boolean DEFAULT true,
    is_premium boolean DEFAULT false,
    token_cost integer DEFAULT 0,
    start_date timestamp with time zone,
    end_date timestamp with time zone,
    sort_order integer DEFAULT 0,
    metadata jsonb DEFAULT '{}',
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- 인덱스
CREATE INDEX idx_trend_contents_type ON public.trend_contents(type);
CREATE INDEX idx_trend_contents_category ON public.trend_contents(category);
CREATE INDEX idx_trend_contents_active ON public.trend_contents(is_active, sort_order);
CREATE INDEX idx_trend_contents_popular ON public.trend_contents(participant_count DESC);

-- RLS
ALTER TABLE public.trend_contents ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Anyone can view active trend contents" ON public.trend_contents
    FOR SELECT USING (is_active = true);

COMMENT ON TABLE public.trend_contents IS '트렌드 콘텐츠 메타데이터 (심리테스트, 이상형월드컵, 밸런스게임 공통)';

-- ============================================
-- 2. 심리테스트 테이블
-- ============================================

-- 심리테스트 정의
CREATE TABLE public.psychology_tests (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    content_id uuid NOT NULL REFERENCES public.trend_contents(id) ON DELETE CASCADE,
    result_type text NOT NULL CHECK (result_type IN ('character', 'animal', 'food', 'color', 'celebrity', 'mbti', 'custom')),
    description text,
    question_count integer DEFAULT 0,
    estimated_minutes integer DEFAULT 5,
    use_llm_analysis boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),

    CONSTRAINT unique_content_test UNIQUE(content_id)
);

-- 테스트 질문
CREATE TABLE public.psychology_test_questions (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    test_id uuid NOT NULL REFERENCES public.psychology_tests(id) ON DELETE CASCADE,
    question_order integer NOT NULL,
    question_text text NOT NULL,
    image_url text,
    created_at timestamp with time zone DEFAULT now()
);

-- 질문 선택지
CREATE TABLE public.psychology_test_options (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    question_id uuid NOT NULL REFERENCES public.psychology_test_questions(id) ON DELETE CASCADE,
    label text NOT NULL,
    image_url text,
    score_map jsonb NOT NULL DEFAULT '{}',
    option_order integer DEFAULT 0
);

-- 테스트 결과 정의
CREATE TABLE public.psychology_test_results (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    test_id uuid NOT NULL REFERENCES public.psychology_tests(id) ON DELETE CASCADE,
    result_code text NOT NULL,
    title text NOT NULL,
    description text NOT NULL,
    image_url text,
    characteristics jsonb DEFAULT '[]',
    compatible_with text,
    incompatible_with text,
    additional_info jsonb DEFAULT '{}',
    selection_count integer DEFAULT 0
);

-- 사용자 테스트 결과
CREATE TABLE public.user_psychology_results (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    test_id uuid NOT NULL REFERENCES public.psychology_tests(id) ON DELETE CASCADE,
    result_id uuid NOT NULL REFERENCES public.psychology_test_results(id),
    answers jsonb NOT NULL,
    score_breakdown jsonb NOT NULL,
    llm_analysis text,
    is_shared boolean DEFAULT false,
    completed_at timestamp with time zone DEFAULT now()
);

-- 인덱스
CREATE INDEX idx_psychology_tests_content ON public.psychology_tests(content_id);
CREATE INDEX idx_psychology_questions_test ON public.psychology_test_questions(test_id, question_order);
CREATE INDEX idx_psychology_options_question ON public.psychology_test_options(question_id, option_order);
CREATE INDEX idx_psychology_results_test ON public.psychology_test_results(test_id);
CREATE INDEX idx_user_psychology_user ON public.user_psychology_results(user_id, completed_at DESC);
CREATE INDEX idx_user_psychology_test ON public.user_psychology_results(test_id, completed_at DESC);

-- RLS
ALTER TABLE public.psychology_tests ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.psychology_test_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.psychology_test_options ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.psychology_test_results ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_psychology_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view psychology tests" ON public.psychology_tests FOR SELECT USING (true);
CREATE POLICY "Anyone can view psychology questions" ON public.psychology_test_questions FOR SELECT USING (true);
CREATE POLICY "Anyone can view psychology options" ON public.psychology_test_options FOR SELECT USING (true);
CREATE POLICY "Anyone can view psychology results" ON public.psychology_test_results FOR SELECT USING (true);
CREATE POLICY "Users can view own psychology results" ON public.user_psychology_results FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own psychology results" ON public.user_psychology_results FOR INSERT WITH CHECK (auth.uid() = user_id);

COMMENT ON TABLE public.psychology_tests IS '심리테스트 정의';
COMMENT ON TABLE public.psychology_test_questions IS '심리테스트 질문';
COMMENT ON TABLE public.psychology_test_options IS '심리테스트 선택지';
COMMENT ON TABLE public.psychology_test_results IS '심리테스트 결과 유형 정의';
COMMENT ON TABLE public.user_psychology_results IS '사용자 심리테스트 참여 결과';

-- ============================================
-- 3. 이상형 월드컵 테이블
-- ============================================

-- 월드컵 정의
CREATE TABLE public.ideal_worldcups (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    content_id uuid NOT NULL REFERENCES public.trend_contents(id) ON DELETE CASCADE,
    description text,
    worldcup_category text NOT NULL CHECK (worldcup_category IN ('celebrity', 'food', 'travel', 'animal', 'movie', 'character', 'custom')),
    total_rounds integer DEFAULT 16 CHECK (total_rounds IN (8, 16, 32, 64)),
    created_at timestamp with time zone DEFAULT now(),

    CONSTRAINT unique_content_worldcup UNIQUE(content_id)
);

-- 월드컵 후보
CREATE TABLE public.worldcup_candidates (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    worldcup_id uuid NOT NULL REFERENCES public.ideal_worldcups(id) ON DELETE CASCADE,
    name text NOT NULL,
    image_url text NOT NULL,
    description text,
    win_count integer DEFAULT 0,
    lose_count integer DEFAULT 0,
    final_win_count integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now()
);

-- 사용자 월드컵 결과
CREATE TABLE public.user_worldcup_results (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    worldcup_id uuid NOT NULL REFERENCES public.ideal_worldcups(id) ON DELETE CASCADE,
    winner_id uuid NOT NULL REFERENCES public.worldcup_candidates(id),
    second_place_id uuid REFERENCES public.worldcup_candidates(id),
    third_place_id uuid REFERENCES public.worldcup_candidates(id),
    fourth_place_id uuid REFERENCES public.worldcup_candidates(id),
    match_history jsonb NOT NULL,
    is_shared boolean DEFAULT false,
    completed_at timestamp with time zone DEFAULT now()
);

-- 월드컵 랭킹 뷰 (실시간 집계)
CREATE VIEW public.worldcup_rankings AS
SELECT
    wc.worldcup_id,
    wc.id as candidate_id,
    wc.name as candidate_name,
    wc.image_url as candidate_image,
    wc.win_count,
    wc.lose_count,
    wc.final_win_count,
    CASE WHEN (wc.win_count + wc.lose_count) > 0
         THEN ROUND((wc.win_count::numeric / (wc.win_count + wc.lose_count)) * 100, 1)
         ELSE 0 END as win_rate,
    RANK() OVER (PARTITION BY wc.worldcup_id ORDER BY wc.final_win_count DESC, wc.win_count DESC) as rank
FROM public.worldcup_candidates wc;

-- 인덱스
CREATE INDEX idx_worldcup_content ON public.ideal_worldcups(content_id);
CREATE INDEX idx_worldcup_candidates_worldcup ON public.worldcup_candidates(worldcup_id);
CREATE INDEX idx_worldcup_candidates_stats ON public.worldcup_candidates(worldcup_id, final_win_count DESC, win_count DESC);
CREATE INDEX idx_user_worldcup_user ON public.user_worldcup_results(user_id, completed_at DESC);
CREATE INDEX idx_user_worldcup_worldcup ON public.user_worldcup_results(worldcup_id, completed_at DESC);

-- RLS
ALTER TABLE public.ideal_worldcups ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.worldcup_candidates ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_worldcup_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view worldcups" ON public.ideal_worldcups FOR SELECT USING (true);
CREATE POLICY "Anyone can view candidates" ON public.worldcup_candidates FOR SELECT USING (true);
CREATE POLICY "Users can view own worldcup results" ON public.user_worldcup_results FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own worldcup results" ON public.user_worldcup_results FOR INSERT WITH CHECK (auth.uid() = user_id);

COMMENT ON TABLE public.ideal_worldcups IS '이상형 월드컵 정의';
COMMENT ON TABLE public.worldcup_candidates IS '이상형 월드컵 후보';
COMMENT ON TABLE public.user_worldcup_results IS '사용자 월드컵 결과';

-- ============================================
-- 4. 밸런스 게임 테이블
-- ============================================

-- 밸런스 게임 세트
CREATE TABLE public.balance_game_sets (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    content_id uuid NOT NULL REFERENCES public.trend_contents(id) ON DELETE CASCADE,
    description text,
    question_count integer DEFAULT 10,
    created_at timestamp with time zone DEFAULT now(),

    CONSTRAINT unique_content_balance UNIQUE(content_id)
);

-- 밸런스 게임 질문
CREATE TABLE public.balance_game_questions (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    game_set_id uuid NOT NULL REFERENCES public.balance_game_sets(id) ON DELETE CASCADE,
    question_order integer NOT NULL,
    choice_a_text text NOT NULL,
    choice_a_image text,
    choice_a_emoji text,
    choice_b_text text NOT NULL,
    choice_b_image text,
    choice_b_emoji text,
    total_votes integer DEFAULT 0,
    votes_a integer DEFAULT 0,
    votes_b integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now()
);

-- 사용자 밸런스 게임 결과
CREATE TABLE public.user_balance_results (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    game_set_id uuid NOT NULL REFERENCES public.balance_game_sets(id) ON DELETE CASCADE,
    answers jsonb NOT NULL,
    majority_match_count integer DEFAULT 0,
    is_shared boolean DEFAULT false,
    completed_at timestamp with time zone DEFAULT now()
);

-- 인덱스
CREATE INDEX idx_balance_sets_content ON public.balance_game_sets(content_id);
CREATE INDEX idx_balance_questions_set ON public.balance_game_questions(game_set_id, question_order);
CREATE INDEX idx_user_balance_user ON public.user_balance_results(user_id, completed_at DESC);
CREATE INDEX idx_user_balance_set ON public.user_balance_results(game_set_id, completed_at DESC);

-- RLS
ALTER TABLE public.balance_game_sets ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.balance_game_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_balance_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view balance games" ON public.balance_game_sets FOR SELECT USING (true);
CREATE POLICY "Anyone can view balance questions" ON public.balance_game_questions FOR SELECT USING (true);
CREATE POLICY "Users can view own balance results" ON public.user_balance_results FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own balance results" ON public.user_balance_results FOR INSERT WITH CHECK (auth.uid() = user_id);

COMMENT ON TABLE public.balance_game_sets IS '밸런스 게임 세트';
COMMENT ON TABLE public.balance_game_questions IS '밸런스 게임 질문';
COMMENT ON TABLE public.user_balance_results IS '사용자 밸런스 게임 결과';

-- ============================================
-- 5. 소셜 기능 테이블 (좋아요, 댓글)
-- ============================================

-- 좋아요 테이블
CREATE TABLE public.trend_likes (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    content_id uuid NOT NULL REFERENCES public.trend_contents(id) ON DELETE CASCADE,
    created_at timestamp with time zone DEFAULT now(),

    CONSTRAINT unique_user_content_like UNIQUE(user_id, content_id)
);

-- 댓글 테이블
CREATE TABLE public.trend_comments (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    content_id uuid NOT NULL REFERENCES public.trend_contents(id) ON DELETE CASCADE,
    parent_id uuid REFERENCES public.trend_comments(id) ON DELETE CASCADE,
    content text NOT NULL,
    like_count integer DEFAULT 0,
    is_deleted boolean DEFAULT false,
    is_edited boolean DEFAULT false,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

-- 댓글 좋아요 테이블
CREATE TABLE public.trend_comment_likes (
    id uuid DEFAULT gen_random_uuid() PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    comment_id uuid NOT NULL REFERENCES public.trend_comments(id) ON DELETE CASCADE,
    created_at timestamp with time zone DEFAULT now(),

    CONSTRAINT unique_user_comment_like UNIQUE(user_id, comment_id)
);

-- 인덱스
CREATE INDEX idx_trend_likes_content ON public.trend_likes(content_id);
CREATE INDEX idx_trend_likes_user ON public.trend_likes(user_id);
CREATE INDEX idx_trend_comments_content ON public.trend_comments(content_id, created_at DESC);
CREATE INDEX idx_trend_comments_parent ON public.trend_comments(parent_id);
CREATE INDEX idx_trend_comment_likes_comment ON public.trend_comment_likes(comment_id);

-- RLS
ALTER TABLE public.trend_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trend_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.trend_comment_likes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view likes" ON public.trend_likes FOR SELECT USING (true);
CREATE POLICY "Users can insert own likes" ON public.trend_likes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own likes" ON public.trend_likes FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Anyone can view comments" ON public.trend_comments FOR SELECT USING (true);
CREATE POLICY "Users can insert own comments" ON public.trend_comments FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own comments" ON public.trend_comments FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own comments" ON public.trend_comments FOR DELETE USING (auth.uid() = user_id);

CREATE POLICY "Anyone can view comment likes" ON public.trend_comment_likes FOR SELECT USING (true);
CREATE POLICY "Users can insert own comment likes" ON public.trend_comment_likes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own comment likes" ON public.trend_comment_likes FOR DELETE USING (auth.uid() = user_id);

COMMENT ON TABLE public.trend_likes IS '트렌드 콘텐츠 좋아요';
COMMENT ON TABLE public.trend_comments IS '트렌드 콘텐츠 댓글';
COMMENT ON TABLE public.trend_comment_likes IS '트렌드 댓글 좋아요';

-- ============================================
-- 6. 통계 업데이트 함수 및 트리거
-- ============================================

-- 참여자 수 업데이트 함수
CREATE OR REPLACE FUNCTION update_trend_participant_count()
RETURNS TRIGGER AS $$
DECLARE
    content_uuid uuid;
BEGIN
    IF TG_TABLE_NAME = 'user_psychology_results' THEN
        SELECT pt.content_id INTO content_uuid
        FROM psychology_tests pt
        WHERE pt.id = NEW.test_id;
    ELSIF TG_TABLE_NAME = 'user_worldcup_results' THEN
        SELECT iw.content_id INTO content_uuid
        FROM ideal_worldcups iw
        WHERE iw.id = NEW.worldcup_id;
    ELSIF TG_TABLE_NAME = 'user_balance_results' THEN
        SELECT bs.content_id INTO content_uuid
        FROM balance_game_sets bs
        WHERE bs.id = NEW.game_set_id;
    END IF;

    IF content_uuid IS NOT NULL THEN
        UPDATE trend_contents
        SET participant_count = participant_count + 1, updated_at = now()
        WHERE id = content_uuid;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 트리거 생성
CREATE TRIGGER trigger_psychology_participant
    AFTER INSERT ON public.user_psychology_results
    FOR EACH ROW EXECUTE FUNCTION update_trend_participant_count();

CREATE TRIGGER trigger_worldcup_participant
    AFTER INSERT ON public.user_worldcup_results
    FOR EACH ROW EXECUTE FUNCTION update_trend_participant_count();

CREATE TRIGGER trigger_balance_participant
    AFTER INSERT ON public.user_balance_results
    FOR EACH ROW EXECUTE FUNCTION update_trend_participant_count();

-- 월드컵 후보 통계 업데이트 함수
CREATE OR REPLACE FUNCTION update_worldcup_candidate_stats()
RETURNS TRIGGER AS $$
DECLARE
    match_record jsonb;
BEGIN
    FOR match_record IN SELECT * FROM jsonb_array_elements(NEW.match_history)
    LOOP
        UPDATE worldcup_candidates
        SET win_count = win_count + 1
        WHERE id = (match_record->>'winnerId')::uuid;

        UPDATE worldcup_candidates
        SET lose_count = lose_count + 1
        WHERE id = (match_record->>'loserId')::uuid;
    END LOOP;

    UPDATE worldcup_candidates
    SET final_win_count = final_win_count + 1
    WHERE id = NEW.winner_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_worldcup_stats
    AFTER INSERT ON public.user_worldcup_results
    FOR EACH ROW EXECUTE FUNCTION update_worldcup_candidate_stats();

-- 밸런스 게임 투표 업데이트 함수
CREATE OR REPLACE FUNCTION update_balance_vote_stats()
RETURNS TRIGGER AS $$
DECLARE
    answer_key text;
    answer_value text;
BEGIN
    FOR answer_key, answer_value IN
        SELECT key, value FROM jsonb_each_text(NEW.answers)
    LOOP
        IF answer_value = 'A' THEN
            UPDATE balance_game_questions
            SET votes_a = votes_a + 1, total_votes = total_votes + 1
            WHERE id = answer_key::uuid;
        ELSIF answer_value = 'B' THEN
            UPDATE balance_game_questions
            SET votes_b = votes_b + 1, total_votes = total_votes + 1
            WHERE id = answer_key::uuid;
        END IF;
    END LOOP;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_balance_votes
    AFTER INSERT ON public.user_balance_results
    FOR EACH ROW EXECUTE FUNCTION update_balance_vote_stats();

-- 좋아요 수 업데이트 함수
CREATE OR REPLACE FUNCTION update_trend_like_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE trend_contents SET like_count = like_count + 1 WHERE id = NEW.content_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE trend_contents SET like_count = like_count - 1 WHERE id = OLD.content_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_trend_like_count
    AFTER INSERT OR DELETE ON public.trend_likes
    FOR EACH ROW EXECUTE FUNCTION update_trend_like_count();

-- 댓글 좋아요 수 업데이트 함수
CREATE OR REPLACE FUNCTION update_comment_like_count()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE trend_comments SET like_count = like_count + 1 WHERE id = NEW.comment_id;
    ELSIF TG_OP = 'DELETE' THEN
        UPDATE trend_comments SET like_count = like_count - 1 WHERE id = OLD.comment_id;
    END IF;
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_comment_like_count
    AFTER INSERT OR DELETE ON public.trend_comment_likes
    FOR EACH ROW EXECUTE FUNCTION update_comment_like_count();

-- 심리테스트 결과 선택 수 업데이트 함수
CREATE OR REPLACE FUNCTION update_psychology_result_count()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE psychology_test_results
    SET selection_count = selection_count + 1
    WHERE id = NEW.result_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_psychology_result_count
    AFTER INSERT ON public.user_psychology_results
    FOR EACH ROW EXECUTE FUNCTION update_psychology_result_count();

-- ============================================
-- 7. 권한 부여
-- ============================================
GRANT SELECT ON public.trend_contents TO anon, authenticated;
GRANT SELECT ON public.psychology_tests TO anon, authenticated;
GRANT SELECT ON public.psychology_test_questions TO anon, authenticated;
GRANT SELECT ON public.psychology_test_options TO anon, authenticated;
GRANT SELECT ON public.psychology_test_results TO anon, authenticated;
GRANT SELECT, INSERT ON public.user_psychology_results TO authenticated;
GRANT SELECT ON public.ideal_worldcups TO anon, authenticated;
GRANT SELECT ON public.worldcup_candidates TO anon, authenticated;
GRANT SELECT ON public.worldcup_rankings TO anon, authenticated;
GRANT SELECT, INSERT ON public.user_worldcup_results TO authenticated;
GRANT SELECT ON public.balance_game_sets TO anon, authenticated;
GRANT SELECT ON public.balance_game_questions TO anon, authenticated;
GRANT SELECT, INSERT ON public.user_balance_results TO authenticated;
GRANT SELECT, INSERT, DELETE ON public.trend_likes TO authenticated;
GRANT SELECT, INSERT, UPDATE, DELETE ON public.trend_comments TO authenticated;
GRANT SELECT, INSERT, DELETE ON public.trend_comment_likes TO authenticated;

-- ============================================
-- 8. RPC 함수 (Repository에서 사용)
-- ============================================

-- 월드컵 통계 증가 함수 (매치 결과)
CREATE OR REPLACE FUNCTION increment_worldcup_stats(p_winner_id uuid, p_loser_id uuid)
RETURNS void AS $$
BEGIN
    UPDATE worldcup_candidates SET win_count = win_count + 1 WHERE id = p_winner_id;
    UPDATE worldcup_candidates SET lose_count = lose_count + 1 WHERE id = p_loser_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 월드컵 최종 우승 증가 함수
CREATE OR REPLACE FUNCTION increment_final_win(p_candidate_id uuid)
RETURNS void AS $$
BEGIN
    UPDATE worldcup_candidates SET final_win_count = final_win_count + 1 WHERE id = p_candidate_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 밸런스 게임 A 투표 증가 함수
CREATE OR REPLACE FUNCTION increment_balance_vote_a(p_question_id uuid)
RETURNS void AS $$
BEGIN
    UPDATE balance_game_questions
    SET votes_a = votes_a + 1, total_votes = total_votes + 1
    WHERE id = p_question_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 밸런스 게임 B 투표 증가 함수
CREATE OR REPLACE FUNCTION increment_balance_vote_b(p_question_id uuid)
RETURNS void AS $$
BEGIN
    UPDATE balance_game_questions
    SET votes_b = votes_b + 1, total_votes = total_votes + 1
    WHERE id = p_question_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 공유 수 증가 함수
CREATE OR REPLACE FUNCTION increment_share_count(p_content_id uuid)
RETURNS void AS $$
BEGIN
    UPDATE trend_contents SET share_count = share_count + 1 WHERE id = p_content_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 조회수 증가 함수
CREATE OR REPLACE FUNCTION increment_view_count(p_content_id uuid)
RETURNS void AS $$
BEGIN
    UPDATE trend_contents SET view_count = view_count + 1 WHERE id = p_content_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- RPC 함수 권한 부여
GRANT EXECUTE ON FUNCTION increment_worldcup_stats TO authenticated;
GRANT EXECUTE ON FUNCTION increment_final_win TO authenticated;
GRANT EXECUTE ON FUNCTION increment_balance_vote_a TO authenticated;
GRANT EXECUTE ON FUNCTION increment_balance_vote_b TO authenticated;
GRANT EXECUTE ON FUNCTION increment_share_count TO authenticated;
GRANT EXECUTE ON FUNCTION increment_view_count TO anon, authenticated;
