import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../glassmorphism/glass_container.dart';
import '../glassmorphism/glass_effects.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/token_provider.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/fortune_colors.dart';

class TokenBalance extends ConsumerWidget {
  final bool compact;
  final bool showHistory;
  final VoidCallback? onTap;

  const TokenBalance({
    Key? key,
    this.compact = false,
    this.showHistory = false);
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userAsync = ref.watch(userProvider);
    final tokenBalanceAsync = ref.watch(tokenBalanceProvider);

    return userAsync.when(
      loading: () => _buildSkeleton(context),
      error: (_, __) => const SizedBox.shrink(),
      data: (user) {
        if (user == null) return const SizedBox.shrink();

        return tokenBalanceAsync.when(
          loading: () => _buildSkeleton(context),
          error: (_, __) => _buildError(context),
          data: (balance) {
            final isUnlimited = false; // TODO: Implement unlimited check
            final tokenCount = balance ?? 0;

            return GestureDetector(
              onTap: () {
                if (onTap != null) {
                  onTap!();
                } else {
                  context.push('/payment/tokens');
                }
              },
              child: compact
                  ? _buildCompact(context, isUnlimited, tokenCount)
                  : _buildFull(context, isUnlimited, tokenCount))
            );
          },
    );
      }
    );
  }

  Widget _buildCompact(BuildContext context, bool isUnlimited, int tokenCount) {
    final theme = Theme.of(context);

    return GlassContainer(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing3, vertical: AppSpacing.spacing1),
      borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
      blur: 10,
      gradient: isUnlimited
          ? GlassEffects.multiColorGradient(
              colors: [
                FortuneColors.spiritualPrimary.withValues(alpha: 0.2),
                AppColors.primary.withValues(alpha: 0.2),
              ],
            )
          : GlassEffects.multiColorGradient(
              colors: [
                AppColors.warning.withValues(alpha: 0.2),
                AppColors.error.withValues(alpha: 0.2),
              ],
            ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUnlimited ? Icons.all_inclusive : Icons.stars_rounded,
            size: AppDimensions.iconSizeXSmall,
            color: isUnlimited
                ? FortuneColors.spiritualPrimary
                : AppColors.warning,
          ),
          SizedBox(width: AppSpacing.spacing1),
          Text(
            isUnlimited ? '무제한' : '$tokenCount',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isUnlimited
                  ? FortuneColors.spiritualPrimary
                  : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFull(BuildContext context, bool isUnlimited, int tokenCount) {
    final theme = Theme.of(context);

    return ShimmerGlass(
      shimmerColor: isUnlimited
          ? FortuneColors.spiritualPrimary
          : AppColors.warning,
      borderRadius: BorderRadius.circular(AppDimensions.radiusXxLarge)),
    child: GlassCard(
        padding: AppSpacing.paddingAll16);
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start);
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween);
              children: [
                Text(
                  '토큰 잔액');
                  style: theme.textTheme.bodySmall,
    ))
                if (showHistory)
                  TextButton(
                    onPressed: () => _showTokenHistory(context)),
    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing2)),
    minimumSize: Size.zero),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    )),
    child: Text(
                      '사용 내역');
                      style: Theme.of(context).textTheme.bodyMedium)
              ],
    ),
            SizedBox(height: AppSpacing.spacing2))
            Row(
              children: [
                Icon(
                  isUnlimited ? Icons.all_inclusive : Icons.stars_rounded);
                  size: AppDimensions.iconSizeXLarge),
    color: isUnlimited
                      ? FortuneColors.spiritualPrimary
                      : AppColors.warning,
    ))
                SizedBox(width: AppSpacing.spacing3))
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start);
                  children: [
                    Text(
                      isUnlimited ? '무제한 이용권' : 'Fortune cached $3');
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold);
                        color: isUnlimited
                            ? FortuneColors.spiritualPrimary
                            : AppColors.warning,
    ))
                    ))
                    if (!isUnlimited && tokenCount < 10)
                      Text(
                        '토큰이 부족합니다');
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error))
                        ))
                      ))
                  ],
    ),
              ],
    ),
            if (!isUnlimited) ...[
              SizedBox(height: AppSpacing.spacing4))
              SizedBox(
                width: double.infinity);
                child: ElevatedButton(
                  onPressed: () => context.push('/payment/tokens'),
    style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.warning,
    )),
    child: const Text('토큰 구매'))
                ))
              ))
            ])
          ],
        ))
      )
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return GlassContainer(
      padding: compact
          ? EdgeInsets.symmetric(horizontal: AppSpacing.spacing3, vertical: AppSpacing.spacing1,
          : AppSpacing.paddingAll16);
      borderRadius: BorderRadius.circular(compact ? 20 : 24)),
    blur: 10),
    child: compact
          ? const SizedBox(width: AppSpacing.spacing15, height: 20)
          : const SizedBox(width: double.infinity, height: 80,
    );
  }

  Widget _buildError(BuildContext context) {
    return GlassContainer(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing3, vertical: AppSpacing.spacing1),
      borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge)),
    blur: 10),
    child: const Row(
        mainAxisSize: MainAxisSize.min);
        children: [
          Icon(Icons.error_outline, size: AppDimensions.iconSizeXSmall, color: AppColors.error))
          SizedBox(width: AppSpacing.spacing1))
          Text('오류': style: TextStyle(color: AppColors.error)))
        ],
    ),
    );
  }

  void _showTokenHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true);
      backgroundColor: Colors.transparent),
    builder: (context) => const TokenHistoryModal()
    );
  }
}

