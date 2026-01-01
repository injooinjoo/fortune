import '../../features/fortune/domain/models/sports_schedule.dart';

/// 한국 프로 스포츠 팀 데이터
/// KBO 10팀, K리그1 12팀, KBL 10팀, V리그 남자 7팀 + 여자 7팀, LCK 10팀

// ============================================================
// KBO (한국프로야구) - 10개 팀
// ============================================================
const List<SportsTeam> kboTeams = [
  SportsTeam(
    id: 'kbo_doosan',
    name: '두산 베어스',
    shortName: '두산',
    sport: SportType.baseball,
    league: 'KBO',
    city: '서울',
    primaryColor: '#131230',
  ),
  SportsTeam(
    id: 'kbo_lg',
    name: 'LG 트윈스',
    shortName: 'LG',
    sport: SportType.baseball,
    league: 'KBO',
    city: '서울',
    primaryColor: '#C30452',
  ),
  SportsTeam(
    id: 'kbo_kia',
    name: 'KIA 타이거즈',
    shortName: 'KIA',
    sport: SportType.baseball,
    league: 'KBO',
    city: '광주',
    primaryColor: '#EA0029',
  ),
  SportsTeam(
    id: 'kbo_samsung',
    name: '삼성 라이온즈',
    shortName: '삼성',
    sport: SportType.baseball,
    league: 'KBO',
    city: '대구',
    primaryColor: '#074CA1',
  ),
  SportsTeam(
    id: 'kbo_nc',
    name: 'NC 다이노스',
    shortName: 'NC',
    sport: SportType.baseball,
    league: 'KBO',
    city: '창원',
    primaryColor: '#315288',
  ),
  SportsTeam(
    id: 'kbo_ssg',
    name: 'SSG 랜더스',
    shortName: 'SSG',
    sport: SportType.baseball,
    league: 'KBO',
    city: '인천',
    primaryColor: '#CE0E2D',
  ),
  SportsTeam(
    id: 'kbo_kt',
    name: 'KT 위즈',
    shortName: 'KT',
    sport: SportType.baseball,
    league: 'KBO',
    city: '수원',
    primaryColor: '#000000',
  ),
  SportsTeam(
    id: 'kbo_hanwha',
    name: '한화 이글스',
    shortName: '한화',
    sport: SportType.baseball,
    league: 'KBO',
    city: '대전',
    primaryColor: '#FF6600',
  ),
  SportsTeam(
    id: 'kbo_lotte',
    name: '롯데 자이언츠',
    shortName: '롯데',
    sport: SportType.baseball,
    league: 'KBO',
    city: '부산',
    primaryColor: '#041E42',
  ),
  SportsTeam(
    id: 'kbo_kiwoom',
    name: '키움 히어로즈',
    shortName: '키움',
    sport: SportType.baseball,
    league: 'KBO',
    city: '서울',
    primaryColor: '#570514',
  ),
];

// ============================================================
// K리그1 (한국프로축구) - 12개 팀
// ============================================================
const List<SportsTeam> kleagueTeams = [
  SportsTeam(
    id: 'kleague_jeonbuk',
    name: '전북 현대 모터스',
    shortName: '전북',
    sport: SportType.soccer,
    league: 'K리그1',
    city: '전주',
    primaryColor: '#006241',
  ),
  SportsTeam(
    id: 'kleague_ulsan',
    name: '울산 HD FC',
    shortName: '울산',
    sport: SportType.soccer,
    league: 'K리그1',
    city: '울산',
    primaryColor: '#004A98',
  ),
  SportsTeam(
    id: 'kleague_pohang',
    name: '포항 스틸러스',
    shortName: '포항',
    sport: SportType.soccer,
    league: 'K리그1',
    city: '포항',
    primaryColor: '#D42027',
  ),
  SportsTeam(
    id: 'kleague_seoul',
    name: 'FC 서울',
    shortName: '서울',
    sport: SportType.soccer,
    league: 'K리그1',
    city: '서울',
    primaryColor: '#B20838',
  ),
  SportsTeam(
    id: 'kleague_suwon',
    name: '수원 삼성 블루윙즈',
    shortName: '수원',
    sport: SportType.soccer,
    league: 'K리그1',
    city: '수원',
    primaryColor: '#0050A0',
  ),
  SportsTeam(
    id: 'kleague_incheon',
    name: '인천 유나이티드',
    shortName: '인천',
    sport: SportType.soccer,
    league: 'K리그1',
    city: '인천',
    primaryColor: '#004B87',
  ),
  SportsTeam(
    id: 'kleague_daegu',
    name: '대구 FC',
    shortName: '대구',
    sport: SportType.soccer,
    league: 'K리그1',
    city: '대구',
    primaryColor: '#0067B1',
  ),
  SportsTeam(
    id: 'kleague_gangwon',
    name: '강원 FC',
    shortName: '강원',
    sport: SportType.soccer,
    league: 'K리그1',
    city: '춘천',
    primaryColor: '#F15A22',
  ),
  SportsTeam(
    id: 'kleague_jeju',
    name: '제주 유나이티드',
    shortName: '제주',
    sport: SportType.soccer,
    league: 'K리그1',
    city: '서귀포',
    primaryColor: '#FF6600',
  ),
  SportsTeam(
    id: 'kleague_daejeon',
    name: '대전 시티즌',
    shortName: '대전',
    sport: SportType.soccer,
    league: 'K리그1',
    city: '대전',
    primaryColor: '#5D2D8E',
  ),
  SportsTeam(
    id: 'kleague_gwangju',
    name: '광주 FC',
    shortName: '광주',
    sport: SportType.soccer,
    league: 'K리그1',
    city: '광주',
    primaryColor: '#FFCD00',
  ),
  SportsTeam(
    id: 'kleague_suwonfc',
    name: '수원 FC',
    shortName: '수원FC',
    sport: SportType.soccer,
    league: 'K리그1',
    city: '수원',
    primaryColor: '#1A1A6C',
  ),
];

