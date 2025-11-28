import 'package:flutter/material.dart';
import 'package:fortune/core/theme/toss_theme.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/components/app_card.dart';
import 'package:fortune/domain/entities/fortune.dart';

class EmotionalCompatibilityCard extends StatelessWidget {
  final Fortune fortune;

  const EmotionalCompatibilityCard({
    super.key,
    required this.fortune,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF06B6D4).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.spa,
                  color: Color(0xFF06B6D4),
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                '감성 궁합',
                style: TossTheme.heading4.copyWith(
                  color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // 계절 궁합
          if (fortune.metadata?['season'] != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '계절 궁합',
                      style: TossTheme.caption.copyWith(
                        color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${fortune.metadata!['season']['person1']} × ${fortune.metadata!['season']['person2']}',
                      style: TossTheme.body2.copyWith(
                        color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              fortune.metadata!['season']['message'],
              style: TossTheme.body2.copyWith(
                color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                height: 1.5,
              ),
            ),
          ],

          // 나이차 분석
          if (fortune.metadata?['age_difference'] != null) ...[
            SizedBox(height: 16),
            Divider(color: isDark ? TossDesignSystem.grayDark600 : TossTheme.borderGray200),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '나이 차이',
                      style: TossTheme.caption.copyWith(
                        color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      fortune.metadata!['age_difference']['years'] == 0
                          ? '동갑'
                          : '${fortune.metadata!['age_difference']['years'].abs()}살 차이',
                      style: TossTheme.body2.copyWith(
                        color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              fortune.metadata!['age_difference']['message'],
              style: TossTheme.body2.copyWith(
                color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
