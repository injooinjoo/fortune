import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../services/storage_service.dart';

/// Helper class for profile validation and completion checks
class ProfileValidation {
  /// Check if user needs to complete onboarding
  static Future<bool> needsOnboarding() async {
    try {
      final storageService = StorageService();

      // Check if user is in guest mode
      final isGuest = await storageService.isGuestMode();
      if (isGuest) {
        debugPrint('ProfileValidation: Guest mode - no onboarding needed');
        return false;
      }

      // First check local storage
      var profile = await storageService.getUserProfile();

      // If no local profile, check database for authenticated users
      if (profile == null) {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          debugPrint('user: ${user.id}');

          try {
            final dbProfile = await Supabase.instance.client
                .from('user_profiles')
                .select()
                .eq('id', user.id)
                .maybeSingle();

            if (dbProfile != null) {
              debugPrint('ProfileValidation: Found profile in database');
              // Save to local storage for future use
              await storageService.saveUserProfile(dbProfile);
              profile = dbProfile;
            } else {
              debugPrint('ProfileValidation: No profile in database either');
            }
          } catch (e) {
            debugPrint('Profile validation error: $e');
          }
        }
      }

      // No profile at all - needs onboarding
      if (profile == null) {
        debugPrint('ProfileValidation: No profile found - needs onboarding');
        return true;
      }

      // Check if onboarding is explicitly marked as incomplete
      final onboardingCompleted = profile['onboarding_completed'] ?? false;
      if (!onboardingCompleted) {
        debugPrint(
            'ProfileValidation: Onboarding not completed - needs onboarding');
        return true;
      }

      // Check required fields
      final hasRequiredFields = _hasRequiredFields(profile);
      if (!hasRequiredFields) {
        debugPrint(
            'ProfileValidation: Missing required fields - needs onboarding');
        return true;
      }

      debugPrint('ProfileValidation: Profile complete - no onboarding needed');
      return false;
    } catch (e) {
      debugPrint('Error during profile validation: $e');
      // If we can't check, assume they need onboarding
      return true;
    }
  }

  /// Check if profile has all required fields
  static bool _hasRequiredFields(Map<String, dynamic> profile) {
    // Required fields for basic profile completion
    final requiredFields = ['name', 'birth_date', 'gender'];

    for (final field in requiredFields) {
      if (profile[field] == null || profile[field].toString().isEmpty) {
        debugPrint('Profile validation failed: missing field $field');
        return false;
      }
    }

    return true;
  }

  /// Calculate profile completion percentage
  static double calculateCompletionPercentage(Map<String, dynamic>? profile) {
    if (profile == null) return 0.0;

    // Define all profile fields with their weights
    final fields = {
      'name': 20.0, // Required
      'birth_date': 20.0, // Required
      'gender': 20.0, // Required
      'birth_time': 10.0, // Optional
      'mbti': 15.0, // Optional
      'email': 15.0, // Usually from auth
    };

    double completedWeight = 0.0;

    for (final entry in fields.entries) {
      final value = profile[entry.key];
      if (value != null && value.toString().isNotEmpty) {
        completedWeight += entry.value;
      }
    }

    return completedWeight / 100.0;
  }

  /// Get list of missing fields
  static List<String> getMissingFields(Map<String, dynamic>? profile) {
    if (profile == null) {
      return ['name', 'birth_date', 'gender', 'birth_time', 'mbti'];
    }

    final missingFields = <String>[];
    final allFields = {
      'name': '이름',
      'birth_date': '생년월일',
      'gender': '성별',
      'birth_time': '태어난 시간',
      'mbti': 'MBTI'
    };

    for (final entry in allFields.entries) {
      final value = profile[entry.key];
      if (value == null || value.toString().isEmpty) {
        missingFields.add(entry.value);
      }
    }

    return missingFields;
  }

  /// Check if profile has essential fields for fortune telling
  static bool hasEssentialFields(Map<String, dynamic>? profile) {
    if (profile == null) return false;

    // Essential fields for fortune telling: name and birth_date
    final name = profile['name'];
    final birthDate = profile['birth_date'];

    return name != null &&
        name.toString().isNotEmpty &&
        birthDate != null &&
        birthDate.toString().isNotEmpty;
  }

  /// Check if user signed up through social login
  static bool isSocialLoginUser(Map<String, dynamic>? profile) {
    if (profile == null) return false;

    // Check if user has social provider data
    final email = profile['email']?.toString() ?? '';
    final id = profile['id']?.toString() ?? '';

    // Common patterns for social login users
    return email.contains('kakao.com') ||
        email.contains('naver.com') ||
        email.contains('google') ||
        email.contains('apple') ||
        id.startsWith('kakao_') ||
        id.startsWith('naver_') ||
        id.startsWith('google_') ||
        id.startsWith('apple_');
  }

  /// Get list of missing essential fields only
  static List<String> getMissingEssentialFields(Map<String, dynamic>? profile) {
    if (profile == null) {
      return ['이름', '생년월일'];
    }

    final missingFields = <String>[];

    final name = profile['name'];
    if (name == null || name.toString().isEmpty) {
      missingFields.add('이름');
    }

    final birthDate = profile['birth_date'];
    if (birthDate == null || birthDate.toString().isEmpty) {
      missingFields.add('생년월일');
    }

    return missingFields;
  }
}
