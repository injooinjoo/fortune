import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/social_auth_service.dart';
import '../../core/utils/logger.dart';
import 'auth_provider.dart';
import 'providers.dart';

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
  error}

// Social Auth Notifier
class SocialAuthNotifier extends StateNotifier<AsyncValue<AuthResponse?>> {
  final SocialAuthService _socialAuthService;
  final Ref _ref;
  
  SocialAuthNotifier(this._socialAuthService, this._ref)
      : super(const AsyncValue.data(null));
  
  // Google Sign In
  Future<void> signInWithGoogle() async {
    print('🟢 [SocialAuthProvider] signInWithGoogle() called');
    state = const AsyncValue.loading();
    
    try {
      print('🟢 [SocialAuthProvider] Calling _socialAuthService.signInWithGoogle()...');
      final response = await _socialAuthService.signInWithGoogle();
      print('received: ${response != null ? "not null" : "null"}');
      
      if (response != null && response.user != null) {
        print('authenticated: ${response.user!.id}');
        state = AsyncValue.data(response);
        
        // 인증 상태 새로고침
        _ref.invalidate(userProvider);
        _ref.invalidate(userProfileProvider);
        
        // 프로필 자동 생성 확인
        print('🟢 [SocialAuthProvider] Ensuring user profile...');
        final authService = _ref.read(authServiceProvider);
        await authService.ensureUserProfile();
        
        // Update consecutive days on social sign in
        try {
          final statisticsService = _ref.read(userStatisticsServiceProvider);
          await statisticsService.updateConsecutiveDays(response.user!.id);
        } catch (e) {
          Logger.error('Failed to update consecutive days', e);
          // Don't throw - this is not critical for sign in
        }
        
        Logger.info('Google Sign-In successful');
        print('🟢 [SocialAuthProvider] Google Sign-In successful');
      } else {
        print('🟢 [SocialAuthProvider] No response or user from Google Sign-In');
        state = const AsyncValue.data(null);
      }
    } catch (error, stackTrace) {
      print('Fortune cached');
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
        
        // Update consecutive days on social sign in
        try {
          final statisticsService = _ref.read(userStatisticsServiceProvider);
          await statisticsService.updateConsecutiveDays(response.user!.id);
        } catch (e) {
          Logger.error('Failed to update consecutive days', e);
          // Don't throw - this is not critical for sign in
        }
        
        Logger.info('Apple Sign-In successful');
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      Logger.error('Apple Sign-In error', error, stackTrace);
    }
  }
  
  // Facebook Sign In
  Future<void> signInWithFacebook() async {
    state = const AsyncValue.loading();
    
    try {
      final response = await _socialAuthService.signInWithFacebook();
      
      if (response != null && response.user != null) {
        state = AsyncValue.data(response);
        
        // 인증 상태 새로고침
        _ref.invalidate(userProvider);
        _ref.invalidate(userProfileProvider);
        
        // 프로필 자동 생성 확인
        final authService = _ref.read(authServiceProvider);
        await authService.ensureUserProfile();
        
        // Update consecutive days on social sign in
        try {
          final statisticsService = _ref.read(userStatisticsServiceProvider);
          await statisticsService.updateConsecutiveDays(response.user!.id);
        } catch (e) {
          Logger.error('Failed to update consecutive days', e);
          // Don't throw - this is not critical for sign in
        }
        
        Logger.info('Facebook Sign-In successful');
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      Logger.error('Facebook Sign-In error', error, stackTrace);
    }
  }
  
  // Kakao Sign In
  Future<void> signInWithKakao() async {
    state = const AsyncValue.loading();
    
    try {
      final response = await _socialAuthService.signInWithKakao();
      
      if (response != null && response.user != null) {
        state = AsyncValue.data(response);
        
        // 인증 상태 새로고침
        _ref.invalidate(userProvider);
        _ref.invalidate(userProfileProvider);
        
        // 프로필 자동 생성 확인
        final authService = _ref.read(authServiceProvider);
        await authService.ensureUserProfile();
        
        // Update consecutive days on social sign in
        try {
          final statisticsService = _ref.read(userStatisticsServiceProvider);
          await statisticsService.updateConsecutiveDays(response.user!.id);
        } catch (e) {
          Logger.error('Failed to update consecutive days', e);
          // Don't throw - this is not critical for sign in
        }
        
        Logger.info('Kakao Sign-In successful');
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      Logger.error('Kakao Sign-In error', error, stackTrace);
    }
  }
  
  // Naver Sign In
  Future<void> signInWithNaver() async {
    state = const AsyncValue.loading();
    
    try {
      final response = await _socialAuthService.signInWithNaver();
      
      if (response != null && response.user != null) {
        state = AsyncValue.data(response);
        
        // 인증 상태 새로고침
        _ref.invalidate(userProvider);
        _ref.invalidate(userProfileProvider);
        
        // 프로필 자동 생성 확인
        final authService = _ref.read(authServiceProvider);
        await authService.ensureUserProfile();
        
        // Update consecutive days on social sign in
        try {
          final statisticsService = _ref.read(userStatisticsServiceProvider);
          await statisticsService.updateConsecutiveDays(response.user!.id);
        } catch (e) {
          Logger.error('Failed to update consecutive days', e);
          // Don't throw - this is not critical for sign in
        }
        
        Logger.info('Naver Sign-In successful');
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
      Logger.error('Naver Sign-In error', error, stackTrace);
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