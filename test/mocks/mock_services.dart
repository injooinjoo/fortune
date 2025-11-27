import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fortune/data/services/fortune_api_service.dart';
import 'package:fortune/data/services/token_api_service.dart';
import 'package:fortune/domain/entities/fortune.dart';
import 'package:fortune/domain/entities/token.dart';
import 'package:fortune/services/cache_service.dart';

// Mock Classes
class MockFortuneApiService extends Mock implements FortuneApiService {}

class MockTokenApiService extends Mock implements TokenApiService {}

class MockCacheService extends Mock implements CacheService {}

class MockRef extends Mock implements Ref {}

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

// Test Data Factories
class TestData {
  static Fortune createTestFortune({
    String id = 'test-fortune-id',
    String type = 'daily',
    String content = '오늘의 운세입니다.',
    int overallScore = 85,
    String? description,
    List<String>? luckyItems,
    List<String>? recommendations,
  }) {
    return Fortune(
      id: id,
      type: type,
      content: content,
      overallScore: overallScore,
      description: description ?? '좋은 하루가 될 것입니다.',
      luckyItems: luckyItems ?? ['행운의 숫자: 7', '행운의 색: 파랑'],
      recommendations: recommendations ?? ['긍정적인 마음을 유지하세요'],
      category: 'general',
      createdAt: DateTime.now(),
    );
  }

  static TokenBalance createTestTokenBalance({
    int remainingTokens = 10,
    int usedTokens = 5,
    int totalTokens = 15,
    bool hasUnlimitedAccess = false,
  }) {
    return TokenBalance(
      remainingTokens: remainingTokens,
      usedTokens: usedTokens,
      totalTokens: totalTokens,
      hasUnlimitedAccess: hasUnlimitedAccess,
    );
  }

  static User createMockUser({
    String id = 'test-user-id',
    String? email = 'test@example.com',
  }) {
    final mockUser = MockUser();
    when(() => mockUser.id).thenReturn(id);
    when(() => mockUser.email).thenReturn(email);
    when(() => mockUser.userMetadata).thenReturn({
      'full_name': 'Test User',
      'birthDate': '1990-01-01',
    });
    return mockUser;
  }
}

// Register fallback values for mocktail
void registerFallbackValues() {
  registerFallbackValue(DateTime.now());
  registerFallbackValue(<String, dynamic>{});
}
