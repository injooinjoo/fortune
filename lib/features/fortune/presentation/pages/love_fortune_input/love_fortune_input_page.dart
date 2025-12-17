import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../core/widgets/accordion_input_section.dart';
import '../../../../../core/services/unified_fortune_service.dart';
import '../../../../../core/services/debug_premium_service.dart';
import '../../../../../core/services/fortune_haptic_service.dart';
import '../../../../../core/widgets/unified_button.dart';
import '../../../../../presentation/providers/token_provider.dart';
import '../../../../../presentation/providers/user_profile_notifier.dart';
import '../../../../../services/storage_service.dart';
import '../../../../fortune/domain/models/conditions/love_fortune_conditions.dart';
import '../../widgets/standard_fortune_app_bar.dart';
import '../love/love_fortune_result_page.dart';
import 'widgets/index.dart';
import 'love_fortune_input_helpers.dart';

class LoveFortuneInputPage extends ConsumerStatefulWidget {
  const LoveFortuneInputPage({super.key});

  @override
  ConsumerState<LoveFortuneInputPage> createState() => _LoveFortuneInputPageState();
}

class _LoveFortuneInputPageState extends ConsumerState<LoveFortuneInputPage> {
  List<AccordionInputSection> _accordionSections = [];

  // Step 1: 기본 정보
  int _age = 25;
  String? _gender;
  String? _relationshipStatus;

  // Step 2: 연애 스타일 & 가치관
  final Set<String> _datingStyles = {};
  final Map<String, double> _valueImportance = {
    '외모': 3.0,
    '성격': 3.0,
    '경제력': 3.0,
    '가치관': 3.0,
    '유머감각': 3.0,
  };

  // Step 3: 이상형
  RangeValues _preferredAgeRange = const RangeValues(20, 30);
  final Set<String> _preferredPersonality = {};
  final Set<String> _preferredMeetingPlaces = {};
  String? _relationshipGoal;

  // Step 4: 나의 매력
  double _appearanceConfidence = 5.0;
  final Set<String> _charmPoints = {};
  String? _lifestyle;
  final Set<String> _hobbies = {};

  bool _isLoading = false;
  final StorageService _storageService = StorageService();

