import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/social_auth_service.dart';
import '../../core/utils/logger.dart';
import 'auth_provider.dart';

// Social Auth Service Provider
final socialAuthServiceProvider = Provider<SocialAuthService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SocialAuthService(supabase);
});

// Social Auth State
enum SocialAuthState {
  initial,
  loading,
  authenticated,
  error,
}

// Social Auth Notifier
class SocialAuthNotifier extends StateNotifier<AsyncValue<AuthResponse?>> {
  final SocialAuthService _socialAuthService;
  final Ref _ref;
  
  SocialAuthNotifier(this._socialAuthService, this._ref)
      : super(const AsyncValue.data(null));
  
  // Google Sign In
  Future<void> signInWithGoogle() async {
    state = const AsyncValue.loading();
    
    try {
      final response = await _socialAuthService.signInWithGoogle();
      
      if (response != null && response.user != null) {
        state = AsyncValue.data(response);
        
        // 인증 상태 새로고침
        _ref.invalidate(userProvider);
        _ref.invalidate(userProfileProvider);
        
        // 프로필 자동 생성 확인
        final authService = _ref.read(authServiceProvider);
        await authService.ensureUserProfile();
        
        Logger.info('Google Sign-In successful');
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      Logger.error('Google Sign-In error', error, stackTrace);
    }
  }
  
  // Apple Sign In
  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();
    
    try {
      final response = await _socialAuthService.signInWithApple();
      
      if (response != null && response.user != null) {
        state = AsyncValue.data(response);
        
        // 인증 상태 새로고침
        _ref.invalidate(userProvider);
        _ref.invalidate(userProfileProvider);
        
        // 프로필 자동 생성 확인
        final authService = _ref.read(authServiceProvider);
        await authService.ensureUserProfile();
        
        Logger.info('Apple Sign-In successful');
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      Logger.error('Apple Sign-In error', error, stackTrace);
    }
  }
  
  // 로그아웃
  Future<void> signOut() async {
    state = const AsyncValue.loading();
    
    try {
      await _socialAuthService.signOut();
      state = const AsyncValue.data(null);
      
      // 인증 상태 새로고침
      _ref.invalidate(userProvider);
      _ref.invalidate(userProfileProvider);
      
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      Logger.error('Sign out error', error, stackTrace);
    }
  }
}

// Social Auth Provider
final socialAuthProvider = 
    StateNotifierProvider<SocialAuthNotifier, AsyncValue<AuthResponse?>>((ref) {
  final socialAuthService = ref.watch(socialAuthServiceProvider);
  return SocialAuthNotifier(socialAuthService, ref);
});

// Current Provider
final currentAuthProviderProvider = FutureProvider<String?>((ref) async {
  final socialAuthService = ref.watch(socialAuthServiceProvider);
  return await socialAuthService.getCurrentProvider();
});