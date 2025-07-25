import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/user_profile.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/supabase_helper.dart';
import 'auth_provider.dart';

class UserProfileNotifier extends StateNotifier<AsyncValue<UserProfile?>> {
  final Ref _ref;

  UserProfileNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadProfile();
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
              user.userMetadata?['full_name'] as String?,
        profileImageUrl: user.userMetadata?['avatar_url'] as String?,
      );
      
      if (profileData != null) {
        final profile = UserProfile.fromJson(profileData);
        state = AsyncValue.data(profile);
      } else {
        state = const AsyncValue.data(null);
      }
    } catch (e, stackTrace) {
      Logger.error('Failed to load user profile', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> updateProfile(UserProfile updatedProfile) async {
    try {
      // Update in database using SupabaseHelper
      await SupabaseHelper.updateUserProfile(
        userId: updatedProfile.userId,
        updates: updatedProfile.toJson(),
      );
      
      // Update local state
      state = AsyncValue.data(updatedProfile);
      Logger.info('User profile updated successfully');
    } catch (e, stackTrace) {
      Logger.error('Failed to update user profile', e, stackTrace);
      state = AsyncValue.error(e, stackTrace);
    }
  }

  Future<void> refresh() async {
    await loadProfile();
  }
}

// Create the StateNotifierProvider
final userProfileNotifierProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<UserProfile?>>((ref) {
  return UserProfileNotifier(ref);
});

// Keep the original provider for backward compatibility but use the notifier
final userProfileProvider = Provider<AsyncValue<UserProfile?>>((ref) {
  return ref.watch(userProfileNotifierProvider);
});