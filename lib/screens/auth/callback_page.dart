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
import '../../core/design_system/design_system.dart';

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
        final response = await Supabase.instance.client
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
            'updated_at': DateTime.now().toIso8601String()
          };

          // Add additional info from user metadata if available
          if (user.userMetadata != null) {
            if (user.userMetadata?['full_name'] != null) {
              profileData['name'] = user.userMetadata?['full_name'];
            }
            if (user.userMetadata?['avatar_url'] != null) {
              profileData['profile_image_url'] =
                  user.userMetadata?['avatar_url'];
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
            debugPrint(
                'Supabase initialized with URL: ${Environment.supabaseUrl}');
            // Continue to onboarding even if profile creation fails
          }
        }
      } catch (e) {
        debugPrint('Supabase initialized with URL: ${Environment.supabaseUrl}');
        // Continue even if sync fails - will check local storage
      }

      // Chat-First: 모든 경우 /chat으로 이동 (온보딩은 채팅 내에서 처리)
      if (mounted) {
        context.go('/chat');
      }
    } catch (e) {
      debugPrint('Supabase initialized with URL: ${Environment.supabaseUrl}');
      // Chat-First: 에러 시에도 /chat으로 이동
      if (mounted) context.go('/chat');
    }
  }

  Uri _resolveCallbackUri() {
    final currentUri = Uri.base;
    final encodedCallbackUri = currentUri.queryParameters['authCallbackUrl'];
    if (encodedCallbackUri == null || encodedCallbackUri.isEmpty) {
      return currentUri;
    }

    try {
      return Uri.parse(Uri.decodeComponent(encodedCallbackUri));
    } catch (error) {
      debugPrint('Failed to decode authCallbackUrl: $error');
      return currentUri;
    }
  }

  Uri _normalizeAuthUri(Uri uri) {
    if (uri.fragment.isEmpty) {
      return uri;
    }

    try {
      final fragmentParams = Uri.splitQueryString(uri.fragment);
      if (fragmentParams.isEmpty) {
        return uri;
      }

      final merged = <String, String>{...uri.queryParameters};
      for (final entry in fragmentParams.entries) {
        merged.putIfAbsent(entry.key, () => entry.value);
      }

      return uri.replace(queryParameters: merged, fragment: '');
    } catch (error) {
      debugPrint('Failed to normalize callback fragment: $error');
      return uri;
    }
  }

  Future<bool> _restoreAuthSessionWithRetry({
    int maxAttempts = 8,
    Duration interval = const Duration(milliseconds: 500),
  }) async {
    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      final session = Supabase.instance.client.auth.currentSession;
      final user = session?.user;

      if (user != null) {
        debugPrint('Session restored on retry attempt: $attempt');
        await _checkAndNavigate(user);
        return true;
      }

      if (attempt == maxAttempts) {
        return false;
      }

      debugPrint('Waiting for auth session, attempt $attempt/$maxAttempts');
      await Future.delayed(interval);
    }

    return false;
  }

  Future<void> _handleCallback() async {
    try {
      final resolvedUri = _resolveCallbackUri();
      final uri = _normalizeAuthUri(resolvedUri);

      debugPrint('=== AUTH CALLBACK HANDLER ===');
      debugPrint('Supabase initialized with URL: ${Environment.supabaseUrl}');
      debugPrint('Scheme: ${uri.scheme}');
      debugPrint('Host: ${uri.host}');
      debugPrint('Path: ${uri.path}');
      debugPrint('parameters: ${uri.queryParameters}');

      if (uri.fragment.isNotEmpty) {
        debugPrint('Fragment (fallback): ${uri.fragment}');
      }

      // Log current Supabase session
      final currentSession = Supabase.instance.client.auth.currentSession;
      debugPrint('exists: ${currentSession != null}');
      if (currentSession != null) {
        debugPrint('user: ${currentSession.user.email}');
      }

      // Extract the code parameter
      final code = uri.queryParameters['code'];
      debugPrint(
          'code: ${code != null ? "present (${code.length} chars)" : "null"}');

      // Extract error parameter if present
      final error = uri.queryParameters['error'];
      final errorDescription = uri.queryParameters['error_description'];
      if (error != null) {
        debugPrint('OAuth Error: $error');
        debugPrint('Error Description: $errorDescription');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('로그인 실패: ${errorDescription ?? error}'),
              backgroundColor: context.colors.error,
              duration: const Duration(seconds: 5)));
          context.go('/chat');
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
      debugPrint('session: ${initialSession?.user.id}');

      // Try to recover session from URL
      debugPrint('Attempting to recover session from URL...');
      try {
        final response = await Supabase.instance.client.auth
            .getSessionFromUrl(uri, storeSession: true);
        final user = response.session.user;

        debugPrint('response: ${user.id}');

        debugPrint('Session recovered successfully!');
        if (mounted) {
          // Check if user has completed onboarding
          await _checkAndNavigate(user);
          return;
        }
      } catch (authError) {
        debugPrint('Session recovery failed from callback url: $authError');
        if (authError.toString().contains('Invalid API key')) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: const Text('Supabase API 키가 유효하지 않습니다. 관리자에게 문의하세요.'),
                backgroundColor: context.colors.error,
                duration: const Duration(seconds: 5)));
          }
        }
      }

      // Give auth state propagation time and retry by polling active session.
      final restored = await _restoreAuthSessionWithRetry();

      // Final check
      if (!restored) {
        debugPrint('No session found after all attempts');
        if (mounted) {
          context.go('/?error=auth_failure&reason=no_session');
        }
      }

      // Clean up
      debugPrint('=== END AUTH CALLBACK ===');
    } catch (e) {
      debugPrint('Supabase initialized with URL: ${Environment.supabaseUrl}');
      debugPrint('Supabase initialized with URL: ${Environment.supabaseUrl}');
      if (mounted) {
        context.go('/?error=auth_failure&reason=exception');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [colors.surface, colors.textPrimary, colors.surface])),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FortuneCompassIcon(
                  size: 64, color: colors.textPrimary.withValues(alpha: 0.87)),
              const SizedBox(height: AppSpacing.spacing6),
              const CircularProgressIndicator(),
              const SizedBox(height: AppSpacing.spacing4),
              Text(
                '로그인 처리 중...',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: colors.textSecondary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
