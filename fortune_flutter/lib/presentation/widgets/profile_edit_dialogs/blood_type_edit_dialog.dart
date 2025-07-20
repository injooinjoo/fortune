import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'profile_field_edit_dialog.dart';

class BloodTypeEditDialog extends StatefulWidget {
  final String? initialBloodType;
  final Function(String?) onSave;

  const BloodTypeEditDialog({
    super.key,
    this.initialBloodType,
    required this.onSave,
  });

  @override
  State<BloodTypeEditDialog> createState() => _BloodTypeEditDialogState();
}

class _BloodTypeEditDialogState extends State<BloodTypeEditDialog> {
  final List<String> bloodTypes = ['A', 'B', 'AB', 'O'];
  String? _selectedBloodType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedBloodType = widget.initialBloodType;
  }

  void _handleSave() async {
    setState(() => _isLoading = true);
    
    try {
      await widget.onSave(_selectedBloodType);
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
      title: '혈액형 수정',
      isLoading: _isLoading,
      onSave: _handleSave,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            '혈액형을 선택해주세요',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.5,
            ),
            itemCount: bloodTypes.length + 1,
            itemBuilder: (context, index) {
              if (index == bloodTypes.length) {
                return _buildBloodTypeOption(null, '선택 안함');
              }
              
              final bloodType = bloodTypes[index];
              return _buildBloodTypeOption(bloodType, '${bloodType}형');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBloodTypeOption(String? value, String label) {
    final isSelected = _selectedBloodType == value;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedBloodType = value;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? AppColors.primary : Colors.white,
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.water_drop,
                  size: 20,
                  color: isSelected ? Colors.white : AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? Colors.white : AppColors.textPrimary,
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