import 'package:fortune/data/models/user_profile.dart';
import 'package:fortune/data/models/fortune_response_model.dart';
import 'package:fortune/domain/entities/fortune.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Factory for creating mock data for tests
class MockFactory {
  static UserProfile createUserProfile({
    String? id,
    String? userId,
    String? email,
    String? name,
    DateTime? birthDate,
    String? gender,
    String? birthTime,
    int? tokenBalance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    final userIdValue = userId ?? id ?? 'test-user-123';
    return UserProfile(
      id: id ?? userIdValue,
      userId: userIdValue,
      email: email ?? 'test@example.com',
      name: name ?? '테스트 사용자',
      birthDate: birthDate ?? DateTime(1990, 1, 1),
      gender: gender ?? 'male',
      birthTime: birthTime,
      tokenBalance: tokenBalance ?? 100,
      createdAt: createdAt ?? DateTime.now(),
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
  
  static FortuneResponseModel createFortuneResponse({
    bool? success,
    String? message,
    String? type,
    String? content,
    int? tokensUsed,
    int? remainingTokens,
    Map<String, dynamic>? metadata,
  }) {
    return FortuneResponseModel(
      success: success ?? true,
      message: message,
      data: FortuneData(
        type: type ?? 'daily',
        content: content ?? '오늘은 행운이 가득한 날입니다.',
        metadata: metadata ?? {'score': 85},
      ),
      tokensUsed: tokensUsed ?? 10,
      remainingTokens: remainingTokens ?? 90,
    );
  }
  
  static Fortune createFortune({
    String? id,
    String? userId,
    String? type,
    String? content,
    Map<String, dynamic>? metadata,
    int? tokenCost,
    DateTime? createdAt,
  }) {
    return Fortune(
      id: id ?? 'fortune-123',
      userId: userId ?? 'test-user-123',
      type: type ?? 'daily',
      content: content ?? '오늘은 행운이 가득한 날입니다.',
      metadata: metadata ?? {'score': 85},
      tokenCost: tokenCost ?? 10,
      createdAt: createdAt ?? DateTime.now(),
    );
  }
  
  static User createSupabaseUser({
    String? id,
    String? email,
    String? phone,
    DateTime? createdAt,
    Map<String, dynamic>? userMetadata,
  }) {
    return User(
      id: id ?? 'test-user-123',
      appMetadata: {},
      userMetadata: userMetadata ?? {'name': '테스트 사용자'},
      aud: 'authenticated',
      createdAt: (createdAt ?? DateTime.now()).toIso8601String(),
      email: email ?? 'test@example.com',
      phone: phone,
    );
  }
  
  static Session createSupabaseSession({
    String? accessToken,
    String? refreshToken,
    int? expiresIn,
    String? tokenType,
    User? user,
  }) {
    return Session(
      accessToken: accessToken ?? 'test-access-token',
      refreshToken: refreshToken ?? 'test-refresh-token',
      expiresIn: expiresIn ?? 3600,
      tokenType: tokenType ?? 'bearer',
      user: user ?? createSupabaseUser(),
    );
  }
  
  static Map<String, dynamic> createTokenPurchaseData({
    String? productId,
    int? tokenAmount,
    double? price,
    String? currency,
  }) {
    return {
      'productId': productId ?? 'tokens_100',
      'tokenAmount': tokenAmount ?? 100,
      'price': price ?? 5.99,
      'currency': currency ?? 'USD',
    };
  }
  
  static Map<String, dynamic> createSocialAuthData({
    String? provider,
    String? providerId,
    String? email,
    String? name,
    String? photoUrl,
  }) {
    return {
      'provider': provider ?? 'google',
      'providerId': providerId ?? 'google-123',
      'email': email ?? 'test@gmail.com',
      'name': name ?? 'Test User',
      'photoUrl': photoUrl ?? 'https://example.com/photo.jpg',
    };
  }
  
  static List<Fortune> createFortuneHistory({
    int count = 5,
    String? userId,
  }) {
    return List.generate(
      count,
      (index) => createFortune(
        id: 'fortune-$index',
        userId: userId ?? 'test-user-123',
        content: '운세 내용 $index',
        createdAt: DateTime.now().subtract(Duration(days: index)),
      ),
    );
  }
  
  static Map<String, dynamic> createErrorResponse({
    int? statusCode,
    String? message,
    String? error,
  }) {
    return {
      'statusCode': statusCode ?? 500,
      'message': message ?? 'Internal server error',
      'error': error ?? 'SERVER_ERROR',
    };
  }
  
  static Map<String, dynamic> createPaginationParams({
    int? limit,
    int? offset,
    String? sortBy,
    String? order,
  }) {
    return {
      'limit': limit ?? 10,
      'offset': offset ?? 0,
      'sortBy': sortBy ?? 'createdAt',
      'order': order ?? 'desc',
    };
  }
}