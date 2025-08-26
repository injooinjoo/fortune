import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/fortune_model.dart';
import '../models/cache_entry.dart';
import '../screens/home/fortune_story_viewer.dart';

class CacheService {
  static const Map<String, int> _cacheDuration = {
    'daily': 24,
    'hourly': 1,
    'weekly': 168,
    'monthly': 720,
    'yearly': 8760,
    'zodiac': 720,
    'personality': 8760,
    'default': 60};

  final SupabaseClient _supabase = Supabase.instance.client;

  CacheService._internal();
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;

  Future<void> initialize() async {
    // DB 기반 캐시는 별도 초기화 불필요
    // Supabase 클라이언트는 이미 초기화됨
    await cleanExpiredCache();
  }

  String _generateCacheKey(String fortuneType, Map<String, dynamic> params) {
    final userId = params['userId'] ?? 'anonymous';
    final dateKey = _getDateKeyForType(fortuneType);
    // Simplify the key generation to avoid inconsistencies
    return '$userId:$fortuneType:$dateKey';
  }

  String _getDateKeyForType(String fortuneType) {
    final now = DateTime.now();

    switch (fortuneType) {
      case 'hourly':
        return '${now.year}-${now.month}-${now.day}-${now.hour}';
      case 'daily':
        return '${now.year}-${now.month}-${now.day}';
      case 'weekly':
        final weekNumber = _getWeekNumber(now);
        return '${now.year}-W$weekNumber';
      case 'monthly':
        return '${now.year}-${now.month}';
      case 'yearly':
        return '${now.year}';
      default:
        return '${now.year}-${now.month}-${now.day}';
    }
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return ((daysSinceFirstDay + firstDayOfYear.weekday - 1) / 7).ceil();
  }

  Future<FortuneModel?> getCachedFortune(
    String fortuneType,
    Map<String, dynamic> params,
  ) async {
    try {
      final userId = params['userId'];
      if (userId == null) return null;
      
      final dateKey = _getDateKeyForType(fortuneType);
      
      // DB에서 캐시된 운세 조회
      final response = await _supabase
          .from('fortune_cache')
          .select()
          .eq('user_id', userId)
          .eq('fortune_type', fortuneType)
          .eq('fortune_date', dateKey)
          .maybeSingle();
      
      if (response == null) {
        debugPrint('No cached fortune found in DB for type: $fortuneType, date: $dateKey');
        return null;
      }
      
      // 만료 시간 체크
      final expiresAt = DateTime.parse(response['expires_at']);
      if (DateTime.now().isAfter(expiresAt)) {
        debugPrint('Cached fortune expired, removing from DB');
        await removeCachedFortune(fortuneType, params);
        return null;
      }
      
      // JSON 데이터를 FortuneModel로 변환
      final fortuneData = response['fortune_data'] as Map<String, dynamic>;
      debugPrint('✅ Found valid cached fortune in DB');
      return FortuneModel.fromJson(fortuneData);
    } catch (e) {
      debugPrint('DB cache operation error: $e');
      return null;
    }
  }

  Future<bool> cacheFortune(
    String fortuneType,
    Map<String, dynamic> params,
    FortuneModel fortune) async {
    try {
      final userId = params['userId'];
      if (userId == null) {
        debugPrint('❌ Cache save failed: userId is null');
        return false;
      }
      
      final dateKey = _getDateKeyForType(fortuneType);
      final duration = _cacheDuration[fortuneType] ?? _cacheDuration['default']!;
      final expiryDate = DateTime.now().add(Duration(hours: duration));
      
      debugPrint('💾 Saving to cache: type=$fortuneType, userId=$userId, dateKey=$dateKey');
      
      // DB에 운세 데이터 저장 (upsert)
      await _supabase.from('fortune_cache').upsert({
        'user_id': userId,
        'fortune_type': fortuneType,
        'fortune_date': dateKey,
        'fortune_data': fortune.toJson(),
        'expires_at': expiryDate.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      }, 
      onConflict: 'user_id,fortune_type,fortune_date');
      
      debugPrint('✅ Fortune cached to DB successfully');
      
      // 저장 확인을 위해 다시 조회
      final verification = await _supabase
          .from('fortune_cache')
          .select('id')
          .eq('user_id', userId)
          .eq('fortune_type', fortuneType)
          .eq('fortune_date', dateKey)
          .maybeSingle();
      
      if (verification != null) {
        debugPrint('✅ Cache verification successful');
        return true;
      } else {
        debugPrint('❌ Cache verification failed: data not found');
        return false;
      }
    } catch (e) {
      debugPrint('❌ DB cache save error: $e');
      return false;
    }
  }

  Future<void> removeCachedFortune(
    String fortuneType,
    Map<String, dynamic> params,
  ) async {
    try {
      final userId = params['userId'];
      if (userId == null) return;
      
      final dateKey = _getDateKeyForType(fortuneType);
      
      // DB에서 캐시 삭제
      await _supabase
          .from('fortune_cache')
          .delete()
          .eq('user_id', userId)
          .eq('fortune_type', fortuneType)
          .eq('fortune_date', dateKey);
          
      debugPrint('Removed cached fortune from DB');
    } catch (e) {
      debugPrint('DB cache delete error: $e');
    }
  }

