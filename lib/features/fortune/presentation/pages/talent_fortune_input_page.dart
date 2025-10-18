/// 재능 발견 운세 입력 페이지 (3단계)
///
/// Phase 1: 사주 정보 (변하지 않는 것)
/// Phase 2: 현재 상태 (환경으로 만들어진 것)
/// Phase 3: 성향 선택 (선호하는 것)

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../shared/components/toss_floating_progress_button.dart';
import '../../../../core/components/toss_card.dart';
import '../../domain/models/talent_input_model.dart';
import '../widgets/standard_fortune_app_bar.dart';
import '../../../../services/ad_service.dart';
import '../../../../core/theme/typography_unified.dart';

/// Provider for talent input data
final talentInputDataProvider = StateProvider<TalentInputData>((ref) => const TalentInputData());

class TalentFortuneInputPage extends ConsumerStatefulWidget {
  const TalentFortuneInputPage({super.key});

  @override
  ConsumerState<TalentFortuneInputPage> createState() => _TalentFortuneInputPageState();
}

class _TalentFortuneInputPageState extends ConsumerState<TalentFortuneInputPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Phase 1
  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  String? _gender;
  final TextEditingController _birthCityController = TextEditingController();

  // Phase 2
  final TextEditingController _occupationController = TextEditingController();
  final Set<String> _selectedConcerns = {};
  final Set<String> _selectedInterests = {};
  final TextEditingController _strengthsController = TextEditingController();
  final TextEditingController _weaknessesController = TextEditingController();

  // Phase 3
  String? _workStyle;
  String? _energySource;
  String? _problemSolving;
  String? _preferredRole;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _birthCityController.dispose();
    _occupationController.dispose();
    _strengthsController.dispose();
    _weaknessesController.dispose();
    super.dispose();
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

      if (response != null && mounted) {
        setState(() {
          // Parse birth date
          if (response['birth_date'] != null) {
            _birthDate = DateTime.tryParse(response['birth_date']);
          }

          // Parse birth time
          if (response['birth_time'] != null) {
            final timeStr = response['birth_time'] as String;
            final parts = timeStr.split(':');
            if (parts.length >= 2) {
              _birthTime = TimeOfDay(
                hour: int.tryParse(parts[0]) ?? 0,
                minute: int.tryParse(parts[1]) ?? 0,
              );
            }
          }

          _gender = response['gender'];
        });
      }
    } catch (e) {
      print('프로필 로드 실패: $e');
    }
  }

  void _nextStep() {
    if (_currentStep == 0) {
      if (!_canProceedPhase1()) {
        _showMessage('필수 정보를 모두 입력해주세요');
        return;
      }
      setState(() {
        _currentStep = 1;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentStep == 1) {
      if (!_canProceedPhase2()) {
        _showMessage('고민 분야나 관심 분야를 최소 1개 이상 선택해주세요');
        return;
      }
      setState(() {
        _currentStep = 2;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentStep == 2) {
      if (!_canProceedPhase3()) {
        _showMessage('모든 성향을 선택해주세요');
        return;
      }
      _analyzeAndShowResult();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  bool _canProceedPhase1() {
    return _birthDate != null && _birthTime != null && _gender != null;
  }

  bool _canProceedPhase2() {
    return _selectedConcerns.isNotEmpty || _selectedInterests.isNotEmpty;
  }

  bool _canProceedPhase3() {
    return _workStyle != null &&
           _energySource != null &&
           _problemSolving != null &&
           _preferredRole != null;
  }

  void _showMessage(String message) {
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
  }

  Future<void> _analyzeAndShowResult() async {
    final inputData = TalentInputData(
      birthDate: _birthDate!,
      birthTime: _birthTime!,
      gender: _gender!,
      birthCity: _birthCityController.text.isNotEmpty ? _birthCityController.text : null,
      currentOccupation: _occupationController.text.isNotEmpty ? _occupationController.text : null,
      concernAreas: _selectedConcerns.toList(),
      interestAreas: _selectedInterests.toList(),
      selfStrengths: _strengthsController.text.isNotEmpty ? _strengthsController.text : null,
      selfWeaknesses: _weaknessesController.text.isNotEmpty ? _weaknessesController.text : null,
      workStyle: _workStyle!,
      energySource: _energySource!,
      problemSolving: _problemSolving!,
      preferredRole: _preferredRole!,
    );

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? TossDesignSystem.grayDark200
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                '사주팔자 분석 중...',
                style: TossDesignSystem.body2,
              ),
            ],
          ),
        ),
      ),
    );

    // Show AdMob interstitial ad
    await AdService.instance.showInterstitialAdWithCallback(
      onAdCompleted: () async {
        // Close loading dialog
        if (mounted) Navigator.pop(context);

        // Navigate to result page
        if (mounted) {
          context.push('/talent-fortune-results', extra: inputData);
        }
      },
      onAdFailed: () async {
        // Close loading dialog even if ad fails
        if (mounted) Navigator.pop(context);

        // Navigate to result page anyway
        if (mounted) {
          context.push('/talent-fortune-results', extra: inputData);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: StandardFortuneAppBar(
        title: '재능 발견',
        onBackPressed: _previousStep,
      ),
      body: Stack(
        children: [
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildPhase1(isDark),
              _buildPhase2(isDark),
              _buildPhase3(isDark),
            ],
          ),

          // Floating Progress Button
          TossFloatingProgressButtonPositioned(
            text: _currentStep == 2 ? '분석 시작' : '다음',
            currentStep: _currentStep + 1,
            totalSteps: 3,
            onPressed: _nextStep,
            isEnabled: _currentStep == 0
                ? _canProceedPhase1()
                : _currentStep == 1
                    ? _canProceedPhase2()
                    : _canProceedPhase3(),
          ),
        ],
      ),
    );
  }

  /// Phase 1: 사주 정보 (변하지 않는 것 - The Unchangeable)
  Widget _buildPhase1(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24).copyWith(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '1단계',
            style: TypographyUnified.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: TossDesignSystem.tossBlue,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '변하지 않는 것',
            style: TypographyUnified.displaySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '타고난 기질을 파악하기 위한 정보입니다',
            style: TypographyUnified.bodySmall.copyWith(
              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 32),

          // 생년월일
          TossCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '생년월일',
                      style: TypographyUnified.buttonMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '*',
                      style: TypographyUnified.buttonMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: TossDesignSystem.warningOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _birthDate ?? DateTime(2000, 1, 1),
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                    );
                    if (date != null && mounted) {
                      setState(() {
                        _birthDate = date;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _birthDate != null
                              ? '${_birthDate!.year}년 ${_birthDate!.month}월 ${_birthDate!.day}일'
                              : '날짜를 선택해주세요',
                          style: TypographyUnified.buttonMedium.copyWith(
                            color: _birthDate != null
                                ? (isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight)
                                : (isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 태어난 시간
          TossCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '태어난 시간',
                      style: TypographyUnified.buttonMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '*',
                      style: TypographyUnified.buttonMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: TossDesignSystem.warningOrange,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '가장 중요!',
                      style: TypographyUnified.labelMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: TossDesignSystem.tossBlue,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                  '모르면 출생 증명서나 가족에게 물어보세요',
                  style: TypographyUnified.labelMedium.copyWith(
                    color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                InkWell(
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _birthTime ?? const TimeOfDay(hour: 12, minute: 0),
                    );
                    if (time != null && mounted) {
                      setState(() {
                        _birthTime = time;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          size: 20,
                          color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _birthTime != null
                              ? '${_birthTime!.hour.toString().padLeft(2, '0')}:${_birthTime!.minute.toString().padLeft(2, '0')}'
                              : '시간을 선택해주세요',
                          style: TypographyUnified.buttonMedium.copyWith(
                            color: _birthTime != null
                                ? (isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight)
                                : (isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 성별
          TossCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '성별',
                      style: TypographyUnified.buttonMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '*',
                      style: TypographyUnified.buttonMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: TossDesignSystem.warningOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildGenderButton(isDark, '남성', 'male'),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildGenderButton(isDark, '여성', 'female'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 태어난 도시 (선택)
          TossCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '태어난 도시 (선택)',
                  style: TypographyUnified.buttonMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '균시차 보정을 위해 사용됩니다',
                  style: TypographyUnified.labelMedium.copyWith(
                    color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _birthCityController,
                  decoration: InputDecoration(
                    hintText: '예: 서울, 부산, 대구...',
                    filled: true,
                    fillColor: isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: TypographyUnified.buttonMedium.copyWith(
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  Widget _buildGenderButton(bool isDark, String label, String value) {
    final isSelected = _gender == value;
    return InkWell(
      onTap: () {
        setState(() {
          _gender = value;
        });
        TossDesignSystem.hapticLight();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? TossDesignSystem.tossBlue.withOpacity(0.1)
              : (isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? TossDesignSystem.tossBlue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: TypographyUnified.buttonMedium.copyWith(
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? TossDesignSystem.tossBlue
                  : (isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight),
            ),
          ),
        ),
      ),
    );
  }

  /// Phase 2: 현재 상태 (환경으로 만들어진 것 - The Nurture)
  Widget _buildPhase2(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24).copyWith(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '2단계',
            style: TypographyUnified.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: TossDesignSystem.tossBlue,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '환경으로 만들어진 것',
            style: TypographyUnified.displaySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '현재 당신의 상태를 알려주세요',
            style: TypographyUnified.bodySmall.copyWith(
              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 32),

          // 현재 직업/전공 (선택)
          TossCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '현재 직업/전공 (선택)',
                  style: TypographyUnified.buttonMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _occupationController,
                  decoration: InputDecoration(
                    hintText: '예: 대학생(컴퓨터공학), 마케터, 구직 중...',
                    filled: true,
                    fillColor: isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: TypographyUnified.buttonMedium.copyWith(
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 고민 분야
          TossCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '고민 분야',
                      style: TypographyUnified.buttonMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '*',
                      style: TypographyUnified.buttonMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: TossDesignSystem.warningOrange,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '복수 선택',
                      style: TypographyUnified.labelMedium.copyWith(
                        color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ConcernAreaOptions.options.map((concern) {
                    final isSelected = _selectedConcerns.contains(concern);
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedConcerns.remove(concern);
                          } else {
                            _selectedConcerns.add(concern);
                          }
                        });
                        TossDesignSystem.hapticLight();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? TossDesignSystem.tossBlue.withOpacity(0.1)
                              : (isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray100),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? TossDesignSystem.tossBlue : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          concern,
                          style: TypographyUnified.bodySmall.copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? TossDesignSystem.tossBlue
                                : (isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 관심 분야
          TossCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '관심 분야',
                      style: TypographyUnified.buttonMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                      ),
                    ),
                    SizedBox(width: 4),
                    Text(
                      '*',
                      style: TypographyUnified.buttonMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: TossDesignSystem.warningOrange,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '복수 선택',
                      style: TypographyUnified.labelMedium.copyWith(
                        color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: InterestAreaOptions.options.map((interest) {
                    final isSelected = _selectedInterests.contains(interest);
                    return InkWell(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedInterests.remove(interest);
                          } else {
                            _selectedInterests.add(interest);
                          }
                        });
                        TossDesignSystem.hapticLight();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? TossDesignSystem.tossBlue.withOpacity(0.1)
                              : (isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray100),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? TossDesignSystem.tossBlue : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                        child: Text(
                          interest,
                          style: TypographyUnified.bodySmall.copyWith(
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                            color: isSelected
                                ? TossDesignSystem.tossBlue
                                : (isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // 자기평가 (선택)
          TossCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '자기평가 (선택)',
                  style: TypographyUnified.buttonMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '스스로 생각하는 강점과 약점을 자유롭게 적어주세요',
                  style: TypographyUnified.labelMedium.copyWith(
                    color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _strengthsController,
                  decoration: InputDecoration(
                    labelText: '강점',
                    hintText: '예: 책임감, 빠른 실행력, 창의적 사고...',
                    filled: true,
                    fillColor: isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: TypographyUnified.buttonMedium.copyWith(
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _weaknessesController,
                  decoration: InputDecoration(
                    labelText: '약점',
                    hintText: '예: 우유부단함, 쉽게 포기함, 조급함...',
                    filled: true,
                    fillColor: isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray100,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  style: TypographyUnified.buttonMedium.copyWith(
                    color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ],
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  /// Phase 3: 성향 선택 (선호하는 것 - The Preference)
  Widget _buildPhase3(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24).copyWith(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '3단계',
            style: TypographyUnified.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: TossDesignSystem.tossBlue,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '선호하는 것',
            style: TypographyUnified.displaySmall.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '당신의 성향을 알려주세요',
            style: TypographyUnified.bodySmall.copyWith(
              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 32),

          // 업무 스타일
          _buildPreferenceCard(
            isDark: isDark,
            title: '업무 스타일',
            question: '일할 때 당신은?',
            options: WorkStyleOptions.options,
            selectedValue: _workStyle,
            onSelect: (value) {
              setState(() {
                _workStyle = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // 에너지 충전 방식
          _buildPreferenceCard(
            isDark: isDark,
            title: '에너지 충전 방식',
            question: '힘들 때 에너지를 채우려면?',
            options: EnergySourceOptions.options,
            selectedValue: _energySource,
            onSelect: (value) {
              setState(() {
                _energySource = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // 문제 해결 방식
          _buildPreferenceCard(
            isDark: isDark,
            title: '문제 해결 방식',
            question: '어려운 문제를 만나면?',
            options: ProblemSolvingOptions.options,
            selectedValue: _problemSolving,
            onSelect: (value) {
              setState(() {
                _problemSolving = value;
              });
            },
          ),
          const SizedBox(height: 16),

          // 선호하는 역할
          _buildPreferenceCard(
            isDark: isDark,
            title: '선호하는 역할',
            question: '조직에서 당신이 맡고 싶은 역할은?',
            options: PreferredRoleOptions.options,
            selectedValue: _preferredRole,
            onSelect: (value) {
              setState(() {
                _preferredRole = value;
              });
            },
          ),
        ],
      ).animate().fadeIn(duration: 300.ms),
    );
  }

  Widget _buildPreferenceCard({
    required bool isDark,
    required String title,
    required String question,
    required List<String> options,
    required String? selectedValue,
    required Function(String) onSelect,
  }) {
    return TossCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: TypographyUnified.buttonMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
                ),
              ),
              SizedBox(width: 4),
              Text(
                '*',
                style: TypographyUnified.buttonMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: TossDesignSystem.warningOrange,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            question,
            style: TypographyUnified.bodySmall.copyWith(
              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 12),
          Column(
            children: options.map((option) {
              final isSelected = selectedValue == option;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InkWell(
                  onTap: () {
                    onSelect(option);
                    TossDesignSystem.hapticLight();
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? TossDesignSystem.tossBlue.withOpacity(0.1)
                          : (isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray100),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? TossDesignSystem.tossBlue : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            option,
                            style: TypographyUnified.buttonMedium.copyWith(
                              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                              color: isSelected
                                  ? TossDesignSystem.tossBlue
                                  : (isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight),
                            ),
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: TossDesignSystem.tossBlue,
                            size: 24,
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
