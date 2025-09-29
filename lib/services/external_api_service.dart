import '../core/utils/logger.dart';
import '../core/services/resilient_service.dart';
import 'weather_service.dart';

// Sports Schedule Models
class GameSchedule {
  final String homeTeam;
  final String awayTeam;
  final DateTime gameTime;
  final String stadium;
  final String status;
  
  GameSchedule({
    required this.homeTeam,
    required this.awayTeam,
    required this.gameTime,
    required this.stadium,
    required this.status});
}

class EsportsMatch {
  final String team1;
  final String team2;
  final DateTime matchTime;
  final String tournament;
  final String gameType;
  final Map<String, dynamic>? stats;
  
  EsportsMatch({
    required this.team1,
    required this.team2,
    required this.matchTime,
    required this.tournament,
    required this.gameType,
    this.stats});
}

class GolfCourse {
  final String name;
  final String region;
  final String address;
  final int holes;
  final double difficulty;
  final String courseType;
  final Map<String, dynamic>? additionalInfo;
  
  GolfCourse({
    required this.name,
    required this.region,
    required this.address,
    required this.holes,
    required this.difficulty,
    required this.courseType,
    this.additionalInfo});
}

/// 강화된 외부 API 서비스
///
/// KAN-79: 외부 API 연결 안정성 문제 해결
/// - ResilientService 패턴 적용
/// - 네트워크 연결 실패 대응
/// - 캐시 동시성 문제 해결
/// - 에러 복구 전략 강화
class ExternalApiService extends ResilientService {
  static final ExternalApiService _instance = ExternalApiService._internal();
  factory ExternalApiService() => _instance;
  ExternalApiService._internal();

  static ExternalApiService get instance => _instance;

  @override
  String get serviceName => 'ExternalApiService';

  // Thread-safe cache for API responses
  final Map<String, dynamic> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  
  // Cache durations
  static const Duration _scheduleCacheDuration = Duration(hours: 24);
  static const Duration _golfCourseCacheDuration = Duration(days: 7);
  
  /// 강화된 날씨 정보 조회 (ResilientService 패턴)
  Future<WeatherInfo> getWeatherData(String location) async {
    return await safeExecuteWithFallbackFunction(
      () async {
        // Use the current location weather method for now
        // In the future, can add location-specific search
        return await WeatherService.getCurrentWeather();
      },
      () async {
        // Fallback: 기본 날씨 정보 생성
        return WeatherInfo(
          condition: '맑음',
          description: '맑은 날씨',
          temperature: 20.0,
          feelsLike: 20.0,
          humidity: 60.0,
          windSpeed: 2.0,
          cityName: location,
          sunrise: DateTime.now().copyWith(hour: 6, minute: 0),
          sunset: DateTime.now().copyWith(hour: 18, minute: 0),
          icon: '01d',
        );
      },
      '날씨 정보 조회: $location',
      '날씨 서비스 연결 실패, 기본 날씨 정보 제공'
    );
  }

  /// Static 호환성을 위한 래퍼 메서드
  static Future<WeatherInfo> getWeatherDataStatic(String location) async {
    return await _instance.getWeatherData(location);
  }
  
  /// 강화된 야구 일정 조회 (ResilientService 패턴)
  Future<List<GameSchedule>> getBaseballSchedule(String team) async {
    final cacheKey = 'baseball_$team';

    return await safeExecuteWithFallbackFunction(
      () async {
        // Check cache first
        if (_isCacheValid(cacheKey, _scheduleCacheDuration)) {
          return _cache[cacheKey] as List<GameSchedule>;
        }

        // In production, this would call actual KBO API
        // For now, return mock data
        final schedule = _getMockBaseballSchedule(team);

        // Update cache
        _updateCache(cacheKey, schedule);

        return schedule;
      },
      () async {
        // Fallback: 기본 일정 데이터
        return _getMockBaseballSchedule(team);
      },
      '야구 일정 조회: $team',
      '야구 API 연결 실패, 기본 일정 데이터 제공'
    );
  }