// ============================================================
// KBL (한국프로농구) - 10개 팀
// ============================================================
const List<SportsTeam> kblTeams = [
  SportsTeam(
    id: 'kbl_seoul_sk',
    name: '서울 SK 나이츠',
    shortName: 'SK',
    sport: SportType.basketball,
    league: 'KBL',
    city: '서울',
    primaryColor: '#ED1C24',
  ),
  SportsTeam(
    id: 'kbl_seoul_samsung',
    name: '서울 삼성 썬더스',
    shortName: '삼성',
    sport: SportType.basketball,
    league: 'KBL',
    city: '서울',
    primaryColor: '#1428A0',
  ),
  SportsTeam(
    id: 'kbl_anyang_kt',
    name: '안양 KT 소닉붐',
    shortName: 'KT',
    sport: SportType.basketball,
    league: 'KBL',
    city: '안양',
    primaryColor: '#FF0000',
  ),
  SportsTeam(
    id: 'kbl_ulsan_hyundai',
    name: '울산 현대모비스 피버스',
    shortName: '현대모비스',
    sport: SportType.basketball,
    league: 'KBL',
    city: '울산',
    primaryColor: '#002F6C',
  ),
  SportsTeam(
    id: 'kbl_busan_kg',
    name: '부산 KCC 이지스',
    shortName: 'KCC',
    sport: SportType.basketball,
    league: 'KBL',
    city: '부산',
    primaryColor: '#00205B',
  ),
  SportsTeam(
    id: 'kbl_goyang_orion',
    name: '고양 오리온 오리온스',
    shortName: '오리온',
    sport: SportType.basketball,
    league: 'KBL',
    city: '고양',
    primaryColor: '#E31837',
  ),
  SportsTeam(
    id: 'kbl_wonju_db',
    name: '원주 DB 프로미',
    shortName: 'DB',
    sport: SportType.basketball,
    league: 'KBL',
    city: '원주',
    primaryColor: '#003DA5',
  ),
  SportsTeam(
    id: 'kbl_changwon_lg',
    name: '창원 LG 세이커스',
    shortName: 'LG',
    sport: SportType.basketball,
    league: 'KBL',
    city: '창원',
    primaryColor: '#A50034',
  ),
  SportsTeam(
    id: 'kbl_suwon_kt',
    name: '수원 KT 소닉붐',
    shortName: 'KT',
    sport: SportType.basketball,
    league: 'KBL',
    city: '수원',
    primaryColor: '#FF0000',
  ),
  SportsTeam(
    id: 'kbl_daegu_kogas',
    name: '대구 한국가스공사 페가수스',
    shortName: '가스공사',
    sport: SportType.basketball,
    league: 'KBL',
    city: '대구',
    primaryColor: '#0046AD',
  ),
];

// ============================================================
// V리그 (한국프로배구) - 남자 7팀 + 여자 7팀
// ============================================================
const List<SportsTeam> vleagueMenTeams = [
  SportsTeam(
    id: 'vleague_incheon_korean_air',
    name: '인천 대한항공 점보스',
    shortName: '대한항공',
    sport: SportType.volleyball,
    league: 'V리그 남자',
    city: '인천',
    primaryColor: '#00338D',
  ),
  SportsTeam(
    id: 'vleague_suwon_kepco',
    name: '수원 한국전력 빅스톰',
    shortName: '한국전력',
    sport: SportType.volleyball,
    league: 'V리그 남자',
    city: '수원',
    primaryColor: '#E31B23',
  ),
  SportsTeam(
    id: 'vleague_ansan_ok',
    name: '안산 OK금융그룹 읏맨',
    shortName: 'OK금융',
    sport: SportType.volleyball,
    league: 'V리그 남자',
    city: '안산',
    primaryColor: '#FF6B00',
  ),
  SportsTeam(
    id: 'vleague_seoul_woori',
    name: '서울 우리카드 우리WON',
    shortName: '우리카드',
    sport: SportType.volleyball,
    league: 'V리그 남자',
    city: '서울',
    primaryColor: '#0033A0',
  ),
  SportsTeam(
    id: 'vleague_daejeon_samsung',
    name: '대전 삼성화재 블루팡스',
    shortName: '삼성화재',
    sport: SportType.volleyball,
    league: 'V리그 남자',
    city: '대전',
    primaryColor: '#1428A0',
  ),
  SportsTeam(
    id: 'vleague_cheonan_hyundai',
    name: '천안 현대캐피탈 스카이워커스',
    shortName: '현대캐피탈',
    sport: SportType.volleyball,
    league: 'V리그 남자',
    city: '천안',
    primaryColor: '#0067B1',
  ),
  SportsTeam(
    id: 'vleague_uijeongbu_kb',
    name: '의정부 KB손해보험 스타즈',
    shortName: 'KB손보',
    sport: SportType.volleyball,
    league: 'V리그 남자',
    city: '의정부',
    primaryColor: '#FFB81C',
  ),
];

const List<SportsTeam> vleagueWomenTeams = [
  SportsTeam(
    id: 'vleague_w_incheon_heungkuk',
    name: '인천 흥국생명 핑크스파이더스',
    shortName: '흥국생명',
    sport: SportType.volleyball,
    league: 'V리그 여자',
    city: '인천',
    primaryColor: '#E11383',
  ),
  SportsTeam(
    id: 'vleague_w_suwon_hyundai',
    name: '수원 현대건설 힐스테이트',
    shortName: '현대건설',
    sport: SportType.volleyball,
    league: 'V리그 여자',
    city: '수원',
    primaryColor: '#00205B',
  ),
  SportsTeam(
    id: 'vleague_w_daejeon_gs',
    name: '대전 정관장',
    shortName: '정관장',
    sport: SportType.volleyball,
    league: 'V리그 여자',
    city: '대전',
    primaryColor: '#C8102E',
  ),
  SportsTeam(
    id: 'vleague_w_hwaseong_ibk',
    name: '화성 IBK기업은행 알토스',
    shortName: 'IBK',
    sport: SportType.volleyball,
    league: 'V리그 여자',
    city: '화성',
    primaryColor: '#0046AD',
  ),
  SportsTeam(
    id: 'vleague_w_gimcheon_ks',
    name: '김천 한국도로공사 하이패스',
    shortName: '도로공사',
    sport: SportType.volleyball,
    league: 'V리그 여자',
    city: '김천',
    primaryColor: '#00A651',
  ),
  SportsTeam(
    id: 'vleague_w_gwangju_pepper',
    name: '광주 페퍼저축은행 AI 페퍼스',
    shortName: '페퍼',
    sport: SportType.volleyball,
    league: 'V리그 여자',
    city: '광주',
    primaryColor: '#E31B23',
  ),
  SportsTeam(
    id: 'vleague_w_seoul_hi',
    name: '서울 하이닉스 웨이브',
    shortName: '하이닉스',
    sport: SportType.volleyball,
    league: 'V리그 여자',
    city: '서울',
    primaryColor: '#FF6600',
  ),
];

// ============================================================
// LCK (롤 챔피언스 코리아) - 10개 팀
// ============================================================
const List<SportsTeam> lckTeams = [
  SportsTeam(
    id: 'lck_t1',
    name: 'T1',
    shortName: 'T1',
    sport: SportType.esports,
    league: 'LCK',
    city: '서울',
    primaryColor: '#E2012D',
  ),
  SportsTeam(
    id: 'lck_geng',
    name: 'Gen.G',
    shortName: 'GEN',
    sport: SportType.esports,
    league: 'LCK',
    city: '서울',
    primaryColor: '#AA8B2A',
  ),
  SportsTeam(
    id: 'lck_hle',
    name: 'Hanwha Life Esports',
    shortName: 'HLE',
    sport: SportType.esports,
    league: 'LCK',
    city: '서울',
    primaryColor: '#FF6600',
  ),
  SportsTeam(
    id: 'lck_dk',
    name: 'Dplus KIA',
    shortName: 'DK',
    sport: SportType.esports,
    league: 'LCK',
    city: '서울',
    primaryColor: '#0085CA',
  ),
  SportsTeam(
    id: 'lck_kt',
    name: 'KT Rolster',
    shortName: 'KT',
    sport: SportType.esports,
    league: 'LCK',
    city: '서울',
    primaryColor: '#FF0000',
  ),
  SportsTeam(
    id: 'lck_brion',
    name: 'OKSavingsBank BRION',
    shortName: 'BRO',
    sport: SportType.esports,
    league: 'LCK',
    city: '서울',
    primaryColor: '#009EE2',
  ),
  SportsTeam(
    id: 'lck_drx',
    name: 'DRX',
    shortName: 'DRX',
    sport: SportType.esports,
    league: 'LCK',
    city: '서울',
    primaryColor: '#5383E8',
  ),
  SportsTeam(
    id: 'lck_ns',
    name: 'Nongshim RedForce',
    shortName: 'NS',
    sport: SportType.esports,
    league: 'LCK',
    city: '서울',
    primaryColor: '#E31C23',
  ),
  SportsTeam(
    id: 'lck_fox',
    name: 'FearX',
    shortName: 'FOX',
    sport: SportType.esports,
    league: 'LCK',
    city: '서울',
    primaryColor: '#F8D12F',
  ),
];

