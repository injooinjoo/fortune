-- 초기 티커 데이터 삽입

-- 암호화폐 (crypto)
INSERT INTO tickers (symbol, name, name_en, category, exchange, is_popular, display_order) VALUES
('BTC', '비트코인', 'Bitcoin', 'crypto', 'BINANCE', true, 1),
('ETH', '이더리움', 'Ethereum', 'crypto', 'BINANCE', true, 2),
('XRP', '리플', 'Ripple', 'crypto', 'BINANCE', true, 3),
('SOL', '솔라나', 'Solana', 'crypto', 'BINANCE', true, 4),
('DOGE', '도지코인', 'Dogecoin', 'crypto', 'BINANCE', true, 5),
('ADA', '에이다', 'Cardano', 'crypto', 'BINANCE', false, 6),
('AVAX', '아발란체', 'Avalanche', 'crypto', 'BINANCE', false, 7),
('DOT', '폴카닷', 'Polkadot', 'crypto', 'BINANCE', false, 8),
('MATIC', '폴리곤', 'Polygon', 'crypto', 'BINANCE', false, 9),
('LINK', '체인링크', 'Chainlink', 'crypto', 'BINANCE', false, 10),
('ATOM', '코스모스', 'Cosmos', 'crypto', 'BINANCE', false, 11),
('UNI', '유니스왑', 'Uniswap', 'crypto', 'BINANCE', false, 12),
('LTC', '라이트코인', 'Litecoin', 'crypto', 'BINANCE', false, 13),
('BCH', '비트코인캐시', 'Bitcoin Cash', 'crypto', 'BINANCE', false, 14),
('NEAR', '니어프로토콜', 'NEAR Protocol', 'crypto', 'BINANCE', false, 15),
('APT', '앱토스', 'Aptos', 'crypto', 'BINANCE', false, 16),
('ARB', '아비트럼', 'Arbitrum', 'crypto', 'BINANCE', false, 17),
('OP', '옵티미즘', 'Optimism', 'crypto', 'BINANCE', false, 18),
('SHIB', '시바이누', 'Shiba Inu', 'crypto', 'BINANCE', false, 19),
('PEPE', '페페', 'Pepe', 'crypto', 'BINANCE', false, 20)
ON CONFLICT (symbol, category) DO UPDATE SET
  name = EXCLUDED.name,
  name_en = EXCLUDED.name_en,
  exchange = EXCLUDED.exchange,
  is_popular = EXCLUDED.is_popular,
  display_order = EXCLUDED.display_order;

-- 국내주식 (krStock)
INSERT INTO tickers (symbol, name, name_en, category, exchange, is_popular, display_order) VALUES
('005930', '삼성전자', 'Samsung Electronics', 'krStock', 'KRX', true, 1),
('000660', 'SK하이닉스', 'SK Hynix', 'krStock', 'KRX', true, 2),
('035420', '네이버', 'NAVER', 'krStock', 'KRX', true, 3),
('035720', '카카오', 'Kakao', 'krStock', 'KRX', true, 4),
('005380', '현대차', 'Hyundai Motor', 'krStock', 'KRX', true, 5),
('051910', 'LG화학', 'LG Chem', 'krStock', 'KRX', false, 6),
('006400', '삼성SDI', 'Samsung SDI', 'krStock', 'KRX', false, 7),
('003670', '포스코홀딩스', 'POSCO Holdings', 'krStock', 'KRX', false, 8),
('105560', 'KB금융', 'KB Financial', 'krStock', 'KRX', false, 9),
('055550', '신한지주', 'Shinhan Financial', 'krStock', 'KRX', false, 10),
('000270', '기아', 'Kia', 'krStock', 'KRX', false, 11),
('068270', '셀트리온', 'Celltrion', 'krStock', 'KRX', false, 12),
('207940', '삼성바이오로직스', 'Samsung Biologics', 'krStock', 'KRX', false, 13),
('373220', 'LG에너지솔루션', 'LG Energy Solution', 'krStock', 'KRX', false, 14),
('012330', '현대모비스', 'Hyundai Mobis', 'krStock', 'KRX', false, 15),
('066570', 'LG전자', 'LG Electronics', 'krStock', 'KRX', false, 16),
('028260', '삼성물산', 'Samsung C&T', 'krStock', 'KRX', false, 17),
('017670', 'SK텔레콤', 'SK Telecom', 'krStock', 'KRX', false, 18),
('030200', 'KT', 'KT', 'krStock', 'KRX', false, 19),
('096770', 'SK이노베이션', 'SK Innovation', 'krStock', 'KRX', false, 20),
('034730', 'SK', 'SK', 'krStock', 'KRX', false, 21),
('018260', '삼성에스디에스', 'Samsung SDS', 'krStock', 'KRX', false, 22),
('086790', '하나금융지주', 'Hana Financial', 'krStock', 'KRX', false, 23),
('032830', '삼성생명', 'Samsung Life', 'krStock', 'KRX', false, 24),
('010130', '고려아연', 'Korea Zinc', 'krStock', 'KRX', false, 25)
ON CONFLICT (symbol, category) DO UPDATE SET
  name = EXCLUDED.name,
  name_en = EXCLUDED.name_en,
  exchange = EXCLUDED.exchange,
  is_popular = EXCLUDED.is_popular,
  display_order = EXCLUDED.display_order;

