import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system/design_system.dart';
import '../../../core/theme/app_theme_extensions.dart';
import '../../../core/services/fortune_haptic_service.dart';

class BottomSheetMbtiPicker extends ConsumerWidget {
  final String dimension;
  final String option1;
  final String option2;
  final String? selectedOption;
  final Function(String) onOptionSelected;

  const BottomSheetMbtiPicker({
    super.key,
    required this.dimension,
    required this.option1,
    required this.option2,
    this.selectedOption,
    required this.onOptionSelected,
  });

  static Future<String?> show(
    BuildContext context, {
    required String dimension,
    required String option1,
    required String option2,
    String? selectedOption,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => BottomSheetMbtiPicker(
        dimension: dimension,
        option1: option1,
        option2: option2,
        selectedOption: selectedOption,
        onOptionSelected: (option) {
          Navigator.of(context).pop(option);
        },
      ),
    );
  }

  String _getDescription(String option) {
    switch (option) {
      case 'E':
        return '외향적 - 사람들과 함께 있을 때 에너지를 얻어요';
      case 'I':
        return '내향적 - 혼자 있을 때 에너지를 얻어요';
      case 'N':
        return '직관적 - 미래와 가능성에 집중해요';
      case 'S':
        return '감각적 - 현재와 사실에 집중해요';
      case 'T':
        return '사고형 - 논리와 분석을 중시해요';
      case 'F':
        return '감정형 - 가치와 조화를 중시해요';
      case 'J':
        return '판단형 - 계획적이고 체계적이에요';
      case 'P':
        return '인식형 - 유연하고 즉흥적이에요';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final fortuneTheme = context.fortuneTheme;

    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(fortuneTheme.bottomSheetStyles.borderRadius),
          topRight:
              Radius.circular(fortuneTheme.bottomSheetStyles.borderRadius),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: fortuneTheme.bottomSheetStyles.handleWidth,
            height: fortuneTheme.bottomSheetStyles.handleHeight,
            decoration: BoxDecoration(
              color: colors.divider,
              borderRadius: BorderRadius.circular(
                  fortuneTheme.bottomSheetStyles.handleHeight / 2),
            ),
          ),

          // Header
          Padding(
            padding:
                EdgeInsets.all(fortuneTheme.formStyles.inputPadding.horizontal),
            child: Text(
              dimension,
              style: context.typography.headingLarge.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // Options
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                  horizontal:
                      fortuneTheme.formStyles.inputPadding.horizontal * 1.5),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildOption(context, ref, option1),
                  SizedBox(
                      height: fortuneTheme.formStyles.inputPadding.horizontal),
                  _buildOption(context, ref, option2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, WidgetRef ref, String option) {
    final isSelected = selectedOption == option;
    final colors = context.colors;
    final fortuneTheme = context.fortuneTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          ref.read(fortuneHapticServiceProvider).selection();
          onOptionSelected(option);
        },
        borderRadius: BorderRadius.circular(DSRadius.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: EdgeInsets.all(
              fortuneTheme.formStyles.inputPadding.horizontal * 1.25),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.textPrimary.withValues(alpha: 0.1)
                : colors.surface,
            borderRadius: BorderRadius.circular(DSRadius.lg),
            border: Border.all(
              color: isSelected
                  ? colors.textPrimary
                  : colors.textPrimary.withValues(alpha: 0.2),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option,
                      style: context.typography.headingSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? colors.textPrimary
                            : colors.textPrimary,
                      ),
                    ),
                    SizedBox(
                        height: fortuneTheme.formStyles.inputPadding.vertical *
                            0.3),
                    Text(
                      _getDescription(option),
                      style: context.typography.bodyMedium.copyWith(
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: colors.textPrimary,
                  size: 24,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
