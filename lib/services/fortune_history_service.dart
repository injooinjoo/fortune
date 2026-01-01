import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../features/history/domain/models/fortune_history.dart';
import '../core/utils/logger.dart';
import 'user_statistics_service.dart';
import 'storage_service.dart';

/// 운세 히스토리 관리 서비스
class FortuneHistoryService {
  static final FortuneHistoryService _instance = FortuneHistoryService._internal();
  factory FortuneHistoryService() => _instance;
  FortuneHistoryService._internal();

  static const String _tableName = 'fortune_history';
  final _supabase = Supabase.instance.client;
  final _uuid = const Uuid();
  
  // 중복 호출 방지를 위한 캐시
  List<int>? _cachedDailyScores;
  DateTime? _lastCacheTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  /// 운세 결과를 히스토리에 저장
  Future<String?> saveFortuneResult({
    required String fortuneType,
    required String title,
    required Map<String, dynamic> summary,
    required Map<String, dynamic> fortuneData, // 전체 운세 데이터 추가
    Map<String, dynamic>? metadata,
    List<String>? tags,
    String? mood,
    int? score, // 점수 추가
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        Logger.warning('[FortuneHistoryService] User not authenticated');
        return null;
      }

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day + 1);

      // 같은 날 같은 타입의 운세가 이미 있는지 확인
      final existingFortune = await _supabase
        .from(_tableName)
        .select('id')
        .eq('user_id', userId)
        .eq('fortune_type', fortuneType)
        .gte('created_at', todayStart.toIso8601String())
        .lt('created_at', todayEnd.toIso8601String())
        .maybeSingle();

      // 이미 오늘 같은 타입의 운세가 있으면 UPDATE
      if (existingFortune != null) {
        final existingId = existingFortune['id'] as String;
        Logger.debug('[FortuneHistoryService] Updating existing $fortuneType fortune for today: $existingId');

        await _supabase.from(_tableName).update({
          'title': title,
          'summary': summary,
          'fortune_data': fortuneData,
          'score': score ?? summary['score'],
          'metadata': metadata,
          'tags': tags ?? _generateTags(fortuneType, summary),
          'last_viewed_at': now.toIso8601String(),
          'mood': mood,
        }).eq('id', existingId);

        Logger.info('[FortuneHistoryService] Fortune updated for today: $fortuneType ($existingId)');
        return existingId;
      }

      // 새로운 운세 저장
      final fortuneId = _uuid.v4();

      // 새로운 테이블 구조에 맞게 데이터 구성
      final historyData = {
        'id': fortuneId,
        'user_id': userId,
        'fortune_type': fortuneType,
        'title': title,
        'summary': summary,
        'fortune_data': fortuneData, // 전체 운세 데이터
        'score': score ?? summary['score'], // 점수
        'created_at': now.toIso8601String(),
        'metadata': metadata,
        'tags': tags ?? _generateTags(fortuneType, summary),
        'view_count': 1,
        'is_shared': false,
        'last_viewed_at': now.toIso8601String(),
        'mood': mood,
      };

      await _supabase
        .from(_tableName)
        .insert(historyData);

      Logger.info('[FortuneHistoryService] Fortune saved to history: $fortuneType ($fortuneId)');

      // 통계 업데이트 (새로운 저장 시에만)
      try {
        final statsService = UserStatisticsService(
          _supabase,
          StorageService(),
        );
        await statsService.incrementFortuneCount(userId, fortuneType);
        Logger.info('[FortuneHistoryService] Statistics updated for $fortuneType');
      } catch (e) {
        Logger.warning('[FortuneHistoryService] 통계 업데이트 실패 (무시): $e');
      }