-- 해외주식 (usStock)
INSERT INTO tickers (symbol, name, name_en, category, exchange, is_popular, display_order) VALUES
('AAPL', '애플', 'Apple', 'usStock', 'NASDAQ', true, 1),
('MSFT', '마이크로소프트', 'Microsoft', 'usStock', 'NASDAQ', true, 2),
('GOOGL', '알파벳(구글)', 'Alphabet (Google)', 'usStock', 'NASDAQ', true, 3),
('AMZN', '아마존', 'Amazon', 'usStock', 'NASDAQ', true, 4),
('NVDA', '엔비디아', 'NVIDIA', 'usStock', 'NASDAQ', true, 5),
('TSLA', '테슬라', 'Tesla', 'usStock', 'NASDAQ', true, 6),
('META', '메타', 'Meta', 'usStock', 'NASDAQ', false, 7),
('TSM', 'TSMC', 'TSMC', 'usStock', 'NYSE', false, 8),
('V', '비자', 'Visa', 'usStock', 'NYSE', false, 9),
('JPM', 'JP모건', 'JPMorgan Chase', 'usStock', 'NYSE', false, 10),
('JNJ', '존슨앤존슨', 'Johnson & Johnson', 'usStock', 'NYSE', false, 11),
('UNH', '유나이티드헬스', 'UnitedHealth', 'usStock', 'NYSE', false, 12),
('HD', '홈디포', 'Home Depot', 'usStock', 'NYSE', false, 13),
('PG', 'P&G', 'Procter & Gamble', 'usStock', 'NYSE', false, 14),
('MA', '마스터카드', 'Mastercard', 'usStock', 'NYSE', false, 15),
('DIS', '디즈니', 'Disney', 'usStock', 'NYSE', false, 16),
('NFLX', '넷플릭스', 'Netflix', 'usStock', 'NASDAQ', false, 17),
('PYPL', '페이팔', 'PayPal', 'usStock', 'NASDAQ', false, 18),
('INTC', '인텔', 'Intel', 'usStock', 'NASDAQ', false, 19),
('AMD', 'AMD', 'AMD', 'usStock', 'NASDAQ', false, 20),
('CRM', '세일즈포스', 'Salesforce', 'usStock', 'NYSE', false, 21),
('ORCL', '오라클', 'Oracle', 'usStock', 'NYSE', false, 22),
('CSCO', '시스코', 'Cisco', 'usStock', 'NASDAQ', false, 23),
('ADBE', '어도비', 'Adobe', 'usStock', 'NASDAQ', false, 24),
('BA', '보잉', 'Boeing', 'usStock', 'NYSE', false, 25)
ON CONFLICT (symbol, category) DO UPDATE SET
  name = EXCLUDED.name,
  name_en = EXCLUDED.name_en,
  exchange = EXCLUDED.exchange,
  is_popular = EXCLUDED.is_popular,
  display_order = EXCLUDED.display_order;

