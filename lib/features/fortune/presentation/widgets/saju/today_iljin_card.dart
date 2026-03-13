import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../shared/components/cards/fortune_cards.dart';
import '../../../domain/models/saju/iljin_calculator.dart';

/// 오늘의 일진(日辰) 카드 위젯
///
/// 오늘 날짜의 일주(日柱)를 표시하고,
/// 사용자의 일간과 비교하여 길일/흉일을 판별합니다.
class TodayIljinCard extends StatelessWidget {
  final Map<String, dynamic> sajuData;

  const TodayIljinCard({
    super.key,
    required this.sajuData,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final iljin = IljinCalculator.today;
    final myDayStem = _getMyDayStem();
    final compatibility = myDayStem.isNotEmpty
        ? IljinCalculator.checkCompatibility(myDayStem, iljin)
        : null;

    return FortuneCardSurface(
      backgroundColor:
          isDark ? context.colors.backgroundSecondary : context.colors.surface,
      showBorder: true,
      borderColor: isDark ? DSColors.border : DSColors.borderDark,
      padding: const EdgeInsets.all(DSSpacing.md),
      child: Column(
        children: [
          // 상단: 날짜 + 일진
          Row(
            children: [
              // 일진 필러
              Container(
                width: 56,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? context.colors.surface.withValues(alpha: 0.1)
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(DSRadius.sm),
                  border: Border.all(
                    color: isDark ? DSColors.border : DSColors.borderDark,
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      iljin.stemHanja,
                      style: context.heading3.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: SajuColors.getStemColor(
                          iljin.stem,
                          isDark: isDark,
                        ),
                      ),
                    ),
                    Container(
                      width: 32,
                      height: 1,
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      color: isDark
                          ? DSColors.border
                          : DSColors.borderDark.withValues(alpha: 0.3),
                    ),
                    Text(
                      iljin.branchHanja,
                      style: context.heading3.copyWith(
                        fontWeight: FontWeight.w900,
                        fontSize: 22,
                        color: SajuColors.getBranchColor(
                          iljin.branch,
                          isDark: isDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: DSSpacing.md),

              // 날짜 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('yyyy년 M월 d일 (E)', 'ko').format(iljin.date),
                      style: context.labelMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: context.colors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${iljin.dayPillar} (${iljin.dayPillarHanja})',
                          style: context.bodySmall.copyWith(
                            color: context.colors.textSecondary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _buildAnimalChip(context, iljin, isDark),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${iljin.stemElement}(천간) · ${iljin.branchElement}(지지)',
                      style: context.labelTiny.copyWith(
                        color: context.colors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // 상성 분석
          if (compatibility != null) ...[
            const SizedBox(height: DSSpacing.md),
            _buildCompatibility(context, compatibility, isDark),
          ],
        ],
      ),
    );
  }

  Widget _buildAnimalChip(
    BuildContext context,
    IljinInfo iljin,
    bool isDark,
  ) {
    return FortuneCardBadge(
      label: '${iljin.animal}띠',
      backgroundColor: SajuColors.getBranchColor(iljin.branch, isDark: isDark)
          .withValues(alpha: 0.15),
      foregroundColor: SajuColors.getBranchColor(iljin.branch, isDark: isDark),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    );
  }

  Widget _buildCompatibility(
    BuildContext context,
    IljinCompatibility compatibility,
    bool isDark,
  ) {
    final fortuneColor = _getFortuneColor(compatibility.fortune);

    return Container(
      padding: const EdgeInsets.all(DSSpacing.sm),
      decoration: BoxDecoration(
        color: fortuneColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(DSRadius.sm),
        border: Border.all(
          color: fortuneColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // 길흉 배지
          FortuneCardBadge(
            label: compatibility.fortune,
            backgroundColor: fortuneColor.withValues(alpha: 0.2),
            foregroundColor: fortuneColor,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          ),
          const SizedBox(width: DSSpacing.sm),

          // 관계 + 설명
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  compatibility.relationship,
                  style: context.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colors.textPrimary,
                  ),
                ),
                Text(
                  compatibility.description,
                  style: context.labelTiny.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getFortuneColor(String fortune) {
    switch (fortune) {
      case '길':
        return const Color(0xFF10B981);
      case '흉':
        return const Color(0xFFEF4444);
      default:
        return const Color(0xFFF59E0B);
    }
  }

  String _getMyDayStem() {
    final myungsik = sajuData['myungsik'] as Map<String, dynamic>?;
    if (myungsik != null) {
      return myungsik['daySky'] as String? ?? '';
    }
    final dayData = sajuData['day'] as Map<String, dynamic>?;
    final cheongan = dayData?['cheongan'] as Map<String, dynamic>?;
    return cheongan?['char'] as String? ?? '';
  }
}
