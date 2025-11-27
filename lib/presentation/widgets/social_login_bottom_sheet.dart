import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/toss_design_system.dart';
import '../../core/providers/user_settings_provider.dart';
import '../../core/theme/typography_theme.dart';

/// 재사용 가능한 소셜 로그인 BottomSheet
/// Landing Page, Onboarding 등 여러 곳에서 사용 가능
class SocialLoginBottomSheet {
  /// BottomSheet를 표시하고 사용자의 선택을 반환
  static Future<String?> show(
    BuildContext context, {
    required VoidCallback onGoogleLogin,
    required VoidCallback onAppleLogin,
    required VoidCallback onKakaoLogin,
    required VoidCallback onNaverLogin,
    bool isProcessing = false,
  }) async {
    return await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black.withValues(alpha: 0.5),
      builder: (bottomSheetContext) {
        debugPrint(
            '🌐 [BOTTOMSHEET] Theme brightness: ${Theme.of(bottomSheetContext).brightness}');
        debugPrint(
            '🌐 [BOTTOMSHEET] colorScheme.onSurface: ${Theme.of(bottomSheetContext).colorScheme.onSurface}');
        debugPrint(
            '🌐 [BOTTOMSHEET] textTheme.bodyLarge.color: ${Theme.of(bottomSheetContext).textTheme.bodyLarge?.color}');

        return Consumer(
          builder: (context, ref, _) {
            final typography = ref.watch(typographyThemeProvider);

            return Theme(
              data: ThemeData.light(),
              child: Container(
                decoration: BoxDecoration(
                  color: TossDesignSystem.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(25),
                    topRight: Radius.circular(25),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Container(
                      margin: const EdgeInsets.only(top: 12),
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: TossDesignSystem.gray300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Content
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title
                          Text(
                            '시작하기',
                            style: typography.headingLarge.copyWith(
                                fontWeight: FontWeight.w700,
                                color: TossDesignSystem.gray900,
                                letterSpacing: -0.5),
                          ),
                          const SizedBox(height: 12),
                          Text('소셜 계정으로 간편하게 시작해보세요',
                              style: typography.labelLarge.copyWith(
                                  color: TossDesignSystem.gray800)),

                          const SizedBox(height: 40),

                          // Social Login Buttons
                          // NOTE: Kakao and Naver are temporarily hidden.
                          // TODO: Re-enable when ready for production rollout.
                          // See: .claude/docs/09-social-login-status.md for details.
                          Column(children: [
                            // Google Login
                            _buildSocialButton(
                                onPressed: isProcessing ? null : onGoogleLogin,
                                type: 'google',
                                typography: typography),
                            const SizedBox(height: 12),

                            // Apple Login
                            _buildSocialButton(
                                onPressed: isProcessing ? null : onAppleLogin,
                                type: 'apple',
                                typography: typography),

                            // ============================================
                            // TEMPORARILY HIDDEN: Kakao & Naver Login
                            // Reason: Focus on Google/Apple for initial launch
                            // Re-enable by uncommenting below when ready
                            // ============================================
                            // const SizedBox(height: 12),
                            // // Kakao Login
                            // _buildSocialButton(
                            //     onPressed: isProcessing ? null : onKakaoLogin,
                            //     type: 'kakao',
                            //     typography: typography),
                            // const SizedBox(height: 12),
                            // // Naver Login
                            // _buildSocialButton(
                            //     onPressed: isProcessing ? null : onNaverLogin,
                            //     type: 'naver',
                            //     typography: typography),
                          ]),

                          const SizedBox(height: 30),

                          const Divider(height: 1),

                          const SizedBox(height: 20),

                          // Terms text
                          Text(
                              '계속하면 서비스 이용약관 및\n개인정보 처리방침에 동의하는 것으로 간주됩니다.',
                              style: typography.labelMedium.copyWith(
                                  color: TossDesignSystem.gray600,
                                  height: 1.5),
                              textAlign: TextAlign.center),

                          // Safe area bottom padding
                          SizedBox(height: MediaQuery.of(context).padding.bottom + 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 소셜 로그인 버튼 빌더
  static Widget _buildSocialButton(
      {required VoidCallback? onPressed, required String type, required TypographyTheme typography}) {
    Widget icon;
    String text;

    // BottomSheet는 항상 라이트 테마 (Theme.light()로 강제했음)
    const backgroundColor = TossDesignSystem.gray100;
    const borderColor = TossDesignSystem.gray300;

    switch (type) {
      case 'apple':
        icon = SvgPicture.asset(
          'assets/images/social/apple.svg',
          width: 24,
          height: 24,
        );
        text = 'Apple로 계속하기';
        break;
      case 'google':
        icon = SvgPicture.asset(
          'assets/images/social/google.svg',
          width: 24,
          height: 24,
        );
        text = 'Google로 계속하기';
        break;
      case 'kakao':
        icon = SvgPicture.asset(
          'assets/images/social/kakao.svg',
          width: 24,
          height: 24,
        );
        text = '카카오로 계속하기';
        break;
      case 'naver':
        icon = SvgPicture.asset(
          'assets/images/social/naver.svg',
          width: 24,
          height: 24,
        );
        text = '네이버로 계속하기';
        break;
      default:
        icon = Container();
        text = '';
    }

    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            SizedBox(width: 12),
            Text(
              text,
              style: typography.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: TossDesignSystem.gray900,
                fontFamily: 'TossProductSans',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
