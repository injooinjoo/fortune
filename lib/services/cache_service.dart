import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/fortune_model.dart';
import '../models/cache_entry.dart';
import '../screens/home/fortune_story_viewer.dart';

class CacheService {
  static const String _fortuneBoxName = 'fortunes';
  static const String _cacheMetaBoxName = 'cache_meta';
  static const String _storyBoxName = 'fortune_stories';

  static const Map<String, int> _cacheDuration = {
    'daily': 24,
    'hourly': 1,
    'weekly': 168,
    'monthly': 720,
    'yearly': 8760,
    'zodiac': 720,
    'personality': 8760,
    'default': 60};

  late Box<FortuneModel> _fortuneBox;
  late Box<CacheEntry> _cacheMetaBox;
  late Box _storyBox; // 스토리 세그먼트를 저장할 박스

  CacheService._internal();
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;

  Future<void> initialize() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(FortuneModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(CacheEntryAdapter());
    }

    // Open boxes if not already opened
    if (!Hive.isBoxOpen(_fortuneBoxName)) {
      _fortuneBox = await Hive.openBox<FortuneModel>(_fortuneBoxName);
    } else {
      _fortuneBox = Hive.box<FortuneModel>(_fortuneBoxName);
    }
    
    if (!Hive.isBoxOpen(_cacheMetaBoxName)) {
      _cacheMetaBox = await Hive.openBox<CacheEntry>(_cacheMetaBoxName);
    } else {
      _cacheMetaBox = Hive.box<CacheEntry>(_cacheMetaBoxName);
    }
    
    if (!Hive.isBoxOpen(_storyBoxName)) {
      _storyBox = await Hive.openBox(_storyBoxName);
    } else {
      _storyBox = Hive.box(_storyBoxName);
    }

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
      // Ensure adapters are registered
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(FortuneModelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(CacheEntryAdapter());
      }
      
      // Ensure boxes are initialized
      if (!Hive.isBoxOpen(_fortuneBoxName)) {
        _fortuneBox = await Hive.openBox<FortuneModel>(_fortuneBoxName);
      }
      if (!Hive.isBoxOpen(_cacheMetaBoxName)) {
        _cacheMetaBox = await Hive.openBox<CacheEntry>(_cacheMetaBoxName);
      }
      
      final key = _generateCacheKey(fortuneType, params);
      final cacheEntry = _cacheMetaBox.get(key);

      if (cacheEntry == null) return null;

      if (cacheEntry.isExpired) {
        await removeCachedFortune(fortuneType, params);
        return null;
      }

