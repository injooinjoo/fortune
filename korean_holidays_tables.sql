-- 한국 공휴일 및 기념일 테이블
CREATE TABLE korean_holidays (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date DATE NOT NULL,
  name TEXT NOT NULL,
  type TEXT NOT NULL, -- 'holiday', 'special', 'memorial'
  is_lunar BOOLEAN DEFAULT false,
  description TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 손없는날 및 길일 테이블
CREATE TABLE auspicious_days (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  date DATE NOT NULL,
  type TEXT NOT NULL, -- 'moving', 'wedding', 'opening', 'travel'
  score INTEGER CHECK (score >= 0 AND score <= 100), -- 0-100 길흉점수
  description TEXT,
  created_at TIMESTAMP DEFAULT NOW()
);

-- 인덱스 생성 (날짜 기반 검색 최적화)
CREATE INDEX idx_korean_holidays_date ON korean_holidays(date);
CREATE INDEX idx_korean_holidays_type ON korean_holidays(type);
CREATE INDEX idx_auspicious_days_date ON auspicious_days(date);
CREATE INDEX idx_auspicious_days_type ON auspicious_days(type);

-- 2024년 공휴일 데이터 삽입
INSERT INTO korean_holidays (date, name, type, is_lunar, description) VALUES
-- 법정공휴일
('2024-01-01', '신정', 'holiday', false, '새해 첫날'),
('2024-02-09', '설날 연휴', 'holiday', true, '설날 전날'),
('2024-02-10', '설날', 'holiday', true, '음력 1월 1일'),
('2024-02-11', '설날 연휴', 'holiday', true, '설날 다음날'),
('2024-02-12', '설날 대체공휴일', 'holiday', false, '설날 대체공휴일'),
('2024-03-01', '삼일절', 'holiday', false, '3·1운동 기념일'),
('2024-04-10', '국회의원선거일', 'holiday', false, '제22대 국회의원선거'),
('2024-05-05', '어린이날', 'holiday', false, '어린이날'),
('2024-05-06', '어린이날 대체공휴일', 'holiday', false, '어린이날 대체공휴일'),
('2024-05-15', '부처님오신날', 'holiday', true, '음력 4월 8일'),
('2024-06-06', '현충일', 'holiday', false, '호국영령을 기리는 날'),
('2024-08-15', '광복절', 'holiday', false, '일제강점기로부터 해방된 날'),
('2024-09-16', '추석 연휴', 'holiday', true, '추석 전날'),
('2024-09-17', '추석', 'holiday', true, '음력 8월 15일'),
('2024-09-18', '추석 연휴', 'holiday', true, '추석 다음날'),
('2024-10-03', '개천절', 'holiday', false, '대한민국 개국기념일'),
('2024-10-09', '한글날', 'holiday', false, '한글 창제를 기념하는 날'),
('2024-12-25', '크리스마스', 'holiday', false, '기독탄신일'),

-- 기념일
('2024-02-14', '발렌타인데이', 'special', false, '사랑하는 사람에게 초콜릿을 주는 날'),
('2024-03-14', '화이트데이', 'special', false, '사탕을 주고받는 날'),
('2024-04-14', '블랙데이', 'special', false, '솔로들이 짜장면을 먹는 날'),
('2024-05-08', '어버이날', 'memorial', false, '부모님의 은혜에 감사하는 날'),
('2024-05-15', '스승의날', 'memorial', false, '선생님께 감사하는 날'),
('2024-06-25', '6.25 전쟁기념일', 'memorial', false, '한국전쟁을 기억하는 날'),
('2024-11-11', '빼빼로데이', 'special', false, '빼빼로를 주고받는 날'),
('2024-12-24', '크리스마스이브', 'special', false, '크리스마스 전날'),
('2024-12-31', '제야', 'special', false, '한 해의 마지막 날');

-- 2025년 공휴일 데이터 삽입
INSERT INTO korean_holidays (date, name, type, is_lunar, description) VALUES
-- 법정공휴일
('2025-01-01', '신정', 'holiday', false, '새해 첫날'),
('2025-01-28', '설날 연휴', 'holiday', true, '설날 전날'),
('2025-01-29', '설날', 'holiday', true, '음력 1월 1일'),
('2025-01-30', '설날 연휴', 'holiday', true, '설날 다음날'),
('2025-03-01', '삼일절', 'holiday', false, '3·1운동 기념일'),
('2025-03-03', '삼일절 대체공휴일', 'holiday', false, '삼일절 대체공휴일'),
('2025-05-05', '어린이날', 'holiday', false, '어린이날'),
('2025-05-12', '부처님오신날', 'holiday', true, '음력 4월 8일'),
('2025-06-06', '현충일', 'holiday', false, '호국영령을 기리는 날'),
('2025-08-15', '광복절', 'holiday', false, '일제강점기로부터 해방된 날'),
('2025-10-05', '추석 연휴', 'holiday', true, '추석 전날'),
('2025-10-06', '추석', 'holiday', true, '음력 8월 15일'),
('2025-10-07', '추석 연휴', 'holiday', true, '추석 다음날'),
('2025-10-08', '추석 대체공휴일', 'holiday', false, '추석 대체공휴일'),
('2025-10-03', '개천절', 'holiday', false, '대한민국 개국기념일'),
('2025-10-09', '한글날', 'holiday', false, '한글 창제를 기념하는 날'),
('2025-12-25', '크리스마스', 'holiday', false, '기독탄신일'),

-- 기념일
('2025-02-14', '발렌타인데이', 'special', false, '사랑하는 사람에게 초콜릿을 주는 날'),
('2025-03-14', '화이트데이', 'special', false, '사탕을 주고받는 날'),
('2025-04-14', '블랙데이', 'special', false, '솔로들이 짜장면을 먹는 날'),
('2025-05-08', '어버이날', 'memorial', false, '부모님의 은혜에 감사하는 날'),
('2025-05-15', '스승의날', 'memorial', false, '선생님께 감사하는 날'),
('2025-06-25', '6.25 전쟁기념일', 'memorial', false, '한국전쟁을 기억하는 날'),
('2025-11-11', '빼빼로데이', 'special', false, '빼빼로를 주고받는 날'),
('2025-12-24', '크리스마스이브', 'special', false, '크리스마스 전날'),
('2025-12-31', '제야', 'special', false, '한 해의 마지막 날');

-- 손없는날 샘플 데이터 (2024년)
INSERT INTO auspicious_days (date, type, score, description) VALUES
('2024-01-07', 'moving', 90, '손없는날 - 이사하기 매우 좋은 날'),
('2024-01-19', 'moving', 85, '손없는날 - 이사하기 좋은 날'),
('2024-02-03', 'moving', 92, '손없는날 - 이사하기 매우 좋은 날'),
('2024-02-15', 'moving', 88, '손없는날 - 이사하기 좋은 날'),
('2024-03-02', 'moving', 90, '손없는날 - 이사하기 매우 좋은 날'),
('2024-03-14', 'moving', 87, '손없는날 - 이사하기 좋은 날'),
('2024-04-05', 'moving', 93, '손없는날 - 이사하기 매우 좋은 날'),
('2024-04-17', 'moving', 89, '손없는날 - 이사하기 좋은 날'),
('2024-05-04', 'moving', 91, '손없는날 - 이사하기 매우 좋은 날'),
('2024-05-16', 'moving', 86, '손없는날 - 이사하기 좋은 날'),
('2024-06-02', 'moving', 94, '손없는날 - 이사하기 매우 좋은 날'),
('2024-06-14', 'moving', 88, '손없는날 - 이사하기 좋은 날'),
('2024-07-01', 'moving', 92, '손없는날 - 이사하기 매우 좋은 날'),
('2024-07-13', 'moving', 87, '손없는날 - 이사하기 좋은 날'),
('2024-08-04', 'moving', 90, '손없는날 - 이사하기 매우 좋은 날'),
('2024-08-16', 'moving', 85, '손없는날 - 이사하기 좋은 날'),
('2024-09-07', 'moving', 93, '손없는날 - 이사하기 매우 좋은 날'),
('2024-09-19', 'moving', 89, '손없는날 - 이사하기 좋은 날'),
('2024-10-06', 'moving', 91, '손없는날 - 이사하기 매우 좋은 날'),
('2024-10-18', 'moving', 86, '손없는날 - 이사하기 좋은 날'),
('2024-11-04', 'moving', 94, '손없는날 - 이사하기 매우 좋은 날'),
('2024-11-16', 'moving', 88, '손없는날 - 이사하기 좋은 날'),
('2024-12-05', 'moving', 92, '손없는날 - 이사하기 매우 좋은 날'),
('2024-12-17', 'moving', 87, '손없는날 - 이사하기 좋은 날');

-- 2025년 손없는날 데이터도 추가
INSERT INTO auspicious_days (date, type, score, description) VALUES
('2025-01-05', 'moving', 89, '손없는날 - 이사하기 매우 좋은 날'),
('2025-01-17', 'moving', 84, '손없는날 - 이사하기 좋은 날'),
('2025-02-01', 'moving', 91, '손없는날 - 이사하기 매우 좋은 날'),
('2025-02-13', 'moving', 87, '손없는날 - 이사하기 좋은 날'),
('2025-03-07', 'moving', 93, '손없는날 - 이사하기 매우 좋은 날'),
('2025-03-19', 'moving', 88, '손없는날 - 이사하기 좋은 날'),
('2025-04-03', 'moving', 90, '손없는날 - 이사하기 매우 좋은 날'),
('2025-04-15', 'moving', 85, '손없는날 - 이사하기 좋은 날'),
('2025-05-02', 'moving', 92, '손없는날 - 이사하기 매우 좋은 날'),
('2025-05-14', 'moving', 89, '손없는날 - 이사하기 좋은 날'),
('2025-06-05', 'moving', 94, '손없는날 - 이사하기 매우 좋은 날'),
('2025-06-17', 'moving', 86, '손없는날 - 이사하기 좋은 날'),
('2025-07-04', 'moving', 91, '손없는날 - 이사하기 매우 좋은 날'),
('2025-07-16', 'moving', 88, '손없는날 - 이사하기 좋은 날'),
('2025-08-02', 'moving', 93, '손없는날 - 이사하기 매우 좋은 날'),
('2025-08-14', 'moving', 87, '손없는날 - 이사하기 좋은 날'),
('2025-09-05', 'moving', 90, '손없는날 - 이사하기 매우 좋은 날'),
('2025-09-17', 'moving', 85, '손없는날 - 이사하기 좋은 날'),
('2025-10-04', 'moving', 92, '손없는날 - 이사하기 매우 좋은 날'),
('2025-10-16', 'moving', 89, '손없는날 - 이사하기 좋은 날'),
('2025-11-02', 'moving', 91, '손없는날 - 이사하기 매우 좋은 날'),
('2025-11-14', 'moving', 86, '손없는날 - 이사하기 좋은 날'),
('2025-12-03', 'moving', 93, '손없는날 - 이사하기 매우 좋은 날'),
('2025-12-15', 'moving', 88, '손없는날 - 이사하기 좋은 날');