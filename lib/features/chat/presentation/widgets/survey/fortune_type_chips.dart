import 'package:flutter/material.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../domain/models/fortune_survey_config.dart';
import '../../../domain/services/intent_detector.dart';

/// 텍스트 입력 시 추천 운세 타입 칩
class FortuneTypeChips extends StatelessWidget {
  final List<DetectedIntent> intents;
  final void Function(FortuneSurveyType type) onSelect;

  const FortuneTypeChips({
    super.key,
    required this.intents,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    if (intents.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '이런 운세가 궁금하신가요?',
            style: typography.labelSmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
          const SizedBox(height: DSSpacing.xs),
          Wrap(
            spacing: DSSpacing.xs,
            runSpacing: DSSpacing.xs,
            children: intents.take(3).map((intent) {
              return _FortuneTypeChip(
                intent: intent,
                onTap: () => onSelect(intent.type),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _FortuneTypeChip extends StatelessWidget {
  final DetectedIntent intent;
  final VoidCallback onTap;

  const _FortuneTypeChip({
    required this.intent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final chipColor = _getColorForType(intent.type);
    final label = _getLabelForType(intent.type);
    final emoji = _getEmojiForType(intent.type);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          DSHaptics.light();
          onTap();
        },
        borderRadius: BorderRadius.circular(DSRadius.lg),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: DSSpacing.sm,
            vertical: DSSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: chipColor.withValues(alpha: isDark ? 0.2 : 0.1),
            borderRadius: BorderRadius.circular(DSRadius.lg),
            border: Border.all(
              color: chipColor.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 14)),
              const SizedBox(width: DSSpacing.xs),
              Text(
                label,
                style: typography.labelMedium.copyWith(
                  color: colors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForType(FortuneSurveyType type) {
    switch (type) {
      case FortuneSurveyType.profileCreation:
        return const Color(0xFF9E9E9E); // 그레이 (유틸리티)
      case FortuneSurveyType.career:
        return const Color(0xFF4A90D9); // 블루
      case FortuneSurveyType.love:
      case FortuneSurveyType.compatibility:
      case FortuneSurveyType.exLover:
      case FortuneSurveyType.blindDate:
      case FortuneSurveyType.celebrity:
      case FortuneSurveyType.family:
        return const Color(0xFFE91E63); // 핑크
      case FortuneSurveyType.talent:
      case FortuneSurveyType.tarot:
      case FortuneSurveyType.traditional:
      case FortuneSurveyType.faceReading:
      case FortuneSurveyType.personalityDna:
      case FortuneSurveyType.dream:
      case FortuneSurveyType.wish:
      case FortuneSurveyType.naming:
        return const Color(0xFF9C27B0); // 퍼플
      case FortuneSurveyType.daily:
      case FortuneSurveyType.luckyItems:
      case FortuneSurveyType.fortuneCookie:
      case FortuneSurveyType.pet:
        return const Color(0xFFFF9800); // 오렌지
      case FortuneSurveyType.mbti:
      case FortuneSurveyType.biorhythm:
      case FortuneSurveyType.health:
      case FortuneSurveyType.exercise:
      case FortuneSurveyType.sportsGame:
        return const Color(0xFF00BCD4); // 시안
      case FortuneSurveyType.yearly:
      case FortuneSurveyType.newYear:
      case FortuneSurveyType.money:
      case FortuneSurveyType.lotto:
        return const Color(0xFFFFB800); // 골드
      case FortuneSurveyType.avoidPeople:
        return const Color(0xFFFF5252); // 레드
    }
  }

  String _getLabelForType(FortuneSurveyType type) {
    switch (type) {
      case FortuneSurveyType.profileCreation:
        return '프로필 생성';
      case FortuneSurveyType.career:
        return '커리어 운세';
      case FortuneSurveyType.love:
        return '연애 운세';
      case FortuneSurveyType.talent:
        return '적성 찾기';
      case FortuneSurveyType.daily:
        return '오늘의 운세';
      case FortuneSurveyType.tarot:
        return '타로';
      case FortuneSurveyType.mbti:
        return 'MBTI';
      case FortuneSurveyType.yearly:
        return '연간 운세';
      case FortuneSurveyType.newYear:
        return '새해 운세';
      case FortuneSurveyType.traditional:
        return '사주 분석';
      case FortuneSurveyType.faceReading:
        return 'AI 관상';
      case FortuneSurveyType.personalityDna:
        return '성격 DNA';
      case FortuneSurveyType.biorhythm:
        return '바이오리듬';
      case FortuneSurveyType.compatibility:
        return '궁합';
      case FortuneSurveyType.avoidPeople:
        return '경계 대상';
      case FortuneSurveyType.exLover:
        return '재회 운세';
      case FortuneSurveyType.blindDate:
        return '소개팅 운세';
      case FortuneSurveyType.money:
        return '재물운';
      case FortuneSurveyType.luckyItems:
        return '행운 아이템';
      case FortuneSurveyType.lotto:
        return '로또 번호';
      case FortuneSurveyType.wish:
        return '소원';
      case FortuneSurveyType.fortuneCookie:
        return '오늘의 메시지';
      case FortuneSurveyType.health:
        return '건강 운세';
      case FortuneSurveyType.exercise:
        return '운동 추천';
      case FortuneSurveyType.sportsGame:
        return '스포츠 경기';
      case FortuneSurveyType.dream:
        return '꿈 해몽';
      case FortuneSurveyType.celebrity:
        return '유명인 궁합';
      case FortuneSurveyType.pet:
        return '반려동물 궁합';
      case FortuneSurveyType.family:
        return '가족 운세';
      case FortuneSurveyType.naming:
        return '작명';
    }
  }

  String _getEmojiForType(FortuneSurveyType type) {
    switch (type) {
      case FortuneSurveyType.profileCreation:
        return '✍️';
      case FortuneSurveyType.career:
        return '💼';
      case FortuneSurveyType.love:
        return '💕';
      case FortuneSurveyType.talent:
        return '🌟';
      case FortuneSurveyType.daily:
        return '🌅';
      case FortuneSurveyType.tarot:
        return '🃏';
      case FortuneSurveyType.mbti:
        return '🧠';
      case FortuneSurveyType.yearly:
        return '📅';
      case FortuneSurveyType.newYear:
        return '🎊';
      case FortuneSurveyType.traditional:
        return '📿';
      case FortuneSurveyType.faceReading:
        return '🎭';
      case FortuneSurveyType.personalityDna:
        return '🧬';
      case FortuneSurveyType.biorhythm:
        return '📊';
      case FortuneSurveyType.compatibility:
        return '💞';
      case FortuneSurveyType.avoidPeople:
        return '⚠️';
      case FortuneSurveyType.exLover:
        return '🔄';
      case FortuneSurveyType.blindDate:
        return '💘';
      case FortuneSurveyType.money:
        return '💰';
      case FortuneSurveyType.luckyItems:
        return '🍀';
      case FortuneSurveyType.lotto:
        return '🎰';
      case FortuneSurveyType.wish:
        return '🌠';
      case FortuneSurveyType.fortuneCookie:
        return '🥠';
      case FortuneSurveyType.health:
        return '💊';
      case FortuneSurveyType.exercise:
        return '🏃';
      case FortuneSurveyType.sportsGame:
        return '🏆';
      case FortuneSurveyType.dream:
        return '💭';
      case FortuneSurveyType.celebrity:
        return '⭐';
      case FortuneSurveyType.pet:
        return '🐾';
      case FortuneSurveyType.family:
        return '👨‍👩‍👧‍👦';
      case FortuneSurveyType.naming:
        return '📝';
    }
  }
}
