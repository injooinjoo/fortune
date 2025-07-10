import 'package:flutter/material.dart';
import '../../../utils/date_utils.dart';
import 'birth_date_preview.dart';

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
    final dayOptions = FortuneDateUtils.getDayOptions(
      birthYear.isNotEmpty ? int.parse(birthYear) : null,
      birthMonth.isNotEmpty ? int.parse(birthMonth) : null,
    );

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
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          onChanged: onNameChanged,
        ),
        const SizedBox(height: 8),
        Text(
          '정확한 사주 분석을 위해 필요해요.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 20),

        // 생년
        DropdownButtonFormField<String>(
          value: birthYear.isEmpty ? null : birthYear,
          decoration: InputDecoration(
            labelText: '생년',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: yearOptions.map((year) => DropdownMenuItem(
            value: year.toString(),
            child: Text('$year년'),
          )).toList(),
          onChanged: (value) => onBirthYearChanged(value ?? ''),
          hint: const Text('년도 선택'),
        ),
        const SizedBox(height: 16),

        // 생월
        DropdownButtonFormField<String>(
          value: birthMonth.isEmpty ? null : birthMonth,
          decoration: InputDecoration(
            labelText: '생월',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: monthOptions.map((month) => DropdownMenuItem(
            value: month.toString(),
            child: Text('$month월'),
          )).toList(),
          onChanged: (value) => onBirthMonthChanged(value ?? ''),
          hint: const Text('월 선택'),
        ),
        const SizedBox(height: 16),

        // 생일
        DropdownButtonFormField<String>(
          value: birthDay.isEmpty ? null : birthDay,
          decoration: InputDecoration(
            labelText: '생일',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: dayOptions.map((day) => DropdownMenuItem(
            value: day.toString(),
            child: Text('$day일'),
          )).toList(),
          onChanged: (value) => onBirthDayChanged(value ?? ''),
          hint: const Text('일 선택'),
        ),
        const SizedBox(height: 16),

        // 시진 선택 (선택사항)
        DropdownButtonFormField<String>(
          value: birthTimePeriod,
          decoration: InputDecoration(
            labelText: '태어난 시진 (선택사항)',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: timePeriods.map((period) => DropdownMenuItem(
            value: period.value,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(period.label),
                Text(
                  period.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          )).toList(),
          onChanged: onBirthTimePeriodChanged,
          hint: const Text('시진 선택'),
        ),
        const SizedBox(height: 8),
        Text(
          '더 정확한 사주 분석을 위해 필요해요.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 20),

        // 선택된 생년월일 표시
        BirthDatePreview(
          birthYear: birthYear,
          birthMonth: birthMonth,
          birthDay: birthDay,
          birthTimePeriod: birthTimePeriod,
        ),
        const SizedBox(height: 24),

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
                const SnackBar(
                  content: Text('필수 정보를 모두 입력해주세요.'),
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text('다음'),
        ),
      ],
    );
  }
}