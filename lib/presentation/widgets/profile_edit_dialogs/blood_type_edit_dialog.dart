import 'package:flutter/material.dart';
import '../../../core/theme/fortune_design_system.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_dimensions.dart';
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
            content: Text('오류가 발생했습니다: ${e.toString()}'),
            backgroundColor: TossDesignSystem.errorRed,
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
          Text(
            '혈액형을 선택해주세요',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? TossDesignSystem.gray300
                  : TossDesignSystem.gray600,
            ),
          ),
          const SizedBox(height: AppSpacing.spacing5),
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
              return _buildBloodTypeOption(bloodType, '$bloodType형');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBloodTypeOption(String? value, String label) {
    final isSelected = _selectedBloodType == value;

    return Material(
      color: TossDesignSystem.white.withValues(alpha: 0.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedBloodType = value;
          });
        },
        borderRadius: AppDimensions.borderRadiusSmall,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? TossDesignSystem.tossBlue : TossDesignSystem.gray200,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: AppDimensions.borderRadiusSmall,
            color: isSelected ? TossDesignSystem.tossBlue.withValues(alpha: 0.1) : null,
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.water_drop,
                  size: AppDimensions.iconSizeSmall,
                  color: isSelected
                      ? (Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.white : TossDesignSystem.grayDark900)
                      : (Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.gray300 : TossDesignSystem.gray600),
                ),
                const SizedBox(width: AppSpacing.spacing2),
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: isSelected
                        ? (Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.white : TossDesignSystem.grayDark900)
                        : null,
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