  Future<void> removeCachedStorySegments(
    String fortuneType,
    Map<String, dynamic> params,
  ) async {
    try {
      final userId = params['userId'];
      if (userId == null) return;
      
      final dateKey = _getDateKeyForType(fortuneType);
      
      // DB에서 스토리 캐시 삭제
      await _supabase
          .from('fortune_stories')
          .delete()
          .eq('user_id', userId)
          .eq('fortune_type', fortuneType)
          .eq('story_date', dateKey);
          
      debugPrint('Removed cached story segments from DB');
    } catch (e) {
      debugPrint('DB story cache delete error: $e');
    }
  }

  // 스토리 세그먼트 캐싱 메서드
  Future<void> cacheStorySegments(
    String fortuneType,
    Map<String, dynamic> params,
    List<StorySegment> segments,
  ) async {
    try {
      final userId = params['userId'];
      if (userId == null) return;
      
      final dateKey = _getDateKeyForType(fortuneType);
      final duration = _cacheDuration[fortuneType] ?? _cacheDuration['default']!;
      final expiryDate = DateTime.now().add(Duration(hours: duration));
      
      // 스토리 데이터를 Map 리스트로 변환
      final storyData = segments.map((segment) => {
        'text': segment.text,
        'subtitle': segment.subtitle,
        'fontSize': segment.fontSize,
        'fontWeight': segment.fontWeight?.index,
        'alignment': segment.alignment?.index,
        'emoji': segment.emoji,
      }).toList();
      
      // DB에 스토리 세그먼트 저장 (upsert)
      await _supabase.from('fortune_stories').upsert({
        'user_id': userId,
        'fortune_type': fortuneType,
        'story_date': dateKey,
        'story_segments': storyData,
        'expires_at': expiryDate.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      },
      onConflict: 'user_id,fortune_type,story_date');
      
      debugPrint('✅ Successfully cached ${storyData.length} story segments to DB');
    } catch (e) {
      debugPrint('DB story cache save error: $e');
    }
  }
  
  Future<List<StorySegment>?> getCachedStorySegments(
    String fortuneType,
    Map<String, dynamic> params,
  ) async {
    try {
      final userId = params['userId'];
      if (userId == null) return null;
      
      final dateKey = _getDateKeyForType(fortuneType);
      debugPrint('🔍 Looking for cached story in DB for type: $fortuneType, date: $dateKey');
      
      // DB에서 캐시된 스토리 조회
      final response = await _supabase
          .from('fortune_stories')
          .select()
          .eq('user_id', userId)
          .eq('fortune_type', fortuneType)
          .eq('story_date', dateKey)
          .maybeSingle();
      
      if (response == null) {
        debugPrint('❌ No cached story found in DB');
        return null;
      }
      
      // 만료 시간 체크
      final expiresAt = DateTime.parse(response['expires_at']);
      if (DateTime.now().isAfter(expiresAt)) {
        debugPrint('Cached story expired, removing from DB');
        await _supabase
            .from('fortune_stories')
            .delete()
            .eq('user_id', userId)
            .eq('fortune_type', fortuneType)
            .eq('story_date', dateKey);
        return null;
      }
      
      final storyData = response['story_segments'];
      if (storyData == null || storyData is! List) {
        debugPrint('❌ No segments data in cached story');
        return null;
      }
      
      debugPrint('✅ Found cached story with ${storyData.length} segments in DB');
      
      // Map 리스트를 StorySegment 리스트로 변환
      return storyData.map((data) {
        final map = Map<String, dynamic>.from(data);
        return StorySegment(
          text: map['text'] ?? '',
          subtitle: map['subtitle'],
          fontSize: map['fontSize']?.toDouble(),
          fontWeight: map['fontWeight'] != null 
            ? FontWeight.values[map['fontWeight']] 
            : null,
          alignment: map['alignment'] != null
            ? TextAlign.values[map['alignment']]
            : null,
          emoji: map['emoji'],
        );
      }).toList();
    } catch (e) {
      debugPrint('DB story cache retrieval error: $e');
      return null;
    }
  }

  Future<void> clearAllCache() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;
      
      // DB에서 사용자의 모든 캐시 삭제
      await _supabase
          .from('fortune_cache')
          .delete()
          .eq('user_id', userId);
          
      await _supabase
          .from('fortune_stories')
          .delete()
          .eq('user_id', userId);
          
