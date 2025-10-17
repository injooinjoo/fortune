import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/components/toss_floating_progress_button.dart';
import '../../../../core/components/toss_card.dart';
import '../widgets/standard_fortune_app_bar.dart';

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
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    // 프로필 정보에서 생년월일 로드
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;

      final response = await Supabase.instance.client
          .from('profiles')
          .select('birth_date, birth_time, gender')
          .eq('id', userId)
          .single();

      if (response != null) {
        final data = ref.read(luckyItemsDataProvider);

        // 생년월일 파싱
        DateTime? birthDate;
        if (response['birth_date'] != null) {
          birthDate = DateTime.tryParse(response['birth_date']);
        }

        // 생년시간 파싱
        TimeOfDay? birthTime;
        if (response['birth_time'] != null) {
          final timeStr = response['birth_time'] as String;
          final parts = timeStr.split(':');
          if (parts.length >= 2) {
            birthTime = TimeOfDay(
              hour: int.tryParse(parts[0]) ?? 0,
              minute: int.tryParse(parts[1]) ?? 0,
            );
          }
        }

        // 성별
        String? gender = response['gender'];

        // 데이터 업데이트
        ref.read(luckyItemsDataProvider.notifier).state = data.copyWith(
          birthDate: birthDate ?? data.birthDate,
          birthTime: birthTime ?? data.birthTime,
          gender: gender ?? data.gender,
        );
      }
    } catch (e) {
      print('프로필 로드 실패: $e');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    ref.read(luckyItemsStepProvider.notifier).reset();
    super.dispose();
  }

  void _nextStep() {
    final currentStep = ref.read(luckyItemsStepProvider);

    if (currentStep == 0) {
      if (!_canProceedStep1()) {
        final data = ref.read(luckyItemsDataProvider);
        if (data.birthDate == null) {
          _showMessage('생년월일을 선택해주세요');
        } else if (data.birthTime == null) {
          _showMessage('태어난 시간을 선택해주세요');
        } else if (data.gender == null) {
          _showMessage('성별을 선택해주세요');
        }
        return;
      }
      ref.read(luckyItemsStepProvider.notifier).nextStep();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (currentStep == 1) {
      if (!_canProceedStep2()) {
        _showMessage('관심 분야를 최소 1개 선택해주세요');
        return;
      }
      ref.read(luckyItemsStepProvider.notifier).nextStep();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (currentStep == 2) {
      _generateLuckyItems();
    }
  }

  void _previousStep() {
    final currentStep = ref.read(luckyItemsStepProvider);
    if (currentStep > 0) {
      ref.read(luckyItemsStepProvider.notifier).previousStep();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canProceedStep1() {
    final data = ref.watch(luckyItemsDataProvider);
    return data.birthDate != null && data.birthTime != null && data.gender != null;
  }

  bool _canProceedStep2() {
    final data = ref.watch(luckyItemsDataProvider);
    return data.selectedInterests.isNotEmpty;
  }

  bool _canProceedStep3() {
    return true;
  }

  void _showMessage(String message) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: TossDesignSystem.warningOrange,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
    });
  }

  void _generateLuckyItems() {
    // 행운 아이템 결과 페이지로 바로 이동
    final data = ref.read(luckyItemsDataProvider);

    context.push('/lucky-items-results', extra: {
      'birthDate': data.birthDate,
      'birthTime': data.birthTime,
      'gender': data.gender,
      'interests': data.selectedInterests,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentStep = ref.watch(luckyItemsStepProvider);

    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.grayDark50 : TossDesignSystem.white,
      appBar: StandardFortuneAppBar(
        title: '행운 아이템',
        onBackPressed: () {
          if (currentStep > 0) {
            _previousStep();
          } else {
            context.pop();
          }
        },
      ),
      body: Stack(
        children: [
          // Page Content
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStep1(isDark),
              _buildStep2(isDark),
              _buildStep3(isDark),
            ],
          ),

          // Floating Progress Button
          _buildFloatingButton(),
        ],
      ),
    );
  }

  Widget _buildFloatingButton() {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final currentStep = ref.watch(luckyItemsStepProvider);

    bool canProceed;
    String buttonText;

    switch (currentStep) {
      case 0:
        canProceed = _canProceedStep1();
        buttonText = '다음';
        break;
      case 1:
        canProceed = _canProceedStep2();
        buttonText = '다음';
        break;
      case 2:
        canProceed = _canProceedStep3();
        buttonText = '행운 아이템 확인하기';
        break;
      default:
        canProceed = false;
        buttonText = '다음';
    }

    return Positioned(
      left: 20,
      right: 20,
      bottom: 16 + bottomPadding,
      child: TossFloatingProgressButton(
        text: buttonText,
        currentStep: currentStep + 1,
        totalSteps: 3,
        onPressed: canProceed ? _nextStep : null,
        isEnabled: canProceed,
        showProgress: true,
      ),
    );
  }

  // ==================== Step 1: 기본 정보 (생년월일시 + 성별) ====================

  Widget _buildStep1(bool isDark) {
    final data = ref.watch(luckyItemsDataProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 안내 카드
          TossCard(
            style: TossCardStyle.elevated,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryColor.withValues(alpha: 0.8),
                        const Color(0xFFEC4899).withValues(alpha: 0.8),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.stars_rounded,
                    color: TossDesignSystem.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '당신만의 행운을 찾아드릴게요',
                  style: TossDesignSystem.heading3.copyWith(
                    color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '기본 정보를 입력해주세요',
                  style: TossDesignSystem.body2.copyWith(
                    color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 생년월일
          Text(
            '생년월일',
            style: TossDesignSystem.body1.copyWith(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          TossCard(
            style: TossCardStyle.filled,
            padding: const EdgeInsets.all(16),
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: data.birthDate ?? DateTime.now(),
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppTheme.primaryColor,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (date != null) {
                ref.read(luckyItemsDataProvider.notifier).state =
                    data.copyWith(birthDate: date);
              }
            },
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    data.birthDate != null
                        ? '${data.birthDate!.year}년 ${data.birthDate!.month}월 ${data.birthDate!.day}일'
                        : '생년월일 선택',
                    style: TossDesignSystem.body2.copyWith(
                      color: data.birthDate != null
                          ? (isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900)
                          : (isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray400),
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray400,
                  size: 20,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 태어난 시간
          Text(
            '태어난 시간',
            style: TossDesignSystem.body1.copyWith(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          TossCard(
            style: TossCardStyle.filled,
            padding: const EdgeInsets.all(16),
            onTap: () async {
              final time = await showTimePicker(
                context: context,
                initialTime: data.birthTime ?? TimeOfDay.now(),
                builder: (context, child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppTheme.primaryColor,
                      ),
                    ),
                    child: child!,
                  );
                },
              );
              if (time != null) {
                ref.read(luckyItemsDataProvider.notifier).state =
                    data.copyWith(birthTime: time);
              }
            },
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: AppTheme.primaryColor,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    data.birthTime != null
                        ? '${data.birthTime!.hour.toString().padLeft(2, '0')}:${data.birthTime!.minute.toString().padLeft(2, '0')}'
                        : '시간 선택',
                    style: TossDesignSystem.body2.copyWith(
                      color: data.birthTime != null
                          ? (isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900)
                          : (isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray400),
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray400,
                  size: 20,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 성별
          Text(
            '성별',
            style: TossDesignSystem.body1.copyWith(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: _buildGenderChip('남성', '남성', data.gender == '남성', isDark),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildGenderChip('여성', '여성', data.gender == '여성', isDark),
              ),
            ],
          ),

          // Floating 버튼 공간 확보
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildGenderChip(String label, String value, bool isSelected, bool isDark) {
    return GestureDetector(
      onTap: () {
        final data = ref.read(luckyItemsDataProvider);
        ref.read(luckyItemsDataProvider.notifier).state =
            data.copyWith(gender: value);
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : (isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : (isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TossDesignSystem.body2.copyWith(
              color: isSelected
                  ? AppTheme.primaryColor
                  : (isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900),
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ),
    );
  }

  // ==================== Step 2: 관심 분야 선택 ====================

  Widget _buildStep2(bool isDark) {
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 안내 카드
          TossCard(
            style: TossCardStyle.elevated,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        TossDesignSystem.tossBlue.withValues(alpha: 0.8),
                        AppTheme.primaryColor.withValues(alpha: 0.8),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.auto_awesome_rounded,
                    color: TossDesignSystem.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '어떤 분야가 궁금하세요?',
                  style: TossDesignSystem.heading3.copyWith(
                    color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '최대 3개까지 선택 가능합니다',
                  style: TossDesignSystem.body2.copyWith(
                    color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 관심 분야 선택
          Text(
            '관심 분야',
            style: TossDesignSystem.body1.copyWith(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: interests.map((interest) {
              final isSelected = data.selectedInterests.contains(interest);
              return _buildInterestChip(interest, isSelected, isDark);
            }).toList(),
          ),

          // Floating 버튼 공간 확보
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildInterestChip(String label, bool isSelected, bool isDark) {
    return GestureDetector(
      onTap: () {
        final data = ref.read(luckyItemsDataProvider);
        final currentInterests = List<String>.from(data.selectedInterests);

        if (isSelected) {
          currentInterests.remove(label);
        } else {
          if (currentInterests.length < 3) {
            currentInterests.add(label);
          } else {
            _showMessage('최대 3개까지만 선택 가능합니다');
            return;
          }
        }

        ref.read(luckyItemsDataProvider.notifier).state =
            data.copyWith(selectedInterests: currentInterests);
        HapticFeedback.lightImpact();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryColor.withValues(alpha: 0.1)
              : (isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray50),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? AppTheme.primaryColor
                : (isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TossDesignSystem.body2.copyWith(
            color: isSelected
                ? AppTheme.primaryColor
                : (isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  // ==================== Step 3: 확인 ====================

  Widget _buildStep3(bool isDark) {
    final data = ref.watch(luckyItemsDataProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 안내 카드
          TossCard(
            style: TossCardStyle.elevated,
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF10B981).withValues(alpha: 0.8),
                        AppTheme.primaryColor.withValues(alpha: 0.8),
                      ],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_rounded,
                    color: TossDesignSystem.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '입력 정보를 확인해주세요',
                  style: TossDesignSystem.heading3.copyWith(
                    color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '정확한 정보로 더 좋은 결과를 받아보세요',
                  style: TossDesignSystem.body2.copyWith(
                    color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // 입력 정보 확인
          TossCard(
            style: TossCardStyle.filled,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildConfirmationRow(
                  '생년월일',
                  data.birthDate == null
                      ? '-'
                      : '${data.birthDate!.year}년 ${data.birthDate!.month}월 ${data.birthDate!.day}일',
                  isDark,
                ),
                const SizedBox(height: 16),
                _buildConfirmationRow(
                  '태어난 시간',
                  data.birthTime == null
                      ? '-'
                      : '${data.birthTime!.hour.toString().padLeft(2, '0')}:${data.birthTime!.minute.toString().padLeft(2, '0')}',
                  isDark,
                ),
                const SizedBox(height: 16),
                _buildConfirmationRow(
                  '성별',
                  data.gender ?? '-',
                  isDark,
                ),
                const SizedBox(height: 16),
                _buildConfirmationRow(
                  '관심 분야',
                  data.selectedInterests.isEmpty
                      ? '-'
                      : data.selectedInterests.join(', '),
                  isDark,
                ),
              ],
            ),
          ),

          // Floating 버튼 공간 확보
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildConfirmationRow(String label, String value, bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TossDesignSystem.body2.copyWith(
              color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TossDesignSystem.body2.copyWith(
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
