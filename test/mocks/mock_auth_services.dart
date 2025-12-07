/// Mock Auth Services - 인증 관련 Mock 클래스
/// Phase 1: 인증 & 온보딩 테스트용

import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fortune/services/storage_service.dart';
import 'package:fortune/services/social_auth/base/base_social_auth_provider.dart';

// ============================================
// Supabase Mocks
// ============================================

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockUser extends Mock implements User {}

class MockSession extends Mock implements Session {}

class MockAuthResponse extends Mock implements AuthResponse {}

// ============================================
// Service Mocks
// ============================================

class MockStorageService extends Mock implements StorageService {}

class MockBaseSocialAuthProvider extends Mock implements BaseSocialAuthProvider {}

// ============================================
// Test Data Factory - Auth
// ============================================

class AuthTestData {
  /// 테스트용 User 생성
  static User createMockUser({
    String id = 'test-user-id-12345',
    String? email = 'test@example.com',
    String? phone,
    Map<String, dynamic>? userMetadata,
  }) {
    final mockUser = MockUser();
    when(() => mockUser.id).thenReturn(id);
    when(() => mockUser.email).thenReturn(email);
    when(() => mockUser.phone).thenReturn(phone);
    when(() => mockUser.userMetadata).thenReturn(userMetadata ?? {
      'full_name': 'Test User',
      'name': 'Test User',
      'avatar_url': 'https://example.com/avatar.png',
    });
    when(() => mockUser.appMetadata).thenReturn({});
    when(() => mockUser.aud).thenReturn('authenticated');
    when(() => mockUser.createdAt).thenReturn(DateTime.now().toIso8601String());
    return mockUser;
  }

  /// 테스트용 Session 생성
  static Session createMockSession({
    String accessToken = 'mock-access-token',
    String refreshToken = 'mock-refresh-token',
    int expiresIn = 3600,
    User? user,
  }) {
    final mockSession = MockSession();
    final mockUser = user ?? createMockUser();

    when(() => mockSession.accessToken).thenReturn(accessToken);
    when(() => mockSession.refreshToken).thenReturn(refreshToken);
    when(() => mockSession.expiresIn).thenReturn(expiresIn);
    when(() => mockSession.user).thenReturn(mockUser);
    when(() => mockSession.tokenType).thenReturn('bearer');
    return mockSession;
  }

  /// 테스트용 AuthResponse 생성
  static AuthResponse createMockAuthResponse({
    Session? session,
    User? user,
  }) {
    final mockResponse = MockAuthResponse();
    when(() => mockResponse.session).thenReturn(session);
    when(() => mockResponse.user).thenReturn(user);
    return mockResponse;
  }

  /// 소셜 로그인 사용자 (Google)
  static User createGoogleUser() {
    return createMockUser(
      id: 'google-user-id',
      email: 'google.user@gmail.com',
      userMetadata: {
        'full_name': 'Google User',
        'name': 'Google User',
        'avatar_url': 'https://lh3.googleusercontent.com/avatar.png',
        'provider': 'google',
      },
    );
  }

  /// 소셜 로그인 사용자 (Kakao)
  static User createKakaoUser() {
    return createMockUser(
      id: 'kakao-user-id',
      email: 'kakao_12345678@kakao.com',
      userMetadata: {
        'full_name': '카카오 사용자',
        'name': '카카오 사용자',
        'avatar_url': 'https://k.kakaocdn.net/avatar.png',
        'provider': 'kakao',
      },
    );
  }

  /// 소셜 로그인 사용자 (Apple)
  static User createAppleUser() {
    return createMockUser(
      id: 'apple-user-id',
      email: 'apple@privaterelay.appleid.com',
      userMetadata: {
        'full_name': 'Apple User',
        'name': 'Apple User',
        'provider': 'apple',
      },
    );
  }

  /// 소셜 로그인 사용자 (Naver)
  static User createNaverUser() {
    return createMockUser(
      id: 'naver-user-id',
      email: 'naver_user@naver.com',
      userMetadata: {
        'full_name': '네이버 사용자',
        'name': '네이버 사용자',
        'avatar_url': 'https://phinf.pstatic.net/avatar.png',
        'provider': 'naver',
      },
    );
  }

  /// 온보딩 완료된 프로필
  static Map<String, dynamic> createCompletedProfile({
    String id = 'test-user-id',
    String name = 'Test User',
    String? email = 'test@example.com',
    String birthDate = '1990-01-01',
    String birthTime = '09:00',
    String gender = 'male',
    bool onboardingCompleted = true,
  }) {
    return {
      'id': id,
      'name': name,
      'email': email,
      'birth_date': birthDate,
      'birth_time': birthTime,
      'gender': gender,
      'onboarding_completed': onboardingCompleted,
      'zodiac_sign': '염소자리',
      'chinese_zodiac': '말',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  /// 온보딩 미완료 프로필
  static Map<String, dynamic> createIncompleteProfile({
    String id = 'test-user-id',
    String? name,
    String? email = 'test@example.com',
  }) {
    return {
      'id': id,
      'name': name,
      'email': email,
      'birth_date': null,
      'birth_time': null,
      'onboarding_completed': false,
      'created_at': DateTime.now().toIso8601String(),
    };
  }
}

// ============================================
// Fallback Value Registration
// ============================================

void registerAuthFallbackValues() {
  registerFallbackValue(DateTime.now());
  registerFallbackValue(<String, dynamic>{});
  registerFallbackValue(const Duration(seconds: 1));
}
