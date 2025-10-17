import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../shared/components/glass_container.dart';

// ==================== State Management ====================

/// 행운 아이템 데이터 모델
class LuckyItemsData {
  DateTime? birthDate;
  TimeOfDay? birthTime;
  String? gender;
  List<String> selectedInterests;

  LuckyItemsData({
    this.birthDate,
    this.birthTime,
    this.gender,
    this.selectedInterests = const [],
  });

  LuckyItemsData copyWith({
    DateTime? birthDate,
    TimeOfDay? birthTime,
    String? gender,
    List<String>? selectedInterests,
  }) {
    return LuckyItemsData(
      birthDate: birthDate ?? this.birthDate,
      birthTime: birthTime ?? this.birthTime,
      gender: gender ?? this.gender,
      selectedInterests: selectedInterests ?? this.selectedInterests,
    );
  }
}

/// 단계 관리 StateNotifier
class LuckyItemsStepNotifier extends StateNotifier<int> {
  LuckyItemsStepNotifier() : super(0);

  void nextStep() {
    if (state < 2) state++;
  }

  void previousStep() {
    if (state > 0) state--;
  }

  void reset() {
    state = 0;
  }
}

/// Provider 정의
final luckyItemsStepProvider = StateNotifierProvider<LuckyItemsStepNotifier, int>((ref) {
  return LuckyItemsStepNotifier();
});

final luckyItemsDataProvider = StateProvider<LuckyItemsData>((ref) {
  return LuckyItemsData();
});

// ==================== Main Page ====================

class LuckyItemsRenewedPage extends ConsumerStatefulWidget {
  const LuckyItemsRenewedPage({super.key});

  @override
  ConsumerState<LuckyItemsRenewedPage> createState() => _LuckyItemsRenewedPageState();
}

