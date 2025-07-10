import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:fortune_flutter/data/services/fortune_api_service.dart';
import 'package:fortune_flutter/core/network/api_client.dart';
import 'package:fortune_flutter/services/cache_service.dart';
import 'package:fortune_flutter/models/fortune_model.dart';
import 'package:fortune_flutter/core/errors/exceptions.dart';
import 'package:fortune_flutter/core/constants/api_endpoints.dart';

// Mock classes
class MockApiClient extends Mock implements ApiClient {}

class MockCacheService extends Mock implements CacheService {}

class MockResponse extends Mock implements Response {}

// Fake classes
class FakeFortuneModel extends Fake implements FortuneModel {}

class FakeRequestOptions extends Fake implements RequestOptions {}

void main() {
  late FortuneApiService fortuneApiService;
  late MockApiClient mockApiClient;
  late MockCacheService mockCacheService;

  setUpAll(() {
    registerFallbackValue(FakeFortuneModel());
    registerFallbackValue(FakeRequestOptions());
  });

  setUp(() {
    mockApiClient = MockApiClient();
    mockCacheService = MockCacheService();
    fortuneApiService = FortuneApiService(mockApiClient);
  });

  group('FortuneApiService Tests', () {
    final testUserId = 'test-user-123';
    final testDate = DateTime.now();
    
    final testFortuneModel = FortuneModel(
      id: 'fortune-123',
      userId: testUserId,
      type: 'daily',
      content: 'Today is your lucky day!',
      createdAt: testDate,
      metadata: {'score': 85},
      tokenCost: 10,
    );
    
    final testFortuneJson = {
      'id': 'fortune-123',
      'userId': testUserId,
      'fortuneType': 'daily',
      'content': 'Today is your lucky day!',
      'category': 'general',
      'score': 85,
      'createdAt': testDate.toIso8601String(),
      'metadata': {'score': 85},
      'tokenCost': 10,
    };

    group('getDailyFortune', () {
      test('should return cached fortune when available', () async {
        // Arrange
        when(() => mockCacheService.getCachedFortune(
          'daily',
          {'userId': testUserId, 'date': testDate.toIso8601String()},
        )).thenAnswer((_) async => testFortuneModel);

        // Act
        final result = await fortuneApiService.getDailyFortune(
          userId: testUserId,
          date: testDate,
        );

        // Assert
        expect(result.id, equals('fortune-123'));
        expect(result.content, equals('Today is your lucky day!'));
        verifyNever(() => mockApiClient.get(any(), queryParameters: any(named: 'queryParameters')));
      });

      test('should fetch from API when cache is empty', () async {
        // Arrange
        when(() => mockCacheService.getCachedFortune(any(), any()))
            .thenAnswer((_) async => null);
        
        when(() => mockApiClient.get(
          ApiEndpoints.dailyFortune,
          queryParameters: any(named: 'queryParameters'),
        )).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: testFortuneJson,
        ));
        
        when(() => mockCacheService.cacheFortune(any(), any(), any()))
            .thenAnswer((_) async {});

        // Act
        final result = await fortuneApiService.getDailyFortune(
          userId: testUserId,
          date: testDate,
        );

        // Assert
        expect(result.content, equals('Today is your lucky day!'));
        verify(() => mockApiClient.get(
          ApiEndpoints.dailyFortune,
          queryParameters: {'date': testDate.toIso8601String()},
        )).called(1);
      });

      test('should return cached data on network error', () async {
        // Arrange
        when(() => mockCacheService.getCachedFortune(any(), any()))
            .thenAnswer((_) async => null);
        
        when(() => mockApiClient.get(any(), queryParameters: any(named: 'queryParameters')))
            .thenThrow(DioException(
              requestOptions: RequestOptions(path: ''),
              type: DioExceptionType.connectionError,
            ));
        
        when(() => mockCacheService.getCachedFortune(any(), any()))
            .thenAnswer((_) async => testFortuneModel);

        // Act
        final result = await fortuneApiService.getDailyFortune(
          userId: testUserId,
          date: testDate,
        );

        // Assert
        expect(result.id, equals('fortune-123'));
        expect(result.content, equals('Today is your lucky day!'));
      });

      test('should throw NetworkException when no cache and network error', () async {
        // Arrange
        when(() => mockCacheService.getCachedFortune(any(), any()))
            .thenAnswer((_) async => null);
        
        when(() => mockApiClient.get(any(), queryParameters: any(named: 'queryParameters')))
            .thenThrow(DioException(
              requestOptions: RequestOptions(path: ''),
              type: DioExceptionType.connectionError,
            ));

        // Act & Assert
        expect(
          () => fortuneApiService.getDailyFortune(
            userId: testUserId,
            date: testDate,
          ),
          throwsA(isA<NetworkException>()),
        );
      });

      test('should handle unauthorized error', () async {
        // Arrange
        when(() => mockCacheService.getCachedFortune(any(), any()))
            .thenAnswer((_) async => null);
        
        when(() => mockApiClient.get(any(), queryParameters: any(named: 'queryParameters')))
            .thenThrow(DioException(
              requestOptions: RequestOptions(path: ''),
              type: DioExceptionType.badResponse,
              response: Response(
                requestOptions: RequestOptions(path: ''),
                statusCode: 401,
              ),
            ));

        // Act & Assert
        expect(
          () => fortuneApiService.getDailyFortune(userId: testUserId),
          throwsA(isA<UnauthorizedException>()),
        );
      });
    });

    group('getSajuFortune', () {
      final birthDate = DateTime(1990, 1, 1);
      
      test('should return cached saju fortune when available', () async {
        // Arrange
        final sajuFortuneModel = FortuneModel(
          id: 'saju-123',
          userId: testUserId,
          type: 'saju',
          content: 'Your destiny is bright',
          createdAt: testDate,
          metadata: {'element': 'fire'},
          tokenCost: 20,
        );
        
        when(() => mockCacheService.getCachedFortune(
          'saju',
          {'userId': testUserId, 'birthDate': birthDate.toIso8601String()},
        )).thenAnswer((_) async => sajuFortuneModel);

        // Act
        final result = await fortuneApiService.getSajuFortune(
          userId: testUserId,
          birthDate: birthDate,
        );

        // Assert
        expect(result.id, equals('saju-123'));
        expect(result.content, equals('Your destiny is bright'));
        verifyNever(() => mockApiClient.post(any(), data: any(named: 'data')));
      });

      test('should fetch saju fortune from API and cache it', () async {
        // Arrange
        when(() => mockCacheService.getCachedFortune(any(), any()))
            .thenAnswer((_) async => null);
        
        when(() => mockApiClient.post(
          ApiEndpoints.sajuFortune,
          data: any(named: 'data'),
        )).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {
            ...testFortuneJson,
            'id': 'saju-123',
            'fortuneType': 'saju',
            'content': 'Your destiny is bright',
          },
        ));
        
        when(() => mockCacheService.cacheFortune(any(), any(), any()))
            .thenAnswer((_) async {});

        // Act
        final result = await fortuneApiService.getSajuFortune(
          userId: testUserId,
          birthDate: birthDate,
        );

        // Assert
        expect(result.content, equals('Your destiny is bright'));
        verify(() => mockApiClient.post(
          ApiEndpoints.sajuFortune,
          data: {'birthDate': birthDate.toIso8601String()},
        )).called(1);
        verify(() => mockCacheService.cacheFortune('saju', any(), any())).called(1);
      });
    });

    group('getCompatibilityFortune', () {
      test('should fetch compatibility fortune without caching', () async {
        // Arrange
        final person1 = {'name': 'Alice', 'birthDate': '1990-01-01'};
        final person2 = {'name': 'Bob', 'birthDate': '1992-05-15'};
        
        when(() => mockApiClient.post(
          ApiEndpoints.compatibilityFortune,
          data: any(named: 'data'),
        )).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {
            ...testFortuneJson,
            'fortuneType': 'compatibility',
            'content': 'You are 85% compatible!',
          },
        ));

        // Act
        final result = await fortuneApiService.getCompatibilityFortune(
          person1: person1,
          person2: person2,
        );

        // Assert
        expect(result.content, equals('You are 85% compatible!'));
        verify(() => mockApiClient.post(
          ApiEndpoints.compatibilityFortune,
          data: {'person1': person1, 'person2': person2},
        )).called(1);
      });
    });

    group('getFortune (generic)', () {
      test('should handle generic fortune requests with caching', () async {
        // Arrange
        final params = {'period': 'weekly', 'category': 'career'};
        
        when(() => mockCacheService.getCachedFortune(
          'weekly',
          {'userId': testUserId, ...params},
        )).thenAnswer((_) async => null);
        
        when(() => mockApiClient.post(
          '/api/fortune/weekly',
          data: any(named: 'data'),
        )).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: testFortuneJson,
        ));
        
        when(() => mockCacheService.cacheFortune(any(), any(), any()))
            .thenAnswer((_) async {});

        // Act
        final result = await fortuneApiService.getFortune(
          fortuneType: 'weekly',
          userId: testUserId,
          params: params,
        );

        // Assert
        expect(result.content, equals('Today is your lucky day!'));
        verify(() => mockApiClient.post('/api/fortune/weekly', data: params)).called(1);
      });

      test('should use GET request when no params provided', () async {
        // Arrange
        when(() => mockCacheService.getCachedFortune(
          'zodiac',
          {'userId': testUserId},
        )).thenAnswer((_) async => null);
        
        when(() => mockApiClient.get('/api/fortune/zodiac'))
            .thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: testFortuneJson,
        ));
        
        when(() => mockCacheService.cacheFortune(any(), any(), any()))
            .thenAnswer((_) async {});

        // Act
        final result = await fortuneApiService.getFortune(
          fortuneType: 'zodiac',
          userId: testUserId,
        );

        // Assert
        expect(result.content, equals('Today is your lucky day!'));
        verify(() => mockApiClient.get('/api/fortune/zodiac')).called(1);
      });
    });

    group('generateBatchFortunes', () {
      test('should generate multiple fortunes in batch', () async {
        // Arrange
        final fortuneTypes = ['daily', 'weekly', 'monthly'];
        
        when(() => mockApiClient.post(
          ApiEndpoints.batchFortune,
          data: any(named: 'data'),
        )).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {
            'fortunes': [
              {...testFortuneJson, 'fortuneType': 'daily'},
              {...testFortuneJson, 'fortuneType': 'weekly', 'content': 'Weekly fortune'},
              {...testFortuneJson, 'fortuneType': 'monthly', 'content': 'Monthly fortune'},
            ],
          },
        ));

        // Act
        final results = await fortuneApiService.generateBatchFortunes(
          userId: testUserId,
          fortuneTypes: fortuneTypes,
        );

        // Assert
        expect(results.length, equals(3));
        expect(results[0].content, equals('Today is your lucky day!'));
        expect(results[1].content, equals('Weekly fortune'));
        expect(results[2].content, equals('Monthly fortune'));
      });
    });

    group('getFortuneHistory', () {
      test('should fetch fortune history with pagination', () async {
        // Arrange
        when(() => mockApiClient.get(
          ApiEndpoints.fortuneHistory,
          queryParameters: any(named: 'queryParameters'),
        )).thenAnswer((_) async => Response(
          requestOptions: RequestOptions(path: ''),
          data: {
            'history': [
              testFortuneJson,
              {...testFortuneJson, 'id': 'fortune-124', 'content': 'Previous fortune'},
            ],
          },
        ));

        // Act
        final results = await fortuneApiService.getFortuneHistory(
          userId: testUserId,
          limit: 10,
          offset: 0,
        );

        // Assert
        expect(results.length, equals(2));
        expect(results[0].content, equals('Today is your lucky day!'));
        expect(results[1].content, equals('Previous fortune'));
        verify(() => mockApiClient.get(
          ApiEndpoints.fortuneHistory,
          queryParameters: {'limit': 10, 'offset': 0},
        )).called(1);
      });
    });

    group('Cache Management', () {
      test('should clear specific fortune cache', () async {
        // Arrange
        when(() => mockCacheService.removeCachedFortune(any(), any()))
            .thenAnswer((_) async {});

        // Act
        await fortuneApiService.clearFortuneCache('daily', testUserId);

        // Assert
        verify(() => mockCacheService.removeCachedFortune(
          'daily',
          {'userId': testUserId},
        )).called(1);
      });

      test('should clear all cache', () async {
        // Arrange
        when(() => mockCacheService.clearAllCache())
            .thenAnswer((_) async {});

        // Act
        await fortuneApiService.clearAllCache();

        // Assert
        verify(() => mockCacheService.clearAllCache()).called(1);
      });

      test('should get cache statistics', () async {
        // Arrange
        final stats = {
          'total': 10,
          'valid': 8,
          'expired': 2,
          'sizeInBytes': 1024,
        };
        
        when(() => mockCacheService.getCacheStats())
            .thenAnswer((_) async => stats);

        // Act
        final result = await fortuneApiService.getCacheStats();

        // Assert
        expect(result, equals(stats));
      });
    });

    group('Offline Support', () {
      test('should get offline fortunes by type', () async {
        // Arrange
        when(() => mockCacheService.getCachedFortunesByType('daily'))
            .thenAnswer((_) async => [testFortuneModel]);

        // Act
        final results = await fortuneApiService.getOfflineFortunes('daily');

        // Assert
        expect(results.length, equals(1));
        expect(results[0].content, equals('Today is your lucky day!'));
      });

      test('should get all cached fortunes for user', () async {
        // Arrange
        when(() => mockCacheService.getAllCachedFortunesForUser(
          testUserId,
          includeExpired: true,
        )).thenAnswer((_) async => [testFortuneModel]);

        // Act
        final results = await fortuneApiService.getAllCachedFortunes(
          testUserId,
          includeExpired: true,
        );

        // Assert
        expect(results.length, equals(1));
        expect(results[0].content, equals('Today is your lucky day!'));
      });

      test('should check offline mode status', () async {
        // Arrange
        when(() => mockCacheService.shouldUseOfflineMode())
            .thenAnswer((_) async => true);

        // Act
        final isOffline = await fortuneApiService.isOfflineMode();

        // Assert
        expect(isOffline, isTrue);
      });

      test('should preload fortunes for offline use', () async {
        // Arrange
        final essentialTypes = ['daily', 'weekly', 'monthly', 'zodiac', 'personality'];
        
        for (final type in essentialTypes) {
          when(() => mockCacheService.getCachedFortune(type, any()))
              .thenAnswer((_) async => null);
          
          when(() => mockApiClient.get('/api/fortune/$type'))
              .thenAnswer((_) async => Response(
            requestOptions: RequestOptions(path: ''),
            data: {...testFortuneJson, 'fortuneType': type},
          ));
          
          when(() => mockCacheService.cacheFortune(any(), any(), any()))
              .thenAnswer((_) async {});
        }

        // Act
        await fortuneApiService.preloadForOfflineUse(testUserId);

        // Assert
        for (final type in essentialTypes) {
          verify(() => mockApiClient.get('/api/fortune/$type')).called(1);
        }
      });
    });

    group('Error Handling', () {
      test('should handle connection timeout', () async {
        // Arrange
        when(() => mockCacheService.getCachedFortune(any(), any()))
            .thenAnswer((_) async => null);
        
        when(() => mockApiClient.get(any(), queryParameters: any(named: 'queryParameters')))
            .thenThrow(DioException(
              requestOptions: RequestOptions(path: ''),
              type: DioExceptionType.connectionTimeout,
            ));

        // Act & Assert
        expect(
          () => fortuneApiService.getDailyFortune(userId: testUserId),
          throwsA(isA<NetworkException>()
              .having((e) => e.message, 'message', '연결 시간이 초과되었습니다')),
        );
      });

      test('should handle rate limiting (429)', () async {
        // Arrange
        when(() => mockCacheService.getCachedFortune(any(), any()))
            .thenAnswer((_) async => null);
        
        when(() => mockApiClient.get(any(), queryParameters: any(named: 'queryParameters')))
            .thenThrow(DioException(
              requestOptions: RequestOptions(path: ''),
              type: DioExceptionType.badResponse,
              response: Response(
                requestOptions: RequestOptions(path: ''),
                statusCode: 429,
              ),
            ));

        // Act & Assert
        expect(
          () => fortuneApiService.getDailyFortune(userId: testUserId),
          throwsA(isA<TooManyRequestsException>()),
        );
      });

      test('should handle server error (500)', () async {
        // Arrange
        when(() => mockCacheService.getCachedFortune(any(), any()))
            .thenAnswer((_) async => null);
        
        when(() => mockApiClient.get(any(), queryParameters: any(named: 'queryParameters')))
            .thenThrow(DioException(
              requestOptions: RequestOptions(path: ''),
              type: DioExceptionType.badResponse,
              response: Response(
                requestOptions: RequestOptions(path: ''),
                statusCode: 500,
                data: {'message': 'Internal server error'},
              ),
            ));

        // Act & Assert
        expect(
          () => fortuneApiService.getDailyFortune(userId: testUserId),
          throwsA(isA<ServerException>()
              .having((e) => e.statusCode, 'statusCode', 500)),
        );
      });
    });
  });
}