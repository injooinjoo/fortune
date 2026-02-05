import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../core/theme/typography_unified.dart';
import '../../core/design_system/tokens/ds_obangseok_colors.dart';
import '../../presentation/providers/token_provider.dart';
import '../../presentation/providers/subscription_provider.dart';
import '../../domain/entities/token.dart';

/// 프로필 페이지의 프리미엄 멤버십 통합 카드
///
/// - 구독자: 황금색 그라데이션 + "프리미엄 구독중" + 플랜 배지 + 남은 기간
/// - 비구독자: accent 그라데이션 + 복주머니 잔액 + 충전하기 + 구독 CTA
class PremiumMembershipCard extends ConsumerWidget {
  const PremiumMembershipCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPremium = ref.watch(isPremiumProvider);
    final tokenBalance = ref.watch(tokenBalanceProvider);
    final tokenState = ref.watch(tokenProvider);
    final subscription = tokenState.subscription;

    return Column(
      children: [
        const SizedBox(height: DSSpacing.md),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: DSSpacing.pageHorizontal),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isPremium
                  ? [ObangseokColors.hwang, ObangseokColors.hwangLight]
                  : [
                      context.colors.accent,
                      context.colors.accent.withValues(alpha: 0.8),
                    ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(DSRadius.lg),
            boxShadow: [
              BoxShadow(
                color: (isPremium ? ObangseokColors.hwang : context.colors.accent)
                    .withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push(isPremium ? '/subscription' : '/token-purchase'),
              borderRadius: BorderRadius.circular(DSRadius.lg),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: isPremium
                    ? _buildPremiumContent(context, subscription)
                    : _buildTokenContent(context, tokenBalance),
              ),
            ),
          ),
        ),
        // 비구독자: 구독 CTA 추가
        if (!isPremium) ...[
          const SizedBox(height: 12),
          _buildSubscriptionCTA(context),
        ],
      ],
    );
  }

  /// 구독자 UI - 프리미엄 구독중 상태 표시
  Widget _buildPremiumContent(BuildContext context, UnlimitedSubscription? subscription) {
    final planText = subscription?.plan == 'yearly' ? '연간' : '월간';
    final remainingDays = subscription?.remainingDays ?? 0;

    return Row(
      children: [
        // 프리미엄 아이콘
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(DSRadius.md),
          ),
          child: const Icon(
            Icons.workspace_premium,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        // 텍스트 정보
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    '프리미엄 구독중',
                    style: context.heading3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // 플랜 배지
                  if (subscription != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        planText,
                        style: context.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                subscription != null
                    ? '$remainingDays일 남음 · 무제한 운세 이용 중'
                    : '무제한 운세 이용 중',
                style: context.labelSmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        // 관리 아이콘
        Icon(
          Icons.chevron_right,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ],
    );
  }

  /// 비구독자 UI - 복주머니 잔액 표시
  Widget _buildTokenContent(BuildContext context, TokenBalance? balance) {
    final remainingTokens = balance?.remainingTokens ?? 0;
    final hasUnlimited = balance?.hasUnlimitedAccess ?? false;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(DSRadius.md),
          ),
          child: Icon(
            hasUnlimited ? Icons.all_inclusive : Icons.toll_rounded,
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '보유 복주머니',
                style: context.labelSmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    hasUnlimited ? '무제한' : '$remainingTokens개',
                    style: context.heading3.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!hasUnlimited) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '충전하기',
                        style: context.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        Icon(
          Icons.chevron_right,
          color: Colors.white.withValues(alpha: 0.8),
        ),
      ],
    );
  }

  /// 비구독자용 구독 CTA
  Widget _buildSubscriptionCTA(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: DSSpacing.pageHorizontal),
      decoration: BoxDecoration(
        color: context.colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(
          color: context.colors.accent.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/subscription'),
          borderRadius: BorderRadius.circular(DSRadius.md),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Icon(
                  Icons.workspace_premium_rounded,
                  color: context.colors.accent,
                  size: 22,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '프리미엄 구독으로 무제한 이용하기',
                    style: context.bodyMedium.copyWith(
                      color: context.colors.textPrimary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: context.colors.textSecondary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