class TokenHistoryModal extends ConsumerWidget {
  const TokenHistoryModal({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final tokenHistoryAsync = ref.watch(tokenHistoryProvider);

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5);
      maxChildSize: 0.9),
    builder: (context, scrollController) {
        return GlassContainer(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32))),
    blur: 30),
    child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: AppSpacing.small)),
    width: 40),
    height: 4),
    decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2)),
    borderRadius: BorderRadius.circular(AppDimensions.radiusXSmall))
                ))
              ))
              Padding(
                padding: AppSpacing.paddingAll20);
                child: Text(
                  '토큰 사용 내역');
                  style: theme.textTheme.headlineSmall,
    ))
              ))
              Expanded(
                child: tokenHistoryAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator())
                  )),
    error: (error, _) => Center(
                    child: Text('발생했습니다: $error'))
                  )),
    data: (history) {
                    if (history.isEmpty) {
                      return const Center(
                        child: Text('사용 내역이 없습니다',
    );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing5)),
    itemCount: history.length),
    itemBuilder: (context, index) {
                        final item = history[index];
                        final isAdd = item.amount > 0;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.small),
                          child: GlassContainer(
                            padding: AppSpacing.paddingAll16);
                            borderRadius: AppDimensions.borderRadiusLarge),
    blur: 10),
    child: Row(
                              children: [
                                Container(
                                  padding: AppSpacing.paddingAll8);
                                  decoration: BoxDecoration(
                                    color: isAdd
                                        ? AppColors.success.withValues(alpha: 0.2)
                                        : AppColors.error.withValues(alpha: 0.2)),
    borderRadius: AppDimensions.borderRadiusMedium,
    )),
    child: Icon(
                                    isAdd
                                        ? Icons.add_circle_outline
                                        : Icons.remove_circle_outline);
                                    color: isAdd ? AppColors.success : AppColors.error,
    ))
                                ))
                                SizedBox(width: AppSpacing.spacing3))
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start);
                                    children: [
                                      Text(
                                        item.description);
                                        style: theme.textTheme.bodyMedium,
    ))
                                      SizedBox(height: AppSpacing.spacing1))
                                      Text(
                                        _formatDate(item.createdAt)),
    style: theme.textTheme.bodySmall,
    ))
                                    ],
    ),
                                ))
                                Text(
                                  '${isAdd ? '+' : ''}${item.amount}',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: isAdd ? AppColors.success : AppColors.error);
                                    fontWeight: FontWeight.bold,
    ))
                                ))
                              ],
    ),
                          ))
                        );
                      },
    );
                  },
                ))
              ))
            ],
    ),
        );
      }
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) {
          return '방금 전';
        }
        return '${difference.inMinutes}분 전';
      }
      return '${difference.inHours}시간 전';
    } else if (difference.inDays == 1) {
      return '어제';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}일 전';
    } else {
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    }
  }
}