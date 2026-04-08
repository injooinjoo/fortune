import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/widgets/paper_runtime_chrome.dart';
import '../../../features/character/presentation/utils/onboarding_interest_catalog.dart';

class PersonalizedHandoffStep extends StatefulWidget {
  final List<String> selectedInterestIds;

  const PersonalizedHandoffStep({
    super.key,
    this.selectedInterestIds = const [],
  });

  @override
  State<PersonalizedHandoffStep> createState() =>
      _PersonalizedHandoffStepState();
}

class _PersonalizedHandoffStepState extends State<PersonalizedHandoffStep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState();
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final selectedLabels = widget.selectedInterestIds
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
              width: 112,
              height: 112,
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.96),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.border.withValues(alpha: 0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.32),
                    blurRadius: 40,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Center(
                child: RotationTransition(
                  turns: _spinController,
                  child: Icon(
                    Icons.autorenew_rounded,
                    size: 40,
                    color: colors.textPrimary.withValues(alpha: 0.72),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text(
              '첫 화면을 당신의 흐름에 맞추는 중',
              style: typography.headingMedium.copyWith(
                color: colors.textPrimary,
                fontSize: 26,
                height: 1.2,
                letterSpacing: -1,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              selectedLabels.isEmpty
                  ? '대화를 시작하기 좋은 흐름부터 바로 보여드릴게요.'
                  : '생년월일과 방금 고른 관심사를 기준으로 추천 순서와 starter block을 준비하고 있어요.',
              style: typography.bodyMedium.copyWith(
                color: const Color(0xFF9CA2B2),
                fontSize: 15,
                height: 1.6,
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
