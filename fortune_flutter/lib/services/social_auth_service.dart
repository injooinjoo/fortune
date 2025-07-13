import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter_naver_login/flutter_naver_login.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../core/utils/logger.dart';
import '../core/config/environment.dart';

class SocialAuthService {
  final SupabaseClient _supabase;
  late final GoogleSignIn _googleSignIn;
  
  SocialAuthService(this._supabase) {
    // Platform-specific client ID 설정
    String? clientId;
    if (kIsWeb) {
      clientId = Environment.googleWebClientId;
    } else if (!kIsWeb && Platform.isIOS) {
      // iOS는 Info.plist에서 설정하므로 여기서는 필요 없음
      clientId = null;
    } else if (!kIsWeb && Platform.isAndroid) {
      // Android는 strings.xml에서 설정하므로 여기서는 필요 없음
      clientId = null;
    }
    
    _googleSignIn = GoogleSignIn(
      scopes: ['email', 'profile'],
      clientId: clientId?.isNotEmpty == true ? clientId : null,
    );
  }

  // Google Sign In
  Future<AuthResponse?> signInWithGoogle() async {
    try {
      Logger.info('Starting Google Sign-In process');
      
      // Google Sign-In 프로세스 시작
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        Logger.info('User cancelled Google Sign-In');
        return null;
      }
      
      // Google 인증 정보 가져오기
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final String? accessToken = googleAuth.accessToken;
      final String? idToken = googleAuth.idToken;
      
      if (accessToken == null || idToken == null) {
        throw Exception('Failed to obtain Google auth tokens');
      }
      
      // Supabase에 Google 토큰으로 로그인
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      
      Logger.securityCheckpoint('User signed in with Google: ${response.user?.id}');
      
      // 사용자 프로필 업데이트
      if (response.user != null) {
        await _updateUserProfile(
          userId: response.user!.id,
          email: googleUser.email,
          name: googleUser.displayName,
          photoUrl: googleUser.photoUrl,
          provider: 'google',
        );
      }
      
      return response;
    } catch (error) {
      Logger.error('Google Sign-In failed', error);
      rethrow;
    }
  }
  
  // Apple Sign In (iOS only)
  Future<AuthResponse?> signInWithApple() async {
    if (!kIsWeb && !Platform.isIOS && !Platform.isMacOS) {
      throw UnsupportedError('Apple Sign-In is only available on iOS and macOS');
    }
    
    try {
      Logger.info('Starting Apple Sign-In process');
      
      // Apple Sign-In 가능 여부 확인
      final isAvailable = await SignInWithApple.isAvailable();
      if (!isAvailable) {
        throw Exception('Apple Sign-In is not available on this device');
      }
      
      // Apple Sign-In 요청
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      final String? idToken = credential.identityToken;
      if (idToken == null) {
        throw Exception('Failed to obtain Apple ID token');
      }
      
      // Supabase에 Apple 토큰으로 로그인
      final response = await _supabase.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: idToken,
      );
      
      Logger.securityCheckpoint('User signed in with Apple: ${response.user?.id}');
      
      // 사용자 프로필 업데이트
      if (response.user != null && credential.givenName != null) {
        await _updateUserProfile(
          userId: response.user!.id,
          email: credential.email,
          name: '${credential.givenName ?? ''} ${credential.familyName ?? ''}'.trim(),
          provider: 'apple',
        );
      }
      
      return response;
    } catch (error) {
      Logger.error('Apple Sign-In failed', error);
      rethrow;
    }
  }
  
  // 사용자 프로필 업데이트
  Future<void> _updateUserProfile({
    required String userId,
    String? email,
    String? name,
    String? photoUrl,
    required String provider,
  }) async {
    try {
      // 기존 프로필 확인
      final existingProfile = await _supabase
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      if (existingProfile == null) {
        // 새 프로필 생성
        await _supabase.from('user_profiles').insert({
          'id': userId,
          'email': email,
          'name': name,
          'profile_image_url': photoUrl,
          'primary_provider': provider,
          'linked_providers': [provider],
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      } else {
        // 기존 프로필 업데이트
        final updates = <String, dynamic>{
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        // Update name if not set
        if (name != null && existingProfile['name'] == null) {
          updates['name'] = name;
        }
        
        // Update profile image if not set
        if (photoUrl != null && existingProfile['profile_image_url'] == null) {
          updates['profile_image_url'] = photoUrl;
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
        }
      }
    } catch (error) {
      Logger.error('Failed to update user profile', error);
      // 프로필 업데이트 실패는 로그인을 막지 않음
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
          : 'com.fortune.fortune://auth-callback',
        authScreenLaunchMode: LaunchMode.externalApplication,
      );
      
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
      final NaverLoginResult result = await FlutterNaverLogin.logIn();
      
      if (result.status != NaverLoginStatus.loggedIn) {
        Logger.info('User cancelled Naver Sign-In');
        return null;
      }
      
      // Supabase 커스텀 인증 (백엔드 API 필요)
      // 임시로 이메일/패스워드로 계정 생성 또는 로그인
      final email = result.account.email ?? '${result.account.id}@naver.local';
      final password = 'naver_${result.account.id}_${Environment.naverClientId}';
      
      AuthResponse response;
      try {
        // 먼저 로그인 시도
        response = await _supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );
      } catch (e) {
        // 로그인 실패시 회원가입
        response = await _supabase.auth.signUp(
          email: email,
          password: password,
        );
      }
      
      Logger.securityCheckpoint('User signed in with Naver: ${response.user?.id}');
      
      // 사용자 프로필 업데이트
      if (response.user != null) {
        await _updateUserProfile(
          userId: response.user!.id,
          email: result.account.email,
          name: result.account.name,
          photoUrl: result.account.profileImage,
          provider: 'naver',
        );
      }
      
      return response;
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
      
      // Google Sign-In 로그아웃
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      
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
    if (await _googleSignIn.isSignedIn()) {
      await _googleSignIn.disconnect();
    }
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
      Logger.error('Failed to link social account: $provider', e);
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
}