import 'dart:ui'; // ✅ ImageFilter.blur용

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/models/personality_dna_model.dart';
import '../../../../core/widgets/unified_fortune_base_widget.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../core/models/fortune_result.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../domain/models/conditions/personality_dna_fortune_conditions.dart';
import '../../../../core/widgets/accordion_input_section.dart';
import '../../../../core/widgets/unified_button.dart';
// ✅ FloatingBottomButton용
import '../../../../services/ad_service.dart'; // ✅ RewardedAd용
import '../../../../core/utils/logger.dart'; // ✅ 로그용
import '../../../../presentation/providers/auth_provider.dart'; // ✅ 사용자 프로필용

class PersonalityDNAPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialParams;

  const PersonalityDNAPage({
    super.key,
    this.initialParams,
  });

  @override
  ConsumerState<PersonalityDNAPage> createState() => _PersonalityDNAPageState();
}

class _PersonalityDNAPageState extends ConsumerState<PersonalityDNAPage> {
  // 선택된 값들
  String? _selectedMbti;
  String? _selectedBloodType;
  String? _selectedZodiac;
  String? _selectedAnimal;

  PersonalityDNA? _currentDNA;

  // 운세 생성 중 플래그
  bool _isGenerating = false;

  // ✅ Blur 상태 관리
  bool _isBlurred = false;
  List<String> _blurredSections = [];
  String? _unlockedConditionsHash; // ✅ 광고로 블러 해제한 조건의 해시값

  // 아코디언 섹션
  late List<AccordionInputSection> _accordionSections;

  // ✅ 현재 조건의 해시값 생성
  String _getCurrentConditionsHash() {
    return 'mbti:$_selectedMbti|blood:$_selectedBloodType|zodiac:$_selectedZodiac|animal:$_selectedAnimal';
  }

  // MBTI 옵션
  static const List<String> _mbtiOptions = [
    'INTJ', 'INTP', 'ENTJ', 'ENTP',
    'INFJ', 'INFP', 'ENFJ', 'ENFP',
    'ISTJ', 'ISFJ', 'ESTJ', 'ESFJ',
    'ISTP', 'ISFP', 'ESTP', 'ESFP',
  ];

  // 혈액형 옵션
  static const List<String> _bloodTypeOptions = ['A', 'B', 'O', 'AB'];

  // 별자리 옵션
  static const List<String> _zodiacOptions = [
    '양자리', '황소자리', '쌍둥이자리', '게자리',
    '사자자리', '처녀자리', '천칭자리', '전갈자리',
    '사수자리', '염소자리', '물병자리', '물고기자리',
  ];

  // 띠 옵션
  static const List<String> _animalOptions = [
    '쥐띠', '소띠', '호랑이띠', '토끼띠',
    '용띠', '뱀띠', '말띠', '양띠',
    '원숭이띠', '닭띠', '개띠', '돼지띠',
  ];

  @override
  void initState() {
    super.initState();

    // ✅ 프로필 먼저 확인 (동기 방식)
    final userProfileAsync = ref.read(userProfileProvider);
    final userProfile = userProfileAsync.value;

    // 프로필 정보로 초기값 설정
    if (userProfile != null) {
      if (userProfile.mbtiType != null && _mbtiOptions.contains(userProfile.mbtiType)) {
        _selectedMbti = userProfile.mbtiType;
      }
      if (userProfile.bloodType != null && _bloodTypeOptions.contains(userProfile.bloodType)) {
        _selectedBloodType = userProfile.bloodType;
      }
      if (userProfile.zodiacSign != null && _zodiacOptions.contains(userProfile.zodiacSign)) {
        _selectedZodiac = userProfile.zodiacSign;
      }
      if (userProfile.chineseZodiac != null) {
        final animalWithSuffix = userProfile.chineseZodiac!.endsWith('띠')
            ? userProfile.chineseZodiac!
            : '${userProfile.chineseZodiac}띠';
        if (_animalOptions.contains(animalWithSuffix)) {
          _selectedAnimal = animalWithSuffix;
        }
      }
    }

    // 아코디언 섹션 초기화 (이미 선택된 값들로)
    _initializeAccordionSections();
  }