-- ETF
INSERT INTO tickers (symbol, name, name_en, category, exchange, is_popular, display_order) VALUES
('SPY', 'S&P 500 ETF', 'SPDR S&P 500 ETF', 'etf', 'NYSE', true, 1),
('QQQ', '나스닥 100 ETF', 'Invesco QQQ', 'etf', 'NASDAQ', true, 2),
('IWM', '러셀 2000 ETF', 'iShares Russell 2000', 'etf', 'NYSE', false, 3),
('VTI', '미국 전체 시장 ETF', 'Vanguard Total Stock', 'etf', 'NYSE', false, 4),
('VOO', '뱅가드 S&P 500', 'Vanguard S&P 500', 'etf', 'NYSE', false, 5),
('ARKK', 'ARK 혁신 ETF', 'ARK Innovation', 'etf', 'NYSE', false, 6),
('SOXX', '반도체 ETF', 'iShares Semiconductor', 'etf', 'NASDAQ', true, 7),
('XLF', '금융 섹터 ETF', 'Financial Select Sector', 'etf', 'NYSE', false, 8),
('XLE', '에너지 섹터 ETF', 'Energy Select Sector', 'etf', 'NYSE', false, 9),
('VNQ', '부동산 ETF', 'Vanguard Real Estate', 'etf', 'NYSE', false, 10),
('069500', 'KODEX 200', 'KODEX 200', 'etf', 'KRX', true, 11),
('102110', 'TIGER 200', 'TIGER 200', 'etf', 'KRX', false, 12),
('114800', 'KODEX 인버스', 'KODEX Inverse', 'etf', 'KRX', false, 13),
('122630', 'KODEX 레버리지', 'KODEX Leverage', 'etf', 'KRX', false, 14),
('133690', 'TIGER 미국나스닥100', 'TIGER NASDAQ 100', 'etf', 'KRX', true, 15),
('143850', 'TIGER 미국S&P500', 'TIGER S&P 500', 'etf', 'KRX', false, 16),
('305720', 'KODEX 2차전지산업', 'KODEX Secondary Battery', 'etf', 'KRX', false, 17),
('364980', 'TIGER 미국테크TOP10', 'TIGER US Tech TOP10', 'etf', 'KRX', false, 18),
('381180', 'TIGER 미국필라델피아반도체', 'TIGER Philadelphia Semi', 'etf', 'KRX', false, 19),
('446720', 'SOL 미국배당다우존스', 'SOL US Dividend Dow Jones', 'etf', 'KRX', false, 20)
ON CONFLICT (symbol, category) DO UPDATE SET
  name = EXCLUDED.name,
  name_en = EXCLUDED.name_en,
  exchange = EXCLUDED.exchange,
  is_popular = EXCLUDED.is_popular,
  display_order = EXCLUDED.display_order;

-- 원자재 (commodity)
INSERT INTO tickers (symbol, name, name_en, category, exchange, is_popular, display_order) VALUES
('GC=F', '금', 'Gold Futures', 'commodity', 'COMEX', true, 1),
('SI=F', '은', 'Silver Futures', 'commodity', 'COMEX', true, 2),
('CL=F', '원유(WTI)', 'Crude Oil WTI', 'commodity', 'NYMEX', true, 3),
('NG=F', '천연가스', 'Natural Gas', 'commodity', 'NYMEX', false, 4),
('HG=F', '구리', 'Copper Futures', 'commodity', 'COMEX', false, 5)
ON CONFLICT (symbol, category) DO UPDATE SET
  name = EXCLUDED.name,
  name_en = EXCLUDED.name_en,
  exchange = EXCLUDED.exchange,
  is_popular = EXCLUDED.is_popular,
  display_order = EXCLUDED.display_order;

-- 부동산 (realEstate)
INSERT INTO tickers (symbol, name, name_en, category, exchange, is_popular, display_order) VALUES
('SEOUL-APT', '서울 아파트', 'Seoul Apartment', 'realEstate', NULL, true, 1),
('METRO-APT', '수도권 아파트', 'Metropolitan Apartment', 'realEstate', NULL, true, 2),
('VNQ', '미국 리츠 ETF', 'Vanguard Real Estate ETF', 'realEstate', 'NYSE', false, 3),
('OFFICE', '오피스/상업시설', 'Office/Commercial', 'realEstate', NULL, false, 4),
('GLOBAL-REIT', '글로벌 리츠', 'Global REITs', 'realEstate', NULL, false, 5)
ON CONFLICT (symbol, category) DO UPDATE SET
  name = EXCLUDED.name,
  name_en = EXCLUDED.name_en,
  exchange = EXCLUDED.exchange,
  is_popular = EXCLUDED.is_popular,
  display_order = EXCLUDED.display_order;
