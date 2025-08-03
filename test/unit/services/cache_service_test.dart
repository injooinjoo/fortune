import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fortune/services/cache_service.dart';
import 'package:fortune/models/fortune_model.dart';
import 'package:fortune/models/cache_entry.dart';

// Mock classes
class MockBox<T> extends Mock implements Box<T> {}

class MockHiveInterface extends Mock implements HiveInterface {}

// Fake classes for setUpAll
class FakeFortuneModel extends Fake implements FortuneModel {}

class FakeCacheEntry extends Fake implements CacheEntry {}

// Test wrapper for CacheService that allows mocking
class TestCacheService {
  final MockBox<FortuneModel> _mockFortuneBox;
  final MockBox<CacheEntry> _mockCacheMetaBox;
  
  TestCacheService(this._mockFortuneBox, this._mockCacheMetaBox);
  
  // Expose methods that mirror CacheService's public interface
  String generateCacheKey(String fortuneType, Map<String, dynamic> params) {
    final userId = params['userId'] ?? 'anonymous';
    final sortedParams = Map.fromEntries(
      params.entries.where((e) => e.key != 'userId').toList()
        ..sort((a, b) => a.key.compareTo(b.key))
    );
    final dateKey = _getDateKeyForType(fortuneType);
    final paramsString = sortedParams.isEmpty ? '' : ':${sortedParams.toString()}';
    return '$userId:$fortuneType:$dateKey$paramsString';
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
      final key = generateCacheKey(fortuneType, params);
      final cacheEntry = _mockCacheMetaBox.get(key);
      
      if (cacheEntry == null) return null;
      
      if (cacheEntry.isExpired) {
        await _mockFortuneBox.delete(key);
        await _mockCacheMetaBox.delete(key);
        return null;
      }
      
      return _mockFortuneBox.get(key);
    } catch (e) {
      debugPrint('Supabase initialized with URL: $supabaseUrl');
      return null;
    }
  }
  
  Future<void> cacheFortune(
    String fortuneType,
    Map<String, dynamic> params,
    FortuneModel fortune,
  ) async {
    try {
      final key = generateCacheKey(fortuneType, params);
      final duration = cacheDuration[fortuneType] ?? cacheDuration['default']!;
      final expiryDate = DateTime.now().add(Duration(hours: duration));
      
      await _mockFortuneBox.put(key, fortune);
      
      final cacheEntry = CacheEntry(
        key: key,
        fortuneType: fortuneType,
        createdAt: DateTime.now(),
        expiresAt: expiryDate,
      );
      await _mockCacheMetaBox.put(key, cacheEntry);
    } catch (e) {
      debugPrint('Supabase initialized with URL: $supabaseUrl');
    }
  }
  
  Future<void> clearAllCache() async {
    try {
      await _mockFortuneBox.clear();
      await _mockCacheMetaBox.clear();
    } catch (e) {
      debugPrint('Supabase initialized with URL: $supabaseUrl');
    }
  }
  
  Future<void> cleanExpiredCache() async {
    try {
      final expiredKeys = <String>[];
      
      for (final entry in _mockCacheMetaBox.values) {
        if (entry.isExpired) {
          expiredKeys.add(entry.key);
        }
      }
      
      for (final key in expiredKeys) {
        await _mockFortuneBox.delete(key);
        await _mockCacheMetaBox.delete(key);
      }
    } catch (e) {
      debugPrint('Supabase initialized with URL: $supabaseUrl');
    }
  }
  
  Future<Map<String, dynamic>> getCacheStats() async {
    try {
      final totalEntries = _mockCacheMetaBox.length;
      int expiredCount = 0;
      int validCount = 0;
      
      for (final entry in _mockCacheMetaBox.values) {
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
        'sizeInBytes'),
      };
    } catch (e) {
      return {
        'total': 0,
        'valid': 0,
        'expired': 0,
        'sizeInBytes'),
      };
    }
  }
  
  Future<List<FortuneModel>> getAllCachedFortunesForUser(String userId) async {
    try {
      final fortunes = <FortuneModel>[];
      
      for (final entry in _mockCacheMetaBox.values) {
        if (entry.key.startsWith('$userId:') && !entry.isExpired) {
          final fortune = _mockFortuneBox.get(entry.key);
          if (fortune != null) {
            fortunes.add(fortune);
          }
        }
      }
      
      fortunes.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return fortunes;
    } catch (e) {
      return [];
    }
  }
  
  Future<FortuneModel?> getMostRecentCachedFortune(String fortuneType, String userId) async {
    try {
      FortuneModel? mostRecent;
      DateTime? mostRecentDate;
      
      for (final entry in _mockCacheMetaBox.values) {
        if (entry.key.startsWith('$userId:$fortuneType:') && !entry.isExpired) {
          if (mostRecentDate == null || entry.createdAt.isAfter(mostRecentDate)) {
            final fortune = _mockFortuneBox.get(entry.key);
            if (fortune != null) {
              mostRecent = fortune;
              mostRecentDate = entry.createdAt;
            }
          }
        }
      }
      
      return mostRecent;
    } catch (e) {
      return null;
    }
  }
  
  Map<String, int> get cacheDuration => {
    'daily': 24,
    'hourly': 1,
    'weekly': 168,
    'monthly': 720,
    'yearly': 8760,
    'zodiac': 720,
    'personality': 8760,
    'default'),
  };
}

