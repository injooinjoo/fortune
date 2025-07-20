import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../constants/fortune_constants.dart';
import 'profile_field_edit_dialog.dart';

class MbtiEditDialog extends StatefulWidget {
  final String? initialMbti;
  final Function(String?) onSave;

  const MbtiEditDialog({
    super.key,
    this.initialMbti,
    required this.onSave,
  });

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
      title: 'MBTI 수정',
      isLoading: _isLoading,
      onSave: _handleSave,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'MBTI 성격 유형을 선택해주세요',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: () {
              // TODO: Open web browser to MBTI test
            },
            child: const Text(
              'MBTI를 모르시나요? 테스트 하러 가기 →',
              style: TextStyle(
                color: AppColors.primary,
                fontSize: 12,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
          const SizedBox(height: 20),
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
                      childAspectRatio: 1.8,
                    ),
                    itemCount: mbtiTypes.length,
                    itemBuilder: (context, index) {
                      final mbti = mbtiTypes[index];
                      return _buildMbtiOption(mbti);
                    },
                  ),
                  const SizedBox(height: 12),
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
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedMbti = value;
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(8),
            color: isSelected ? AppColors.primary : Colors.white,
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}