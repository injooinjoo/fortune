import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/widgets/paper_runtime_chrome.dart';
import '../../../features/character/presentation/utils/onboarding_interest_catalog.dart';

class PersonalizedHandoffStep extends StatelessWidget {
  final List<String> selectedInterestIds;

  const PersonalizedHandoffStep({
    super.key,
    this.selectedInterestIds = const [],
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final selectedLabels = selectedInterestIds
        .take(3)
        .map((id) => onboardingInterestById[id]?.label)
        .whereType<String>()
        .toList(growable: false);

    return Scaffold(
      backgroundColor: colors.background,
      body: PaperRuntimeBackground(
        ringAlignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: DSSpacing.lg),
        child: Column(
          children: [
            const Spacer(flex: 3),
            Container(
              width: 128,
              height: 128,
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.96),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.border.withValues(alpha: 0.74),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 76,
                    height: 76,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      value: 0.82,
                      color: colors.textPrimary.withValues(alpha: 0.72),
                      backgroundColor: colors.border.withValues(alpha: 0.35),
                    ),
                  ),
                  Icon(
                    Icons.auto_awesome,
                    color: colors.textPrimary,
                    size: 28,
                  ),
                ],
              ),
            ),
            const SizedBox(height: DSSpacing.xl),
            Text(
              '첫 화면을 정리하고 있어요',
              style: typography.headingMedium.copyWith(
                color: colors.textPrimary,
                height: 1.16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              selectedLabels.isEmpty
                  ? '대화를 시작하기 좋은 흐름부터 바로 보여드릴게요.'
                  : '${selectedLabels.join(' · ')} 기준으로 추천 시작점을 맞추고 있어요.',
              style: typography.bodyMedium.copyWith(
                color: colors.textSecondary,
                height: 1.55,
              ),
              textAlign: TextAlign.center,
            ),
            if (selectedLabels.isNotEmpty) ...[
              const SizedBox(height: DSSpacing.lg),
              Wrap(
                spacing: DSSpacing.sm,
                runSpacing: DSSpacing.sm,
                alignment: WrapAlignment.center,
                children: selectedLabels
                    .map((label) => PaperRuntimePill(label: label))
                    .toList(growable: false),
              ),
            ],
            const Spacer(flex: 4),
          ],
        ),
      ),
    );
  }
}