      return _fortuneBox.get(key);
    } catch (e) {
      debugPrint('Cache operation error: $e');
      return null;
    }
  }

  Future<void> cacheFortune(
    String fortuneType,
    Map<String, dynamic> params,
    FortuneModel fortune) async {
    try {
      // Ensure adapters are registered
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(FortuneModelAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(CacheEntryAdapter());
      }
      
      // Ensure boxes are initialized
      if (!Hive.isBoxOpen(_fortuneBoxName)) {
        _fortuneBox = await Hive.openBox<FortuneModel>(_fortuneBoxName);
      }
      if (!Hive.isBoxOpen(_cacheMetaBoxName)) {
        _cacheMetaBox = await Hive.openBox<CacheEntry>(_cacheMetaBoxName);
      }
      
      final key = _generateCacheKey(fortuneType, params);
      final duration = _cacheDuration[fortuneType] ?? _cacheDuration['default']!;
      final expiryDate = DateTime.now().add(Duration(hours: duration));

      await _fortuneBox.put(key, fortune);

      final cacheEntry = CacheEntry(
        key: key,
        fortuneType: fortuneType,
        createdAt: DateTime.now(),
        expiresAt: expiryDate);
      await _cacheMetaBox.put(key, cacheEntry);
    } catch (e) {
      debugPrint('Cache operation error: $e');
    }
  }

  Future<void> removeCachedFortune(
    String fortuneType,
    Map<String, dynamic> params,
  ) async {
    try {
      final key = _generateCacheKey(fortuneType, params);
      await _fortuneBox.delete(key);
      await _cacheMetaBox.delete(key);
    } catch (e) {
      debugPrint('Cache operation error: $e');
    }
  }

  // 스토리 세그먼트 캐싱 메서드
  Future<void> cacheStorySegments(
    String fortuneType,
    Map<String, dynamic> params,
    List<StorySegment> segments,
  ) async {
    try {
      // Ensure boxes are initialized
      if (!Hive.isBoxOpen(_storyBoxName)) {
        _storyBox = await Hive.openBox(_storyBoxName);
      }
      if (!Hive.isBoxOpen(_cacheMetaBoxName)) {
        _cacheMetaBox = await Hive.openBox<CacheEntry>(_cacheMetaBoxName);
      }
      
      final key = _generateCacheKey(fortuneType, params) + ':story';
      
      // 스토리 데이터를 Map 리스트로 변환
      final storyData = segments.map((segment) => {
        'text': segment.text,
        'subtitle': segment.subtitle,
        'fontSize': segment.fontSize,
        'fontWeight': segment.fontWeight?.index,
        'alignment': segment.alignment?.index,
        'emoji': segment.emoji,
      }).toList();
      
      // Store story data with metadata embedded
      final duration = _cacheDuration[fortuneType] ?? _cacheDuration['default']!;
      final expiryDate = DateTime.now().add(Duration(hours: duration));
      
      final storyWithMeta = {
        'segments': storyData,
        'createdAt': DateTime.now().toIso8601String(),
        'expiresAt': expiryDate.toIso8601String(),
      };
      
      await _storyBox.put(key, storyWithMeta);
      
      debugPrint('✅ Successfully cached ${storyData.length} story segments with key: $key');
      debugPrint('📦 Story box now contains ${_storyBox.length} items');
      debugPrint('📦 All story box keys: ${_storyBox.keys.toList()}');
    } catch (e) {
      debugPrint('Story cache operation error: $e');
    }
  }
  
  Future<List<StorySegment>?> getCachedStorySegments(
    String fortuneType,
    Map<String, dynamic> params,
  ) async {
    try {
      // Ensure boxes are initialized
      if (!Hive.isBoxOpen(_storyBoxName)) {
        _storyBox = await Hive.openBox(_storyBoxName);
      }
      if (!Hive.isBoxOpen(_cacheMetaBoxName)) {
        _cacheMetaBox = await Hive.openBox<CacheEntry>(_cacheMetaBoxName);
      }
      
      final key = _generateCacheKey(fortuneType, params) + ':story';
      debugPrint('🔍 Looking for cached story with key: $key');
      
      // Also list all keys in the story box for debugging
      debugPrint('📦 Story box keys: ${_storyBox.keys.toList()}');
      
      final storyWithMeta = _storyBox.get(key);
      if (storyWithMeta == null) {
        debugPrint('❌ No cached story found for key: $key');
        return null;
      }
      
      // Check expiry
      if (storyWithMeta['expiresAt'] != null) {
        final expiryDate = DateTime.parse(storyWithMeta['expiresAt']);
        if (DateTime.now().isAfter(expiryDate)) {
          await _storyBox.delete(key);
          return null;
        }
      }
      
      final storyData = storyWithMeta['segments'];
      if (storyData == null) {
        debugPrint('❌ No segments data in cached story');
        return null;
      }
      
      debugPrint('✅ Found cached story with ${(storyData as List).length} segments');
      
      // Map 리스트를 StorySegment 리스트로 변환
      return (storyData as List).map((data) {
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
      debugPrint('Story cache retrieval error: $e');
      return null;
    }
  }

  Future<void> clearAllCache() async {
    try {
      await _fortuneBox.clear();
      await _cacheMetaBox.clear();
      await _storyBox.clear();
    } catch (e) {
      debugPrint('Cache operation error: $e');
    }
  }

  Future<void> cleanExpiredCache() async {
    try {
      final expiredKeys = <String>[];
      for (final entry in _cacheMetaBox.values) {
        if (entry.isExpired) {
          expiredKeys.add(entry.key);
        }
      }
      for (final key in expiredKeys) {
        await _fortuneBox.delete(key);
        await _cacheMetaBox.delete(key);
      }
      debugPrint('Cleaned ${expiredKeys.length} expired cache entries');
    } catch (e) {
      debugPrint('Cache operation error: $e');
    }
  }

  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final totalEntries = _cacheMetaBox.length;
      int expiredCount = 0;
      int validCount = 0;
      for (final entry in _cacheMetaBox.values) {
        if (entry.isExpired) {
          expiredCount++;
        } else {
          validCount++;
        }
      }
      return {
        'total': totalEntries,
        'valid': validCount,
        'expired': expiredCount,
        'sizeInBytes': _fortuneBox.path != null
            ? await _calculateBoxSize(_fortuneBox.path!)
            : 0};
    } catch (e) {
      debugPrint('Cache operation error: $e');
      return {
        'total': 0,
        'valid': 0,
        'expired': 0,
        'sizeInBytes': 0};
    }
  }

  Future<int> _calculateBoxSize(String path) async {
    return _fortuneBox.length * 1024;
  }

  Future<List<FortuneModel>> getCachedFortunesByType(String fortuneType) async {
    try {
      final fortunes = <FortuneModel>[];
      for (final entry in _cacheMetaBox.values) {
        if (entry.fortuneType == fortuneType && !entry.isExpired) {
          final fortune = _fortuneBox.get(entry.key);
          if (fortune != null) {
            fortunes.add(fortune);
          }
        }
      }
      return fortunes;
    } catch (e) {
      debugPrint('Cache operation error: $e');
      return [];
    }
  }

  Future<List<FortuneModel>> getAllCachedFortunesForUser(String userId, {bool includeExpired = false}) async {
    try {
      final fortunes = <FortuneModel>[];
      for (final entry in _cacheMetaBox.values) {
        if (entry.key.startsWith('$userId:')) {
          if (includeExpired || !entry.isExpired) {
            final fortune = _fortuneBox.get(entry.key);
            if (fortune != null) {
              fortunes.add(fortune);
            }
          }
        }
      }
      fortunes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return fortunes;
    } catch (e) {
      debugPrint('Cache operation error: $e');
      return [];
    }
  }

  Future<bool> shouldUseOfflineMode() async {
    try {
      final hasCache = _fortuneBox.isNotEmpty;
      return hasCache;
    } catch (e) {
      debugPrint('Cache operation error: $e');
      return false;
    }
  }

  Future<FortuneModel?> getMostRecentCachedFortune(String fortuneType, String userId) async {
    try {
      FortuneModel? mostRecent;
      DateTime? mostRecentDate;
      for (final entry in _cacheMetaBox.values) {
        if (entry.fortuneType == fortuneType && entry.key.startsWith('$userId:')) {
          final fortune = _fortuneBox.get(entry.key);
          if (fortune != null) {
            if (mostRecentDate == null || fortune.createdAt.isAfter(mostRecentDate)) {
              mostRecent = fortune;
              mostRecentDate = fortune.createdAt;
            }
          }
        }
      }
      return mostRecent;
    } catch (e) {
      debugPrint('Cache operation error: $e');
      return null;
    }
  }

  Future<void> preloadForOffline(String userId, List<String> fortuneTypes) async {
    try {
      debugPrint('Preloading \${fortuneTypes.length} fortune types for offline use');
    } catch (e) {
      debugPrint('Cache operation error: $e');
    }
  }

  void dispose() {
    _fortuneBox.close();
    _cacheMetaBox.close();
  }
}
