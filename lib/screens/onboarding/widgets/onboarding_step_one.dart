import 'package:flutter/material.dart';
import '../../../core/theme/app_theme_extensions.dart';
import '../../../core/utils/fortune_date_utils.dart';
import '../../../core/utils/zodiac_calculator.dart';

class OnboardingStepOne extends StatelessWidget {
  final TextEditingController nameController;
  final String birthYear;
  final String birthMonth;
  final String birthDay;
  final String? birthTimePeriod;
  final Function(String) onNameChanged;
  final Function(String) onBirthYearChanged;
  final Function(String) onBirthMonthChanged;
  final Function(String) onBirthDayChanged;
  final Function(String?) onBirthTimePeriodChanged;
  final VoidCallback onNext;

  const OnboardingStepOne({
    super.key,
    required this.nameController,
    required this.birthYear,
    required this.birthMonth,
    required this.birthDay,
    this.birthTimePeriod,
    required this.onNameChanged,
    required this.onBirthYearChanged,
    required this.onBirthMonthChanged,
    required this.onBirthDayChanged,
    required this.onBirthTimePeriodChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final yearOptions = FortuneDateUtils.getYearOptions();
    final monthOptions = FortuneDateUtils.getMonthOptions();
    final dayOptions = birthMonth.isNotEmpty 
        ? FortuneDateUtils.getDayOptions(int.parse(birthYear), int.parse(birthMonth))
        : [];
    final timePeriodOptions = FortuneDateUtils.getTimePeriodOptions();
    
    final formStyle = context.fortuneTheme.formStyles;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 이름 입력
        TextField(
          controller: nameController,
          decoration: InputDecoration(
            labelText: '이름',
            hintText: '홍길동',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(formStyle.inputBorderRadius),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: formStyle.inputPadding.horizontal,
              vertical: formStyle.inputPadding.vertical,
            ),
          ),
          onChanged: onNameChanged,
        ),
        SizedBox(height: formStyle.inputPadding.vertical * 0.5),
        Text(
          '정확한 사주 분석을 위해 필요해요.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.fortuneTheme.subtitleText,
          ),
        ),
        SizedBox(height: formStyle.inputPadding.horizontal * 1.25),

        // 생년
        DropdownButtonFormField<String>(
          value: birthYear.isEmpty ? null : birthYear,
          decoration: InputDecoration(
            labelText: '생년',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(formStyle.inputBorderRadius),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: formStyle.inputPadding.horizontal,
              vertical: formStyle.inputPadding.vertical,
            ),
          ),
          items: yearOptions.map((year) => DropdownMenuItem(
            value: year.toString(),
            child: Text('$year년'),
          )).toList(),
          onChanged: (value) => onBirthYearChanged(value ?? ''),
          hint: const Text('년도 선택'),
        ),
        SizedBox(height: formStyle.inputPadding.horizontal),

        // 생월
        DropdownButtonFormField<String>(
          value: birthMonth.isEmpty ? null : birthMonth,
          decoration: InputDecoration(
            labelText: '생월',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(formStyle.inputBorderRadius),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: formStyle.inputPadding.horizontal,
              vertical: formStyle.inputPadding.vertical,
            ),
          ),
          items: monthOptions.map((month) => DropdownMenuItem(
            value: month.toString(),
            child: Text('$month월'),
          )).toList(),
          onChanged: (value) => onBirthMonthChanged(value ?? ''),
          hint: const Text('월 선택'),
        ),
        SizedBox(height: formStyle.inputPadding.horizontal),

        // 생일
        DropdownButtonFormField<String>(
          value: birthDay.isEmpty ? null : birthDay,
          decoration: InputDecoration(
            labelText: '생일',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(formStyle.inputBorderRadius),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: formStyle.inputPadding.horizontal,
              vertical: formStyle.inputPadding.vertical,
            ),
          ),
          items: dayOptions.map((day) => DropdownMenuItem(
            value: day.toString(),
            child: Text('$day일'),
          )).toList(),
          onChanged: (value) => onBirthDayChanged(value ?? ''),
          hint: const Text('일 선택'),
        ),
        SizedBox(height: formStyle.inputPadding.horizontal),

        // 생시 (선택사항)
        DropdownButtonFormField<String>(
          value: birthTimePeriod,
          decoration: InputDecoration(
            labelText: '생시 (선택사항)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(formStyle.inputBorderRadius),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: formStyle.inputPadding.horizontal,
              vertical: formStyle.inputPadding.vertical,
            ),
          ),
          items: timePeriodOptions.map((time) => DropdownMenuItem(
            value: time['value'],
            child: Text(time['label']!),
          )).toList(),
          onChanged: onBirthTimePeriodChanged,
          hint: const Text('생시를 모르시면 선택하지 않으셔도 됩니다'),
        ),

        // 띠 표시
        if (birthYear.isNotEmpty) ...[
          SizedBox(height: formStyle.inputPadding.horizontal),
          _buildZodiacInfo(context),
        ],
        
        SizedBox(height: formStyle.inputPadding.horizontal * 2),
        
        // 다음 버튼
        ElevatedButton(
          onPressed: _canProceed() ? onNext : null,
          style: context.fortuneTheme.ctaButtonStyle,
          child: const Text('다음'),
        ),
      ],
    );
  }

  bool _canProceed() {
    return nameController.text.isNotEmpty &&
           birthYear.isNotEmpty &&
           birthMonth.isNotEmpty &&
           birthDay.isNotEmpty;
  }

  Widget _buildZodiacInfo(BuildContext context) {
    final zodiac = ZodiacCalculator.getZodiac(int.parse(birthYear));
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.fortuneTheme.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.fortuneTheme.dividerColor),
      ),
      child: Row(
        children: [
          Text(
            zodiac['emoji']!,
            style: const TextStyle(fontSize: 24),
          ),
          const SizedBox(width: 12),
          Text(
            '${zodiac['name']}띠',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}