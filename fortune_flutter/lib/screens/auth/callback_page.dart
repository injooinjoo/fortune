import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/icons/fortune_compass_icon.dart';

class CallbackPage extends StatefulWidget {
  const CallbackPage({super.key});

  @override
  State<CallbackPage> createState() => _CallbackPageState();
}

class _CallbackPageState extends State<CallbackPage> {
  @override
  void initState() {
    super.initState();
    _handleCallback();
  }

  Future<void> _handleCallback() async {
    try {
      // Get the current URL and extract parameters
      final uri = Uri.base;
      debugPrint('=== AUTH CALLBACK HANDLER ===');
      debugPrint('Full URI: $uri');
      debugPrint('Query parameters: ${uri.queryParameters}');
      
      // Extract the code parameter
      final code = uri.queryParameters['code'];
      debugPrint('Auth code: $code');
      
      // Check current session before listening
      final initialSession = Supabase.instance.client.auth.currentSession;
      debugPrint('Initial session: ${initialSession?.user?.id}');
      
      // Try to recover session from URL
      debugPrint('Attempting to recover session from URL...');
      final response = await Supabase.instance.client.auth.getSessionFromUrl(uri);
      debugPrint('Session recovery response: ${response.session?.user?.id}');
      
      if (response.session != null) {
        debugPrint('Session recovered successfully!');
        if (mounted) {
          context.go('/home');
          return;
        }
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
            context.go('/home');
          }
        }
      });
      
      // Wait for auth state to settle
      debugPrint('Waiting for auth state to settle...');
      await Future.delayed(const Duration(seconds: 3));
      
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
            colors: [Colors.purple[50]!, Colors.white, Colors.pink[50]!],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FortuneCompassIcon(
                size: 64,
                color: Colors.purple[600],
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