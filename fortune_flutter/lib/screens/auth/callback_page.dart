import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../widgets/icons/fortune_compass_icon.dart';
import '../../services/storage_service.dart';
import '../../core/utils/url_cleaner_stub.dart'
    if (dart.library.html) '../../core/utils/url_cleaner_web.dart';
import '../../core/utils/profile_validation.dart';

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
    debugPrint('Current URI: ${Uri.base}');
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
      debugPrint('Attempting to sync profile from Supabase for user: ${user.id}');
      try {
        var response = await Supabase.instance.client
            .from('user_profiles')
            .select()
            .eq('id', user.id)
            .maybeSingle();
        
        if (response != null) {
          debugPrint('Found profile in Supabase: ${response['onboarding_completed']}');
          // Save to local storage
          await _storageService.saveUserProfile(response);
          debugPrint('Profile synced from Supabase to local storage');
        } else {
          debugPrint('No profile found in Supabase for user: ${user.id}');
          
          // Create profile automatically for OAuth users
          debugPrint('Creating new profile for OAuth user...');
          final profileData = {
            'id': user.id,
            'email': user.email,
            'primary_provider': user.appMetadata['provider'] ?? 'google',
            'linked_providers': [user.appMetadata['provider'] ?? 'google'],
            'created_at': DateTime.now().toIso8601String(),
            'updated_at': DateTime.now().toIso8601String(),
          };
          
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
            debugPrint('Error creating profile: $insertError');
            // Continue to onboarding even if profile creation fails
          }
        }
      } catch (e) {
        debugPrint('Error syncing profile from Supabase: $e');
        // Continue even if sync fails - will check local storage
      }
      
      // Now check if user needs onboarding (will use synced data if available)
      final needsOnboarding = await ProfileValidation.needsOnboarding();
      debugPrint('User needs onboarding: $needsOnboarding');
      
      if (needsOnboarding && mounted) {
        // User needs to complete onboarding
        context.go('/onboarding');
      } else if (mounted) {
        // User has completed onboarding
        context.go('/home');
      }
    } catch (e) {
      debugPrint('Error checking user profile: $e');
      // On error, go to onboarding to be safe
      if (mounted) context.go('/onboarding');
    }
  }

  Future<void> _handleCallback() async {
    try {
      // Get the current URL and extract parameters
      final uri = Uri.base;
      debugPrint('=== AUTH CALLBACK HANDLER ===');
      debugPrint('Full URI: $uri');
      debugPrint('URI Scheme: ${uri.scheme}');
      debugPrint('URI Host: ${uri.host}');
      debugPrint('URI Path: ${uri.path}');
      debugPrint('Query parameters: ${uri.queryParameters}');
      
      // Log current Supabase session
      final currentSession = Supabase.instance.client.auth.currentSession;
      debugPrint('Current Supabase session exists: ${currentSession != null}');
      if (currentSession != null) {
        debugPrint('Session user: ${currentSession.user.email}');
      }
      
      // Extract the code parameter
      final code = uri.queryParameters['code'];
      debugPrint('Auth code: ${code != null ? "present (${code.length} chars)" : "null"}');
      
      // Extract error parameter if present
      final error = uri.queryParameters['error'];
      final errorDescription = uri.queryParameters['error_description'];
      if (error != null) {
        debugPrint('❌ OAuth Error: $error');
        debugPrint('❌ Error Description: $errorDescription');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('로그인 실패: ${errorDescription ?? error}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
          context.go('/');
          return;
        }
      }
      
      // Clean up the URL by removing the code parameter (web only)
      if (code != null && kIsWeb) {
        final cleanUrl = uri.toString().split('?')[0];
        cleanUrlInBrowser(cleanUrl);
        debugPrint('URL cleaned: $cleanUrl');
      }
      
      // Check current session before listening
      final initialSession = Supabase.instance.client.auth.currentSession;
      debugPrint('Initial session: ${initialSession?.user?.id}');
      
      // Try to recover session from URL
      debugPrint('Attempting to recover session from URL...');
      try {
        final response = await Supabase.instance.client.auth.getSessionFromUrl(uri);
        debugPrint('Session recovery response: ${response.session?.user?.id}');
        
        if (response.session != null) {
          debugPrint('Session recovered successfully!');
          if (mounted) {
            // Check if user has completed onboarding
            await _checkAndNavigate(response.session!.user);
            return;
          }
        }
      } catch (authError) {
        debugPrint('Auth error details: $authError');
        if (authError.toString().contains('Invalid API key')) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Supabase API 키가 유효하지 않습니다. 관리자에게 문의하세요.'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 5),
              ),
            );
          }
        }
        rethrow;
      }
      
      // Listen for auth state changes
      bool sessionFound = false;
      final authSub = Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        debugPrint('Auth state changed: ${data.event}');
        debugPrint('Session user: ${data.session?.user?.id}');
        
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
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Final check
      final finalSession = Supabase.instance.client.auth.currentSession;
      debugPrint('Final session check: ${finalSession?.user?.id}');
      
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
      debugPrint('Callback error: $e');
      debugPrint('Stack trace: $stack');
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
            colors: [Colors.grey[100]!, Colors.white, Colors.grey[50]!],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FortuneCompassIcon(
                size: 64,
                color: Colors.black87,
              ),
              const SizedBox(height: 24),
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                '로그인 처리 중...',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}