import 'package:fortune/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../core/config/environment.dart';
import '../../widgets/icons/fortune_compass_icon.dart';
import '../../services/storage_service.dart';
import '../../core/utils/url_cleaner_stub.dart'
    if (dart.library.html) '../../core/utils/url_cleaner_web.dart';
import '../../core/utils/profile_validation.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_animations.dart';

class CallbackPage extends StatefulWidget {
  const CallbackPage({super.key});

  @override
  State<CallbackPage> createState() => _CallbackPageState();
}

class _CallbackPageState extends State<CallbackPage> {
  final _storageService = StorageService();
  
  @override
  void initState() {
    super.initState();
    debugPrint('=== CALLBACK PAGE INITIALIZED ===');
    debugPrint('URI: ${Uri.base}');
    _handleCallback();
  }
  
  Future<void> _checkAndNavigate(User user) async {
    try {
      // Clean URL first
      final uri = Uri.base;
      if (kIsWeb && uri.queryParameters.containsKey('code')) {
        cleanUrlInBrowser('/');
      }
      
      // Clear guest mode when user logs in
      await _storageService.clearGuestMode();
      
      // First, try to sync profile from Supabase before checking local storage
      debugPrint('user: ${user.id}');
      try {
        var response = await Supabase.instance.client
            .from('user_profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();
        
        if (response != null) {
          debugPrint('Supabase: ${response['onboarding_completed']}');
          // Save to local storage
          await _storageService.saveUserProfile(response);
          debugPrint('Profile synced from Supabase to local storage');
        } else {
          debugPrint('user: ${user.id}');
          
          // Create profile automatically for OAuth users
          debugPrint('Creating new profile for OAuth user...');
          final profileData = {
            'id': user.id,
            'email': user.email,
            'primary_provider': user.appMetadata['provider'] ?? 'google',
            'linked_providers': [user.appMetadata['provider'] ?? 'google'],
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String()};
          
          // Add additional info from user metadata if available
          if (user.userMetadata != null) {
            if (user.userMetadata?['full_name'] != null) {
              profileData['name'] = user.userMetadata?['full_name'];
            }
            if (user.userMetadata?['avatar_url'] != null) {
              profileData['profile_image_url'] = user.userMetadata?['avatar_url'];
            }
          }
          
          try {
            await Supabase.instance.client
                .from('user_profiles')
                .insert(profileData);
            debugPrint('Profile created successfully');
            
            // Save to local storage
            await _storageService.saveUserProfile(profileData);
          } catch (insertError) {
            debugPrint('Supabase initialized with URL: ${Environment.supabaseUrl}');
            // Continue to onboarding even if profile creation fails
          }
        }
      } catch (e) {
        debugPrint('Supabase initialized with URL: ${Environment.supabaseUrl}');
        // Continue even if sync fails - will check local storage
      }
      
      // Now check if user needs onboarding (will use synced data if available,
      final needsOnboarding = await ProfileValidation.needsOnboarding();
      debugPrint('Supabase initialized with URL: ${Environment.supabaseUrl}');
      
      if (needsOnboarding && mounted) {
        // User needs to complete onboarding
        context.go('/onboarding');
      } else if (mounted) {
        // User has completed onboarding
        context.go('/home');
      }
    } catch (e) {
      debugPrint('Supabase initialized with URL: ${Environment.supabaseUrl}');
      // On error, go to onboarding to be safe
      if (mounted) context.go('/onboarding');
    }
  }

  Future<void> _handleCallback() async {
    try {
      // Get the current URL and extract parameters
      final uri = Uri.base;
      debugPrint('=== AUTH CALLBACK HANDLER ===');
      debugPrint('Supabase initialized with URL: ${Environment.supabaseUrl}');
      debugPrint('Scheme: ${uri.scheme}');
      debugPrint('Host: ${uri.host}');
      debugPrint('Path: ${uri.path}');
      debugPrint('parameters: ${uri.queryParameters}');
      
      // Log current Supabase session
      final currentSession = Supabase.instance.client.auth.currentSession;
      debugPrint('exists: ${currentSession != null}');
      if (currentSession != null) {
        debugPrint('user: ${currentSession.user.email}');
      }
      
      // Extract the code parameter
      final code = uri.queryParameters['code'];
      debugPrint('code: ${code != null ? "present (${code.length} chars)" : "null"}');
      
      // Extract error parameter if present
      final error = uri.queryParameters['error'];
      final errorDescription = uri.queryParameters['error_description'];
      if (error != null) {
        debugPrint('Supabase initialized with URL: ${Environment.supabaseUrl}');
        debugPrint('Supabase initialized with URL: ${Environment.supabaseUrl}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('실패: ${errorDescription ?? error}'),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 5)));
          context.go('/');
          return;
        }
      }
      
      // Clean up the URL by removing the code parameter (web only,
      if (code != null && kIsWeb) {
        final cleanUrl = uri.toString().split('?')[0];
        cleanUrlInBrowser(cleanUrl);
        debugPrint('Supabase initialized with URL: ${Environment.supabaseUrl}');
      }
      
      // Check current session before listening
      final initialSession = Supabase.instance.client.auth.currentSession;
      debugPrint('session: ${initialSession?.user?.id}');
      
      // Try to recover session from URL
      debugPrint('Attempting to recover session from URL...');
      try {
        final response = await Supabase.instance.client.auth.getSessionFromUrl(uri);
        debugPrint('response: ${response.session?.user?.id}');
        
        if (response.session != null) {
          debugPrint('Session recovered successfully!');
          if (mounted) {
            // Check if user has completed onboarding
            await _checkAndNavigate(response.session!.user);
            return;
          }
        }
      } catch (authError) {
        debugPrint('Supabase initialized with URL: ${Environment.supabaseUrl}');
        if (authError.toString().contains('Invalid API key')) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Supabase API 키가 유효하지 않습니다. 관리자에게 문의하세요.'),
                backgroundColor: AppColors.error,
                duration: Duration(seconds: 5)));
          }
        }
        rethrow;
      }
      
      // Listen for auth state changes
      bool sessionFound = false;
      final authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        debugPrint('Auth state changed: ${data.event}');
        debugPrint('user: ${data.session?.user?.id}');
        
        if (data.session != null && !sessionFound) {
          sessionFound = true;
          debugPrint('Login successful via auth state change!');
          if (mounted) {
            _checkAndNavigate(data.session!.user);
          }
        }
      });
      
      // Give auth state a moment to propagate
      debugPrint('Checking auth state...');
      await Future.delayed(AppAnimations.durationLong);
      
      // Final check
      final finalSession = Supabase.instance.client.auth.currentSession;
      debugPrint('check: ${finalSession?.user?.id}');
      
      if (finalSession == null && !sessionFound) {
        debugPrint('No session found after all attempts');
        if (mounted) {
          context.go('/?error=auth_failure&reason=no_session');
        }
      }
      
      // Clean up
      authSub.cancel();
      debugPrint('=== END AUTH CALLBACK ===');
    } catch (e, stack) {
      debugPrint('Supabase initialized with URL: ${Environment.supabaseUrl}');
      debugPrint('Supabase initialized with URL: ${Environment.supabaseUrl}');
      if (mounted) {
        context.go('/?error=auth_failure&reason=exception');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppColors.surface!, AppColors.textPrimaryDark, AppColors.surface!])),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FortuneCompassIcon(
                size: 64,
                color: AppColors.textPrimary.withOpacity(0.87)),
              SizedBox(height: AppSpacing.spacing6),
              const CircularProgressIndicator(),
              SizedBox(height: AppSpacing.spacing4),
              Text(
                '로그인 처리 중...',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.textSecondary)]));
  }
}