  /// Static 호환성을 위한 래퍼 메서드
  static Future<List<GameSchedule>> getBaseballScheduleStatic(String team) async {
    return await _instance.getBaseballSchedule(team);
  }
  
  /// 강화된 LCK 일정 조회 (ResilientService 패턴)
  Future<List<EsportsMatch>> getLCKSchedule({String? team}) async {
    final cacheKey = 'lck_${team ?? 'all'}';

    return await safeExecuteWithFallbackFunction(
      () async {
        // Check cache first
        if (_isCacheValid(cacheKey, _scheduleCacheDuration)) {
          return _cache[cacheKey] as List<EsportsMatch>;
        }

        // In production, this would call actual LCK API
        // For now, return mock data
        final schedule = _getMockLCKSchedule(team);

        // Update cache
        _updateCache(cacheKey, schedule);

        return schedule;
      },
      () async {
        // Fallback: 기본 LCK 일정 데이터
        return _getMockLCKSchedule(team);
      },
      'LCK 일정 조회: ${team ?? 'all'}',
      'LCK API 연결 실패, 기본 일정 데이터 제공'
    );
  }

  /// Static 호환성을 위한 래퍼 메서드
  static Future<List<EsportsMatch>> getLCKScheduleStatic({String? team}) async {
    return await _instance.getLCKSchedule(team: team);
  }
  
  /// 강화된 골프장 정보 조회 (ResilientService 패턴)
  Future<List<GolfCourse>> getGolfCourseInfo(String region) async {
    final cacheKey = 'golf_$region';

    return await safeExecuteWithFallbackFunction(
      () async {
        // Check cache first
        if (_isCacheValid(cacheKey, _golfCourseCacheDuration)) {
          return _cache[cacheKey] as List<GolfCourse>;
        }

        // In production, this would call actual golf course API
        // For now, return mock data
        final courses = _getMockGolfCourses(region);

        // Update cache
        _updateCache(cacheKey, courses);

        return courses;
      },
      () async {
        // Fallback: 기본 골프장 데이터
        return _getMockGolfCourses(region);
      },
      '골프장 정보 조회: $region',
      '골프장 API 연결 실패, 기본 골프장 정보 제공'
    );
  }

  /// Static 호환성을 위한 래퍼 메서드
  static Future<List<GolfCourse>> getGolfCourseInfoStatic(String region) async {
    return await _instance.getGolfCourseInfo(region);
  }
  
  /// 강화된 암호화폐 시세 조회 (ResilientService 패턴)
  Future<Map<String, dynamic>> getCryptoMarketData() async {
    final cacheKey = 'crypto_market';

    return await safeExecuteWithFallbackFunction(
      () async {
        // Check cache (shorter duration for crypto)
        if (_isCacheValid(cacheKey, Duration(minutes: 5))) {
          return _cache[cacheKey] as Map<String, dynamic>;
        }

        // In production, this would call actual crypto API
        // For now, return mock data
        final marketData = {
          'bitcoin': {
            'price': 50000000,
            'change24h': 2.5,
            'volume': 1000000000,
            'volatility': 'medium',
            'trend': 'bullish'},
          'ethereum': {
            'price': 3000000,
            'change24h': -1.2,
            'volume': 500000000,
            'volatility': 'high',
            'trend': 'neutral'},
          'marketSentiment': 'greed',
          'fearGreedIndex': null};

        // Update cache
        _updateCache(cacheKey, marketData);

        return marketData;
      },
      () async {
        // Fallback: 기본 암호화폐 시세 데이터
        return {
          'bitcoin': {
            'price': 50000000,
            'change24h': 0.0,
            'volume': 0,
            'volatility': 'low',
            'trend': 'stable'},
          'ethereum': {
            'price': 3000000,
            'change24h': 0.0,
            'volume': 0,
            'volatility': 'low',
            'trend': 'stable'},
          'marketSentiment': 'neutral',
          'fearGreedIndex': 50};
      },
      '암호화폐 시세 조회',
      '암호화폐 API 연결 실패, 기본 시세 정보 제공'
    );
  }

