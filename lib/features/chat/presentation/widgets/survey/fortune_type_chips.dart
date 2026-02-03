import 'package:flutter/material.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../domain/models/fortune_survey_config.dart';
import '../../../domain/services/intent_detector.dart';

/// 텍스트 입력 시 추천 인사이트 타입 칩
class FortuneTypeChips extends StatelessWidget {
  final List<DetectedIntent> intents;
  final void Function(FortuneSurveyType type) onSelect;
  final bool isLoading;

  const FortuneTypeChips({
    super.key,
    required this.intents,
    required this.onSelect,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    if (intents.isEmpty && !isLoading) return const SizedBox.shrink();

    // AI 추천인지 확인
    final isAiRecommendation =
        intents.isNotEmpty && intents.first.isAiGenerated;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(
                isAiRecommendation
                    ? '✨ AI 추천'
                    : '이런 인사이트가 궁금하신가요?',
                style: typography.labelSmall.copyWith(
                  color: isAiRecommendation
                      ? colors.accent
                      : colors.textSecondary,
                  fontWeight:
                      isAiRecommendation ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
              if (isLoading) ...[
                const SizedBox(width: DSSpacing.xs),
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(colors.textTertiary),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: DSSpacing.xs),
          if (intents.isNotEmpty)
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

    final label = _getLabelForType(intent.type);

    return GestureDetector(
      onTap: () {
        DSHaptics.light();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: DSSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: colors.surfaceSecondary,
          borderRadius: BorderRadius.circular(DSRadius.md),
        ),
        child: Text(
          label,
          style: typography.labelMedium.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  String _getLabelForType(FortuneSurveyType type) {
    switch (type) {
      case FortuneSurveyType.profileCreation:
        return '프로필 생성';
      case FortuneSurveyType.career:
        return '커리어 인사이트';
      case FortuneSurveyType.love:
        return '연애 인사이트';
      case FortuneSurveyType.talent:
        return '적성 찾기';
      case FortuneSurveyType.daily:
        return '오늘의 인사이트';
      case FortuneSurveyType.tarot:
        return '타로';
      case FortuneSurveyType.mbti:
        return 'MBTI';
      case FortuneSurveyType.newYear:
        return '새해 인사이트';
      case FortuneSurveyType.dailyCalendar:
        return '기간별 인사이트';
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
        return '재회 인사이트';
      case FortuneSurveyType.blindDate:
        return '소개팅 인사이트';
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
        return '건강 인사이트';
      case FortuneSurveyType.exercise:
        return '운동 추천';
      case FortuneSurveyType.sportsGame:
        return '스포츠 경기';
      case FortuneSurveyType.dream:
        return '꿈 해몽';
      case FortuneSurveyType.pastLife:
        return '전생탐험';
      case FortuneSurveyType.celebrity:
        return '유명인 궁합';
      case FortuneSurveyType.pet:
        return '반려동물 궁합';
      case FortuneSurveyType.family:
        return '가족 인사이트';
      case FortuneSurveyType.naming:
        return '작명';
      case FortuneSurveyType.babyNickname:
        return '태명';
      case FortuneSurveyType.ootdEvaluation:
        return 'OOTD 평가';
      case FortuneSurveyType.talisman:
        return '부적';
      case FortuneSurveyType.exam:
        return '시험운';
      case FortuneSurveyType.moving:
        return '이사운';
      case FortuneSurveyType.gratitude:
        return '감사일기';
      case FortuneSurveyType.yearlyEncounter:
        return '올해의 인연';
      case FortuneSurveyType.gameEnhance:
        return '강화운세';
    }
  }
}
