import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/supabase_helper.dart';
import '../../data/models/user_profile.dart';
import '../../services/user_statistics_service.dart';
import '../../services/storage_service.dart';

// Supabase client provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Auth state provider
final authStateProvider = StreamProvider<AuthState?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

// Auth token provider
final authTokenProvider = FutureProvider<String?>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final session = client.auth.currentSession;
  return session?.accessToken;
});

// Current user provider
final userProvider = StreamProvider<User?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  
  Logger.info('🔍 [userProvider] Creating user provider stream');
  Logger.info('🔍 [userProvider] Current user: ${client.auth.currentUser?.id}');
  Logger.info('🔍 [userProvider] User email: ${client.auth.currentUser?.email}');
  
  // Listen to auth state changes
  ref.listen(authStateProvider, (previous, next) {
    Logger.info('🔍 [userProvider] Auth state changed');
    Logger.info('🔍 [userProvider] Previous: ${previous?.value?.session?.user.id}');
    Logger.info('🔍 [userProvider] Next: ${next.value?.session?.user.id}');
    Logger.info('🔍 [userProvider] Session: ${next.value?.session != null}');
    Logger.info('🔍 [userProvider] Event type: ${next.value?.event}');
  });

  final user = client.auth.currentUser;
  if (user == null) {
    Logger.info('❌ [userProvider] No current user found');
  } else {
    Logger.info('✅ [userProvider] User found: ${user.id}');
  }
  
  return Stream.value(user);
});

// User profile provider with auto-creation using helper
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  Logger.info('🔍 [userProfileProvider] Creating user profile provider');
  
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  
  Logger.info('🔍 [userProfileProvider] Current user: ${user?.id}');
  Logger.info('🔍 [userProfileProvider] User email: ${user?.email}');
  
  if (user == null) {
    Logger.info('❌ [userProfileProvider] No user found, returning null');
    return null;
  }
  
  try {
    Logger.info('🔍 [userProfileProvider] Ensuring user profile exists...');
    // Use helper function to ensure profile exists
    final profileData = await SupabaseHelper.ensureUserProfile(
      userId: user.id,
      email: user.email ?? 'unknown@example.com',
      name: user.userMetadata?['name'] as String? ?? 
            user.userMetadata?['full_name'] as String?,
      profileImageUrl: user.userMetadata?['avatar_url'] as String?,
    );
    
    Logger.info('🔍 [userProfileProvider] Profile data returned: ${profileData != null}');
    if (profileData != null) {
      Logger.info('🔍 [userProfileProvider] Profile data: $profileData');
      final profile = UserProfile.fromJson(profileData);
      Logger.info('✅ [userProfileProvider] Profile created successfully');
      return profile;
    }
    
    Logger.info('❌ [userProfileProvider] Profile data is null');
    return null;
  } catch (e, stackTrace) {
    Logger.error('❌ [userProfileProvider] Failed to fetch or create user profile', e);
    Logger.error('❌ [userProfileProvider] Stack trace: $stackTrace');
    return null;
  }
});

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  final storageService = StorageService();
  final statisticsService = UserStatisticsService(client, storageService);
  return AuthService(client, statisticsService);
});

// Auth service class
class AuthService {
  final SupabaseClient _client;
  final UserStatisticsService _statisticsService;
  
  AuthService(this._client, this._statisticsService);
  
  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;
  
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: metadata,
      );
      
      if (response.user != null) {
        Logger.securityCheckpoint('User signed up: ${response.user!.id}');
      }
      
      return response;
    } catch (e) {
      Logger.error('Sign up failed', e);
      rethrow;
    }
  }
  
  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      if (response.user != null) {
        Logger.securityCheckpoint('User signed in: ${response.user!.id}');
        
        // Update consecutive days on sign in
        try {
          await _statisticsService.updateConsecutiveDays(response.user!.id);
        } catch (e) {
          Logger.error('Failed to update consecutive days', e);
          // Don't throw - this is not critical for sign in
        }
      }
      
      return response;
    } catch (e) {
      Logger.error('Sign in failed', e);
      rethrow;
    }
  }
  
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      Logger.securityCheckpoint('User signed out');
    } catch (e) {
      Logger.error('Sign out failed', e);
      rethrow;
    }
  }
  
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
      Logger.info('Password reset email sent to $email');
    } catch (e) {
      Logger.error('Password reset failed', e);
      rethrow;
    }
  }
  
  Future<UserResponse> updateUser({
    String? email,
    String? password,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await _client.auth.updateUser(
        UserAttributes(
          email: email,
          password: password,
          data: metadata,
        ),
      );
      
      Logger.info('User updated');
      return response;
    } catch (e) {
      Logger.error('User update failed', e);
      rethrow;
    }
  }
  
  Future<UserProfile?> ensureUserProfile() async {
    final user = currentUser;
    if (user == null) return null;
    
    try {
      // Use helper function to ensure profile exists
      final profileData = await SupabaseHelper.ensureUserProfile(
        userId: user.id,
        email: user.email ?? 'unknown@example.com',
        name: user.userMetadata?['name'] as String? ?? 
              user.userMetadata?['full_name'] as String?,
        profileImageUrl: user.userMetadata?['avatar_url'] as String?,
      );
      
      if (profileData != null) {
        return UserProfile.fromJson(profileData);
      }
      
      return null;
    } catch (e) {
      Logger.error('Failed to ensure user profile', e);
      return null;
    }
  }

  Future<bool> hasUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) return false;

      final response = await _client
          .from('user_profiles')
          .select('onboarding_completed')
          .eq('id', user.id)
          .maybeSingle();

      if (response == null) return false;
      
      return response['onboarding_completed'] == true;
    } catch (e) {
      Logger.error('Error checking user profile', e);
      return false;
    }
  }
}