  @override
  void initState() {
    super.initState();
    _initializeAccordionSections();

    // Pre-fill user data with profile if available
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // 1. 프로필에서 기본값 먼저 설정 (항상)
      final userProfileAsync = ref.read(userProfileProvider);
      final userProfile = userProfileAsync.maybeWhen(
        data: (profile) => profile,
        orElse: () => null,
      );

      if (userProfile != null && mounted) {
        setState(() {
          // 생년월일에서 나이 계산
          if (userProfile.birthDate != null) {
            final now = DateTime.now();
            int calculatedAge = now.year - userProfile.birthDate!.year;
            if (now.month < userProfile.birthDate!.month ||
                (now.month == userProfile.birthDate!.month &&
                    now.day < userProfile.birthDate!.day)) {
              calculatedAge--;
            }
            _age = calculatedAge;
          }
          // 성별 설정
          if (userProfile.gender != null) {
            _gender = userProfile.gender;
          }
        });
      }

      // 2. 저장된 입력값 복원 (있으면 프로필 값 덮어씀 - 사용자 선택 우선)
      await _loadSavedInput();

      // 3. Accordion 섹션 업데이트
      if (mounted) {
        _initializeAccordionSections();
      }
    });
  }

  /// 저장된 입력값 불러오기
  Future<void> _loadSavedInput() async {
    final savedInput = await _storageService.getLoveFortuneInput();
    if (savedInput == null || !mounted) return;

    setState(() {
      // 기본 정보
      _age = savedInput['age'] as int? ?? _age;
      _gender = savedInput['gender'] as String?;
      _relationshipStatus = savedInput['relationshipStatus'] as String?;

      // 연애 스타일
      final savedStyles = savedInput['datingStyles'] as List<dynamic>?;
      if (savedStyles != null) {
        _datingStyles.clear();
        _datingStyles.addAll(savedStyles.cast<String>());
      }

      // 이상형 중요도
      final savedImportance = savedInput['valueImportance'] as Map<String, dynamic>?;
      if (savedImportance != null) {
        savedImportance.forEach((key, value) {
          if (_valueImportance.containsKey(key)) {
            _valueImportance[key] = (value as num).toDouble();
          }
        });
      }

      // 이상형 나이대
      final savedAgeRange = savedInput['preferredAgeRange'] as Map<String, dynamic>?;
      if (savedAgeRange != null) {
        _preferredAgeRange = RangeValues(
          (savedAgeRange['min'] as num?)?.toDouble() ?? 20,
          (savedAgeRange['max'] as num?)?.toDouble() ?? 30,
        );
      }

      // 이상형 성격
      final savedPersonality = savedInput['preferredPersonality'] as List<dynamic>?;
      if (savedPersonality != null) {
        _preferredPersonality.clear();
        _preferredPersonality.addAll(savedPersonality.cast<String>());
      }

      // 만남 방식
      final savedPlaces = savedInput['preferredMeetingPlaces'] as List<dynamic>?;
      if (savedPlaces != null) {
        _preferredMeetingPlaces.clear();
        _preferredMeetingPlaces.addAll(savedPlaces.cast<String>());
      }
      _relationshipGoal = savedInput['relationshipGoal'] as String?;

      // 나의 매력
      final savedCharms = savedInput['charmPoints'] as List<dynamic>?;
      if (savedCharms != null) {
        _charmPoints.clear();
        _charmPoints.addAll(savedCharms.cast<String>());
      }
      _lifestyle = savedInput['lifestyle'] as String?;

      // 자신감 & 취미
      _appearanceConfidence = (savedInput['appearanceConfidence'] as num?)?.toDouble() ?? 5.0;
      final savedHobbies = savedInput['hobbies'] as List<dynamic>?;
      if (savedHobbies != null) {
        _hobbies.clear();
        _hobbies.addAll(savedHobbies.cast<String>());
      }
    });

    // Accordion 섹션 업데이트
    _initializeAccordionSections();
    debugPrint('[LoveFortuneInput] 저장된 입력값 복원 완료');
  }

  /// 현재 입력값 저장
  Future<void> _saveCurrentInput() async {
    final inputData = {
      'age': _age,
      'gender': _gender,
      'relationshipStatus': _relationshipStatus,
      'datingStyles': _datingStyles.toList(),
      'valueImportance': _valueImportance,
      'preferredAgeRange': {
        'min': _preferredAgeRange.start.round(),
        'max': _preferredAgeRange.end.round(),
      },
      'preferredPersonality': _preferredPersonality.toList(),
      'preferredMeetingPlaces': _preferredMeetingPlaces.toList(),
      'relationshipGoal': _relationshipGoal,
      'appearanceConfidence': _appearanceConfidence,
      'charmPoints': _charmPoints.toList(),
      'lifestyle': _lifestyle,
      'hobbies': _hobbies.toList(),
    };
    await _storageService.saveLoveFortuneInput(inputData);
  }

  void _initializeAccordionSections() {
    _accordionSections = [
      // 1. 나의 기본 정보
      AccordionInputSection(
        id: 'basicInfo',
        title: '나의 기본 정보',
        icon: Icons.person_outline,
        inputWidgetBuilder: (context, onComplete) => BasicInfoInput(
          age: _age,
          gender: _gender,
          relationshipStatus: _relationshipStatus,
          onAgeChanged: (value) => setState(() => _age = value),
          onGenderChanged: (value) => setState(() => _gender = value),
          onRelationshipStatusChanged: (value) => setState(() => _relationshipStatus = value),
          onComplete: () => _checkBasicInfoComplete(onComplete),
        ),
        value: _gender != null && _relationshipStatus != null
            ? {'age': _age, 'gender': _gender, 'relationshipStatus': _relationshipStatus}
            : null,
        isCompleted: _gender != null && _relationshipStatus != null,
        displayValue: _gender != null && _relationshipStatus != null
            ? '$_age세 · ${LoveFortuneInputHelpers.getGenderText(_gender!)} · ${LoveFortuneInputHelpers.getRelationshipStatusText(_relationshipStatus!)}'
            : null,
      ),

      // 2. 나의 연애 스타일
      AccordionInputSection(
        id: 'datingStyles',
        title: '나의 연애 스타일',
        icon: Icons.favorite_border,
        inputWidgetBuilder: (context, onComplete) => DatingStylesInput(
          selectedStyles: _datingStyles,
          onStyleToggled: (styleId) {
            setState(() {
              if (_datingStyles.contains(styleId)) {
                _datingStyles.remove(styleId);
              } else {
                _datingStyles.add(styleId);
              }
            });
            _updateAccordionSection(
              'datingStyles',
              _datingStyles.toList(),
              _datingStyles.map((s) => LoveFortuneInputHelpers.getDatingStyleText(s)).join(', '),
            );
            onComplete(_datingStyles.toList());
          },
        ),
        value: _datingStyles.toList(),
        isCompleted: _datingStyles.isNotEmpty,
        displayValue: _datingStyles.isNotEmpty
            ? _datingStyles.map((s) => LoveFortuneInputHelpers.getDatingStyleText(s)).join(', ')
            : null,
        isMultiSelect: true,
      ),

      // 3. 이상형 조건별 중요도
      AccordionInputSection(
        id: 'valueImportance',
        title: '이상형 조건별 중요도',
        icon: Icons.stars_rounded,
        inputWidgetBuilder: (context, onComplete) => ValueImportanceInput(
          valueImportance: _valueImportance,
          onValueChanged: (entry) {
            setState(() {
              _valueImportance[entry.key] = entry.value;
            });
            _updateAccordionSection(
              'valueImportance',
              _valueImportance,
              _buildValueImportanceDisplay(),
            );
            onComplete(_valueImportance);
          },
        ),
        value: _valueImportance,
        isCompleted: true,
        displayValue: _buildValueImportanceDisplay(),
      ),

      // 4. 이상형 나이대
      AccordionInputSection(
        id: 'preferredAgeRange',
        title: '이상형 나이대',
        icon: Icons.cake_rounded,
        inputWidgetBuilder: (context, onComplete) => PreferredAgeRangeInput(
          preferredAgeRange: _preferredAgeRange,
          onAgeRangeChanged: (values) {
            setState(() {
              _preferredAgeRange = values;
            });
            final data = {
              'min': values.start.round(),
              'max': values.end.round(),
            };
            _updateAccordionSection(
              'preferredAgeRange',
              data,
              '${values.start.round()}세 ~ ${values.end.round()}세',
            );
            onComplete(data);
          },
        ),
        value: {
          'min': _preferredAgeRange.start.round(),
          'max': _preferredAgeRange.end.round(),
        },
        isCompleted: true,
        displayValue: '${_preferredAgeRange.start.round()}세 ~ ${_preferredAgeRange.end.round()}세',
      ),

      // 5. 이상형의 성격
      AccordionInputSection(
        id: 'preferredPersonality',
        title: '이상형의 성격',
        icon: Icons.emoji_emotions_outlined,
        inputWidgetBuilder: (context, onComplete) => PreferredPersonalityInput(
          selectedPersonality: _preferredPersonality,
          onPersonalityToggled: (trait) {
            setState(() {
              if (_preferredPersonality.contains(trait)) {
                _preferredPersonality.remove(trait);
              } else if (_preferredPersonality.length < 4) {
                _preferredPersonality.add(trait);
              }
            });
            _updateAccordionSection(
              'preferredPersonality',
              _preferredPersonality.toList(),
              _preferredPersonality.join(', '),
            );
            // 4개 선택 시에만 자동으로 다음 섹션으로 이동
            if (_preferredPersonality.length == 4) {
              onComplete(_preferredPersonality.toList());
            }
          },
        ),
        value: _preferredPersonality.toList(),
        isCompleted: _preferredPersonality.length == 4,
        displayValue: _preferredPersonality.isNotEmpty
            ? _preferredPersonality.join(', ')
            : null,
        isMultiSelect: false, // 4개 선택 시 자동 넘김 활성화
      ),

      // 6. 만남 방식
      AccordionInputSection(
        id: 'meetingPlacesAndGoal',
        title: '만남 방식',
        icon: Icons.location_on_outlined,
        inputWidgetBuilder: (context, onComplete) => MeetingPlacesAndGoalInput(
          selectedMeetingPlaces: _preferredMeetingPlaces,
          relationshipGoal: _relationshipGoal,
          onMeetingPlaceToggled: (placeId) {
            setState(() {
              if (_preferredMeetingPlaces.contains(placeId)) {
                _preferredMeetingPlaces.remove(placeId);
              } else {
                _preferredMeetingPlaces.add(placeId);
              }
            });
            _checkMeetingPlacesAndGoalComplete(onComplete);
          },
          onRelationshipGoalChanged: (goal) {
            setState(() {
              _relationshipGoal = goal;
            });
            _checkMeetingPlacesAndGoalComplete(onComplete);
          },
        ),
        value: _preferredMeetingPlaces.isNotEmpty && _relationshipGoal != null
            ? {
                'places': _preferredMeetingPlaces.toList(),
                'goal': _relationshipGoal,
              }
            : null,
        isCompleted: _preferredMeetingPlaces.isNotEmpty && _relationshipGoal != null,
        displayValue: _preferredMeetingPlaces.isNotEmpty && _relationshipGoal != null
            ? '${_relationshipGoal == 'casual' ? '가벼운 만남' : _relationshipGoal == 'serious' ? '진지한 연애' : '결혼 전제'} · ${_preferredMeetingPlaces.length}곳'
            : null,
      ),

      // 7. 나의 매력
      AccordionInputSection(
        id: 'charmAndLifestyle',
        title: '나의 매력',
        icon: Icons.auto_awesome,
        inputWidgetBuilder: (context, onComplete) => CharmAndLifestyleInput(
          selectedCharmPoints: _charmPoints,
          lifestyle: _lifestyle,
          onCharmPointToggled: (charm) {
            setState(() {
              if (_charmPoints.contains(charm)) {
                _charmPoints.remove(charm);
              } else {
                _charmPoints.add(charm);
              }
            });
            _checkCharmAndLifestyleComplete(onComplete);
          },
          onLifestyleChanged: (value) {
            setState(() {
              _lifestyle = value;
            });
            _checkCharmAndLifestyleComplete(onComplete);
          },
        ),
        value: _charmPoints.isNotEmpty && _lifestyle != null
            ? {
                'charmPoints': _charmPoints.toList(),
                'lifestyle': _lifestyle,
              }
            : null,
        isCompleted: _charmPoints.isNotEmpty && _lifestyle != null,
        displayValue: _charmPoints.isNotEmpty && _lifestyle != null
            ? '${LoveFortuneInputHelpers.getLifestyleText(_lifestyle!)} · ${_charmPoints.length}개'
            : null,
      ),

      // 8. 자신감 & 취미
      AccordionInputSection(
        id: 'confidenceAndHobbies',
        title: '자신감 & 취미',
        icon: Icons.sports_esports_outlined,
        inputWidgetBuilder: (context, onComplete) => ConfidenceAndHobbiesInput(
          appearanceConfidence: _appearanceConfidence,
          selectedHobbies: _hobbies,
          onConfidenceChanged: (value) {
            setState(() {
              _appearanceConfidence = value;
            });
            _checkConfidenceAndHobbiesComplete(onComplete);
          },
          onHobbyToggled: (hobbyId) {
            setState(() {
              if (_hobbies.contains(hobbyId)) {
                _hobbies.remove(hobbyId);
              } else {
                _hobbies.add(hobbyId);
              }
            });
            _checkConfidenceAndHobbiesComplete(onComplete);
          },
        ),
        value: _hobbies.isNotEmpty
            ? {
                'appearanceConfidence': _appearanceConfidence,
                'hobbies': _hobbies.toList(),
              }
            : null,
        isCompleted: _hobbies.isNotEmpty,
        displayValue: _hobbies.isNotEmpty
            ? '자신감 ${_appearanceConfidence.round()}점 · ${_hobbies.length}개 취미'
            : null,
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
          isCompleted: value != null &&
                      (value is! String || value.isNotEmpty) &&
                      (value is! List || value.isNotEmpty) &&
                      (value is! Set || value.isNotEmpty) &&
                      (value is! Map || value.isNotEmpty),
          displayValue: displayValue,
          isMultiSelect: _accordionSections[index].isMultiSelect,
        );
      });
      // 입력값 변경 시 저장
      _saveCurrentInput();
    }
  }

  void _checkBasicInfoComplete(Function(dynamic) onComplete) {
    if (_gender != null && _relationshipStatus != null) {
      final data = {
        'age': _age,
        'gender': _gender,
        'relationshipStatus': _relationshipStatus,
      };
      _updateAccordionSection(
        'basicInfo',
        data,
        '$_age세 · ${LoveFortuneInputHelpers.getGenderText(_gender!)} · ${LoveFortuneInputHelpers.getRelationshipStatusText(_relationshipStatus!)}',
      );
      onComplete(data);
    }
  }

  void _checkMeetingPlacesAndGoalComplete(Function(dynamic) onComplete) {
    if (_preferredMeetingPlaces.isNotEmpty && _relationshipGoal != null) {
      final data = {
        'places': _preferredMeetingPlaces.toList(),
        'goal': _relationshipGoal,
      };
      _updateAccordionSection(
        'meetingPlacesAndGoal',
        data,
        '${_relationshipGoal == 'casual' ? '가벼운 만남' : _relationshipGoal == 'serious' ? '진지한 연애' : '결혼 전제'} · ${_preferredMeetingPlaces.length}곳',
      );
      onComplete(data);
    }
  }

  void _checkCharmAndLifestyleComplete(Function(dynamic) onComplete) {
    if (_charmPoints.isNotEmpty && _lifestyle != null) {
      final data = {
        'charmPoints': _charmPoints.toList(),
        'lifestyle': _lifestyle,
      };
      _updateAccordionSection(
        'charmAndLifestyle',
        data,
        '${LoveFortuneInputHelpers.getLifestyleText(_lifestyle!)} · ${_charmPoints.length}개',
      );
      onComplete(data);
    }
  }

  void _checkConfidenceAndHobbiesComplete(Function(dynamic) onComplete) {
    if (_hobbies.isNotEmpty) {
      final data = {
        'appearanceConfidence': _appearanceConfidence,
        'hobbies': _hobbies.toList(),
      };
      _updateAccordionSection(
        'confidenceAndHobbies',
        data,
        '자신감 ${_appearanceConfidence.round()}점 · ${_hobbies.length}개 취미',
      );
      onComplete(data);
    }
  }

  /// 중요도 표시 문자열 생성 (개별 항목별)
  String _buildValueImportanceDisplay() {
    final items = _valueImportance.entries.map((e) {
      final shortName = e.key.substring(0, 1); // 외, 성, 경, 가, 유
      return '$shortName${e.value.round()}';
    }).join(' ');
    return items; // 예: "외3 성4 경2 가5 유3"
  }

  bool _canGenerate() {
    return _gender != null &&
        _relationshipStatus != null &&
        _datingStyles.isNotEmpty &&
        _preferredPersonality.isNotEmpty &&
        _preferredMeetingPlaces.isNotEmpty &&
        _relationshipGoal != null &&
        _charmPoints.isNotEmpty &&
        _lifestyle != null &&
        _hobbies.isNotEmpty;
  }

  Future<void> _analyzeAndShowResult() async {
    if (!_canGenerate() || _isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Premium 상태 확인
      final debugOverride = await DebugPremiumService.getOverrideValue();
      final tokenState = ref.read(tokenProvider);
      final isPremium = debugOverride ?? tokenState.hasUnlimitedAccess;

      // 2. 입력 데이터 구성
      final inputData = {
        'age': _age,
        'gender': _gender,
        'relationshipStatus': _relationshipStatus,
        'datingStyles': _datingStyles.toList(),
        'valueImportance': _valueImportance,
        'preferredAgeRange': {
          'min': _preferredAgeRange.start.round(),
          'max': _preferredAgeRange.end.round(),
        },
        'preferredPersonality': _preferredPersonality.toList(),
        'preferredMeetingPlaces': _preferredMeetingPlaces.toList(),
        'relationshipGoal': _relationshipGoal,
        'appearanceConfidence': _appearanceConfidence,
        'charmPoints': _charmPoints.toList(),
        'lifestyle': _lifestyle,
        'hobbies': _hobbies.toList(),
        'isPremium': isPremium,
      };

      // 3. LoveFortuneConditions 생성
      final conditions = LoveFortuneConditions.fromInputData(inputData);

      // 4. UnifiedFortuneService 호출
      final fortuneService = UnifiedFortuneService(
        Supabase.instance.client,
        enableOptimization: true,
      );

      final fortuneResult = await fortuneService.getFortune(
        fortuneType: 'love',
        dataSource: FortuneDataSource.api,
        inputConditions: inputData,
        conditions: conditions,
        isPremium: isPremium,
      );

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // 입력 완료 햅틱
        ref.read(fortuneHapticServiceProvider).sectionComplete();

        // 5. 결과 페이지로 이동
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LoveFortuneResultPage(
              fortuneResult: fortuneResult,
            ),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [연애운] 에러 발생: $e');
      debugPrint('Stack trace: $stackTrace');

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('오류 발생'),
              content: Text('연애운 생성 중 오류가 발생했습니다.\n$e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: const StandardFortuneAppBar(
        title: '연애운',
      ),
      body: SafeArea(
        child: Stack(
          children: [
            _accordionSections.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : AccordionInputFormWithHeader(
                    header: _buildTitleSection(context),
                    sections: _accordionSections,
                    onAllCompleted: null,
                    completionButtonText: '연애운세 보기',
                  ),
            if (_canGenerate())
              UnifiedButton.floating(
                text: '🔮 연애운세 보기',
                onPressed: _canGenerate() ? () => _analyzeAndShowResult() : null,
                isEnabled: _canGenerate() && !_isLoading,
                isLoading: _isLoading,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '연애운세',
            style: DSTypography.displayLarge.copyWith(
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '솔직하게 답할수록 정확한 조언을 드려요',
            style: DSTypography.bodyMedium.copyWith(
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