class _LuckyItemsRenewedPageState extends ConsumerState<LuckyItemsRenewedPage> {
  @override
  void dispose() {
    // Reset state when leaving page
    ref.read(luckyItemsStepProvider.notifier).reset();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentStep = ref.watch(luckyItemsStepProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.backgroundLight,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
          ),
          onPressed: () {
            if (currentStep > 0) {
              ref.read(luckyItemsStepProvider.notifier).previousStep();
            } else {
              context.pop();
            }
          },
        ),
        title: Text(
          '행운 아이템',
          style: TextStyle(
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressIndicator(),
            Expanded(
              child: _buildCurrentStep(),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== Progress Indicator ====================

  Widget _buildProgressIndicator() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentStep = ref.watch(luckyItemsStepProvider);
    final steps = ['기본 정보', '관심 분야', '확인'];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: List.generate(3, (index) {
              final isActive = index <= currentStep;
              return Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppTheme.primaryColor
                              : (isDark
                                  ? TossDesignSystem.grayDark300.withValues(alpha: 0.3)
                                  : TossDesignSystem.gray300),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    if (index < 2) const SizedBox(width: 8),
                  ],
                ),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(
            steps[currentStep],
            style: TextStyle(
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== Step Router ====================

  Widget _buildCurrentStep() {
    final currentStep = ref.watch(luckyItemsStepProvider);

    switch (currentStep) {
      case 0:
        return _buildStep1BasicInfo();
      case 1:
        return _buildStep2InterestAreas();
      case 2:
        return _buildStep3Confirmation();
      default:
        return _buildStep1BasicInfo();
    }
  }

  // ==================== Step 1: 기본 정보 (생년월일시 + 성별) ====================

  Widget _buildStep1BasicInfo() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = ref.watch(luckyItemsDataProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '생년월일',
                  style: TextStyle(
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: data.birthDate ?? DateTime.now(),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      ref.read(luckyItemsDataProvider.notifier).state =
                          data.copyWith(birthDate: picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? TossDesignSystem.grayDark200
                          : TossDesignSystem.gray100,
                      borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data.birthDate == null
                              ? '날짜를 선택해주세요'
                              : '${data.birthDate!.year}년 ${data.birthDate!.month}월 ${data.birthDate!.day}일',
                          style: TextStyle(
                            color: data.birthDate == null
                                ? (isDark
                                    ? TossDesignSystem.textSecondaryDark
                                    : TossDesignSystem.textSecondaryLight)
                                : (isDark
                                    ? TossDesignSystem.textPrimaryDark
                                    : TossDesignSystem.textPrimaryLight),
                            fontSize: 15,
                          ),
                        ),
                        Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: isDark
                              ? TossDesignSystem.textSecondaryDark
                              : TossDesignSystem.textSecondaryLight,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '태어난 시간',
                  style: TextStyle(
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final picked = await showTimePicker(
                      context: context,
                      initialTime: data.birthTime ?? TimeOfDay.now(),
                    );
                    if (picked != null) {
                      ref.read(luckyItemsDataProvider.notifier).state =
                          data.copyWith(birthTime: picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: isDark
                          ? TossDesignSystem.grayDark200
                          : TossDesignSystem.gray100,
                      borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          data.birthTime == null
                              ? '시간을 선택해주세요'
                              : '${data.birthTime!.hour.toString().padLeft(2, '0')}:${data.birthTime!.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: data.birthTime == null
                                ? (isDark
                                    ? TossDesignSystem.textSecondaryDark
                                    : TossDesignSystem.textSecondaryLight)
                                : (isDark
                                    ? TossDesignSystem.textPrimaryDark
                                    : TossDesignSystem.textPrimaryLight),
                            fontSize: 15,
                          ),
                        ),
                        Icon(
                          Icons.access_time,
                          size: 20,
                          color: isDark
                              ? TossDesignSystem.textSecondaryDark
                              : TossDesignSystem.textSecondaryLight,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          GlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '성별',
                  style: TextStyle(
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildGenderButton('남성', '남성', data.gender == '남성'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGenderButton('여성', '여성', data.gender == '여성'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TossButton(
            text: '다음',
            onPressed: _canProceedFromStep1()
                ? () {
                    ref.read(luckyItemsStepProvider.notifier).nextStep();
                  }
                : null,
            style: TossButtonStyle.primary,
            size: TossButtonSize.large,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildGenderButton(String label, String value, bool isSelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        final data = ref.read(luckyItemsDataProvider);
        ref.read(luckyItemsDataProvider.notifier).state =
            data.copyWith(gender: value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor
              : (isDark
                  ? TossDesignSystem.grayDark200
                  : TossDesignSystem.gray100),
          borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: isSelected
                  ? TossDesignSystem.white
                  : (isDark
                      ? TossDesignSystem.textPrimaryDark
                      : TossDesignSystem.textPrimaryLight),
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  bool _canProceedFromStep1() {
    final data = ref.watch(luckyItemsDataProvider);
    return data.birthDate != null && data.birthTime != null && data.gender != null;
  }

  // ==================== Step 2: 관심 분야 선택 ====================

  Widget _buildStep2InterestAreas() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = ref.watch(luckyItemsDataProvider);

    final interests = [
      '직업운',
      '연애운',
      '금전운',
      '건강운',
      '학업운',
      '대인운',
      '가족운',
      '여행운',
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '관심 있는 분야를 선택해주세요',
                  style: TextStyle(
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '최대 3개까지 선택 가능합니다',
                  style: TextStyle(
                    color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: interests.map((interest) {
                    final isSelected = data.selectedInterests.contains(interest);
                    return FilterChip(
                      label: Text(interest),
                      selected: isSelected,
                      onSelected: (selected) {
                        final currentInterests = List<String>.from(data.selectedInterests);
                        if (selected && currentInterests.length < 3) {
                          currentInterests.add(interest);
                        } else if (!selected) {
                          currentInterests.remove(interest);
                        }
                        ref.read(luckyItemsDataProvider.notifier).state =
                            data.copyWith(selectedInterests: currentInterests);
                      },
                      selectedColor: AppTheme.primaryColor,
                      checkmarkColor: TossDesignSystem.white,
                      backgroundColor: isDark
                          ? TossDesignSystem.grayDark200
                          : TossDesignSystem.gray100,
                      labelStyle: TextStyle(
                        color: isSelected
                            ? TossDesignSystem.white
                            : (isDark
                                ? TossDesignSystem.textPrimaryDark
                                : TossDesignSystem.textPrimaryLight),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TossButton(
            text: '다음',
            onPressed: data.selectedInterests.isNotEmpty
                ? () {
                    ref.read(luckyItemsStepProvider.notifier).nextStep();
                  }
                : null,
            style: TossButtonStyle.primary,
            size: TossButtonSize.large,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  // ==================== Step 3: 확인 ====================

  Widget _buildStep3Confirmation() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = ref.watch(luckyItemsDataProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '입력 정보 확인',
                  style: TextStyle(
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                _buildConfirmationRow('생년월일', data.birthDate == null
                    ? '-'
                    : '${data.birthDate!.year}년 ${data.birthDate!.month}월 ${data.birthDate!.day}일'),
                const SizedBox(height: 12),
                _buildConfirmationRow('태어난 시간', data.birthTime == null
                    ? '-'
                    : '${data.birthTime!.hour.toString().padLeft(2, '0')}:${data.birthTime!.minute.toString().padLeft(2, '0')}'),
                const SizedBox(height: 12),
                _buildConfirmationRow('성별', data.gender ?? '-'),
                const SizedBox(height: 12),
                _buildConfirmationRow('관심 분야', data.selectedInterests.isEmpty
                    ? '-'
                    : data.selectedInterests.join(', ')),
              ],
            ),
          ),
          const SizedBox(height: 24),
          TossButton(
            text: '행운 아이템 확인하기',
            onPressed: () {
              // TODO: Navigate to result page
              // For now, just show a placeholder
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('행운 아이템 생성 중...')),
              );
            },
            style: TossButtonStyle.primary,
            size: TossButtonSize.large,
            width: double.infinity,
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmationRow(String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
              fontSize: 14,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
