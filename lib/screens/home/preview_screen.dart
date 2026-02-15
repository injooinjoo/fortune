import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/design_system/design_system.dart';
import '../../services/social_auth_service.dart';
import '../../core/utils/logger.dart';
import '../../presentation/widgets/social_login_bottom_sheet.dart';

class PreviewScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;
  final VoidCallback? onContinueWithoutLogin;

  const PreviewScreen({
    super.key,
    this.onLoginSuccess,
    this.onContinueWithoutLogin,
  });

  @override
  State<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends State<PreviewScreen>
    with TickerProviderStateMixin {
  late final SocialAuthService _socialAuthService;
  late AnimationController _fadeController;
  late AnimationController _slideController;

  @override
  void initState() {
    super.initState();
    _socialAuthService = SocialAuthService(Supabase.instance.client);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // 애니메이션 시작
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  Future<void> _showSocialLoginBottomSheet(BuildContext context) async {
    await SocialLoginBottomSheet.show(
      context,
      onGoogleLogin: () => _handleSocialLogin(
        provider: 'google',
        loginAction: () =>
            _socialAuthService.signInWithGoogle(context: context),
      ),
      onAppleLogin: () => _handleSocialLogin(
        provider: 'apple',
        loginAction: _socialAuthService.signInWithApple,
      ),
      onKakaoLogin: () => _handleSocialLogin(
        provider: 'kakao',
        loginAction: _socialAuthService.signInWithKakao,
      ),
      onNaverLogin: () => _handleSocialLogin(
        provider: 'naver',
        loginAction: _socialAuthService.signInWithNaver,
      ),
    );
  }

  Future<void> _handleSocialLogin({
    required String provider,
    required Future<AuthResponse?> Function() loginAction,
  }) async {
    try {
      final response = await loginAction();
      if (!mounted) return;

      if (response != null && response.user != null) {
        widget.onLoginSuccess?.call();
      } else {
        widget.onLoginSuccess?.call();
      }
    } catch (error) {
      Logger.error('소셜 로그인 실패: $provider', error);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('로그인에 실패했습니다. 다시 시도해주세요.'),
          backgroundColor: context.colors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.background,
      body: SafeArea(
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: DSSpacing.pageHorizontal),
          child: Column(
            children: [
              const Spacer(),

              // Main content
              FadeTransition(
                opacity: _fadeController,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 0.3),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _slideController,
                    curve: Curves.easeOutCubic,
                  )),
                  child: Column(
                    children: [
                      // Title
                      Text(
                        '오늘의 이야기가\n완성되었어요!',
                        style: context.displaySmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colors.textPrimary,
                          height: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 16),

                      // Subtitle
                      Text(
                        '로그인하고 나만의 맞춤 인사이트를\n확인해보세요',
                        style: context.labelMedium.copyWith(
                          color: colors.textSecondary,
                          height: 1.4,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 48),

                      // Preview button
                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          onPressed: () => _showSocialLoginBottomSheet(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.ctaBackground,
                            foregroundColor: colors.ctaForeground,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(DSRadius.md),
                            ),
                          ),
                          child: Text(
                            '내 미래 미리보기',
                            style: context.labelMedium.copyWith(
                              color: colors.ctaForeground,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Continue without login
                      GestureDetector(
                        onTap: widget.onContinueWithoutLogin,
                        child: Text(
                          '로그인 없이 보기',
                          style: context.bodySmall.copyWith(
                            color: colors.textSecondary,
                            decoration: TextDecoration.underline,
                            decorationColor: colors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
