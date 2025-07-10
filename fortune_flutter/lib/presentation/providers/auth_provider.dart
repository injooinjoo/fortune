import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/supabase_helper.dart';
import '../../data/models/user_profile.dart';

// Supabase client provider
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// Auth state provider
final authStateProvider = StreamProvider<AuthState?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return client.auth.onAuthStateChange;
});

// Current user provider
final userProvider = StreamProvider<User?>((ref) {
  final client = ref.watch(supabaseClientProvider);
  
  // Listen to auth state changes
  ref.listen(authStateProvider, (previous, next) {
    Logger.info('Auth state changed: ${next.value?.session?.user.id}');
  });

  return Stream.value(client.auth.currentUser);
});

// User profile provider with auto-creation using helper
final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final client = ref.watch(supabaseClientProvider);
  final user = client.auth.currentUser;
  
  if (user == null) return null;
  
  try {
    // Use helper function to ensure profile exists
    final profileData = await SupabaseHelper.ensureUserProfile(
      userId: user.id,
      email: user.email ?? '',
      name: user.userMetadata?['name'] ?? user.userMetadata?['full_name'],
      profileImageUrl: user.userMetadata?['avatar_url'],
    );
    
    if (profileData != null) {
      return UserProfile.fromJson(profileData);
    }
    
    return null;
  } catch (e) {
    Logger.error('Failed to fetch or create user profile', e);
    return null;
  }
});

// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return AuthService(client);
});

// Auth service class
class AuthService {
  final SupabaseClient _client;
  
  AuthService(this._client);
  
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
        email: user.email ?? '',
        name: user.userMetadata?['name'] ?? user.userMetadata?['full_name'],
        profileImageUrl: user.userMetadata?['avatar_url'],
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
}