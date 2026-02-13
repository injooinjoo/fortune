import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/models/user_profile.dart';

// Provider for TestAccountService
final testAccountServiceProvider = Provider<TestAccountService>((ref) {
  return TestAccountService();
});

class TestAccountService {
  final _supabase = Supabase.instance.client;

  // Toggle premium status for test accounts
  Future<bool> togglePremium(String userId, bool enabled) async {
    try {
      final response =
          await _supabase.rpc('toggle_test_account_premium', params: {
        'user_id':
            userId, // This is the auth user ID which is same as profile ID
        'enabled': null
      });

      if (response == null) {
        throw Exception('Failed to toggle premium status');
      }

      return response['success'] == true;
    } catch (e) {
      throw Exception('Fortune cached');
    }
  }

  // Check if user is a test account
  Future<bool> isTestAccount(String email) async {
    try {
      final response =
          await _supabase.rpc('is_test_account', params: {'user_email': email});

      return response == true;
    } catch (e) {
      return false;
    }
  }

  // Get test account features
  Map<String, dynamic> getTestAccountFeatures(UserProfile profile) {
    if (!profile.isTestAccount || profile.testAccountFeatures == null) {
      return {};
    }
    return profile.testAccountFeatures!;
  }

  // Check if test account has unlimited tokens
  bool hasUnlimitedTokens(UserProfile profile) {
    return profile.hasUnlimitedTokens;
  }

  // Check if test account has premium enabled
  bool isPremiumEnabled(UserProfile profile) {
    return profile.isPremiumActive;
  }

  // Check if test account can toggle premium
  bool canTogglePremium(UserProfile profile) {
    if (!profile.isTestAccount || profile.testAccountFeatures == null) {
      return false;
    }
    return profile.testAccountFeatures!['can_toggle_premium'] == true;
  }
}
