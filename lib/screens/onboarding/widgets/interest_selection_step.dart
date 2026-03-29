import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/widgets/paper_runtime_chrome.dart';
import '../../../features/character/presentation/utils/onboarding_interest_catalog.dart';

class InterestSelectionStep extends StatefulWidget {
  final List<String> initialSelectedIds;
  final ValueChanged<List<String>> onSelectionChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const InterestSelectionStep({
    super.key,
    this.initialSelectedIds = const [],
    required this.onSelectionChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<InterestSelectionStep> createState() => _InterestSelectionStepState();
}

class _InterestSelectionStepState extends State<InterestSelectionStep> {
  late final List<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = [...widget.initialSelectedIds];
  }

  bool get _canContinue => _selectedIds.length >= 3;

  void _toggleInterest(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
    widget.onSelectionChanged(List<String>.from(_selectedIds));
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Scaffold(
      backgroundColor: colors.background,
      body: PaperRuntimeBackground(
        ringAlignment: Alignment.topCenter,
        padding: const EdgeInsets.fromLTRB(
          DSSpacing.lg,
          DSSpacing.xs,
          DSSpacing.lg,
          DSSpacing.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: widget.onBack,
              icon: Icon(
                Icons.arrow_back_ios_new,
                color: colors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(height: DSSpacing.sm),
            PaperRuntimePill(
              label: '${_selectedIds.length}/3 선택',
              icon: Icons.auto_awesome,
              emphasize: _canContinue,
            ),
            const SizedBox(height: DSSpacing.md),
            Text(
              '지금 더 보고 싶은 흐름을 골라주세요',
              style: typography.displayMedium.copyWith(
                color: colors.textPrimary,
              ),
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              '추천 정렬과 starter block에 반영되도록 3개 이상 선택합니다.',
              style: typography.bodyMedium.copyWith(
                color: const Color(0xFF98A0B1),
                fontSize: 15,
                height: 1.55,
              ),
            ),
            const SizedBox(height: DSSpacing.lg),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: DSSpacing.sm,
                  runSpacing: DSSpacing.sm,
                  children: onboardingInterestOptions.map((option) {
                    final isSelected = _selectedIds.contains(option.id);
                    return GestureDetector(
                      onTap: () => _toggleInterest(option.id),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        width: (MediaQuery.of(context).size.width -
                                (DSSpacing.lg * 2) -
                                DSSpacing.sm) /
                            2,
                        padding: const EdgeInsets.all(DSSpacing.md),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? colors.selectionBackground
                                  .withValues(alpha: 0.96)
                              : colors.surface.withValues(alpha: 0.96),
                          borderRadius: BorderRadius.circular(DSRadius.xl),
                          border: Border.all(
                            color: isSelected
                                ? colors.selectionBorder
                                : colors.border.withValues(alpha: 0.72),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colors.textPrimary.withValues(alpha: 0.03),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              option.label,
                              style: typography.labelLarge.copyWith(
                                color: isSelected
                                    ? colors.selectionForeground
                                    : colors.textPrimary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: DSSpacing.sm),
                            Text(
                              option.subtitle,
                              style: typography.bodySmall.copyWith(
                                color: isSelected
                                    ? colors.selectionForeground
                                        .withValues(alpha: 0.82)
                                    : colors.textSecondary,
                                height: 1.45,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const SizedBox(height: DSSpacing.md),
            DSButton.primary(
              text: '추천 맞추기',
              onPressed: _canContinue ? widget.onNext : null,
            ),
          ],
        ),
      ),
    );
  }
}
