import 'package:flutter/material.dart';
import '../../../utils/date_utils.dart';
import '../../../core/theme/app_theme_extensions.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

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
    this.birthTimePeriod});

  @override
  Widget build(BuildContext context) {
    if (birthYear.isEmpty || birthMonth.isEmpty || birthDay.isEmpty) {
      return const SizedBox.shrink();
    }

    final formattedDate = FortuneDateUtils.formatKoreanDate(
      birthYear,
      birthMonth,
      birthDay);

    TimePeriod? selectedTimePeriod;
    if (birthTimePeriod != null) {
      try {
        selectedTimePeriod = timePeriods.firstWhere(
          (period) => period.value == birthTimePeriod
        );
      } catch (_) {}
    }

    return Container(
      padding: EdgeInsets.all(context.fortuneTheme.formStyles.inputPadding.vertical * 0.75),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(context.fortuneTheme.formStyles.inputBorderRadius),
        border: Border.all(color: Theme.of(context).primaryColor.withOpacity(0.2)),
      child: Column(
        children: [
          Text(
            formattedDate,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: Theme.of(context).primaryColor
            ),
            textAlign: TextAlign.center),
          if (selectedTimePeriod != null) ...[
            SizedBox(height: context.fortuneTheme.formStyles.inputPadding.vertical * 0.25),
            Text(
              selectedTimePeriod.label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).primaryColor.withOpacity(0.8)),
              textAlign: TextAlign.center)]]));
  }
}