// ============================================================
// MLB (메이저리그 야구) - 30개 팀
// ============================================================
const List<SportsTeam> mlbTeams = [
  // American League East
  SportsTeam(id: 'mlb_nyy', name: 'New York Yankees', shortName: '양키스', sport: SportType.baseball, league: 'MLB', city: 'New York', primaryColor: '#003087'),
  SportsTeam(id: 'mlb_bos', name: 'Boston Red Sox', shortName: '레드삭스', sport: SportType.baseball, league: 'MLB', city: 'Boston', primaryColor: '#BD3039'),
  SportsTeam(id: 'mlb_tor', name: 'Toronto Blue Jays', shortName: '블루제이스', sport: SportType.baseball, league: 'MLB', city: 'Toronto', primaryColor: '#134A8E'),
  SportsTeam(id: 'mlb_tb', name: 'Tampa Bay Rays', shortName: '레이스', sport: SportType.baseball, league: 'MLB', city: 'Tampa Bay', primaryColor: '#092C5C'),
  SportsTeam(id: 'mlb_bal', name: 'Baltimore Orioles', shortName: '오리올스', sport: SportType.baseball, league: 'MLB', city: 'Baltimore', primaryColor: '#DF4601'),
  // American League Central
  SportsTeam(id: 'mlb_cle', name: 'Cleveland Guardians', shortName: '가디언스', sport: SportType.baseball, league: 'MLB', city: 'Cleveland', primaryColor: '#00385D'),
  SportsTeam(id: 'mlb_min', name: 'Minnesota Twins', shortName: '트윈스', sport: SportType.baseball, league: 'MLB', city: 'Minnesota', primaryColor: '#002B5C'),
  SportsTeam(id: 'mlb_det', name: 'Detroit Tigers', shortName: '타이거스', sport: SportType.baseball, league: 'MLB', city: 'Detroit', primaryColor: '#0C2340'),
  SportsTeam(id: 'mlb_cws', name: 'Chicago White Sox', shortName: '화이트삭스', sport: SportType.baseball, league: 'MLB', city: 'Chicago', primaryColor: '#27251F'),
  SportsTeam(id: 'mlb_kc', name: 'Kansas City Royals', shortName: '로열스', sport: SportType.baseball, league: 'MLB', city: 'Kansas City', primaryColor: '#004687'),
  // American League West
  SportsTeam(id: 'mlb_hou', name: 'Houston Astros', shortName: '애스트로스', sport: SportType.baseball, league: 'MLB', city: 'Houston', primaryColor: '#002D62'),
  SportsTeam(id: 'mlb_tex', name: 'Texas Rangers', shortName: '레인저스', sport: SportType.baseball, league: 'MLB', city: 'Texas', primaryColor: '#003278'),
  SportsTeam(id: 'mlb_sea', name: 'Seattle Mariners', shortName: '매리너스', sport: SportType.baseball, league: 'MLB', city: 'Seattle', primaryColor: '#0C2C56'),
  SportsTeam(id: 'mlb_laa', name: 'Los Angeles Angels', shortName: '에인절스', sport: SportType.baseball, league: 'MLB', city: 'Los Angeles', primaryColor: '#BA0021'),
  SportsTeam(id: 'mlb_oak', name: 'Oakland Athletics', shortName: '애슬레틱스', sport: SportType.baseball, league: 'MLB', city: 'Oakland', primaryColor: '#003831'),
  // National League East
  SportsTeam(id: 'mlb_atl', name: 'Atlanta Braves', shortName: '브레이브스', sport: SportType.baseball, league: 'MLB', city: 'Atlanta', primaryColor: '#CE1141'),
  SportsTeam(id: 'mlb_nym', name: 'New York Mets', shortName: '메츠', sport: SportType.baseball, league: 'MLB', city: 'New York', primaryColor: '#002D72'),
  SportsTeam(id: 'mlb_phi', name: 'Philadelphia Phillies', shortName: '필리스', sport: SportType.baseball, league: 'MLB', city: 'Philadelphia', primaryColor: '#E81828'),
  SportsTeam(id: 'mlb_mia', name: 'Miami Marlins', shortName: '말린스', sport: SportType.baseball, league: 'MLB', city: 'Miami', primaryColor: '#00A3E0'),
  SportsTeam(id: 'mlb_wsh', name: 'Washington Nationals', shortName: '내셔널스', sport: SportType.baseball, league: 'MLB', city: 'Washington', primaryColor: '#AB0003'),
  // National League Central
  SportsTeam(id: 'mlb_mil', name: 'Milwaukee Brewers', shortName: '브루어스', sport: SportType.baseball, league: 'MLB', city: 'Milwaukee', primaryColor: '#12284B'),
  SportsTeam(id: 'mlb_chc', name: 'Chicago Cubs', shortName: '컵스', sport: SportType.baseball, league: 'MLB', city: 'Chicago', primaryColor: '#0E3386'),
  SportsTeam(id: 'mlb_cin', name: 'Cincinnati Reds', shortName: '레즈', sport: SportType.baseball, league: 'MLB', city: 'Cincinnati', primaryColor: '#C6011F'),
  SportsTeam(id: 'mlb_pit', name: 'Pittsburgh Pirates', shortName: '파이어리츠', sport: SportType.baseball, league: 'MLB', city: 'Pittsburgh', primaryColor: '#27251F'),
  SportsTeam(id: 'mlb_stl', name: 'St. Louis Cardinals', shortName: '카디널스', sport: SportType.baseball, league: 'MLB', city: 'St. Louis', primaryColor: '#C41E3A'),
  // National League West
  SportsTeam(id: 'mlb_lad', name: 'Los Angeles Dodgers', shortName: '다저스', sport: SportType.baseball, league: 'MLB', city: 'Los Angeles', primaryColor: '#005A9C'),
  SportsTeam(id: 'mlb_sd', name: 'San Diego Padres', shortName: '파드리스', sport: SportType.baseball, league: 'MLB', city: 'San Diego', primaryColor: '#2F241D'),
  SportsTeam(id: 'mlb_sf', name: 'San Francisco Giants', shortName: '자이언츠', sport: SportType.baseball, league: 'MLB', city: 'San Francisco', primaryColor: '#FD5A1E'),
  SportsTeam(id: 'mlb_ari', name: 'Arizona Diamondbacks', shortName: '다이아몬드백스', sport: SportType.baseball, league: 'MLB', city: 'Arizona', primaryColor: '#A71930'),
  SportsTeam(id: 'mlb_col', name: 'Colorado Rockies', shortName: '로키스', sport: SportType.baseball, league: 'MLB', city: 'Colorado', primaryColor: '#33006F'),
];