void main() {
  late TestCacheService cacheService;
  late MockBox<FortuneModel> mockFortuneBox;
  late MockBox<CacheEntry> mockCacheMetaBox;
  late MockHiveInterface mockHive;

  setUpAll(() {
    registerFallbackValue(FakeFortuneModel());
    registerFallbackValue(FakeCacheEntry());
  });

  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockFortuneBox = MockBox<FortuneModel>();
    mockCacheMetaBox = MockBox<CacheEntry>();
    mockHive = MockHiveInterface();
    
    cacheService = TestCacheService(mockFortuneBox, mockCacheMetaBox);
  });

  group('CacheService Tests', () {
    group('Cache Key Generation', () {
      test('should generate unique keys for different fortune types', () {
        final now = DateTime.now();
        final params = {'userId': 'test123'};
        
        // Test that daily fortune keys change by day
        final dailyKey1 = cacheService.generateCacheKey('daily', params);
        final dailyKey2 = cacheService.generateCacheKey('daily', params);
        expect(dailyKey1, equals(dailyKey2));
        
        // Test that different fortune types have different keys
        final weeklyKey = cacheService.generateCacheKey('weekly', params);
        expect(dailyKey1, isNot(equals(weeklyKey)));
      });

      test('should include all params in cache key', () {
        final params1 = {'userId': 'test123', 'birthDate': '1990-01-01'};
        final params2 = {'userId': 'test123', 'birthDate': '1990-01-02'};
        
        final key1 = cacheService.generateCacheKey('zodiac', params1);
        final key2 = cacheService.generateCacheKey('zodiac', params2);
        
        expect(key1, isNot(equals(key2)));
      });

      test('should handle anonymous users', () {
        final params = {}; // No userId
        final key = cacheService.generateCacheKey('daily', Map<String, dynamic>.from(params));
        
        expect(key, contains('anonymous'));
      });
    });

    group('Fortune Caching', () {
      test('should cache fortune successfully', () async {
        // Arrange
        final fortune = FortuneModel(
          id: 'test-id',
          userId: 'test123',
          type: 'daily',
          content: 'Test fortune content',
          createdAt: DateTime.now(),
          metadata: {},
        );
        
        final params = {'userId': 'test123'};
        
        when(() => mockFortuneBox.put(any(), any())).thenAnswer((_) async {});
        when(() => mockCacheMetaBox.put(any(), any())).thenAnswer((_) async {});
        
        // Act
        await cacheService.cacheFortune('daily', params, fortune);
        
        // Assert
        verify(() => mockFortuneBox.put(any(), fortune)).called(1);
        verify(() => mockCacheMetaBox.put(any(), any())).called(1);
      });

      test('should retrieve cached fortune when not expired', () async {
        // Arrange
        final fortune = FortuneModel(
          id: 'test-id',
          userId: 'test123',
          type: 'daily',
          content: 'Test fortune content',
          createdAt: DateTime.now(),
          metadata: {},
        );
        
        final cacheEntry = CacheEntry(
          key: 'test-key',
          fortuneType: 'daily',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(hours: 24)),
        );
        
        final params = {'userId': 'test123'};
        
        when(() => mockCacheMetaBox.get(any())).thenReturn(cacheEntry);
        when(() => mockFortuneBox.get(any())).thenReturn(fortune);
        
        // Act
        final result = await cacheService.getCachedFortune('daily', params);
        
        // Assert
        expect(result, equals(fortune));
      });

      test('should return null for expired cache', () async {
        // Arrange
        final expiredCacheEntry = CacheEntry(
          key: 'test-key',
          fortuneType: 'daily',
          createdAt: DateTime.now().subtract(Duration(days: 2)),
          expiresAt: DateTime.now().subtract(Duration(days: 1)),
        );
        
        final params = {'userId': 'test123'};
        
        when(() => mockCacheMetaBox.get(any())).thenReturn(expiredCacheEntry);
        when(() => mockFortuneBox.delete(any())).thenAnswer((_) async {});
        when(() => mockCacheMetaBox.delete(any())).thenAnswer((_) async {});
        
        // Act
        final result = await cacheService.getCachedFortune('daily', params);
        
        // Assert
        expect(result, isNull);
        verify(() => mockFortuneBox.delete(any())).called(1);
        verify(() => mockCacheMetaBox.delete(any())).called(1);
      });
    });

    group('Cache Management', () {
      test('should clear all cache', () async {
        // Arrange
        when(() => mockFortuneBox.clear()).thenAnswer((_) async => 0);
        when(() => mockCacheMetaBox.clear()).thenAnswer((_) async => 0);
        
        // Act
        await cacheService.clearAllCache();
        
        // Assert
        verify(() => mockFortuneBox.clear()).called(1);
        verify(() => mockCacheMetaBox.clear()).called(1);
      });

      test('should clean expired cache entries', () async {
        // Arrange
        final expiredEntry = CacheEntry(
          key: 'expired-key',
          fortuneType: 'daily',
          createdAt: DateTime.now().subtract(Duration(days: 2)),
          expiresAt: DateTime.now().subtract(Duration(days: 1)),
        );
        
        final validEntry = CacheEntry(
          key: 'valid-key',
          fortuneType: 'daily',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(days: 1)),
        );
        
        when(() => mockCacheMetaBox.values).thenReturn([expiredEntry, validEntry]);
        when(() => mockFortuneBox.delete(any())).thenAnswer((_) async {});
        when(() => mockCacheMetaBox.delete(any())).thenAnswer((_) async {});
        
        // Act
        await cacheService.cleanExpiredCache();
        
        // Assert
        verify(() => mockFortuneBox.delete('expired-key')).called(1);
        verify(() => mockCacheMetaBox.delete('expired-key')).called(1);
        verifyNever(() => mockFortuneBox.delete('valid-key'));
        verifyNever(() => mockCacheMetaBox.delete('valid-key'));
      });

      test('should get cache statistics', () async {
        // Arrange
        final entries = [
          CacheEntry(
            key: 'key1',
            fortuneType: 'daily',
            createdAt: DateTime.now(),
            expiresAt: DateTime.now().add(Duration(days: 1)),
          ),
          CacheEntry(
            key: 'key2',
            fortuneType: 'weekly',
            createdAt: DateTime.now().subtract(Duration(days: 8)),
            expiresAt: DateTime.now().subtract(Duration(days: 1)),
          ),
        ];
        
        when(() => mockCacheMetaBox.length).thenReturn(2);
        when(() => mockCacheMetaBox.values).thenReturn(entries);
        when(() => mockFortuneBox.path).thenReturn('/test/path');
        when(() => mockFortuneBox.length).thenReturn(2);
        
        // Act
        final stats = await cacheService.getCacheStats();
        
        // Assert
        expect(stats['total'], equals(2));
        expect(stats['valid'], equals(1));
        expect(stats['expired'], equals(1));
        expect(stats['sizeInBytes'], greaterThan(0));
      });
    });

    group('User-specific Cache Operations', () {
      test('should get all cached fortunes for a user', () async {
        // Arrange
        final userId = 'test123';
        final fortune1 = FortuneModel(
          id: 'fortune1',
          userId: userId,
          type: 'daily',
          content: 'Fortune 1',
          createdAt: DateTime.now(),
          metadata: {},
        );
        
        final fortune2 = FortuneModel(
          id: 'fortune2',
          userId: userId,
          type: 'weekly',
          content: 'Fortune 2',
          createdAt: DateTime.now().subtract(Duration(days: 1)),
          metadata: {},
        );
        
        final entry1 = CacheEntry(
          key: 'test123:daily:2024-01-01',
          fortuneType: 'daily',
          createdAt: DateTime.now(),
          expiresAt: DateTime.now().add(Duration(days: 1)),
        );
        
        final entry2 = CacheEntry(
          key: 'test123:weekly:2024-W1',
          fortuneType: 'weekly',
          createdAt: DateTime.now().subtract(Duration(days: 1)),
          expiresAt: DateTime.now().add(Duration(days: 6)),
        );
        
        when(() => mockCacheMetaBox.values).thenReturn([entry1, entry2]);
        when(() => mockFortuneBox.get(entry1.key)).thenReturn(fortune1);
        when(() => mockFortuneBox.get(entry2.key)).thenReturn(fortune2);
        
        // Act
        final fortunes = await cacheService.getAllCachedFortunesForUser(userId);
        
        // Assert
        expect(fortunes.length, equals(2));
        expect(fortunes[0].id, equals('fortune1')); // Most recent first
        expect(fortunes[1].id, equals('fortune2'));
      });

      test('should get most recent cached fortune for type', () async {
        // Arrange
        final userId = 'test123';
        final olderFortune = FortuneModel(
          id: 'older',
          userId: userId,
          type: 'daily',
          content: 'Older fortune',
          createdAt: DateTime.now().subtract(Duration(days: 2)),
          metadata: {},
        );
        
        final newerFortune = FortuneModel(
          id: 'newer',
          userId: userId,
          type: 'daily',
          content: 'Newer fortune',
          createdAt: DateTime.now().subtract(Duration(days: 1)),
          metadata: {},
        );
        
        final entry1 = CacheEntry(
          key: 'test123:daily:2024-01-01',
          fortuneType: 'daily',
          createdAt: DateTime.now().subtract(Duration(days: 2)),
          expiresAt: DateTime.now().add(Duration(days: 1)),
        );
        
        final entry2 = CacheEntry(
          key: 'test123:daily:2024-01-02',
          fortuneType: 'daily',
          createdAt: DateTime.now().subtract(Duration(days: 1)),
          expiresAt: DateTime.now().add(Duration(days: 1)),
        );
        
        when(() => mockCacheMetaBox.values).thenReturn([entry1, entry2]);
        when(() => mockFortuneBox.get(entry1.key)).thenReturn(olderFortune);
        when(() => mockFortuneBox.get(entry2.key)).thenReturn(newerFortune);
        
        // Act
        final result = await cacheService.getMostRecentCachedFortune('daily', userId);
        
        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals('newer'));
      });
    });

    group('Cache Duration', () {
      test('should use correct cache duration for each fortune type', () {
        final durations = cacheService.cacheDuration;
        
        expect(durations['daily'], equals(24));
        expect(durations['hourly'], equals(1));
        expect(durations['weekly'], equals(168));
        expect(durations['monthly'], equals(720));
        expect(durations['yearly'], equals(8760));
        expect(durations['zodiac'], equals(720));
        expect(durations['personality'], equals(8760));
        expect(durations['default'], equals(72));
      });
    });
  });
}

