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

    // 화면 전체를 채우고, 콘텐츠를 중앙에 배치
    return SizedBox.expand(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          DSSpacing.md,
          0,
          DSSpacing.md,
          bottomPadding + 80, // 입력창 높이만큼 하단 여백
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
                color: colors.textSecondary.withValues(alpha: 0.1),
              ),
              child: Icon(
                Icons.auto_awesome,
                size: 28,
                color: colors.textSecondary,
              ),
            ),
            const SizedBox(height: DSSpacing.sm),

            // 환영 텍스트
            Text(
              "How's your day?",
              style: typography.headingSmall.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DSSpacing.xs),

            Text(
              '인사이트, 타로, 꿈해몽 등\n다양한 서비스를 채팅으로 이용해보세요',
              style: typography.bodyLarge.copyWith(
                color: colors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DSSpacing.md),

            // 추천 칩 그리드 (시작 시 3개만 표시)
            FortuneChipGrid(
              chips: initialChips,
              onChipTap: onChipTap,
            ),
          ],
        ),
      ),
    );
  }
}