// ============================================================
// NBA (미국프로농구) - 30개 팀
// ============================================================
const List<SportsTeam> nbaTeams = [
  // Eastern Conference - Atlantic
  SportsTeam(id: 'nba_bos', name: 'Boston Celtics', shortName: '셀틱스', sport: SportType.basketball, league: 'NBA', city: 'Boston', primaryColor: '#007A33'),
  SportsTeam(id: 'nba_bkn', name: 'Brooklyn Nets', shortName: '네츠', sport: SportType.basketball, league: 'NBA', city: 'Brooklyn', primaryColor: '#000000'),
  SportsTeam(id: 'nba_nyk', name: 'New York Knicks', shortName: '닉스', sport: SportType.basketball, league: 'NBA', city: 'New York', primaryColor: '#006BB6'),
  SportsTeam(id: 'nba_phi', name: 'Philadelphia 76ers', shortName: '76ers', sport: SportType.basketball, league: 'NBA', city: 'Philadelphia', primaryColor: '#006BB6'),
  SportsTeam(id: 'nba_tor', name: 'Toronto Raptors', shortName: '랩터스', sport: SportType.basketball, league: 'NBA', city: 'Toronto', primaryColor: '#CE1141'),
  // Eastern Conference - Central
  SportsTeam(id: 'nba_chi', name: 'Chicago Bulls', shortName: '불스', sport: SportType.basketball, league: 'NBA', city: 'Chicago', primaryColor: '#CE1141'),
  SportsTeam(id: 'nba_cle', name: 'Cleveland Cavaliers', shortName: '캐벌리어스', sport: SportType.basketball, league: 'NBA', city: 'Cleveland', primaryColor: '#860038'),
  SportsTeam(id: 'nba_det', name: 'Detroit Pistons', shortName: '피스톤즈', sport: SportType.basketball, league: 'NBA', city: 'Detroit', primaryColor: '#C8102E'),
  SportsTeam(id: 'nba_ind', name: 'Indiana Pacers', shortName: '페이서스', sport: SportType.basketball, league: 'NBA', city: 'Indiana', primaryColor: '#002D62'),
  SportsTeam(id: 'nba_mil', name: 'Milwaukee Bucks', shortName: '벅스', sport: SportType.basketball, league: 'NBA', city: 'Milwaukee', primaryColor: '#00471B'),
  // Eastern Conference - Southeast
  SportsTeam(id: 'nba_atl', name: 'Atlanta Hawks', shortName: '호크스', sport: SportType.basketball, league: 'NBA', city: 'Atlanta', primaryColor: '#E03A3E'),
  SportsTeam(id: 'nba_cha', name: 'Charlotte Hornets', shortName: '호넷츠', sport: SportType.basketball, league: 'NBA', city: 'Charlotte', primaryColor: '#1D1160'),
  SportsTeam(id: 'nba_mia', name: 'Miami Heat', shortName: '히트', sport: SportType.basketball, league: 'NBA', city: 'Miami', primaryColor: '#98002E'),
  SportsTeam(id: 'nba_orl', name: 'Orlando Magic', shortName: '매직', sport: SportType.basketball, league: 'NBA', city: 'Orlando', primaryColor: '#0077C0'),
  SportsTeam(id: 'nba_was', name: 'Washington Wizards', shortName: '위저즈', sport: SportType.basketball, league: 'NBA', city: 'Washington', primaryColor: '#002B5C'),
  // Western Conference - Northwest
  SportsTeam(id: 'nba_den', name: 'Denver Nuggets', shortName: '너겟츠', sport: SportType.basketball, league: 'NBA', city: 'Denver', primaryColor: '#0E2240'),
  SportsTeam(id: 'nba_min', name: 'Minnesota Timberwolves', shortName: '팀버울브스', sport: SportType.basketball, league: 'NBA', city: 'Minnesota', primaryColor: '#0C2340'),
  SportsTeam(id: 'nba_okc', name: 'Oklahoma City Thunder', shortName: '썬더', sport: SportType.basketball, league: 'NBA', city: 'Oklahoma City', primaryColor: '#007AC1'),
  SportsTeam(id: 'nba_por', name: 'Portland Trail Blazers', shortName: '블레이저스', sport: SportType.basketball, league: 'NBA', city: 'Portland', primaryColor: '#E03A3E'),
  SportsTeam(id: 'nba_uta', name: 'Utah Jazz', shortName: '재즈', sport: SportType.basketball, league: 'NBA', city: 'Utah', primaryColor: '#002B5C'),
  // Western Conference - Pacific
  SportsTeam(id: 'nba_gsw', name: 'Golden State Warriors', shortName: '워리어스', sport: SportType.basketball, league: 'NBA', city: 'Golden State', primaryColor: '#1D428A'),
  SportsTeam(id: 'nba_lac', name: 'LA Clippers', shortName: '클리퍼스', sport: SportType.basketball, league: 'NBA', city: 'Los Angeles', primaryColor: '#C8102E'),
  SportsTeam(id: 'nba_lal', name: 'Los Angeles Lakers', shortName: '레이커스', sport: SportType.basketball, league: 'NBA', city: 'Los Angeles', primaryColor: '#552583'),
  SportsTeam(id: 'nba_phx', name: 'Phoenix Suns', shortName: '선즈', sport: SportType.basketball, league: 'NBA', city: 'Phoenix', primaryColor: '#1D1160'),
  SportsTeam(id: 'nba_sac', name: 'Sacramento Kings', shortName: '킹스', sport: SportType.basketball, league: 'NBA', city: 'Sacramento', primaryColor: '#5A2D81'),
  // Western Conference - Southwest
  SportsTeam(id: 'nba_dal', name: 'Dallas Mavericks', shortName: '매버릭스', sport: SportType.basketball, league: 'NBA', city: 'Dallas', primaryColor: '#00538C'),
  SportsTeam(id: 'nba_hou', name: 'Houston Rockets', shortName: '로켓츠', sport: SportType.basketball, league: 'NBA', city: 'Houston', primaryColor: '#CE1141'),
  SportsTeam(id: 'nba_mem', name: 'Memphis Grizzlies', shortName: '그리즐리스', sport: SportType.basketball, league: 'NBA', city: 'Memphis', primaryColor: '#5D76A9'),
  SportsTeam(id: 'nba_nop', name: 'New Orleans Pelicans', shortName: '펠리컨스', sport: SportType.basketball, league: 'NBA', city: 'New Orleans', primaryColor: '#0C2340'),
  SportsTeam(id: 'nba_sas', name: 'San Antonio Spurs', shortName: '스퍼스', sport: SportType.basketball, league: 'NBA', city: 'San Antonio', primaryColor: '#C4CED4'),
];

