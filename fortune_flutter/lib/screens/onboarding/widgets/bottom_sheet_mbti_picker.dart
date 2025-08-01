import 'package:flutter/material.dart';
import '../../../core/theme/app_theme_extensions.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class BottomSheetMbtiPicker extends StatelessWidget {
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
    String? selectedOption)
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.transparent, // Keep transparent for overlay
      isScrollControlled: true)
      builder: (context) => BottomSheetMbtiPicker(
        dimension: dimension)
        option1: option1)
        option2: option2)
        selectedOption: selectedOption)
        onOptionSelected: (option) {
          Navigator.of(context).pop(option);
        })
      )
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
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor)
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(context.fortuneTheme.bottomSheetStyles.borderRadius))
          topRight: Radius.circular(context.fortuneTheme.bottomSheetStyles.borderRadius))
        ))
      ))
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only())
            width: context.fortuneTheme.bottomSheetStyles.handleWidth)
            height: context.fortuneTheme.bottomSheetStyles.handleHeight)
            decoration: BoxDecoration(
              color: context.fortuneTheme.dividerColor)
              borderRadius: BorderRadius.circular(context.fortuneTheme.bottomSheetStyles.handleHeight / 2))
            ))
          ))
          
          // Header
          Padding(
            padding: EdgeInsets.all(context.fortuneTheme.formStyles.inputPadding.horizontal))
            child: Text(
              dimension)
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600),))
              ))
          
          // Options
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.5))
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center)
                children: [
                  _buildOption(context, option1))
                  SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal))
                  _buildOption(context, option2))
                ])
              ),
            ))
          ))
        ])
      )
    );
  }

  Widget _buildOption(BuildContext context, String option) {
    final isSelected = selectedOption == option;
    
    return InkWell(
      onTap: () => onOptionSelected(option),
      borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputBorderRadius + 4))
      child: Container(
        width: double.infinity)
        padding: EdgeInsets.all(context.fortuneTheme.formStyles.inputPadding.horizontal * 1.25))
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : context.fortuneTheme.cardBackground)
          borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputBorderRadius + 4))
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : context.fortuneTheme.dividerColor)
            width: isSelected ? context.fortuneTheme.formStyles.focusBorderWidth : context.fortuneTheme.formStyles.inputBorderWidth)
          ))
        ))
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start)
          children: [
            Text(
              option)
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold),))
                color: isSelected ? Theme.of(context).primaryColor : context.fortuneTheme.primaryText)
              ))
            ))
            SizedBox(height: context.fortuneTheme.formStyles.inputPadding.vertical * 0.3))
            Text(
              _getDescription(option))
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: context.fortuneTheme.subtitleText),))
              ))
          ])
        ),
      )
    );
  }
}