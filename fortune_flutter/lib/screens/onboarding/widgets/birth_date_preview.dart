import 'package:flutter/material.dart';
import '../../../utils/date_utils.dart';

class BirthDatePreview extends StatelessWidget {
  final String birthYear;
  final String birthMonth;
  final String birthDay;
  final String? birthTimePeriod;

  const BirthDatePreview({
    super.key,
    required this.birthYear,
    required this.birthMonth,
    required this.birthDay,
    this.birthTimePeriod,
  });

  @override
  Widget build(BuildContext context) {
    if (birthYear.isEmpty || birthMonth.isEmpty || birthDay.isEmpty) {
      return const SizedBox.shrink();
    }

    final formattedDate = FortuneDateUtils.formatKoreanDate(
      birthYear,
      birthMonth,
      birthDay,
    );

    TimePeriod? selectedTimePeriod;
    if (birthTimePeriod != null) {
      try {
        selectedTimePeriod = timePeriods.firstWhere(
          (period) => period.value == birthTimePeriod,
        );
      } catch (_) {}
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.purple.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Column(
        children: [
          Text(
            formattedDate,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.purple.shade800,
            ),
            textAlign: TextAlign.center,
          ),
          if (selectedTimePeriod != null) ...[
            const SizedBox(height: 4),
            Text(
              selectedTimePeriod.label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.purple.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}