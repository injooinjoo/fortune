import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../glassmorphism/glass_container.dart';
import '../glassmorphism/glass_effects.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/providers/token_provider.dart';

class TokenBalance extends ConsumerWidget {
  final bool compact;
  final bool showHistory;
  final VoidCallback? onTap;

  const TokenBalance({
    Key? key,
    this.compact = false,
    this.showHistory = false,
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
                  : _buildFull(context, isUnlimited, tokenCount),
            );
          },
        );
      },
    );
  }

  Widget _buildCompact(BuildContext context, bool isUnlimited, int tokenCount) {
    final theme = Theme.of(context);

    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      borderRadius: BorderRadius.circular(20),
      blur: 10,
      gradient: isUnlimited
          ? GlassEffects.multiColorGradient(
              colors: [
                const Color(0xFF7C3AED).withValues(alpha: 0.2),
                const Color(0xFF3B82F6).withValues(alpha: 0.2),
              ],
            )
          : GlassEffects.multiColorGradient(
              colors: [
                const Color(0xFFF59E0B).withValues(alpha: 0.2),
                const Color(0xFFEF4444).withValues(alpha: 0.2),
              ],
            ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isUnlimited ? Icons.all_inclusive : Icons.stars_rounded,
            size: 16,
            color: isUnlimited
                ? const Color(0xFF7C3AED)
                : const Color(0xFFF59E0B),
          ),
          const SizedBox(width: 4),
          Text(
            isUnlimited ? '무제한' : '$tokenCount',
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isUnlimited
                  ? const Color(0xFF7C3AED)
                  : const Color(0xFFF59E0B),
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
          ? const Color(0xFF7C3AED)
          : const Color(0xFFF59E0B),
      borderRadius: BorderRadius.circular(24),
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '토큰 잔액',
                  style: theme.textTheme.bodySmall,
                ),
                if (showHistory)
                  TextButton(
                    onPressed: () => _showTokenHistory(context),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      '사용 내역',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  isUnlimited ? Icons.all_inclusive : Icons.stars_rounded,
                  size: 32,
                  color: isUnlimited
                      ? const Color(0xFF7C3AED)
                      : const Color(0xFFF59E0B),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isUnlimited ? '무제한 이용권' : '$tokenCount 토큰',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isUnlimited
                            ? const Color(0xFF7C3AED)
                            : const Color(0xFFF59E0B),
                      ),
                    ),
                    if (!isUnlimited && tokenCount < 10)
                      Text(
                        '토큰이 부족합니다',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                  ],
                ),
              ],
            ),
            if (!isUnlimited) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.push('/payment/tokens'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                  ),
                  child: const Text('토큰 구매'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSkeleton(BuildContext context) {
    return GlassContainer(
      padding: compact
          ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
          : const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(compact ? 20 : 24),
      blur: 10,
      child: compact
          ? const SizedBox(width: 60, height: 20)
          : const SizedBox(width: double.infinity, height: 80),
    );
  }

  Widget _buildError(BuildContext context) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      borderRadius: BorderRadius.circular(20),
      blur: 10,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.error_outline, size: 16, color: Colors.red),
          SizedBox(width: 4),
          Text('오류', style: TextStyle(color: Colors.red)),
        ],
      ),
    );
  }

  void _showTokenHistory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const TokenHistoryModal(),
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
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return GlassContainer(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
          blur: 30,
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  '토큰 사용 내역',
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              Expanded(
                child: tokenHistoryAsync.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  error: (error, _) => Center(
                    child: Text('오류가 발생했습니다: $error'),
                  ),
                  data: (history) {
                    if (history.isEmpty) {
                      return const Center(
                        child: Text('사용 내역이 없습니다'),
                      );
                    }

                    return ListView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final item = history[index];
                        final isAdd = item.amount > 0;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlassContainer(
                            padding: const EdgeInsets.all(16),
                            borderRadius: BorderRadius.circular(16),
                            blur: 10,
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isAdd
                                        ? Colors.green.withValues(alpha: 0.2)
                                        : Colors.red.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isAdd
                                        ? Icons.add_circle_outline
                                        : Icons.remove_circle_outline,
                                    color: isAdd ? Colors.green : Colors.red,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.description,
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        _formatDate(item.createdAt),
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  '${isAdd ? '+' : ''}${item.amount}',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    color: isAdd ? Colors.green : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
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