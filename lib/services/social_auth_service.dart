import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
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

  // Google Sign In - Supabase OAuth 방식 사용
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      print('🟡 [SocialAuthService] signInWithGoogle() started');
      Logger.info('=== GOOGLE OAUTH PROCESS STARTED ===');
      
      // Debug: Log the Supabase URL being used
      final supabaseUrl = Environment.supabaseUrl;
      print('Fortune cached');
      Logger.info('Supabase initialized successfully');
      
      // Verify the URL is correct
      if (supabaseUrl.contains('your-project')) {
        Logger.error('Fortune cached');
        throw Exception('Supabase URL is not properly configured');
      }
      
      // Debug: Log platform and redirect URL
      final isWeb = kIsWeb;
      final isIOS = !kIsWeb && Platform.isIOS;
      final isAndroid = !kIsWeb && Platform.isAndroid;
      print('Fortune cached');
      Logger.info('Supabase initialized successfully');
      
      // Supabase OAuth 리다이렉트 방식 사용
      final redirectUrl = kIsWeb ? null : 'io.supabase.flutter://login-callback/';
      print('URL: ${redirectUrl ?? "null (web default)"}');
      Logger.info('URL: ${redirectUrl ?? "null (web default)"}');
      
      // Debug: Log OAuth provider settings
      print('Provider: ${OAuthProvider.google}');
      Logger.info('Provider: ${OAuthProvider.google}');
      Logger.info('Scopes: email');
      
      // Log before calling signInWithOAuth
      print('🟡 [SocialAuthService] Calling Supabase signInWithOAuth...');
      Logger.info('Calling Supabase signInWithOAuth...');
      
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
        scopes: 'email',
        queryParams: {
          'access_type': 'offline',
          'prompt': 'consent'}
      );
      
      print('🟡 [SocialAuthService] OAuth redirect initiated successfully');
      Logger.info('=== GOOGLE OAUTH REDIRECT INITIATED ===');
      Logger.info('Check browser/webview for Google login page');
      Logger.info('Supabase initialized successfully');
      
      // 리다이렉트 방식이므로 응답을 기다리지 않고 null 반환
      // 실제 인증 완료는 auth callback에서 처리됨
      return null;
    } catch (error, stackTrace) {
      print('Fortune cached');
      Logger.error('=== GOOGLE OAUTH FAILED ===', error, stackTrace);
      Logger.error('type: ${error.runtimeType}');
      Logger.error('Fortune cached');
      rethrow;
    }
  }
  
  // Apple Sign In
  Future<AuthResponse?> signInWithApple() async {
    try {
      Logger.info('Starting Apple Sign-In process');
      
      // Use native Sign in with Apple on iOS/macOS, OAuth on other platforms
      if (!kIsWeb && (Platform.isIOS || Platform.isMacOS)) {
        // Check if native Apple Sign-In is available
        final isAvailable = await SignInWithApple.isAvailable();
        if (!isAvailable) {
          // Fall back to OAuth if native is not available
          return await _signInWithAppleOAuth();
        }
        // Native Sign in with Apple for iOS/macOS
        return await _signInWithAppleNative();
      } else {
        // Use Supabase OAuth for web and Android
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
      Logger.info('Using native Apple Sign-In');
      
      // Apple Sign-In 요청
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName]
      );
      
      final String? idToken = credential.identityToken;
      if (idToken == null) {
        throw Exception('Failed to obtain Apple ID token');
      }
      
      // Supabase에 Apple 토큰으로 로그인
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken);
      
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
    } catch (error) {
      Logger.error('Native Apple Sign-In failed', error);
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
          ? null 
          : 'com.beyond.fortune://auth-callback',
        authScreenLaunchMode: LaunchMode.externalApplication);
      
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
      if (name != null) profileData['name'] = name;
      if (photoUrl != null && provider == 'google') {
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
              'name': name ?? email?.split('@')[0] ?? 'User',
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
        
        // Update name if not set
        if (name != null && existingProfile['name'] == null) {
          updates['name'] = name;
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
          ? null 
          : 'com.beyond.fortune://auth-callback',
        authScreenLaunchMode: LaunchMode.externalApplication);
      
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
      Logger.info('Starting Kakao Sign-In process with Supabase OAuth');
      
      // Supabase OAuth를 사용한 카카오 로그인
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.kakao,
        redirectTo: kIsWeb 
          ? null 
          : 'com.beyond.fortune://auth-callback',
        authScreenLaunchMode: LaunchMode.externalApplication);
      
      if (!response) {
        throw Exception('Kakao OAuth sign in failed');
      }
      
      Logger.securityCheckpoint('Kakao OAuth sign in initiated');
      
      // OAuth 로그인은 웹브라우저나 카카오톡 앱을 통해 진행되며,
      // 완료 후 앱으로 돌아올 때 Supabase가 자동으로 세션을 처리합니다.
      // 따라서 여기서는 null을 반환하고, 
      // 실제 인증 완료는 deep link 콜백에서 처리됩니다.
      return null;
    } catch (error) {
      Logger.error('Kakao Sign-In failed', error);
      rethrow;
    }
  }
  
  // Naver Sign In
  Future<AuthResponse?> signInWithNaver() async {
    try {
      Logger.info('Starting Naver Sign-In process');
      
      // 네이버 로그인
      final loginResult = await FlutterNaverLogin.logIn();
      
      // Check if logged in
      if (loginResult.status.toString() != 'NaverLoginStatus.loggedIn') {
        Logger.info('User cancelled Naver Sign-In');
        return null;
      }
      
      // Get access token
      final tokenResult = await FlutterNaverLogin.getCurrentAccessToken();
      if (tokenResult.accessToken.isEmpty) {
        throw Exception('Failed to get Naver access token');
      }
      
      // Call our Edge Function to handle OAuth
      final response = await _supabase.functions.invoke(
        'naver-oauth',
        body: {
          'accessToken': tokenResult.accessToken});
      
      if (response.status != 200) {
        throw Exception('Naver OAuth failed: ${response.data}');
      }
      
      final data = response.data as Map<String, dynamic>;
      final userData = data['user'] as Map<String, dynamic>;
      
      // Sign in the user with email and generated password
      // Since Naver doesn't provide direct OAuth, we use email/password auth
      final email = userData['email'] as String;
      final userId = userData['id'] as String;
      
      // Try to sign in first
      try {
        final signInResponse = await _supabase.auth.signInWithPassword(
          email: email,
          password: 'naver_$userId', // Use a consistent password pattern
        );
        
        Logger.securityCheckpoint('Naver: ${signInResponse.user?.id}');
        
        // Update user profile with Naver info
        await _updateUserProfile(
          userId: signInResponse.user!.id,
          email: email,
          provider: 'naver');
        
        return signInResponse;
      } catch (signInError) {
        // If sign in fails, the user might not exist with password auth
        // In this case, we need to handle it differently
        Logger.warning('Naver sign in with password failed, user might need different auth method');
        
        // Since we can't create a session directly, we return null
        // and show a message to the user
        throw Exception('Naver 로그인을 완료하려면 이메일 인증이 필요합니다. 이메일을 확인해주세요.');
      }
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
        await UserApi.instance.logout();
      } catch (e) {
        // 카카오 로그아웃 실패 무시
      }
      
      // Naver 로그아웃
      try {
        await FlutterNaverLogin.logOut();
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
      await UserApi.instance.unlink();
    } catch (e) {
      Logger.error('Failed to disconnect Kakao', e);
    }
  }
  
  // Naver 계정 연결 해제
  Future<void> disconnectNaver() async {
    try {
      await FlutterNaverLogin.logOutAndDeleteToken();
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
      if (user == null) throw Exception('User not authenticated')
      
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