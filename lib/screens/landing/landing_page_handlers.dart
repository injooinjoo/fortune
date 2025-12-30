import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/design_system/design_system.dart';
import '../../presentation/widgets/social_login_bottom_sheet.dart';
import 'landing_page_state.dart';

/// Event handlers for LandingPage
/// Extracted from _LandingPageState to separate concerns
mixin LandingPageHandlers<T extends StatefulWidget> on LandingPageState<T> {
  Future<void> handleAppleLogin() async {
    debugPrint('🍎 _handleAppleLogin() called');
    debugPrint('🍎 _isAuthProcessing at start: $isAuthProcessing');

    if (isAuthProcessing) {
      debugPrint('🍎 Already processing, returning early');
      return;
    }

    debugPrint('🍎 Setting _isAuthProcessing to true');
    setAuthProcessing(true);
    startAuthTimeout();

    try {
      debugPrint('🍎 Calling _socialAuthService.signInWithApple()');
      if (socialAuthService == null) {
        throw Exception('Social auth service not available');
      }
      final result = await socialAuthService!.signInWithApple();

      debugPrint('🍎 signInWithApple() result: $result');

      if (result != null) {
        debugPrint('🍎 Native Apple Sign-In successful');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Apple 로그인 성공!'),
              backgroundColor: context.colors.success,
            ),
          );

          // Chat-First: 모든 경우 /chat으로 이동
          context.go('/chat');
        }
      } else {
        debugPrint('🍎 OAuth flow initiated');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Apple 로그인을 처리하고 있습니다...'),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('🍎 Apple login error: $e');
      debugPrint('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('Apple 로그인 중 문제가 발생했습니다. 다시 시도해주세요.'),
            backgroundColor: context.colors.error));
      }
    } finally {
      debugPrint('🍎 Setting _isAuthProcessing to false');
      if (mounted) {
        setAuthProcessing(false);
      }
    }
  }

  Future<void> handleNaverLogin() async {
    debugPrint('🟢 [NAVER] _handleNaverLogin() called');
    debugPrint('🟢 [NAVER] _isAuthProcessing at entry: $isAuthProcessing');

    if (isAuthProcessing) {
      debugPrint('🟢 [NAVER] Already processing, returning early');
      return;
    }

    debugPrint('🟢 [NAVER] Setting _isAuthProcessing = true');
    setAuthProcessing(true);
    startAuthTimeout();

    try {
      debugPrint('🟢 [NAVER] Checking _socialAuthService: $socialAuthService');
      if (socialAuthService == null) {
        debugPrint('🟢 [NAVER] ERROR: Social auth service is NULL!');
        throw Exception('Social auth service not available');
      }

      debugPrint('🟢 [NAVER] Calling signInWithNaver()...');

      final futureResult = socialAuthService!.signInWithNaver();
      debugPrint('🟢 [NAVER] Got Future: ${futureResult.runtimeType}');

      final result = await futureResult;
      debugPrint('🟢 [NAVER] signInWithNaver() returned: $result');

      if (result != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('네이버 로그인 성공!'),
            backgroundColor: context.colors.success,
          ));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('네이버 로그인을 처리하고 있습니다...')));
        }
      }
    } catch (e) {
      debugPrint('🟢 [NAVER] Exception caught: $e');
      debugPrint('🟢 [NAVER] Exception type: ${e.runtimeType}');
      debugPrint('Error saving profile: $e');
      if (mounted) {
        String errorMessage = '네이버 로그인 중 문제가 발생했습니다. 다시 시도해주세요.';
        if (e is AuthException) {
          errorMessage = e.message;
        } else if (e.toString().contains('already been registered')) {
          errorMessage =
              '이미 다른 소셜 계정(Google, Kakao, Apple)으로 가입된 이메일입니다.\n다른 로그인 방법을 시도해주세요.';
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(errorMessage),
            duration: const Duration(seconds: 4),
            backgroundColor: context.colors.error));
      }
    } finally {
      if (mounted) {
        setAuthProcessing(false);
      }
    }
  }

  void startOnboarding() async {
    showSocialLoginBottomSheet();
  }

  void showSocialLoginBottomSheet() async {
    if (isAuthProcessing) {
      setAuthProcessing(false);
      // Cancel timeout timer
      // Note: This should be handled by the state mixin
    }

    await SocialLoginBottomSheet.show(
      context,
      onGoogleLogin: () async {
        debugPrint('🔴 Google login button clicked');

        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        await Future.delayed(const Duration(milliseconds: 100));
        handleSocialLogin('Google');
      },
      onAppleLogin: () async {
        debugPrint('🍎 Apple login button clicked');
        debugPrint('🍎 _isAuthProcessing: $isAuthProcessing');

        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        await Future.delayed(const Duration(milliseconds: 100));
        handleAppleLogin();
      },
      onKakaoLogin: () async {
        debugPrint('🟡 Kakao login button clicked');

        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }

        await Future.delayed(const Duration(milliseconds: 100));
        handleSocialLogin('Kakao');
      },
      onNaverLogin: () {
        debugPrint('🟢 Naver login button clicked');
        debugPrint('🟢 _isAuthProcessing before pop: $isAuthProcessing');

        Navigator.pop(context);

        debugPrint('🟢 About to call _handleNaverLogin()');
        handleNaverLogin();
      },
      isProcessing: isAuthProcessing,
    );
  }

  Future<void> handleSocialLogin(String provider) async {
    if (isAuthProcessing) return;

    setAuthProcessing(true);
    startAuthTimeout();

    try {
      if (provider == 'Google') {
        await _handleGoogleLogin();
      } else if (provider == 'Kakao') {
        await _handleKakaoLogin();
      } else if (provider == 'Instagram') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: const Text('인스타그램 로그인은 현재 준비 중입니다.'),
              backgroundColor: context.colors.warning));
        }
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: const Text('로그인 중 문제가 발생했습니다. 다시 시도해주세요.'),
            backgroundColor: context.colors.error));
      }
    } finally {
      if (mounted) {
        setAuthProcessing(false);
      }
    }
  }

  Future<void> _handleGoogleLogin() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white)),
              ),
              SizedBox(width: 16),
              Text('Google 로그인 진행 중...'),
            ],
          ),
          duration: Duration(seconds: 10),
        ),
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final keys = prefs
        .getKeys()
        .where((key) =>
            key.contains('fortune-auth-token-code-verifier') ||
            (key.contains('code-verifier') && !key.startsWith('sb-')))
        .toList();

    for (final key in keys) {
      await prefs.remove(key);
    }

    try {
      if (socialAuthService == null) {
        throw Exception('Social auth service not available');
      }

      await socialAuthService!.signInWithGoogle();

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google 로그인을 처리하고 있습니다...'),
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      debugPrint('Google 로그인 에러: $e');

      if (mounted) {
        String errorMessage = '로그인 중 문제가 발생했습니다. 다시 시도해주세요.';

        if (e.toString().contains('Invalid API key')) {
          errorMessage = '인증 서버 연결에 실패했습니다. 잠시 후 다시 시도해주세요.';
        } else if (e.toString().contains('sign in failed to start')) {
          errorMessage = 'Google 로그인을 시작할 수 없습니다. 다시 시도해주세요.';
        }

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(errorMessage),
            backgroundColor: context.colors.error));
      }
      rethrow;
    }
  }

  Future<void> _handleKakaoLogin() async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white)),
              ),
              SizedBox(width: 16),
              Text('카카오 로그인 진행 중...'),
            ],
          ),
          duration: Duration(seconds: 10),
        ),
      );
    }

    try {
      debugPrint('🟡 Starting Kakao login...');
      if (socialAuthService == null) {
        throw Exception('Social auth service not available');
      }

      final response = await socialAuthService!.signInWithKakao();

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      debugPrint('🟡 Kakao login response: $response');

      if (response != null && response.user != null) {
        debugPrint('🟡 Kakao login successful, user: ${response.user?.id}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('카카오 로그인이 완료되었습니다.'),
              backgroundColor: context.colors.success,
            ),
          );
        }

        await syncProfileFromSupabase();
        await updateKakaoProfileName();

        // Chat-First: 모든 경우 /chat으로 이동 (온보딩은 채팅 내에서 처리)
        if (mounted) {
          debugPrint('🟡 Redirecting to chat...');
          context.go('/chat');
        }
      } else {
        debugPrint('🟡 Kakao OAuth flow initiated, waiting for callback...');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('카카오 로그인을 처리하고 있습니다...'),
              backgroundColor: context.colors.warning,
            ),
          );
        }
      }
    } catch (kakaoError) {
      debugPrint('🟡 Kakao login error: $kakaoError');

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('카카오 로그인 중 문제가 발생했습니다: ${kakaoError.toString()}'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }
}
