/// 성장 타임라인 위젯
///
/// Part 4: 평생 성장 가이드
/// - 성장을 도와줄 행운의 요소
/// - 대운(大運) 기반 시기 분석
library;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/components/app_card.dart';
import '../../domain/models/sipseong_talent.dart';

class GrowthTimelineWidget extends StatelessWidget {
  final SipseongTalent primaryTalent; // TOP 1 재능
  final List<Map<String, dynamic>> daeunList; // 대운 리스트
  final int currentAge; // 현재 나이

  const GrowthTimelineWidget({
    super.key,
    required this.primaryTalent,
    required this.daeunList,
    required this.currentAge,
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
            '평생 성장 가이드',
            style: context.heading2.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '대운(大運)으로 보는 당신의 생애 주기와 성장 방향',
            style: context.bodySmall.copyWith(
              height: 1.5,
              color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
            ),
          ),
          const SizedBox(height: 24),

          // 행운의 요소
          _buildLuckyElementsSection(context, isDark)
              .animate()
              .fadeIn(delay: 0.ms, duration: 400.ms),
          const SizedBox(height: 24),

          // 성장 조언
          _buildGrowthAdviceSection(context, isDark)
              .animate()
              .fadeIn(delay: 100.ms, duration: 400.ms),
          const SizedBox(height: 24),

          // 대운 타임라인
          _buildDaeunTimeline(context, isDark)
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildLuckyElementsSection(BuildContext context, bool isDark) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '🍀',
                style: context.displaySmall,
              ),
              SizedBox(width: 12),
              Text(
                '성장을 도와줄 행운의 요소',
                style: context.heading3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: primaryTalent.luckyElements.map((element) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      DSColors.accent.withValues(alpha: 0.1),
                      DSColors.accentDark.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: DSColors.accent.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.star,
                      color: DSColors.accent,
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      element,
                      style: context.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthAdviceSection(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DSColors.accent.withValues(alpha: 0.1),
            DSColors.accentDark.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DSColors.accent.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '💡',
            style: context.displaySmall,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '성장 조언',
                  style: context.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  primaryTalent.growthAdvice,
                  style: context.bodySmall.copyWith(
                    height: 1.6,
                    color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDaeunTimeline(BuildContext context, bool isDark) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '📅',
                style: context.displaySmall,
              ),
              SizedBox(width: 12),
              Text(
                '대운(大運) 타임라인',
                style: context.heading3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            '10년 주기로 변화하는 인생의 흐름',
            style: context.bodySmall.copyWith(
              color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
            ),
          ),
          const SizedBox(height: 16),

          // 대운 리스트
          ...daeunList.asMap().entries.map((entry) {
            final index = entry.key;
            final daeun = entry.value;
            final age = daeun['age'] as int;
            final isActive = daeun['isActive'] as bool;
            final gan = daeun['gan'] as String;
            final zhi = daeun['zhi'] as String;
            final wuxing = daeun['wuxing'] as String;

            return Padding(
              padding: EdgeInsets.only(bottom: index < daeunList.length - 1 ? 12 : 0),
              child: _buildDaeunCard(context,
                isDark: isDark,
                age: age,
                isActive: isActive,
                gan: gan,
                zhi: zhi,
                wuxing: wuxing,
              ),
            ).animate().fadeIn(delay: (100 * index).ms, duration: 400.ms);
          }),
        ],
      ),
    );
  }

  Widget _buildDaeunCard(BuildContext context, {
    required bool isDark,
    required int age,
    required bool isActive,
    required String gan,
    required String zhi,
    required String wuxing,
  }) {
    // 오행별 색상
    final wuxingColor = _getWuxingColor(wuxing);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isActive
            ? wuxingColor.withValues(alpha: 0.1)
            : (isDark ? DSColors.border : Colors.white),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive ? wuxingColor : Colors.transparent,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // 나이 & 상태
          Container(
            width: 70,
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: isActive ? wuxingColor.withValues(alpha: 0.2) : DSColors.border,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  '$age세',
                  style: context.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: isActive ? wuxingColor : DSColors.textSecondary,
                  ),
                ),
                if (isActive)
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: wuxingColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '현재',
                      style: context.labelSmall.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // 대운 정보
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: wuxingColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$wuxing 운',
                        style: context.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: wuxingColor,
                        ),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '$gan$zhi',
                      style: context.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? DSColors.textPrimary : DSColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  _getDaeunDescription(wuxing, isActive),
                  style: context.labelMedium.copyWith(
                    height: 1.4,
                    color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // 화살표
          Icon(
            isActive ? Icons.arrow_forward : Icons.chevron_right,
            color: isActive ? wuxingColor : DSColors.textTertiary,
            size: isActive ? 24 : 20,
          ),
        ],
      ),
    );
  }

  Color _getWuxingColor(String wuxing) {
    switch (wuxing) {
      case '목':
        return const Color(0xFF4CAF50);
      case '화':
        return const Color(0xFFF44336);
      case '토':
        return const Color(0xFFFF9800);
      case '금':
        return const Color(0xFF9E9E9E);
      case '수':
        return const Color(0xFF2196F3);
      default:
        return DSColors.textTertiary;
    }
  }

  String _getDaeunDescription(String wuxing, bool isActive) {
    if (isActive) {
      return _getCurrentDaeunDescription(wuxing);
    } else {
      return _getFutureDaeunDescription(wuxing);
    }
  }

  String _getCurrentDaeunDescription(String wuxing) {
    switch (wuxing) {
      case '목':
        return '현재는 성장과 발전의 시기입니다. 새로운 도전과 학습이 중요합니다.';
      case '화':
        return '현재는 열정과 활동의 시기입니다. 적극적으로 기회를 포착하세요.';
      case '토':
        return '현재는 안정과 축적의 시기입니다. 기반을 다지는 데 집중하세요.';
      case '금':
        return '현재는 결단과 수확의 시기입니다. 결과를 맺고 정리하세요.';
      case '수':
        return '현재는 지혜와 유연성의 시기입니다. 흐름에 맞춰 적응하세요.';
      default:
        return '현재 대운을 잘 활용하세요.';
    }
  }

  String _getFutureDaeunDescription(String wuxing) {
    switch (wuxing) {
      case '목':
        return '성장과 확장의 기회가 찾아올 시기입니다.';
      case '화':
        return '열정을 발산하고 성과를 내는 시기가 될 것입니다.';
      case '토':
        return '안정적으로 기반을 다지는 시기가 될 것입니다.';
      case '금':
        return '결단력을 발휘하고 성과를 거두는 시기가 될 것입니다.';
      case '수':
        return '지혜와 통찰력이 빛나는 시기가 될 것입니다.';
      default:
        return '이 대운을 준비하세요.';
    }
  }
}

/// 간단한 대운 요약 위젯 (헤더용)
class DaeunSummaryWidget extends StatelessWidget {
  final List<Map<String, dynamic>> daeunList;

  const DaeunSummaryWidget({
    super.key,
    required this.daeunList,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeDaeun = daeunList.firstWhere(
      (d) => d['isActive'] == true,
      orElse: () => daeunList.first,
    );

    final age = activeDaeun['age'] as int;
    final wuxing = activeDaeun['wuxing'] as String;
    final gan = activeDaeun['gan'] as String;
    final zhi = activeDaeun['zhi'] as String;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DSColors.accent.withValues(alpha: 0.1),
            DSColors.accentDark.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: DSColors.accent.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Text(
            '📅',
            style: context.displayMedium,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '현재 대운',
                  style: context.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? DSColors.textSecondary : DSColors.textSecondary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '$age세 · $gan$zhi ($wuxing 운)',
                  style: context.heading3.copyWith(
                    fontWeight: FontWeight.w700,
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
}