// ============================================================
// NFL (미국프로미식축구) - 32개 팀
// ============================================================
const List<SportsTeam> nflTeams = [
  // AFC East
  SportsTeam(id: 'nfl_buf', name: 'Buffalo Bills', shortName: '빌스', sport: SportType.americanFootball, league: 'NFL', city: 'Buffalo', primaryColor: '#00338D'),
  SportsTeam(id: 'nfl_mia', name: 'Miami Dolphins', shortName: '돌핀스', sport: SportType.americanFootball, league: 'NFL', city: 'Miami', primaryColor: '#008E97'),
  SportsTeam(id: 'nfl_ne', name: 'New England Patriots', shortName: '패트리어츠', sport: SportType.americanFootball, league: 'NFL', city: 'New England', primaryColor: '#002244'),
  SportsTeam(id: 'nfl_nyj', name: 'New York Jets', shortName: '제츠', sport: SportType.americanFootball, league: 'NFL', city: 'New York', primaryColor: '#125740'),
  // AFC North
  SportsTeam(id: 'nfl_bal', name: 'Baltimore Ravens', shortName: '레이븐스', sport: SportType.americanFootball, league: 'NFL', city: 'Baltimore', primaryColor: '#241773'),
  SportsTeam(id: 'nfl_cin', name: 'Cincinnati Bengals', shortName: '벵갈스', sport: SportType.americanFootball, league: 'NFL', city: 'Cincinnati', primaryColor: '#FB4F14'),
  SportsTeam(id: 'nfl_cle', name: 'Cleveland Browns', shortName: '브라운스', sport: SportType.americanFootball, league: 'NFL', city: 'Cleveland', primaryColor: '#311D00'),
  SportsTeam(id: 'nfl_pit', name: 'Pittsburgh Steelers', shortName: '스틸러스', sport: SportType.americanFootball, league: 'NFL', city: 'Pittsburgh', primaryColor: '#FFB612'),
  // AFC South
  SportsTeam(id: 'nfl_hou', name: 'Houston Texans', shortName: '텍산스', sport: SportType.americanFootball, league: 'NFL', city: 'Houston', primaryColor: '#03202F'),
  SportsTeam(id: 'nfl_ind', name: 'Indianapolis Colts', shortName: '콜츠', sport: SportType.americanFootball, league: 'NFL', city: 'Indianapolis', primaryColor: '#002C5F'),
  SportsTeam(id: 'nfl_jax', name: 'Jacksonville Jaguars', shortName: '재규어스', sport: SportType.americanFootball, league: 'NFL', city: 'Jacksonville', primaryColor: '#006778'),
  SportsTeam(id: 'nfl_ten', name: 'Tennessee Titans', shortName: '타이탄스', sport: SportType.americanFootball, league: 'NFL', city: 'Tennessee', primaryColor: '#0C2340'),
  // AFC West
  SportsTeam(id: 'nfl_den', name: 'Denver Broncos', shortName: '브롱코스', sport: SportType.americanFootball, league: 'NFL', city: 'Denver', primaryColor: '#FB4F14'),
  SportsTeam(id: 'nfl_kc', name: 'Kansas City Chiefs', shortName: '치프스', sport: SportType.americanFootball, league: 'NFL', city: 'Kansas City', primaryColor: '#E31837'),
  SportsTeam(id: 'nfl_lv', name: 'Las Vegas Raiders', shortName: '레이더스', sport: SportType.americanFootball, league: 'NFL', city: 'Las Vegas', primaryColor: '#000000'),
  SportsTeam(id: 'nfl_lac', name: 'Los Angeles Chargers', shortName: '차저스', sport: SportType.americanFootball, league: 'NFL', city: 'Los Angeles', primaryColor: '#0080C6'),
  // NFC East
  SportsTeam(id: 'nfl_dal', name: 'Dallas Cowboys', shortName: '카우보이스', sport: SportType.americanFootball, league: 'NFL', city: 'Dallas', primaryColor: '#003594'),
  SportsTeam(id: 'nfl_nyg', name: 'New York Giants', shortName: '자이언츠', sport: SportType.americanFootball, league: 'NFL', city: 'New York', primaryColor: '#0B2265'),
  SportsTeam(id: 'nfl_phi', name: 'Philadelphia Eagles', shortName: '이글스', sport: SportType.americanFootball, league: 'NFL', city: 'Philadelphia', primaryColor: '#004C54'),
  SportsTeam(id: 'nfl_wsh', name: 'Washington Commanders', shortName: '커맨더스', sport: SportType.americanFootball, league: 'NFL', city: 'Washington', primaryColor: '#773141'),
  // NFC North
  SportsTeam(id: 'nfl_chi', name: 'Chicago Bears', shortName: '베어스', sport: SportType.americanFootball, league: 'NFL', city: 'Chicago', primaryColor: '#0B162A'),
  SportsTeam(id: 'nfl_det', name: 'Detroit Lions', shortName: '라이온스', sport: SportType.americanFootball, league: 'NFL', city: 'Detroit', primaryColor: '#0076B6'),
  SportsTeam(id: 'nfl_gb', name: 'Green Bay Packers', shortName: '패커스', sport: SportType.americanFootball, league: 'NFL', city: 'Green Bay', primaryColor: '#203731'),
  SportsTeam(id: 'nfl_min', name: 'Minnesota Vikings', shortName: '바이킹스', sport: SportType.americanFootball, league: 'NFL', city: 'Minnesota', primaryColor: '#4F2683'),
  // NFC South
  SportsTeam(id: 'nfl_atl', name: 'Atlanta Falcons', shortName: '팰컨스', sport: SportType.americanFootball, league: 'NFL', city: 'Atlanta', primaryColor: '#A71930'),
  SportsTeam(id: 'nfl_car', name: 'Carolina Panthers', shortName: '팬서스', sport: SportType.americanFootball, league: 'NFL', city: 'Carolina', primaryColor: '#0085CA'),
  SportsTeam(id: 'nfl_no', name: 'New Orleans Saints', shortName: '세인츠', sport: SportType.americanFootball, league: 'NFL', city: 'New Orleans', primaryColor: '#D3BC8D'),
  SportsTeam(id: 'nfl_tb', name: 'Tampa Bay Buccaneers', shortName: '버커니어스', sport: SportType.americanFootball, league: 'NFL', city: 'Tampa Bay', primaryColor: '#D50A0A'),
  // NFC West
  SportsTeam(id: 'nfl_ari', name: 'Arizona Cardinals', shortName: '카디널스', sport: SportType.americanFootball, league: 'NFL', city: 'Arizona', primaryColor: '#97233F'),
  SportsTeam(id: 'nfl_lar', name: 'Los Angeles Rams', shortName: '램스', sport: SportType.americanFootball, league: 'NFL', city: 'Los Angeles', primaryColor: '#003594'),
  SportsTeam(id: 'nfl_sf', name: 'San Francisco 49ers', shortName: '49ers', sport: SportType.americanFootball, league: 'NFL', city: 'San Francisco', primaryColor: '#AA0000'),
  SportsTeam(id: 'nfl_sea', name: 'Seattle Seahawks', shortName: '시호크스', sport: SportType.americanFootball, league: 'NFL', city: 'Seattle', primaryColor: '#002244'),
];