      debugPrint('Cleared all cache from DB for user');
    } catch (e) {
      debugPrint('DB cache clear error: $e');
    }
  }

  Future<void> cleanExpiredCache() async {
    try {
      final now = DateTime.now();
      
      // DB에서 만료된 캐시 삭제
      await _supabase
          .from('fortune_cache')
          .delete()
          .lt('expires_at', now.toIso8601String());
          
      await _supabase
          .from('fortune_stories')
          .delete()
          .lt('expires_at', now.toIso8601String());
          
      debugPrint('Cleaned expired cache entries from DB');
    } catch (e) {
      debugPrint('DB cache cleanup error: $e');
    }
  }

  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        return {'total': 0, 'valid': 0, 'expired': 0};
      }
      
      final now = DateTime.now();
      
      // DB에서 캐시 통계 조회
      final fortuneCacheResponse = await _supabase
          .from('fortune_cache')
          .select('expires_at')
          .eq('user_id', userId);
          
      final storyCacheResponse = await _supabase
          .from('fortune_stories')
          .select('expires_at')
          .eq('user_id', userId);
      
      int totalEntries = 0;
      int validCount = 0;
      int expiredCount = 0;
      
      // Fortune cache 통계
      if (fortuneCacheResponse != null && fortuneCacheResponse is List) {
        for (final entry in fortuneCacheResponse) {
          totalEntries++;
          final expiresAt = DateTime.parse(entry['expires_at']);
          if (now.isAfter(expiresAt)) {
            expiredCount++;
          } else {
            validCount++;
          }
        }
      }
      
      // Story cache 통계
      if (storyCacheResponse != null && storyCacheResponse is List) {
        for (final entry in storyCacheResponse) {
          totalEntries++;
          final expiresAt = DateTime.parse(entry['expires_at']);
          if (now.isAfter(expiresAt)) {
            expiredCount++;
          } else {
            validCount++;
          }
        }
      }
      
      return {
        'total': totalEntries,
        'valid': validCount,
        'expired': expiredCount,
      };
    } catch (e) {
      debugPrint('DB cache stats error: $e');
      return {'total': 0, 'valid': 0, 'expired': 0};
    }
  }

  Future<List<FortuneModel>> getCachedFortunesByType(String fortuneType) async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return [];
      
      final now = DateTime.now();
      
      // DB에서 특정 타입의 캐시된 운세들 조회
      final response = await _supabase
          .from('fortune_cache')
          .select()
          .eq('user_id', userId)
          .eq('fortune_type', fortuneType)
          .gte('expires_at', now.toIso8601String())
          .order('created_at', ascending: false);
      
      if (response == null || response is! List) return [];
      
      final fortunes = <FortuneModel>[];
      for (final entry in response) {
        try {
          final fortuneData = entry['fortune_data'] as Map<String, dynamic>;
          fortunes.add(FortuneModel.fromJson(fortuneData));
        } catch (e) {
          debugPrint('Error parsing cached fortune: $e');
        }
      }
      
      return fortunes;
    } catch (e) {
      debugPrint('DB cache retrieval error: $e');
      return [];
    }
  }

  Future<List<FortuneModel>> getAllCachedFortunesForUser(String userId, {bool includeExpired = false}) async {
    try {
      final now = DateTime.now();
      
      // DB에서 사용자의 모든 캐시된 운세 조회
      var query = _supabase
          .from('fortune_cache')
          .select()
          .eq('user_id', userId);
      
      // 만료되지 않은 것만 가져오기 (옵션)
      if (!includeExpired) {
        query = query.gte('expires_at', now.toIso8601String());
      }
      
      final response = await query.order('created_at', ascending: false);
      
      if (response == null || response is! List) return [];
      
      final fortunes = <FortuneModel>[];
      for (final entry in response) {
        try {
          final fortuneData = entry['fortune_data'] as Map<String, dynamic>;
          fortunes.add(FortuneModel.fromJson(fortuneData));
        } catch (e) {
          debugPrint('Error parsing cached fortune: $e');
        }
      }
      
      return fortunes;
    } catch (e) {
      debugPrint('DB cache retrieval error: $e');
      return [];
    }
  }

  Future<bool> shouldUseOfflineMode() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;
      
      // DB에 캐시가 있는지 확인
      final response = await _supabase
          .from('fortune_cache')
          .select('id')
          .eq('user_id', userId)
          .limit(1)
          .maybeSingle();
          
      return response != null;
    } catch (e) {
      debugPrint('DB cache check error: $e');
      return false;
    }
  }

  Future<FortuneModel?> getMostRecentCachedFortune(String fortuneType, String userId) async {
    try {
      final now = DateTime.now();
      
      // DB에서 가장 최근의 캐시된 운세 조회
      final response = await _supabase
          .from('fortune_cache')
          .select()
          .eq('user_id', userId)
          .eq('fortune_type', fortuneType)
          .gte('expires_at', now.toIso8601String())
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();
      
      if (response == null) return null;
      
      try {
        final fortuneData = response['fortune_data'] as Map<String, dynamic>;
        return FortuneModel.fromJson(fortuneData);
      } catch (e) {
        debugPrint('Error parsing cached fortune: $e');
        return null;
      }
    } catch (e) {
      debugPrint('DB cache retrieval error: $e');
      return null;
    }
  }

  Future<void> preloadForOffline(String userId, List<String> fortuneTypes) async {
    try {
      // DB 기반에서는 preload가 필요 없음 (항상 온라인 DB 접근)
      debugPrint('Preloading not needed for DB-based cache');
    } catch (e) {
      debugPrint('Preload error: $e');
    }
  }

  void dispose() {
    // DB 기반에서는 dispose 불필요
    // Supabase client는 앱 레벨에서 관리됨
  }
}
