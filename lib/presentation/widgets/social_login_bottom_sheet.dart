import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/design_system/design_system.dart';
import '../../core/services/fortune_haptic_service.dart';
import '../../services/social_auth/base/social_auth_attempt_result.dart';
import '../../services/social_auth_service.dart';

typedef SocialLoginAction = Future<void> Function();

/// 재사용 가능한 소셜 로그인 BottomSheet
/// Landing Page, Onboarding 등 여러 곳에서 사용 가능
class SocialLoginBottomSheet {
  static Future<void> showForAuthentication(
    BuildContext context, {
    required WidgetRef ref,
    SocialAuthService? socialAuthService,
    VoidCallback? onAuthenticated,
  }) async {
    final authService =
        socialAuthService ?? SocialAuthService(Supabase.instance.client);

    await show(
      context,
      onGoogleLogin: () => _handleSocialLogin(
        context: context,
        providerLabel: 'Google',
        loginAction: () => authService.signInWithGoogle(context: context),
        onAuthenticated: onAuthenticated,
      ),
      onAppleLogin: () => _handleSocialLogin(
        context: context,
        providerLabel: 'Apple',
        loginAction: authService.signInWithApple,
        onAuthenticated: onAuthenticated,
      ),
      onKakaoLogin: () async {},
      onNaverLogin: () async {},
      ref: ref,
    );
  }

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
      backgroundColor: context.colors.surface.withValues(alpha: 0),
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
            final typography = context.typography;
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
                color: colors.surface.withValues(alpha: 0.98),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
                border: Border(
                  top: BorderSide(
                    color: colors.border.withValues(alpha: 0.7),
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 14),
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: colors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '로그인하고 대화를 이어가세요',
                          style: typography.headingSmall.copyWith(
                            color: colors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '지금까지의 흐름을 저장하고, 더 자연스럽게 이어서 사용할 수 있어요.',
                          style: typography.bodyMedium.copyWith(
                            color: colors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildSocialButton(
                          context: context,
                          onPressed: isButtonDisabled
                              ? null
                              : () => handleSocialTap(onGoogleLogin, 'google'),
                          type: 'google',
                          colors: colors,
                          isLoading: activeLoadingProvider == 'google',
                        ),
                        if (!Platform.isAndroid) ...[
                          const SizedBox(height: 12),
                          _buildSocialButton(
                            context: context,
                            onPressed: isButtonDisabled
                                ? null
                                : () => handleSocialTap(onAppleLogin, 'apple'),
                            type: 'apple',
                            colors: colors,
                            isLoading: activeLoadingProvider == 'apple',
                          ),
                        ],
                        SizedBox(
                          height: MediaQuery.of(context).padding.bottom + 8,
                        ),
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

  static Future<void> _handleSocialLogin({
    required BuildContext context,
    required String providerLabel,
    required Future<SocialAuthAttemptResult> Function() loginAction,
    VoidCallback? onAuthenticated,
  }) async {
    if (!context.mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    messenger.showSnackBar(
      SnackBar(
        content: Text('$providerLabel 로그인 시도 중...'),
        duration: const Duration(seconds: 1),
      ),
    );

    try {
      final result = await loginAction();

      if (!context.mounted) return;
      messenger.hideCurrentSnackBar();

      if (result.isAuthenticated) {
        if (onAuthenticated != null) {
          onAuthenticated();
        } else {
          context.go('/chat');
        }
        return;
      }

      if (result.isPendingExternalAuth) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('브라우저에서 인증을 완료해 주세요. 완료되면 앱으로 돌아옵니다.'),
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (error) {
      if (!context.mounted) return;

      final errorMessage = error.toString();
      if (errorMessage.toLowerCase().contains('cancel')) {
        messenger.hideCurrentSnackBar();
        return;
      }

      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text('$providerLabel 로그인 실패: $errorMessage'),
          backgroundColor: context.colors.error,
          duration: const Duration(seconds: 5),
        ),
      );
    }
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
        height: 56,
        decoration: BoxDecoration(
          color: isApple ? colors.ctaBackground : backgroundColor,
          borderRadius: BorderRadius.circular(18),
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
                      fontWeight: FontWeight.w700,
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
                      fontWeight: FontWeight.w700,
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
