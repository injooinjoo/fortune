import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/components/custom_calendar_date_picker.dart';
import 'profile_field_edit_dialog.dart';

class BirthDateEditDialog extends StatefulWidget {
  final DateTime? initialDate;
  final Function(DateTime) onSave;

  const BirthDateEditDialog({
    super.key,
    this.initialDate,
    required this.onSave,
  });

  @override
  State<BirthDateEditDialog> createState() => _BirthDateEditDialogState();
}

class _BirthDateEditDialogState extends State<BirthDateEditDialog> {
  late DateTime _selectedDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate ?? DateTime.now();
  }

  void _handleSave() async {
    setState(() => _isLoading = true);
    
    try {
      await widget.onSave(_selectedDate);
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
      title: '생년월일 수정',
      isLoading: _isLoading,
      onSave: _handleSave,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cake,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  DateFormat('yyyy년 MM월 dd일').format(_selectedDate),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 300,
            child: CustomCalendarDatePicker(
              initialDate: _selectedDate,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
              onDateChanged: (date) {
                setState(() {
                  _selectedDate = date;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}