import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/design_system/design_system.dart';
import '../../../../data/models/pet_profile.dart';
import '../../../../presentation/providers/pet_profiles_provider.dart';

class PetProfileCreateSheet extends ConsumerStatefulWidget {
  const PetProfileCreateSheet({super.key});

  static Future<PetProfile?> show(BuildContext context) {
    return DSBottomSheet.show<PetProfile>(
      context: context,
      title: '반려동물 등록',
      showClose: true,
      isScrollable: true,
      child: const PetProfileCreateSheet(),
    );
  }

  @override
  ConsumerState<PetProfileCreateSheet> createState() =>
      _PetProfileCreateSheetState();
}

class _PetProfileCreateSheetState extends ConsumerState<PetProfileCreateSheet> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _speciesController = TextEditingController();

  bool _isSubmitting = false;
  bool _submitted = false;

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    super.dispose();
  }

  String? get _nameError {
    if (!_submitted && _nameController.text.trim().isEmpty) {
      return null;
    }
    return _nameController.text.trim().isEmpty ? '이름을 입력해주세요.' : null;
  }

  String? get _speciesError {
    if (!_submitted && _speciesController.text.trim().isEmpty) {
      return null;
    }
    return _speciesController.text.trim().isEmpty ? '종류를 입력해주세요.' : null;
  }

  Future<void> _submit() async {
    setState(() {
      _submitted = true;
    });

    if (_nameError != null || _speciesError != null) {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final profile = await ref.read(petProfilesProvider.notifier).addProfile(
            name: _nameController.text.trim(),
            species: _speciesController.text.trim(),
          );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(profile);
    } catch (_) {
      if (!mounted) {
        return;
      }

      DSToast.error(context, '반려동물 등록에 실패했어요. 다시 시도해주세요.');
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      key: const ValueKey('pet-profile-create-sheet'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '반려동물 이름과 종류만 입력하면 바로 선택해서 이어서 볼 수 있어요.',
          style: context.bodyMedium.copyWith(
            color: colors.textSecondary,
          ),
        ),
        const SizedBox(height: DSSpacing.lg),
        DSTextField(
          key: const ValueKey('pet-create-name-field'),
          label: '이름',
          placeholder: '예: 복실이',
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
        DSTextField(
          key: const ValueKey('pet-create-species-field'),
          label: '종류',
          placeholder: '예: 강아지, 고양이',
          controller: _speciesController,
          errorText: _speciesError,
          textInputAction: TextInputAction.done,
          onChanged: (_) {
            if (_submitted) {
              setState(() {});
            }
          },
          onSubmitted: (_) => _submit(),
        ),
        const SizedBox(height: DSSpacing.xl),
        Row(
          children: [
            Expanded(
              child: DSButton.secondary(
                key: const ValueKey('pet-create-cancel-button'),
                text: '취소',
                onPressed:
                    _isSubmitting ? null : () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: DSSpacing.sm),
            Expanded(
              child: DSButton.primary(
                key: const ValueKey('pet-create-submit-button'),
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
