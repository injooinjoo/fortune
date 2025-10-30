import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/widgets/accordion_input_section.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../core/services/debug_premium_service.dart';
import '../../../../shared/components/toss_floating_progress_button.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../fortune/domain/models/conditions/love_fortune_conditions.dart';
import '../widgets/standard_fortune_app_bar.dart';
import 'love/love_fortune_result_page.dart';

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

  @override
  void initState() {
    super.initState();
    _initializeAccordionSections();
  }

  void _initializeAccordionSections() {
    _accordionSections = [
      // 1. 나의 기본 정보 (나이, 성별, 연애 상태)
      AccordionInputSection(
        id: 'basicInfo',
        title: '나의 기본 정보',
        icon: Icons.person_outline,
        inputWidgetBuilder: (context, onComplete) => _buildBasicInfoInput(onComplete),
        value: _gender != null && _relationshipStatus != null
            ? {'age': _age, 'gender': _gender, 'relationshipStatus': _relationshipStatus}
            : null,
        isCompleted: _gender != null && _relationshipStatus != null,
        displayValue: _gender != null && _relationshipStatus != null
            ? '$_age세 · ${_getGenderText(_gender!)} · ${_getRelationshipStatusText(_relationshipStatus!)}'
            : null,
      ),

      // 2. 나의 연애 스타일 (다중 선택)
      AccordionInputSection(
        id: 'datingStyles',
        title: '나의 연애 스타일',
        icon: Icons.favorite_border,
        inputWidgetBuilder: (context, onComplete) => _buildDatingStylesInput(onComplete),
        value: _datingStyles.toList(),
        isCompleted: _datingStyles.isNotEmpty,
        displayValue: _datingStyles.isNotEmpty
            ? _datingStyles.map((s) => _getDatingStyleText(s)).join(', ')
            : null,
        isMultiSelect: true, // 다중 선택 - 선택 후에도 닫히지 않음
      ),

      // 3. 이상형 조건 중요도 (5개 슬라이더)
      AccordionInputSection(
        id: 'valueImportance',
        title: '이상형 조건별 중요도',
        icon: Icons.stars_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildValueImportanceInput(onComplete),
        value: _valueImportance,
        isCompleted: true, // 기본값 3.0이므로 항상 완료
        displayValue: '평균 ${_getAverageImportance().toStringAsFixed(1)}점',
      ),

      // 4. 이상형 나이대 (RangeSlider)
      AccordionInputSection(
        id: 'preferredAgeRange',
        title: '이상형 나이대',
        icon: Icons.cake_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildPreferredAgeRangeInput(onComplete),
        value: {
          'min': _preferredAgeRange.start.round(),
          'max': _preferredAgeRange.end.round(),
        },
        isCompleted: true, // 기본값이 있으므로 항상 완료
        displayValue: '${_preferredAgeRange.start.round()}세 ~ ${_preferredAgeRange.end.round()}세',
      ),

      // 5. 이상형 성격 (다중 선택, 최대 4개)
      AccordionInputSection(
        id: 'preferredPersonality',
        title: '이상형의 성격',
        icon: Icons.emoji_emotions_outlined,
        inputWidgetBuilder: (context, onComplete) => _buildPreferredPersonalityInput(onComplete),
        value: _preferredPersonality.toList(),
        isCompleted: _preferredPersonality.isNotEmpty,
        displayValue: _preferredPersonality.isNotEmpty
            ? _preferredPersonality.join(', ')
            : null,
        isMultiSelect: true, // 다중 선택 - 선택 후에도 닫히지 않음
      ),

      // 6. 만남 장소 & 연애 목표
      AccordionInputSection(
        id: 'meetingPlacesAndGoal',
        title: '만남 방식',
        icon: Icons.location_on_outlined,
        inputWidgetBuilder: (context, onComplete) => _buildMeetingPlacesAndGoalInput(onComplete),
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

      // 7. 나의 매력 & 라이프스타일
      AccordionInputSection(
        id: 'charmAndLifestyle',
        title: '나의 매력',
        icon: Icons.auto_awesome,
        inputWidgetBuilder: (context, onComplete) => _buildCharmAndLifestyleInput(onComplete),
        value: _charmPoints.isNotEmpty && _lifestyle != null
            ? {
                'charmPoints': _charmPoints.toList(),
                'lifestyle': _lifestyle,
              }
            : null,
        isCompleted: _charmPoints.isNotEmpty && _lifestyle != null,
        displayValue: _charmPoints.isNotEmpty && _lifestyle != null
            ? '${_getLifestyleText(_lifestyle!)} · ${_charmPoints.length}개'
            : null,
      ),

      // 8. 외모 자신감 & 취미
      AccordionInputSection(
        id: 'confidenceAndHobbies',
        title: '자신감 & 취미',
        icon: Icons.sports_esports_outlined,
        inputWidgetBuilder: (context, onComplete) => _buildConfidenceAndHobbiesInput(onComplete),
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
    }
  }

  bool _canGenerate() {
    // 필수: 성별, 연애상태, 연애스타일, 선호성격, 만남장소, 연애목표, 매력포인트, 라이프스타일, 취미
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

  bool _isLoading = false;

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

        // 에러 다이얼로그 표시
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.white,
      appBar: const StandardFortuneAppBar(
        title: '연애운',
      ),
      body: SafeArea(
        child: Stack(
          children: [
            _accordionSections.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : AccordionInputFormWithHeader(
                    header: _buildTitleSection(isDark),
                    sections: _accordionSections,
                    onAllCompleted: null,
                    completionButtonText: '연애운세 보기',
                  ),
            if (_canGenerate())
              TossFloatingProgressButtonPositioned(
                text: '🔮 연애운세 보기',
                onPressed: _canGenerate() ? () => _analyzeAndShowResult() : null,
                isEnabled: _canGenerate() && !_isLoading,
                showProgress: false,
                isVisible: _canGenerate(),
                isLoading: _isLoading,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(bool isDark) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '연애운세',
            style: TypographyUnified.heading1.copyWith(
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '솔직하게 답할수록 정확한 조언을 드려요',
            style: TypographyUnified.bodyMedium.copyWith(
              color: isDark ? TossDesignSystem.textSecondaryDark : TossDesignSystem.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  // ========================================
  // Input Builder Methods (각 섹션의 입력 UI)
  // ========================================

  /// Section 1: 기본 정보 (나이, 성별, 연애 상태)
  Widget _buildBasicInfoInput(Function(dynamic) onComplete) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 나이 슬라이더
        Text(
          '나이',
          style: TypographyUnified.labelLarge.copyWith(
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: TossDesignSystem.tossBlue,
            inactiveTrackColor: isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200,
            thumbColor: TossDesignSystem.tossBlue,
            overlayColor: TossDesignSystem.tossBlue.withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            trackHeight: 4,
          ),
          child: Slider(
            value: _age.toDouble(),
            min: 18,
            max: 50,
            divisions: 32,
            onChanged: (value) {
              setState(() {
                _age = value.round();
              });
            },
          ),
        ),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: TossDesignSystem.tossBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$_age세',
              style: TypographyUnified.bodyMedium.copyWith(
                color: TossDesignSystem.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // 성별 선택
        Text(
          '성별',
          style: TypographyUnified.labelLarge.copyWith(
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildGenderButton('male', '남성', Icons.male, isDark, onComplete),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildGenderButton('female', '여성', Icons.female, isDark, onComplete),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // 연애 상태 선택
        Text(
          '현재 연애 상태',
          style: TypographyUnified.labelLarge.copyWith(
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ..._buildRelationshipStatusButtons(isDark, onComplete),
      ],
    );
  }

  Widget _buildGenderButton(String value, String label, IconData icon, bool isDark, Function(dynamic) onComplete) {
    final isSelected = _gender == value;
    return InkWell(
      onTap: () {
        setState(() {
          _gender = value;
          _checkBasicInfoComplete(onComplete);
        });
        TossDesignSystem.hapticLight();
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
              : (isDark ? TossDesignSystem.cardBackgroundDark : TossTheme.backgroundSecondary),
          border: Border.all(
            color: isSelected
                ? TossDesignSystem.tossBlue
                : (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? TossDesignSystem.tossBlue
                  : (isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TypographyUnified.bodyMedium.copyWith(
                color: isSelected
                    ? TossDesignSystem.tossBlue
                    : (isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600),
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildRelationshipStatusButtons(bool isDark, Function(dynamic) onComplete) {
    final statuses = [
      {'id': 'single', 'text': '싱글 (새로운 만남 희망)', 'emoji': '💫'},
      {'id': 'dating', 'text': '연애중 (관계 발전)', 'emoji': '💕'},
      {'id': 'breakup', 'text': '이별 후 (재회 또는 새출발)', 'emoji': '🌱'},
      {'id': 'crush', 'text': '짝사랑 중', 'emoji': '💘'},
    ];

    return statuses.map((status) {
      final isSelected = _relationshipStatus == status['id'];
      return Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: InkWell(
          onTap: () {
            setState(() {
              _relationshipStatus = status['id'] as String;
              _checkBasicInfoComplete(onComplete);
            });
            TossDesignSystem.hapticLight();
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected
                  ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
                  : (isDark ? TossDesignSystem.cardBackgroundDark : TossTheme.backgroundSecondary),
              border: Border.all(
                color: isSelected
                    ? TossDesignSystem.tossBlue
                    : (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                width: isSelected ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Text(
                  status['emoji'] as String,
                  style: TypographyUnified.displaySmall,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    status['text'] as String,
                    style: TypographyUnified.bodyMedium.copyWith(
                      color: isSelected
                          ? TossDesignSystem.tossBlue
                          : (isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack),
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    ),
                  ),
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: TossDesignSystem.tossBlue,
                    size: 20,
                  ),
              ],
            ),
          ),
        ),
      );
    }).toList();
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
        '$_age세 · ${_getGenderText(_gender!)} · ${_getRelationshipStatusText(_relationshipStatus!)}',
      );
      onComplete(data);
    }
  }

  /// Section 2: 연애 스타일 (다중 선택)
  Widget _buildDatingStylesInput(Function(dynamic) onComplete) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final styles = [
      {'id': 'active', 'text': '적극적', 'emoji': '🔥'},
      {'id': 'passive', 'text': '소극적', 'emoji': '🌸'},
      {'id': 'emotional', 'text': '감성적', 'emoji': '💖'},
      {'id': 'logical', 'text': '이성적', 'emoji': '🧠'},
      {'id': 'independent', 'text': '독립적', 'emoji': '🦅'},
      {'id': 'dependent', 'text': '의존적', 'emoji': '🤝'},
      {'id': 'serious', 'text': '진지한', 'emoji': '💍'},
      {'id': 'casual', 'text': '가벼운', 'emoji': '😊'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '여러 개 선택 가능',
          style: TypographyUnified.labelMedium.copyWith(
            color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 2.5,
          children: styles.map((style) {
            final styleId = style['id'] as String;
            final isSelected = _datingStyles.contains(styleId);
            return InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _datingStyles.remove(styleId);
                  } else {
                    _datingStyles.add(styleId);
                  }
                });
                TossDesignSystem.hapticLight();
                _updateAccordionSection(
                  'datingStyles',
                  _datingStyles.toList(),
                  _datingStyles.map((s) => _getDatingStyleText(s)).join(', '),
                );
                onComplete(_datingStyles.toList());
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? TossDesignSystem.tossBlue
                      : (isDark ? TossDesignSystem.cardBackgroundDark : TossTheme.backgroundSecondary),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? TossDesignSystem.tossBlue
                        : (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      style['emoji'] as String,
                      style: TypographyUnified.heading4,
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        style['text'] as String,
                        style: TypographyUnified.bodyMedium.copyWith(
                          color: isSelected
                              ? TossDesignSystem.white
                              : (isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Section 3: 중요한 가치 (5개 슬라이더)
  Widget _buildValueImportanceInput(Function(dynamic) onComplete) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: TossTheme.success.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '1~5점으로 평가',
            style: TypographyUnified.labelMedium.copyWith(
              color: TossTheme.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          '각 항목이 연애할 때 얼마나 중요한지 점수를 매겨주세요',
          style: TypographyUnified.bodySmall.copyWith(
            color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
          ),
        ),
        const SizedBox(height: 20),
        ..._valueImportance.entries.map((entry) {
          return _buildValueSlider(entry.key, entry.value, isDark, onComplete);
        }),
      ],
    );
  }

  Widget _buildValueSlider(String label, double value, bool isDark, Function(dynamic) onComplete) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: TypographyUnified.bodyMedium.copyWith(
                  color: isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getScoreColor(value).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${value.round()}점',
                  style: TypographyUnified.labelLarge.copyWith(
                    color: _getScoreColor(value),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: _getScoreColor(value),
              inactiveTrackColor: isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200,
              thumbColor: _getScoreColor(value),
              overlayColor: _getScoreColor(value).withValues(alpha: 0.2),
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
              trackHeight: 4,
            ),
            child: Slider(
              value: value,
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: (newValue) {
                setState(() {
                  _valueImportance[label] = newValue;
                });
                _updateAccordionSection(
                  'valueImportance',
                  _valueImportance,
                  '평균 ${_getAverageImportance().toStringAsFixed(1)}점',
                );
                onComplete(_valueImportance);
              },
            ),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score <= 2) {
      return TossTheme.textGray500;
    } else if (score <= 3) {
      return TossTheme.warning;
    } else if (score <= 4) {
      return TossTheme.success;
    } else {
      return TossTheme.primaryBlue;
    }
  }

  double _getAverageImportance() {
    if (_valueImportance.isEmpty) return 0.0;
    return _valueImportance.values.reduce((a, b) => a + b) / _valueImportance.length;
  }

  /// Section 4: 선호 나이대 (RangeSlider)
  Widget _buildPreferredAgeRangeInput(Function(dynamic) onComplete) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '18세',
              style: TypographyUnified.bodySmall.copyWith(
                color: isDark ? TossDesignSystem.textTertiaryDark : TossTheme.textGray500,
              ),
            ),
            Text(
              '45세',
              style: TypographyUnified.bodySmall.copyWith(
                color: isDark ? TossDesignSystem.textTertiaryDark : TossTheme.textGray500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        RangeSlider(
          values: _preferredAgeRange,
          min: 18,
          max: 45,
          divisions: 27,
          activeColor: TossDesignSystem.tossBlue,
          inactiveColor: isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200,
          onChanged: (RangeValues values) {
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
        const SizedBox(height: 8),
        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: TossDesignSystem.tossBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_preferredAgeRange.start.round()}세 ~ ${_preferredAgeRange.end.round()}세',
              style: TypographyUnified.bodyMedium.copyWith(
                color: TossDesignSystem.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Section 5: 선호 성격 (다중 선택, 최대 4개)
  Widget _buildPreferredPersonalityInput(Function(dynamic) onComplete) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final traits = [
      '활발한', '차분한', '유머러스한', '진중한', '외향적인', '내향적인',
      '모험적인', '안정적인', '로맨틱한', '현실적인', '창의적인', '체계적인'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: TossTheme.primaryBlue.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '최대 4개까지 선택',
            style: TypographyUnified.labelMedium.copyWith(
              color: TossTheme.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: traits.map((trait) {
            final isSelected = _preferredPersonality.contains(trait);
            final canSelect = _preferredPersonality.length < 4 || isSelected;
            return InkWell(
              onTap: canSelect
                  ? () {
                      setState(() {
                        if (isSelected) {
                          _preferredPersonality.remove(trait);
                        } else {
                          _preferredPersonality.add(trait);
                        }
                      });
                      TossDesignSystem.hapticLight();
                      _updateAccordionSection(
                        'preferredPersonality',
                        _preferredPersonality.toList(),
                        _preferredPersonality.join(', '),
                      );
                      onComplete(_preferredPersonality.toList());
                    }
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
                      : (isDark ? TossDesignSystem.cardBackgroundDark : TossTheme.backgroundSecondary),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? TossDesignSystem.tossBlue
                        : (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  trait,
                  style: TypographyUnified.bodySmall.copyWith(
                    color: isSelected
                        ? TossDesignSystem.tossBlue
                        : canSelect
                            ? (isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack)
                            : TossTheme.textGray400,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Section 6: 만남 장소 & 연애 목표
  Widget _buildMeetingPlacesAndGoalInput(Function(dynamic) onComplete) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final places = [
      {'id': 'cafe', 'text': '카페·맛집', 'emoji': '☕'},
      {'id': 'gym', 'text': '헬스장·운동시설', 'emoji': '🏋️'},
      {'id': 'library', 'text': '도서관·문화공간', 'emoji': '📚'},
      {'id': 'meeting', 'text': '소개팅·미팅', 'emoji': '👥'},
      {'id': 'app', 'text': '앱·온라인', 'emoji': '📱'},
      {'id': 'hobby', 'text': '취미모임·동호회', 'emoji': '🎭'},
    ];

    final goals = [
      {'id': 'casual', 'text': '가벼운 만남', 'emoji': '😊'},
      {'id': 'serious', 'text': '진지한 연애', 'emoji': '💕'},
      {'id': 'marriage', 'text': '결혼 전제', 'emoji': '💍'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 만남 장소
        Text(
          '선호하는 만남 장소',
          style: TypographyUnified.labelLarge.copyWith(
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '여러 개 선택 가능',
          style: TypographyUnified.labelMedium.copyWith(
            color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: places.map((place) {
            final placeId = place['id'] as String;
            final isSelected = _preferredMeetingPlaces.contains(placeId);
            return InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _preferredMeetingPlaces.remove(placeId);
                  } else {
                    _preferredMeetingPlaces.add(placeId);
                  }
                });
                TossDesignSystem.hapticLight();
                _checkMeetingPlacesAndGoalComplete(onComplete);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
                      : (isDark ? TossDesignSystem.cardBackgroundDark : TossTheme.backgroundSecondary),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? TossDesignSystem.tossBlue
                        : (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      place['emoji'] as String,
                      style: TypographyUnified.bodyMedium,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      place['text'] as String,
                      style: TypographyUnified.bodySmall.copyWith(
                        color: isSelected
                            ? TossDesignSystem.tossBlue
                            : (isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // 연애 목표
        Text(
          '연애 목표',
          style: TypographyUnified.labelLarge.copyWith(
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        ...goals.map((goal) {
          final goalId = goal['id'] as String;
          final isSelected = _relationshipGoal == goalId;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: InkWell(
              onTap: () {
                setState(() {
                  _relationshipGoal = goalId;
                });
                TossDesignSystem.hapticLight();
                _checkMeetingPlacesAndGoalComplete(onComplete);
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isSelected
                      ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
                      : (isDark ? TossDesignSystem.cardBackgroundDark : TossTheme.backgroundSecondary),
                  border: Border.all(
                    color: isSelected
                        ? TossDesignSystem.tossBlue
                        : (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                    width: isSelected ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      goal['emoji'] as String,
                      style: TypographyUnified.displaySmall,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        goal['text'] as String,
                        style: TypographyUnified.bodyMedium.copyWith(
                          color: isSelected
                              ? TossDesignSystem.tossBlue
                              : (isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack),
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                        ),
                      ),
                    ),
                    if (isSelected)
                      Icon(
                        Icons.check_circle,
                        color: TossDesignSystem.tossBlue,
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ],
    );
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

  /// Section 7: 나의 매력 & 라이프스타일
  Widget _buildCharmAndLifestyleInput(Function(dynamic) onComplete) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final charmOptions = [
      '유머감각', '배려심', '경제력', '외모', '성실함', '지적능력',
      '사교성', '요리실력', '운동신경', '예술감각', '리더십', '따뜻함'
    ];

    final lifestyles = [
      {'id': 'employee', 'text': '직장인', 'emoji': '💼'},
      {'id': 'student', 'text': '학생', 'emoji': '📚'},
      {'id': 'freelancer', 'text': '프리랜서', 'emoji': '💻'},
      {'id': 'business', 'text': '사업가', 'emoji': '🏢'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 매력 포인트
        Text(
          '나의 매력 포인트',
          style: TypographyUnified.labelLarge.copyWith(
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '여러 개 선택 가능',
          style: TypographyUnified.labelMedium.copyWith(
            color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: charmOptions.map((charm) {
            final isSelected = _charmPoints.contains(charm);
            return InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _charmPoints.remove(charm);
                  } else {
                    _charmPoints.add(charm);
                  }
                });
                TossDesignSystem.hapticLight();
                _checkCharmAndLifestyleComplete(onComplete);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
                      : (isDark ? TossDesignSystem.cardBackgroundDark : TossTheme.backgroundSecondary),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? TossDesignSystem.tossBlue
                        : (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Text(
                  charm,
                  style: TypographyUnified.bodySmall.copyWith(
                    color: isSelected
                        ? TossDesignSystem.tossBlue
                        : (isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),

        // 라이프스타일
        Text(
          '라이프스타일',
          style: TypographyUnified.labelLarge.copyWith(
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: lifestyles.map((lifestyle) {
            final lifestyleId = lifestyle['id'] as String;
            final isSelected = _lifestyle == lifestyleId;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () {
                    setState(() {
                      _lifestyle = lifestyleId;
                    });
                    TossDesignSystem.hapticLight();
                    _checkCharmAndLifestyleComplete(onComplete);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
                          : (isDark ? TossDesignSystem.cardBackgroundDark : TossTheme.backgroundSecondary),
                      border: Border.all(
                        color: isSelected
                            ? TossDesignSystem.tossBlue
                            : (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          lifestyle['emoji'] as String,
                          style: TypographyUnified.heading3,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          lifestyle['text'] as String,
                          style: TypographyUnified.labelMedium.copyWith(
                            color: isSelected
                                ? TossDesignSystem.tossBlue
                                : (isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack),
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
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
        '${_getLifestyleText(_lifestyle!)} · ${_charmPoints.length}개',
      );
      onComplete(data);
    }
  }

  /// Section 8: 외모 자신감 & 취미
  Widget _buildConfidenceAndHobbiesInput(Function(dynamic) onComplete) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final hobbyOptions = [
      {'id': 'exercise', 'text': '운동', 'emoji': '🏃'},
      {'id': 'reading', 'text': '독서', 'emoji': '📖'},
      {'id': 'travel', 'text': '여행', 'emoji': '✈️'},
      {'id': 'cooking', 'text': '요리', 'emoji': '👨‍🍳'},
      {'id': 'gaming', 'text': '게임', 'emoji': '🎮'},
      {'id': 'movie', 'text': '영화', 'emoji': '🎬'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 외모 자신감
        Text(
          '외모 자신감',
          style: TypographyUnified.labelLarge.copyWith(
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '1점 (전혀 자신 없음) ~ 10점 (매우 자신 있음)',
          style: TypographyUnified.labelSmall.copyWith(
            color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
          ),
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: _getConfidenceColor(_appearanceConfidence),
            inactiveTrackColor: TossTheme.borderGray200,
            thumbColor: _getConfidenceColor(_appearanceConfidence),
            overlayColor: _getConfidenceColor(_appearanceConfidence).withValues(alpha: 0.2),
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            trackHeight: 6,
          ),
          child: Slider(
            value: _appearanceConfidence,
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (value) {
              setState(() {
                _appearanceConfidence = value;
              });
              _checkConfidenceAndHobbiesComplete(onComplete);
            },
          ),
        ),
        Center(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getConfidenceColor(_appearanceConfidence),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_appearanceConfidence.round()}점',
                  style: TypographyUnified.bodyMedium.copyWith(
                    color: TossDesignSystem.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _getConfidenceText(_appearanceConfidence),
                style: TypographyUnified.labelMedium.copyWith(
                  color: _getConfidenceColor(_appearanceConfidence),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // 취미
        Text(
          '취미',
          style: TypographyUnified.labelLarge.copyWith(
            color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '여러 개 선택 가능',
          style: TypographyUnified.labelMedium.copyWith(
            color: isDark ? TossDesignSystem.textSecondaryDark : TossTheme.textGray600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: hobbyOptions.map((hobby) {
            final hobbyId = hobby['id'] as String;
            final isSelected = _hobbies.contains(hobbyId);
            return InkWell(
              onTap: () {
                setState(() {
                  if (isSelected) {
                    _hobbies.remove(hobbyId);
                  } else {
                    _hobbies.add(hobbyId);
                  }
                });
                TossDesignSystem.hapticLight();
                _checkConfidenceAndHobbiesComplete(onComplete);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
                      : (isDark ? TossDesignSystem.cardBackgroundDark : TossTheme.backgroundSecondary),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected
                        ? TossDesignSystem.tossBlue
                        : (isDark ? TossDesignSystem.borderDark : TossTheme.borderGray200),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      hobby['emoji'] as String,
                      style: TypographyUnified.bodyMedium,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hobby['text'] as String,
                      style: TypographyUnified.bodySmall.copyWith(
                        color: isSelected
                            ? TossDesignSystem.tossBlue
                            : (isDark ? TossDesignSystem.textPrimaryDark : TossTheme.textBlack),
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
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

  Color _getConfidenceColor(double confidence) {
    if (confidence <= 3) {
      return TossTheme.error;
    } else if (confidence <= 5) {
      return TossTheme.warning;
    } else if (confidence <= 7) {
      return TossTheme.success;
    } else {
      return TossTheme.primaryBlue;
    }
  }

  String _getConfidenceText(double confidence) {
    if (confidence <= 3) {
      return '보완이 필요해요';
    } else if (confidence <= 5) {
      return '평범해요';
    } else if (confidence <= 7) {
      return '괜찮은 편이에요';
    } else if (confidence <= 9) {
      return '자신 있어요';
    } else {
      return '매우 자신 있어요';
    }
  }

  // ========================================
  // Helper Methods (텍스트 변환 메서드)
  // ========================================

  String _getGenderText(String gender) {
    return gender == 'male' ? '남성' : '여성';
  }

  String _getRelationshipStatusText(String status) {
    switch (status) {
      case 'single':
        return '싱글';
      case 'dating':
        return '연애중';
      case 'breakup':
        return '이별 후';
      case 'crush':
        return '짝사랑';
      default:
        return status;
    }
  }

  String _getDatingStyleText(String style) {
    switch (style) {
      case 'active':
        return '적극적';
      case 'passive':
        return '소극적';
      case 'emotional':
        return '감성적';
      case 'logical':
        return '이성적';
      case 'independent':
        return '독립적';
      case 'dependent':
        return '의존적';
      case 'serious':
        return '진지한';
      case 'casual':
        return '가벼운';
      default:
        return style;
    }
  }

  String _getLifestyleText(String lifestyle) {
    switch (lifestyle) {
      case 'employee':
        return '직장인';
      case 'student':
        return '학생';
      case 'freelancer':
        return '프리랜서';
      case 'business':
        return '사업가';
      default:
        return lifestyle;
    }
  }
}
