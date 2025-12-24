import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/design_system/design_system.dart';
import '../../../../../../core/theme/typography_unified.dart';
import '../../../../domain/models/face_condition.dart';
import '../../../../domain/models/emotion_analysis.dart';

/// 오늘의 안색 인사이트 위젯
/// 친근한 말투로 오늘의 컨디션에 대한 한 줄 인사이트를 제공합니다.
/// 예: "오늘은 미소 지수가 조금 낮아요 😢"
class TodayFaceConditionWidget extends StatelessWidget {
  /// 얼굴 컨디션 데이터
  final FaceCondition? condition;

  /// 감정 분석 데이터
  final EmotionAnalysis? emotionAnalysis;

  /// 다크모드 여부
  final bool isDark;

  /// 성별 (콘텐츠 차별화)
  final String? gender;

  /// 탭 콜백 (상세 보기)
  final VoidCallback? onTap;

  const TodayFaceConditionWidget({
    super.key,
    this.condition,
    this.emotionAnalysis,
    required this.isDark,
    this.gender,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final insight = _generateInsight();
    if (insight == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              insight.color.withValues(alpha: 0.12),
              insight.color.withValues(alpha: 0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: insight.color.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            // 이모지
            Text(
              insight.emoji,
              style: const TextStyle(fontSize: 28),
            ),
            const SizedBox(width: 14),

            // 메시지
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    insight.title,
                    style: context.labelLarge.copyWith(
                      color: isDark
                          ? DSColors.textPrimaryDark
                          : DSColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    insight.message,
                    style: context.bodySmall.copyWith(
                      color: isDark
                          ? DSColors.textSecondaryDark
                          : DSColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // 화살표 (탭 가능한 경우)
            if (onTap != null)
              Icon(
                Icons.chevron_right,
                color: insight.color.withValues(alpha: 0.6),
                size: 22,
              ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05, end: 0);
  }

  _InsightData? _generateInsight() {
    // 감정 분석 기반 인사이트
    if (emotionAnalysis != null) {
      final smile = emotionAnalysis!.smilePercentage;
      final tension = emotionAnalysis!.tensionPercentage;
      final relaxed = emotionAnalysis!.relaxedPercentage;

      if (smile >= 60) {
        return _InsightData(
          emoji: '😊',
          title: '오늘 미소가 가득해요!',
          message: _getPositiveSmileMessage(),
          color: Colors.amber,
        );
      } else if (smile >= 40 && relaxed >= 40) {
        return _InsightData(
          emoji: '😌',
          title: '편안한 표정이에요',
          message: _getRelaxedMessage(),
          color: DSColors.success,
        );
      } else if (tension >= 40) {
        return _InsightData(
          emoji: '😰',
          title: '조금 긴장한 것 같아요',
          message: _getTensionMessage(),
          color: Colors.orange,
        );
      } else if (smile < 30) {
        return _InsightData(
          emoji: '😔',
          title: '오늘은 미소 지수가 조금 낮아요',
          message: _getLowSmileMessage(),
          color: Colors.blue,
        );
      }
    }

    // 컨디션 기반 인사이트
    if (condition != null) {
      final overall = condition!.overallScore;
      final fatigue = condition!.fatigueLevel;
      final puffiness = condition!.puffinessLevel;

      if (overall >= 80) {
        return _InsightData(
          emoji: '✨',
          title: '오늘 컨디션이 최고예요!',
          message: _getHighConditionMessage(),
          color: Colors.pink,
        );
      } else if (fatigue >= 60) {
        return _InsightData(
          emoji: '😪',
          title: '피로가 얼굴에 보여요',
          message: _getFatigueMessage(),
          color: Colors.purple,
        );
      } else if (puffiness >= 60) {
        return _InsightData(
          emoji: '💧',
          title: '얼굴이 조금 부어 보여요',
          message: _getPuffinessMessage(),
          color: Colors.blue,
        );
      } else if (overall < 40) {
        return _InsightData(
          emoji: '🌙',
          title: '충분한 휴식이 필요해 보여요',
          message: _getLowConditionMessage(),
          color: Colors.indigo,
        );
      }
    }

    // 기본 인사이트
    return _InsightData(
      emoji: '🔮',
      title: '오늘의 관상을 분석했어요',
      message: '자세한 내용을 확인해 보세요',
      color: DSColors.accent,
    );
  }

  String _getPositiveSmileMessage() {
    if (gender == 'female') {
      return '밝은 에너지가 느껴져요. 좋은 인연을 만날 수 있을 거예요!';
    } else if (gender == 'male') {
      return '긍정적인 에너지가 느껴져요. 좋은 기회가 찾아올 거예요.';
    }
    return '밝은 에너지가 주변 사람들에게 좋은 영향을 줄 거예요';
  }

  String _getRelaxedMessage() {
    if (gender == 'female') {
      return '차분하고 안정적인 느낌이에요. 신뢰감을 주는 인상이에요';
    } else if (gender == 'male') {
      return '여유로운 모습이 좋아요. 리더십이 느껴져요';
    }
    return '마음이 평온해 보여요. 좋은 결정을 내릴 수 있을 거예요';
  }

  String _getTensionMessage() {
    if (gender == 'female') {
      return '긴장을 풀어보세요. 편안한 표정이 더 매력적이에요';
    } else if (gender == 'male') {
      return '잠시 긴장을 풀어보세요. 여유가 더 좋은 인상을 줘요';
    }
    return '깊게 숨을 쉬어보세요. 긴장이 풀리면 더 좋아질 거예요';
  }

  String _getLowSmileMessage() {
    if (gender == 'female') {
      return '오늘 하루 조금 힘드셨나요? 괜찮아요, 충분히 잘하고 있어요';
    } else if (gender == 'male') {
      return '걱정되는 일이 있으신가요? 잠시 쉬어가도 괜찮아요';
    }
    return '미소를 지어보세요. 작은 미소가 운을 바꿀 수 있어요';
  }

  String _getHighConditionMessage() {
    if (gender == 'female') {
      return '피부톤이 맑고 생기 있어요. 오늘 좋은 인상을 줄 수 있어요!';
    } else if (gender == 'male') {
      return '건강하고 활력 넘치는 모습이에요. 자신감을 가져도 좋아요';
    }
    return '컨디션이 좋으니 오늘 하고 싶은 일에 도전해 보세요';
  }

  String _getFatigueMessage() {
    if (gender == 'female') {
      return '오늘은 일찍 쉬어보세요. 충분한 수면이 미용에도 좋아요';
    } else if (gender == 'male') {
      return '오늘은 무리하지 마세요. 내일을 위한 휴식도 중요해요';
    }
    return '피로가 쌓였네요. 충분한 휴식을 취해보세요';
  }

  String _getPuffinessMessage() {
    if (gender == 'female') {
      return '가벼운 마사지가 도움이 될 거예요. 물도 충분히 마셔보세요';
    } else if (gender == 'male') {
      return '충분한 수분 섭취가 도움이 돼요. 가벼운 운동도 좋아요';
    }
    return '물을 많이 마시고 가벼운 스트레칭을 해보세요';
  }

  String _getLowConditionMessage() {
    if (gender == 'female') {
      return '오늘은 자기 케어에 집중해보세요. 충분히 쉬어도 괜찮아요';
    } else if (gender == 'male') {
      return '무리하지 마세요. 충전하는 시간도 필요해요';
    }
    return '오늘은 자신을 위한 시간을 가져보세요';
  }
}

/// 인사이트 데이터 모델
class _InsightData {
  final String emoji;
  final String title;
  final String message;
  final Color color;

  const _InsightData({
    required this.emoji,
    required this.title,
    required this.message,
    required this.color,
  });
}

/// 인사이트 배너 (리스트용)
/// 홈 화면 등에서 간단한 배너 형태로 표시할 때 사용합니다.
class FaceConditionInsightBanner extends StatelessWidget {
  final FaceCondition? condition;
  final EmotionAnalysis? emotionAnalysis;
  final bool isDark;
  final VoidCallback? onTap;

  const FaceConditionInsightBanner({
    super.key,
    this.condition,
    this.emotionAnalysis,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final insight = _generateQuickInsight();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: insight.color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(insight.emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                insight.message,
                style: context.labelSmall.copyWith(
                  color: insight.color,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: insight.color.withValues(alpha: 0.7),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _QuickInsight _generateQuickInsight() {
    if (emotionAnalysis != null) {
      final smile = emotionAnalysis!.smilePercentage;
      if (smile >= 50) {
        return _QuickInsight(
          emoji: '😊',
          message: '오늘 미소가 환해요!',
          color: Colors.amber,
        );
      } else if (smile < 30) {
        return _QuickInsight(
          emoji: '😔',
          message: '미소 지수가 낮아요',
          color: Colors.blue,
        );
      }
    }

    if (condition != null) {
      final overall = condition!.overallScore;
      if (overall >= 70) {
        return _QuickInsight(
          emoji: '✨',
          message: '컨디션 좋아요!',
          color: Colors.pink,
        );
      } else if (overall < 40) {
        return _QuickInsight(
          emoji: '😪',
          message: '휴식이 필요해요',
          color: Colors.purple,
        );
      }
    }

    return _QuickInsight(
      emoji: '🔮',
      message: '관상 분석하기',
      color: DSColors.accent,
    );
  }
}

class _QuickInsight {
  final String emoji;
  final String message;
  final Color color;

  const _QuickInsight({
    required this.emoji,
    required this.message,
    required this.color,
  });
}
