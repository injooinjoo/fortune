import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../../../core/components/app_card.dart';
import '../../../../domain/models/face_condition.dart';

/// 얼굴 컨디션 카드
/// 혈색, 붓기, 피로도 등 오늘의 안색 상태를 시각화합니다.
class FaceConditionCard extends StatelessWidget {
  /// 얼굴 컨디션 데이터
  final FaceCondition condition;

  /// 다크모드 여부
  final bool isDark;

  /// 이전 컨디션 (비교용, 선택적)
  final FaceCondition? previousCondition;

  /// 상세 보기 클릭 콜백
  final VoidCallback? onDetailPressed;

  /// 블러 처리 여부
  final bool isBlurred;

  /// 블러 처리된 섹션들
  final List<String>? blurredSections;

  /// 잠금 해제 요청 콜백
  final VoidCallback? onUnlockRequested;

  const FaceConditionCard({
    super.key,
    required this.condition,
    required this.isDark,
    this.previousCondition,
    this.onDetailPressed,
    this.isBlurred = false,
    this.blurredSections,
    this.onUnlockRequested,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      style: AppCardStyle.filled,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          _buildHeader(context),
          const SizedBox(height: 20),

          // 전체 점수
          _buildOverallScore(context),
          const SizedBox(height: 20),

          // 세부 지표들
          _buildConditionIndicators(context),

          // 팁 (있는 경우)
          if (condition.improvementTips.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildTips(context),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.pink.withValues(alpha: 0.15),
                Colors.orange.withValues(alpha: 0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.face_retouching_natural,
            color: Colors.pink,
            size: 24,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '오늘의 안색 컨디션',
                style: context.heading2.copyWith(
                  color: isDark
                      ? DSColors.textPrimaryDark
                      : DSColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _getConditionMessage(),
                style: context.labelSmall.copyWith(
                  color: isDark
                      ? DSColors.textSecondaryDark
                      : DSColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        if (onDetailPressed != null)
          TextButton(
            onPressed: onDetailPressed,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
            ),
            child: Text(
              '기록 보기',
              style: context.labelSmall.copyWith(
                color: Colors.pink,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  String _getConditionMessage() {
    final overallScore = condition.overallScore;
    if (overallScore >= 80) {
      return '오늘 컨디션이 정말 좋아 보여요! ✨';
    } else if (overallScore >= 60) {
      return '괜찮은 하루를 보내고 있네요';
    } else if (overallScore >= 40) {
      return '오늘은 조금 피곤해 보여요';
    } else {
      return '충분한 휴식이 필요해 보여요';
    }
  }

  Widget _buildOverallScore(BuildContext context) {
    final score = condition.overallScore;
    final color = _getScoreColor(score);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color.withValues(alpha: 0.1),
            color.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // 점수 원형
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: score / 100,
                    strokeWidth: 8,
                    backgroundColor: color.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation(color),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$score',
                        style: context.heading1.copyWith(
                          color: color,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '점',
                        style: context.labelSmall.copyWith(
                          color: color.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),

          // 상태 설명
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getScoreLabel(score),
                  style: context.heading3.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _getScoreDescription(score),
                  style: context.bodySmall.copyWith(
                    color: isDark
                        ? DSColors.textSecondaryDark
                        : DSColors.textSecondary,
                    height: 1.4,
                  ),
                ),
                // 이전 대비 변화
                if (previousCondition != null) ...[
                  const SizedBox(height: 8),
                  _buildChangeIndicator(context, score, previousCondition!.overallScore),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChangeIndicator(BuildContext context, int current, int previous) {
    final diff = current - previous;
    if (diff == 0) return const SizedBox.shrink();

    final isPositive = diff > 0;
    final color = isPositive ? DSColors.success : DSColors.error;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isPositive ? Icons.arrow_upward : Icons.arrow_downward,
          color: color,
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          '어제보다 ${diff.abs()}점 ${isPositive ? '상승' : '하락'}',
          style: context.labelSmall.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildConditionIndicators(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ConditionIndicator(
            label: '혈색',
            score: condition.complexionScore,
            icon: Icons.palette,
            color: Colors.pink,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ConditionIndicator(
            label: '붓기',
            score: 100 - condition.puffinessLevel, // 낮을수록 좋음
            icon: Icons.water_drop,
            color: Colors.blue,
            isDark: isDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ConditionIndicator(
            label: '피로도',
            score: 100 - condition.fatigueLevel, // 낮을수록 좋음
            icon: Icons.battery_charging_full,
            color: Colors.orange,
            isDark: isDark,
          ),
        ),
      ],
    );
  }

  Widget _buildTips(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lightbulb_outline, color: Colors.amber, size: 18),
              const SizedBox(width: 8),
              Text(
                '오늘의 관리 팁',
                style: context.labelLarge.copyWith(
                  color: Colors.amber.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...condition.improvementTips.take(2).map((tip) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${tip.emoji} ',
                      style: const TextStyle(fontSize: 14),
                    ),
                    Expanded(
                      child: Text(
                        tip.content,
                        style: context.bodySmall.copyWith(
                          color: isDark
                              ? DSColors.textPrimaryDark
                              : DSColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return DSColors.success;
    if (score >= 60) return Colors.pink;
    if (score >= 40) return DSColors.warning;
    return DSColors.error;
  }

  String _getScoreLabel(int score) {
    if (score >= 80) return '아주 좋음';
    if (score >= 60) return '양호';
    if (score >= 40) return '보통';
    return '관리 필요';
  }

  String _getScoreDescription(int score) {
    if (score >= 80) {
      return '피부톤이 맑고 생기가 넘쳐요. 오늘 좋은 인상을 줄 수 있어요!';
    } else if (score >= 60) {
      return '전반적으로 괜찮은 상태예요. 가벼운 스킨케어로 더 좋아질 수 있어요.';
    } else if (score >= 40) {
      return '약간 피곤해 보일 수 있어요. 충분한 수분 섭취를 권해드려요.';
    } else {
      return '피로가 얼굴에 드러나고 있어요. 충분한 휴식이 필요해요.';
    }
  }
}

/// 개별 컨디션 지표
class _ConditionIndicator extends StatelessWidget {
  final String label;
  final int score;
  final IconData icon;
  final Color color;
  final bool isDark;

  const _ConditionIndicator({
    required this.label,
    required this.score,
    required this.icon,
    required this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 8),
          Text(
            label,
            style: context.labelSmall.copyWith(
              color: isDark
                  ? DSColors.textSecondaryDark
                  : DSColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          // 점수 바
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: score / 100,
              minHeight: 6,
              backgroundColor: color.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$score점',
            style: context.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
