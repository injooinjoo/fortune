import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _supabase = Supabase.instance.client;

  @Deprecated('Use SocialAuthService.signInWithGoogle() instead for better performance',
  Future<void> signInWithGoogle() async {
    // This method is deprecated. Use SocialAuthService for OAuth login
    throw UnimplementedError(
      'Google Sign-In has been moved to SocialAuthService. '
      'Please use SocialAuthService.signInWithGoogle() instead.'
    );
  }

  Future<AuthResponse> signInWithKakao() async {
    // Kakao 로그인은 추후 구현
    throw UnimplementedError('Kakao login is not implemented yet');
  }

  @Deprecated('Use SocialAuthService.signInWithApple() instead for better performance',
  Future<void> signInWithApple() async {
    // This method is deprecated. Use SocialAuthService for OAuth login
    throw UnimplementedError(
      'Apple Sign-In has been moved to SocialAuthService. '
      'Please use SocialAuthService.signInWithApple() instead.'
    );
  }

  @Deprecated('Use SocialAuthService.signInWithNaver() instead for better performance',
  Future<void> signInWithNaver() async {
    // This method is deprecated. Use SocialAuthService for OAuth login
    throw UnimplementedError(
      'Naver Sign-In has been moved to SocialAuthService. '
      'Please use SocialAuthService.signInWithNaver() instead.'
    );
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