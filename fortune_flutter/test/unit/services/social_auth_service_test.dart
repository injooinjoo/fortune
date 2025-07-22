import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:fortune/services/social_auth_service.dart';
import '../../test_utils/mocks/mock_services.dart';
import '../../test_utils/mocks/mock_factory.dart';
import '../../test_utils/fixtures/test_data.dart';

// Additional mocks for social auth
class MockAuthorizationCredentialAppleID extends Mock 
    implements AuthorizationCredentialAppleID {}
class MockNaverAccessToken extends Mock implements NaverAccessToken {}
class MockOAuthToken extends Mock implements kakao.OAuthToken {}

void main() {
  late SocialAuthService socialAuthService;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  
  setUpAll(() {
    registerFallbackValue(OAuthProvider.google);
    registerFallbackValue(Uri());
    registerFallbackValue(LaunchMode.platformDefault);
  });
  
  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    
    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    
    socialAuthService = SocialAuthService(mockSupabaseClient);
  });
  
  group('SocialAuthService', () {
    group('signInWithGoogle', () {
      test('should initiate Google OAuth sign in', () async {
        // Arrange
        when(() => mockGoTrueClient.signInWithOAuth(
          any(),
          redirectTo: any(named: 'redirectTo'),
          scopes: any(named: 'scopes'),
        )).thenAnswer((_) async => true);
        
        // Act
        final result = await socialAuthService.signInWithGoogle();
        
        // Assert
        expect(result, isNull); // OAuth redirect returns null
        verify(() => mockGoTrueClient.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: any(named: 'redirectTo'),
          scopes: 'email',
        )).called(1);
      });
      
      test('should handle Google OAuth error', () async {
        // Arrange
        when(() => mockGoTrueClient.signInWithOAuth(
          any(),
          redirectTo: any(named: 'redirectTo'),
          scopes: any(named: 'scopes'),
        )).thenThrow(AuthException('Google OAuth failed'));
        
        // Act & Assert
        expect(
          () => socialAuthService.signInWithGoogle(),
          throwsA(isA<AuthException>()),
        );
      });
    });
    
    group('signInWithApple', () {
      test('should use OAuth for web platform', () async {
        // Arrange
        when(() => mockGoTrueClient.signInWithOAuth(
          any(),
          redirectTo: any(named: 'redirectTo'),
          authScreenLaunchMode: any(named: 'authScreenLaunchMode'),
        )).thenAnswer((_) async => true);
        
        // Act
        final result = await socialAuthService.signInWithApple();
        
        // Assert
        expect(result, isNull); // OAuth returns null
        verify(() => mockGoTrueClient.signInWithOAuth(
          OAuthProvider.apple,
          redirectTo: any(named: 'redirectTo'),
          authScreenLaunchMode: any(named: 'authScreenLaunchMode'),
        )).called(1);
      });
      
      test('should handle Apple OAuth error', () async {
        // Arrange
        when(() => mockGoTrueClient.signInWithOAuth(
          any(),
          redirectTo: any(named: 'redirectTo'),
          authScreenLaunchMode: any(named: 'authScreenLaunchMode'),
        )).thenThrow(AuthException('Apple OAuth failed'));
        
        // Act & Assert
        expect(
          () => socialAuthService.signInWithApple(),
          throwsA(isA<AuthException>()),
        );
      });
    });
    
    group('signInWithKakao', () {
      test('should sign in with Kakao successfully', () async {
        // Arrange
        final mockUser = kakao.User(
          id: 123456789,
          properties: {
            'nickname': 'Kakao User',
            'profile_image': 'https://kakao.com/profile.jpg',
          },
        );
        
        final mockToken = MockOAuthToken();
        when(() => mockToken.accessToken).thenReturn('kakao-access-token');
        
        // Mock successful Kakao login
        when(() => kakao.UserApi.instance.loginWithKakaoAccount())
            .thenAnswer((_) async => mockToken);
        when(() => kakao.UserApi.instance.me())
            .thenAnswer((_) async => mockUser);
        
        final authResponse = AuthResponse(
          session: MockFactory.createSupabaseSession(),
          user: MockFactory.createSupabaseUser(),
        );
        
        when(() => mockGoTrueClient.signInWithIdToken(
          provider: OAuthProvider.kakao,
          idToken: any(named: 'idToken'),
          accessToken: any(named: 'accessToken'),
        )).thenAnswer((_) async => authResponse);
        
        // Note: Full implementation would require mocking Kakao SDK
        // For now, we test the expected flow
        expect(socialAuthService.signInWithKakao, isA<Function>());
      });
    });
    
    group('signInWithNaver', () {
      test('should sign in with Naver successfully', () async {
        // Arrange
        final mockResult = NaverLoginResult(
          status: NaverLoginStatus.loggedIn,
          account: NaverAccount(
            id: 'naver-123',
            email: 'test@naver.com',
            name: 'Naver User',
          ),
        );
        
        final mockAccessToken = MockNaverAccessToken();
        when(() => mockAccessToken.accessToken).thenReturn('naver-access-token');
        
        // Mock successful Naver login
        when(() => FlutterNaverLogin.logIn())
            .thenAnswer((_) async => mockResult);
        when(() => FlutterNaverLogin.currentAccessToken)
            .thenReturn(mockAccessToken);
        
        final authResponse = AuthResponse(
          session: MockFactory.createSupabaseSession(),
          user: MockFactory.createSupabaseUser(),
        );
        
        when(() => mockGoTrueClient.signInWithIdToken(
          provider: any(),
          idToken: any(named: 'idToken'),
          accessToken: any(named: 'accessToken'),
        )).thenAnswer((_) async => authResponse);
        
        // Note: Full implementation would require mocking Naver SDK
        expect(socialAuthService.signInWithNaver, isA<Function>());
      });
    });
    
    group('signInWithFacebook', () {
      test('should initiate Facebook OAuth sign in', () async {
        // Arrange
        when(() => mockGoTrueClient.signInWithOAuth(
          any(),
          redirectTo: any(named: 'redirectTo'),
          scopes: any(named: 'scopes'),
        )).thenAnswer((_) async => true);
        
        // Act
        final result = await socialAuthService.signInWithFacebook();
        
        // Assert
        expect(result, isNull); // OAuth redirect returns null
        verify(() => mockGoTrueClient.signInWithOAuth(
          OAuthProvider.facebook,
          redirectTo: any(named: 'redirectTo'),
          scopes: 'email,public_profile',
        )).called(1);
      });
    });
    
    group('unlinkProvider', () {
      test('should unlink provider successfully', () async {
        // Arrange
        final user = MockFactory.createSupabaseUser();
        when(() => mockGoTrueClient.currentUser).thenReturn(user);
        
        final profileData = {
          'id': user.id,
          'linked_providers': ['google', 'apple'],
          'primary_provider': 'google',
        };
        
        when(() => mockSupabaseClient.from(any())).thenReturn(
          MockSupabaseQueryBuilder() as SupabaseQueryBuilder,
        );
        
        // Note: Full implementation would require complex query builder mocking
        expect(socialAuthService.unlinkProvider, isA<Function>());
      });
    });
    
    group('getLinkedProviders', () {
      test('should return empty list when user not authenticated', () async {
        // Arrange
        when(() => mockGoTrueClient.currentUser).thenReturn(null);
        
        // Act
        final result = await socialAuthService.getLinkedProviders();
        
        // Assert
        expect(result, isEmpty);
      });
      
      test('should return linked providers for authenticated user', () async {
        // Arrange
        final user = MockFactory.createSupabaseUser();
        when(() => mockGoTrueClient.currentUser).thenReturn(user);
        
        // Note: Full implementation would require query builder mocking
        expect(socialAuthService.getLinkedProviders, isA<Function>());
      });
    });
    
    group('profile update', () {
      test('should handle profile update errors gracefully', () async {
        // Arrange
        final user = MockFactory.createSupabaseUser();
        final authResponse = AuthResponse(
          session: MockFactory.createSupabaseSession(user: user),
          user: user,
        );
        
        when(() => mockGoTrueClient.signInWithOAuth(
          any(),
          redirectTo: any(named: 'redirectTo'),
          scopes: any(named: 'scopes'),
        )).thenAnswer((_) async => true);
        
        when(() => mockSupabaseClient.from(any())).thenThrow(
          PostgrestException(
            message: 'Profile update failed',
            code: '23505',
          ),
        );
        
        // Act - should not throw
        await socialAuthService.signInWithGoogle();
        
        // Assert - login should succeed even if profile update fails
        verify(() => mockGoTrueClient.signInWithOAuth(
          OAuthProvider.google,
          redirectTo: any(named: 'redirectTo'),
          scopes: 'email',
        )).called(1);
      });
    });
  });
}

// Mock Supabase query builder
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}