import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/logger.dart';
import '../base/base_social_auth_provider.dart';

class KakaoAuthProvider extends BaseSocialAuthProvider {
  KakaoAuthProvider(super.supabase, super.profileCache);

  @override
  String get providerName => 'kakao';

  @override
  Future<AuthResponse?> signIn() async {
    try {
      Logger.info('=== KAKAO SIGN-IN STARTED ===');
      Logger.info('Platform: ${kIsWeb ? 'Web' : (Platform.isIOS ? 'iOS' : 'Android')}');

      if (!kIsWeb && (Platform.isIOS || Platform.isAndroid)) {
        Logger.info('Using native Kakao SDK for mobile platform');
        final result = await _signInWithKakaoNative();
        Logger.info('Native Kakao result: ${result != null ? 'Success' : 'Null/OAuth flow'}');
        return result;
      } else {
        Logger.info('Using Kakao OAuth for web platform');
        final result = await _signInWithKakaoOAuth();
        Logger.info('OAuth Kakao result: ${result != null ? 'Success' : 'Null/OAuth flow'}');
        return result;
      }
    } catch (error) {
      Logger.warning('[KakaoAuthProvider] Kakao 로그인 실패 (선택적 기능, 다른 로그인 방법 사용 권장): $error');
      Logger.warning('[KakaoAuthProvider] Kakao 로그인 에러 타입 (선택적 기능, 다른 로그인 방법 사용 권장): ${error.runtimeType}');
      rethrow;
    }
  }

  Future<AuthResponse?> _signInWithKakaoNative() async {
    try {
      Logger.info('Using native Kakao Sign-In with OAuth');

      bool isKakaoTalkInstalled = await kakao.isKakaoTalkInstalled();

      kakao.OAuthToken token;
      if (isKakaoTalkInstalled) {
        Logger.info('Kakao login via KakaoTalk app');
        token = await kakao.UserApi.instance.loginWithKakaoTalk();
      } else {
        Logger.info('Kakao login via web account');
        token = await kakao.UserApi.instance.loginWithKakaoAccount();
      }

      Logger.info('Kakao OAuth token obtained successfully');

      final kakaoUser = await kakao.UserApi.instance.me();
      Logger.info('Kakao user info retrieved: ${kakaoUser.id}');

      final String email = kakaoUser.kakaoAccount?.email ?? 'kakao_${kakaoUser.id}@kakao.local';
      final String nickname = kakaoUser.kakaoAccount?.profile?.nickname ??
          (kakaoUser.kakaoAccount?.name ?? '사용자');

      Logger.info('🟡 [Kakao] Processing Kakao login:');
      Logger.info('🟡 [Kakao] - Email: $email');
      Logger.info('🟡 [Kakao] - Nickname: $nickname');

      try {
        final response = await supabase.functions.invoke(
          'kakao-oauth',
          body: {
            'access_token': token.accessToken,
            'refresh_token': token.refreshToken,
            'user_info': {
              'id': kakaoUser.id.toString(),
              'email': email,
              'nickname': nickname,
              'profile_image_url': kakaoUser.kakaoAccount?.profile?.profileImageUrl,
            }
          },
        );

        if (response.status != 200) {
          Logger.warning('[KakaoAuthProvider] Kakao OAuth Edge Function 실패 (선택적 기능, 대체 인증 방법 사용): ${response.status}');
          throw Exception('Kakao OAuth failed: ${response.data}');
        }

        final data = response.data as Map<String, dynamic>;
        Logger.info('Edge Function response data: ${data.keys.join(', ')}');

        if (!data['success']) {
          throw Exception(data['error'] ?? 'Kakao OAuth failed');
        }

        if (data['needsManualAuth'] == true) {
          Logger.info('Edge Function requires manual auth, falling back...');
          throw Exception('Manual auth required');
        }

        final sessionData = data['session'] as Map<String, dynamic>?;
        Session? currentSession;

        if (sessionData != null && sessionData['access_token'] != null) {
          Logger.info('Got session from Edge Function, processing...');

          final accessToken = sessionData['access_token'] as String;
          final refreshToken = sessionData['refresh_token'] as String?;

          if (refreshToken != null) {
            await supabase.auth.setSession(refreshToken);
            currentSession = supabase.auth.currentSession;
          } else {
            await supabase.auth.setSession(accessToken);
            currentSession = supabase.auth.currentSession;
          }

          if (currentSession == null) {
            Logger.warning('Failed to set session from Edge Function, falling back...');
            throw Exception('Failed to set session from Kakao OAuth');
          }
        } else {
          Logger.info('No session from Edge Function, falling back to manual auth...');
          throw Exception('No session returned from Kakao OAuth');
        }

        Logger.securityCheckpoint('Kakao OAuth: ${currentSession.user.id}');

        return AuthResponse(session: currentSession, user: currentSession.user);
      } catch (edgeFunctionError) {
        Logger.warning('[KakaoAuthProvider] Kakao Edge Function 실패, 수동 사용자 생성으로 대체 (선택적 기능, 대체 인증 방법 사용): $edgeFunctionError');

        return await _fallbackManualAuth(kakaoUser, email, nickname);
      }
    } catch (error) {
      Logger.warning('[KakaoAuthProvider] 네이티브 Kakao 로그인 실패 (선택적 기능, 다른 로그인 방법 사용 권장): $error');
      rethrow;
    }
  }

