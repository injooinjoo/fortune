-- 투자 종목(티커) 테이블 생성
-- 코인, 주식, ETF, 원자재, 부동산 등 투자 종목 정보 저장

CREATE TABLE IF NOT EXISTS tickers (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  symbol VARCHAR(20) NOT NULL,
  name VARCHAR(255) NOT NULL,
  name_en VARCHAR(255),
  category VARCHAR(50) NOT NULL, -- crypto, krStock, usStock, etf, commodity, realEstate
  exchange VARCHAR(50), -- BINANCE, NASDAQ, NYSE, KRX, KOSDAQ 등
  description TEXT,
  logo_url TEXT,
  is_popular BOOLEAN DEFAULT false,
  display_order INT DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  metadata JSONB DEFAULT '{}',
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),

  UNIQUE(symbol, category)
);

-- 인덱스 생성
CREATE INDEX idx_tickers_category ON tickers(category);
CREATE INDEX idx_tickers_symbol ON tickers(symbol);
CREATE INDEX idx_tickers_is_popular ON tickers(is_popular) WHERE is_popular = true;
CREATE INDEX idx_tickers_is_active ON tickers(is_active) WHERE is_active = true;
CREATE INDEX idx_tickers_display_order ON tickers(category, display_order);

-- 검색을 위한 GIN 인덱스 (한글 + 영문 검색)
CREATE INDEX idx_tickers_name_search ON tickers USING gin(to_tsvector('simple', name || ' ' || COALESCE(name_en, '') || ' ' || symbol));

-- RLS 활성화 (읽기 전용 공개)
ALTER TABLE tickers ENABLE ROW LEVEL SECURITY;

-- 모든 사용자가 읽기 가능
CREATE POLICY "tickers_select_policy" ON tickers
  FOR SELECT USING (is_active = true);

-- 서비스 역할만 수정 가능
CREATE POLICY "tickers_admin_policy" ON tickers
  FOR ALL USING (auth.role() = 'service_role');

-- updated_at 자동 업데이트 트리거
CREATE OR REPLACE FUNCTION update_tickers_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER tickers_updated_at_trigger
  BEFORE UPDATE ON tickers
  FOR EACH ROW
  EXECUTE FUNCTION update_tickers_updated_at();

-- 코멘트 추가
COMMENT ON TABLE tickers IS '투자 종목 마스터 테이블 (코인, 주식, ETF 등)';
COMMENT ON COLUMN tickers.category IS 'crypto: 암호화폐, krStock: 국내주식, usStock: 해외주식, etf: ETF, commodity: 원자재, realEstate: 부동산';
COMMENT ON COLUMN tickers.is_popular IS '인기 종목 여부 (메인 화면 노출)';
COMMENT ON COLUMN tickers.display_order IS '카테고리 내 정렬 순서';
