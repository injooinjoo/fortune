import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune/core/widgets/app_widgets.dart';
import 'package:fortune/core/widgets/unified_date_picker.dart';
import 'package:fortune/features/fortune/presentation/widgets/fortune_loading_skeleton.dart';
import 'package:fortune/presentation/providers/secondary_profiles_provider.dart';
import 'package:fortune/data/models/secondary_profile.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:fortune/core/design_system/components/traditional/traditional_button.dart';

class CompatibilityInputView extends ConsumerStatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController person1NameController;
  final TextEditingController person2NameController;
  final DateTime? person1BirthDate;
  final DateTime? person2BirthDate;
  final ValueChanged<DateTime?> onPerson1BirthDateChanged;
  final ValueChanged<DateTime?> onPerson2BirthDateChanged;
  final VoidCallback onAnalyze;
  final bool isLoading;
  final bool canAnalyze;

  /// 직접 입력 모드 변경 시 콜백 (프로필 추가 프롬프트 표시 여부 결정용)
  final ValueChanged<bool>? onManualInputChanged;

  const CompatibilityInputView({
    super.key,
    required this.formKey,
    required this.person1NameController,
    required this.person2NameController,
    required this.person1BirthDate,
    required this.person2BirthDate,
    required this.onPerson1BirthDateChanged,
    required this.onPerson2BirthDateChanged,
    required this.onAnalyze,
    required this.isLoading,
    required this.canAnalyze,
    this.onManualInputChanged,
  });

  @override
  ConsumerState<CompatibilityInputView> createState() =>
      _CompatibilityInputViewState();
}

