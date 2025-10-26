/// 재능 발견 운세 입력 페이지 (Accordion 형태)
///
/// 프로필 정보는 자동으로 채워지고 접혀있음
/// 선택이 필요한 항목만 열려있음

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../shared/components/toss_floating_progress_button.dart';
import '../../domain/models/talent_input_model.dart';
import '../widgets/standard_fortune_app_bar.dart';
import '../../../../services/ad_service.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/widgets/accordion_input_section.dart';
import '../../../../presentation/providers/auth_provider.dart';

/// Provider for talent input data
final talentInputDataProvider = StateProvider<TalentInputData>((ref) => const TalentInputData());

class TalentFortuneInputPage extends ConsumerStatefulWidget {
  const TalentFortuneInputPage({super.key});

  @override
  ConsumerState<TalentFortuneInputPage> createState() => _TalentFortuneInputPageState();
}

class _TalentFortuneInputPageState extends ConsumerState<TalentFortuneInputPage> {
  // Phase 1: 프로필 정보 (자동 채워짐)
  DateTime? _birthDate;
  TimeOfDay? _birthTime;
  String? _gender;
  final TextEditingController _birthDateController = TextEditingController();
  final TextEditingController _birthTimeController = TextEditingController();
  final TextEditingController _birthCityController = TextEditingController();

  // Phase 2: 현재 상태 (선택 필요)
  final TextEditingController _occupationController = TextEditingController();
  final Set<String> _selectedConcerns = {};
  final Set<String> _selectedInterests = {};
  final TextEditingController _strengthsController = TextEditingController();
  final TextEditingController _weaknessesController = TextEditingController();

  // Phase 3: 성향 (선택 필요)
  String? _workStyle;
  String? _energySource;
  String? _problemSolving;
  String? _preferredRole;

  // Accordion sections
  List<AccordionInputSection> _accordionSections = [];

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _birthDateController.dispose();
    _birthTimeController.dispose();
    _birthCityController.dispose();
    _occupationController.dispose();
    _strengthsController.dispose();
    _weaknessesController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    // 이미 로드된 프로필 정보 사용 (앱 시작 시 로드됨)
    final profileAsync = ref.read(userProfileProvider);
    final profile = profileAsync.value;

