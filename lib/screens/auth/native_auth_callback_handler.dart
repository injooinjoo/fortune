import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/utils/profile_validation.dart';
import '../../core/utils/logger.dart';

/// Lightweight callback handler for native auth flows (Google Sign-In SDK, etc)
/// This doesn't need complex session recovery since the SDK handles auth directly
class NativeAuthCallbackHandler {
  static Future<void> handleAuthSuccess(BuildContext context, User user) async {
    try {
      Logger.info('user: ${user.id}');
      
      // Check if user needs onboarding
      final needsOnboarding = await ProfileValidation.needsOnboarding();
      
      if (needsOnboarding && context.mounted) {
        Logger.info('Redirecting to onboarding');
        context.go('/onboarding');
      } else if (context.mounted) {
        Logger.info('Redirecting to home');
        context.go('/home');
      }
    } catch (e) {
      Logger.error('Error in native auth callback', e);
      if (context.mounted) {
        context.go('/');
      }
    }
  }
  
  static void handleAuthError(BuildContext context, String error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('실패: $error'),
          backgroundColor: context.colors.error,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}