class _CompatibilityInputViewState
    extends ConsumerState<CompatibilityInputView> {
  SecondaryProfile? _selectedProfile;
  bool _isManualInput = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final secondaryProfilesAsync = ref.watch(secondaryProfilesProvider);

    // 로딩 중일 때 스켈레톤 UI 표시
    if (widget.isLoading) {
      return _buildLoadingSkeleton(isDark);
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: widget.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 헤더 카드 - ChatGPT 스타일 (Center로 감싸서 중앙 정렬)
                const Center(
                  child: PageHeaderSection(
                    emoji: '💕',
                    title: '두 사람의 궁합',
                    subtitle: '이름과 생년월일을 입력하면\n두 사람의 궁합을 자세히 분석해드릴게요',
                  ),
                ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3),

                const SizedBox(height: 32),

                // 첫 번째 사람 정보 - 컴팩트 스타일
                _buildPerson1Label(),

                const SizedBox(height: 12),

                _buildPerson1Card(isDark),

                const SizedBox(height: 24),

                // 두 번째 사람 정보 - 프로필 선택 우선
                _buildPerson2Label(),

                const SizedBox(height: 16),

                // 프로필 선택 섹션
                secondaryProfilesAsync.when(
                  data: (profiles) => _buildProfileSelector(profiles, isDark),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),

                // 직접 입력 또는 선택된 프로필 표시
                _buildPerson2Card(isDark),

                const SizedBox(height: 20),

                Center(
                  child: Text(
                    '분석 결과는 참고용으로만 활용해 주세요',
                    style: TextStyle(
                      fontSize: 13, // 예외: 초소형 안내 문구
                      color: isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),

        // Floating 버튼 - 조건 미달성 시 숨김 (전통 스타일)
        if (widget.canAnalyze)
          Positioned(
            left: 20,
            right: 20,
            bottom: 32,
            child: TraditionalButton(
              text: '성향 매칭하기',
              hanja: '宮合',
              style: TraditionalButtonStyle.filled,
              colorScheme: TraditionalButtonColorScheme.love,
              isExpanded: true,
              height: 56,
              onPressed: widget.canAnalyze ? widget.onAnalyze : null,
            ),
          ),
      ],
    );
  }

  /// 프로필 선택 UI
  Widget _buildProfileSelector(List<SecondaryProfile> profiles, bool isDark) {
    if (profiles.isEmpty) {
      return const SizedBox.shrink();
    }

    final colors = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 등록된 프로필 칩 목록
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: profiles.length + 1, // +1 for "직접 입력"
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              // 마지막 아이템: 직접 입력
              if (index == profiles.length) {
                return _buildManualInputChip(colors);
              }

              final profile = profiles[index];
              final isSelected =
                  _selectedProfile?.id == profile.id && !_isManualInput;

              return _buildProfileChip(profile, isSelected, colors);
            },
          ),
        ).animate(delay: 150.ms).fadeIn().slideX(begin: 0.1),

        const SizedBox(height: 16),
      ],
    );
  }

  /// 프로필 선택 칩
  Widget _buildProfileChip(
      SecondaryProfile profile, bool isSelected, DSColorScheme colors) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        setState(() {
          _selectedProfile = profile;
          _isManualInput = false;
        });
        // 프로필 정보로 입력 필드 채우기
        widget.person2NameController.text = profile.name;
        widget.onPerson2BirthDateChanged(profile.birthDateTime);
        // 프로필 선택 시 직접 입력 모드 해제 알림
        widget.onManualInputChanged?.call(false);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colors.accent : colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colors.accent : colors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 관계 아이콘
            Text(
              _getRelationshipEmoji(profile.relationship),
              style: const TextStyle(fontSize: 16), // 예외: 이모지
            ),
            const SizedBox(width: 6),
            Text(
              profile.name,
              style: DSTypography.bodyMedium.copyWith(
                color: isSelected ? Colors.white : colors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.check_circle,
                size: 16,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 직접 입력 칩
  Widget _buildManualInputChip(DSColorScheme colors) {
    final isSelected = _isManualInput;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        setState(() {
          _selectedProfile = null;
          _isManualInput = true;
        });
        // 입력 필드 초기화
        widget.person2NameController.clear();
        widget.onPerson2BirthDateChanged(null);
        // 직접 입력 모드 활성화 알림
        widget.onManualInputChanged?.call(true);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colors.accent : colors.backgroundSecondary,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? colors.accent : colors.border,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.edit_outlined,
              size: 16,
              color: isSelected ? Colors.white : colors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              '직접 입력',
              style: DSTypography.bodyMedium.copyWith(
                color: isSelected ? Colors.white : colors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 관계 이모지
  String _getRelationshipEmoji(String? relationship) {
    switch (relationship) {
      case 'family':
        return '👨‍👩‍👧';
      case 'friend':
        return '👫';
      case 'lover':
        return '💑';
      default:
        return '👤';
    }
  }

  /// 로딩 스켈레톤 UI
  Widget _buildLoadingSkeleton(bool isDark) {
    return const SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: FortuneLoadingSkeleton(
        itemCount: 4,
        showHeader: true,
        loadingMessages: [
          '두 분의 궁합을 분석하고 있어요...',
          '사주팔자를 확인하는 중...',
          '운명의 연결고리를 찾는 중...',
          '특별한 인연을 분석하는 중...',
        ],
      ),
    );
  }

  Widget _buildPerson1Label() {
    return const FieldLabel(text: '👤 나의 정보');
  }

  Widget _buildPerson1Card(bool isDark) {
    return ModernCard(
      child: Column(
        children: [
          PillTextField(
            controller: widget.person1NameController,
            labelText: '이름',
            hintText: '이름을 입력해주세요',
          ),

          const SizedBox(height: 12),

          UnifiedDatePicker(
            mode: UnifiedDatePickerMode.numeric,
            selectedDate: widget.person1BirthDate,
            onDateChanged: (date) {
              widget.onPerson1BirthDateChanged(date);
              HapticFeedback.mediumImpact();
            },
            label: '생년월일',
            minDate: DateTime(1900),
            maxDate: DateTime.now(),
            showAge: false,
          ),
        ],
      ),
    ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.3);
  }

  Widget _buildPerson2Label() {
    return const FieldLabel(text: '💕 상대방 정보');
  }

  Widget _buildPerson2Card(bool isDark) {
    // 선택된 프로필이 있으면 읽기 전용으로 표시
    final hasSelectedProfile = _selectedProfile != null && !_isManualInput;

    return ModernCard(
      child: Column(
        children: [
          PillTextField(
            controller: widget.person2NameController,
            labelText: '이름',
            hintText: '상대방 이름을 입력해주세요',
            readOnly: hasSelectedProfile,
          ),

          const SizedBox(height: 16),

          UnifiedDatePicker(
            mode: UnifiedDatePickerMode.numeric,
            selectedDate: widget.person2BirthDate,
            onDateChanged: (date) {
              if (!hasSelectedProfile) {
                widget.onPerson2BirthDateChanged(date);
                HapticFeedback.mediumImpact();
              }
            },
            label: '상대방 생년월일',
            minDate: DateTime(1900),
            maxDate: DateTime.now(),
            showAge: false,
          ),
        ],
      ),
    ).animate(delay: 200.ms).fadeIn().slideY(begin: 0.3);
  }
}