    if (profile != null && mounted) {
      setState(() {
        _birthDate = profile.birthDate;
        _birthTime = profile.birthTime != null
            ? _parseTimeOfDay(profile.birthTime!)
            : null;
        _gender = profile.gender;

        // TextEditingController 초기값 설정
        if (_birthDate != null) {
          _birthDateController.text = '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}';
        }
        if (_birthTime != null) {
          _birthTimeController.text = '${_birthTime!.hour.toString().padLeft(2, '0')}:${_birthTime!.minute.toString().padLeft(2, '0')}';
        }

        // Accordion 섹션 초기화
        _initializeAccordionSections();
      });
    } else {
      // 프로필이 없으면 빈 상태로 초기화
      _initializeAccordionSections();
    }
  }

  TimeOfDay? _parseTimeOfDay(String timeString) {
    try {
      final parts = timeString.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);
        return TimeOfDay(hour: hour, minute: minute);
      }
    } catch (e) {
      // 파싱 실패
    }
    return null;
  }

  void _initializeAccordionSections() {
    _accordionSections = [
      // 1. 생년월일 (프로필에서 자동 채워짐)
      AccordionInputSection(
        id: 'birthDate',
        title: '생년월일',
        icon: Icons.cake_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildBirthDateInput(onComplete),
        value: _birthDate,
        isCompleted: _birthDate != null,
        displayValue: _birthDate != null
            ? '${_birthDate!.year}년 ${_birthDate!.month}월 ${_birthDate!.day}일'
            : null,
      ),

      // 2. 출생 시간 (프로필에서 자동 채워짐)
      AccordionInputSection(
        id: 'birthTime',
        title: '출생 시간',
        icon: Icons.access_time_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildBirthTimeInput(onComplete),
        value: _birthTime,
        isCompleted: _birthTime != null,
        displayValue: _birthTime != null
            ? '${_birthTime!.hour.toString().padLeft(2, '0')}:${_birthTime!.minute.toString().padLeft(2, '0')}'
            : null,
      ),

      // 3. 성별 (프로필에서 자동 채워짐)
      AccordionInputSection(
        id: 'gender',
        title: '성별',
        icon: Icons.person_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildGenderInput(onComplete),
        value: _gender,
        isCompleted: _gender != null,
        displayValue: _gender != null
            ? (_gender == 'male' ? '남성' : '여성')
            : null,
      ),

      // 4. 태어난 도시 (선택사항)
      AccordionInputSection(
        id: 'birthCity',
        title: '태어난 도시 (선택)',
        icon: Icons.location_city_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildBirthCityInput(onComplete),
        value: _birthCityController.text.isNotEmpty ? _birthCityController.text : null,
        isCompleted: false, // 선택사항이므로 완료 체크 안함
        displayValue: _birthCityController.text.isNotEmpty ? _birthCityController.text : null,
      ),

      // 5. 현재 직업/전공 (선택사항)
      AccordionInputSection(
        id: 'occupation',
        title: '현재 직업/전공 (선택)',
        icon: Icons.work_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildOccupationInput(onComplete),
        value: _occupationController.text.isNotEmpty ? _occupationController.text : null,
        isCompleted: false, // 선택사항
        displayValue: _occupationController.text.isNotEmpty ? _occupationController.text : null,
      ),

      // 6. 고민 분야 (선택 필요 - 열려있음, 다중 선택)
      AccordionInputSection(
        id: 'concerns',
        title: '고민 분야',
        icon: Icons.psychology_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildConcernsInput(onComplete),
        value: _selectedConcerns.toList(),
        isCompleted: _selectedConcerns.isNotEmpty,
        displayValue: _selectedConcerns.isNotEmpty
            ? _selectedConcerns.join(', ')
            : null,
        isMultiSelect: true, // 다중 선택 가능 - 선택 후에도 닫히지 않음
      ),

      // 7. 관심 분야 (선택 필요 - 열려있음, 다중 선택)
      AccordionInputSection(
        id: 'interests',
        title: '관심 분야',
        icon: Icons.favorite_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildInterestsInput(onComplete),
        value: _selectedInterests.toList(),
        isCompleted: _selectedInterests.isNotEmpty,
        displayValue: _selectedInterests.isNotEmpty
            ? _selectedInterests.join(', ')
            : null,
        isMultiSelect: true, // 다중 선택 가능 - 선택 후에도 닫히지 않음
      ),

      // 8. 자기평가 (선택사항)
      AccordionInputSection(
        id: 'selfEvaluation',
        title: '자기평가 (선택)',
        icon: Icons.rate_review_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildSelfEvaluationInput(onComplete),
        value: _strengthsController.text.isNotEmpty || _weaknessesController.text.isNotEmpty,
        isCompleted: false, // 선택사항
        displayValue: _strengthsController.text.isNotEmpty
            ? '강점: ${_strengthsController.text}'
            : null,
      ),

      // 9. 업무 스타일 (선택 필요 - 열려있음)
      AccordionInputSection(
        id: 'workStyle',
        title: '업무 스타일',
        icon: Icons.business_center_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildWorkStyleInput(onComplete),
        value: _workStyle,
        isCompleted: _workStyle != null,
        displayValue: _workStyle,
      ),

      // 10. 에너지 충전 방식 (선택 필요 - 열려있음)
      AccordionInputSection(
        id: 'energySource',
        title: '에너지 충전 방식',
        icon: Icons.battery_charging_full_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildEnergySourceInput(onComplete),
        value: _energySource,
        isCompleted: _energySource != null,
        displayValue: _energySource,
      ),

      // 11. 문제 해결 방식 (선택 필요 - 열려있음)
      AccordionInputSection(
        id: 'problemSolving',
        title: '문제 해결 방식',
        icon: Icons.lightbulb_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildProblemSolvingInput(onComplete),
        value: _problemSolving,
        isCompleted: _problemSolving != null,
        displayValue: _problemSolving,
      ),

      // 12. 선호하는 역할 (선택 필요 - 열려있음)
      AccordionInputSection(
        id: 'preferredRole',
        title: '선호하는 역할',
        icon: Icons.groups_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildPreferredRoleInput(onComplete),
        value: _preferredRole,
        isCompleted: _preferredRole != null,
        displayValue: _preferredRole,
      ),
    ];
  }

  void _updateAccordionSection(String id, dynamic value, String? displayValue) {
    final index = _accordionSections.indexWhere((section) => section.id == id);
    if (index != -1) {
      setState(() {
        _accordionSections[index] = AccordionInputSection(
          id: _accordionSections[index].id,
          title: _accordionSections[index].title,
          icon: _accordionSections[index].icon,
          inputWidgetBuilder: _accordionSections[index].inputWidgetBuilder,
          value: value,
          isCompleted: value != null && (value is! String || value.isNotEmpty),
          displayValue: displayValue,
          isMultiSelect: _accordionSections[index].isMultiSelect, // 기존 isMultiSelect 값 유지
        );
      });
    }
  }

  bool _canGenerate() {
    // 필수: 생년월일, 출생시간, 성별, 고민/관심 중 1개, 성향 4개
    return _birthDate != null &&
        _birthTime != null &&
        _gender != null &&
        (_selectedConcerns.isNotEmpty || _selectedInterests.isNotEmpty) &&
        _workStyle != null &&
        _energySource != null &&
        _problemSolving != null &&
        _preferredRole != null;
  }

  Future<void> _analyzeAndShowResult() async {
    if (!_canGenerate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('필수 정보를 모두 입력해주세요'),
          backgroundColor: TossDesignSystem.warningOrange,
        ),
      );
      return;
    }

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
                style: TypographyUnified.bodyMedium,
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
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.white,
      appBar: StandardFortuneAppBar(
        title: '재능 발견',
      ),
      body: SafeArea(
        child: Stack(
          children: [
            _accordionSections.isEmpty
                ? Center(child: CircularProgressIndicator())
                : AccordionInputFormWithHeader(
                    header: _buildTitleSection(isDark),
                    sections: _accordionSections,
                    onAllCompleted: null,
                    completionButtonText: '🔮 재능 분석 시작하기',
                  ),
            if (_canGenerate())
              TossFloatingProgressButtonPositioned(
                text: '🔮 재능 분석 시작하기',
                onPressed: _canGenerate() ? () => _analyzeAndShowResult() : null,
                isEnabled: _canGenerate(),
                showProgress: false,
                isVisible: _canGenerate(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '당신의 숨은 재능을\n찾아드릴게요',
          style: TypographyUnified.heading1.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '사주팔자와 성향을 분석해서\n맞춤 재능 가이드를 제공해드려요',
          style: TypographyUnified.bodySmall.copyWith(
            color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ===== 입력 위젯들 =====

  Widget _buildBirthDateInput(Function(dynamic) onComplete) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'YYYY-MM-DD 형식으로 입력해주세요 (예: 1990-05-15)',
          style: TypographyUnified.labelSmall.copyWith(
            color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _birthDateController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'YYYY-MM-DD',
            prefixIcon: Icon(Icons.calendar_today),
            filled: true,
            fillColor: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            // YYYY-MM-DD 형식 파싱
            if (value.length == 10) {
              try {
                final parts = value.split('-');
                if (parts.length == 3) {
                  final year = int.parse(parts[0]);
                  final month = int.parse(parts[1]);
                  final day = int.parse(parts[2]);
                  final date = DateTime(year, month, day);

                  setState(() {
                    _birthDate = date;
                    _updateAccordionSection(
                      'birthDate',
                      date,
                      '${date.year}년 ${date.month}월 ${date.day}일',
                    );
                  });
                  onComplete(date);
                }
              } catch (e) {
                // 파싱 실패 - 아무것도 안함
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildBirthTimeInput(Function(dynamic) onComplete) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'HH:MM 형식으로 입력해주세요 (예: 14:30)',
          style: TypographyUnified.labelSmall.copyWith(
            color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _birthTimeController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'HH:MM',
            prefixIcon: Icon(Icons.access_time),
            filled: true,
            fillColor: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            // HH:MM 형식 파싱
            if (value.length == 5 && value.contains(':')) {
              try {
                final parts = value.split(':');
                if (parts.length == 2) {
                  final hour = int.parse(parts[0]);
                  final minute = int.parse(parts[1]);

                  if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
                    final time = TimeOfDay(hour: hour, minute: minute);

                    setState(() {
                      _birthTime = time;
                      _updateAccordionSection(
                        'birthTime',
                        time,
                        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                      );
                    });
                    onComplete(time);
                  }
                }
              } catch (e) {
                // 파싱 실패 - 아무것도 안함
              }
            }
          },
        ),
      ],
    );
  }

  Widget _buildGenderInput(Function(dynamic) onComplete) {
    return Row(
      children: [
        Expanded(
          child: _buildGenderButton('남성', 'male', onComplete),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildGenderButton('여성', 'female', onComplete),
        ),
      ],
    );
  }

  Widget _buildGenderButton(String label, String value, Function(dynamic) onComplete) {
    final isSelected = _gender == value;
    return InkWell(
      onTap: () {
        setState(() {
          _gender = value;
          _updateAccordionSection('gender', value, label);
        });
        TossDesignSystem.hapticLight();
        onComplete(value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? TossDesignSystem.tossBlue.withOpacity(0.1)
              : TossDesignSystem.gray100,
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
              color: isSelected ? TossDesignSystem.tossBlue : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBirthCityInput(Function(dynamic) onComplete) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '균시차 보정을 위해 사용됩니다',
          style: TypographyUnified.labelMedium.copyWith(
            color: TossDesignSystem.gray600,
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _birthCityController,
          decoration: InputDecoration(
            hintText: '예: 서울, 부산, 대구...',
            filled: true,
            fillColor: TossDesignSystem.gray100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) {
            _updateAccordionSection('birthCity', value.isNotEmpty ? value : null, value);
          },
        ),
      ],
    );
  }

  Widget _buildOccupationInput(Function(dynamic) onComplete) {
    return TextField(
      controller: _occupationController,
      decoration: InputDecoration(
        hintText: '예: 대학생(컴퓨터공학), 마케터, 구직 중...',
        filled: true,
        fillColor: TossDesignSystem.gray100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
      onChanged: (value) {
        _updateAccordionSection('occupation', value.isNotEmpty ? value : null, value);
      },
    );
  }

  Widget _buildConcernsInput(Function(dynamic) onComplete) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '복수 선택 가능',
          style: TypographyUnified.labelMedium.copyWith(
            color: TossDesignSystem.gray600,
          ),
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
                  _updateAccordionSection(
                    'concerns',
                    _selectedConcerns.toList(),
                    _selectedConcerns.join(', '),
                  );
                });
                TossDesignSystem.hapticLight();
                onComplete(_selectedConcerns.toList());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? TossDesignSystem.tossBlue.withOpacity(0.1)
                      : TossDesignSystem.gray100,
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
                    color: isSelected ? TossDesignSystem.tossBlue : null,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildInterestsInput(Function(dynamic) onComplete) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '복수 선택 가능',
          style: TypographyUnified.labelMedium.copyWith(
            color: TossDesignSystem.gray600,
          ),
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
                  _updateAccordionSection(
                    'interests',
                    _selectedInterests.toList(),
                    _selectedInterests.join(', '),
                  );
                });
                TossDesignSystem.hapticLight();
                onComplete(_selectedInterests.toList());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? TossDesignSystem.tossBlue.withOpacity(0.1)
                      : TossDesignSystem.gray100,
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
                    color: isSelected ? TossDesignSystem.tossBlue : null,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSelfEvaluationInput(Function(dynamic) onComplete) {
    return Column(
      children: [
        TextField(
          controller: _strengthsController,
          decoration: InputDecoration(
            labelText: '강점',
            hintText: '예: 책임감, 빠른 실행력, 창의적 사고...',
            filled: true,
            fillColor: TossDesignSystem.gray100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          maxLines: 2,
          onChanged: (value) {
            _updateAccordionSection(
              'selfEvaluation',
              value.isNotEmpty || _weaknessesController.text.isNotEmpty,
              value.isNotEmpty ? '강점: $value' : null,
            );
          },
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _weaknessesController,
          decoration: InputDecoration(
            labelText: '약점',
            hintText: '예: 우유부단함, 쉽게 포기함, 조급함...',
            filled: true,
            fillColor: TossDesignSystem.gray100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
          maxLines: 2,
        ),
      ],
    );
  }

  Widget _buildWorkStyleInput(Function(dynamic) onComplete) {
    return _buildPreferenceOptions(
      options: WorkStyleOptions.options,
      selectedValue: _workStyle,
      onSelect: (value) {
        setState(() {
          _workStyle = value;
          _updateAccordionSection('workStyle', value, value);
        });
        onComplete(value);
      },
    );
  }

  Widget _buildEnergySourceInput(Function(dynamic) onComplete) {
    return _buildPreferenceOptions(
      options: EnergySourceOptions.options,
      selectedValue: _energySource,
      onSelect: (value) {
        setState(() {
          _energySource = value;
          _updateAccordionSection('energySource', value, value);
        });
        onComplete(value);
      },
    );
  }

  Widget _buildProblemSolvingInput(Function(dynamic) onComplete) {
    return _buildPreferenceOptions(
      options: ProblemSolvingOptions.options,
      selectedValue: _problemSolving,
      onSelect: (value) {
        setState(() {
          _problemSolving = value;
          _updateAccordionSection('problemSolving', value, value);
        });
        onComplete(value);
      },
    );
  }

  Widget _buildPreferredRoleInput(Function(dynamic) onComplete) {
    return _buildPreferenceOptions(
      options: PreferredRoleOptions.options,
      selectedValue: _preferredRole,
      onSelect: (value) {
        setState(() {
          _preferredRole = value;
          _updateAccordionSection('preferredRole', value, value);
        });
        onComplete(value);
      },
    );
  }

  Widget _buildPreferenceOptions({
    required List<String> options,
    required String? selectedValue,
    required Function(String) onSelect,
  }) {
    return Column(
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
                    : TossDesignSystem.gray100,
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
                        color: isSelected ? TossDesignSystem.tossBlue : null,
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
    );
  }
}