  Future<AuthResponse?> _fallbackManualAuth(
    kakao.User kakaoUser,
    String email,
    String nickname,
  ) async {
    try {
      final existingUser = await _findUserByEmail(email);

      if (existingUser != null) {
        await AuthProviderUtils.updateUserProfile(
          supabase: supabase,
          profileCache: profileCache,
          userId: existingUser.id,
          email: email,
          name: nickname,
          photoUrl: kakaoUser.kakaoAccount?.profile?.profileImageUrl,
          provider: 'kakao',
        );

        final sessionResponse = await _createManualSession(existingUser, kakaoId: kakaoUser.id.toString());
        return sessionResponse;
      } else {
        final password = 'kakao_oauth_${kakaoUser.id}_secure2024';
        final signUpResponse = await supabase.auth.signUp(
          email: email,
          password: password,
          data: {
            'provider': 'kakao',
            'kakao_id': kakaoUser.id.toString(),
            'name': nickname,
            'profile_image': kakaoUser.kakaoAccount?.profile?.profileImageUrl,
            'email_confirmed_at': DateTime.now().toIso8601String(),
          },
          emailRedirectTo: 'com.beyond.fortune://auth-callback',
        );

        if (signUpResponse.user != null) {
          Logger.securityCheckpoint('Kakao new user: ${signUpResponse.user?.id}');

          await AuthProviderUtils.updateUserProfile(
            supabase: supabase,
            profileCache: profileCache,
            userId: signUpResponse.user!.id,
            email: email,
            name: nickname,
            photoUrl: kakaoUser.kakaoAccount?.profile?.profileImageUrl,
            provider: 'kakao',
          );

          if (signUpResponse.session != null) {
            Logger.info('Kakao user signed up with session successfully');
            return signUpResponse;
          } else {
            Logger.info('No session from signUp, requesting OTP sign-in');
            try {
              await supabase.auth.signInWithOtp(
                email: email,
                shouldCreateUser: false,
              );
              Logger.info('OTP sent to Kakao user email (if real email)');
            } catch (otpError) {
              Logger.warning('OTP sign-in failed', otpError);
            }
          }
        }

        if (signUpResponse.user != null) {
          Logger.info('Kakao user created successfully, but session creation pending');
          return AuthResponse(
            session: null,
            user: signUpResponse.user,
          );
        }

        return signUpResponse;
      }
    } catch (fallbackError) {
      Logger.warning('[KakaoAuthProvider] Kakao 대체 인증 실패 (선택적 기능, 다른 로그인 방법 사용 권장): $fallbackError');
      throw Exception('Kakao authentication failed: $fallbackError');
    }
  }

  Future<User?> _findUserByEmail(String email) async {
    try {
      final response = await supabase
          .from('auth.users')
          .select('id')
          .eq('email', email)
          .maybeSingle();

      if (response != null) {
        return User.fromJson(response);
      }
      return null;
    } catch (e) {
      Logger.warning('Failed to find user by email', e);
      return null;
    }
  }

  Future<AuthResponse?> _createManualSession(User user, {String? kakaoId}) async {
    final effectiveKakaoId = kakaoId ??
        user.userMetadata?['kakao_id'] ??
        user.appMetadata['provider_id'] ??
        user.id;

    try {
      Logger.info('Creating manual session for user: ${user.id}');

      final password = 'kakao_oauth_${effectiveKakaoId}_secure2024';

      Logger.info('Attempting to sign in existing Kakao user with email: ${user.email}');

      final signInResponse = await supabase.auth.signInWithPassword(
        email: user.email!,
        password: password,
      );

      if (signInResponse.session != null) {
        Logger.info('Successfully signed in existing Kakao user');
        return signInResponse;
      } else {
        Logger.warning('Sign in succeeded but no session returned');
        return null;
      }
    } catch (e) {
      Logger.warning('[KakaoAuthProvider] 수동 세션 생성 실패 (선택적 기능, 재시도 권장): $e');

      try {
        final legacyPassword = 'kakao_oauth_${effectiveKakaoId}_${user.createdAt.replaceAll(RegExp(r'[^0-9]'), '')}';

        Logger.info('Trying legacy password pattern for Kakao user');
        final legacySignIn = await supabase.auth.signInWithPassword(
          email: user.email!,
          password: legacyPassword,
        );

        if (legacySignIn.session != null) {
          Logger.info('Successfully signed in with legacy password');
          return legacySignIn;
        }
      } catch (legacyError) {
        Logger.warning('[KakaoAuthProvider] 레거시 비밀번호 로그인도 실패 (선택적 기능, 새 인증 필요): $legacyError');
      }
      return null;
    }
  }

  Future<AuthResponse?> _signInWithKakaoOAuth() async {
    try {
      Logger.info('Using Kakao OAuth sign in');

      final response = await supabase.auth.signInWithOAuth(
        OAuthProvider.kakao,
        redirectTo: kIsWeb
            ? '${Uri.base.origin}/auth/callback'
            : 'com.beyond.fortune://auth-callback',
        authScreenLaunchMode: LaunchMode.platformDefault,
      );

      if (!response) {
        throw Exception('Kakao OAuth sign in failed');
      }

      Logger.securityCheckpoint('Kakao OAuth sign in initiated');
      return null;
    } catch (error) {
      Logger.warning('[KakaoAuthProvider] Kakao OAuth 로그인 실패 (선택적 기능, 다른 로그인 방법 사용 권장): $error');
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await kakao.UserApi.instance.unlink();
    } catch (e) {
      Logger.warning('[KakaoAuthProvider] Kakao 연결 해제 실패 (선택적 기능, 수동 연결 해제 가능): $e');
    }
  }
}
