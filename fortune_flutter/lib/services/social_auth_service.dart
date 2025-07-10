import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
    } else if (Platform.isIOS) {
      // iOS는 Info.plist에서 설정하므로 여기서는 필요 없음
      clientId = null;
    } else if (Platform.isAndroid) {
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
    if (!Platform.isIOS && !Platform.isMacOS) {
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
          .eq('user_id', userId)
          .maybeSingle();
      
      if (existingProfile == null) {
        // 새 프로필 생성
        await _supabase.from('user_profiles').insert({
          'user_id': userId,
          'email': email,
          'name': name,
          'profile_image_url': photoUrl,
          'auth_provider': provider,
          'created_at': DateTime.now().toIso8601String(),
          'updated_at': DateTime.now().toIso8601String(),
        });
      } else {
        // 기존 프로필 업데이트
        final updates = <String, dynamic>{
          'updated_at': DateTime.now().toIso8601String(),
        };
        
        if (name != null && existingProfile['name'] == null) {
          updates['name'] = name;
        }
        
        if (photoUrl != null && existingProfile['profile_image_url'] == null) {
          updates['profile_image_url'] = photoUrl;
        }
        
        if (updates.length > 1) {
          await _supabase
              .from('user_profiles')
              .update(updates)
              .eq('user_id', userId);
        }
      }
    } catch (error) {
      Logger.error('Failed to update user profile', error);
      // 프로필 업데이트 실패는 로그인을 막지 않음
    }
  }
  
  // 로그아웃
  Future<void> signOut() async {
    try {
      // Google Sign-In 로그아웃
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
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
}