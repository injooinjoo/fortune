import 'package:universal_io/io.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/logger.dart';
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
        return await _signInWithAppleNative();
      } else {
        Logger.info('Using OAuth for Apple Sign-In (web/Android)');
        return await _signInWithAppleOAuth();
      }
    } catch (error) {
      Logger.warning('[AppleAuthProvider] Apple 로그인 실패 (선택적 기능, 다른 로그인 방법 사용 권장): $error');
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

      if (response.user != null && credential.givenName != null) {
        AuthProviderUtils.updateUserProfile(
          supabase: supabase,
          profileCache: profileCache,
          userId: response.user!.id,
          email: credential.email,
          name: '${credential.givenName ?? ''} ${credential.familyName ?? ''}',
          provider: 'apple',
        ).catchError((error) {
          Logger.warning('[AppleAuthProvider] 백그라운드 프로필 업데이트 실패 (선택적 기능, 나중에 재시도): $error');
        });
      }

      return response;
    } on SignInWithAppleAuthorizationException catch (e) {
      return _handleAppleError(e);
    } catch (error) {
      Logger.warning('[AppleAuthProvider] 네이티브 Apple 로그인 실패 (선택적 기능, 다른 로그인 방법 사용 권장): $error');

      if (error.toString().contains('not available') ||
          error.toString().contains('simulator')) {
        throw Exception('Apple 로그인은 실제 기기에서만 사용 가능합니다.');
      }
      rethrow;
    }
  }

  AuthResponse? _handleAppleError(SignInWithAppleAuthorizationException e) {
    if (e.code == AuthorizationErrorCode.canceled) {
      Logger.info('User canceled Apple Sign-In');
      return null;
    } else if (e.code == AuthorizationErrorCode.failed) {
      Logger.warning('[AppleAuthProvider] Apple 로그인 인증 실패 (선택적 기능, 다른 로그인 방법 사용 권장): $e');
      throw Exception('Apple 로그인 인증에 실패했습니다. 다시 시도해주세요.');
    } else if (e.code == AuthorizationErrorCode.invalidResponse) {
      Logger.warning('[AppleAuthProvider] Apple 로그인 응답 오류 (선택적 기능, 다른 로그인 방법 사용 권장): $e');
      throw Exception('Apple 서버 응답 오류가 발생했습니다.');
    } else if (e.code == AuthorizationErrorCode.notHandled) {
      Logger.warning('[AppleAuthProvider] Apple 로그인 처리 실패 (선택적 기능, 다른 로그인 방법 사용 권장): $e');
      throw Exception('Apple 로그인을 처리할 수 없습니다.');
    } else if (e.code == AuthorizationErrorCode.unknown) {
      Logger.warning('[AppleAuthProvider] Apple 로그인 알 수 없는 오류 (선택적 기능, 다른 로그인 방법 사용 권장): ${e.code}');
      Logger.warning('[AppleAuthProvider] Apple 로그인 에러 메시지 (선택적 기능, 다른 로그인 방법 사용 권장): ${e.message}');

      if (e.message.contains('1000') || e.toString().contains('1000')) {
        Logger.warning('[AppleAuthProvider] Apple 로그인 오류 1000 발생 (선택적 기능, 설정 확인 필요): 설정 문제 감지됨');
        throw Exception('Apple ID 설정을 확인해주세요');
      }

      if (e.message.isNotEmpty) {
        throw Exception('Apple 로그인 오류: ${e.message}');
      }
      throw Exception('알 수 없는 오류가 발생했습니다. (${e.code})');
    } else {
      Logger.warning('[AppleAuthProvider] Apple 로그인 오류 (선택적 기능, 다른 로그인 방법 사용 권장): $e');
      throw Exception('Apple 로그인 중 오류가 발생했습니다.');
    }
  }

  Future<AuthResponse?> _signInWithAppleOAuth() async {
    try {
      Logger.info('Using Apple OAuth sign in');

      final response = await supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: kIsWeb
            ? '${Uri.base.origin}/auth/callback'
            : 'com.beyond.fortune://auth-callback',
        authScreenLaunchMode: LaunchMode.platformDefault,
      );

      if (!response) {
        throw Exception('Apple OAuth sign in failed');
      }

      Logger.securityCheckpoint('Apple OAuth sign in initiated');
      return null;
    } catch (error) {
      Logger.warning('[AppleAuthProvider] Apple OAuth 로그인 실패 (선택적 기능, 다른 로그인 방법 사용 권장): $error');
      rethrow;
    }
  }
}