// ============================================================
// EPL (잉글랜드 프리미어리그) - 20개 팀
// ============================================================
const List<SportsTeam> eplTeams = [
  SportsTeam(id: 'epl_ars', name: 'Arsenal', shortName: '아스날', sport: SportType.soccer, league: 'EPL', city: 'London', primaryColor: '#EF0107'),
  SportsTeam(id: 'epl_avl', name: 'Aston Villa', shortName: '아스톤빌라', sport: SportType.soccer, league: 'EPL', city: 'Birmingham', primaryColor: '#670E36'),
  SportsTeam(id: 'epl_bou', name: 'AFC Bournemouth', shortName: '본머스', sport: SportType.soccer, league: 'EPL', city: 'Bournemouth', primaryColor: '#DA291C'),
  SportsTeam(id: 'epl_bre', name: 'Brentford', shortName: '브렌트퍼드', sport: SportType.soccer, league: 'EPL', city: 'London', primaryColor: '#E30613'),
  SportsTeam(id: 'epl_bha', name: 'Brighton & Hove Albion', shortName: '브라이튼', sport: SportType.soccer, league: 'EPL', city: 'Brighton', primaryColor: '#0057B8'),
  SportsTeam(id: 'epl_che', name: 'Chelsea', shortName: '첼시', sport: SportType.soccer, league: 'EPL', city: 'London', primaryColor: '#034694'),
  SportsTeam(id: 'epl_cry', name: 'Crystal Palace', shortName: '크리스탈팰리스', sport: SportType.soccer, league: 'EPL', city: 'London', primaryColor: '#1B458F'),
  SportsTeam(id: 'epl_eve', name: 'Everton', shortName: '에버턴', sport: SportType.soccer, league: 'EPL', city: 'Liverpool', primaryColor: '#003399'),
  SportsTeam(id: 'epl_ful', name: 'Fulham', shortName: '풀럼', sport: SportType.soccer, league: 'EPL', city: 'London', primaryColor: '#000000'),
  SportsTeam(id: 'epl_ips', name: 'Ipswich Town', shortName: '입스위치', sport: SportType.soccer, league: 'EPL', city: 'Ipswich', primaryColor: '#0044B9'),
  SportsTeam(id: 'epl_lei', name: 'Leicester City', shortName: '레스터', sport: SportType.soccer, league: 'EPL', city: 'Leicester', primaryColor: '#003090'),
  SportsTeam(id: 'epl_liv', name: 'Liverpool', shortName: '리버풀', sport: SportType.soccer, league: 'EPL', city: 'Liverpool', primaryColor: '#C8102E'),
  SportsTeam(id: 'epl_mci', name: 'Manchester City', shortName: '맨시티', sport: SportType.soccer, league: 'EPL', city: 'Manchester', primaryColor: '#6CABDD'),
  SportsTeam(id: 'epl_mun', name: 'Manchester United', shortName: '맨유', sport: SportType.soccer, league: 'EPL', city: 'Manchester', primaryColor: '#DA291C'),
  SportsTeam(id: 'epl_new', name: 'Newcastle United', shortName: '뉴캐슬', sport: SportType.soccer, league: 'EPL', city: 'Newcastle', primaryColor: '#241F20'),
  SportsTeam(id: 'epl_nfo', name: 'Nottingham Forest', shortName: '노팅엄', sport: SportType.soccer, league: 'EPL', city: 'Nottingham', primaryColor: '#E53233'),
  SportsTeam(id: 'epl_sou', name: 'Southampton', shortName: '사우샘프턴', sport: SportType.soccer, league: 'EPL', city: 'Southampton', primaryColor: '#D71920'),
  SportsTeam(id: 'epl_tot', name: 'Tottenham Hotspur', shortName: '토트넘', sport: SportType.soccer, league: 'EPL', city: 'London', primaryColor: '#132257'),
  SportsTeam(id: 'epl_whu', name: 'West Ham United', shortName: '웨스트햄', sport: SportType.soccer, league: 'EPL', city: 'London', primaryColor: '#7A263A'),
  SportsTeam(id: 'epl_wol', name: 'Wolverhampton Wanderers', shortName: '울버햄튼', sport: SportType.soccer, league: 'EPL', city: 'Wolverhampton', primaryColor: '#FDB913'),
];

// ============================================================
// La Liga (스페인 라리가) - 20개 팀
// ============================================================
const List<SportsTeam> laLigaTeams = [
  SportsTeam(id: 'laliga_rma', name: 'Real Madrid', shortName: '레알마드리드', sport: SportType.soccer, league: 'La Liga', city: 'Madrid', primaryColor: '#FEBE10'),
  SportsTeam(id: 'laliga_bar', name: 'FC Barcelona', shortName: '바르셀로나', sport: SportType.soccer, league: 'La Liga', city: 'Barcelona', primaryColor: '#004D98'),
  SportsTeam(id: 'laliga_atm', name: 'Atletico Madrid', shortName: '아틀레티코', sport: SportType.soccer, league: 'La Liga', city: 'Madrid', primaryColor: '#CB3524'),
  SportsTeam(id: 'laliga_sev', name: 'Sevilla FC', shortName: '세비야', sport: SportType.soccer, league: 'La Liga', city: 'Sevilla', primaryColor: '#F43333'),
  SportsTeam(id: 'laliga_rso', name: 'Real Sociedad', shortName: '레알소시에다드', sport: SportType.soccer, league: 'La Liga', city: 'San Sebastian', primaryColor: '#143C8B'),
  SportsTeam(id: 'laliga_bet', name: 'Real Betis', shortName: '베티스', sport: SportType.soccer, league: 'La Liga', city: 'Sevilla', primaryColor: '#00954C'),
  SportsTeam(id: 'laliga_vil', name: 'Villarreal CF', shortName: '비야레알', sport: SportType.soccer, league: 'La Liga', city: 'Villarreal', primaryColor: '#FFE667'),
  SportsTeam(id: 'laliga_ath', name: 'Athletic Bilbao', shortName: '아틀레틱빌바오', sport: SportType.soccer, league: 'La Liga', city: 'Bilbao', primaryColor: '#EE2523'),
  SportsTeam(id: 'laliga_val', name: 'Valencia CF', shortName: '발렌시아', sport: SportType.soccer, league: 'La Liga', city: 'Valencia', primaryColor: '#EE3524'),
  SportsTeam(id: 'laliga_cel', name: 'Celta Vigo', shortName: '셀타비고', sport: SportType.soccer, league: 'La Liga', city: 'Vigo', primaryColor: '#8AC3EE'),
  SportsTeam(id: 'laliga_gir', name: 'Girona FC', shortName: '지로나', sport: SportType.soccer, league: 'La Liga', city: 'Girona', primaryColor: '#CD2534'),
  SportsTeam(id: 'laliga_rma2', name: 'Rayo Vallecano', shortName: '라요바예카노', sport: SportType.soccer, league: 'La Liga', city: 'Madrid', primaryColor: '#E53027'),
  SportsTeam(id: 'laliga_osa', name: 'Osasuna', shortName: '오사수나', sport: SportType.soccer, league: 'La Liga', city: 'Pamplona', primaryColor: '#D91A21'),
  SportsTeam(id: 'laliga_mal', name: 'Mallorca', shortName: '마요르카', sport: SportType.soccer, league: 'La Liga', city: 'Palma', primaryColor: '#E20613'),
  SportsTeam(id: 'laliga_get', name: 'Getafe CF', shortName: '헤타페', sport: SportType.soccer, league: 'La Liga', city: 'Getafe', primaryColor: '#005999'),
  SportsTeam(id: 'laliga_esp', name: 'Espanyol', shortName: '에스파뇰', sport: SportType.soccer, league: 'La Liga', city: 'Barcelona', primaryColor: '#007FC8'),
  SportsTeam(id: 'laliga_alv', name: 'Alaves', shortName: '알라베스', sport: SportType.soccer, league: 'La Liga', city: 'Vitoria', primaryColor: '#0055A5'),
  SportsTeam(id: 'laliga_leg', name: 'Leganes', shortName: '레가네스', sport: SportType.soccer, league: 'La Liga', city: 'Leganes', primaryColor: '#0055A5'),
  SportsTeam(id: 'laliga_vll', name: 'Real Valladolid', shortName: '바야돌리드', sport: SportType.soccer, league: 'La Liga', city: 'Valladolid', primaryColor: '#5F259F'),
  SportsTeam(id: 'laliga_lpa', name: 'Las Palmas', shortName: '라스팔마스', sport: SportType.soccer, league: 'La Liga', city: 'Las Palmas', primaryColor: '#FFE400'),
];

