import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design_system/design_system.dart';
import '../../../core/extensions/l10n_extension.dart';
import '../../../core/widgets/date_picker/numeric_date_input.dart';
import '../../../presentation/providers/secondary_profiles_provider.dart';

/// 프로필 추가 바텀시트
///
/// 가족/친구/애인의 정보를 입력받아 새 프로필 생성
class AddProfileSheet extends ConsumerStatefulWidget {
  /// 미리 채울 이름 (궁합에서 직접 입력 후 호출 시)
  final String? initialName;

  /// 미리 채울 생년월일 (궁합에서 직접 입력 후 호출 시)
  final DateTime? initialBirthDate;

  /// 커스텀 타이틀 (기본: '프로필 추가')
  final String? title;

  /// 커스텀 서브타이틀 (기본: '가족이나 친구의 운세를 확인할 수 있어요')
  final String? subtitle;

  /// 기본 관계 설정 (family/friend/lover/other)
  final String? defaultRelationship;

  /// 기본 가족 세부 관계 (parents/spouse/children/siblings)
  /// defaultRelationship이 'family'일 때만 사용
  final String? defaultFamilyRelation;

  const AddProfileSheet({
    super.key,
    this.initialName,
    this.initialBirthDate,
    this.title,
    this.subtitle,
    this.defaultRelationship,
    this.defaultFamilyRelation,
  });

  @override
  ConsumerState<AddProfileSheet> createState() => _AddProfileSheetState();
}

class _AddProfileSheetState extends ConsumerState<AddProfileSheet> {
  final _nameController = TextEditingController();
  DateTime? _birthDate;
  String? _birthTime;
  String _gender = 'male';
  bool _isLunar = false;
  String _relationship = 'family';
  String? _familyRelation; // 가족 세부 관계
  String? _mbti;
  String? _bloodType;
  bool _isLoading = false;

  // 관계 옵션
  static const List<Map<String, String>> _relationshipOptions = [
    {'value': 'family', 'label': '가족', 'emoji': '👨‍👩‍👧'},
    {'value': 'friend', 'label': '친구', 'emoji': '👫'},
    {'value': 'lover', 'label': '애인', 'emoji': '💑'},
    {'value': 'other', 'label': '기타', 'emoji': '👤'},
  ];

  // 가족 세부 관계 옵션
  static const List<Map<String, String>> _familyRelationOptions = [
    {'value': 'parents', 'label': '부모님', 'emoji': '👴👵'},
    {'value': 'spouse', 'label': '배우자', 'emoji': '💑'},
    {'value': 'children', 'label': '자녀', 'emoji': '👶'},
    {'value': 'siblings', 'label': '형제자매', 'emoji': '👫'},
  ];

  // MBTI 목록
  static const List<String> _mbtiTypes = [
    'ISTJ',
    'ISFJ',
    'INFJ',
    'INTJ',
    'ISTP',
    'ISFP',
    'INFP',
    'INTP',
    'ESTP',
    'ESFP',
    'ENFP',
    'ENTP',
    'ESTJ',
    'ESFJ',
    'ENFJ',
    'ENTJ',
  ];

  // 혈액형 목록
  static const List<String> _bloodTypes = ['A', 'B', 'O', 'AB'];

  @override
  void initState() {
    super.initState();
    if (widget.initialName != null) {
      _nameController.text = widget.initialName!;
    }
    if (widget.initialBirthDate != null) {
      _birthDate = widget.initialBirthDate;
    }
    // 기본 관계 설정
    if (widget.defaultRelationship != null) {
      _relationship = widget.defaultRelationship!;
    }
    // 기본 가족 세부 관계 설정
    if (widget.defaultFamilyRelation != null) {
      _familyRelation = widget.defaultFamilyRelation;
    }
  }

  String _formatDateString(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _nameController.text.trim().isNotEmpty && _birthDate != null;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // 핸들바
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: DSSpacing.lg),

