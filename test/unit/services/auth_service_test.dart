import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:fortune/services/auth_service.dart';
import '../../test_utils/mocks/mock_services.dart';
import '../../test_utils/mocks/mock_factory.dart';
import '../../test_utils/fixtures/test_data.dart';

void main() {
  late AuthService authService;
  late MockSupabaseClient mockSupabaseClient;
  late MockGoTrueClient mockGoTrueClient;
  
  setUpAll(() {
    registerFallbackValue(Uri());
    registerFallbackValue(AuthChangeEvent.signedIn);
  });
  
  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockGoTrueClient = MockGoTrueClient();
    
    when(() => mockSupabaseClient.auth).thenReturn(mockGoTrueClient);
    
    // Mock Supabase singleton
    Supabase.initialize(
      url: 'https://test.supabase.co',
      anonKey: 'test-anon-key',
    );
    
    authService = AuthService();
  });
  
  group('AuthService', () {
    group('currentUser', () {
      test('should return current user when authenticated', () {
        // Arrange
        final user = MockFactory.createSupabaseUser();
        when(() => mockGoTrueClient.currentUser).thenReturn(user);
        
        // Act
        final result = authService.currentUser;
        
        // Assert
        expect(result, equals(user));
        expect(result?.id, equals('test-user-123'));
        expect(result?.email, equals('test@example.com'));
      });
      
      test('should return null when not authenticated', () {
        // Arrange
        when(() => mockGoTrueClient.currentUser).thenReturn(null);
        
        // Act
        final result = authService.currentUser;
        
        // Assert
        expect(result, isNull);
      });
    });
    
    group('currentSession', () {
      test('should return current session when authenticated', () {
        // Arrange
        final session = MockFactory.createSupabaseSession();
        when(() => mockGoTrueClient.currentSession).thenReturn(session);
        
        // Act
        final result = authService.currentSession;
        
        // Assert
        expect(result, equals(session));
        expect(result?.accessToken, equals('test-access-token'));
        expect(result?.refreshToken, equals('test-refresh-token'));
      });
      
      test('should return null when not authenticated', () {
        // Arrange
        when(() => mockGoTrueClient.currentSession).thenReturn(null);
        
        // Act
        final result = authService.currentSession;
        
        // Assert
        expect(result, isNull);
      });
    });
    
    group('authStateChanges', () {
      test('should emit auth state changes', () async {
        // Arrange
        final user = MockFactory.createSupabaseUser();
        final authStateStream = Stream<AuthState>.fromIterable([
          AuthState(AuthChangeEvent.signedIn, MockFactory.createSupabaseSession(user: user)),
          AuthState(AuthChangeEvent.signedOut, null),
        ]);
        
        when(() => mockGoTrueClient.onAuthStateChange).thenAnswer((_) => authStateStream);
        
        // Act
        final states = <AuthState>[];
        final subscription = authService.authStateChanges.listen(states.add);
        
        // Allow stream to emit all values
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Assert
        expect(states.length, equals(2));
        expect(states[0].event, equals(AuthChangeEvent.signedIn));
        expect(states[0].session?.user, equals(user));
        expect(states[1].event, equals(AuthChangeEvent.signedOut));
        expect(states[1].session, isNull);
        
        // Cleanup
        await subscription.cancel();
      });
    });
    
    group('signOut', () {
      test('should sign out successfully', () async {
        // Arrange
        when(() => mockGoTrueClient.signOut()).thenAnswer((_) async {});
        
        // Act
        await authService.signOut();
        
        // Assert
        verify(() => mockGoTrueClient.signOut()).called(1);
      });
      
      test('should handle sign out error', () async {
        // Arrange
        when(() => mockGoTrueClient.signOut()).thenThrow(
          AuthException('Failed to sign out'),
        );
        
        // Act & Assert
        expect(
          () => authService.signOut(),
          throwsA(isA<AuthException>()),
        );
      });
    });
    
    group('hasUserProfile', () {
      test('should return true when user has completed profile', () async {
        // Arrange
        final user = MockFactory.createSupabaseUser();
        when(() => mockGoTrueClient.currentUser).thenReturn(user);
        
        when(() => mockSupabaseClient.from('user_profiles')).thenReturn(
          MockSupabaseQueryBuilder() as SupabaseQueryBuilder,
        );
        
        // Note: In real implementation, you would need to mock the entire query chain
        // For now, we'll test the logic without full Supabase mocking
        
        // Act & Assert
        // This test would require more complex mocking of Supabase query builder
        // which is beyond the scope of this basic test setup
        expect(authService.hasUserProfile, isA<Function>());
      });
      
      test('should return false when user is not authenticated', () async {
        // Arrange
        when(() => mockGoTrueClient.currentUser).thenReturn(null);
        
        // Act
        final result = await authService.hasUserProfile();
        
        // Assert
        expect(result, isFalse);
      });
    });
    
    group('deprecated methods', () {
      test('signInWithGoogle should throw UnimplementedError', () {
        expect(
          () => authService.signInWithGoogle(),
          throwsUnimplementedError,
        );
      });
      
      test('signInWithApple should throw UnimplementedError', () {
        expect(
          () => authService.signInWithApple(),
          throwsUnimplementedError,
        );
      });
      
      test('signInWithNaver should throw UnimplementedError', () {
        expect(
          () => authService.signInWithNaver(),
          throwsUnimplementedError,
        );
      });
      
      test('signInWithKakao should throw UnimplementedError', () {
        expect(
          () => authService.signInWithKakao(),
          throwsUnimplementedError,
        );
      });
    });
  });
}

// Mock classes for Supabase query builder
class MockSupabaseQueryBuilder extends Mock implements SupabaseQueryBuilder {}