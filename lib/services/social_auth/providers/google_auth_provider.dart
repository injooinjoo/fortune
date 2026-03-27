import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:universal_io/io.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/logger.dart';
import '../../../core/config/environment.dart';
import '../../oauth_in_app_browser_coordinator.dart';
import '../base/base_social_auth_provider.dart';
import '../base/social_auth_attempt_result.dart';

class _GoogleSignInCancelledException implements Exception {
  @override
  String toString() => '사용자가 Google 로그인을 취소했습니다.';
}

class GoogleAuthProvider extends BaseSocialAuthProvider {
  GoogleAuthProvider(
    super.supabase,
    super.profileCache, {
    Future<AuthResponse> Function()? nativeSignInOverride,
    Future<bool> Function()? signInWithOAuthOverride,
    Future<AuthResponse?> Function(Object error)?
        recoverAuthResponseAfterLaunchErrorOverride,
    bool? isWebOverride,
    bool? isIOSOverride,
    bool? isAndroidOverride,
  })  : _nativeSignInOverride = nativeSignInOverride,
        _signInWithOAuthOverride = signInWithOAuthOverride,
        _recoverAuthResponseAfterLaunchErrorOverride =
            recoverAuthResponseAfterLaunchErrorOverride,
        _isWebOverride = isWebOverride,
        _isIOSOverride = isIOSOverride,
        _isAndroidOverride = isAndroidOverride;

  static const String _fallbackGoogleWebClientId =
      '676247567847-aim7omjjgnk8615sdsifppv41pm3o0m2.apps.googleusercontent.com';
  static const String _fallbackGoogleIosClientId =
      '676247567847-u13rae7nvi2ilcobf5shfdg5b1pkkvbu.apps.googleusercontent.com';

  final Future<AuthResponse> Function()? _nativeSignInOverride;
  final Future<bool> Function()? _signInWithOAuthOverride;
  final Future<AuthResponse?> Function(Object error)?
      _recoverAuthResponseAfterLaunchErrorOverride;
  final bool? _isWebOverride;
  final bool? _isIOSOverride;
  final bool? _isAndroidOverride;
  GoogleSignIn? _googleSignIn;

  @override
  String get providerName => 'google';

  @override
  Future<SocialAuthAttemptResult> signIn() async {
    try {
      Logger.info('=== GOOGLE SIGN-IN PROCESS STARTED ===');

      SocialAuthConfigGuard.ensureOAuthConfigurationIsValid(
        providerName: providerName,
        supabase: supabase,
      );

      if (_supportsNativeGoogleSignIn) {
        Logger.info('[GoogleAuthProvider] Native Google Sign-In 시작');
        try {
          final response = await _signInWithGoogleNative();
          return SocialAuthAttemptResult.authenticated(response);
        } catch (error) {
          if (_shouldFallbackToOAuth(error)) {
            Logger.warning(
              '[GoogleAuthProvider] Native Google Sign-In nonce mismatch 감지, Browser OAuth로 fallback합니다. '
              'Supabase Dashboard > Authentication > Providers > Google에서 '
              '"Skip nonce check" 설정도 확인해 주세요.',
            );
            await disconnect();
            return await _signInWithGoogleOAuth();
          }
          rethrow;
        }
      }

      Logger.info('[GoogleAuthProvider] Browser OAuth fallback 시작');
      return await _signInWithGoogleOAuth();
    } catch (error) {
      if (_isCancellationError(error)) {
        Logger.info('[GoogleAuthProvider] Google 로그인 취소 감지');
        return const SocialAuthAttemptResult.cancelled();
      }

      Logger.warning(
          '[GoogleAuthProvider] Google 로그인 실패 (선택적 기능, 다른 로그인 방법 사용 권장): $error');
      Logger.warning(
          '[GoogleAuthProvider] Google 로그인 에러 타입 (선택적 기능, 다른 로그인 방법 사용 권장): ${error.runtimeType}');
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    final googleSignIn = _googleSignIn;
    if (googleSignIn == null) {
      return;
    }

    try {
      await googleSignIn.signOut();
      Logger.info('[GoogleAuthProvider] Google SDK 로컬 세션 정리 완료');
    } catch (error) {
      Logger.warning('[GoogleAuthProvider] Google SDK 세션 정리 실패: $error');
    }
  }

  bool get _isWeb => _isWebOverride ?? kIsWeb;

  bool get _isIOS => !_isWeb && (_isIOSOverride ?? Platform.isIOS);

  bool get _isAndroid => !_isWeb && (_isAndroidOverride ?? Platform.isAndroid);

  bool get _supportsNativeGoogleSignIn => _isIOS || _isAndroid;

  GoogleSignIn get _googleSignInClient {
    return _googleSignIn ??= GoogleSignIn(
      scopes: const ['email'],
      clientId: _isIOS ? _googleIosClientId : null,
      serverClientId: _googleWebClientId,
    );
  }

  Future<AuthResponse> _signInWithGoogleNative() async {
    if (_nativeSignInOverride != null) {
      return _nativeSignInOverride();
    }

    final googleUser = await _googleSignInClient.signIn();
    if (googleUser == null) {
      throw _GoogleSignInCancelledException();
    }

    final googleAuth = await googleUser.authentication;
    final accessToken = googleAuth.accessToken;
    final idToken = googleAuth.idToken;

    if (accessToken == null || accessToken.isEmpty) {
      throw Exception('Google access token을 가져오지 못했습니다.');
    }

    if (idToken == null || idToken.isEmpty) {
      throw Exception('Google ID token을 가져오지 못했습니다.');
    }

    final response = await supabase.auth
        .signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
      accessToken: accessToken,
    )
        .timeout(
      const Duration(seconds: 30),
      onTimeout: () {
        throw TimeoutException('Google 인증 서버 응답 지연. 잠시 후 다시 시도해 주세요.');
      },
    );

    Logger.securityCheckpoint('Google: ${response.user?.id}');

    if (response.user != null) {
      await AuthProviderUtils.updateUserProfile(
        supabase: supabase,
        profileCache: profileCache,
        userId: response.user!.id,
        email: googleUser.email,
        name: googleUser.displayName,
        photoUrl: googleUser.photoUrl,
        provider: providerName,
      ).catchError((error) {
        Logger.warning(
            '[GoogleAuthProvider] 백그라운드 프로필 업데이트 실패 (선택적 기능, 나중에 재시도): $error');
      });
    }

    return response;
  }

