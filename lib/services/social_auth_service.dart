import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart' as kakao;
import '../core/utils/logger.dart';
import '../core/cache/profile_cache.dart';
import 'social_auth/providers/google_auth_provider.dart';
import 'social_auth/providers/apple_auth_provider.dart';
import 'social_auth/providers/kakao_auth_provider.dart';
import 'social_auth/providers/naver_auth_provider.dart';
import 'social_auth/providers/facebook_auth_provider.dart';

class SocialAuthService {
  final SupabaseClient _supabase;
  final _profileCache = ProfileCache();

  late final GoogleAuthProvider _googleProvider;
  late final AppleAuthProvider _appleProvider;
  late final KakaoAuthProvider _kakaoProvider;
  late final NaverAuthProvider _naverProvider;
  late final FacebookAuthProvider _facebookProvider;

  SocialAuthService(this._supabase) {
    _googleProvider = GoogleAuthProvider(_supabase, _profileCache);
    _appleProvider = AppleAuthProvider(_supabase, _profileCache);
    _kakaoProvider = KakaoAuthProvider(_supabase, _profileCache);
    _naverProvider = NaverAuthProvider(_supabase, _profileCache);
    _facebookProvider = FacebookAuthProvider(_supabase, _profileCache);
  }

  // Google Sign In
  Future<AuthResponse?> signInWithGoogle({BuildContext? context}) async {
    return await _googleProvider.signIn();
  }

  // Apple Sign In
  Future<AuthResponse?> signInWithApple() async {
    return await _appleProvider.signIn();
  }

  // Kakao Sign In
  Future<AuthResponse?> signInWithKakao() async {
    return await _kakaoProvider.signIn();
  }

  // Naver Sign In
  Future<AuthResponse?> signInWithNaver() async {
    return await _naverProvider.signIn();
  }

  // Facebook Sign In
  Future<AuthResponse?> signInWithFacebook() async {
    return await _facebookProvider.signIn();
  }

  // Sign Out
  Future<void> signOut() async {
    try {
      // Kakao logout
      try {
        await kakao.UserApi.instance.logout();
      } catch (e) {
        // Ignore Kakao logout failure
      }

      // Naver logout
      try {
        await _naverProvider.disconnect();
      } catch (e) {
        // Ignore Naver logout failure
      }

      // Supabase logout
      await _supabase.auth.signOut();

      // Clear profile cache
      _profileCache.clearAll();

      Logger.securityCheckpoint('User signed out');
    } catch (error) {
      Logger.warning(
          '[SocialAuthService] 로그아웃 실패 (선택적 기능, 수동 로그아웃 가능): $error');
      rethrow;
    }
  }

  // Get current provider
  Future<String?> getCurrentProvider() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;

    final provider = user.appMetadata['provider'] as String?;
    return provider;
  }

  // Disconnect provider-specific accounts
  Future<void> disconnectGoogle() async {
    Logger.info('Google disconnect handled by Supabase');
  }

  Future<void> disconnectKakao() async {
    await _kakaoProvider.disconnect();
  }

  Future<void> disconnectNaver() async {
    await _naverProvider.disconnect();
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
          await signInWithFacebook();
          return true;
        case 'kakao':
          await signInWithKakao();
          return true;
        case 'naver':
          final result = await signInWithNaver();
          return result != null;
        default:
          return false;
      }
    } catch (e) {
      Logger.warning(
          '[SocialAuthService] 계정 연결 실패 (선택적 기능, 다른 로그인 방법 사용 권장): $provider - $e');
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
      Logger.warning(
          '[SocialAuthService] 연결된 계정 조회 실패 (선택적 기능, 비어 있는 목록 반환): $e');
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

      final identities = user.identities ?? [];

      if (identities.length <= 1) {
        throw Exception('연동된 계정이 하나뿐이라 해제할 수 없습니다');
      }

      final identityToUnlink = identities.firstWhere(
        (identity) => identity.provider == provider,
        orElse: () => throw Exception('해당 계정이 연동되어 있지 않습니다'),
      );

      await _supabase.auth.unlinkIdentity(identityToUnlink);

      await _updateLinkedProviders(user.id, provider, false);

      Logger.securityCheckpoint('Provider unlinked: $provider');
    } catch (e) {
      Logger.warning(
          '[SocialAuthService] 계정 연결 해제 실패 (선택적 기능, 수동 연결 해제 가능): $e');
      rethrow;
    }
  }

  Future<void> _updateLinkedProviders(
      String userId, String provider, bool isAdding) async {
    try {
      final profile = await _supabase
          .from('user_profiles')
          .select('linked_providers')
          .eq('id', userId)
          .maybeSingle();

      final List<dynamic> linkedProviders = profile?['linked_providers'] ?? [];

      if (isAdding) {
        if (!linkedProviders.contains(provider)) {
          linkedProviders.add(provider);
        }
      } else {
        linkedProviders.remove(provider);
      }

      await _supabase.from('user_profiles').update({
        'linked_providers': linkedProviders,
        'updated_at': null,
      }).eq('id', userId);
    } catch (e) {
      Logger.warning(
          '[SocialAuthService] 연결된 제공자 업데이트 실패 (선택적 기능, 수동 업데이트 가능): $e');
    }
  }
}
