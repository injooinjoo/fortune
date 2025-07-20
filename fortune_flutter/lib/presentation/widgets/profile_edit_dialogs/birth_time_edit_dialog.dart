import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../constants/fortune_constants.dart';
import 'profile_field_edit_dialog.dart';

class TimePeriod {
  final String value;
  final String label;
  final String? description;

  const TimePeriod({
    required this.value,
    required this.label,
    this.description,
  });
}

class BirthTimeEditDialog extends StatefulWidget {
  final String? initialTime;
  final Function(String?) onSave;

  const BirthTimeEditDialog({
    super.key,
    this.initialTime,
    required this.onSave,
  });

  @override
  State<BirthTimeEditDialog> createState() => _BirthTimeEditDialogState();
}

class _BirthTimeEditDialogState extends State<BirthTimeEditDialog> {
  String? _selectedTime;
  bool _isLoading = false;

  static final List<TimePeriod> timePeriods = [
    TimePeriod(value: '자시', label: '자시 (23:00 - 01:00)', description: '23:00 - 01:00'),
    TimePeriod(value: '축시', label: '축시 (01:00 - 03:00)', description: '01:00 - 03:00'),
    TimePeriod(value: '인시', label: '인시 (03:00 - 05:00)', description: '03:00 - 05:00'),
    TimePeriod(value: '묘시', label: '묘시 (05:00 - 07:00)', description: '05:00 - 07:00'),
    TimePeriod(value: '진시', label: '진시 (07:00 - 09:00)', description: '07:00 - 09:00'),
    TimePeriod(value: '사시', label: '사시 (09:00 - 11:00)', description: '09:00 - 11:00'),
    TimePeriod(value: '오시', label: '오시 (11:00 - 13:00)', description: '11:00 - 13:00'),
    TimePeriod(value: '미시', label: '미시 (13:00 - 15:00)', description: '13:00 - 15:00'),
    TimePeriod(value: '신시', label: '신시 (15:00 - 17:00)', description: '15:00 - 17:00'),
    TimePeriod(value: '유시', label: '유시 (17:00 - 19:00)', description: '17:00 - 19:00'),
    TimePeriod(value: '술시', label: '술시 (19:00 - 21:00)', description: '19:00 - 21:00'),
    TimePeriod(value: '해시', label: '해시 (21:00 - 23:00)', description: '21:00 - 23:00'),
  ];

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
  }

  void _handleSave() async {
    setState(() => _isLoading = true);
    
    try {
      await widget.onSave(_selectedTime);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('저장 중 오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProfileFieldEditDialog(
      title: '출생시간 수정',
      isLoading: _isLoading,
      onSave: _handleSave,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '정확한 시간을 모르시면 선택하지 않으셔도 됩니다',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            constraints: const BoxConstraints(maxHeight: 400),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: timePeriods.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildTimeOption(null, '선택 안함');
                }
                
                final period = timePeriods[index - 1];
                return _buildTimeOption(
                  period.value,
                  period.label,
                  description: period.description,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimeOption(String? value, String label, {String? description}) {
    final isSelected = _selectedTime == value;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            setState(() {
              _selectedTime = value;
            });
          },
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? AppColors.primary : AppColors.divider,
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(8),
              color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
            ),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.textSecondary,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? AppColors.primary : AppColors.textPrimary,
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          description,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}