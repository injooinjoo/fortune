import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/social_auth_service.dart';
import '../../services/social_auth/base/social_auth_attempt_result.dart';
import '../../core/utils/logger.dart';
import 'providers.dart';

// Social Auth Service Provider
final socialAuthServiceProvider = Provider<SocialAuthService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SocialAuthService(supabase);
});

// Social Auth State
enum SocialAuthState { initial, loading, authenticated, error }

// Social Auth Notifier
class SocialAuthNotifier
    extends StateNotifier<AsyncValue<SocialAuthAttemptResult?>> {
  final SocialAuthService _socialAuthService;
  final Ref _ref;

  SocialAuthNotifier(this._socialAuthService, this._ref)
      : super(const AsyncValue.data(null));

  // Google Sign In
  Future<void> signInWithGoogle() async {
    debugPrint('🟢 [SocialAuthProvider] signInWithGoogle() called');
    state = const AsyncValue.loading();

    try {
      debugPrint(
          '🟢 [SocialAuthProvider] Calling _socialAuthService.signInWithGoogle()...');
      final result = await _socialAuthService.signInWithGoogle();
      debugPrint('received status: ${result.status.name}');

      if (result.isAuthenticated && result.user != null) {
        debugPrint('authenticated: ${result.user!.id}');
        state = AsyncValue.data(result);

        // 인증 상태 새로고침
        _ref.invalidate(userProvider);
        _ref.invalidate(userProfileProvider);

        // 프로필 자동 생성 확인
        debugPrint('🟢 [SocialAuthProvider] Ensuring user profile...');
        final authService = _ref.read(authServiceProvider);
        await authService.ensureUserProfile();

        // Update consecutive days on social sign in
        try {
          final statisticsService = _ref.read(userStatisticsServiceProvider);
          await statisticsService.updateConsecutiveDays(result.user!.id);
        } catch (e) {
          Logger.error('Failed to update consecutive days', e);
          // Don't throw - this is not critical for sign in
        }

        Logger.info('Google Sign-In successful');
        debugPrint('🟢 [SocialAuthProvider] Google Sign-In successful');
      } else {
        debugPrint('🟢 [SocialAuthProvider] Google Sign-In pending/cancelled');
        state = AsyncValue.data(result);
      }
    } catch (error, stackTrace) {
      debugPrint('Fortune cached');
      state = AsyncValue.error(error, stackTrace);
      Logger.error('Google Sign-In error', error, stackTrace);
    }
  }

  // Apple Sign In
  Future<void> signInWithApple() async {
    state = const AsyncValue.loading();

    try {
      final result = await _socialAuthService.signInWithApple();

      if (result.isAuthenticated && result.user != null) {
        state = AsyncValue.data(result);

        // 인증 상태 새로고침
        _ref.invalidate(userProvider);
        _ref.invalidate(userProfileProvider);

        // 프로필 자동 생성 확인
        final authService = _ref.read(authServiceProvider);
        await authService.ensureUserProfile();

        // Update consecutive days on social sign in
        try {
          final statisticsService = _ref.read(userStatisticsServiceProvider);
          await statisticsService.updateConsecutiveDays(result.user!.id);
        } catch (e) {
          Logger.error('Failed to update consecutive days', e);
          // Don't throw - this is not critical for sign in
        }

        Logger.info('Apple Sign-In successful');
      } else {
        state = AsyncValue.data(result);
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
      final result = await _socialAuthService.signInWithFacebook();

      if (result.isAuthenticated && result.user != null) {
        state = AsyncValue.data(result);

        // 인증 상태 새로고침
        _ref.invalidate(userProvider);
        _ref.invalidate(userProfileProvider);

        // 프로필 자동 생성 확인
        final authService = _ref.read(authServiceProvider);
        await authService.ensureUserProfile();

        // Update consecutive days on social sign in
        try {
          final statisticsService = _ref.read(userStatisticsServiceProvider);
          await statisticsService.updateConsecutiveDays(result.user!.id);
        } catch (e) {
          Logger.error('Failed to update consecutive days', e);
          // Don't throw - this is not critical for sign in
        }

        Logger.info('Facebook Sign-In successful');
      } else {
        state = AsyncValue.data(result);
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
      final result = await _socialAuthService.signInWithKakao();

      if (result.isAuthenticated && result.user != null) {
        state = AsyncValue.data(result);

        // 인증 상태 새로고침
        _ref.invalidate(userProvider);
        _ref.invalidate(userProfileProvider);

        // 프로필 자동 생성 확인
        final authService = _ref.read(authServiceProvider);
        await authService.ensureUserProfile();

        // Update consecutive days on social sign in
        try {
          final statisticsService = _ref.read(userStatisticsServiceProvider);
          await statisticsService.updateConsecutiveDays(result.user!.id);
        } catch (e) {
          Logger.error('Failed to update consecutive days', e);
          // Don't throw - this is not critical for sign in
        }

        Logger.info('Kakao Sign-In successful');
      } else {
        state = AsyncValue.data(result);
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
      final result = await _socialAuthService.signInWithNaver();

      if (result.isAuthenticated && result.user != null) {
        state = AsyncValue.data(result);

        // 인증 상태 새로고침
        _ref.invalidate(userProvider);
        _ref.invalidate(userProfileProvider);

        // 프로필 자동 생성 확인
        final authService = _ref.read(authServiceProvider);
        await authService.ensureUserProfile();

        // Update consecutive days on social sign in
        try {
          final statisticsService = _ref.read(userStatisticsServiceProvider);
          await statisticsService.updateConsecutiveDays(result.user!.id);
        } catch (e) {
          Logger.error('Failed to update consecutive days', e);
          // Don't throw - this is not critical for sign in
        }

        Logger.info('Naver Sign-In successful');
      } else {
        state = AsyncValue.data(result);
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
final socialAuthProvider = StateNotifierProvider<SocialAuthNotifier,
    AsyncValue<SocialAuthAttemptResult?>>((ref) {
  final socialAuthService = ref.watch(socialAuthServiceProvider);
  return SocialAuthNotifier(socialAuthService, ref);
});

// Current Provider
final currentAuthProviderProvider = FutureProvider<String?>((ref) async {
  final socialAuthService = ref.watch(socialAuthServiceProvider);
  return await socialAuthService.getCurrentProvider();
});
