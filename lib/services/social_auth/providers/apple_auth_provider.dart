import 'dart:async';
import 'package:universal_io/io.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/logger.dart';
import '../../oauth_in_app_browser_coordinator.dart';
import '../base/base_social_auth_provider.dart';

class AppleAuthProvider extends BaseSocialAuthProvider {
  AppleAuthProvider(super.supabase, super.profileCache);

  @override
  String get providerName => 'apple';

  @override
  Future<AuthResponse?> signIn() async {
    try {
      Logger.info('Starting Apple Sign-In process');

      if (!kIsWeb && Platform.isIOS) {
        Logger.info('Using native Apple Sign-In for iOS');
        final nativeResponse = await _signInWithAppleNative();
        if (nativeResponse?.user != null && nativeResponse?.session != null) {
          return nativeResponse;
        }

        Logger.warning(
            'Apple native sign-in did not return a valid session, fallback to OAuth flow');
        return await _signInWithAppleOAuth();
      } else {
        Logger.info('Using OAuth for Apple Sign-In (web/Android)');
        return await _signInWithAppleOAuth();
      }
    } catch (error) {
      Logger.warning(
          '[AppleAuthProvider] Apple 로그인 실패 (선택적 기능, 다른 로그인 방법 사용 권장): $error');
      rethrow;
    }
  }

  Future<AuthResponse?> _signInWithAppleNative() async {
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

      final response = await supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,
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
      return _handleAppleError(e);
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
  /// - canceled: 사용자 취소 → null 반환 (로그인 중단)
  /// - 기타 에러: null 반환 (OAuth fallback 트리거)
  AuthResponse? _handleAppleError(SignInWithAppleAuthorizationException e) {
    if (e.code == AuthorizationErrorCode.canceled) {
      Logger.info('User canceled Apple Sign-In');
      // 사용자 취소는 조용히 처리 (OAuth fallback 없음)
      throw Exception('사용자가 Apple 로그인을 취소했습니다.');
    }

    // 나머지 모든 에러는 OAuth fallback 트리거
    Logger.warning(
        '[AppleAuthProvider] Native Apple Sign-In 실패, OAuth fallback 시도: ${e.code} - ${e.message}');

    if (e.code == AuthorizationErrorCode.unknown &&
        (e.message.contains('1000') || e.toString().contains('1000'))) {
      Logger.info(
          '[AppleAuthProvider] Error 1000 감지 - iPad/Catalyst 환경일 수 있음, OAuth로 전환');
    }

    // null 반환 → signIn()에서 OAuth fallback 실행
    return null;
  }

  Future<AuthResponse?> _signInWithAppleOAuth() async {
    try {
      Logger.info('Using Apple OAuth sign in');
      final flowId =
          OAuthInAppBrowserCoordinator.markOAuthStarted(providerName);

      final response = await supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: kIsWeb
            ? '${Uri.base.origin}/auth/callback'
            : 'com.beyond.fortune://auth-callback',
        authScreenLaunchMode: LaunchMode.inAppBrowserView,
      );

      if (!response) {
        OAuthInAppBrowserCoordinator.markOAuthFinished(reason: 'launch_failed');
        throw Exception('Apple OAuth sign in failed');
      }

      unawaited(
        OAuthInAppBrowserCoordinator.watchForSessionAndClose(
          supabase,
          flowId: flowId,
        ),
      );
      Logger.securityCheckpoint('Apple OAuth sign in initiated');
      return null;
    } catch (error) {
      OAuthInAppBrowserCoordinator.markOAuthFinished(reason: 'exception');
      Logger.warning(
          '[AppleAuthProvider] Apple OAuth 로그인 실패 (선택적 기능, 다른 로그인 방법 사용 권장): $error');
      rethrow;
    }
  }
}
