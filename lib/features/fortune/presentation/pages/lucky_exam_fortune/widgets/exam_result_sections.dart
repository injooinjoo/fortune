import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../../core/theme/toss_design_system.dart';
import '../../../../../../core/components/app_card.dart';
import '../../../../../../core/utils/fortune_text_cleaner.dart';
import '../../../../../../core/widgets/unified_blur_wrapper.dart';

class PassPossibilitySection extends StatelessWidget {
  final String passPossibility;
  final bool isBlurred;
  final List<String> blurredSections;

  const PassPossibilitySection({
    super.key,
    required this.passPossibility,
    required this.isBlurred,
    required this.blurredSections,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return UnifiedBlurWrapper(
      isBlurred: isBlurred,
      blurredSections: blurredSections,
      sectionKey: 'pass_possibility',
      child: AppCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: TossDesignSystem.successGreen, size: 24),
                const SizedBox(width: 8),
                Text(
                  '합격 가능성',
                  style: TossDesignSystem.body1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? TossDesignSystem.textPrimaryDark : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              FortuneTextCleaner.clean(passPossibility),
              style: TossDesignSystem.body2.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.3);
  }
}

class FocusSubjectSection extends StatelessWidget {
  final String focusSubject;
  final bool isBlurred;
  final List<String> blurredSections;

  const FocusSubjectSection({
    super.key,
    required this.focusSubject,
    required this.isBlurred,
    required this.blurredSections,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return UnifiedBlurWrapper(
      isBlurred: isBlurred,
      blurredSections: blurredSections,
      sectionKey: 'focus_subject',
      child: AppCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.school, color: TossDesignSystem.tossBlue, size: 24),
                const SizedBox(width: 8),
                Text(
                  '집중 과목/영역',
                  style: TossDesignSystem.body1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? TossDesignSystem.textPrimaryDark : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              FortuneTextCleaner.clean(focusSubject),
              style: TossDesignSystem.body2.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.3);
  }
}

class StudyMethodsSection extends StatelessWidget {
  final List<String> studyMethods;
  final bool isBlurred;
  final List<String> blurredSections;

  const StudyMethodsSection({
    super.key,
    required this.studyMethods,
    required this.isBlurred,
    required this.blurredSections,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return UnifiedBlurWrapper(
      isBlurred: isBlurred,
      blurredSections: blurredSections,
      sectionKey: 'study_methods',
      child: AppCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_stories, color: TossDesignSystem.warningOrange, size: 24),
                const SizedBox(width: 8),
                Text(
                  '추천 학습법',
                  style: TossDesignSystem.body1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? TossDesignSystem.textPrimaryDark : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...studyMethods.map((method) =>
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 8, right: 12),
                      decoration: BoxDecoration(
                        color: TossDesignSystem.warningOrange,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        FortuneTextCleaner.clean(method),
                        style: TossDesignSystem.body2.copyWith(height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3);
  }
}

class CautionsSection extends StatelessWidget {
  final List<String> cautions;
  final bool isBlurred;
  final List<String> blurredSections;

  const CautionsSection({
    super.key,
    required this.cautions,
    required this.isBlurred,
    required this.blurredSections,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return UnifiedBlurWrapper(
      isBlurred: isBlurred,
      blurredSections: blurredSections,
      sectionKey: 'cautions',
      child: AppCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.warning_amber, color: TossDesignSystem.errorRed, size: 24),
                const SizedBox(width: 8),
                Text(
                  '주의사항',
                  style: TossDesignSystem.body1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? TossDesignSystem.textPrimaryDark : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...cautions.map((caution) =>
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(top: 8, right: 12),
                      decoration: BoxDecoration(
                        color: TossDesignSystem.errorRed,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        FortuneTextCleaner.clean(caution),
                        style: TossDesignSystem.body2.copyWith(height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: 250.ms).fadeIn().slideY(begin: 0.3);
  }
}

class DdayAdviceSection extends StatelessWidget {
  final String ddayAdvice;
  final bool isBlurred;
  final List<String> blurredSections;

  const DdayAdviceSection({
    super.key,
    required this.ddayAdvice,
    required this.isBlurred,
    required this.blurredSections,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return UnifiedBlurWrapper(
      isBlurred: isBlurred,
      blurredSections: blurredSections,
      sectionKey: 'dday_advice',
      child: AppCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.calendar_today, color: TossDesignSystem.tossBlue, size: 24),
                const SizedBox(width: 8),
                Text(
                  '시험 당일 조언',
                  style: TossDesignSystem.body1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? TossDesignSystem.textPrimaryDark : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              FortuneTextCleaner.clean(ddayAdvice),
              style: TossDesignSystem.body2.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    ).animate(delay: 275.ms).fadeIn().slideY(begin: 0.3);
  }
}

class LuckyHoursSection extends StatelessWidget {
  final String luckyHours;
  final bool isBlurred;
  final List<String> blurredSections;

  const LuckyHoursSection({
    super.key,
    required this.luckyHours,
    required this.isBlurred,
    required this.blurredSections,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return UnifiedBlurWrapper(
      isBlurred: isBlurred,
      blurredSections: blurredSections,
      sectionKey: 'lucky_hours',
      child: AppCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.access_time, color: TossDesignSystem.warningOrange, size: 24),
                const SizedBox(width: 8),
                Text(
                  '행운의 시간',
                  style: TossDesignSystem.body1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? TossDesignSystem.textPrimaryDark : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              FortuneTextCleaner.clean(luckyHours),
              style: TossDesignSystem.body2.copyWith(height: 1.5),
            ),
          ],
        ),
      ),
    ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.3);
  }
}

class StrengthsSection extends StatelessWidget {
  final List<String> strengths;
  final bool isBlurred;
  final List<String> blurredSections;

  const StrengthsSection({
    super.key,
    required this.strengths,
    required this.isBlurred,
    required this.blurredSections,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return UnifiedBlurWrapper(
      isBlurred: isBlurred,
      blurredSections: blurredSections,
      sectionKey: 'strengths',
      child: AppCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.stars, color: TossDesignSystem.successGreen, size: 24),
                const SizedBox(width: 8),
                Text(
                  '당신의 강점',
                  style: TossDesignSystem.body1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? TossDesignSystem.textPrimaryDark : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: strengths.map((strength) =>
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: TossDesignSystem.successGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: TossDesignSystem.successGreen.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    FortuneTextCleaner.clean(strength),
                    style: TossDesignSystem.caption.copyWith(
                      color: TossDesignSystem.successGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ).toList(),
            ),
          ],
        ),
      ),
    ).animate(delay: 325.ms).fadeIn().slideY(begin: 0.3);
  }
}

class PositiveMessageSection extends StatelessWidget {
  final String positiveMessage;
  final bool isBlurred;
  final List<String> blurredSections;

  const PositiveMessageSection({
    super.key,
    required this.positiveMessage,
    required this.isBlurred,
    required this.blurredSections,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return UnifiedBlurWrapper(
      isBlurred: isBlurred,
      blurredSections: blurredSections,
      sectionKey: 'positive_message',
      child: AppCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.favorite, color: TossDesignSystem.errorRed, size: 24),
                const SizedBox(width: 8),
                Text(
                  '응원 메시지',
                  style: TossDesignSystem.body1.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? TossDesignSystem.textPrimaryDark : null,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                    TossDesignSystem.successGreen.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                FortuneTextCleaner.clean(positiveMessage),
                style: TossDesignSystem.body2.copyWith(
                  height: 1.6,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    ).animate(delay: 350.ms).fadeIn().slideY(begin: 0.3);
  }
}