// ============================================================
// Bundesliga (독일 분데스리가) - 18개 팀
// ============================================================
const List<SportsTeam> bundesligaTeams = [
  SportsTeam(id: 'bun_bay', name: 'Bayern Munich', shortName: '바이에른뮌헨', sport: SportType.soccer, league: 'Bundesliga', city: 'Munich', primaryColor: '#DC052D'),
  SportsTeam(id: 'bun_bvb', name: 'Borussia Dortmund', shortName: '도르트문트', sport: SportType.soccer, league: 'Bundesliga', city: 'Dortmund', primaryColor: '#FDE100'),
  SportsTeam(id: 'bun_rbl', name: 'RB Leipzig', shortName: '라이프치히', sport: SportType.soccer, league: 'Bundesliga', city: 'Leipzig', primaryColor: '#DD0741'),
  SportsTeam(id: 'bun_b04', name: 'Bayer Leverkusen', shortName: '레버쿠젠', sport: SportType.soccer, league: 'Bundesliga', city: 'Leverkusen', primaryColor: '#E32221'),
  SportsTeam(id: 'bun_sge', name: 'Eintracht Frankfurt', shortName: '프랑크푸르트', sport: SportType.soccer, league: 'Bundesliga', city: 'Frankfurt', primaryColor: '#E1000F'),
  SportsTeam(id: 'bun_vfb', name: 'VfB Stuttgart', shortName: '슈투트가르트', sport: SportType.soccer, league: 'Bundesliga', city: 'Stuttgart', primaryColor: '#E32219'),
  SportsTeam(id: 'bun_wob', name: 'VfL Wolfsburg', shortName: '볼프스부르크', sport: SportType.soccer, league: 'Bundesliga', city: 'Wolfsburg', primaryColor: '#65B32E'),
  SportsTeam(id: 'bun_bmg', name: 'Borussia Monchengladbach', shortName: '묀헨글라트바흐', sport: SportType.soccer, league: 'Bundesliga', city: 'Monchengladbach', primaryColor: '#000000'),
  SportsTeam(id: 'bun_scf', name: 'SC Freiburg', shortName: '프라이부르크', sport: SportType.soccer, league: 'Bundesliga', city: 'Freiburg', primaryColor: '#E2001A'),
  SportsTeam(id: 'bun_tsg', name: 'TSG Hoffenheim', shortName: '호펜하임', sport: SportType.soccer, league: 'Bundesliga', city: 'Hoffenheim', primaryColor: '#1961B5'),
  SportsTeam(id: 'bun_m05', name: 'Mainz 05', shortName: '마인츠', sport: SportType.soccer, league: 'Bundesliga', city: 'Mainz', primaryColor: '#ED1C24'),
  SportsTeam(id: 'bun_fcb', name: 'FC Augsburg', shortName: '아우크스부르크', sport: SportType.soccer, league: 'Bundesliga', city: 'Augsburg', primaryColor: '#BA3733'),
  SportsTeam(id: 'bun_wer', name: 'Werder Bremen', shortName: '브레멘', sport: SportType.soccer, league: 'Bundesliga', city: 'Bremen', primaryColor: '#1D9053'),
  SportsTeam(id: 'bun_boc', name: 'VfL Bochum', shortName: '보훔', sport: SportType.soccer, league: 'Bundesliga', city: 'Bochum', primaryColor: '#005BA1'),
  SportsTeam(id: 'bun_fcu', name: 'Union Berlin', shortName: '우니온베를린', sport: SportType.soccer, league: 'Bundesliga', city: 'Berlin', primaryColor: '#EB1923'),
  SportsTeam(id: 'bun_koe', name: '1. FC Koln', shortName: '쾰른', sport: SportType.soccer, league: 'Bundesliga', city: 'Cologne', primaryColor: '#ED1C24'),
  SportsTeam(id: 'bun_hei', name: 'FC Heidenheim', shortName: '하이덴하임', sport: SportType.soccer, league: 'Bundesliga', city: 'Heidenheim', primaryColor: '#E30613'),
  SportsTeam(id: 'bun_stp', name: 'FC St. Pauli', shortName: '장크트파울리', sport: SportType.soccer, league: 'Bundesliga', city: 'Hamburg', primaryColor: '#7D4E24'),
];

