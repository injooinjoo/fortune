import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../presentation/widgets/social_login_bottom_sheet.dart';
import '../../../../services/social_auth_service.dart';

/// 배너 임시 숨김 상태 (세션 내에서만 유지)
final _bannerDismissedProvider = StateProvider<bool>((ref) => false);

/// 로그인 처리 중 상태
final _loginProcessingProvider = StateProvider<bool>((ref) => false);

/// 게스트 사용자에게 로그인을 유도하는 배너
class GuestLoginBanner extends ConsumerWidget {
  const GuestLoginBanner({super.key});

  void _showLoginBottomSheet(BuildContext context, WidgetRef ref) {
    SocialAuthService? socialAuthService;
    try {
      socialAuthService = SocialAuthService(Supabase.instance.client);
    } catch (e) {
      debugPrint('⚠️ [GuestLoginBanner] SocialAuthService init failed: $e');
      return;
    }

    final isProcessing = ref.read(_loginProcessingProvider);

    SocialLoginBottomSheet.show(
      context,
      onGoogleLogin: () async {
        Navigator.pop(context);
        ref.read(_loginProcessingProvider.notifier).state = true;
        try {
          await socialAuthService!.signInWithGoogle();
        } catch (e) {
          debugPrint('❌ Google login failed: $e');
        } finally {
          ref.read(_loginProcessingProvider.notifier).state = false;
        }
      },
      onAppleLogin: () async {
        Navigator.pop(context);
        ref.read(_loginProcessingProvider.notifier).state = true;
        try {
          await socialAuthService!.signInWithApple();
        } catch (e) {
          debugPrint('❌ Apple login failed: $e');
        } finally {
          ref.read(_loginProcessingProvider.notifier).state = false;
        }
      },
      onKakaoLogin: () async {
        Navigator.pop(context);
        ref.read(_loginProcessingProvider.notifier).state = true;
        try {
          await socialAuthService!.signInWithKakao();
        } catch (e) {
          debugPrint('❌ Kakao login failed: $e');
        } finally {
          ref.read(_loginProcessingProvider.notifier).state = false;
        }
      },
      onNaverLogin: () async {
        Navigator.pop(context);
        ref.read(_loginProcessingProvider.notifier).state = true;
        try {
          await socialAuthService!.signInWithNaver();
        } catch (e) {
          debugPrint('❌ Naver login failed: $e');
        } finally {
          ref.read(_loginProcessingProvider.notifier).state = false;
        }
      },
      isProcessing: isProcessing,
      ref: ref,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // authStateProvider를 watch하여 로그인 상태 변경 시 자동 리빌드
    final authState = ref.watch(authStateProvider);
    final isDismissed = ref.watch(_bannerDismissedProvider);
    final isProcessing = ref.watch(_loginProcessingProvider);

    // 로그인 상태 확인 (세션이 있으면 로그인됨)
    final isLoggedIn = authState.maybeWhen(
      data: (state) => state?.session != null,
      orElse: () => false,
    );

    // 로그인 상태거나 배너 닫힌 상태면 표시 안 함
    if (isLoggedIn || isDismissed) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;

    // 심플한 작은 로그인 버튼
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isProcessing ? null : () => _showLoginBottomSheet(context, ref),
        borderRadius: BorderRadius.circular(DSRadius.full),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.sm,
            vertical: DSSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: colors.backgroundSecondary,
            borderRadius: BorderRadius.circular(DSRadius.full),
            border: Border.all(
              color: colors.divider,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isProcessing)
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.textSecondary,
                  ),
                )
              else
                Icon(
                  Icons.person_outline_rounded,
                  size: 14,
                  color: colors.textSecondary,
                ),
              const SizedBox(width: 4),
              Text(
                '로그인',
                style: context.typography.labelSmall.copyWith(
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
