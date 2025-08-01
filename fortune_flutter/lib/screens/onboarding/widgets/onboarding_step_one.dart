import 'package:flutter/material.dart';
import '../../../utils/date_utils.dart';
import 'birth_date_preview.dart';
import '../../../core/theme/app_theme_extensions.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

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

  const OnboardingStepOne(
    {
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
  )});

  @override
  Widget build(BuildContext context) {
    final yearOptions = FortuneDateUtils.getYearOptions();
    final monthOptions = FortuneDateUtils.getMonthOptions();
    final dayOptions = FortuneDateUtils.getDayOptions(
      birthYear.isNotEmpty ? int.parse(birthYear) : null
      birthMonth.isNotEmpty ? int.parse(birthMonth) : null
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 이름 입력
        TextField(
          controller: nameController,
          decoration: InputDecoration(,
      labelText: '이름',
            hintText: '홍길동'),
        border: OutlineInputBorder(,
      borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputBorderRadius),
      contentPadding: EdgeInsets.symmetric(,
      horizontal: context.fortuneTheme.formStyles.inputPadding.horizontal),
        vertical: context.fortuneTheme.formStyles.inputPadding.vertical)
            ))
          onChanged: onNameChanged)
        SizedBox(height: context.fortuneTheme.formStyles.inputPadding.vertical * 0.5),
        Text(
          '정확한 사주 분석을 위해 필요해요.'),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(,
      color: context.fortuneTheme.subtitleText,
                          ),
        SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.25),

        // 생년
        DropdownButtonFormField<String>(
          value: birthYear.isEmpty ? null : birthYear,
      decoration: InputDecoration(,
      labelText: '생년'),
        border: OutlineInputBorder(,
      borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputBorderRadius),
      contentPadding: EdgeInsets.symmetric(,
      horizontal: context.fortuneTheme.formStyles.inputPadding.horizontal),
        vertical: context.fortuneTheme.formStyles.inputPadding.vertical)
            ))
          items: yearOptions.map((year) => DropdownMenuItem(,
      value: year.toString(),
            child: Text('$year년')))).toList(),
          onChanged: (value) => onBirthYearChanged(value ?? ''),
          hint: Text('년도 선택'))
        SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal),

        // 생월
        DropdownButtonFormField<String>(
          value: birthMonth.isEmpty ? null : birthMonth,
      decoration: InputDecoration(,
      labelText: '생월'),
        border: OutlineInputBorder(,
      borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputBorderRadius),
      contentPadding: EdgeInsets.symmetric(,
      horizontal: context.fortuneTheme.formStyles.inputPadding.horizontal),
        vertical: context.fortuneTheme.formStyles.inputPadding.vertical)
            ))
          items: monthOptions.map((month) => DropdownMenuItem(,
      value: month.toString(),
            child: Text('$month월')))).toList(),
          onChanged: (value) => onBirthMonthChanged(value ?? ''),
          hint: const Text('월 선택'))
        SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal),

        // 생일
        DropdownButtonFormField<String>(
          value: birthDay.isEmpty ? null : birthDay,
      decoration: InputDecoration(,
      labelText: '생일'),
        border: OutlineInputBorder(,
      borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputBorderRadius),
      contentPadding: EdgeInsets.symmetric(,
      horizontal: context.fortuneTheme.formStyles.inputPadding.horizontal),
        vertical: context.fortuneTheme.formStyles.inputPadding.vertical)
            ))
          items: dayOptions.map((day) => DropdownMenuItem(,
      value: day.toString(),
            child: Text('$day일')))).toList(),
          onChanged: (value) => onBirthDayChanged(value ?? ''),
          hint: const Text('일 선택'))
        SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal),

        // 시진 선택 (선택사항)
        DropdownButtonFormField<String>(
          value: birthTimePeriod,
          decoration: InputDecoration(,
      labelText: '태어난 시진 (선택사항)',
            border: OutlineInputBorder(,
      borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputBorderRadius),
      contentPadding: EdgeInsets.symmetric(,
      horizontal: context.fortuneTheme.formStyles.inputPadding.horizontal),
        vertical: context.fortuneTheme.formStyles.inputPadding.vertical)
            ))
          items: timePeriods.map((period) => DropdownMenuItem(,
      value: period.value,
            child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              ),
              children: [
                        Text(
                          period.label),
                Text(
                  period.description,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(,
      color: AppColors.textSecondary,
                          ))
              ]))))).toList(),
          onChanged: onBirthTimePeriodChanged,
          hint: const Text('시진 선택'))
        SizedBox(height: context.fortuneTheme.formStyles.inputPadding.vertical * 0.5),
        Text(
          '더 정확한 사주 분석을 위해 필요해요.'),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(,
      color: context.fortuneTheme.subtitleText,
                          ),
        SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.25),

        // 선택된 생년월일 표시
        BirthDatePreview(
          birthYear: birthYear,
          birthMonth: birthMonth,
          birthDay: birthDay,
          birthTimePeriod: birthTimePeriod)
        SizedBox(height: context.fortuneTheme.formStyles.inputPadding.horizontal * 1.5),

        // 다음 버튼
        ElevatedButton(
          onPressed: () {
            if (nameController.text.isNotEmpty &&
                birthYear.isNotEmpty &&
                birthMonth.isNotEmpty &&
                birthDay.isNotEmpty) {
              onNext();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('필수 정보를 모두 입력해주세요.'),
                  backgroundColor: context.fortuneTheme.errorColor)))
            }
          }
          style: ElevatedButton.styleFrom(,
      padding: EdgeInsets.symmetric(vertic,
      al: context.fortuneTheme.formStyles.inputPadding.horizontal),
            shape: RoundedRectangleBorder(,
      borderRadius: BorderRadius.circular(AppDimensions.radiusSmall))))
          child: const Text('다음'))
      ])
  }
}