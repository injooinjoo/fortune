import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/user_profile.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/request_audit_tracker.dart';
import '../../core/utils/supabase_helper.dart';
import '../../utils/date_utils.dart' as legacy_date_utils;
import '../providers/providers.dart';
import '../../data/models/secondary_profile.dart';
import '../../constants/fortune_constants.dart';

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final Ref _ref;
  UserProfile? _primaryProfile;
  UserProfile? _overrideProfile;
  Future<UserProfile?>? _loadProfileFuture;
  String? _loadedUserId;

  UserProfileNotifier(this._ref) : super(const AsyncValue.loading()) {
    ensureLoaded(trigger: 'bootstrap');
    _ref.listen<AsyncValue<AuthState?>>(authStateProvider, (previous, next) {
      next.whenData((authState) {
        if (authState == null) return;

        if (authState.event == AuthChangeEvent.signedIn ||
            authState.event == AuthChangeEvent.initialSession) {
          Logger.info(
              '🔄 [UserProfileNotifier] Auth state changed, reloading profile...');
          ensureLoaded(
            force: _loadedUserId != authState.session?.user.id,
            trigger: 'auth.${authState.event.name}',
          );
        } else if (authState.event == AuthChangeEvent.signedOut) {
          Logger.info('🔄 [UserProfileNotifier] Signed out, clearing profile');
          _primaryProfile = null;
          _overrideProfile = null;
          _loadedUserId = null;
          _loadProfileFuture = null;
          _ref.read(storageServiceProvider).clearActiveProfileOverride();
          state = const AsyncValue.data(null);
        }
      });
    });
  }

  Future<UserProfile?> ensureLoaded({
    bool force = false,
    String trigger = 'manual',
  }) async {
    SupabaseClient client;
    try {
      client = _ref.read(supabaseClientProvider);
    } catch (_) {
      state = const AsyncValue.data(null);
      return null;
    }

    final user = client.auth.currentUser;
    if (user == null) {
      _primaryProfile = null;
      _overrideProfile = null;
      _loadedUserId = null;
      state = const AsyncValue.data(null);
      return null;
    }

    if (!force &&
        _loadProfileFuture == null &&
        _primaryProfile != null &&
        _loadedUserId == user.id &&
        state.hasValue) {
      return _overrideProfile ?? _primaryProfile;
    }

    if (_loadProfileFuture != null) {
      return _loadProfileFuture!;
    }

    final future = _performLoadProfile(
      user: user,
      trigger: trigger,
    );
    _loadProfileFuture = future;

    try {
      return await future;
    } finally {
      if (identical(_loadProfileFuture, future)) {
        _loadProfileFuture = null;
      }
    }
  }

  Future<void> loadProfile({
    bool force = true,
    String trigger = 'manual',
  }) async {
    await ensureLoaded(force: force, trigger: trigger);
  }

  Future<UserProfile?> _performLoadProfile({
    required User user,
    required String trigger,
  }) async {
    try {
      RequestAuditTracker.record(
        key: 'profile.load',
        trigger: trigger,
        source: 'UserProfileNotifier',
      );
      state = const AsyncValue.loading();

      final profileData = await SupabaseHelper.ensureUserProfile(
          userId: user.id,
          email: user.email ?? 'unknown@example.com',
          name: user.userMetadata?['name'] as String? ??
              user.userMetadata?['full_name'],
          profileImageUrl: user.userMetadata?['avatar_url'] as String?);

      if (profileData != null) {
        final profile = UserProfile.fromJson(profileData);
        _primaryProfile = profile;
        _loadedUserId = user.id;

        final storage = _ref.read(storageServiceProvider);
        await storage.saveUserProfile(profile.toJson());

        final resolvedProfile = _overrideProfile ?? profile;
        state = AsyncValue.data(resolvedProfile);
        return resolvedProfile;
      }

      _primaryProfile = null;
      _loadedUserId = user.id;
      state = const AsyncValue.data(null);
      return null;
    } catch (e, stackTrace) {
      Logger.error('Failed to load user profile', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
      rethrow;
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
    await ensureLoaded(force: true, trigger: 'refresh');
  }

  void applyProfile(UserProfile profile) {
    _primaryProfile = profile;
    if (_overrideProfile == null) {
      state = AsyncValue.data(profile);
    }
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
  if (profileAsync.hasValue) {
    return profileAsync.valueOrNull;
  }

  if (profileAsync.hasError) {
    throw profileAsync.error!;
  }

  return ref.read(userProfileNotifierProvider.notifier).ensureLoaded(
        trigger: 'userProfileProvider.future',
      );
});
