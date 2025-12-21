import 'package:flutter/material.dart';
import '../../../core/theme/fortune_design_system.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_dimensions.dart';
import '../../../constants/fortune_constants.dart';
import 'profile_field_edit_dialog.dart';

class MbtiEditDialog extends StatefulWidget {
  final String? initialMbti;
  final Function(String?) onSave;

  const MbtiEditDialog({
    super.key,
    this.initialMbti,
    required this.onSave});

  @override
  State<MbtiEditDialog> createState() => _MbtiEditDialogState();
}

class _MbtiEditDialogState extends State<MbtiEditDialog> {
  String? _selectedMbti;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedMbti = widget.initialMbti?.toUpperCase();
  }

  void _handleSave() async {
    setState(() => _isLoading = true);
    
    try {
      await widget.onSave(_selectedMbti?.toLowerCase());
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('발생했습니다: ${e.toString()}'),
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
      title: 'MBTI 수정',
      isLoading: _isLoading,
      onSave: _handleSave,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'MBTI 성격 유형을 선택해주세요',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? TossDesignSystem.gray300
                  : TossDesignSystem.gray600,
            ),
          ),
          SizedBox(height: AppSpacing.spacing2),
          InkWell(
            onTap: () {
              // TODO: Open web browser to MBTI test
            },
            child: Text(
              'MBTI를 모르시나요? 테스트 하러 가기 →',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: TossDesignSystem.tossBlue,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          SizedBox(height: AppSpacing.spacing5),
          Container(
            constraints: const BoxConstraints(maxHeight: 300),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 1.8),
                    itemCount: mbtiTypes.length,
                    itemBuilder: (context, index) {
                      final mbti = mbtiTypes[index];
                      return _buildMbtiOption(mbti);
                    }),
                  SizedBox(height: AppSpacing.spacing3),
                  _buildMbtiOption(null, '선택 안함'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMbtiOption(String? value, [String? customLabel]) {
    final isSelected = _selectedMbti == value;
    final label = customLabel ?? value ?? '';
    
    return Material(
      color: TossDesignSystem.white.withValues(alpha: 0.0),
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedMbti = value;
          });
        },
        borderRadius: AppDimensions.borderRadiusSmall,
        child: Container(
          padding: AppSpacing.paddingVertical8,
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? TossDesignSystem.tossBlue : TossDesignSystem.gray200,
              width: isSelected ? 2 : 1),
            borderRadius: AppDimensions.borderRadiusSmall,
            color: isSelected ? TossDesignSystem.tossBlue.withValues(alpha: 0.1) : TossDesignSystem.white.withValues(alpha: 0.0)),
          child: Center(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: isSelected
                    ? (Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.white : TossDesignSystem.grayDark900)
                    : (Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.gray300 : TossDesignSystem.gray900),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}