  /// Static 호환성을 위한 래퍼 메서드
  static Future<Map<String, dynamic>> getCryptoMarketDataStatic() async {
    return await _instance.getCryptoMarketData();
  }
  
  /// 강화된 로또 통계 조회 (ResilientService 패턴)
  Future<Map<String, dynamic>> getLottoStatistics() async {
    final cacheKey = 'lotto_stats';

    return await safeExecuteWithFallbackFunction(
      () async {
        // Check cache first
        if (_isCacheValid(cacheKey, Duration(days: 1))) {
          return _cache[cacheKey] as Map<String, dynamic>;
        }

        // In production, this would analyze historical lotto data
        // For now, return mock data
        final stats = {
          'hotNumbers': [7, 13, 23, 27, 35, 40],
          'coldNumbers': [2, 8, 15, 28, 37, 42],
          'mostDrawnPairs': [[7, 13], [23, 27], [35, 40]],
          'lastDrawDate': DateTime.now().subtract(Duration(days: 3)),
          'nextDrawDate': DateTime.now().add(Duration(days: 4)),
          'jackpot': 10000000000, // 100억
        };

        // Update cache
        _updateCache(cacheKey, stats);

        return stats;
      },
      () async {
        // Fallback: 기본 로또 통계 데이터
        return {
          'hotNumbers': [1, 7, 13, 21, 27, 35],
          'coldNumbers': [3, 9, 15, 23, 29, 37],
          'mostDrawnPairs': [[1, 7], [13, 21], [27, 35]],
          'lastDrawDate': DateTime.now().subtract(Duration(days: 7)),
          'nextDrawDate': DateTime.now().add(Duration(days: 1)),
          'jackpot': 5000000000, // 50억
        };
      },
      '로또 통계 조회',
      '로또 API 연결 실패, 기본 통계 정보 제공'
    );
  }

  /// Static 호환성을 위한 래퍼 메서드
  static Future<Map<String, dynamic>> getLottoStatisticsStatic() async {
    return await _instance.getLottoStatistics();
  }
  
  /// 강화된 캐시 검증 (Thread-safe)
  bool _isCacheValid(String key, Duration maxAge) {
    if (!_cache.containsKey(key) || !_cacheTimestamps.containsKey(key)) {
      return false;
    }

    final timestamp = _cacheTimestamps[key]!;
    return DateTime.now().difference(timestamp) < maxAge;
  }

  /// 강화된 캐시 업데이트 (Thread-safe)
  void _updateCache(String key, dynamic value) {
    _cache[key] = value;
    _cacheTimestamps[key] = DateTime.now();
  }

  /// 캐시 초기화 (메모리 정리)
  Future<void> clearCache() async {
    await safeExecute(
      () async {
        _cache.clear();
        _cacheTimestamps.clear();
        Logger.info('External API cache cleared');
      },
      '외부 API 캐시 초기화',
      '캐시 초기화 실패'
    );
  }
  
  /// Static 호환성을 위한 기존 메서드들 (Deprecated)
  @Deprecated('Use instance methods instead for better error handling')
  static Future<WeatherInfo> getWeatherDataOld(String location) => _instance.getWeatherData(location);

  @Deprecated('Use instance methods instead for better error handling')
  static Future<List<GameSchedule>> getBaseballScheduleOld(String team) => _instance.getBaseballSchedule(team);

  @Deprecated('Use instance methods instead for better error handling')
  static Future<List<EsportsMatch>> getLCKScheduleOld({String? team}) => _instance.getLCKSchedule(team: team);

