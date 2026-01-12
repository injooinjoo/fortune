-- 소원빌기 하루 1회 → 하루 3회로 변경
-- unique constraint 제거 (애플리케이션 레벨에서 3회 제한 체크)

-- 1. 기존 unique constraint 제거
ALTER TABLE wish_fortunes DROP CONSTRAINT IF EXISTS one_wish_per_day;

-- 2. 새 인덱스 생성 (하루 3회 제한 체크용)
CREATE INDEX IF NOT EXISTS idx_wish_fortunes_user_date_count
ON wish_fortunes(user_id, wish_date);

-- 3. 코멘트 업데이트
COMMENT ON TABLE wish_fortunes IS '소원빌기 결과 (하루 3회 제한, 전체 히스토리 누적)';
COMMENT ON COLUMN wish_fortunes.wish_date IS '소원을 빈 날짜 (하루 3회 제한용)';