              // 타이틀 + 닫기 버튼
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(widget.title ?? '프로필 추가',
                        style: context.typography.headingLarge),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.close,
                      color: colors.textSecondary,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: DSSpacing.sm),
              Text(
                widget.subtitle ?? '가족이나 친구의 운세를 확인할 수 있어요',
                style: context.typography.bodyMedium.copyWith(
                  color: colors.textSecondary,
                ),
              ),
              const SizedBox(height: DSSpacing.lg),

              // 이름 입력
              _buildSectionTitle('이름'),
              const SizedBox(height: DSSpacing.sm),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: '이름을 입력해주세요',
                  hintStyle: context.typography.bodyMedium.copyWith(
                    color: colors.textSecondary,
                  ),
                  filled: true,
                  fillColor: colors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: colors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                style: context.typography.bodyLarge.copyWith(
                  color: colors.textPrimary,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: DSSpacing.lg),

              // 관계 선택 (칩 스타일)
              _buildSectionTitle('관계'),
              const SizedBox(height: 12),
              _buildRelationshipChips(colors),
              const SizedBox(height: DSSpacing.lg),

              // 가족 세부 관계 선택 (관계가 '가족'일 때만 표시)
              if (_relationship == 'family') ...[
                _buildSectionTitle('가족 구성원'),
                const SizedBox(height: 12),
                _buildFamilyRelationChips(colors),
                const SizedBox(height: DSSpacing.lg),
              ],

              // 생년월일 선택
              _buildSectionTitle('생년월일'),
              const SizedBox(height: DSSpacing.sm),
              NumericDateInput(
                selectedDate: _birthDate,
                onDateChanged: (date) {
                  setState(() {
                    _birthDate = date;
                  });
                },
                minDate: DateTime(1900),
                // maxDate 미지정 → 2100년까지 허용 (출산 예정일 등)
                showAge: true,
              ),
              const SizedBox(height: DSSpacing.sm),

              // 음력 체크박스
              GestureDetector(
                onTap: () => setState(() => _isLunar = !_isLunar),
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _isLunar,
                        onChanged: (v) => setState(() => _isLunar = v ?? false),
                        activeColor: Theme.of(context).colorScheme.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: DSSpacing.sm),
                    Text(
                      '음력',
                      style: context.typography.bodyMedium.copyWith(
                        color: colors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: DSSpacing.lg),

              // 태어난 시간 (선택)
              _buildSectionTitle('태어난 시간 (선택)'),
              const SizedBox(height: DSSpacing.sm),
              GestureDetector(
                onTap: _selectBirthTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    border: Border.all(color: colors.border),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _birthTime ?? '모름',
                        style: context.typography.bodyLarge.copyWith(
                          color: _birthTime != null
                              ? colors.textPrimary
                              : colors.textSecondary,
                        ),
                      ),
                      Icon(
                        Icons.access_time_outlined,
                        color: colors.textSecondary,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: DSSpacing.lg),

              // 성별 선택 (칩 스타일)
              _buildSectionTitle('성별'),
              const SizedBox(height: 12),
              _buildGenderChips(colors),
              const SizedBox(height: DSSpacing.lg),

              // MBTI 선택 (선택)
              _buildSectionTitle('MBTI (선택)'),
              const SizedBox(height: 12),
              _buildMbtiGrid(colors),
              const SizedBox(height: DSSpacing.lg),

              // 혈액형 선택 (선택)
              _buildSectionTitle('혈액형 (선택)'),
              const SizedBox(height: 12),
              _buildBloodTypeChips(colors),
              const SizedBox(height: DSSpacing.xl),

              // 저장 버튼
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isValid && !_isLoading ? _saveProfile : null,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    disabledBackgroundColor: colors.divider,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          context.l10n.save,
                          style: context.typography.buttonLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    final colors = context.colors;
    return Text(
      title,
      style: context.typography.bodyMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: colors.textPrimary,
      ),
    );
  }

  /// 관계 선택 칩
  Widget _buildRelationshipChips(DSColorScheme colors) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _relationshipOptions.map((option) {
        final isSelected = _relationship == option['value'];
        return _buildSelectionChip(
          label: '${option['emoji']} ${option['label']}',
          isSelected: isSelected,
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() {
              _relationship = option['value']!;
              // 가족이 아닌 경우 familyRelation 초기화
              if (_relationship != 'family') {
                _familyRelation = null;
              }
            });
          },
          colors: colors,
        );
      }).toList(),
    );
  }

  /// 가족 세부 관계 선택 칩
  Widget _buildFamilyRelationChips(DSColorScheme colors) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _familyRelationOptions.map((option) {
        final isSelected = _familyRelation == option['value'];
        return _buildSelectionChip(
          label: '${option['emoji']} ${option['label']}',
          isSelected: isSelected,
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _familyRelation = option['value']!);
          },
          colors: colors,
        );
      }).toList(),
    );
  }

  /// 성별 선택 칩
  Widget _buildGenderChips(DSColorScheme colors) {
    return Row(
      children: [
        _buildSelectionChip(
          label: '♂ 남성',
          isSelected: _gender == 'male',
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _gender = 'male');
          },
          colors: colors,
        ),
        const SizedBox(width: DSSpacing.sm),
        _buildSelectionChip(
          label: '♀ 여성',
          isSelected: _gender == 'female',
          onTap: () {
            HapticFeedback.lightImpact();
            setState(() => _gender = 'female');
          },
          colors: colors,
        ),
      ],
    );
  }

  /// MBTI 선택 그리드
  Widget _buildMbtiGrid(DSColorScheme colors) {
    return Column(
      children: [
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _mbtiTypes.map((type) {
            final isSelected = _mbti == type;
            return _buildSelectionChip(
              label: type,
              isSelected: isSelected,
              onTap: () {
                HapticFeedback.lightImpact();
                setState(() => _mbti = type);
              },
              colors: colors,
              compact: true,
            );
          }).toList(),
        ),
        const SizedBox(height: DSSpacing.sm),
        TextButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            setState(() => _mbti = null);
          },
          child: Text(
            '모르겠어요',
            style: context.typography.bodySmall.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  /// 혈액형 선택 칩
  Widget _buildBloodTypeChips(DSColorScheme colors) {
    return Column(
      children: [
        Row(
          children: _bloodTypes.map((type) {
            final isSelected = _bloodType == type;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _buildSelectionChip(
                label: '$type형',
                isSelected: isSelected,
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _bloodType = type);
                },
                colors: colors,
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: DSSpacing.sm),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              setState(() => _bloodType = null);
            },
            child: Text(
              '모르겠어요',
              style: context.typography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// 공통 선택 칩 위젯 (채팅 페이지와 동일한 스타일)
  Widget _buildSelectionChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required DSColorScheme colors,
    bool compact = false,
  }) {
    final isDark = context.isDark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(DSRadius.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 16,
            vertical: compact ? 8 : 10,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? colors.textPrimary.withValues(alpha: 0.1)
                : (isDark ? colors.backgroundSecondary : colors.surface),
            borderRadius: BorderRadius.circular(DSRadius.lg),
            border: Border.all(
              color: isSelected
                  ? colors.textPrimary
                  : colors.textPrimary.withValues(alpha: 0.2),
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: context.typography.bodyMedium.copyWith(
                  color: isSelected ? colors.textPrimary : colors.textPrimary,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: DSSpacing.xs),
                Icon(
                  Icons.check,
                  size: 14,
                  color: colors.textPrimary,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectBirthTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() {
        _birthTime =
            '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_isValid) return;

    setState(() => _isLoading = true);

    try {
      final newProfile = await ref
          .read(secondaryProfilesProvider.notifier)
          .addProfile(
            name: _nameController.text.trim(),
            birthDate: _formatDateString(_birthDate!),
            birthTime: _birthTime,
            gender: _gender,
            isLunar: _isLunar,
            relationship: _relationship,
            familyRelation: _relationship == 'family' ? _familyRelation : null,
            mbti: _mbti,
            bloodType: _bloodType,
          );

      if (mounted) {
        Navigator.pop(context, newProfile); // 성공 시 생성된 프로필 반환
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_nameController.text.trim()} 프로필이 추가되었습니다'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = '프로필 추가에 실패했습니다';
        if (e.toString().contains('Maximum 5 secondary profiles')) {
          errorMessage = '프로필은 최대 5개까지 등록할 수 있습니다';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            behavior: SnackBarBehavior.floating,
            backgroundColor: context.colors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
