import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fortune/services/auth_service.dart';
import 'package:fortune/services/storage_service.dart';
import 'package:fortune/services/social_auth_service.dart';
import 'package:fortune/services/in_app_purchase_service.dart';
import 'package:fortune/services/cache_service.dart';
import 'package:fortune/data/services/fortune_api_service.dart';
import 'package:fortune/data/services/token_api_service.dart';
import 'package:fortune/core/network/api_client.dart';
import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

// Supabase mocks
class MockSupabaseClient extends Mock implements SupabaseClient {}
class MockGoTrueClient extends Mock implements GoTrueClient {}
class MockSupabaseStorageClient extends Mock implements SupabaseStorageClient {}
class MockStorageBucket extends Mock implements StorageBucket {}

// Service mocks
class MockAuthService extends Mock implements AuthService {}
class MockStorageService extends Mock implements StorageService {}
class MockSocialAuthService extends Mock implements SocialAuthService {}
class MockInAppPurchaseService extends Mock implements InAppPurchaseService {}
class MockCacheService extends Mock implements CacheService {}
class MockFortuneApiService extends Mock implements FortuneApiService {}
class MockTokenApiService extends Mock implements TokenApiService {}
class MockApiClient extends Mock implements ApiClient {}

// External service mocks
class MockGoogleSignIn extends Mock implements GoogleSignIn {}
class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}
class MockGoogleSignInAuthentication extends Mock implements GoogleSignInAuthentication {}
class MockKakaoUser extends Mock implements kakao.User {}
class MockNaverLoginResult extends Mock implements NaverLoginResult {}
class MockAppleIDCredential extends Mock implements AuthorizationCredentialAppleID {}

// HTTP mocks
class MockDio extends Mock implements Dio {}
class MockResponse extends Mock implements Response {}
class MockRequestOptions extends Mock implements RequestOptions {}

// Test service factory
class MockServiceFactory {
  static MockSupabaseClient createMockSupabaseClient({
    MockGoTrueClient? auth,
    MockSupabaseStorageClient? storage,
  }) {
    final client = MockSupabaseClient();
    final mockAuth = auth ?? MockGoTrueClient();
    final mockStorage = storage ?? MockSupabaseStorageClient();
    
    when(() => client.auth).thenReturn(mockAuth);
    when(() => client.storage).thenReturn(mockStorage);
    
    return client;
  }
  
  static MockAuthService createMockAuthService({
    User? currentUser,
    bool isAuthenticated = false,
  }) {
    final service = MockAuthService();
    
    when(() => service.currentUser).thenReturn(currentUser);
    when(() => service.isAuthenticated).thenReturn(isAuthenticated);
    when(() => service.authStateChanges).thenAnswer(
      (_) => Stream.value(currentUser != null ? AuthState.authenticated : AuthState.unauthenticated),
    );
    
    return service;
  }
  
  static MockStorageService createMockStorageService() {
    final service = MockStorageService();
    final storage = <String, dynamic>{};
    
    when(() => service.getString(any())).thenAnswer((invocation) {
      final key = invocation.positionalArguments[0] as String;
      return Future.value(storage[key] as String?);
    });
    
    when(() => service.setString(any(), any())).thenAnswer((invocation) {
      final key = invocation.positionalArguments[0] as String;
      final value = invocation.positionalArguments[1] as String;
      storage[key] = value;
      return Future.value(true);
    });
    
    when(() => service.remove(any())).thenAnswer((invocation) {
      final key = invocation.positionalArguments[0] as String;
      storage.remove(key);
      return Future.value(true);
    });
    
    when(() => service.clear()).thenAnswer((_) {
      storage.clear();
      return Future.value(true);
    });
    
    return service;
  }
  
  static MockCacheService createMockCacheService() {
    final service = MockCacheService();
    final cache = <String, dynamic>{};
    
    when(() => service.get(any())).thenAnswer((invocation) {
      final key = invocation.positionalArguments[0] as String;
      return Future.value(cache[key]);
    });
    
    when(() => service.set(any(), any(), duration: any(named: 'duration')))
        .thenAnswer((invocation) {
      final key = invocation.positionalArguments[0] as String;
      final value = invocation.positionalArguments[1];
      cache[key] = value;
      return Future.value();
    });
    
    when(() => service.remove(any())).thenAnswer((invocation) {
      final key = invocation.positionalArguments[0] as String;
      cache.remove(key);
      return Future.value();
    });
    
    when(() => service.clear()).thenAnswer((_) {
      cache.clear();
      return Future.value();
    });
    
    return service;
  }
  
  static MockApiClient createMockApiClient() {
    final client = MockApiClient();
    final dio = MockDio();
    
    when(() => client.dio).thenReturn(dio);
    
    return client;
  }
  
  static MockResponse createMockResponse({
    dynamic data,
    int statusCode = 200,
    String? statusMessage,
    Map<String, dynamic>? headers,
  }) {
    final response = MockResponse();
    final requestOptions = MockRequestOptions();
    
    when(() => requestOptions.path).thenReturn('');
    when(() => response.data).thenReturn(data);
    when(() => response.statusCode).thenReturn(statusCode);
    when(() => response.statusMessage).thenReturn(statusMessage);
    when(() => response.headers).thenReturn(Headers.fromMap(headers ?? {}));
    when(() => response.requestOptions).thenReturn(requestOptions);
    
    return response;
  }
  
  static void setupGoogleSignInMock(
    MockGoogleSignIn googleSignIn, {
    String? email,
    String? displayName,
    String? idToken,
    String? accessToken,
    bool shouldSucceed = true,
  }) {
    if (shouldSucceed) {
      final account = MockGoogleSignInAccount();
      final auth = MockGoogleSignInAuthentication();
      
      when(() => account.email).thenReturn(email ?? 'test@gmail.com');
      when(() => account.displayName).thenReturn(displayName ?? 'Test User');
      when(() => account.authentication).thenAnswer((_) async => auth);
      
      when(() => auth.idToken).thenReturn(idToken ?? 'google-id-token');
      when(() => auth.accessToken).thenReturn(accessToken ?? 'google-access-token');
      
      when(() => googleSignIn.signIn()).thenAnswer((_) async => account);
    } else {
      when(() => googleSignIn.signIn()).thenAnswer((_) async => null);
    }
    
    when(() => googleSignIn.signOut()).thenAnswer((_) async => null);
  }
}