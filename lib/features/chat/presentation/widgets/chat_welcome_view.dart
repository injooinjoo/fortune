import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../domain/models/recommendation_chip.dart';
import 'fortune_chip_grid.dart';

/// 채팅 환영 화면 (메시지가 없을 때)
class ChatWelcomeView extends StatelessWidget {
  final void Function(RecommendationChip chip) onChipTap;
  final double bottomPadding;

  const ChatWelcomeView({
    super.key,
    required this.onChipTap,
    this.bottomPadding = 0,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          DSSpacing.md,
          DSSpacing.sm,
          DSSpacing.md,
          DSSpacing.md + bottomPadding,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // AI 아바타
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.accentSecondary.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 28,
                color: colors.accentSecondary,
              ),
            ),
            const SizedBox(height: DSSpacing.sm),

            // 환영 텍스트
            Text(
              '오늘 무엇이 궁금하세요?',
              style: typography.bodyLarge.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DSSpacing.xs),

            Text(
              '운세, 타로, 꿈해몽 등\n다양한 서비스를 채팅으로 이용해보세요',
              style: typography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DSSpacing.md),

            // 추천 칩 그리드
            FortuneChipGrid(
              chips: defaultChips,
              onChipTap: onChipTap,
            ),
          ],
        ),
      ),
    );
  }
}
