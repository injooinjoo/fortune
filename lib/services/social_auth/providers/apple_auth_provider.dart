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

class AppleAuthProvider extends BaseSocialAuthProvider {
  AppleAuthProvider(
    super.supabase,
    super.profileCache, {
    bool? isWebOverride,
    bool? isIOSOverride,
    Future<bool> Function()? shouldUseNativeAppleSignInOverride,
    Future<AuthResponse?> Function()? nativeSignInOverride,
    Future<SocialAuthAttemptResult> Function()? oauthSignInOverride,
  })  : _isWebOverride = isWebOverride,
        _isIOSOverride = isIOSOverride,
        _shouldUseNativeAppleSignInOverride =
            shouldUseNativeAppleSignInOverride,
        _nativeSignInOverride = nativeSignInOverride,
        _oauthSignInOverride = oauthSignInOverride,
        _deviceInfo = DeviceInfoPlugin();

  /// iPad Error 1000 재시도 횟수 추적
  int _error1000RetryCount = 0;
  static const int _maxError1000Retries = 1;
  final bool? _isWebOverride;
  final bool? _isIOSOverride;
  final Future<bool> Function()? _shouldUseNativeAppleSignInOverride;
  final Future<AuthResponse?> Function()? _nativeSignInOverride;
  final Future<SocialAuthAttemptResult> Function()? _oauthSignInOverride;
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
        Logger.info('Using native Apple Sign-In for iPhone');
        final nativeResponse = await _signInWithAppleNative();
        if (nativeResponse?.user != null) {
          return SocialAuthAttemptResult.authenticated(nativeResponse!);
        }

        Logger.warning(
            'Apple native sign-in did not return a valid session, fallback to OAuth flow');
        return await _signInWithAppleOAuth();
      } else {
        Logger.info('Using OAuth for Apple Sign-In (web/Android/iPad)');
        return await _signInWithAppleOAuth();
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

      // 15초 타임아웃으로 네트워크 지연 대응 (IPv6/NAT64 환경 고려)
      final response = await supabase.auth
          .signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
      )
          .timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          Logger.warning('[AppleAuthProvider] signInWithIdToken 타임아웃 (15초)');
          throw TimeoutException('Apple 인증 서버 응답 지연. 잠시 후 다시 시도해 주세요.');
        },
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
          '[AppleAuthProvider] Native Apple 로그인 실패, OAuth fallback 시도: $error');

      // 사용자 취소인 경우에만 rethrow
      final errorString = error.toString().toLowerCase();
      if (errorString.contains('cancel') || errorString.contains('cancelled')) {
        rethrow;
      }

      // iPad/Mac Catalyst 환경 또는 기타 실패 시 OAuth로 자동 fallback
      // return null을 반환하면 signIn()에서 OAuth fallback 트리거
      Logger.info('[AppleAuthProvider] OAuth fallback 활성화 (iPad/기타 환경 지원)');
      return null;
    }
  }

  /// Apple Sign-In 에러 처리
  /// - canceled: 사용자 취소 → 예외 throw (로그인 중단)
  /// - Error 1000: iPad 환경 → 1회 재시도 후 OAuth fallback
  /// - 기타 에러: null 반환 (OAuth fallback 트리거)
  Future<AuthResponse?> _handleAppleError(
      SignInWithAppleAuthorizationException e) async {
    if (e.code == AuthorizationErrorCode.canceled) {
      Logger.info('User canceled Apple Sign-In');
      // 사용자 취소는 조용히 처리 (OAuth fallback 없음)
      throw Exception('사용자가 Apple 로그인을 취소했습니다.');
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

    // 나머지 모든 에러는 OAuth fallback 트리거
    Logger.warning(
        '[AppleAuthProvider] Native Apple Sign-In 실패, OAuth fallback 시도: ${e.code} - ${e.message}');

    // null 반환 → signIn()에서 OAuth fallback 실행
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
      final redirectUrl = kIsWeb
          ? '${Uri.base.origin}/auth/callback'
          : 'com.beyond.fortune://auth-callback';

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
    final errorString = error.toString().toLowerCase();
    return errorString.contains('사용자가 apple 로그인을 취소했습니다') ||
        errorString.contains('cancel') ||
        errorString.contains('cancelled');
  }
}
