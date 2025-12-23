import 'dart:async';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/logger.dart';
import '../base/base_social_auth_provider.dart';

class NaverAuthProvider extends BaseSocialAuthProvider {
  static const _naverChannel = MethodChannel('com.beyond.fortune/naver_auth');

  NaverAuthProvider(super.supabase, super.profileCache);

  @override
  String get providerName => 'naver';

  @override
  Future<AuthResponse?> signIn() async {
    try {
      Logger.info('Starting Naver Sign-In process (Native)');

      final initResult = await _naverChannel
          .invokeMethod('initializeNaver')
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              Logger.warning('Naver SDK initialization timed out');
              throw TimeoutException('Naver SDK initialization timed out');
            },
          );
      Logger.info('Naver SDK initialization: $initResult');

      final loginResult = await _naverChannel.invokeMethod('loginWithNaver');
      Logger.info('Naver native login result: $loginResult');

      if (loginResult == null || loginResult['success'] != true) {
        Logger.info('User cancelled Naver Sign-In or login failed');
        return null;
      }

      final accessToken = loginResult['accessToken'] as String?;
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Failed to get Naver access token');
      }

      Logger.info('Got Naver access token, calling Edge Function');
      Logger.info('Access token (first 10 chars): ${accessToken.substring(0, 10 > accessToken.length ? accessToken.length : 10)}...');

      final response = await supabase.functions.invoke(
        'naver-oauth',
        body: {'access_token': accessToken},
      );

      Logger.info('Edge Function response status: ${response.status}');
      Logger.info('Edge Function response data: ${response.data}');

      if (response.status != 200) {
        Logger.warning('[NaverAuthProvider] Naver OAuth Edge Function 실패 (선택적 기능, 다른 로그인 방법 사용 권장): ${response.status}');
        Logger.warning('[NaverAuthProvider] Naver OAuth 응답 데이터 (선택적 기능, 다른 로그인 방법 사용 권장): ${response.data}');

        final errorData = response.data as Map<String, dynamic>?;
        final errorMessage = errorData?['error']?.toString() ?? '';
        if (errorMessage.contains('already been registered')) {
          throw const AuthException(
            '이미 다른 소셜 계정(Google, Kakao, Apple)으로 가입된 이메일입니다.\n'
            '다른 로그인 방법을 시도해주세요.',
          );
        }

        throw Exception('Naver OAuth failed: Status ${response.status}, Data: ${response.data}');
      }

      final data = response.data as Map<String, dynamic>;

      if (data['success'] != true) {
        Logger.warning('[NaverAuthProvider] Naver OAuth 실패 (선택적 기능, 다른 로그인 방법 사용 권장): ${data['error'] ?? 'Unknown error'}');
        Logger.warning('[NaverAuthProvider] Naver OAuth 전체 응답 데이터 (선택적 기능, 다른 로그인 방법 사용 권장): $data');

        final errorMessage = data['error']?.toString() ?? '';
        if (errorMessage.contains('already been registered')) {
          throw const AuthException(
            '이미 다른 소셜 계정(Google, Kakao, Apple)으로 가입된 이메일입니다.\n'
            '다른 로그인 방법을 시도해주세요.',
          );
        }

        throw Exception(data['error'] ?? 'Naver OAuth failed');
      }

      final sessionData = data['session'] as Map<String, dynamic>?;
      if (sessionData != null && sessionData['access_token'] != null) {
        Logger.info('Got session tokens directly from Edge Function');

        try {
          final refreshToken = sessionData['refresh_token'] as String?;
          if (refreshToken != null) {
            final authResponse = await supabase.auth.setSession(refreshToken);

            if (authResponse.session != null) {
              Logger.securityCheckpoint('Naver: ${authResponse.session?.user.id}');
              return authResponse;
            }
          }
          Logger.warning('Failed to set session with tokens, falling back to magic link');
        } catch (e) {
          Logger.warning('Session setting failed: $e, falling back to magic link');
        }
      }

      final sessionUrl = data['session_url'] as String?;
      if (sessionUrl == null) {
        final userData = data['user'] as Map<String, dynamic>?;
        if (userData != null && userData['id'] != null) {
          Logger.info('User created successfully but session pending');
          return AuthResponse(
            session: null,
            user: User(
              id: userData['id'] as String,
              email: userData['email'] as String?,
              appMetadata: {'provider': 'naver'},
              userMetadata: {
                'name': userData['name'],
                'profile_image': userData['profile_image']
              },
              aud: '',
              createdAt: DateTime.now().toIso8601String(),
            ),
          );
        }
        throw Exception('No session URL returned from Naver OAuth');
      }

      Logger.info('Got session URL from Edge Function, processing via getSessionFromUrl...');

      final uri = Uri.parse(sessionUrl);
      final sessionResponse = await supabase.auth.getSessionFromUrl(uri);

      Logger.securityCheckpoint('Naver: ${sessionResponse.session.user.id}');

      return AuthResponse(
        session: sessionResponse.session,
        user: sessionResponse.session.user,
      );
    } catch (error) {
      Logger.warning('[NaverAuthProvider] Naver 로그인 실패 (선택적 기능, 다른 로그인 방법 사용 권장): $error');
      rethrow;
    }
  }

  @override
  Future<void> disconnect() async {
    try {
      await _naverChannel.invokeMethod('logoutNaver');
    } catch (e) {
      Logger.warning('[NaverAuthProvider] Naver 연결 해제 실패 (선택적 기능, 수동 연결 해제 가능): $e');
    }
  }
}
