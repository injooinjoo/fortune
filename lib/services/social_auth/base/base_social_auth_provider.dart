import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/utils/logger.dart';
import '../../../core/cache/profile_cache.dart';

/// Base interface for all social authentication providers
abstract class BaseSocialAuthProvider {
  final SupabaseClient supabase;
  final ProfileCache profileCache;

  BaseSocialAuthProvider(this.supabase, this.profileCache);

  /// Main sign-in method that each provider must implement
  Future<AuthResponse?> signIn();

  /// Provider name (e.g., 'google', 'apple', 'kakao')
  String get providerName;

  /// Optional: Handle provider-specific disconnect logic
  Future<void> disconnect() async {
    Logger.info('$providerName disconnect handled by Supabase');
  }
}

/// Common utilities shared across all providers
class AuthProviderUtils {
  /// Update user profile after successful authentication
  static Future<void> updateUserProfile({
    required SupabaseClient supabase,
    required ProfileCache profileCache,
    required String userId,
    String? email,
    String? name,
    String? photoUrl,
    required String provider,
  }) async {
    try {
      final now = DateTime.now().toIso8601String();

      final profileData = {
        'id': userId,
        'email': email,
        'updated_at': null,
      };

      if (name != null && name.isNotEmpty) profileData['name'] = name;
      if (photoUrl != null && photoUrl.isNotEmpty) {
        profileData['profile_image_url'] = photoUrl;
      }

      // Check cache first
      var existingProfile = profileCache.get(userId);

      if (existingProfile == null) {
        existingProfile = await supabase
            .from('user_profiles')
            .select('linked_providers, primary_provider, name, profile_image_url')
            .eq('id', userId)
            .maybeSingle();

        if (existingProfile != null) {
          profileCache.set(userId, existingProfile);
        }
      }

      if (existingProfile == null) {
        // Create new profile
        await _createNewProfile(supabase, profileData, provider, now, name);
      } else {
        // Update existing profile
        await _updateExistingProfile(
          supabase,
          profileCache,
          userId,
          existingProfile,
          name,
          photoUrl,
          provider,
        );
      }
    } catch (error) {
      Logger.warning('[AuthProviderUtils] 사용자 프로필 업데이트 실패 (선택적 기능, 로그인은 계속): $error');
    }
  }

  static Future<void> _createNewProfile(
    SupabaseClient supabase,
    Map<String, dynamic> profileData,
    String provider,
    String now,
    String? name,
  ) async {
    Logger.info('Creating new profile for provider: $provider');

    try {
      profileData.addAll({
        'primary_provider': provider,
        'linked_providers': [provider],
        'created_at': null,
      });

      await supabase.from('user_profiles').insert(profileData);
      Logger.info('Profile created successfully');
    } catch (insertError) {
      Logger.warning('[AuthProviderUtils] 소셜 인증으로 프로필 생성 실패 (선택적 기능, 기본 프로필로 계속): $insertError');

      if (_isSchemaError(insertError)) {
        await _createMinimalProfile(supabase, profileData, now, name);
      } else {
        rethrow;
      }
    }
  }

  static bool _isSchemaError(dynamic error) {
    final errorStr = error.toString();
    return errorStr.contains('linked_providers') ||
           errorStr.contains('primary_provider') ||
           errorStr.contains('profile_image_url') ||
           errorStr.contains('avatar_url');
  }

  static Future<void> _createMinimalProfile(
    SupabaseClient supabase,
    Map<String, dynamic> profileData,
    String now,
    String? name,
  ) async {
    Logger.warning('Schema mismatch detected, creating minimal profile');

    final minimalProfile = {
      'id': profileData['id'],
      'email': profileData['email'],
      'name': name ?? '사용자',
      'created_at': now,
      'updated_at': null,
    };

    try {
      await supabase.from('user_profiles').insert(minimalProfile);
      Logger.info('Minimal profile created successfully');
    } catch (fallbackError) {
      Logger.warning('[AuthProviderUtils] 최소 프로필 생성 실패 (선택적 기능, 로그인은 계속): $fallbackError');
    }
  }

  static Future<void> _updateExistingProfile(
    SupabaseClient supabase,
    ProfileCache profileCache,
    String userId,
    Map<String, dynamic> existingProfile,
    String? name,
    String? photoUrl,
    String provider,
  ) async {
    final updates = <String, dynamic>{'updated_at': null};

    // Update name if needed
    if (name != null && name.isNotEmpty) {
      final currentName = existingProfile['name'] as String?;
      if (currentName == null || currentName == '사용자' || currentName.startsWith('kakao_')) {
        Logger.info('Updating name from "$currentName" to "$name"');
        updates['name'] = name;
      }
    }

    // Update profile image
    if (photoUrl != null) {
      final shouldUpdate = provider == 'google' || existingProfile['profile_image_url'] == null;
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

    if (existingProfile['primary_provider'] == null) {
      updates['primary_provider'] = provider;
    }

    if (updates.length > 1) {
      await supabase
          .from('user_profiles')
          .update(updates)
          .eq('id', userId);

      profileCache.updateFields(userId, updates);
    }
  }
}
