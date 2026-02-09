import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/design_system/design_system.dart';
import '../../presentation/providers/token_provider.dart';
import '../../presentation/providers/subscription_provider.dart';
import '../../domain/entities/token.dart';

/// 프로필 페이지의 구독 멤버십 통합 카드
///
/// - 구독자: 황금색 그라데이션 + "구독중" + 플랜 배지 + 남은 기간
/// - 비구독자: accent 그라데이션 + 토큰 잔액 + 충전하기 + 구독 CTA
class PremiumMembershipCard extends ConsumerWidget {
  const PremiumMembershipCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSubscriber = ref.watch(isSubscriptionActiveProvider);
    final tokenBalance = ref.watch(tokenBalanceProvider);
    final tokenState = ref.watch(tokenProvider);

    return Column(
      children: [
        const SizedBox(height: DSSpacing.md),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: DSSpacing.pageHorizontal),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isSubscriber
                  ? [DSColors.warning, DSColors.warning.withValues(alpha: 0.8)]
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
                color: (isSubscriber ? DSColors.warning : context.colors.accent)
                    .withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push(isSubscriber ? '/subscription' : '/token-purchase'),
              borderRadius: BorderRadius.circular(DSRadius.lg),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: isSubscriber
                    ? _buildPremiumContent(context, tokenState)
                    : _buildTokenContent(context, tokenBalance),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 구독자 UI - 토큰 잔액 표시
  Widget _buildPremiumContent(BuildContext context, TokenState tokenState) {
    final remainingTokens = tokenState.currentTokens;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '보유 토큰',
              style: context.labelSmall.copyWith(
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$remainingTokens개',
              style: context.heading3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                '구독중',
                style: context.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right,
              color: Colors.white.withValues(alpha: 0.8),
              size: 18,
            ),
          ],
        ),
      ],
    );
  }

  /// 비구독자 UI - 토큰 게이지바 표시
  Widget _buildTokenContent(BuildContext context, TokenBalance? balance) {
    final remainingTokens = balance?.remainingTokens ?? 0;
    final hasUnlimited = balance?.hasUnlimitedAccess ?? false;
    const maxTokens = 100; // 일반 유저 최대 토큰
    final progress = (remainingTokens / maxTokens).clamp(0.0, 1.0);

    if (hasUnlimited) {
      return Row(
        children: [
          const Icon(Icons.all_inclusive, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Text(
            '무제한',
            style: context.heading3.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Icon(
            Icons.chevron_right,
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 게이지바
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 8,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
        const SizedBox(height: 10),
        // 하단: 남은 토큰 + 충전하기
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '$remainingTokens / $maxTokens 남음',
              style: context.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Row(
              children: [
                Text(
                  '충전하기',
                  style: context.labelSmall.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right,
                  color: Colors.white.withValues(alpha: 0.8),
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

}
