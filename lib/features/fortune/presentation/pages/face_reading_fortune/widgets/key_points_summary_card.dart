import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../domain/models/face_reading_result_v2.dart';

/// 핵심 포인트 요약 카드
/// 관상 분석의 가장 중요한 3가지 인사이트를 친근한 말투로 보여줍니다.
/// 기본적으로 펼쳐진 상태로 표시됩니다.
class KeyPointsSummaryCard extends StatelessWidget {
  /// 우선순위 인사이트 목록
  final List<PriorityInsight> insights;

  /// 다크모드 여부
  final bool isDark;

  /// 사용자 성별 (콘텐츠 차별화)
  final String? gender;

  const KeyPointsSummaryCard({
    super.key,
    required this.insights,
    required this.isDark,
    this.gender,
  });

  @override
  Widget build(BuildContext context) {
    if (insights.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DSColors.accent.withValues(alpha: 0.08),
            DSColors.accentTertiary.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: DSColors.accent.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      DSColors.accent.withValues(alpha: 0.15),
                      DSColors.accentTertiary.withValues(alpha: 0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: DSColors.accent,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '오늘의 관상 핵심 포인트',
                      style: context.heading2.copyWith(
                        color: DSColors.textPrimary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getSubtitleByGender(),
                      style: context.labelSmall.copyWith(
                        color: DSColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 핵심 인사이트 카드들
          ...insights.take(3).toList().asMap().entries.map((entry) {
            final index = entry.key;
            final insight = entry.value;
            return Padding(
              padding: EdgeInsets.only(bottom: index < 2 ? 12 : 0),
              child: _KeyPointCard(
                insight: insight,
                index: index,
                isDark: isDark,
              ),
            );
          }),
        ],
      ),
    ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.1, end: 0);
  }

  String _getSubtitleByGender() {
    if (gender == 'female') {
      return '당신만을 위한 맞춤 분석이에요';
    } else if (gender == 'male') {
      return '오늘 당신의 운세 하이라이트예요';
    }
    return '가장 중요한 포인트만 모았어요';
  }
}

/// 개별 핵심 포인트 카드
class _KeyPointCard extends StatelessWidget {
  final PriorityInsight insight;
  final int index;
  final bool isDark;

  const _KeyPointCard({
    required this.insight,
    required this.index,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColorByPriority(insight.priority);
    final icon = _getIconByCategory(insight.category);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark
            ? DSColors.surfaceDark.withValues(alpha: 0.5)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 아이콘 + 번호
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(icon, color: color, size: 22),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: context.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // 콘텐츠
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 제목
                Text(
                  insight.title,
                  style: context.bodyLarge.copyWith(
                    color: DSColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 6),

                // 설명 (친근한 말투)
                Text(
                  insight.description,
                  style: context.bodyMedium.copyWith(
                    color: DSColors.textSecondary,
                    height: 1.5,
                  ),
                ),

                // 점수 표시 (있는 경우)
                if (insight.score != null) ...[
                  const SizedBox(height: 10),
                  _buildScoreIndicator(context, insight.score!, color),
                ],
              ],
            ),
          ),
        ],
      ),
    ).animate(delay: Duration(milliseconds: 100 * index))
        .fadeIn(duration: 400.ms)
        .slideX(begin: 0.1, end: 0);
  }

  Widget _buildScoreIndicator(BuildContext context, int score, Color color) {
    return Row(
      children: [
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 6,
              backgroundColor: color.withValues(alpha: 0.1),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$score점',
          style: context.labelSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getColorByPriority(int priority) {
    switch (priority) {
      case 1:
        return DSColors.accentTertiary; // Gold for highest priority
      case 2:
        return DSColors.accent;
      case 3:
        return DSColors.success;
      default:
        return DSColors.textSecondary;
    }
  }

  IconData _getIconByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'wealth':
      case '재물':
        return Icons.monetization_on;
      case 'love':
      case '연애':
      case '결혼':
        return Icons.favorite;
      case 'career':
      case '직업':
        return Icons.work;
      case 'health':
      case '건강':
        return Icons.health_and_safety;
      case 'relationship':
      case '인간관계':
        return Icons.people;
      case 'personality':
      case '성격':
        return Icons.psychology;
      case 'first_impression':
      case '첫인상':
        return Icons.visibility;
      case 'beauty':
      case '매력':
        return Icons.auto_awesome;
      default:
        return Icons.star;
    }
  }
}