// ============================================================
// Serie A (이탈리아 세리에A) - 20개 팀
// ============================================================
const List<SportsTeam> serieATeams = [
  SportsTeam(id: 'seria_int', name: 'Inter Milan', shortName: '인터밀란', sport: SportType.soccer, league: 'Serie A', city: 'Milan', primaryColor: '#0068A8'),
  SportsTeam(id: 'seria_acm', name: 'AC Milan', shortName: 'AC밀란', sport: SportType.soccer, league: 'Serie A', city: 'Milan', primaryColor: '#FB090B'),
  SportsTeam(id: 'seria_juv', name: 'Juventus', shortName: '유벤투스', sport: SportType.soccer, league: 'Serie A', city: 'Turin', primaryColor: '#000000'),
  SportsTeam(id: 'seria_nap', name: 'Napoli', shortName: '나폴리', sport: SportType.soccer, league: 'Serie A', city: 'Naples', primaryColor: '#12A0D7'),
  SportsTeam(id: 'seria_rom', name: 'AS Roma', shortName: '로마', sport: SportType.soccer, league: 'Serie A', city: 'Rome', primaryColor: '#8E1F2F'),
  SportsTeam(id: 'seria_laz', name: 'Lazio', shortName: '라치오', sport: SportType.soccer, league: 'Serie A', city: 'Rome', primaryColor: '#87D8F7'),
  SportsTeam(id: 'seria_ata', name: 'Atalanta', shortName: '아탈란타', sport: SportType.soccer, league: 'Serie A', city: 'Bergamo', primaryColor: '#1E71B8'),
  SportsTeam(id: 'seria_fio', name: 'Fiorentina', shortName: '피오렌티나', sport: SportType.soccer, league: 'Serie A', city: 'Florence', primaryColor: '#482E92'),
  SportsTeam(id: 'seria_tor', name: 'Torino', shortName: '토리노', sport: SportType.soccer, league: 'Serie A', city: 'Turin', primaryColor: '#8B0000'),
  SportsTeam(id: 'seria_bol', name: 'Bologna', shortName: '볼로냐', sport: SportType.soccer, league: 'Serie A', city: 'Bologna', primaryColor: '#1A2F48'),
  SportsTeam(id: 'seria_mon', name: 'Monza', shortName: '몬차', sport: SportType.soccer, league: 'Serie A', city: 'Monza', primaryColor: '#EE1C25'),
  SportsTeam(id: 'seria_udi', name: 'Udinese', shortName: '우디네세', sport: SportType.soccer, league: 'Serie A', city: 'Udine', primaryColor: '#000000'),
  SportsTeam(id: 'seria_sas', name: 'Sassuolo', shortName: '사수올로', sport: SportType.soccer, league: 'Serie A', city: 'Sassuolo', primaryColor: '#00A650'),
  SportsTeam(id: 'seria_emp', name: 'Empoli', shortName: '엠폴리', sport: SportType.soccer, league: 'Serie A', city: 'Empoli', primaryColor: '#00529F'),
  SportsTeam(id: 'seria_lec', name: 'Lecce', shortName: '레체', sport: SportType.soccer, league: 'Serie A', city: 'Lecce', primaryColor: '#FADC04'),
  SportsTeam(id: 'seria_cag', name: 'Cagliari', shortName: '칼리아리', sport: SportType.soccer, league: 'Serie A', city: 'Cagliari', primaryColor: '#6D1A36'),
  SportsTeam(id: 'seria_gen', name: 'Genoa', shortName: '제노아', sport: SportType.soccer, league: 'Serie A', city: 'Genoa', primaryColor: '#9A1B23'),
  SportsTeam(id: 'seria_ver', name: 'Hellas Verona', shortName: '베로나', sport: SportType.soccer, league: 'Serie A', city: 'Verona', primaryColor: '#003D7C'),
  SportsTeam(id: 'seria_ven', name: 'Venezia', shortName: '베네치아', sport: SportType.soccer, league: 'Serie A', city: 'Venice', primaryColor: '#FF6600'),
  SportsTeam(id: 'seria_par', name: 'Parma', shortName: '파르마', sport: SportType.soccer, league: 'Serie A', city: 'Parma', primaryColor: '#FFEB3B'),
];

// ============================================================
// 통합 데이터 접근
// ============================================================

/// 종목별 팀 목록 (한국 + 해외 리그 통합)
Map<SportType, List<SportsTeam>> get sportTeamsMap => {
      SportType.baseball: [...kboTeams, ...mlbTeams],
      SportType.soccer: [...kleagueTeams, ...eplTeams, ...laLigaTeams, ...bundesligaTeams, ...serieATeams],
      SportType.basketball: [...kblTeams, ...nbaTeams],
      SportType.volleyball: [...vleagueMenTeams, ...vleagueWomenTeams],
      SportType.esports: lckTeams,
      SportType.americanFootball: nflTeams,
      SportType.fighting: [], // UFC는 팀이 아닌 선수 구조 - Phase 12에서 별도 처리
    };

/// 종목으로 팀 목록 가져오기
List<SportsTeam> getTeamsBySport(SportType sport) {
  return sportTeamsMap[sport] ?? [];
}

/// 팀 ID로 팀 찾기
SportsTeam? getTeamById(String teamId) {
  final allTeams = [
    // 한국 리그
    ...kboTeams,
    ...kleagueTeams,
    ...kblTeams,
    ...vleagueMenTeams,
    ...vleagueWomenTeams,
    ...lckTeams,
    // 해외 리그
    ...mlbTeams,
    ...nbaTeams,
    ...nflTeams,
    ...eplTeams,
    ...laLigaTeams,
    ...bundesligaTeams,
    ...serieATeams,
  ];
  try {
    return allTeams.firstWhere((team) => team.id == teamId);
  } catch (_) {
    return null;
  }
}

/// 팀 shortName으로 팀 찾기
SportsTeam? getTeamByShortName(String shortName, SportType sport) {
  final teams = getTeamsBySport(sport);
  try {
    return teams.firstWhere(
      (team) => team.shortName.toLowerCase() == shortName.toLowerCase(),
    );
  } catch (_) {
    return null;
  }
}

/// 모든 팀 목록
List<SportsTeam> get allSportsTeams => [
      // 한국 리그
      ...kboTeams,
      ...kleagueTeams,
      ...kblTeams,
      ...vleagueMenTeams,
      ...vleagueWomenTeams,
      ...lckTeams,
      // 해외 리그
      ...mlbTeams,
      ...nbaTeams,
      ...nflTeams,
      ...eplTeams,
      ...laLigaTeams,
      ...bundesligaTeams,
      ...serieATeams,
    ];

/// 팀 검색 (이름으로)
List<SportsTeam> searchTeams(String query) {
  final lowerQuery = query.toLowerCase();
  return allSportsTeams.where((team) {
    return team.name.toLowerCase().contains(lowerQuery) ||
        team.shortName.toLowerCase().contains(lowerQuery) ||
        (team.city?.toLowerCase().contains(lowerQuery) ?? false);
  }).toList();
}

/// 리그별 팀 목록 가져오기
List<SportsTeam> getTeamsByLeague(String league) {
  return allSportsTeams.where((team) => team.league == league).toList();
}

/// 종목 + 리그로 팀 목록 가져오기
List<SportsTeam> getTeamsBySportAndLeague(SportType sport, String league) {
  return getTeamsBySport(sport).where((team) => team.league == league).toList();
}

/// 사용 가능한 리그 목록 가져오기
List<String> getAvailableLeagues(SportType sport) {
  return getTeamsBySport(sport)
      .map((team) => team.league)
      .toSet()
      .toList();
}

/// 리그별 팀 목록 직접 접근 Map
Map<String, List<SportsTeam>> get leagueTeamsMap => {
  // 한국 리그
  'KBO': kboTeams,
  'K리그': kleagueTeams,
  'KBL': kblTeams,
  'V리그 남자': vleagueMenTeams,
  'V리그 여자': vleagueWomenTeams,
  'LCK': lckTeams,
  // 미국 리그
  'MLB': mlbTeams,
  'NBA': nbaTeams,
  'NFL': nflTeams,
  // 유럽 축구
  'EPL': eplTeams,
  'La Liga': laLigaTeams,
  'Bundesliga': bundesligaTeams,
  'Serie A': serieATeams,
};
