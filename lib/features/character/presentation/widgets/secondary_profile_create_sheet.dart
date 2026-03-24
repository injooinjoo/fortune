import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../data/models/secondary_profile.dart';
import '../../../../presentation/providers/secondary_profiles_provider.dart';

class SecondaryProfileCreateSheet extends ConsumerStatefulWidget {
  const SecondaryProfileCreateSheet({
    super.key,
    this.selectedFamilyMember,
  });

  final String? selectedFamilyMember;

  static Future<SecondaryProfile?> show(
    BuildContext context, {
    String? selectedFamilyMember,
  }) {
    final title = selectedFamilyMember == null ? '프로필 등록' : '가족 프로필 등록';

    return DSBottomSheet.show<SecondaryProfile>(
      context: context,
      title: title,
      showClose: true,
      isScrollable: true,
      child: SecondaryProfileCreateSheet(
        selectedFamilyMember: selectedFamilyMember,
      ),
    );
  }

  @override
  ConsumerState<SecondaryProfileCreateSheet> createState() =>
      _SecondaryProfileCreateSheetState();
}

class _SecondaryProfileCreateSheetState
    extends ConsumerState<SecondaryProfileCreateSheet> {
  final TextEditingController _nameController = TextEditingController();

  DateTime? _birthDate;
  String? _gender;
  bool _isSubmitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  String? get _nameError {
    if (!_submitted && _nameController.text.trim().isEmpty) {
      return null;
    }
    return _nameController.text.trim().isEmpty ? '이름을 입력해주세요.' : null;
  }

  String? get _birthDateError {
    if (!_submitted && _birthDate == null) {
      return null;
    }
    return _birthDate == null ? '생년월일을 선택해주세요.' : null;
  }

  String? get _genderError {
    if (!_submitted && _gender == null) {
      return null;
    }
    return _gender == null ? '성별을 선택해주세요.' : null;
  }

  String get _selectedFamilyMemberLabel {
    switch (widget.selectedFamilyMember) {
      case 'parents':
        return '부모님';
      case 'spouse':
        return '배우자';
      case 'children':
        return '자녀';
      case 'siblings':
        return '형제자매';
      default:
        return '가족';
    }
  }

  String get _birthDateLabel {
    final date = _birthDate;
    if (date == null) {
      return '생년월일 선택';
    }

    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}.$month.$day';
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: '생년월일 선택',
    );

    if (picked == null || !mounted) {
      return;
    }

    setState(() {
      _birthDate = picked;
    });
  }

  Future<void> _submit() async {
    setState(() {
      _submitted = true;
    });

    if (_nameError != null || _birthDateError != null || _genderError != null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final birthDate = _birthDate!;
    final birthDateText =
        '${birthDate.year}-${birthDate.month.toString().padLeft(2, '0')}-${birthDate.day.toString().padLeft(2, '0')}';

    try {
      final profile =
          await ref.read(secondaryProfilesProvider.notifier).addProfile(
                name: _nameController.text.trim(),
                birthDate: birthDateText,
                gender: _gender!,
                relationship:
                    widget.selectedFamilyMember == null ? 'other' : 'family',
                familyRelation: widget.selectedFamilyMember,
              );

      if (!mounted || profile == null) {
        return;
      }

      Navigator.of(context).pop(profile);
    } catch (_) {
      if (!mounted) {
        return;
      }

      DSToast.error(context, '프로필 등록에 실패했어요. 다시 시도해주세요.');
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final helperText = widget.selectedFamilyMember == null
        ? '이름, 생년월일, 성별을 입력하면 저장 프로필로 바로 사용할 수 있어요.'
        : '$_selectedFamilyMemberLabel 정보를 등록하면 바로 선택해서 가족 운세를 이어서 볼 수 있어요.';

    return Column(
      key: const ValueKey('secondary-profile-create-sheet'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          helperText,
          style: context.bodyMedium.copyWith(
            color: colors.textSecondary,
          ),
        ),
        if (widget.selectedFamilyMember != null) ...[
          const SizedBox(height: DSSpacing.md),
          Text(
            '저장 관계: $_selectedFamilyMemberLabel',
            style: context.labelMedium.copyWith(
              color: colors.textPrimary,
            ),
          ),
        ],
        const SizedBox(height: DSSpacing.lg),
        DSTextField(
          key: const ValueKey('secondary-create-name-field'),
          label: '이름',
          placeholder: '예: 엄마, 아빠, 동생',
          controller: _nameController,
          errorText: _nameError,
          textInputAction: TextInputAction.next,
          onChanged: (_) {
            if (_submitted) {
              setState(() {});
            }
          },
        ),
        const SizedBox(height: DSSpacing.md),
        Text(
          '생년월일',
          style: context.labelMedium.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: DSSpacing.sm),
        DSButton.outline(
          key: const ValueKey('secondary-create-birthdate-button'),
          text: _birthDateLabel,
          leadingIcon: Icons.calendar_today_outlined,
          onPressed: _isSubmitting ? null : _pickBirthDate,
        ),
        if (_birthDateError != null) ...[
          const SizedBox(height: DSSpacing.xs),
          Text(
            _birthDateError!,
            style: context.bodySmall.copyWith(color: colors.error),
          ),
        ],
        const SizedBox(height: DSSpacing.md),
        Text(
          '성별',
          style: context.labelMedium.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: DSSpacing.sm),
        DSChoiceChips(
          options: const ['남성', '여성'],
          selected: _gender == null ? null : (_gender == 'male' ? 0 : 1),
          onSelected: (index) {
            setState(() {
              _gender = index == 0 ? 'male' : 'female';
            });
          },
        ),
        if (_genderError != null) ...[
          const SizedBox(height: DSSpacing.xs),
          Text(
            _genderError!,
            style: context.bodySmall.copyWith(color: colors.error),
          ),
        ],
        const SizedBox(height: DSSpacing.xl),
        Row(
          children: [
            Expanded(
              child: DSButton.secondary(
                key: const ValueKey('secondary-create-cancel-button'),
                text: '취소',
                onPressed:
                    _isSubmitting ? null : () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: DSSpacing.sm),
            Expanded(
              child: DSButton.primary(
                key: const ValueKey('secondary-create-submit-button'),
                text: '등록하기',
                isLoading: _isSubmitting,
                onPressed: _isSubmitting ? null : _submit,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
