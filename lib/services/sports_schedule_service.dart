import 'dart:math';
import '../core/services/resilient_service.dart';
import '../core/utils/logger.dart';
import '../features/fortune/domain/models/sports_schedule.dart';
import '../core/constants/sports_teams.dart'
    show getTeamsBySport, getTeamsByLeague;

/// 스포츠 경기 일정 서비스
///
/// 한국 프로 스포츠 경기 일정을 조회합니다.
/// - KBO (야구), K리그 (축구), KBL (농구), V리그 (배구), LCK (e스포츠)
/// - 12시간 캐싱
/// - Mock 데이터 fallback
class SportsScheduleService extends ResilientService {
  static final SportsScheduleService _instance =
      SportsScheduleService._internal();
  factory SportsScheduleService() => _instance;
  SportsScheduleService._internal();

  static SportsScheduleService get instance => _instance;

  @override
  String get serviceName => 'SportsScheduleService';

  // Thread-safe cache
  final Map<String, List<SportsGame>> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};

  // 캐시 유효 시간: 12시간
  static const Duration _cacheDuration = Duration(hours: 12);

  /// 종목별 경기 일정 조회
  Future<List<SportsGame>> getSchedule(SportType sport,
      {DateTime? from, DateTime? to}) async {
    final cacheKey =
        '${sport.name}_${from?.toIso8601String()}_${to?.toIso8601String()}';

    return await safeExecuteWithFallbackFunction(() async {
      // 캐시 확인
      if (_isCacheValid(cacheKey)) {
        Logger.info('[$serviceName] Cache hit: $cacheKey');
        return _cache[cacheKey]!;
      }

      // TODO: 실제 API 연동 시 구현
      // - KBO: 네이버 스포츠 크롤링 또는 KBO 공식 API
      // - K리그: 네이버 스포츠 또는 K리그 공식
      // - KBL: 네이버 스포츠
      // - V리그: 네이버 스포츠
      // - LCK: Liquipedia API 또는 LoL Esports API

      // 현재는 Mock 데이터 사용
      final schedule = _generateMockSchedule(sport, from, to);

      // 캐시 업데이트
      _updateCache(cacheKey, schedule);

      return schedule;
    }, () async {
      // Fallback: Mock 데이터
      Logger.warning(
          '[$serviceName] Using fallback mock data for ${sport.name}');
      return _generateMockSchedule(sport, from, to);
    }, '${sport.displayName} 일정 조회',
        '${sport.displayName} API 연결 실패, 샘플 일정 데이터 제공');
  }

  /// 특정 팀의 경기 일정 조회
  Future<List<SportsGame>> getTeamSchedule(
    SportType sport,
    String teamName, {
    DateTime? from,
    DateTime? to,
  }) async {
    final allGames = await getSchedule(sport, from: from, to: to);
    return allGames
        .where((game) => game.homeTeam == teamName || game.awayTeam == teamName)
        .toList();
  }

  /// 오늘의 경기 조회
  Future<List<SportsGame>> getTodayGames(SportType sport) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));

    final allGames = await getSchedule(sport, from: today, to: tomorrow);
    return allGames.where((game) => game.isToday).toList();
  }

  /// 이번 주 경기 조회
  Future<List<SportsGame>> getWeekGames(SportType sport) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextWeek = today.add(const Duration(days: 7));

    return await getSchedule(sport, from: today, to: nextWeek);
  }

  /// 리그별 경기 조회 (이번 주)
  Future<List<SportsGame>> getScheduleByLeague(String league) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final nextWeek = today.add(const Duration(days: 7));
    final cacheKey = 'league_${league}_${today.toIso8601String()}';

    return await safeExecuteWithFallbackFunction(() async {
      // 캐시 확인
      if (_isCacheValid(cacheKey)) {
        Logger.info('[$serviceName] Cache hit: $cacheKey');
        return _cache[cacheKey]!;
      }

      // 리그에 맞는 종목 찾기
      final sport = _getSportTypeByLeague(league);
      if (sport == null) {
        Logger.warning('[$serviceName] Unknown league: $league');
        return [];
      }

      // Mock 데이터 생성 (리그별 필터링)
      final schedule =
          _generateMockScheduleByLeague(sport, league, today, nextWeek);

      // 캐시 업데이트
      _updateCache(cacheKey, schedule);

      return schedule;
    }, () async {
      // Fallback: Mock 데이터
      Logger.warning(
          '[$serviceName] Using fallback mock data for league $league');
      final sport = _getSportTypeByLeague(league);
      if (sport == null) return [];
      return _generateMockScheduleByLeague(sport, league, today, nextWeek);
    }, '$league 일정 조회', '$league API 연결 실패, 샘플 일정 데이터 제공');
  }

  /// 리그로 종목 타입 찾기
  SportType? _getSportTypeByLeague(String league) {
    const leagueSportMap = {
      // 한국
      'KBO': SportType.baseball,
      'K리그1': SportType.soccer,
      'KBL': SportType.basketball,
      'V리그 남자': SportType.volleyball,
      'V리그 여자': SportType.volleyball,
      'LCK': SportType.esports,
      // 미국
      'MLB': SportType.baseball,
      'NBA': SportType.basketball,
      'NFL': SportType.americanFootball,
      // 유럽
      'EPL': SportType.soccer,
      'La Liga': SportType.soccer,
      'Bundesliga': SportType.soccer,
      'Serie A': SportType.soccer,
    };
    return leagueSportMap[league];
  }

  /// 리그별 Mock 경기 일정 생성
  List<SportsGame> _generateMockScheduleByLeague(
    SportType sport,
    String league,
    DateTime from,
    DateTime to,
  ) {
    final teams = getTeamsByLeague(league);
    if (teams.isEmpty) return [];

    final random = Random();
    final now = DateTime.now();
    final games = <SportsGame>[];

    // 7일간의 경기 생성 (하루 2-4경기)
    for (var day = from;
        day.isBefore(to);
        day = day.add(const Duration(days: 1))) {
      final gamesPerDay = random.nextInt(3) + 2; // 2-4경기
      final usedTeams = <String>{};

      for (var i = 0;
          i < gamesPerDay && usedTeams.length < teams.length - 1;
          i++) {
        // 홈팀 선택 (아직 사용되지 않은 팀)
        final availableTeams =
            teams.where((t) => !usedTeams.contains(t.name)).toList();
        if (availableTeams.length < 2) break;

        final homeTeam = availableTeams[random.nextInt(availableTeams.length)];
        usedTeams.add(homeTeam.name);

        // 어웨이팀 선택
        final awayAvailable =
            availableTeams.where((t) => t.name != homeTeam.name).toList();
        final awayTeam = awayAvailable[random.nextInt(awayAvailable.length)];
        usedTeams.add(awayTeam.name);

        // 경기 시간 생성 (종목별 시간대)
        final gameHour = _getTypicalGameHour(sport, random);
        final gameTime = DateTime(day.year, day.month, day.day, gameHour, 0);

        games.add(SportsGame(
          id: '${league}_${day.toIso8601String()}_$i',
          sport: sport,
          homeTeam: homeTeam.name,
          awayTeam: awayTeam.name,
          gameTime: gameTime,
          venue: _getVenue(sport, homeTeam.name),
          status: gameTime.isBefore(now)
              ? GameStatus.finished
              : GameStatus.scheduled,
          league: league,
          season: '2024',
        ));
      }
    }

    // 시간순 정렬
    games.sort((a, b) => a.gameTime.compareTo(b.gameTime));

    return games;
  }

  /// 캐시 유효성 확인
  bool _isCacheValid(String key) {
    if (!_cache.containsKey(key) || !_cacheTimestamps.containsKey(key)) {
      return false;
    }
    final timestamp = _cacheTimestamps[key]!;
    return DateTime.now().difference(timestamp) < _cacheDuration;
  }

  /// 캐시 업데이트
  void _updateCache(String key, List<SportsGame> data) {
    _cache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
  }

  /// 캐시 클리어
  void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
    Logger.info('[$serviceName] Cache cleared');
  }

  /// Mock 경기 일정 생성
  List<SportsGame> _generateMockSchedule(
    SportType sport,
    DateTime? from,
    DateTime? to,
  ) {
    final teams = getTeamsBySport(sport);
    if (teams.isEmpty) return [];

    final random = Random();
    final now = DateTime.now();
    final startDate = from ?? now;
    final endDate = to ?? now.add(const Duration(days: 7));

    final games = <SportsGame>[];

    // 7일간의 경기 생성 (하루 2-4경기)
    for (var day = startDate;
        day.isBefore(endDate);
        day = day.add(const Duration(days: 1))) {
      final gamesPerDay = random.nextInt(3) + 2; // 2-4경기
      final usedTeams = <String>{};

      for (var i = 0;
          i < gamesPerDay && usedTeams.length < teams.length - 1;
          i++) {
        // 홈팀 선택 (아직 사용되지 않은 팀)
        final availableTeams =
            teams.where((t) => !usedTeams.contains(t.name)).toList();
        if (availableTeams.length < 2) break;

        final homeTeam = availableTeams[random.nextInt(availableTeams.length)];
        usedTeams.add(homeTeam.name);

        // 어웨이팀 선택
        final awayAvailable =
            availableTeams.where((t) => t.name != homeTeam.name).toList();
        final awayTeam = awayAvailable[random.nextInt(awayAvailable.length)];
        usedTeams.add(awayTeam.name);

        // 경기 시간 생성 (종목별 시간대)
        final gameHour = _getTypicalGameHour(sport, random);
        final gameTime = DateTime(day.year, day.month, day.day, gameHour, 0);

        games.add(SportsGame(
          id: '${sport.name}_${day.toIso8601String()}_$i',
          sport: sport,
          homeTeam: homeTeam.name,
          awayTeam: awayTeam.name,
          gameTime: gameTime,
          venue: _getVenue(sport, homeTeam.name),
          status: gameTime.isBefore(now)
              ? GameStatus.finished
              : GameStatus.scheduled,
          league: sport.league,
          season: '2024',
        ));
      }
    }

    // 시간순 정렬
    games.sort((a, b) => a.gameTime.compareTo(b.gameTime));

    return games;
  }

  /// 종목별 전형적인 경기 시간 (한국 시간 기준)
  int _getTypicalGameHour(SportType sport, Random random) {
    switch (sport) {
      case SportType.baseball:
        // KBO/MLB: KBO 14:00-18:00, MLB 한국시간 오전 (미국 경기는 오전에 시청)
        return [10, 14, 17, 18][random.nextInt(4)];
      case SportType.soccer:
        // K리그/EPL/라리가/분데스/세리에: 한국시간 오후~새벽
        return [14, 16, 19, 21, 23][random.nextInt(5)];
      case SportType.basketball:
        // KBL/NBA: KBL 14:00-19:00, NBA 한국시간 오전
        return [10, 11, 14, 17, 19][random.nextInt(5)];
      case SportType.volleyball:
        // V리그: 주로 14:00, 17:00, 19:00
        return [14, 17, 19][random.nextInt(3)];
      case SportType.esports:
        // LCK: 주로 17:00, 20:00
        return [17, 20][random.nextInt(2)];
      case SportType.americanFootball:
        // NFL: 한국시간 월요일 새벽~오전
        return [2, 4, 7, 10][random.nextInt(4)];
      case SportType.fighting:
        // UFC: 한국시간 일요일 오전~오후
        return [10, 11, 12, 14][random.nextInt(4)];
    }
  }

  /// 종목/팀별 경기장
  String _getVenue(SportType sport, String homeTeam) {
    final venues = {
      // === 한국 리그 ===
      // KBO
      'LG 트윈스': '잠실',
      '두산 베어스': '잠실',
      '키움 히어로즈': '고척',
      '삼성 라이온즈': '대구',
      'KIA 타이거즈': '광주',
      'NC 다이노스': '창원',
      '롯데 자이언츠': '부산',
      'SSG 랜더스': '인천',
      'KT 위즈': '수원',
      '한화 이글스': '대전',
      // K리그
      '전북 현대': '전주',
      '울산 현대': '울산',
      '포항 스틸러스': '포항',
      '대구 FC': '대구',
      '인천 유나이티드': '인천',
      '수원 FC': '수원',
      'FC 서울': '서울',
      '제주 유나이티드': '제주',
      '광주 FC': '광주',
      '강원 FC': '강릉',
      '대전 시티즌': '대전',
      '김천 상무': '김천',
      // LCK
      'T1': 'LCK 아레나',
      'Gen.G': 'LCK 아레나',
      'DRX': 'LCK 아레나',
      '한화생명 e스포츠': 'LCK 아레나',
      'kt 롤스터': 'LCK 아레나',
      'Dplus KIA': 'LCK 아레나',
      'Kwangdong Freecs': 'LCK 아레나',
      'BNK FearX': 'LCK 아레나',
      'OK BRION': 'LCK 아레나',
      'FearX': 'LCK 아레나',
      // === 미국 리그 ===
      // MLB (주요 팀)
      'New York Yankees': '양키 스타디움',
      'Los Angeles Dodgers': '다저 스타디움',
      'Boston Red Sox': '펜웨이 파크',
      'Chicago Cubs': '리글리 필드',
      'San Diego Padres': '펫코 파크',
      'Los Angeles Angels': '에인절 스타디움',
      // NBA (주요 팀)
      'Los Angeles Lakers': '크립토닷컴 아레나',
      'Golden State Warriors': '체이스 센터',
      'Boston Celtics': 'TD 가든',
      'Chicago Bulls': '유나이티드 센터',
      'Brooklyn Nets': '바클레이스 센터',
      'Miami Heat': '카세야 센터',
      // NFL (주요 팀)
      'Kansas City Chiefs': '애로우헤드 스타디움',
      'Dallas Cowboys': 'AT&T 스타디움',
      'New England Patriots': '질레트 스타디움',
      'Philadelphia Eagles': '링컨 파이낸셜 필드',
      // === 유럽 축구 ===
      // EPL
      'Tottenham Hotspur': '토트넘 핫스퍼 스타디움',
      'Manchester United': '올드 트래포드',
      'Manchester City': '에티하드 스타디움',
      'Liverpool': '안필드',
      'Chelsea': '스탬포드 브릿지',
      'Arsenal': '에미레이츠 스타디움',
      // La Liga
      'Real Madrid': '산티아고 베르나베우',
      'Barcelona': '캄프 누',
      'Atletico Madrid': '완다 메트로폴리타노',
      // Bundesliga
      'Bayern Munich': '알리안츠 아레나',
      'Borussia Dortmund': '지그날 이두나 파크',
      // Serie A
      'Juventus': '알리안츠 스타디움',
      'AC Milan': '산 시로',
      'Inter Milan': '산 시로',
      'Napoli': '스타디오 디에고 아르만도 마라도나',
    };

    return venues[homeTeam] ?? '홈구장';
  }

  /// Static 호환성 래퍼
  static Future<List<SportsGame>> getScheduleStatic(SportType sport,
      {DateTime? from, DateTime? to}) {
    return _instance.getSchedule(sport, from: from, to: to);
  }

  static Future<List<SportsGame>> getTodayGamesStatic(SportType sport) {
    return _instance.getTodayGames(sport);
  }

  static Future<List<SportsGame>> getWeekGamesStatic(SportType sport) {
    return _instance.getWeekGames(sport);
  }
}
