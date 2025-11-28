import 'package:flutter/material.dart';
import 'package:fortune/core/theme/toss_theme.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/components/app_card.dart';
import 'package:fortune/domain/entities/fortune.dart';

class NumericCompatibilityCard extends StatelessWidget {
  final Fortune fortune;
  final String person1Name;
  final String person2Name;

  const NumericCompatibilityCard({
    super.key,
    required this.fortune,
    required this.person1Name,
    required this.person2Name,
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
                  color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calculate,
                  color: Color(0xFFF59E0B),
                  size: 20,
                ),
              ),
              SizedBox(width: 12),
              Text(
                '숫자 궁합',
                style: TossTheme.heading4.copyWith(
                  color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          SizedBox(height: 16),

          // 이름 궁합
          if (fortune.metadata?['name_compatibility'] != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '이름 궁합',
                      style: TossTheme.caption.copyWith(
                        color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '$person1Name ♥ $person2Name',
                      style: TossTheme.body2.copyWith(
                        color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${fortune.metadata!['name_compatibility']}%',
                    style: TossTheme.heading4.copyWith(
                      color: const Color(0xFFF59E0B),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],

          // 운명수
          if (fortune.metadata?['destiny_number'] != null) ...[
            SizedBox(height: 16),
            Divider(color: isDark ? TossDesignSystem.grayDark600 : TossTheme.borderGray200),
            SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '두 사람의 운명수',
                  style: TossTheme.caption.copyWith(
                    color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
                  ),
                ),
                SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${fortune.metadata!['destiny_number']['number']}',
                          style: TossTheme.heading3.copyWith(
                            color: const Color(0xFFF59E0B),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        fortune.metadata!['destiny_number']['meaning'],
                        style: TossTheme.body2.copyWith(
                          color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
