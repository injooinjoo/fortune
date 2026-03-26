import 'package:flutter/material.dart';

import '../../../core/design_system/design_system.dart';
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
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
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
              const SizedBox(height: 12),
              Text(
                '어떤 흐름부터 보고 싶나요?',
                style: typography.headingLarge.copyWith(
                  color: colors.textPrimary,
                  height: 1.18,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                '세 가지 이상 고르면 첫 화면 추천을 더 자연스럽게 맞춰드릴게요.',
                style: typography.bodyMedium.copyWith(
                  color: colors.textSecondary,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                '${_selectedIds.length}/3 선택',
                style: typography.labelLarge.copyWith(
                  color:
                      _canContinue ? colors.textPrimary : colors.textTertiary,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: onboardingInterestOptions.map((option) {
                      final isSelected = _selectedIds.contains(option.id);
                      return GestureDetector(
                        onTap: () => _toggleInterest(option.id),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          width: (MediaQuery.of(context).size.width - 60) / 2,
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colors.selectionBackground
                                : colors.surface,
                            borderRadius:
                                BorderRadius.circular(context.radius.xl),
                            border: Border.all(
                              color: isSelected
                                  ? colors.selectionBorder
                                  : colors.border.withValues(alpha: 0.7),
                            ),
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
                              const SizedBox(height: 8),
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
              const SizedBox(height: 20),
              DSButton.primary(
                text: '추천 맞추기',
                onPressed: _canContinue ? widget.onNext : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
