/// 커리어 로드맵 위젯
///
/// Part 3: 커리어 로드맵
/// - 추천 직업군 (1순위, 2순위 with reasons)
/// - 추천 업무 환경 (Best/Worst)
/// - 주의해야 할 함정 & 보완점
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/components/app_card.dart';
import '../../domain/models/sipseong_talent.dart';

class CareerRoadmapWidget extends StatelessWidget {
  final SipseongTalent primaryTalent; // TOP 1 재능 기반
  final List<SipseongTalent> allTalents; // 모든 재능 (보완 용도)

  const CareerRoadmapWidget({
    super.key,
    required this.primaryTalent,
    required this.allTalents,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 제목
          Text(
            '커리어 로드맵',
            style: context.heading2.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '당신의 재능에 맞는 직업과 환경을 추천합니다',
            style: context.bodySmall.copyWith(
              height: 1.5,
              color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // 1순위 직업군
          _buildCareerSection(context,
            isDark: isDark,
            rank: 1,
            careers: primaryTalent.primaryCareers,
            reason: primaryTalent.careerReason,
          ).animate().fadeIn(delay: 0.ms, duration: 400.ms),
          const SizedBox(height: 16),

          // 2순위 직업군
          _buildCareerSection(context,
            isDark: isDark,
            rank: 2,
            careers: primaryTalent.secondaryCareers,
            reason: '${primaryTalent.name} 재능의 연관 분야로, 주 재능을 보완할 수 있는 선택지입니다.',
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 24),

          // 추천 업무 환경
          _buildEnvironmentSection(context, isDark)
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms),
          const SizedBox(height: 24),

          // 주의사항 & 보완점
          _buildCautionSection(context, isDark)
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildCareerSection(BuildContext context, {
    required bool isDark,
    required int rank,
    required List<String> careers,
    required String reason,
  }) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: rank == 1
                      ? DSColors.accent.withValues(alpha: 0.1)
                      : DSColors.border.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: rank == 1 ? DSColors.accent : DSColors.textTertiary,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  '$rank순위 직업군',
                  style: context.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: rank == 1 ? DSColors.accent : DSColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                rank == 1 ? '🎯' : '✨',
                style: context.heading2,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 직업 목록
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: careers.map((career) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark ? DSColors.border : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: rank == 1
                        ? DSColors.accent.withValues(alpha: 0.3)
                        : DSColors.textTertiary,
                    width: 1,
                  ),
                ),
                child: Text(
                  career,
                  style: context.bodySmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // 추천 이유
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: rank == 1
                  ? DSColors.accent.withValues(alpha: 0.05)
                  : (isDark ? DSColors.border : Colors.white),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '💡',
                  style: context.labelMedium,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    reason,
                    style: context.bodySmall.copyWith(
                      height: 1.5,
                      color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnvironmentSection(BuildContext context, bool isDark) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '🏢',
                style: context.displaySmall,
              ),
              SizedBox(width: 12),
              Text(
                '추천 업무 환경',
                style: context.heading3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Best 환경
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.green.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Best',
                            style: context.labelMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.green[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  primaryTalent.bestEnvironment,
                  style: context.bodySmall.copyWith(
                    height: 1.6,
                    color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Worst 환경
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.red.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.cancel,
                            color: Colors.red,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Worst',
                            style: context.labelMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: Colors.red[700],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  primaryTalent.worstEnvironment,
                  style: context.bodySmall.copyWith(
                    height: 1.6,
                    color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCautionSection(BuildContext context, bool isDark) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '⚠️',
                style: context.displaySmall,
              ),
              SizedBox(width: 12),
              Text(
                '주의사항 & 보완점',
                style: context.heading3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 주의해야 할 함정
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DSColors.warning.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: DSColors.warning.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '주의해야 할 함정',
                  style: context.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: DSColors.warning,
                  ),
                ),
                const SizedBox(height: 12),
                ...primaryTalent.pitfalls.map((pitfall) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '•',
                            style: context.labelMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: DSColors.warning,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              pitfall,
                              style: context.bodySmall.copyWith(
                                height: 1.5,
                                color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 보완할 점
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: DSColors.accent.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: DSColors.accent.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '보완할 점',
                  style: context.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: DSColors.accent,
                  ),
                ),
                const SizedBox(height: 12),
                ...primaryTalent.complements.map((complement) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✓',
                            style: context.labelMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: DSColors.accent,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              complement,
                              style: context.bodySmall.copyWith(
                                height: 1.5,
                                color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
