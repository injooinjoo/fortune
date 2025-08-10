import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/utils/logger.dart';
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

class ExternalApiService {
  // Cache for API responses
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  
  // Cache durations
  static const Duration _weatherCacheDuration = Duration(hours: 1);
  static const Duration _scheduleCacheDuration = Duration(hours: 24);
  static const Duration _golfCourseCacheDuration = Duration(days: 7);
  
  // Weather API (delegated to WeatherService,
  static Future<WeatherData> getWeatherData(String location) async {
    return WeatherService.getWeatherForLocation(location);
  }
  
  // Baseball Schedule API
  static Future<List<GameSchedule>> getBaseballSchedule(String team) async {
    final cacheKey = 'baseball_$team';
    
    // Check cache
    if (_isCacheValid(cacheKey, _scheduleCacheDuration)) {
      return _cache[cacheKey] as List<GameSchedule>;
    }
    
    try {
      // In production, this would call actual KBO API
      // For now, return mock data
      final schedule = _getMockBaseballSchedule(team);
      
      // Update cache
      _updateCache(cacheKey, schedule);
      
      return schedule;
    } catch (e) {
      Logger.error('Baseball API error', e);
      return [];
    }
  }
  
  // LCK Schedule API
  static Future<List<EsportsMatch>> getLCKSchedule({String? team}) async {
    final cacheKey = 'lck_${team ?? 'all'}';
    
    // Check cache
    if (_isCacheValid(cacheKey, _scheduleCacheDuration)) {
      return _cache[cacheKey] as List<EsportsMatch>;
    }
    
    try {
      // In production, this would call actual LCK API
      // For now, return mock data
      final schedule = _getMockLCKSchedule(team);
      
      // Update cache
      _updateCache(cacheKey, schedule);
      
      return schedule;
    } catch (e) {
      Logger.error('LCK API error', e);
      return [];
    }
  }
  
  // Golf Course API
  static Future<List<GolfCourse>> getGolfCourseInfo(String region) async {
    final cacheKey = 'golf_$region';
    
    // Check cache
    if (_isCacheValid(cacheKey, _golfCourseCacheDuration)) {
      return _cache[cacheKey] as List<GolfCourse>;
    }
    
    try {
      // In production, this would call actual golf course API
      // For now, return mock data
      final courses = _getMockGolfCourses(region);
      
      // Update cache
      _updateCache(cacheKey, courses);
      
      return courses;
    } catch (e) {
      Logger.error('Golf Course API error', e);
      return [];
    }
  }
  
  // Crypto Market Data
  static Future<Map<String, dynamic>> getCryptoMarketData() async {
    final cacheKey = 'crypto_market';
    
    // Check cache (shorter duration for crypto,
    if (_isCacheValid(cacheKey, Duration(minutes: 5))) {
      return _cache[cacheKey] as Map<String, dynamic>;
    }
    
    try {
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
    } catch (e) {
      Logger.error('Crypto API error', e);
      return {};
    }
  }
  
  // Lotto Statistics
  static Future<Map<String, dynamic>> getLottoStatistics() async {
    final cacheKey = 'lotto_stats';
    
    // Check cache
    if (_isCacheValid(cacheKey, Duration(days: 1))) {
      return _cache[cacheKey] as Map<String, dynamic>;
    }
    
    try {
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
    } catch (e) {
      Logger.error('Lotto API error', e);
      return {};
    }
  }
  
  // Helper methods
  static bool _isCacheValid(String key, Duration maxAge) {
    if (!_cache.containsKey(key) || !_cacheTimestamps.containsKey(key)) {
      return false;
    }
    
    final timestamp = _cacheTimestamps[key]!;
    return DateTime.now().difference(timestamp) < maxAge;
  }
  
  static void _updateCache(String key, dynamic value) {
    _cache[key] = value;
    _cacheTimestamps[key] = DateTime.now();
  }
  
  // Mock data generators
  static List<GameSchedule> _getMockBaseballSchedule(String team) {
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
  
  static List<EsportsMatch> _getMockLCKSchedule(String? team) {
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
            'recent_matches': '${team1} 2-1 ${team2}'}));
      }
    }
    
    return matches;
  }
  
  static List<GolfCourse> _getMockGolfCourses(String region) {
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