  Future<SocialAuthAttemptResult> _signInWithGoogleOAuth() async {
    try {
      final redirectTo = _resolveRedirectTo();
      Logger.info('Google OAuth redirectTo: $redirectTo');
      final flowId =
          OAuthInAppBrowserCoordinator.markOAuthStarted(providerName);

      final response = await (_signInWithOAuthOverride != null
          ? _signInWithOAuthOverride()
          : supabase.auth.signInWithOAuth(
              OAuthProvider.google,
              redirectTo: redirectTo,
              authScreenLaunchMode: LaunchMode.inAppBrowserView,
            ));

      if (!response) {
        OAuthInAppBrowserCoordinator.markOAuthFinished(reason: 'launch_failed');
        Logger.warning('Google OAuth initiation failed');
        throw Exception('Google OAuth sign in failed to start');
      }

      unawaited(
        OAuthInAppBrowserCoordinator.watchForSessionAndClose(
          supabase,
          flowId: flowId,
        ),
      );

      Logger.securityCheckpoint('Google OAuth flow initiated');
      return const SocialAuthAttemptResult.pendingExternalAuth();
    } catch (error) {
      final recoveredResponse =
          await (_recoverAuthResponseAfterLaunchErrorOverride?.call(error) ??
              OAuthInAppBrowserCoordinator.recoverAuthResponseAfterLaunchError(
                supabase,
                provider: providerName,
                error: error,
                isIOSOverride: _isIOSOverride,
              ));
      if (recoveredResponse != null) {
        Logger.info(
          '[GoogleAuthProvider] OAuth launch exception ignored after session recovery',
        );
        return SocialAuthAttemptResult.authenticated(recoveredResponse);
      }

      OAuthInAppBrowserCoordinator.markOAuthFinished(reason: 'exception');
      rethrow;
    }
  }

  String _resolveRedirectTo() {
    return SocialAuthRedirectUrlResolver.resolveOAuthRedirectTo(isWeb: _isWeb);
  }

  String get _googleWebClientId =>
      _configuredClientId(Environment.googleWebClientId) ??
      _fallbackGoogleWebClientId;

  String get _googleIosClientId =>
      _configuredClientId(Environment.googleIosClientId) ??
      _fallbackGoogleIosClientId;

  String? _configuredClientId(String value) {
    final trimmed = value.trim();
    if (trimmed.isEmpty ||
        trimmed.contains('your-') ||
        trimmed.contains('placeholder')) {
      return null;
    }
    return trimmed;
  }

  bool _isCancellationError(Object error) {
    if (error is _GoogleSignInCancelledException) {
      return true;
    }

    if (error is PlatformException) {
      return error.code == GoogleSignIn.kSignInCanceledError ||
          (error.message?.toLowerCase().contains('cancel') ?? false);
    }

    final normalized = error.toString().toLowerCase();
    return normalized.contains('cancelled') ||
        normalized.contains('canceled') ||
        normalized.contains('취소');
  }

  bool _shouldFallbackToOAuth(Object error) {
    if (!_isIOS) {
      return false;
    }

    final normalized = error.toString().toLowerCase();
    return normalized.contains('passed nonce') &&
        normalized.contains('id_token') &&
        normalized.contains('both exist or not');
  }
}