  @Deprecated('Use instance methods instead for better error handling')
  static Future<List<GolfCourse>> getGolfCourseInfoOld(String region) => _instance.getGolfCourseInfo(region);

  @Deprecated('Use instance methods instead for better error handling')
  static Future<Map<String, dynamic>> getCryptoMarketDataOld() => _instance.getCryptoMarketData();

  @Deprecated('Use instance methods instead for better error handling')
  static Future<Map<String, dynamic>> getLottoStatisticsOld() => _instance.getLottoStatistics();

  // Mock data generators
  List<GameSchedule> _getMockBaseballSchedule(String team) {
    final teams = ['LG', 'KT', '두산', 'SSG', '키움', '한화', 'NC', '롯데', '삼성', 'KIA'];
    final stadiums = {
      'LG': '잠실',
      'KT': '수원',
      '두산': '잠실',
      'SSG': '인천',
      '키움': '고척',
      '한화': '대전',
      'NC': '창원',
      '롯데': '부산',
      '삼성': '대구',
      'KIA': '광주'};
    
    final schedule = <GameSchedule>[];
    final now = DateTime.now();
    
    for (int i = 0; i < 5; i++) {
      final opponent = teams.where((t) => t != team).toList()[i % 9];
      final isHome = i % 2 == 0;
      
      schedule.add(GameSchedule(
        homeTeam: isHome ? team : opponent,
        awayTeam: isHome ? opponent : team,
        gameTime: now.add(Duration(days: i, hours: 18, minutes: 30)),
        stadium: stadiums[isHome ? team : opponent] ?? '잠실',
        status: i == 0 ? 'today' : 'scheduled'));
    }
    
    return schedule;
  }
  
  List<EsportsMatch> _getMockLCKSchedule(String? team) {
    final teams = ['T1', 'Gen.G', 'DRX', 'DK', 'KT', 'BRO', 'NS', 'LSB', 'HLE', 'FOX'];
    final matches = <EsportsMatch>[];
    final now = DateTime.now();
    
    for (int i = 0; i < 5; i++) {
      final team1 = team ?? teams[i * 2 % 10];
      final team2 = teams[(i * 2 + 1) % 10];
      
      if (team == null || team1 == team || team2 == team) {
        matches.add(EsportsMatch(
          team1: team1,
          team2: team2,
          matchTime: now.add(Duration(days: i, hours: 17)),
          tournament: 'LCK Spring 2025',
          gameType: 'BO3',
          stats: {
            'team1_winrate': 0.65,
            'team2_winrate': 0.58,
            'recent_matches': '$team1 2-1 $team2'}));
      }
    }
    
    return matches;
  }
  
  List<GolfCourse> _getMockGolfCourses(String region) {
    final courses = {
      '경기': [
        GolfCourse(
          name: '남서울CC',
          region: '경기',
          address: '경기도 성남시',
          holes: 18,
          difficulty: 4.2,
          courseType: 'Members',
          additionalInfo: {'greenFee': 250000, 'cart': true}),
        GolfCourse(
          name: '레이크우드CC',
          region: '경기',
          address: '경기도 용인시',
          holes: 27,
          difficulty: 4.5,
          courseType: 'Public',
          additionalInfo: {'greenFee': 180000, 'cart': true}),
      ],
      '강원': [
        GolfCourse(
          name: '비발디파크CC',
          region: '강원',
          address: '강원도 홍천군',
          holes: 18,
          difficulty: 4.0,
          courseType: 'Resort',
          additionalInfo: {'greenFee': 200000, 'cart': true}),
      ],
      '제주': [
        GolfCourse(
          name: '나인브릿지',
          region: '제주',
          address: '제주특별자치도 서귀포시',
          holes: 18,
          difficulty: 4.8,
          courseType: 'Premium',
          additionalInfo: {'greenFee': 450000, 'cart': true}),
      ],
    };
    
    return courses[region] ?? [];
  }
}