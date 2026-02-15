// 토큰 부족 모달 - 프리미엄 기능 이용 시 토큰 부족할 때 표시 (풀스크린)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/design_system/design_system.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/token_provider.dart';
import '../../presentation/widgets/social_login_bottom_sheet.dart';
import '../../services/social_auth_service.dart';

class TokenInsufficientModal extends ConsumerStatefulWidget {
  final int requiredTokens;
  final String fortuneType;

  const TokenInsufficientModal({
    super.key,
    required this.requiredTokens,
    required this.fortuneType,
  });

  @override
  ConsumerState<TokenInsufficientModal> createState() =>
      _TokenInsufficientModalState();

  static Future<bool> show({
    required BuildContext context,
    required int requiredTokens,
    required String fortuneType,
  }) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      enableDrag: true,
      builder: (context) => TokenInsufficientModal(
        requiredTokens: requiredTokens,
        fortuneType: fortuneType,
      ),
    );
    return result ?? false;
  }
}

class _TokenInsufficientModalState
    extends ConsumerState<TokenInsufficientModal> {
  /// 다음 무료 토큰 지급 시간 (자정)
  String _getNextResetTime() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    final hoursLeft = tomorrow.difference(now).inHours;
    final minutesLeft = tomorrow.difference(now).inMinutes % 60;

    if (hoursLeft > 0) {
      return '$hoursLeft시간 $minutesLeft분';
    } else {
      return '$minutesLeft분';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final authState = ref.watch(authStateProvider);
    final isLoggedIn = authState.maybeWhen(
      data: (state) =>
          state?.session != null ||
          Supabase.instance.client.auth.currentSession != null,
      orElse: () => Supabase.instance.client.auth.currentSession != null,
    );

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 12, 24, bottomPadding + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 드래그 핸들
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),

              // 토큰 아이콘
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: colors.accent.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.toll_outlined,
                  size: 32,
                  color: colors.accent,
                ),
              ),
              const SizedBox(height: 20),

              // Title
              Text(
                isLoggedIn ? '토큰을 모두 소진했어요' : '로그인이 필요해요',
                style: context.headingMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),

              if (isLoggedIn)
                // 남은 시간 안내 (로그인 사용자)
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: colors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.schedule_outlined,
                        size: 20,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '무료 토큰 충전까지 ',
                        style: context.bodyMedium.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                      Text(
                        _getNextResetTime(),
                        style: context.bodyMedium.copyWith(
                          color: colors.accent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                )
              else
                // 로그인 안내 (비로그인 사용자)
                Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                  decoration: BoxDecoration(
                    color: colors.backgroundSecondary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.login_outlined,
                        size: 20,
                        color: colors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '로그인 후 토큰을 충전하고 사용할 수 있어요',
                        style: context.bodyMedium.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 12),

              // 안내 문구
              Text(
                isLoggedIn
                    ? '지금 바로 이용하시려면 토큰을 구매하세요'
                    : '로그인하면 현재 채팅을 이어서 사용할 수 있어요',
                style: context.bodySmall.copyWith(
                  color: colors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              if (isLoggedIn) ...[
                // Best Value - Subscription (가성비 최고)
                _buildSubscriptionButton(),
                const SizedBox(height: 12),

                // Secondary Options
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.shopping_bag_outlined,
                        label: '토큰 구매',
                        subtitle: '₩28~/개',
                        isPrimary: false,
                        onTap: () {
                          Navigator.of(context).pop();
                          context.push('/token-purchase');
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        icon: Icons.card_giftcard_outlined,
                        label: '무료 받기',
                        subtitle: '일 1회',
                        isPrimary: false,
                        onTap: () async {
                          final result = await ref
                              .read(tokenProvider.notifier)
                              .claimDailyTokens();
                          if (result && context.mounted) {
                            Navigator.of(context).pop(true);
                          } else if (context.mounted) {
                            _showClaimError();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ] else ...[
                DSButton.primary(
                  text: '로그인하기',
                  leadingIcon: Icons.login_outlined,
                  onPressed: _showSocialLoginBottomSheet,
                ),
              ],
              const SizedBox(height: 16),

              // Cancel Button
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(
                    '나중에 하기',
                    style: context.bodyMedium.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSocialLoginBottomSheet() {
    SocialAuthService? socialAuthService;
    try {
      socialAuthService = SocialAuthService(Supabase.instance.client);
    } catch (e) {
      _showLoginError();
      return;
    }

    SocialLoginBottomSheet.show(
      context,
      onGoogleLogin: () async {
        await _handleSocialLogin(() async {
          await socialAuthService!.signInWithGoogle();
        });
      },
      onAppleLogin: () async {
        await _handleSocialLogin(() async {
          await socialAuthService!.signInWithApple();
        });
      },
      onKakaoLogin: () async {
        await _handleSocialLogin(() async {
          await socialAuthService!.signInWithKakao();
        });
      },
      onNaverLogin: () async {
        await _handleSocialLogin(() async {
          await socialAuthService!.signInWithNaver();
        });
      },
      isProcessing: false,
      ref: ref,
    );
  }

  Future<void> _handleSocialLogin(Future<void> Function() loginAction) async {
    final messenger = ScaffoldMessenger.maybeOf(context);
    final errorColor = context.colors.error;

    // 토큰 모달 닫기
    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    try {
      await loginAction();
    } catch (e) {
      messenger?.showSnackBar(
        SnackBar(
          content: const Text('로그인에 실패했습니다. 다시 시도해주세요.'),
          backgroundColor: errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  void _showLoginError() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('로그인 화면을 여는 중 문제가 발생했습니다.'),
        backgroundColor: context.colors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    String? subtitle,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    final colors = context.colors;

    return Material(
      color: isPrimary ? colors.accent : colors.backgroundSecondary,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          DSHaptics.light();
          onTap();
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.white : colors.textSecondary,
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: context.labelMedium.copyWith(
                  color: isPrimary ? Colors.white : colors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: context.labelSmall.copyWith(
                    color: isPrimary ? Colors.white70 : colors.textTertiary,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionButton() {
    final colors = context.colors;

    return Material(
      color: colors.accent,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          DSHaptics.light();
          Navigator.of(context).pop();
          context.push('/subscription');
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              // 아이콘
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.workspace_premium_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              // 텍스트
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Plus 구독',
                          style: context.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '21배 저렴',
                            style: context.labelSmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '월 ₩3,900 · 3,000 토큰 (₩1.3/개)',
                      style: context.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Colors.white70,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClaimError() {
    final colors = context.colors;
    final tokenError = ref.read(tokenProvider).error;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          tokenError == 'ALREADY_CLAIMED'
              ? '오늘은 이미 무료 토큰을 받으셨습니다'
              : '무료 토큰 받기에 실패했습니다',
        ),
        backgroundColor: colors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}
