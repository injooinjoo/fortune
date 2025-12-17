import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/typography_unified.dart';
import '../../../core/theme/app_theme/fortune_theme_extension.dart';
import '../../../presentation/providers/secondary_profiles_provider.dart';

/// 프로필 추가 바텀시트
///
/// 가족/친구의 정보를 입력받아 새 프로필 생성
class AddProfileSheet extends ConsumerStatefulWidget {
  /// 미리 채울 이름 (궁합에서 직접 입력 후 호출 시)
  final String? initialName;

  /// 미리 채울 생년월일 (궁합에서 직접 입력 후 호출 시)
  final DateTime? initialBirthDate;

  /// 커스텀 타이틀 (기본: '프로필 추가')
  final String? title;

  /// 커스텀 서브타이틀 (기본: '가족이나 친구의 운세를 확인할 수 있어요')
  final String? subtitle;

  const AddProfileSheet({
    super.key,
    this.initialName,
    this.initialBirthDate,
    this.title,
    this.subtitle,
  });

  @override
  ConsumerState<AddProfileSheet> createState() => _AddProfileSheetState();
}

class _AddProfileSheetState extends ConsumerState<AddProfileSheet> {
  final _nameController = TextEditingController();
  String? _birthDate;
  String? _birthTime;
  String _gender = 'male';
  bool _isLunar = false;
  String _relationship = 'family';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // 초기값 설정 (궁합에서 직접 입력 후 호출 시)
    if (widget.initialName != null) {
      _nameController.text = widget.initialName!;
    }
    if (widget.initialBirthDate != null) {
      _birthDate = _formatDate(widget.initialBirthDate!);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isValid => _nameController.text.trim().isNotEmpty && _birthDate != null;

  @override
  Widget build(BuildContext context) {
    final fortuneTheme = context.fortuneTheme;

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: fortuneTheme.cardBackground,
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
                    color: fortuneTheme.dividerColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 타이틀
              Text(widget.title ?? '프로필 추가', style: context.heading2),
              const SizedBox(height: 8),
              Text(
                widget.subtitle ?? '가족이나 친구의 운세를 확인할 수 있어요',
                style: context.bodyMedium.copyWith(
                  color: fortuneTheme.secondaryText,
                ),
              ),
              const SizedBox(height: 24),

              // 이름 입력
              _buildSectionTitle('이름'),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: '이름을 입력해주세요',
                  hintStyle: context.bodyMedium.copyWith(
                    color: fortuneTheme.secondaryText,
                  ),
                  filled: true,
                  fillColor: fortuneTheme.cardSurface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: fortuneTheme.dividerColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: fortuneTheme.dividerColor),
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
                style: context.bodyLarge.copyWith(
                  color: fortuneTheme.primaryText,
                ),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 20),

              // 관계 선택
              _buildSectionTitle('관계'),
              const SizedBox(height: 8),
              Row(
                children: [
                  _RelationshipChip(
                    label: '가족',
                    value: 'family',
                    selected: _relationship == 'family',
                    onTap: () => setState(() => _relationship = 'family'),
                  ),
                  const SizedBox(width: 8),
                  _RelationshipChip(
                    label: '친구',
                    value: 'friend',
                    selected: _relationship == 'friend',
                    onTap: () => setState(() => _relationship = 'friend'),
                  ),
                  const SizedBox(width: 8),
                  _RelationshipChip(
                    label: '기타',
                    value: 'other',
                    selected: _relationship == 'other',
                    onTap: () => setState(() => _relationship = 'other'),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // 생년월일 선택
              _buildSectionTitle('생년월일'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _selectBirthDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: fortuneTheme.cardSurface,
                    border: Border.all(color: fortuneTheme.dividerColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _birthDate ?? '생년월일을 선택해주세요',
                        style: context.bodyLarge.copyWith(
                          color: _birthDate != null
                              ? fortuneTheme.primaryText
                              : fortuneTheme.secondaryText,
                        ),
                      ),
                      Icon(
                        Icons.calendar_today_outlined,
                        color: fortuneTheme.secondaryText,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

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
                    const SizedBox(width: 8),
                    Text(
                      '음력',
                      style: context.bodyMedium.copyWith(
                        color: fortuneTheme.primaryText,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // 태어난 시간 (선택)
              _buildSectionTitle('태어난 시간 (선택)'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: _selectBirthTime,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: fortuneTheme.cardSurface,
                    border: Border.all(color: fortuneTheme.dividerColor),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _birthTime ?? '모름',
                        style: context.bodyLarge.copyWith(
                          color: _birthTime != null
                              ? fortuneTheme.primaryText
                              : fortuneTheme.secondaryText,
                        ),
                      ),
                      Icon(
                        Icons.access_time_outlined,
                        color: fortuneTheme.secondaryText,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // 성별 선택
              _buildSectionTitle('성별'),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _GenderButton(
                      label: '남성',
                      selected: _gender == 'male',
                      onTap: () => setState(() => _gender = 'male'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _GenderButton(
                      label: '여성',
                      selected: _gender == 'female',
                      onTap: () => setState(() => _gender = 'female'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

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
                    disabledBackgroundColor: fortuneTheme.dividerColor,
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
                          '저장',
                          style: context.buttonLarge.copyWith(
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
    final fortuneTheme = context.fortuneTheme;
    return Text(
      title,
      style: context.bodyMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: fortuneTheme.primaryText,
      ),
    );
  }

  Future<void> _selectBirthDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('ko', 'KR'),
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
    if (date != null) {
      setState(() {
        _birthDate =
            '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      });
    }
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
      await ref.read(secondaryProfilesProvider.notifier).addProfile(
            name: _nameController.text.trim(),
            birthDate: _birthDate!,
            birthTime: _birthTime,
            gender: _gender,
            isLunar: _isLunar,
            relationship: _relationship,
          );

      if (mounted) {
        Navigator.pop(context, true); // 성공 시 true 반환
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
            backgroundColor: context.fortuneTheme.errorColor,
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

/// 관계 선택 칩
class _RelationshipChip extends StatelessWidget {
  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  const _RelationshipChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fortuneTheme = context.fortuneTheme;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? primaryColor : fortuneTheme.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? primaryColor : fortuneTheme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: context.bodyMedium.copyWith(
            color: selected ? Colors.white : fortuneTheme.primaryText,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

/// 성별 선택 버튼
class _GenderButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenderButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fortuneTheme = context.fortuneTheme;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? primaryColor : fortuneTheme.cardSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? primaryColor : fortuneTheme.dividerColor,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: context.bodyLarge.copyWith(
              color: selected ? Colors.white : fortuneTheme.primaryText,
              fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
