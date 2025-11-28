import 'package:flutter/material.dart';
import 'package:fortune/core/theme/toss_theme.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/components/app_card.dart';
import 'package:fortune/domain/entities/fortune.dart';
import '../compatibility_utils.dart';

class TraditionalCompatibilityCard extends StatelessWidget {
  final Fortune fortune;

  const TraditionalCompatibilityCard({
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
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.brightness_5,
                  color: Color(0xFF8B5CF6),
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                '전통 궁합',
                style: TossTheme.heading4.copyWith(
                  color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // 띠 궁합
          if (fortune.metadata?['zodiac_animal'] != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '띠 궁합',
                        style: TossTheme.caption.copyWith(
                          color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${fortune.metadata!['zodiac_animal']['person1']} × ${fortune.metadata!['zodiac_animal']['person2']}',
                        style: TossTheme.body2.copyWith(
                          color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: CompatibilityUtils.getScoreColor(fortune.metadata!['zodiac_animal']['score'] / 100).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${fortune.metadata!['zodiac_animal']['score']}점',
                    style: TossTheme.caption.copyWith(
                      color: CompatibilityUtils.getScoreColor(fortune.metadata!['zodiac_animal']['score'] / 100),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              fortune.metadata!['zodiac_animal']['message'],
              style: TossTheme.body2.copyWith(
                color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                height: 1.5,
              ),
            ),
          ],

          // 별자리 궁합
          if (fortune.metadata?['star_sign'] != null) ...[
            SizedBox(height: 16),
            Divider(color: isDark ? TossDesignSystem.grayDark600 : TossTheme.borderGray200),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '별자리 궁합',
                        style: TossTheme.caption.copyWith(
                          color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '${fortune.metadata!['star_sign']['person1']} × ${fortune.metadata!['star_sign']['person2']}',
                        style: TossTheme.body2.copyWith(
                          color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: CompatibilityUtils.getScoreColor(fortune.metadata!['star_sign']['score'] / 100).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${fortune.metadata!['star_sign']['score']}점',
                    style: TossTheme.caption.copyWith(
                      color: CompatibilityUtils.getScoreColor(fortune.metadata!['star_sign']['score'] / 100),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              fortune.metadata!['star_sign']['message'],
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
