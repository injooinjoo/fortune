import 'package:flutter/material.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/components/app_card.dart';
import '../../../../../../core/models/fortune_result.dart';
import '../../../../../../core/utils/fortune_text_cleaner.dart';
import '../../../../../../core/widgets/gpt_style_typing_text.dart';

class OverviewSection extends StatelessWidget {
  final FortuneResult? fortuneResult;
  final DSColorScheme colors;
  final bool enableTyping;
  final bool startTyping;
  final VoidCallback? onTypingComplete;

  const OverviewSection({
    super.key,
    required this.fortuneResult,
    required this.colors,
    this.enableTyping = false,
    this.startTyping = true,
    this.onTypingComplete,
  });

  @override
  Widget build(BuildContext context) {
    final content = FortuneTextCleaner.cleanNullable(fortuneResult?.data['content'] as String?);
    // ✅ score 우선순위: 1) fortuneResult.score 2) data['overallScore'] 3) data['overall_score'] 4) summary
    final score = fortuneResult?.score ??
        (fortuneResult?.data['overallScore'] as int?) ??
        (fortuneResult?.data['overall_score'] as int?) ??
        (fortuneResult?.summary['score'] as int?) ??
        (fortuneResult?.data['score'] as int?) ??
        50; // 기본값 50점 (0점 대신 중간값)
    final luckyItems = fortuneResult?.data['luckyItems'] as Map<String, dynamic>?;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.accent.withValues(alpha: 0.1),
            colors.accent.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '재능 발견 운세',
                        style: DSTypography.displayLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'LLM이 분석한 당신의 재능과 잠재력',
                        style: DSTypography.bodySmall.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                // 종합 점수 표시
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        colors.accent,
                        colors.accent.withValues(alpha: 0.8),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '$score점',
                        style: DSTypography.headingLarge.copyWith(
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '재능 점수',
                        style: DSTypography.labelSmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // LLM 분석 브리핑
            if (content.isNotEmpty)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          color: colors.accent,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '신령의 재능 풀이',
                          style: DSTypography.headingMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    enableTyping
                        ? GptStyleTypingText(
                            text: content,
                            style: DSTypography.bodyMedium.copyWith(
                              height: 1.7,
                              color: colors.textPrimary,
                            ),
                            showGhostText: true,
                            startTyping: startTyping,
                            onComplete: onTypingComplete,
                          )
                        : Text(
                            content,
                            style: DSTypography.bodyMedium.copyWith(
                              height: 1.7,
                              color: colors.textPrimary,
                            ),
                          ),
                  ],
                ),
              ),

            if (content.isNotEmpty) const SizedBox(height: 16),

            // 행운 아이템
            if (luckyItems != null)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.stars,
                          color: DSColors.warning,
                          size: 24,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '행운 아이템',
                          style: DSTypography.headingMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildLuckyItem('색상', luckyItems['color'] as String? ?? '', Icons.palette, colors),
                    _buildLuckyItem('숫자', '${luckyItems['number'] ?? ''}', Icons.filter_9_plus, colors),
                    _buildLuckyItem('방향', luckyItems['direction'] as String? ?? '', Icons.explore, colors),
                    _buildLuckyItem('도구', luckyItems['tool'] as String? ?? '', Icons.build_circle, colors),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLuckyItem(String label, String value, IconData icon, DSColorScheme colors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 20, color: colors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: DSTypography.labelSmall.copyWith(
                    color: colors.textSecondary,
                  ),
                ),
                Text(
                  value,
                  style: DSTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
