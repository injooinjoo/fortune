-- 인기 지역 테이블 생성
CREATE TABLE popular_regions (
  id SERIAL PRIMARY KEY,
  display_name VARCHAR(100) NOT NULL,
  sido VARCHAR(50) NOT NULL,
  sigungu VARCHAR(50),
  is_featured BOOLEAN DEFAULT false,
  order_priority INTEGER DEFAULT 0,
  usage_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 인덱스 생성
CREATE INDEX idx_popular_regions_priority ON popular_regions(order_priority);
CREATE INDEX idx_popular_regions_featured ON popular_regions(is_featured);
CREATE INDEX idx_popular_regions_usage ON popular_regions(usage_count DESC);

-- 인기 지역 데이터 삽입
INSERT INTO popular_regions (display_name, sido, sigungu, is_featured, order_priority) VALUES
-- 서울 주요 구 (featured)
('서울시 강남구', '서울특별시', '강남구', true, 1),
('서울시 서초구', '서울특별시', '서초구', true, 2),
('서울시 송파구', '서울특별시', '송파구', true, 3),
('서울시 강서구', '서울특별시', '강서구', true, 4),
('서울시 마포구', '서울특별시', '마포구', true, 5),

-- 서울 기타 구
('서울시 성동구', '서울특별시', '성동구', false, 10),
('서울시 용산구', '서울특별시', '용산구', false, 11),
('서울시 종로구', '서울특별시', '종로구', false, 12),
('서울시 중구', '서울특별시', '중구', false, 13),
('서울시 영등포구', '서울특별시', '영등포구', false, 14),
('서울시 관악구', '서울특별시', '관악구', false, 15),
('서울시 서대문구', '서울특별시', '서대문구', false, 16),
('서울시 동작구', '서울특별시', '동작구', false, 17),
('서울시 은평구', '서울특별시', '은평구', false, 18),
('서울시 성북구', '서울특별시', '성북구', false, 19),
('서울시 강북구', '서울특별시', '강북구', false, 20),
('서울시 도봉구', '서울특별시', '도봉구', false, 21),
('서울시 노원구', '서울특별시', '노원구', false, 22),
('서울시 중랑구', '서울특별시', '중랑구', false, 23),
('서울시 동대문구', '서울특별시', '동대문구', false, 24),
('서울시 광진구', '서울특별시', '광진구', false, 25),
('서울시 양천구', '서울특별시', '양천구', false, 26),
('서울시 구로구', '서울특별시', '구로구', false, 27),
('서울시 금천구', '서울특별시', '금천구', false, 28),

-- 경기도 인기 지역
('경기도 성남시', '경기도', '성남시', true, 30),
('경기도 수원시', '경기도', '수원시', true, 31),
('경기도 안양시', '경기도', '안양시', true, 32),
('경기도 부천시', '경기도', '부천시', true, 33),
('경기도 고양시', '경기도', '고양시', true, 34),
('경기도 용인시', '경기도', '용인시', false, 35),
('경기도 화성시', '경기도', '화성시', false, 36),
('경기도 평택시', '경기도', '평택시', false, 37),
('경기도 의정부시', '경기도', '의정부시', false, 38),
('경기도 시흥시', '경기도', '시흥시', false, 39),
('경기도 파주시', '경기도', '파주시', false, 40),
('경기도 광명시', '경기도', '광명시', false, 41),
('경기도 김포시', '경기도', '김포시', false, 42),
('경기도 군포시', '경기도', '군포시', false, 43),
('경기도 하남시', '경기도', '하남시', false, 44),

-- 인천 주요 구
('인천시 연수구', '인천광역시', '연수구', true, 50),
('인천시 남동구', '인천광역시', '남동구', true, 51),
('인천시 부평구', '인천광역시', '부평구', false, 52),
('인천시 서구', '인천광역시', '서구', false, 53),
('인천시 중구', '인천광역시', '중구', false, 54),

-- 부산 주요 구
('부산시 해운대구', '부산광역시', '해운대구', true, 60),
('부산시 부산진구', '부산광역시', '부산진구', true, 61),
('부산시 서면구', '부산광역시', '부산진구', false, 62),
('부산시 남구', '부산광역시', '남구', false, 63),
('부산시 동래구', '부산광역시', '동래구', false, 64),

-- 대구 주요 구
('대구시 수성구', '대구광역시', '수성구', true, 70),
('대구시 달서구', '대구광역시', '달서구', false, 71),
('대구시 북구', '대구광역시', '북구', false, 72),

-- 광주 주요 구
('광주시 서구', '광주광역시', '서구', false, 80),
('광주시 남구', '광주광역시', '남구', false, 81),

-- 대전 주요 구
('대전시 유성구', '대전광역시', '유성구', false, 90),
('대전시 서구', '대전광역시', '서구', false, 91),

-- 울산 주요 구
('울산시 남구', '울산광역시', '남구', false, 100),
('울산시 동구', '울산광역시', '동구', false, 101),

-- 세종시
('세종시', '세종특별자치시', null, false, 110),

-- 기타 (검색용)
('기타 지역', null, null, false, 999);

-- RLS 정책 설정
ALTER TABLE popular_regions ENABLE ROW LEVEL SECURITY;

-- 모든 사용자가 읽을 수 있도록 허용
CREATE POLICY "Popular regions are publicly readable" ON popular_regions
  FOR SELECT USING (true);

-- 업데이트 트리거 설정
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_popular_regions_updated_at 
  BEFORE UPDATE ON popular_regions 
  FOR EACH ROW 
  EXECUTE FUNCTION update_updated_at_column();