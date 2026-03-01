import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/design_system/design_system.dart';
import '../../core/services/fortune_haptic_service.dart';

typedef SocialLoginAction = Future<void> Function();

/// 재사용 가능한 소셜 로그인 BottomSheet
/// Landing Page, Onboarding 등 여러 곳에서 사용 가능
class SocialLoginBottomSheet {
  /// BottomSheet를 표시하고 사용자의 선택을 반환
  static Future<void> show(
    BuildContext context, {
    required SocialLoginAction onGoogleLogin,
    required SocialLoginAction onAppleLogin,
    required SocialLoginAction onKakaoLogin,
    required SocialLoginAction onNaverLogin,
    bool isProcessing = false,
    WidgetRef? ref,
  }) async {
    // 바텀시트 열림 햅틱
    if (ref != null) {
      ref.read(fortuneHapticServiceProvider).sheetOpen();
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: DSColorScheme(Theme.of(context).brightness).overlay,
      builder: (bottomSheetContext) {
        debugPrint(
            '🌐 [BOTTOMSHEET] Theme brightness: ${Theme.of(bottomSheetContext).brightness}');
        debugPrint(
            '🌐 [BOTTOMSHEET] colorScheme.onSurface: ${Theme.of(bottomSheetContext).colorScheme.onSurface}');
        debugPrint(
            '🌐 [BOTTOMSHEET] textTheme.bodyLarge.color: ${Theme.of(bottomSheetContext).textTheme.bodyLarge?.color}');

        bool isTapLocked = false;
        String? activeLoadingProvider;

        return StatefulBuilder(
          builder: (context, setSheetState) {
            final colors = context.colors;
            final isButtonDisabled = isProcessing || isTapLocked;

            Future<void> handleSocialTap(
                SocialLoginAction action, String provider) async {
              if (isProcessing || isTapLocked) return;
              setSheetState(() {
                isTapLocked = true;
                activeLoadingProvider = provider;
              });

              // 잠시 로딩 상태 표시 후 닫기 (사용자 피드백)
              await Future<void>.delayed(const Duration(milliseconds: 300));
              if (bottomSheetContext.mounted) {
                Navigator.of(bottomSheetContext).pop();
              }
              await Future<void>.delayed(const Duration(milliseconds: 80));
              await action();
            }

            return Container(
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
                            context: context,
                            onPressed: isButtonDisabled
                                ? null
                                : () =>
                                    handleSocialTap(onGoogleLogin, 'google'),
                            type: 'google',
                            colors: colors,
                            isLoading: activeLoadingProvider == 'google'),

                        // Apple Login - iOS/Web only (Android OAuth 미지원)
                        if (!Platform.isAndroid) ...[
                          const SizedBox(height: 12),
                          _buildSocialButton(
                              context: context,
                              onPressed: isButtonDisabled
                                  ? null
                                  : () =>
                                      handleSocialTap(onAppleLogin, 'apple'),
                              type: 'apple',
                              colors: colors,
                              isLoading: activeLoadingProvider == 'apple'),
                        ],

                        // Safe area bottom padding
                        SizedBox(
                            height: MediaQuery.of(context).padding.bottom + 8),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// 소셜 로그인 버튼 빌더
  /// [isLoading]이 true일 때 로딩 인디케이터 표시 (해당 버튼만)
  static Widget _buildSocialButton({
    required BuildContext context,
    required VoidCallback? onPressed,
    required String type,
    required DSColorScheme colors,
    bool isLoading = false,
  }) {
    Widget icon;
    String text;

    final backgroundColor = colors.backgroundSecondary;
    final borderColor = colors.border;

    // Apple: solid CTA style (ChatGPT pattern)
    // Google: bordered style (ChatGPT pattern)
    final isApple = type == 'apple';

    switch (type) {
      case 'apple':
        icon = SvgPicture.asset(
          'assets/images/social/apple.svg',
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            colors.ctaForeground,
            BlendMode.srcIn,
          ),
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
          color: isApple ? colors.ctaBackground : backgroundColor,
          borderRadius: BorderRadius.circular(26),
          border: isApple ? null : Border.all(color: borderColor, width: 1),
        ),
        child: isLoading
            // 로딩 상태: 인디케이터 + 텍스트
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color:
                          isApple ? colors.ctaForeground : colors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${type == 'apple' ? 'Apple' : type == 'google' ? 'Google' : type == 'kakao' ? '카카오' : '네이버'} 계정 연결 중...',
                    style: context.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color:
                          isApple ? colors.ctaForeground : colors.textPrimary,
                    ),
                  ),
                ],
              )
            // 기본 상태: 아이콘 + 텍스트
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon,
                  const SizedBox(width: 12),
                  Text(
                    text,
                    style: context.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color:
                          isApple ? colors.ctaForeground : colors.textPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
