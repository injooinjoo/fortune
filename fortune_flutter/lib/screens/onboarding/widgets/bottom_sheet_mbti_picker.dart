import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.4,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              dimension,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // Options
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildOption(context, option1),
                  const SizedBox(height: 16),
                  _buildOption(context, option2),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(BuildContext context, String option) {
    final isSelected = selectedOption == option;
    
    return InkWell(
      onTap: () => onOptionSelected(option),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor.withValues(alpha: 0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Theme.of(context).primaryColor : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              option,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isSelected ? Theme.of(context).primaryColor : Colors.black,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _getDescription(option),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}