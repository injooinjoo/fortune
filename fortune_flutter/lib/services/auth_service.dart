import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  Future<void> signInWithGoogle() async {
    try {
      // Use different redirect URLs for web and mobile platforms
      final redirectUrl = kIsWeb 
          ? 'http://localhost:9002/auth/callback'
          : 'io.supabase.flutter://login-callback/';
      
      print('=== GOOGLE SIGN IN START ===');
      print('Platform: ${kIsWeb ? "Web" : "Mobile"}');
      print('Redirect URL: $redirectUrl');
      
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
      );
      
      print('OAuth flow initiated successfully');
      print('=== GOOGLE SIGN IN END ===');
    } catch (e, stack) {
      print('Google sign in error: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<AuthResponse> signInWithKakao() async {
    // Kakao 로그인은 추후 구현
    throw UnimplementedError('Kakao login is not implemented yet');
  }

  Future<void> signInWithApple() async {
    try {
      final redirectUrl = kIsWeb 
          ? 'http://localhost:9002/auth/callback'
          : 'io.supabase.flutter://login-callback/';
      
      print('=== APPLE SIGN IN START ===');
      print('Platform: ${kIsWeb ? "Web" : "Mobile"}');
      print('Redirect URL: $redirectUrl');
      
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: redirectUrl,
      );
      
      print('OAuth flow initiated successfully');
      print('=== APPLE SIGN IN END ===');
    } catch (e, stack) {
      print('Apple sign in error: $e');
      print('Stack trace: $stack');
      rethrow;
    }
  }

  Future<void> signInWithNaver() async {
    // Naver 로그인은 추후 구현
    throw UnimplementedError('Naver login is not implemented yet');
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;
  
  Session? get currentSession => _supabase.auth.currentSession;

  Stream<AuthState> get authStateChanges => _supabase.auth.onAuthStateChange;

  Future<bool> hasUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final response = await _supabase
          .from('user_profiles')
          .select('onboarding_completed')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) return false;
      
      return response['onboarding_completed'] == true;
    } catch (e) {
      print('Error checking user profile: $e');
      return false;
    }
  }
}