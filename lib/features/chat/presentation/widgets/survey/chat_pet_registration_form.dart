import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../data/models/pet_profile.dart';
import '../../../../../providers/pet_provider.dart';

/// 채팅 내 반려동물 등록 폼
///
/// 사용자가 새로운 반려동물을 등록할 수 있는 인라인 폼.
/// 필수 입력: 이름, 종류, 나이
/// 선택 입력: 성별, 성격
class ChatPetRegistrationForm extends ConsumerStatefulWidget {
  final void Function(PetProfile pet) onComplete;
  final VoidCallback? onCancel;

  const ChatPetRegistrationForm({
    super.key,
    required this.onComplete,
    this.onCancel,
  });

  @override
  ConsumerState<ChatPetRegistrationForm> createState() =>
      _ChatPetRegistrationFormState();
}

class _ChatPetRegistrationFormState
    extends ConsumerState<ChatPetRegistrationForm> {
  final _nameController = TextEditingController();
  String? _selectedSpecies;
  String? _selectedAge;
  String? _selectedGender;
  String? _selectedPersonality;
  bool _isSubmitting = false;

  static const _speciesOptions = [
    ('dog', '강아지', '🐕'),
    ('cat', '고양이', '🐈'),
    ('bird', '새', '🐦'),
    ('hamster', '햄스터', '🐹'),
    ('fish', '물고기', '🐟'),
    ('other', '기타', '🐾'),
  ];

  static const _ageOptions = [
    ('0', '1살 미만', '🍼'),
    ('2', '1-3살', '🐾'),
    ('5', '4-7살', '🎾'),
    ('9', '8살 이상', '🌟'),
  ];

  static const _genderOptions = [
    ('수컷', '수컷', '♂️'),
    ('암컷', '암컷', '♀️'),
    ('모름', '모름', '❓'),
  ];

  static const _personalityOptions = [
    ('활발함', '활발함', '⚡'),
    ('차분함', '차분함', '😌'),
    ('수줍음', '수줍음', '🙈'),
    ('애교쟁이', '애교쟁이', '🥰'),
  ];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty &&
      _selectedSpecies != null &&
      _selectedAge != null;

  Future<void> _submit() async {
    if (!_isValid || _isSubmitting) return;

    setState(() => _isSubmitting = true);

    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) {
        _showError('로그인이 필요합니다');
        return;
      }

      // 종류 라벨 가져오기
      final speciesLabel = _speciesOptions
          .firstWhere((e) => e.$1 == _selectedSpecies,
              orElse: () => ('other', '기타', '🐾'))
          .$2;

      // 나이 숫자로 변환
      final age = int.tryParse(_selectedAge ?? '2') ?? 2;

      final newPet = await ref.read(petProvider.notifier).createPet(
            userId: userId,
            species: speciesLabel,
            name: _nameController.text.trim(),
            age: age,
            gender: _selectedGender,
            personality: _selectedPersonality,
          );

      if (newPet != null) {
        widget.onComplete(newPet);
      } else {
        final error = ref.read(petProvider).error;
        _showError(error ?? '등록에 실패했습니다');
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = context.isDark;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      padding: const EdgeInsets.all(DSSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? colors.backgroundSecondary : colors.surface,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        border: Border.all(
          color: colors.textPrimary.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // 헤더
          Row(
            children: [
              const Text('🐾', style: TextStyle(fontSize: 20)),
              const SizedBox(width: DSSpacing.xs),
              Text(
                '반려동물 등록',
                style: typography.headingSmall.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (widget.onCancel != null)
                IconButton(
                  icon:
                      Icon(Icons.close, size: 20, color: colors.textSecondary),
                  onPressed: widget.onCancel,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: DSSpacing.md),

          // 이름 입력
          _buildLabel('이름', isRequired: true),
          const SizedBox(height: DSSpacing.xs),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              hintText: '반려동물 이름을 입력하세요',
              hintStyle: typography.bodyMedium.copyWith(
                color: colors.textSecondary,
              ),
              filled: true,
              fillColor: isDark
                  ? colors.background
                  : colors.textPrimary.withValues(alpha: 0.05),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(DSRadius.md),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.sm,
                vertical: DSSpacing.sm,
              ),
            ),
            style: typography.bodyMedium,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: DSSpacing.md),

          // 종류 선택
          _buildLabel('종류', isRequired: true),
          const SizedBox(height: DSSpacing.xs),
          _buildChipSelector(
            options: _speciesOptions,
            selectedValue: _selectedSpecies,
            onSelect: (value) => setState(() => _selectedSpecies = value),
          ),
          const SizedBox(height: DSSpacing.md),

          // 나이 선택
          _buildLabel('나이', isRequired: true),
          const SizedBox(height: DSSpacing.xs),
          _buildChipSelector(
            options: _ageOptions,
            selectedValue: _selectedAge,
            onSelect: (value) => setState(() => _selectedAge = value),
          ),
          const SizedBox(height: DSSpacing.md),

          // 성별 선택 (선택)
          _buildLabel('성별'),
          const SizedBox(height: DSSpacing.xs),
          _buildChipSelector(
            options: _genderOptions,
            selectedValue: _selectedGender,
            onSelect: (value) => setState(() => _selectedGender = value),
          ),
          const SizedBox(height: DSSpacing.md),

          // 성격 선택 (선택)
          _buildLabel('성격'),
          const SizedBox(height: DSSpacing.xs),
          _buildChipSelector(
            options: _personalityOptions,
            selectedValue: _selectedPersonality,
            onSelect: (value) => setState(() => _selectedPersonality = value),
          ),
          const SizedBox(height: DSSpacing.lg),

          // 등록 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isValid && !_isSubmitting ? _submit : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.ctaBackground,
                foregroundColor: colors.ctaForeground,
                disabledBackgroundColor:
                    colors.textSecondary.withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(DSRadius.md),
                ),
              ),
              child: _isSubmitting
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(colors.ctaForeground),
                      ),
                    )
                  : Text(
                      '등록하기',
                      style: typography.labelLarge.copyWith(
                        color: colors.ctaForeground,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(String text, {bool isRequired = false}) {
    final typography = context.typography;
    final colors = context.colors;

    return Row(
      children: [
        Text(
          text,
          style: typography.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (isRequired) ...[
          const SizedBox(width: 2),
          Text(
            '*',
            style: typography.labelMedium.copyWith(
              color: colors.error,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildChipSelector({
    required List<(String, String, String)> options,
    required String? selectedValue,
    required void Function(String) onSelect,
  }) {
    final colors = context.colors;
    final typography = context.typography;
    final isDark = context.isDark;

    return Wrap(
      spacing: DSSpacing.xs,
      runSpacing: DSSpacing.xs,
      children: options.map((option) {
        final (value, label, emoji) = option;
        final isSelected = selectedValue == value;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              DSHaptics.light();
              onSelect(value);
            },
            borderRadius: BorderRadius.circular(DSRadius.lg),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: DSSpacing.sm,
                vertical: DSSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: isSelected
                    ? colors.accentSecondary.withValues(alpha: 0.2)
                    : (isDark
                        ? colors.background
                        : colors.textPrimary.withValues(alpha: 0.05)),
                borderRadius: BorderRadius.circular(DSRadius.lg),
                border: Border.all(
                  color: isSelected
                      ? colors.accentSecondary
                      : colors.textPrimary.withValues(alpha: 0.2),
                  width: isSelected ? 1.5 : 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(emoji, style: const TextStyle(fontSize: 14)),
                  const SizedBox(width: DSSpacing.xs),
                  Text(
                    label,
                    style: typography.labelMedium.copyWith(
                      color: isSelected
                          ? colors.accentSecondary
                          : colors.textPrimary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(width: DSSpacing.xs),
                    Icon(
                      Icons.check,
                      size: 14,
                      color: colors.accentSecondary,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
