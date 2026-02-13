import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/user_profile.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/supabase_helper.dart';
import '../../utils/date_utils.dart' as legacy_date_utils;
import '../providers/providers.dart';
import '../../data/models/secondary_profile.dart';
import '../../constants/fortune_constants.dart';

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final Ref _ref;
  UserProfile? _primaryProfile;
  UserProfile? _overrideProfile;

  UserProfileNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadProfile();
    // 로그인 상태 변경 시 프로필 재로드
    _ref.listen<AsyncValue<AuthState?>>(authStateProvider, (previous, next) {
      next.whenData((authState) {
        if (authState?.event == AuthChangeEvent.signedIn ||
            authState?.event == AuthChangeEvent.tokenRefreshed) {
          Logger.info(
              '🔄 [UserProfileNotifier] Auth state changed, reloading profile...');
          loadProfile();
        } else if (authState?.event == AuthChangeEvent.signedOut) {
          Logger.info('🔄 [UserProfileNotifier] Signed out, clearing profile');
          _primaryProfile = null;
          _overrideProfile = null;
          _ref.read(storageServiceProvider).clearActiveProfileOverride();
          state = const AsyncValue.data(null);
        }
      });
    });
  }

  Future<void> loadProfile() async {
    try {
      state = const AsyncValue.loading();

      final client = _ref.read(supabaseClientProvider);
      final user = client.auth.currentUser;

      if (user == null) {
        state = const AsyncValue.data(null);
        return;
      }

      // Use helper function to ensure profile exists
      final profileData = await SupabaseHelper.ensureUserProfile(
          userId: user.id,
          email: user.email ?? 'unknown@example.com',
          name: user.userMetadata?['name'] as String? ??
              user.userMetadata?['full_name'],
          profileImageUrl: user.userMetadata?['avatar_url'] as String?);

      if (profileData != null) {
        final profile = UserProfile.fromJson(profileData);
        _primaryProfile = profile;

        // Update local storage as well to keep it in sync
        final storage = _ref.read(storageServiceProvider);
        await storage.saveUserProfile(profile.toJson());

        state = AsyncValue.data(_overrideProfile ?? profile);
      } else {
        _primaryProfile = null;
        state = const AsyncValue.data(null);
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to load user profile', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateProfile(UserProfile updatedProfile) async {
    try {
      // 1. Update in database using SupabaseHelper
      await SupabaseHelper.updateUserProfile(
          userId: updatedProfile.userId, updates: updatedProfile.toJson());

      // 2. Update in local storage
      final storage = _ref.read(storageServiceProvider);
      await storage.saveUserProfile(updatedProfile.toJson());

      // 3. Update local state
      _primaryProfile = updatedProfile;
      if (_overrideProfile == null) {
        state = AsyncValue.data(updatedProfile);
      }
      Logger.info(
          'User profile updated successfully in Supabase, Local Storage, and State');
    } catch (e, stackTrace) {
      Logger.error('Failed to update user profile', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await loadProfile();
  }

  UserProfile? get primaryProfile => _primaryProfile;

  void applySecondaryProfile(SecondaryProfile profile) {
    final primary = _primaryProfile;
    if (primary == null) {
      Logger.warning('[UserProfileNotifier] 기본 프로필이 없어 대리 전환 실패');
      return;
    }

    final birthDate = DateTime.tryParse(profile.birthDate);
    final zodiacSign = legacy_date_utils.FortuneDateUtils.getZodiacSign(
      profile.birthDate,
    );
    final chineseZodiac = legacy_date_utils.FortuneDateUtils.getChineseZodiac(
      profile.birthDate,
    );

    final override = primary.copyWith(
      name: profile.name,
      birthDate: birthDate,
      birthTime: profile.birthTime,
      mbti: profile.mbti,
      bloodType: profile.bloodType,
      gender: _mapGender(profile.gender),
      zodiacSign: zodiacSign,
      chineseZodiac: chineseZodiac,
      isLunarBirthdate: profile.isLunar,
      profileImageUrl: null,
    );

    _overrideProfile = override;
    state = AsyncValue.data(override);
    final storage = _ref.read(storageServiceProvider);
    storage.saveActiveProfileOverride(override.toJson());
    Logger.info('[UserProfileNotifier] 대리 프로필 적용: ${profile.name}');
  }

  void clearOverride() {
    _overrideProfile = null;
    state = AsyncValue.data(_primaryProfile);
    final storage = _ref.read(storageServiceProvider);
    storage.clearActiveProfileOverride();
    Logger.info('[UserProfileNotifier] 대리 프로필 해제');
  }

  Gender _mapGender(String value) {
    switch (value) {
      case 'male':
        return Gender.male;
      case 'female':
        return Gender.female;
      default:
        return Gender.other;
    }
  }
}

// Create the StateNotifierProvider
final userProfileNotifierProvider =
    StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  return UserProfileNotifier(ref);
});

final primaryUserProfileProvider = Provider<UserProfile?>((ref) {
  ref.watch(userProfileNotifierProvider);
  return ref.read(userProfileNotifierProvider.notifier).primaryProfile;
});

// Keep the original provider for backward compatibility but use the notifier
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final profileAsync = ref.watch(userProfileNotifierProvider);

  return profileAsync.when(
    data: (profile) => profile,
    loading: () async => ref.read(userProfileNotifierProvider).value,
    error: (e, st) => throw e,
  );
});
