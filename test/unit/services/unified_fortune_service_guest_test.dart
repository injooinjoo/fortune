import 'package:flutter_test/flutter_test.dart';
import 'package:ondo/core/models/cached_fortune_result.dart';
import 'package:ondo/core/models/fortune_result.dart';
import 'package:ondo/core/services/fortune_optimization_service.dart';
import 'package:ondo/core/services/generator_factory.dart';
import 'package:ondo/core/services/unified_fortune_service.dart';
import 'package:ondo/features/fortune/domain/models/fortune_conditions.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/mock_auth_services.dart';

class _FakeFortuneConditions extends FortuneConditions {
  @override
  Map<String, dynamic> buildAPIPayload() => const {'period': 'daily'};

  @override
  String generateHash() => 'hash-daily';

  @override
  Map<String, dynamic> toIndexableFields() => const {'fortune_type': 'daily'};

  @override
  Map<String, dynamic> toJson() => const {'fortune_type': 'daily'};
}

class _TrackingGeneratorFactory extends GeneratorFactory {
  _TrackingGeneratorFactory(this.result) : super(MockSupabaseClient());

  final FortuneResult result;
  bool called = false;

  @override
  Future<FortuneResult> generate({
    required String fortuneType,
    required Map<String, dynamic> inputConditions,
    required GeneratorDataSource dataSource,
  }) async {
    called = true;
    return result;
  }
}

class _TrackingOptimizationService extends FortuneOptimizationService {
  _TrackingOptimizationService({
    CachedFortuneResult? cachedResult,
  })  : _cachedResult = cachedResult,
        super(supabase: MockSupabaseClient());

  final CachedFortuneResult? _cachedResult;
  bool called = false;

  @override
  Future<CachedFortuneResult> getFortune({
    required String userId,
    required String fortuneType,
    required FortuneConditions conditions,
    required Future<Map<String, dynamic>> Function(Map<String, dynamic>)
        onAPICall,
    Map<String, dynamic>? inputConditions,
  }) async {
    called = true;
    if (_cachedResult != null) {
      return _cachedResult;
    }
    throw StateError('Optimization service should not have been called');
  }
}

void main() {
  group('UnifiedFortuneService guest optimization', () {
    late MockSupabaseClient supabaseClient;
    late MockGoTrueClient authClient;
    late MockStorageService storageService;

    setUp(() {
      supabaseClient = MockSupabaseClient();
      authClient = MockGoTrueClient();
      storageService = MockStorageService();

      when(() => supabaseClient.auth).thenReturn(authClient);
    });

    test('guest users bypass optimization and go straight to direct API flow',
        () async {
      when(() => authClient.currentUser).thenReturn(null);
      when(() => storageService.getOrCreateGuestId()).thenAnswer(
        (_) async => 'guest_test-user-id',
      );

      final optimizationService = _TrackingOptimizationService();
      final generatorFactory = _TrackingGeneratorFactory(
        FortuneResult(
          type: 'daily',
          title: '오늘의 운세',
          summary: const {'message': '직접 API 호출 결과'},
          data: const {'content': '게스트 직통 결과'},
          score: 88,
        ),
      );

      final service = UnifiedFortuneService(
        supabaseClient,
        optimizationService: optimizationService,
        generatorFactory: generatorFactory,
        storageService: storageService,
      );

      final result = await service.getFortune(
        fortuneType: 'daily',
        dataSource: FortuneDataSource.api,
        inputConditions: const {'period': 'daily'},
        conditions: _FakeFortuneConditions(),
      );

      expect(optimizationService.called, isFalse);
      expect(generatorFactory.called, isTrue);
      expect(result.title, '오늘의 운세');
      expect(result.summary['message'], '직접 API 호출 결과');
    });

    test('authenticated users still use optimization when enabled', () async {
      final user = AuthTestData.createMockUser(
          id: '11111111-1111-1111-1111-111111111111');
      when(() => authClient.currentUser).thenReturn(user);

      final now = DateTime(2026, 3, 16);
      final optimizationService = _TrackingOptimizationService(
        cachedResult: CachedFortuneResult(
          id: 'cached-id',
          userId: user.id,
          fortuneType: 'daily',
          resultData: const {
            'title': '캐시된 오늘의 운세',
            'summary': '캐시 히트',
            'content': '캐시 결과 본문',
            'overallScore': 77,
          },
          conditionsHash: 'hash-daily',
          conditionsData: const {'fortune_type': 'daily'},
          createdAt: now,
          updatedAt: now,
          source: 'personal_cache',
          apiCall: false,
        ),
      );
      final generatorFactory = _TrackingGeneratorFactory(
        FortuneResult(
          type: 'daily',
          title: '직접 호출되면 안 됨',
          summary: const {'message': 'should not use generator'},
          data: const {'content': 'should not use generator'},
        ),
      );

      final service = UnifiedFortuneService(
        supabaseClient,
        optimizationService: optimizationService,
        generatorFactory: generatorFactory,
        storageService: storageService,
      );

      final result = await service.getFortune(
        fortuneType: 'daily',
        dataSource: FortuneDataSource.api,
        inputConditions: const {'period': 'daily'},
        conditions: _FakeFortuneConditions(),
      );

      expect(optimizationService.called, isTrue);
      expect(generatorFactory.called, isFalse);
      expect(result.title, '캐시된 오늘의 운세');
      expect(result.summary['message'], '캐시 히트');
    });
  });
}
