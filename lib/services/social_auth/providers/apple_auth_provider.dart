import 'dart:async';
import 'package:universal_io/io.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/logger.dart';
import '../../oauth_in_app_browser_coordinator.dart';
import '../base/base_social_auth_provider.dart';
import '../base/social_auth_attempt_result.dart';

class _AppleSignInCancelledException implements Exception {
  @override
  String toString() => '사용자가 Apple 로그인을 취소했습니다.';
}

class _AppleSignInFailedException implements Exception {
  _AppleSignInFailedException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AppleAuthProvider extends BaseSocialAuthProvider {
  AppleAuthProvider(
    super.supabase,
    super.profileCache, {
    bool? isWebOverride,
    bool? isIOSOverride,
    Future<bool> Function()? shouldUseNativeAppleSignInOverride,
    Future<AuthResponse?> Function()? nativeSignInOverride,
    Future<SocialAuthAttemptResult> Function()? oauthSignInOverride,
    Duration nativeRetryDelay = const Duration(seconds: 1),
    Duration oauthRetryDelay = const Duration(seconds: 2),
  })  : _isWebOverride = isWebOverride,
        _isIOSOverride = isIOSOverride,
        _shouldUseNativeAppleSignInOverride =
            shouldUseNativeAppleSignInOverride,
        _nativeSignInOverride = nativeSignInOverride,
        _oauthSignInOverride = oauthSignInOverride,
        _nativeRetryDelay = nativeRetryDelay,
        _oauthRetryDelay = oauthRetryDelay,
        _deviceInfo = DeviceInfoPlugin();

  /// iPad Error 1000 재시도 횟수 추적
  int _error1000RetryCount = 0;
  static const int _maxError1000Retries = 1;
  final bool? _isWebOverride;
  final bool? _isIOSOverride;
  final Future<bool> Function()? _shouldUseNativeAppleSignInOverride;
  final Future<AuthResponse?> Function()? _nativeSignInOverride;
  final Future<SocialAuthAttemptResult> Function()? _oauthSignInOverride;
  final Duration _nativeRetryDelay;
  final Duration _oauthRetryDelay;
  final DeviceInfoPlugin _deviceInfo;

  @override
  String get providerName => 'apple';

  @override
  Future<SocialAuthAttemptResult> signIn() async {
    // 새 로그인 시도 시 재시도 카운터 리셋
    _error1000RetryCount = 0;

    try {
      Logger.info('Starting Apple Sign-In process');
      SocialAuthConfigGuard.ensureOAuthConfigurationIsValid(
        providerName: providerName,
        supabase: supabase,
      );

      final shouldUseNativeAppleSignIn = await _shouldUseNativeAppleSignIn();

      if (shouldUseNativeAppleSignIn) {
        return await _signInWithAppleNativePreferred();
      } else {
        Logger.info('Using OAuth for Apple Sign-In (web/Android/iPad)');
        return await _signInWithAppleOAuthWithRetry();
      }
    } catch (error) {
      if (_isCancellationError(error)) {
        Logger.info('[AppleAuthProvider] Apple 로그인 취소 감지');
        return const SocialAuthAttemptResult.cancelled();
      }
      Logger.warning(
          '[AppleAuthProvider] Apple 로그인 실패 (선택적 기능, 다른 로그인 방법 사용 권장): $error');
      rethrow;
    }
  }

  Future<SocialAuthAttemptResult> _signInWithAppleNativePreferred() async {
    Logger.info('Using native Apple Sign-In for iPhone');

    Object? lastError;

    for (var attempt = 1; attempt <= 2; attempt++) {
      try {
        final nativeResponse = await _signInWithAppleNative();
        if (nativeResponse?.user != null) {
          return SocialAuthAttemptResult.authenticated(nativeResponse!);
        }

        lastError = _AppleSignInFailedException(
          'Apple 로그인 세션을 확인하지 못했습니다. 잠시 후 다시 시도해 주세요.',
        );
      } catch (error) {
        if (_isCancellationError(error)) {
          rethrow;
        }
        lastError = error;
      }

      if (attempt == 2) {
        break;
      }

      final retryDelayLabel = _nativeRetryDelay.inMilliseconds % 1000 == 0
          ? '${_nativeRetryDelay.inSeconds}초'
          : '${_nativeRetryDelay.inMilliseconds}ms';
      Logger.warning(
        '[AppleAuthProvider] Native Apple 로그인 재시도 준비 ($attempt/2, 대기: $retryDelayLabel)',
      );
      await Future<void>.delayed(_nativeRetryDelay);
    }

    Logger.warning(
      '[AppleAuthProvider] iPhone에서 web OAuth fallback 차단, native Apple 로그인 실패 유지: $lastError',
    );
    throw _AppleSignInFailedException(
      'Apple 로그인을 완료하지 못했습니다. 잠시 후 다시 시도해 주세요.',
    );
  }

  Future<SocialAuthAttemptResult> _signInWithAppleOAuthWithRetry() async {
    try {
      return await _signInWithAppleOAuth();
    } catch (oauthError) {
      if (_isCancellationError(oauthError)) {
        rethrow;
      }

      final retryDelayLabel = _oauthRetryDelay.inMilliseconds % 1000 == 0
          ? '${_oauthRetryDelay.inSeconds}초'
          : '${_oauthRetryDelay.inMilliseconds}ms';
      Logger.warning(
          '[AppleAuthProvider] OAuth fallback 실패, $retryDelayLabel 후 재시도: $oauthError');
      await Future<void>.delayed(_oauthRetryDelay);
      return await _signInWithAppleOAuth();
    }
  }

  Future<bool> _shouldUseNativeAppleSignIn() async {
    final shouldUseNativeAppleSignInOverride =
        _shouldUseNativeAppleSignInOverride;
    if (shouldUseNativeAppleSignInOverride != null) {
      return shouldUseNativeAppleSignInOverride();
    }
    if (_isWebOverride == true) {
      return false;
    }
    if (_isIOSOverride == false) {
      return false;
    }

    final isIOS = _isIOSOverride ?? (!kIsWeb && Platform.isIOS);
    if (!isIOS) {
      return false;
    }

    try {
      final iosInfo = await _deviceInfo.iosInfo;
      final localizedModel = iosInfo.localizedModel.toLowerCase();
      final machine = iosInfo.utsname.machine.toLowerCase();
      final isIPad =
          localizedModel.contains('ipad') || machine.startsWith('ipad');

      if (iosInfo.isiOSAppOnMac || isIPad) {
        Logger.info(
            '[AppleAuthProvider] Native Apple Sign-In 비활성화: ${iosInfo.localizedModel} (${iosInfo.utsname.machine})');
        return false;
      }
    } catch (error) {
      Logger.warning(
          '[AppleAuthProvider] iOS 기기 판별 실패, native Apple Sign-In 유지: $error');
    }

    return true;
  }

  Future<AuthResponse?> _signInWithAppleNative() async {
    if (_nativeSignInOverride != null) {
      return _nativeSignInOverride();
    }

    try {
      Logger.info('Starting native Apple Sign-In process...');
      Logger.info('Platform: ${Platform.operatingSystem}');
      Logger.info('Device info: ${Platform.localHostname}');

      try {
        final iosInfo = await _deviceInfo.iosInfo;
        Logger.info('[AppleAuthProvider] Device: ${iosInfo.utsname.machine}, '
            'iOS: ${iosInfo.systemVersion}, '
            'Model: ${iosInfo.localizedModel}');
      } catch (_) {}

      final rawNonce = supabase.auth.generateRawNonce();
      Logger.info('Generated raw nonce for Supabase');

      final bytes = utf8.encode(rawNonce);
      final digest = sha256.convert(bytes);
      final hashedNonce = digest.toString();
      Logger.info('Generated SHA256 hashed nonce for Apple');

      Logger.info('Requesting Apple ID credential with hashed nonce...');
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      Logger.info('Apple credential received successfully');

      final String? idToken = credential.identityToken;
      if (idToken == null) {
        throw Exception('Failed to obtain Apple ID token');
      }

      final response = await _exchangeAppleIdTokenForSession(
        idToken: idToken,
        rawNonce: rawNonce,
      );

      Logger.securityCheckpoint('Apple: ${response.user?.id}');

      if (response.user != null) {
        final fullName =
            '${credential.givenName ?? ''} ${credential.familyName ?? ''}'
                .trim();
        await AuthProviderUtils.updateUserProfile(
          supabase: supabase,
          profileCache: profileCache,
          userId: response.user!.id,
          email: credential.email,
          name: fullName.isEmpty ? null : fullName,
          provider: 'apple',
        ).catchError((error) {
          Logger.warning(
              '[AppleAuthProvider] 백그라운드 프로필 업데이트 실패 (선택적 기능, 나중에 재시도): $error');
        });
      }

      return response;
    } on SignInWithAppleAuthorizationException catch (e) {
      return await _handleAppleError(e);
    } catch (error) {
      Logger.warning(
          '[AppleAuthProvider] Native Apple 로그인 실패 (${error.runtimeType}), 상위 레이어에서 복구 여부 결정: $error');

      // 사용자 취소인 경우에만 rethrow (타입 기반 감지로 iOS 26 호환성 확보)
      if (error is _AppleSignInCancelledException) {
        rethrow;
      }

      // 그 외 모든 에러 → null 반환 → signIn() 상위 레이어에서 재시도/후속 처리 결정
      Logger.info(
          '[AppleAuthProvider] Native 후속 처리 위임 (에러 타입: ${error.runtimeType})');
      return null;
    }
  }

  Future<AuthResponse> _exchangeAppleIdTokenForSession({
    required String idToken,
    required String rawNonce,
  }) async {
    Object? lastError;

    for (var attempt = 1; attempt <= 2; attempt++) {
      try {
        // 30초 타임아웃으로 네트워크 지연 대응 (iOS 26 프라이버시 릴레이/IPv6/NAT64 환경 고려)
        return await supabase.auth
            .signInWithIdToken(
          provider: OAuthProvider.apple,
          idToken: idToken,
          nonce: rawNonce,
        )
            .timeout(
          const Duration(seconds: 30),
          onTimeout: () {
            Logger.warning('[AppleAuthProvider] signInWithIdToken 타임아웃 (30초)');
            throw TimeoutException('Apple 인증 서버 응답 지연. 잠시 후 다시 시도해 주세요.');
          },
        );
      } catch (error) {
        lastError = error;
        if (!_isRecoverableNativeSessionError(error) || attempt == 2) {
          rethrow;
        }

        Logger.warning(
          '[AppleAuthProvider] signInWithIdToken 재시도 ($attempt/2): $error',
        );
        await Future<void>.delayed(const Duration(seconds: 1));
      }
    }

    throw lastError ??
        _AppleSignInFailedException(
          'Apple 로그인을 완료하지 못했습니다. 잠시 후 다시 시도해 주세요.',
        );
  }

  bool _isRecoverableNativeSessionError(Object error) {
    if (error is TimeoutException) {
      return true;
    }

    final errorString = error.toString().toLowerCase();
    return errorString.contains('network') ||
        errorString.contains('socket') ||
        errorString.contains('timed out') ||
        errorString.contains('timeout') ||
        errorString.contains('temporarily unavailable');
  }

  /// Apple Sign-In 에러 처리
  /// - canceled: 사용자 취소 → 예외 throw (로그인 중단)
  /// - Error 1000: iPad 환경 → 1회 재시도 후 OAuth fallback
  /// - 기타 에러: null 반환 (상위 레이어가 후속 처리 결정)
  Future<AuthResponse?> _handleAppleError(
      SignInWithAppleAuthorizationException e) async {
    if (e.code == AuthorizationErrorCode.canceled) {
      Logger.info('User canceled Apple Sign-In');
      // 사용자 취소는 조용히 처리 (OAuth fallback 없음)
      throw _AppleSignInCancelledException();
    }

    // Error 1000 감지 - iPad/Catalyst 환경에서 1회 재시도
    if (e.code == AuthorizationErrorCode.unknown &&
        (e.message.contains('1000') || e.toString().contains('1000'))) {
      Logger.info(
          '[AppleAuthProvider] Error 1000 감지 - iPad/Catalyst 환경, 재시도 횟수: $_error1000RetryCount');

      if (_error1000RetryCount < _maxError1000Retries) {
        _error1000RetryCount++;
        Logger.info(
            '[AppleAuthProvider] 1초 대기 후 Native 재시도 ($_error1000RetryCount/$_maxError1000Retries)');

        // iPad에서 일시적 오류일 수 있으므로 1초 대기 후 재시도
        await Future<void>.delayed(const Duration(seconds: 1));

        try {
          final retryResponse = await _signInWithAppleNative();
          if (retryResponse?.user != null && retryResponse?.session != null) {
            Logger.info('[AppleAuthProvider] Error 1000 재시도 성공');
            return retryResponse;
          }
        } catch (retryError) {
          Logger.warning('[AppleAuthProvider] Error 1000 재시도 실패: $retryError');
        }
      }

      Logger.info('[AppleAuthProvider] Error 1000 재시도 한도 초과, OAuth로 전환');
    }

    // 나머지 모든 에러는 상위 레이어가 후속 처리 결정
    Logger.warning(
        '[AppleAuthProvider] Native Apple Sign-In 실패, 상위 레이어에서 후속 처리 결정: ${e.code} - ${e.message}');

    // null 반환 → signIn() 상위 레이어에서 재시도/후속 처리 실행
    return null;
  }

  Future<SocialAuthAttemptResult> _signInWithAppleOAuth() async {
    if (_oauthSignInOverride != null) {
      return _oauthSignInOverride();
    }

    try {
      Logger.info('[AppleAuthProvider] OAuth fallback 시작');
      SocialAuthConfigGuard.ensureOAuthConfigurationIsValid(
        providerName: providerName,
        supabase: supabase,
      );
      final flowId =
          OAuthInAppBrowserCoordinator.markOAuthStarted(providerName);

      // Note: redirectTo는 Supabase가 인증 완료 후 앱으로 돌아올 때 사용
      // Apple OAuth 자체는 Supabase Dashboard에 설정된 Service ID와 Return URL을 사용
      final redirectUrl =
          SocialAuthRedirectUrlResolver.resolveOAuthRedirectTo(isWeb: kIsWeb);

      Logger.info('[AppleAuthProvider] OAuth redirect URL: $redirectUrl');

      final response = await supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: redirectUrl,
        authScreenLaunchMode: LaunchMode.inAppBrowserView,
      );

      if (!response) {
        OAuthInAppBrowserCoordinator.markOAuthFinished(reason: 'launch_failed');
        throw Exception('Apple OAuth sign in failed to launch browser');
      }

      unawaited(
        OAuthInAppBrowserCoordinator.watchForSessionAndClose(
          supabase,
          flowId: flowId,
        ),
      );
      Logger.securityCheckpoint('Apple OAuth sign in initiated');
      return const SocialAuthAttemptResult.pendingExternalAuth();
    } catch (error) {
      final recoveredResponse = await OAuthInAppBrowserCoordinator
          .recoverAuthResponseAfterLaunchError(
        supabase,
        provider: providerName,
        error: error,
      );
      if (recoveredResponse != null) {
        Logger.info(
          '[AppleAuthProvider] OAuth launch exception ignored after session recovery',
        );
        return SocialAuthAttemptResult.authenticated(recoveredResponse);
      }

      OAuthInAppBrowserCoordinator.markOAuthFinished(reason: 'exception');
      // OAuth 에러는 주로 Apple Developer Console/Supabase 설정 문제
      // "Invalid client id or web redirect url" → Service ID/Return URL 설정 확인 필요
      Logger.warning('[AppleAuthProvider] Apple OAuth 실패: $error\n'
          '→ Apple Developer Console에서 Service ID의 Return URL 확인 필요\n'
          '→ Supabase Dashboard에서 Apple Provider 설정 확인 필요');
      rethrow;
    }
  }

  bool _isCancellationError(Object error) {
    if (error is _AppleSignInCancelledException) return true;
    final errorString = error.toString().toLowerCase();
    return errorString.contains('사용자가 apple 로그인을 취소했습니다');
  }
}