      return fortuneId;

    } catch (error) {
      Logger.warning('[FortuneHistoryService] 운세 히스토리 저장 실패 (테이블 없음, 폴백 모드): $error');
      return null;
    }
  }

  /// 운세 조회수 증가
  Future<void> incrementViewCount(String fortuneId) async {
    try {
      await _supabase.rpc('increment_fortune_view_count', 
        params: {'fortune_id': fortuneId});
      
      Logger.debug('[FortuneHistoryService] View count incremented: $fortuneId');
    } catch (error) {
      Logger.warning('[FortuneHistoryService] 조회수 증가 실패 (RPC 함수 없음, 무시): $error');
    }
  }

  /// 운세 공유 상태 업데이트
  Future<void> updateShareStatus(String fortuneId, bool isShared) async {
    try {
      await _supabase
        .from(_tableName)
        .update({'is_shared': isShared})
        .eq('id', fortuneId);
      
      Logger.debug('[FortuneHistoryService] Share status updated: $fortuneId -> $isShared');
    } catch (error) {
      Logger.warning('[FortuneHistoryService] 공유 상태 업데이트 실패 (테이블 없음, 무시): $error');
    }
  }

  /// 실제 결과 기록 (운세 검증용)
  Future<void> recordActualResult(String fortuneId, String actualResult) async {
    try {
      await _supabase
        .from(_tableName)
        .update({'actual_result': actualResult})
        .eq('id', fortuneId);
      
      Logger.debug('[FortuneHistoryService] Actual result recorded: $fortuneId');
    } catch (error) {
      Logger.warning('[FortuneHistoryService] 실제 결과 기록 실패 (테이블 없음, 무시): $error');
    }
  }

  /// 운세 타입과 결과를 기반으로 태그 자동 생성
  List<String> _generateTags(String fortuneType, Map<String, dynamic> summary) {
    final tags = <String>[];
    
    // 운세 타입 기반 태그
    if (fortuneType.contains('love')) tags.add('연애');
    if (fortuneType.contains('money') || fortuneType.contains('wealth')) tags.add('금전');
    if (fortuneType.contains('career') || fortuneType.contains('job')) tags.add('직업');
    if (fortuneType.contains('health')) tags.add('건강');
    if (fortuneType.contains('daily') || fortuneType.contains('today')) tags.add('일일');
    if (fortuneType.contains('weekly')) tags.add('주간');
    if (fortuneType.contains('monthly')) tags.add('월간');
    if (fortuneType.contains('moving')) tags.add('이사');
    if (fortuneType.contains('wish')) tags.add('소원');
    
    // 점수 기반 태그
    final score = summary['score'] as int?;
    if (score != null) {
      if (score >= 90) {
        tags.add('최고운');
      } else if (score >= 80) {
        tags.add('대길');
      } else if (score >= 70) {
        tags.add('길');
      } else if (score >= 60) {
        tags.add('보통');
      } else if (score >= 40) {
        tags.add('소흉');
      } else {
        tags.add('주의');
      }
    }

    return tags;
  }

  /// 사용자의 최근 운세 히스토리 가져오기
  Future<List<FortuneHistory>> getRecentHistory({int limit = 10}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
        .from(_tableName)
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(limit);

      return (response as List)
        .map((json) => FortuneHistory.fromJson(json))
        .toList();

    } catch (error) {
      Logger.warning('[FortuneHistoryService] 최근 히스토리 조회 실패 (테이블 없음, 빈 목록 반환): $error');
      return [];
    }
  }

  /// 일일 운세 히스토리만 가져오기 (월별)
  Future<List<FortuneHistory>> getDailyFortuneHistory({
    DateTime? year,
    DateTime? month,
    int limit = 31
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      var query = _supabase
        .from(_tableName)
        .select()
        .eq('user_id', userId)
        .eq('fortune_type', 'daily');

      // 월별 필터링
      if (month != null) {
        final startOfMonth = DateTime(month.year, month.month, 1);
        final endOfMonth = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
        query = query
          .gte('created_at', startOfMonth.toIso8601String())
          .lte('created_at', endOfMonth.toIso8601String());
      }
      // 연도별 필터링
      else if (year != null) {
        final startOfYear = DateTime(year.year, 1, 1);
        final endOfYear = DateTime(year.year, 12, 31, 23, 59, 59);
        query = query
          .gte('created_at', startOfYear.toIso8601String())
          .lte('created_at', endOfYear.toIso8601String());
      }

      final response = await query
        .order('created_at', ascending: false)
        .limit(limit);

      return (response as List)
        .map((json) => FortuneHistory.fromJson(json))
        .toList();

    } catch (error) {
      Logger.warning('[FortuneHistoryService] 일일 운세 히스토리 조회 실패 (테이블 없음, 빈 목록 반환): $error');
      return [];
    }
  }

  /// 특정 운세 타입의 히스토리 가져오기
  Future<List<FortuneHistory>> getHistoryByType(String fortuneType, {int limit = 50}) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];

      final response = await _supabase
        .from(_tableName)
        .select()
        .eq('user_id', userId)
        .eq('fortune_type', fortuneType)
        .order('created_at', ascending: false)
        .limit(limit);

      return (response as List)
        .map((json) => FortuneHistory.fromJson(json))
        .toList();

    } catch (error) {
      Logger.warning('[FortuneHistoryService] 타입별 히스토리 조회 실패 (테이블 없음, 빈 목록 반환): $error');
      return [];
    }
  }

  /// 일일 운세를 히스토리에 저장 (홈 화면 전용)
  Future<String?> saveDailyFortuneFromHome({
    required String userId,
    required String fortuneId,
    required String title,
    required Map<String, dynamic> summary,
    Map<String, dynamic>? metadata,
    List<String>? tags,
  }) async {
    try {
      final now = DateTime.now();

      // 이미 오늘 일일 운세가 저장되어 있는지 확인
      final existingFortune = await _supabase
        .from(_tableName)
        .select('id')
        .eq('user_id', userId)
        .eq('fortune_type', 'daily')
        .gte('created_at', DateTime(now.year, now.month, now.day).toIso8601String())
        .lt('created_at', DateTime(now.year, now.month, now.day + 1).toIso8601String())
        .maybeSingle();
      
      // 이미 오늘 운세가 있으면 업데이트
      if (existingFortune != null) {
        Logger.debug('[FortuneHistoryService] Updating existing daily fortune for today');
        await _supabase
          .from(_tableName)
          .update({
            'title': title,
            'summary': summary,
            'metadata': metadata,
            'tags': tags ?? _generateTags('daily', summary),
            'view_count': 1,
            'last_viewed_at': now.toIso8601String(),
          })
          .eq('id', existingFortune['id']);
        
        Logger.info('[FortuneHistoryService] Daily fortune updated for today');
        return existingFortune['id'] as String;
      }
      
      // 새로운 운세 저장
      final historyId = _uuid.v4();
      final fortuneHistory = FortuneHistory(
        id: historyId,
        userId: userId,
        fortuneType: 'daily',
        title: title,
        summary: summary,
        createdAt: now,
        metadata: metadata,
        tags: tags ?? _generateTags('daily', summary),
        viewCount: 1,
        isShared: false,
        lastViewedAt: now,
      );

      await _supabase
        .from(_tableName)
        .insert(fortuneHistory.toJson());

      Logger.info('[FortuneHistoryService] Daily fortune saved: $title ($historyId)');

      // 통계 업데이트 (새로운 운세 저장 시에만)
      try {
        final statsService = UserStatisticsService(
          _supabase,
          StorageService(),
        );
        await statsService.incrementFortuneCount(userId, 'daily');
        Logger.info('[FortuneHistoryService] Statistics updated for daily fortune');
      } catch (e) {
        Logger.warning('[FortuneHistoryService] 통계 업데이트 실패 (무시): $e');
      }

      return historyId;

    } catch (error) {
      Logger.warning('[FortuneHistoryService] 일일 운세 저장 실패 (테이블 없음, 폴백 모드): $error');
      return null;
    }
  }

  /// 운세 히스토리 삭제
  Future<bool> deleteFortuneHistory(String fortuneId) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      await _supabase
        .from(_tableName)
        .delete()
        .eq('id', fortuneId)
        .eq('user_id', userId); // 보안: 자신의 기록만 삭제

      Logger.info('[FortuneHistoryService] Fortune deleted: $fortuneId');
      return true;

    } catch (error) {
      Logger.warning('[FortuneHistoryService] 운세 삭제 실패 (테이블 없음, 무시): $error');
      return false;
    }
  }

  /// 오늘 날짜 + 동일 조건의 운세 결과 조회 (캐싱용)
  Future<FortuneHistory?> getTodayFortuneByConditions({
    required String fortuneType,
    required Map<String, dynamic> inputConditions,
  }) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        Logger.warning('[FortuneHistoryService] User not authenticated for cache lookup');
        return null;
      }

      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day + 1);

      // 조건 해시 생성
      final conditionsHash = _generateConditionsHash(inputConditions);

      // 오늘 + 같은 타입 + 같은 조건 해시의 운세 조회
      final response = await _supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('fortune_type', fortuneType)
          .gte('created_at', todayStart.toIso8601String())
          .lt('created_at', todayEnd.toIso8601String())
          .maybeSingle();

      if (response == null) {
        Logger.debug('[FortuneHistoryService] No cached fortune found for $fortuneType');
        return null;
      }

      // 조건 해시 비교 (metadata에 저장된 해시와 비교)
      final savedHash = response['metadata']?['conditions_hash'] as String?;
      if (savedHash != null && savedHash != conditionsHash) {
        Logger.debug('[FortuneHistoryService] Conditions hash mismatch for $fortuneType');
        return null;
      }

      Logger.info('[FortuneHistoryService] Cache HIT for $fortuneType (hash: $conditionsHash)');
      return FortuneHistory.fromJson(response);
    } catch (error) {
      Logger.warning('[FortuneHistoryService] Cache lookup failed (fallback to API): $error');
      return null;
    }
  }

  /// 조건 해시 생성 (대용량 필드 제외)
  String _generateConditionsHash(Map<String, dynamic> conditions) {
    // 제외할 필드 (대용량/변동성)
    const excludedFields = {
      'imagePath',
      'image',
      'partnerPhoto',
      'partnerPhotoBase64',
      'faceImagePath',
      'faceImage',
      'photoBase64',
      'imageBase64',
    };

    // 필터링된 조건 맵 생성
    final filtered = Map<String, dynamic>.from(conditions)
      ..removeWhere((key, value) =>
          excludedFields.contains(key) ||
          value == null ||
          (value is String && value.length > 1000)); // 긴 문자열도 제외

    // 키 정렬하여 일관된 해시 생성
    final sortedKeys = filtered.keys.toList()..sort();
    final sortedMap = <String, dynamic>{};
    for (final key in sortedKeys) {
      sortedMap[key] = filtered[key];
    }

    // SHA256 해시 생성 (16자로 축약)
    final jsonStr = jsonEncode(sortedMap);
    final hash = sha256.convert(utf8.encode(jsonStr));
    return hash.toString().substring(0, 16);
  }

  /// 운세 결과를 히스토리에 저장 (조건 해시 포함)
  Future<String?> saveFortuneResultWithConditions({
    required String fortuneType,
    required String title,
    required Map<String, dynamic> summary,
    required Map<String, dynamic> fortuneData,
    required Map<String, dynamic> inputConditions,
    Map<String, dynamic>? metadata,
    List<String>? tags,
    String? mood,
    int? score,
  }) async {
    // 조건 해시를 metadata에 추가
    final conditionsHash = _generateConditionsHash(inputConditions);
    final enrichedMetadata = <String, dynamic>{
      ...?metadata,
      'conditions_hash': conditionsHash,
    };

    return saveFortuneResult(
      fortuneType: fortuneType,
      title: title,
      summary: summary,
      fortuneData: fortuneData,
      metadata: enrichedMetadata,
      tags: tags,
      mood: mood,
      score: score,
    );
  }

  /// 최근 7일간 일별 운세 점수 가져오기 (그래프용)
  Future<List<int>> getLast7DaysDailyScores() async {
    // 캐시된 데이터가 있고 유효하면 반환
    final now = DateTime.now();
    if (_cachedDailyScores != null && _lastCacheTime != null) {
      if (now.difference(_lastCacheTime!).compareTo(_cacheValidDuration) < 0) {
        Logger.info('[FortuneHistoryService] Using cached 7 days scores: $_cachedDailyScores');
        return _cachedDailyScores!;
      }
    }
    
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        _cachedDailyScores = List.filled(7, 0);
        _lastCacheTime = now;
        return _cachedDailyScores!;
      }

      // 새로운 함수를 사용하여 7일간 점수 조회
      final response = await _supabase.rpc('get_last_7_days_scores', params: {
        'target_user_id': userId,
      });

      final List<int> scores = List.filled(7, 0);
      
      if (response is List && response.isNotEmpty) {
        for (final item in response) {
          final dayOffset = item['day_offset'] as int?;
          final score = item['score'] as int?;
          
          if (dayOffset != null && dayOffset >= 0 && dayOffset < 7 && score != null) {
            scores[dayOffset] = score;
          }
        }
      }
      
      // 캐시에 저장
      _cachedDailyScores = scores;
      _lastCacheTime = now;
      
      Logger.info('[FortuneHistoryService] Retrieved 7 days scores from history DB: $scores');
      return scores;

    } catch (error) {
      Logger.warning('[FortuneHistoryService] 7일 점수 조회 실패 (RPC 함수 없음, 폴백 데이터 사용): $error');
      _cachedDailyScores = List.filled(7, 0);
      _lastCacheTime = now;
      return _cachedDailyScores!;
    }
  }
}