import 'dart:io';
import 'dart:convert';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
// import 'package:flutter_naver_login/flutter_naver_login.dart'; // Replaced with native implementation
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/utils/logger.dart';
import '../core/config/environment.dart';
import '../core/cache/profile_cache.dart';
import '../core/utils/performance_monitor.dart';

class SocialAuthService {
  final SupabaseClient _supabase;
  final _profileCache = ProfileCache();
  
  SocialAuthService(this._supabase);

  // Google Sign In - Supabase 표준 OAuth 사용
  Future<AuthResponse?> signInWithGoogle({BuildContext? context}) async {
    try {
      print('🟡 [SocialAuthService] signInWithGoogle() started with Supabase OAuth');
      Logger.info('=== GOOGLE OAUTH SUPABASE PROCESS STARTED ===');
      
      // Debug: Log the Supabase URL being used
      final supabaseUrl = Environment.supabaseUrl;
      Logger.info('Using Supabase URL for OAuth: ${supabaseUrl.substring(0, 30)}...');
      
      // Verify the URL is correct
      if (supabaseUrl.contains('your-project')) {
        Logger.error('Supabase URL is not properly configured');
        throw Exception('Supabase URL is not properly configured');
      }
      
      print('🟡 [SocialAuthService] Starting Supabase OAuth for Google...');
      Logger.info('Starting Supabase OAuth for Google');
      
      // Use Supabase standard OAuth
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb 
          ? '${Uri.base.origin}/auth/callback'
          : 'com.beyond.fortune://auth-callback',
        authScreenLaunchMode: LaunchMode.platformDefault,
      );
      
      if (!response) {
        Logger.warning('Google OAuth initiation failed');
        throw Exception('Google OAuth sign in failed to start');
      }
      
      Logger.info('Google OAuth initiated successfully - redirecting to browser');
      print('🟡 [SocialAuthService] OAuth redirect initiated');
      
      Logger.securityCheckpoint('Google OAuth flow initiated');
      
      // OAuth는 브라우저에서 처리되며, 완료 후 앱으로 돌아올 때 
      // Supabase가 자동으로 세션을 처리합니다.
      // 따라서 여기서는 null을 반환하고, 
      // 실제 인증 완료는 deep link 콜백에서 처리됩니다.
      Logger.info('=== GOOGLE OAUTH SUPABASE INITIATED ===');
      return null;
      
    } catch (error, stackTrace) {
      Logger.error('=== GOOGLE OAUTH SUPABASE FAILED ===', error, stackTrace);
      Logger.error('Error type: ${error.runtimeType}');
      rethrow;
    }
  }
  
  
  // Exchange authorization code for Supabase session
  Future<AuthResponse?> _exchangeCodeForSession(String authData, String redirectUrl) async {
    try {
      Logger.info('Exchanging auth data for session: ${authData.substring(0, 50)}...');
      
      // PRIORITY 1: Check for fragment with access_token first (most common case for OAuth)
      if (authData.contains('#access_token') || (authData.contains('://') && authData.contains('#'))) {
        Logger.info('Processing callback URL with fragment');
        final uri = Uri.parse(authData);
        
        // Handle fragment-based OAuth response (implicit flow)
        if (uri.fragment.isNotEmpty) {
          Logger.info('Fragment found: ${uri.fragment.substring(0, 50)}...');
          
          // Parse the fragment to extract tokens
          final fragment = uri.fragment;
          final fragmentParams = <String, String>{};
          
          for (final param in fragment.split('&')) {
            final keyValue = param.split('=');
            if (keyValue.length == 2) {
              fragmentParams[keyValue[0]] = Uri.decodeComponent(keyValue[1]);
            }
          }
          
          final accessToken = fragmentParams['access_token'];
          final refreshToken = fragmentParams['refresh_token'];
          
          Logger.info('Fragment tokens - access: ${accessToken != null}, refresh: ${refreshToken != null}');
          
          if (accessToken != null) {
            // Use the direct session setting approach that works with Supabase
            try {
              // Create session URL format that Supabase expects
              final sessionUrl = Uri.parse('$redirectUrl#access_token=$accessToken' + 
                (refreshToken != null ? '&refresh_token=$refreshToken' : '') +
                '&token_type=bearer&type=recovery');
              
              Logger.info('Attempting getSessionFromUrl with formatted URL');
              final sessionResponse = await _supabase.auth.getSessionFromUrl(sessionUrl);
              
              if (sessionResponse.session != null) {
                Logger.info('✅ Session created successfully via getSessionFromUrl');
                return AuthResponse(session: sessionResponse.session, user: sessionResponse.session?.user);
              }
            } catch (sessionUrlError) {
              Logger.warning('getSessionFromUrl failed: $sessionUrlError');
            }
            
            // Fallback: Try recoverSession (standard approach)
            try {
              final response = await _supabase.auth.recoverSession(accessToken);
              if (response.session != null) {
                Logger.info('✅ Session recovered via recoverSession');
                return AuthResponse(session: response.session, user: response.session?.user);
              }
            } catch (recoverError) {
              Logger.warning('recoverSession failed: $recoverError');
            }
          }
        }
      }
      
      // PRIORITY 2: Handle authorization code flow
      if (authData.startsWith('http') || authData.contains('://')) {
        Logger.info('Processing standard OAuth callback URL');
        final uri = Uri.parse(authData);
        
        final code = uri.queryParameters['code'];
        if (code != null) {
          Logger.info('Found authorization code, processing with getSessionFromUrl');
          final sessionResponse = await _supabase.auth.getSessionFromUrl(uri);
          return AuthResponse(session: sessionResponse.session, user: sessionResponse.session?.user);
        }
      }
      
      // PRIORITY 3: If authData is just the code
      if (!authData.contains('://') && !authData.contains('#')) {
        Logger.info('Processing raw authorization code');
        final callbackUrl = '$redirectUrl?code=$authData';
        final uri = Uri.parse(callbackUrl);
        final sessionResponse = await _supabase.auth.getSessionFromUrl(uri);
        return AuthResponse(session: sessionResponse.session, user: sessionResponse.session?.user);
      }
      
      Logger.warning('No valid auth data format found');
      return null;
      
    } catch (error) {
      Logger.error('Failed to exchange code for session', error);
      return null;
    }
  }
  
  // Apple Sign In
  Future<AuthResponse?> signInWithApple() async {
    try {
      Logger.info('Starting Apple Sign-In process');
      
      // Use native Sign in with Apple for iOS
      if (!kIsWeb && Platform.isIOS) {
        Logger.info('Using native Apple Sign-In for iOS');
        return await _signInWithAppleNative();
      } else {
        // Use OAuth for web and other platforms
        Logger.info('Using OAuth for Apple Sign-In (web/Android)');
        return await _signInWithAppleOAuth();
      }
    } catch (error) {
      Logger.error('Apple Sign-In failed', error);
      rethrow;
    }
  }
  
  // Native Apple Sign In for iOS/macOS
  Future<AuthResponse?> _signInWithAppleNative() async {
    try {
      Logger.info('Starting native Apple Sign-In process...');
      Logger.info('Platform: ${Platform.operatingSystem}');
      Logger.info('Device info: ${Platform.localHostname}');
      
      // Generate raw nonce for Supabase
      final rawNonce = _supabase.auth.generateRawNonce();
      Logger.info('Generated raw nonce for Supabase');
      
      // Hash the nonce with SHA256 for Apple (iOS 18 requirement)
      final bytes = utf8.encode(rawNonce);
      final digest = sha256.convert(bytes);
      final hashedNonce = digest.toString();
      Logger.info('Generated SHA256 hashed nonce for Apple');
      
      // Apple Sign-In 요청 - 네이티브 시스템 UI가 표시됨
      Logger.info('Requesting Apple ID credential with hashed nonce...');
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,  // Use hashed nonce for Apple
      );
      
      Logger.info('Apple credential received successfully');
      
      final String? idToken = credential.identityToken;
      if (idToken == null) {
        throw Exception('Failed to obtain Apple ID token');
      }
      
      // Supabase에 Apple 토큰으로 로그인
      // IMPORTANT: Use raw (unhashed) nonce for Supabase
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
        nonce: rawNonce,  // Use original raw nonce for Supabase, not hashed
      );
      
      Logger.securityCheckpoint('Apple: ${response.user?.id}');
      
      // 사용자 프로필 업데이트 (비동기로 처리,
      if (response.user != null && credential.givenName != null) {
        // Fire and forget - 프로필 업데이트는 백그라운드에서 처리
        _updateUserProfile(
          userId: response.user!.id,
          email: credential.email,
          name: '${credential.givenName ?? ''} ${credential.familyName ?? ''}',
          provider: 'apple').catchError((error) {
          Logger.error('Background profile update failed', error);
        });
      }
      
      return response;
    } on SignInWithAppleAuthorizationException catch (e) {
      // Apple Sign-In specific errors
      if (e.code == AuthorizationErrorCode.canceled) {
        Logger.info('User canceled Apple Sign-In');
        // Return null for user cancellation - don't throw error
        return null;
      } else if (e.code == AuthorizationErrorCode.failed) {
        Logger.error('Apple Sign-In authorization failed', e);
        throw Exception('Apple 로그인 인증에 실패했습니다. 다시 시도해주세요.');
      } else if (e.code == AuthorizationErrorCode.invalidResponse) {
        Logger.error('Invalid response from Apple Sign-In', e);
        throw Exception('Apple 서버 응답 오류가 발생했습니다.');
      } else if (e.code == AuthorizationErrorCode.notHandled) {
        Logger.error('Apple Sign-In not handled', e);
        throw Exception('Apple 로그인을 처리할 수 없습니다.');
      } else if (e.code == AuthorizationErrorCode.unknown) {
        // Add detailed logging for unknown errors
        Logger.error('Unknown Apple Sign-In error - code: ${e.code}', e);
        Logger.error('Error message: ${e.message}');
        Logger.error('Full error details: ${e.toString()}');
        
        // Check for specific error code 1000
        if (e.message?.contains('1000') ?? false || e.toString().contains('1000')) {
          Logger.error('Apple Sign-In Error 1000 - Configuration issue detected');
          Logger.error('This usually means the app ID configuration is incorrect');
          throw Exception('Apple ID 설정을 확인해주세요');
        }
        
        // Provide more specific error message if possible
        if (e.message != null && e.message!.isNotEmpty) {
          throw Exception('Apple 로그인 오류: ${e.message}');
        }
        throw Exception('알 수 없는 오류가 발생했습니다. (${e.code})');
      } else {
        Logger.error('Apple Sign-In error', e);
        throw Exception('Apple 로그인 중 오류가 발생했습니다.');
      }
    } catch (error) {
      Logger.error('Native Apple Sign-In failed', error);
      // Check if it's a simulator-specific error
      if (error.toString().contains('not available') || 
          error.toString().contains('simulator')) {
        throw Exception('Apple 로그인은 실제 기기에서만 사용 가능합니다.');
      }
      rethrow;
    }
  }
  
  // OAuth Apple Sign In for web and Android
  Future<AuthResponse?> _signInWithAppleOAuth() async {
    try {
      Logger.info('Using Apple OAuth sign in');
      
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.apple,
        redirectTo: kIsWeb 
          ? '${Uri.base.origin}/auth/callback'
          : 'com.beyond.fortune://auth-callback',
        authScreenLaunchMode: LaunchMode.platformDefault);
      
      if (!response) {
        throw Exception('Apple OAuth sign in failed');
      }
      
      Logger.securityCheckpoint('Apple OAuth sign in initiated');
      return null; // OAuth flow will handle the callback
    } catch (error) {
      Logger.error('Apple OAuth Sign-In failed', error);
      rethrow;
    }
  }
  
  // 사용자 프로필 업데이트 (최적화됨,
  Future<void> _updateUserProfile({
    required String userId,
    String? email,
    String? name,
    String? photoUrl,
    required String provider}) async {
    try {
      // 프로필 데이터 준비
      final now = DateTime.now().toIso8601String();
      
      // Upsert 사용으로 단일 쿼리로 처리
      final profileData = {
        'id': userId,
        'email': email,
        'updated_at': null};
      
      // 조건부 필드 추가
      if (name != null && name.isNotEmpty) profileData['name'] = name;
      if (photoUrl != null && photoUrl.isNotEmpty) {
        profileData['profile_image_url'] = photoUrl;
      }
      
      // 캐시에서 먼저 확인
      var existingProfile = _profileCache.get(userId);
      
      // 캐시에 없으면 DB에서 조회
      if (existingProfile == null) {
        existingProfile = await _supabase
            .from('user_profiles')
            .select('linked_providers, primary_provider, name, profile_image_url')
            .eq('id', userId)
            .maybeSingle();
            
        // 조회 결과를 캐시에 저장
        if (existingProfile != null) {
          _profileCache.set(userId, existingProfile);
        }
      }
      
      if (existingProfile == null) {
        // 새 프로필 생성
        Logger.info('Supabase initialized successfully');
        
        try {
          // First try with social auth columns
          profileData.addAll({
            'primary_provider': provider,
            'linked_providers': jsonEncode([provider]),
            'created_at': null});
          
          await _supabase.from('user_profiles').insert(profileData);
          Logger.info('Profile created successfully with social auth columns');
        } catch (insertError) {
          Logger.error('Error creating profile with social auth', insertError);
          
          // Handle various schema issues
          if (insertError.toString().contains('linked_providers') || 
              insertError.toString().contains('primary_provider') ||
              insertError.toString().contains('profile_image_url') ||
              insertError.toString().contains('avatar_url')) {
            Logger.warning('Schema mismatch detected, creating profile with minimal fields');
            
            // Create minimal profile with only essential fields
            final minimalProfile = {
              'id': userId,
              'email': email,
              'name': name ?? '사용자',
              'created_at': now,
              'updated_at': null};
            
            try {
              await _supabase.from('user_profiles').insert(minimalProfile);
              Logger.info('Minimal profile created successfully');
              
              // Try to update with additional fields separately
              final updates = <String, dynamic>{};
              if (photoUrl != null && provider == 'google') {
                // Try both column names
                try {
                  await _supabase.from('user_profiles')
                    .update({'profile_image_url': photoUrl})
                    .eq('id', userId);
                } catch (e) {
                  Logger.warning('Fortune cached');
                }
              }
            } catch (fallbackError) {
              Logger.error('Failed to create minimal profile', fallbackError);
              // Don't throw - allow login to continue
            }
          } else {
            throw insertError;
          }
        }
      } else {
        // 기존 프로필 업데이트
        final updates = <String, dynamic>{
          'updated_at': null};
        
        // Update name if not set or if it's a kakao placeholder
        if (name != null && name.isNotEmpty) {
          final currentName = existingProfile['name'] as String?;
          if (currentName == null || currentName == '사용자' || currentName.startsWith('kakao_')) {
            updates['name'] = name;
          }
        }
        
        // Handle profile image update
        if (photoUrl != null) {
          // For Google, always update; for others, only if not set
          final shouldUpdate = provider == 'google' || 
            existingProfile['profile_image_url'] == null;
          
          if (shouldUpdate) {
            updates['profile_image_url'] = photoUrl;
          }
        }
        
        // Update linked providers
        final linkedProviders = existingProfile['linked_providers'] != null
            ? List<String>.from(existingProfile['linked_providers'])
            : <String>[];
        
        if (!linkedProviders.contains(provider)) {
          linkedProviders.add(provider);
          updates['linked_providers'] = linkedProviders;
        }
        
        // Set primary provider if not set
        if (existingProfile['primary_provider'] == null) {
          updates['primary_provider'] = provider;
        }
        
        if (updates.length > 1) {
          await _supabase
              .from('user_profiles')
              .update(updates)
              .eq('id', userId);
              
          // 캐시 업데이트
          _profileCache.updateFields(userId, updates);
        }
      }
    } catch (error) {
      Logger.error('Failed to update user profile', error);
      // 프로필 업데이트 실패는 로그인을 막지 않음
    }
  }
  
  // Facebook Sign In
  Future<AuthResponse?> signInWithFacebook() async {
    try {
      Logger.info('Starting Facebook Sign-In process with Supabase OAuth');
      
      // Supabase OAuth를 사용한 Facebook 로그인
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.facebook,
        redirectTo: kIsWeb 
          ? '${Uri.base.origin}/auth/callback'
          : 'com.beyond.fortune://auth-callback',
        authScreenLaunchMode: LaunchMode.platformDefault);
      
      if (!response) {
        throw Exception('Facebook OAuth sign in failed');
      }
      
      Logger.securityCheckpoint('Facebook OAuth sign in initiated');
      
      // OAuth 로그인은 웹브라우저를 통해 진행되며,
      // 완료 후 앱으로 돌아올 때 Supabase가 자동으로 세션을 처리합니다.
      return null;
    } catch (error) {
      Logger.error('Facebook Sign-In failed', error);
      rethrow;
    }
  }
  
  // Kakao Sign In
  Future<AuthResponse?> signInWithKakao() async {
    try {
      Logger.info('=== KAKAO SIGN-IN STARTED ===');
      Logger.info('Platform: ${kIsWeb ? 'Web' : (Platform.isIOS ? 'iOS' : 'Android')}');
      
      // iOS/Android에서는 네이티브 카카오 SDK 사용, 웹에서는 OAuth 사용
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
      Logger.error('=== KAKAO SIGN-IN FAILED ===', error);
      Logger.error('Error type: ${error.runtimeType}');
      Logger.error('Error message: ${error.toString()}');
      rethrow;
    }
  }
  
  // 네이티브 카카오 로그인 (iOS/Android) - OAuth 방식으로 변경
  Future<AuthResponse?> _signInWithKakaoNative() async {
    try {
      Logger.info('Using native Kakao Sign-In with OAuth');
      
      // 카카오톡 설치 여부 확인 후 로그인
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
      
      // 사용자 정보 가져오기
      final kakaoUser = await kakao.UserApi.instance.me();
      Logger.info('Kakao user info retrieved: ${kakaoUser.id}');
      
      // Kakao 계정에 이메일이 없는 경우 대체 이메일 생성
      final String email = kakaoUser.kakaoAccount?.email ?? 
                          'kakao_${kakaoUser.id}@kakao.local';
      
      // 카카오 닉네임 가져오기 (없으면 기본값 사용)
      final String nickname = kakaoUser.kakaoAccount?.profile?.nickname ?? 
                            (kakaoUser.kakaoAccount?.name ?? '사용자');
      
      Logger.info('Processing Kakao login for email: $email, nickname: $nickname');
      
      // Supabase Edge Function을 사용해 OAuth 처리
      try {
        final response = await _supabase.functions.invoke(
          'kakao-oauth',
          body: {
            'access_token': token.accessToken,
            'refresh_token': token.refreshToken,
            'user_info': {
              'id': kakaoUser.id.toString(),
              'email': email,
              'nickname': nickname,  // 위에서 계산한 닉네임 사용
              'profile_image_url': kakaoUser.kakaoAccount?.profile?.profileImageUrl,
            }
          }
        );
        
        if (response.status != 200) {
          Logger.error('Kakao OAuth Edge Function failed: ${response.status}');
          throw Exception('Kakao OAuth failed: ${response.data}');
        }
        
        final data = response.data as Map<String, dynamic>;
        
        Logger.info('Edge Function response data: ${data.keys.join(', ')}');
        
        if (!data['success']) {
          throw Exception(data['error'] ?? 'Kakao OAuth failed');
        }
        
        // Edge Function이 needsManualAuth를 반환하면 수동 인증 필요
        if (data['needsManualAuth'] == true) {
          Logger.info('Edge Function requires manual auth, falling back...');
          throw Exception('Manual auth required');
        }
        
        final sessionData = data['session'] as Map<String, dynamic>?;
        Session? currentSession;
        
        if (sessionData != null && sessionData['access_token'] != null) {
          Logger.info('Got session from Edge Function, processing...');
          
          // Set the session using both access and refresh tokens
          final accessToken = sessionData['access_token'] as String;
          final refreshToken = sessionData['refresh_token'] as String?;
          
          if (refreshToken != null) {
            // Use refreshSession if we have a refresh token
            await _supabase.auth.setSession(refreshToken);
            currentSession = _supabase.auth.currentSession;
          } else {
            // Try with access token only
            await _supabase.auth.setSession(accessToken);
            currentSession = _supabase.auth.currentSession;
          }
          
          if (currentSession == null) {
            Logger.warning('Failed to set session from Edge Function, falling back...');
            throw Exception('Failed to set session from Kakao OAuth');
          }
        } else {
          // 세션이 없으면 수동 인증으로 폴백
          Logger.info('No session from Edge Function, falling back to manual auth...');
          throw Exception('No session returned from Kakao OAuth');
        }
        
        Logger.securityCheckpoint('Kakao OAuth: ${currentSession?.user?.id}');
        
        // Return the auth response
        return AuthResponse(
          session: currentSession,
          user: currentSession.user
        );
        
      } catch (edgeFunctionError) {
        Logger.error('Kakao Edge Function failed, falling back to manual user creation', edgeFunctionError);
        
        // Fallback: 직접 사용자 생성 후 OAuth 세션 처리
        try {
          // Create or get existing user by email
          final existingUser = await _findUserByEmail(email);
          
          if (existingUser != null) {
            // 기존 사용자 - 카카오 정보 업데이트
            await _updateUserProfile(
              userId: existingUser.id,
              email: email,
              name: nickname,  // 위에서 계산한 닉네임 사용
              photoUrl: kakaoUser.kakaoAccount?.profile?.profileImageUrl,
              provider: 'kakao'
            );
            
            // Create a session for existing user
            // Pass the Kakao ID to ensure correct password generation
            final sessionResponse = await _createManualSession(existingUser, kakaoId: kakaoUser.id.toString());
            return sessionResponse;
            
          } else {
            // 새 사용자 생성
            // Use consistent password pattern that can be regenerated for existing users
            final password = 'kakao_oauth_${kakaoUser.id}_secure2024';
            final signUpResponse = await _supabase.auth.signUp(
              email: email,
              password: password,
              data: {
                'provider': 'kakao',
                'kakao_id': kakaoUser.id.toString(),
                'name': nickname,  // 위에서 계산한 닉네임 사용
                'profile_image': kakaoUser.kakaoAccount?.profile?.profileImageUrl,
                'email_confirmed_at': DateTime.now().toIso8601String(), // Mark email as confirmed
              },
              emailRedirectTo: 'com.beyond.fortune://auth-callback', // Set redirect URL
            );
            
            if (signUpResponse.user != null) {
              Logger.securityCheckpoint('Kakao new user: ${signUpResponse.user?.id}');
              
              // 프로필 정보 업데이트
              await _updateUserProfile(
                userId: signUpResponse.user!.id,
                email: email,
                name: nickname,  // 위에서 계산한 닉네임 사용
                photoUrl: kakaoUser.kakaoAccount?.profile?.profileImageUrl,
                provider: 'kakao'
              );
              
              // signUp response에 session이 있으면 사용하고, 없으면 OTP로 로그인 요청
              if (signUpResponse.session != null) {
                Logger.info('Kakao user signed up with session successfully');
                return signUpResponse;
              } else {
                // session이 없으면 OTP로 로그인 처리
                Logger.info('No session from signUp, requesting OTP sign-in');
                try {
                  // OTP 요청 - 이메일로 매직 링크 발송
                  await _supabase.auth.signInWithOtp(
                    email: email,
                    shouldCreateUser: false, // 이미 사용자를 생성했으므로 false
                  );
                  
                  Logger.info('OTP sent to Kakao user email (if real email)');
                  // OTP를 보냈지만 Kakao 이메일은 가짜일 수 있으므로
                  // 사용자가 생성되었다는 사실만 반환
                } catch (otpError) {
                  Logger.warning('OTP sign-in failed', otpError);
                }
              }
            }
            
            // 사용자는 생성되었지만 세션이 없는 경우에도 성공으로 처리
            // (Kakao 로그인은 이메일 확인이 불가능하므로)
            if (signUpResponse.user != null) {
              Logger.info('Kakao user created successfully, but session creation pending');
              // 사용자 생성은 성공했으므로 성공 응답 반환
              return AuthResponse(
                session: null,
                user: signUpResponse.user,
              );
            }
            
            return signUpResponse;
          }
        } catch (fallbackError) {
          Logger.error('Kakao fallback authentication failed', fallbackError);
          throw Exception('Kakao authentication failed: $fallbackError');
        }
      }
    } catch (error) {
      Logger.error('Native Kakao Sign-In failed', error);
      rethrow;
    }
  }
  
  // Helper method to find user by email
  Future<User?> _findUserByEmail(String email) async {
    try {
      final response = await _supabase
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
  
  // Helper method to create manual session
  Future<AuthResponse?> _createManualSession(User user, {String? kakaoId}) async {
    // Extract Kakao ID - use provided kakaoId first, then try metadata
    final effectiveKakaoId = kakaoId ?? 
                            user.userMetadata?['kakao_id'] ?? 
                            user.appMetadata?['provider_id'] ??
                            user.id; // Fallback to user ID
    
    try {
      Logger.info('Creating manual session for user: ${user.id}');
      
      // Generate consistent password for existing Kakao users
      // This should match the password used during user creation
      final password = 'kakao_oauth_${effectiveKakaoId}_secure2024';
      
      Logger.info('Attempting to sign in existing Kakao user with email: ${user.email}');
      
      // Sign in with password
      final signInResponse = await _supabase.auth.signInWithPassword(
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
      Logger.error('Failed to create manual session', e);
      // If password sign-in fails, try with a legacy password pattern
      try {
        // Try with the timestamp-based password that might have been used before
        final legacyPassword = 'kakao_oauth_${effectiveKakaoId}_${user.createdAt.replaceAll(RegExp(r'[^0-9]'), '')}';
        
        Logger.info('Trying legacy password pattern for Kakao user');
        final legacySignIn = await _supabase.auth.signInWithPassword(
          email: user.email!,
          password: legacyPassword,
        );
        
        if (legacySignIn.session != null) {
          Logger.info('Successfully signed in with legacy password');
          return legacySignIn;
        }
      } catch (legacyError) {
        Logger.error('Legacy password sign-in also failed', legacyError);
      }
      return null;
    }
  }
  
  // OAuth 카카오 로그인 (웹)
  Future<AuthResponse?> _signInWithKakaoOAuth() async {
    try {
      Logger.info('Using Kakao OAuth sign in');
      
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.kakao,
        redirectTo: kIsWeb 
          ? '${Uri.base.origin}/auth/callback'
          : 'com.beyond.fortune://auth-callback',
        authScreenLaunchMode: LaunchMode.platformDefault);
      
      if (!response) {
        throw Exception('Kakao OAuth sign in failed');
      }
      
      Logger.securityCheckpoint('Kakao OAuth sign in initiated');
      return null; // OAuth flow will handle the callback
    } catch (error) {
      Logger.error('Kakao OAuth Sign-In failed', error);
      rethrow;
    }
  }
  
  // Native Naver platform channel
  static const _naverChannel = MethodChannel('com.beyond.fortune/naver_auth');
  
  // Naver Sign In using native implementation
  Future<AuthResponse?> signInWithNaver() async {
    try {
      Logger.info('Starting Naver Sign-In process (Native)');
      
      // Initialize Naver SDK
      final initResult = await _naverChannel.invokeMethod('initializeNaver');
      Logger.info('Naver SDK initialization: $initResult');
      
      // Perform Naver login
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
      
      // Call our Edge Function to handle OAuth
      final response = await _supabase.functions.invoke(
        'naver-oauth',
        body: {
          'accessToken': accessToken
        }
      );
      
      if (response.status != 200) {
        Logger.error('Naver OAuth Edge Function failed: ${response.status}');
        throw Exception('Naver OAuth failed: ${response.data}');
      }
      
      final data = response.data as Map<String, dynamic>;
      
      if (!data['success']) {
        throw Exception(data['error'] ?? 'Naver OAuth failed');
      }
      
      final sessionUrl = data['session_url'] as String?;
      if (sessionUrl == null) {
        throw Exception('No session URL returned from Naver OAuth');
      }
      
      Logger.info('Got session URL from Edge Function, processing via getSessionFromUrl...');

      // Let Supabase parse and set session directly from the callback URL
      final uri = Uri.parse(sessionUrl);
      final sessionResponse = await _supabase.auth.getSessionFromUrl(uri);
      
      if (sessionResponse.session == null) {
        Logger.error('Failed to set session with tokens');
        throw Exception('Failed to create session from Naver OAuth tokens');
      }
      
      Logger.securityCheckpoint('Naver: ${sessionResponse.session?.user?.id}');
      
      // Return the auth response
      return AuthResponse(
        session: sessionResponse.session,
        user: sessionResponse.session?.user
      );
      
    } catch (error) {
      Logger.error('Naver Sign-In failed', error);
      rethrow;
    }
  }
  
  // 로그아웃
  Future<void> signOut() async {
    try {
      // 현재 provider 확인
      final provider = await getCurrentProvider();
      
      // Google Sign-Out은 Supabase signOut이 자동으로 처리함
      // Supabase OAuth를 사용하므로 별도의 Google Sign-Out 불필요
      
      // Kakao 로그아웃
      try {
        await kakao.UserApi.instance.logout();
      } catch (e) {
        // 카카오 로그아웃 실패 무시
      }
      
      // Naver 로그아웃 (native channel)
      try {
        await _naverChannel.invokeMethod('logoutNaver');
      } catch (e) {
        // 네이버 로그아웃 실패 무시
      }
      
      // Supabase 로그아웃
      await _supabase.auth.signOut();
      
      // 프로필 캐시 클리어
      _profileCache.clearAll();
      
      Logger.securityCheckpoint('User signed out');
    } catch (error) {
      Logger.error('Sign out failed', error);
      rethrow;
    }
  }
  
  // 현재 로그인된 소셜 계정 정보
  Future<String?> getCurrentProvider() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    
    // user.app_metadata에서 provider 정보 확인
    final provider = user.appMetadata['provider'] as String?;
    return provider;
  }
  
  // Google 계정 연결 해제
  Future<void> disconnectGoogle() async {
    // Supabase OAuth를 사용하므로 별도의 Google disconnect 불필요
    // 계정 삭제 시 Supabase가 자동으로 OAuth 연결 해제
    Logger.info('Google disconnect handled by Supabase');
  }
  
  // Kakao 계정 연결 해제
  Future<void> disconnectKakao() async {
    try {
      await kakao.UserApi.instance.unlink();
    } catch (e) {
      Logger.error('Failed to disconnect Kakao', e);
    }
  }
  
  // Naver 계정 연결 해제
  Future<void> disconnectNaver() async {
    try {
      await _naverChannel.invokeMethod('logoutNaver');
    } catch (e) {
      Logger.error('Failed to disconnect Naver', e);
    }
  }
  
  // Link additional social account
  Future<bool> linkSocialAccount(String provider) async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return false;
      
      switch (provider) {
        case 'google':
          final result = await signInWithGoogle();
          return result != null;
        case 'apple':
          final result = await signInWithApple();
          return result != null;
        case 'facebook':
          // Facebook uses OAuth flow
          await signInWithFacebook();
          return true;
        case 'kakao':
          // Kakao uses OAuth flow
          await signInWithKakao();
          return true;
        case 'naver':
          final result = await signInWithNaver();
          return result != null;
        default:
          return false;
      }
    } catch (e) {
      Logger.error('account: $provider', e);
      return false;
    }
  }
  
  // Get all linked providers for current user
  Future<List<String>> getLinkedProviders() async {
    try {
      final currentUser = _supabase.auth.currentUser;
      if (currentUser == null) return [];
      
      final profile = await _supabase
          .from('user_profiles')
          .select('linked_providers')
          .eq('id', currentUser.id)
          .maybeSingle();
      
      if (profile != null && profile['linked_providers'] != null) {
        return List<String>.from(profile['linked_providers']);
      }
      
      return [];
    } catch (e) {
      Logger.error('Failed to get linked providers', e);
      return [];
    }
  }
  
  // Unlink a provider from current account
  Future<void> unlinkProvider(String provider) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }
      
      // Get all user identities
      final identities = user.identities ?? [];
      
      // Check if user has more than one identity
      if (identities.length <= 1) {
        throw Exception('연동된 계정이 하나뿐이라 해제할 수 없습니다');
      }
      
      // Find the identity to unlink
      final identityToUnlink = identities.firstWhere(
        (identity) => identity.provider == provider,
        orElse: () => throw Exception('해당 계정이 연동되어 있지 않습니다'));
      
      // Use Supabase's unlinkIdentity method
      await _supabase.auth.unlinkIdentity(identityToUnlink);
      
      // Update linked providers in user profile
      await _updateLinkedProviders(user.id, provider, false);
      
      Logger.securityCheckpoint('Fortune cached');
    } catch (e) {
      Logger.error('Fortune cached');
      rethrow;
    }
  }
  
  Future<void> _updateLinkedProviders(String userId, String provider, bool isAdding) async {
    try {
      // Get current profile
      final profile = await _supabase
          .from('user_profiles')
          .select('linked_providers')
          .eq('id', userId)
          .maybeSingle();
      
      List<dynamic> linkedProviders = profile?['linked_providers'] ?? [];
      
      if (isAdding) {
        // Add provider if not already in list
        if (!linkedProviders.contains(provider)) {
          linkedProviders.add(provider);
        }
      } else {
        // Remove provider
        linkedProviders.remove(provider);
      }
      
      // Update profile
      await _supabase.from('user_profiles').update({
        'linked_providers': linkedProviders,
        'updated_at': null}).eq('id', userId);
      
    } catch (e) {
      Logger.error('Fortune cached');
      // Non-critical error, don't rethrow
    }
  }
}