  void _initializeAccordionSections() {
    _accordionSections = [
      AccordionInputSection(
        id: 'mbti',
        title: 'MBTI',
        icon: Icons.psychology_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildMbtiInput(onComplete),
        // ✅ 프로필에서 로드된 값이 있으면 완료 상태로 시작
        isCompleted: _selectedMbti != null,
        value: _selectedMbti,
        displayValue: _selectedMbti != null ? 'MBTI: $_selectedMbti' : null,
      ),
      AccordionInputSection(
        id: 'blood_type',
        title: '혈액형',
        icon: Icons.bloodtype_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildBloodTypeInput(onComplete),
        isCompleted: _selectedBloodType != null,
        value: _selectedBloodType,
        displayValue: _selectedBloodType != null ? '혈액형: $_selectedBloodType형' : null,
      ),
      AccordionInputSection(
        id: 'zodiac',
        title: '별자리',
        icon: Icons.star_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildZodiacInput(onComplete),
        isCompleted: _selectedZodiac != null,
        value: _selectedZodiac,
        displayValue: _selectedZodiac != null ? '별자리: $_selectedZodiac' : null,
      ),
      AccordionInputSection(
        id: 'animal',
        title: '띠',
        icon: Icons.pets_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildAnimalInput(onComplete),
        isCompleted: _selectedAnimal != null,
        value: _selectedAnimal,
        displayValue: _selectedAnimal != null ? '띠: $_selectedAnimal' : null,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return UnifiedFortuneBaseWidget(
      fortuneType: 'personality-dna',
      title: '성격 DNA',
      description: 'MBTI, 혈액형, 별자리, 띠를 조합한 특별한 성격 분석',
      dataSource: FortuneDataSource.api,
      inputBuilder: (context, onComplete) => _buildInputForm(() {
        debugPrint('🔵 [버튼클릭] _isGenerating = true 설정 시작');
        // 1️⃣ 로딩 애니메이션 시작
        setState(() {
          _isGenerating = true;
          debugPrint('🔵 [setState] _isGenerating = $_isGenerating');
        });

        debugPrint('🔵 [버튼클릭] onComplete() 호출 (0.1초 후)');
        // 2️⃣ 0.1초 후 운세 생성 시작
        Future.delayed(const Duration(milliseconds: 100), () {
          debugPrint('🔵 [딜레이완료] onComplete() 실행');
          onComplete();
        });

        // 3️⃣ 3초 후 로딩 해제
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            debugPrint('🔵 [3초후] _isGenerating = false 설정');
            setState(() => _isGenerating = false);
          }
        });
      }),
      conditionsBuilder: () async {
        return PersonalityDnaFortuneConditions(
          mbti: _selectedMbti,
          bloodType: _selectedBloodType,
          zodiac: _selectedZodiac,
          animal: _selectedAnimal,
          date: DateTime.now(),
        );
      },
      resultBuilder: (context, result) => _buildResultView(result),
    );
  }

  Widget _buildInputForm(VoidCallback onComplete) {
    debugPrint('🟢 [build] _buildInputForm - _isGenerating: $_isGenerating, _canGenerate: ${_canGenerate()}');

    return Stack(
      children: [
        Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: _buildTitleSection(),
            ),
            Expanded(
              child: AccordionInputForm(
                sections: _accordionSections,
                onAllCompleted: null,
                completionButtonText: '🧬 나만의 성격 DNA 발견하기',
              ),
            ),
          ],
        ),
        if (_canGenerate())
          Builder(
            builder: (context) {
              debugPrint('🟡 [TossButton] showProgress: $_isGenerating, isLoading: $_isGenerating, isEnabled: ${_canGenerate() && !_isGenerating}');
              if (!_canGenerate()) return const SizedBox.shrink();
              return UnifiedButton.floating(
                text: '🧬 나만의 성격 DNA 발견하기',
                onPressed: _canGenerate() && !_isGenerating ? onComplete : null,
                isEnabled: _canGenerate() && !_isGenerating,
                showProgress: _isGenerating,
                isLoading: _isGenerating, // ✅ 점 3개 애니메이션 표시!
              );
            },
          ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '당신만의 성격 DNA를\n발견해보세요',
          style: TypographyUnified.heading1.copyWith(
            fontWeight: FontWeight.w700,
            color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.white : TossDesignSystem.gray900,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'MBTI, 혈액형, 별자리, 띠를 조합하여\n특별한 성격 분석 결과를 확인하세요',
          style: TypographyUnified.bodySmall.copyWith(
            color: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Widget _buildMbtiInput(Function(dynamic) onComplete) {
    return _buildGridSelection(
      options: _mbtiOptions,
      columns: 4,
      selectedValue: _selectedMbti, // ✅ 초기값 전달
      onSelect: (value) {
        setState(() {
          _selectedMbti = value;
          // ✅ 아코디언 섹션 업데이트
          _accordionSections[0] = _accordionSections[0].copyWith(
            isCompleted: true,
            value: value,
            displayValue: 'MBTI: $value',
          );
        });
        onComplete(value);
      },
    );
  }

  Widget _buildBloodTypeInput(Function(dynamic) onComplete) {
    return _buildGridSelection(
      options: _bloodTypeOptions,
      columns: 4,
      selectedValue: _selectedBloodType, // ✅ 초기값 전달
      onSelect: (value) {
        setState(() {
          _selectedBloodType = value;
          // ✅ 아코디언 섹션 업데이트
          _accordionSections[1] = _accordionSections[1].copyWith(
            isCompleted: true,
            value: value,
            displayValue: '혈액형: $value',
          );
        });
        onComplete(value);
      },
    );
  }

  Widget _buildZodiacInput(Function(dynamic) onComplete) {
    return _buildGridSelection(
      options: _zodiacOptions,
      columns: 3,
      selectedValue: _selectedZodiac, // ✅ 초기값 전달
      onSelect: (value) {
        setState(() {
          _selectedZodiac = value;
          // ✅ 아코디언 섹션 업데이트
          _accordionSections[2] = _accordionSections[2].copyWith(
            isCompleted: true,
            value: value,
            displayValue: '별자리: $value',
          );
        });
        onComplete(value);
      },
    );
  }

  Widget _buildAnimalInput(Function(dynamic) onComplete) {
    return _buildGridSelection(
      options: _animalOptions,
      columns: 3,
      selectedValue: _selectedAnimal, // ✅ 초기값 전달
      onSelect: (value) {
        setState(() {
          _selectedAnimal = value;
          // ✅ 아코디언 섹션 업데이트
          _accordionSections[3] = _accordionSections[3].copyWith(
            isCompleted: true,
            value: value,
            displayValue: '띠: $value',
          );
        });
        onComplete(value);
      },
    );
  }

  Widget _buildGridSelection({
    required List<String> options,
    required int columns,
    required Function(String) onSelect,
    String? selectedValue, // ✅ 선택된 값 추가
  }) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      childAspectRatio: 2.2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: options.map((option) {
        final isSelected = option == selectedValue; // ✅ 선택 여부 확인
        return _buildOptionChip(option, onSelect, isSelected);
      }).toList(),
    );
  }

  Widget _buildOptionChip(String option, Function(String) onSelect, bool isSelected) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onSelect(option);
      },
      child: Container(
        decoration: BoxDecoration(
          // ✅ 선택된 경우 파란색 배경
          color: isSelected
              ? (isDark ? TossDesignSystem.tossBlueDark : TossDesignSystem.tossBlue)
              : (isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray50),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            // ✅ 선택된 경우 파란색 테두리
            color: isSelected
                ? (isDark ? TossDesignSystem.tossBlueDark : TossDesignSystem.tossBlue)
                : (isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray200),
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            option,
            style: TypographyUnified.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              // ✅ 선택된 경우 흰색 텍스트
              color: isSelected
                  ? TossDesignSystem.white
                  : (isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight),
            ),
          ),
        ),
      ).animate()
        .scale(
          duration: 100.ms,
          begin: const Offset(1, 1),
          end: const Offset(0.95, 0.95),
        )
        .then()
        .scale(
          duration: 100.ms,
          begin: const Offset(0.95, 0.95),
          end: const Offset(1, 1),
        ),
    );
  }

  bool _canGenerate() {
    return _selectedMbti != null &&
        _selectedBloodType != null &&
        _selectedZodiac != null &&
        _selectedAnimal != null;
  }

  bool get canGenerateFortune => _canGenerate();

  Widget _buildResultView(FortuneResult result) {
    // FortuneResult에서 PersonalityDNA 정보 추출
    final data = result.data;
    final dnaCode = data['dnaCode'] as String? ?? PersonalityDNA.generateDNACode(
      mbti: _selectedMbti!,
      bloodType: _selectedBloodType!,
      zodiac: _selectedZodiac!,
      zodiacAnimal: _selectedAnimal!,
    );

    // Edge Function 응답에서 상세 데이터 파싱
    final loveStyleData = data['loveStyle'] as Map<String, dynamic>?;
    final workStyleData = data['workStyle'] as Map<String, dynamic>?;
    final dailyMatchingData = data['dailyMatching'] as Map<String, dynamic>?;
    final compatibilityData = data['compatibility'] as Map<String, dynamic>?;
    final funStatsData = data['funStats'] as Map<String, dynamic>?;
    final dailyFortuneData = data['dailyFortune'] as Map<String, dynamic>?;

    // PersonalityDNA 객체 생성
    final dnaObject = PersonalityDNA(
      mbti: _selectedMbti!,
      bloodType: _selectedBloodType!,
      zodiac: _selectedZodiac!,
      zodiacAnimal: _selectedAnimal!,
      dnaCode: dnaCode,
      title: data['title'] as String? ?? '성격 DNA',
      emoji: data['emoji'] as String? ?? '🧬',
      description: '',
      traits: [],
      gradientColors: [],
      scores: {'socialRanking': (data['socialRanking'] as num?)?.toInt() ?? 50},
      todaysFortune: data['todayAdvice'] as String? ?? '',
      todayHighlight: data['todayHighlight'] as String?,
      popularityRank: (data['socialRanking'] as num?)?.toInt() ?? 50,
      // ✅ Edge Function 데이터를 PersonalityDNA 모델로 변환
      loveStyle: loveStyleData != null ? LoveStyle(
        title: loveStyleData['title'] as String? ?? '',
        description: loveStyleData['description'] as String? ?? '',
        whenDating: loveStyleData['when_dating'] as String? ?? '',
        afterBreakup: loveStyleData['after_breakup'] as String? ?? '',
      ) : null,
      workStyle: workStyleData != null ? WorkStyle(
        title: workStyleData['title'] as String? ?? '',
        asBoss: workStyleData['as_boss'] as String? ?? '',
        atCompanyDinner: workStyleData['at_company_dinner'] as String? ?? '',
        workHabit: workStyleData['work_habit'] as String? ?? '',
      ) : null,
      dailyMatching: dailyMatchingData != null ? DailyMatching(
        cafeMenu: dailyMatchingData['cafe_menu'] as String? ?? '',
        netflixGenre: dailyMatchingData['netflix_genre'] as String? ?? '',
        weekendActivity: dailyMatchingData['weekend_activity'] as String? ?? '',
      ) : null,
      compatibility: compatibilityData != null ? Compatibility(
        friend: CompatibilityType(
          mbti: (compatibilityData['friend'] as Map<String, dynamic>?)?['mbti'] as String? ?? '',
          description: (compatibilityData['friend'] as Map<String, dynamic>?)?['description'] as String? ?? '',
        ),
        lover: CompatibilityType(
          mbti: (compatibilityData['lover'] as Map<String, dynamic>?)?['mbti'] as String? ?? '',
          description: (compatibilityData['lover'] as Map<String, dynamic>?)?['description'] as String? ?? '',
        ),
        colleague: CompatibilityType(
          mbti: (compatibilityData['colleague'] as Map<String, dynamic>?)?['mbti'] as String? ?? '',
          description: (compatibilityData['colleague'] as Map<String, dynamic>?)?['description'] as String? ?? '',
        ),
      ) : null,
      celebrity: funStatsData != null ? Celebrity(
        name: funStatsData['celebrity_match'] as String? ?? '',
        reason: '$_selectedMbti 유형의 대표적인 인물',
      ) : null,
      funnyFact: funStatsData != null
        ? '전국 상위 ${funStatsData['rarity_rank']}! 한국 인구의 ${funStatsData['percentage_in_korea']}를 차지합니다.'
        : null,
      dailyFortune: dailyFortuneData != null ? DailyFortune.fromJson(dailyFortuneData) : null,
    );

    // ✅ 즉시 동기화 (postFrameCallback 제거)
    _currentDNA = dnaObject;

    // ✅ 현재 조건의 해시값
    final currentHash = _getCurrentConditionsHash();

    // ✅ 광고로 블러 해제한 조건과 다른 경우에만 result의 블러 상태 반영
    if (_unlockedConditionsHash != currentHash) {
      _isBlurred = result.isBlurred;
      _blurredSections = List<String>.from(result.blurredSections);
    }

    debugPrint('🔒 [성격DNA] isBlurred: $_isBlurred, blurredSections: $_blurredSections, currentHash: $currentHash, unlockedHash: $_unlockedConditionsHash');

    return buildFortuneResult();
  }

  Widget buildFortuneResult() {
    if (_currentDNA == null) return const SizedBox.shrink();

    debugPrint('🎨 [buildResult] _isBlurred: $_isBlurred, FloatingButton 표시: ${_isBlurred ? "YES" : "NO"}');

    // ✅ Phase 8: Stack으로 변경하여 FloatingBottomButton 추가
    return Stack(
      children: [
        // 기존 콘텐츠 (SingleChildScrollView)
        SingleChildScrollView(
          child: Column(
            children: [
          _buildDNAHeader(),
          const SizedBox(height: 8),
          // ✅ 오늘의 운세 섹션 (최상단)
          if (_currentDNA!.dailyFortune != null) ...[
            _buildDailyFortuneSection(),
            const SizedBox(height: 8),
          ],
          if (_currentDNA!.todayHighlight != null) ...[
            _buildTodayHighlight(),
            const SizedBox(height: 8),
          ],
          if (_currentDNA!.loveStyle != null) ...[
            // ✅ Premium 섹션 1: 연애 스타일
            _buildBlurWrapper(
              sectionKey: 'loveStyle',
              child: _buildLoveStyleSection(),
            ),
            const SizedBox(height: 8),
          ],
          if (_currentDNA!.workStyle != null) ...[
            // ✅ Premium 섹션 2: 직장 스타일
            _buildBlurWrapper(
              sectionKey: 'workStyle',
              child: _buildWorkStyleSection(),
            ),
            const SizedBox(height: 8),
          ],
          if (_currentDNA!.dailyMatching != null) ...[
            // ✅ Premium 섹션 3: 데일리 매칭
            _buildBlurWrapper(
              sectionKey: 'dailyMatching',
              child: _buildDailyMatchingSection(),
            ),
            const SizedBox(height: 8),
          ],
          if (_currentDNA!.compatibility != null) ...[
            // ✅ Premium 섹션 4: 궁합
            _buildBlurWrapper(
              sectionKey: 'compatibility',
              child: _buildCompatibilitySection(),
            ),
            const SizedBox(height: 8),
          ],
          if (_currentDNA!.celebrity != null) ...[
            // ✅ Premium 섹션 5-1: 닮은 유명인
            _buildBlurWrapper(
              sectionKey: 'celebrity',
              child: _buildCelebritySection(),
            ),
            const SizedBox(height: 8),
          ],
          if (_currentDNA!.funnyFact != null) ...[
            // ✅ Premium 섹션 5-2: 재미있는 사실
            _buildBlurWrapper(
              sectionKey: 'funnyFact',
              child: _buildFunnyFactSection(),
            ),
            const SizedBox(height: 8),
          ],
              const SizedBox(height: 32),
            ],
          ),
        ),

        // ✅ FloatingBottomButton (블러 상태일 때만 표시)
        if (_isBlurred)
          UnifiedButton.floating(
            text: '광고 보고 전체 내용 확인하기',
            onPressed: _showAdAndUnblur,
            isEnabled: true,
            bottom: 20, // ✅ 하단에서 20px 위에 배치 (Safe Area 고려)
          ),
      ],
    );
  }

  Widget _buildTossSection({
    required String title,
    required Widget child,
    IconData? icon,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(
                  icon,
                  color: TossDesignSystem.tossBlue,
                  size: 20,
                ),
                SizedBox(width: 8),
              ],
              Text(
                title,
                style: TypographyUnified.heading4.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? TossDesignSystem.textPrimaryDark : const Color(0xFF191F28),
                  height: 1.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildDNAHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          if (_currentDNA!.popularityRank != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _currentDNA!.popularityColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.trending_up, color: TossDesignSystem.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    _currentDNA!.popularityText,
                    style: const TextStyle(
                      color: TossDesignSystem.white,
                      fontWeight: FontWeight.w600,
                      
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Text(_currentDNA!.emoji, style: TypographyUnified.displayLarge),
          const SizedBox(height: 16),
          Text(
            _currentDNA!.title,
            style: TypographyUnified.heading3.copyWith(
              color: isDark ? TossDesignSystem.textPrimaryDark : const Color(0xFF191F28),
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            _currentDNA!.description,
            style: TextStyle(
              color: isDark ? TossDesignSystem.textSecondaryDark : const Color(0xFF8B95A1),
              
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? TossDesignSystem.grayDark200 : const Color(0xFFF7F8FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _currentDNA!.dnaCode,
              style: TextStyle(
                color: isDark ? TossDesignSystem.textPrimaryDark : const Color(0xFF191F28),
                
                fontWeight: FontWeight.w600,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyFortuneSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dailyFortune = _currentDNA!.dailyFortune!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            isDark ? TossDesignSystem.tossBlueDark : TossDesignSystem.tossBlue,
            isDark ? TossDesignSystem.tossBlueDark.withValues(alpha: 0.7) : TossDesignSystem.tossBlue.withValues(alpha: 0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.wb_sunny_outlined,
                color: TossDesignSystem.white,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                '오늘의 운세',
                style: TypographyUnified.heading3.copyWith(
                  fontWeight: FontWeight.w700,
                  color: TossDesignSystem.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 행운 색상
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _parseColor(dailyFortune.luckyColor),
                  shape: BoxShape.circle,
                  border: Border.all(color: TossDesignSystem.white, width: 2),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '행운의 색',
                      style: TypographyUnified.labelMedium.copyWith(
                        color: TossDesignSystem.white.withValues(alpha: 0.8),
                      ),
                    ),
                    Text(
                      dailyFortune.luckyColor,
                      style: TypographyUnified.buttonMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: TossDesignSystem.white,
                      ),
                    ),
                  ],
                ),
              ),
              // 행운 숫자
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: TossDesignSystem.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Text(
                      '행운 번호',
                      style: TypographyUnified.labelMedium.copyWith(
                        color: TossDesignSystem.white.withValues(alpha: 0.8),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${dailyFortune.luckyNumber}',
                      style: TypographyUnified.heading3.copyWith(
                        fontWeight: FontWeight.w700,
                        color: TossDesignSystem.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 에너지 레벨 프로그레스 바
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '오늘의 에너지',
                    style: TypographyUnified.labelMedium.copyWith(
                      color: TossDesignSystem.white.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    '${dailyFortune.energyLevel}%',
                    style: TypographyUnified.heading4.copyWith(
                      fontWeight: FontWeight.w700,
                      color: TossDesignSystem.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: dailyFortune.energyLevel / 100,
                  minHeight: 8,
                  backgroundColor: TossDesignSystem.white.withValues(alpha: 0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(TossDesignSystem.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 추천 활동
          _buildFortuneItem(
            icon: Icons.lightbulb_outline,
            title: '추천 활동',
            content: dailyFortune.recommendedActivity,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // 주의사항
          _buildFortuneItem(
            icon: Icons.warning_amber_outlined,
            title: '주의사항',
            content: dailyFortune.caution,
            isDark: isDark,
          ),
          const SizedBox(height: 12),

          // 오늘의 베스트 매치
          _buildFortuneItem(
            icon: Icons.favorite_outline,
            title: '오늘의 베스트 매치',
            content: dailyFortune.bestMatchToday,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildFortuneItem({
    required IconData icon,
    required String title,
    required String content,
    required bool isDark,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: TossDesignSystem.white,
          size: 20,
        ),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TypographyUnified.labelMedium.copyWith(
                  color: TossDesignSystem.white.withValues(alpha: 0.8),
                ),
              ),
              SizedBox(height: 2),
              Text(
                content,
                style: TypographyUnified.buttonMedium.copyWith(
                  fontWeight: FontWeight.w400,
                  color: TossDesignSystem.white,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _parseColor(String colorName) {
    // 색상 이름을 Color로 변환하는 간단한 매핑
    final colorMap = {
      '로즈 골드': Color(0xFFB76E79),
      '코랄 핑크': Color(0xFFFF6F61),
      '민트 그린': Color(0xFF98D8C8),
      '라벤더': Color(0xFFE6E6FA),
      '스카이 블루': Color(0xFF87CEEB),
      '페일 옐로우': Color(0xFFFFFACD),
      '피치': Color(0xFFFFDAB9),
      '라일락': Color(0xFFC8A2C8),
      '베이비 블루': Color(0xFF89CFF0),
      '아이보리': Color(0xFFFFFFF0),
      '세이지 그린': Color(0xFF9DC183),
      '샴페인': Color(0xFFF7E7CE),
    };
    return colorMap[colorName] ?? TossDesignSystem.white;
  }

  Widget _buildTodayHighlight() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _buildTossSection(
      title: '오늘의 하이라이트',
      icon: Icons.star,
      child: Text(
        _currentDNA!.todayHighlight!,
        style: TypographyUnified.buttonMedium.copyWith(
          fontWeight: FontWeight.w400,
          color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildLoveStyleSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final loveStyle = _currentDNA!.loveStyle!;
    return _buildTossSection(
      title: '연애 스타일',
      icon: Icons.favorite,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            loveStyle.title,
            style: TypographyUnified.heading4.copyWith(
              fontWeight: FontWeight.w600,
              color: TossDesignSystem.tossBlue,
              height: 1.3,
            ),
          ),
          SizedBox(height: 8),
          Text(
            loveStyle.description,
            style: TypographyUnified.buttonMedium.copyWith(
              fontWeight: FontWeight.w400,
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          _buildLoveStyleDetailCard('연애할 때', loveStyle.whenDating),
          const SizedBox(height: 8),
          _buildLoveStyleDetailCard('이별 후', loveStyle.afterBreakup),
        ],
      ),
    );
  }

  Widget _buildLoveStyleDetailCard(String title, String content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.grayDark200 : const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TypographyUnified.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? TossDesignSystem.textSecondaryDark : const Color(0xFF8B95A1),
            ),
          ),
          SizedBox(height: 4),
          Text(
            content,
            style: TypographyUnified.buttonMedium.copyWith(
              fontWeight: FontWeight.w400,
              color: isDark ? TossDesignSystem.textPrimaryDark : const Color(0xFF191F28),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkStyleSection() {
    final workStyle = _currentDNA!.workStyle!;
    return _buildTossSection(
      title: '업무 스타일',
      icon: Icons.work,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            workStyle.title,
            style: TypographyUnified.heading4.copyWith(
              fontWeight: FontWeight.w600,
              color: TossDesignSystem.tossBlue,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 16),
          _buildWorkStyleDetailCard('상사가 된다면', workStyle.asBoss),
          const SizedBox(height: 8),
          _buildWorkStyleDetailCard('회식에서', workStyle.atCompanyDinner),
          const SizedBox(height: 8),
          _buildWorkStyleDetailCard('업무 습관', workStyle.workHabit),
        ],
      ),
    );
  }

  Widget _buildWorkStyleDetailCard(String title, String content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.grayDark200 : const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TypographyUnified.bodySmall.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? TossDesignSystem.textSecondaryDark : const Color(0xFF8B95A1),
            ),
          ),
          SizedBox(height: 4),
          Text(
            content,
            style: TypographyUnified.buttonMedium.copyWith(
              fontWeight: FontWeight.w400,
              color: isDark ? TossDesignSystem.textPrimaryDark : const Color(0xFF191F28),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyMatchingSection() {
    final dailyMatching = _currentDNA!.dailyMatching!;
    return _buildTossSection(
      title: '일상 매칭',
      icon: Icons.coffee,
      child: Column(
        children: [
          _buildDailyMatchingCard('카페 메뉴', dailyMatching.cafeMenu),
          const SizedBox(height: 8),
          _buildDailyMatchingCard('넷플릭스 장르', dailyMatching.netflixGenre),
          const SizedBox(height: 8),
          _buildDailyMatchingCard('주말 활동', dailyMatching.weekendActivity),
        ],
      ),
    );
  }

  Widget _buildDailyMatchingCard(String title, String content) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.grayDark200 : const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TypographyUnified.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark ? TossDesignSystem.textSecondaryDark : const Color(0xFF8B95A1),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  content,
                  style: TypographyUnified.buttonMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: TossDesignSystem.tossBlue,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompatibilitySection() {
    final compatibility = _currentDNA!.compatibility!;
    return _buildTossSection(
      title: '궁합',
      icon: Icons.people,
      child: Column(
        children: [
          _buildCompatibilityCard('친구', compatibility.friend.mbti, compatibility.friend.description),
          const SizedBox(height: 8),
          _buildCompatibilityCard('연인', compatibility.lover.mbti, compatibility.lover.description),
          const SizedBox(height: 8),
          _buildCompatibilityCard('동료', compatibility.colleague.mbti, compatibility.colleague.description),
        ],
      ),
    );
  }

  Widget _buildCompatibilityCard(String type, String mbti, String description) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.grayDark200 : const Color(0xFFF7F8FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                type,
                style: TypographyUnified.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? TossDesignSystem.textSecondaryDark : const Color(0xFF8B95A1),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: TossDesignSystem.tossBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  mbti,
                  style: TypographyUnified.labelMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: TossDesignSystem.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            description,
            style: TypographyUnified.buttonMedium.copyWith(
              fontWeight: FontWeight.w400,
              color: isDark ? TossDesignSystem.textPrimaryDark : const Color(0xFF191F28),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCelebritySection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final celebrity = _currentDNA!.celebrity!;
    return _buildTossSection(
      title: '닮은 유명인',
      icon: Icons.star_border,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? TossDesignSystem.grayDark200 : const Color(0xFFF7F8FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              celebrity.name,
              style: TypographyUnified.heading4.copyWith(
                fontWeight: FontWeight.w600,
                color: TossDesignSystem.tossBlue,
                height: 1.3,
              ),
            ),
            SizedBox(height: 8),
            Text(
              celebrity.reason,
              style: TypographyUnified.buttonMedium.copyWith(
                fontWeight: FontWeight.w400,
                color: isDark ? TossDesignSystem.textPrimaryDark : const Color(0xFF191F28),
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFunnyFactSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return _buildTossSection(
      title: '재미있는 사실',
      icon: Icons.lightbulb_outline,
      child: Text(
        _currentDNA!.funnyFact!,
        style: TypographyUnified.buttonMedium.copyWith(
          fontWeight: FontWeight.w400,
          color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
          height: 1.5,
        ),
      ),
    );
  }

  // ✅ Phase 5: RewardedAd 패턴 - 광고 시청 후 블러 해제
  Future<void> _showAdAndUnblur() async {
    debugPrint('[성격DNA] 광고 시청 후 블러 해제 시작');

    try {
      final adService = AdService.instance;

      // 광고가 준비 안됐으면 로드
      if (!adService.isRewardedAdReady) {
        debugPrint('[성격DNA] ⏳ RewardedAd 로드 중...');
        await adService.loadRewardedAd();

        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
        }

        if (!adService.isRewardedAdReady) {
          debugPrint('[성격DNA] ❌ RewardedAd 로드 타임아웃');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('광고를 불러올 수 없습니다. 잠시 후 다시 시도해주세요.'),
                backgroundColor: TossDesignSystem.errorRed,
              ),
            );
          }
          return;
        }
      }

      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) {
          debugPrint('[성격DNA] ✅ 광고 시청 완료, 블러 해제');
          if (mounted) {
            setState(() {
              _isBlurred = false;
              _blurredSections = [];
              _unlockedConditionsHash = _getCurrentConditionsHash(); // ✅ 현재 조건의 해시 저장
              debugPrint('[성격DNA] 블러 해제된 조건: $_unlockedConditionsHash');
            });
          }
        },
      );
    } catch (e, stackTrace) {
      Logger.error('[성격DNA] 광고 표시 실패', e, stackTrace);

      // UX 개선: 에러 발생해도 블러 해제
      if (mounted) {
        setState(() {
          _isBlurred = false;
          _blurredSections = [];
          _unlockedConditionsHash = _getCurrentConditionsHash(); // ✅ 현재 조건의 해시 저장
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('광고 표시 중 오류가 발생했지만, 콘텐츠를 확인하실 수 있습니다.'),
            backgroundColor: TossDesignSystem.warningOrange,
          ),
        );
      }
    }
  }

  // ✅ Phase 6: Blur wrapper helper - ImageFilter.blur 적용
  Widget _buildBlurWrapper({
    required Widget child,
    required String sectionKey,
  }) {
    debugPrint('🔐 [BlurWrapper] sectionKey: $sectionKey, _isBlurred: $_isBlurred, contains: ${_blurredSections.contains(sectionKey)}');

    if (!_isBlurred || !_blurredSections.contains(sectionKey)) {
      debugPrint('   ✅ 블러 안함 - 일반 표시');
      return child;
    }

    debugPrint('   🔒 블러 적용');

    // ✅ Stack의 크기를 child 크기로 제한하기 위해 LayoutBuilder 사용
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            // 1. 블러된 child
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: child,
              ),
            ),
            // 2. 어두운 오버레이 (child와 동일한 위젯을 사용하여 크기 맞춤)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0, // child를 투명하게 만들어 크기만 차지
                    child: child,
                  ),
                ),
              ),
            ),
            // 3. 자물쇠 아이콘 (child 위에 배치, 중앙 정렬을 위해 child 복제)
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Icon(
                    Icons.lock_outline,
                    size: 48,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
