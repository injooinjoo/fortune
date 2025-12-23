import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system/design_system.dart';
import '../../core/services/fortune_haptic_service.dart';

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
    WidgetRef? ref,
  }) async {
    // 바텀시트 열림 햅틱
    if (ref != null) {
      ref.read(fortuneHapticServiceProvider).sheetOpen();
    }

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

        return Builder(
          builder: (context) {
            final colors = context.colors;

            return Theme(
              data: ThemeData.light(),
              child: Container(
                decoration: BoxDecoration(
                  color: colors.surface,
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
                        color: colors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),

                    // Content - 버튼만
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Google Login
                          _buildSocialButton(
                              onPressed: isProcessing ? null : onGoogleLogin,
                              type: 'google',
                              colors: colors),
                          const SizedBox(height: 12),

                          // Apple Login
                          _buildSocialButton(
                              onPressed: isProcessing ? null : onAppleLogin,
                              type: 'apple',
                              colors: colors),

                          // Safe area bottom padding
                          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
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
      {required VoidCallback? onPressed, required String type, required DSColorScheme colors}) {
    Widget icon;
    String text;

    // BottomSheet는 항상 라이트 테마 (Theme.light()로 강제했음)
    final backgroundColor = colors.backgroundSecondary;
    final borderColor = colors.border;

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
            const SizedBox(width: 12),
            Text(
              text,
              style: DSTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
