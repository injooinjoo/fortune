import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune/core/models/personality_dna_model.dart';
import 'package:fortune/core/widgets/unified_fortune_base_widget.dart';
import 'package:fortune/core/services/unified_fortune_service.dart';
import 'package:fortune/core/models/fortune_result.dart';
import 'package:fortune/core/theme/font_config.dart';
import 'package:fortune/features/fortune/domain/models/conditions/personality_dna_fortune_conditions.dart';
import 'package:fortune/core/widgets/accordion_input_section.dart';
import 'package:fortune/core/widgets/unified_button.dart';
import 'package:fortune/services/ad_service.dart';
import 'package:fortune/core/utils/subscription_snackbar.dart';
import 'package:fortune/presentation/providers/token_provider.dart';
import 'package:fortune/core/utils/logger.dart';
import 'package:fortune/presentation/providers/auth_provider.dart';
import 'package:fortune/core/design_system/design_system.dart';
import 'package:fortune/core/theme/typography_unified.dart';
import 'package:fortune/core/utils/fortune_completion_helper.dart';
import 'widgets/dna_header_widget.dart';
import 'widgets/daily_fortune_section.dart';
import 'widgets/love_style_section.dart';
import 'widgets/work_style_section.dart';
import 'widgets/daily_matching_section.dart';
import 'widgets/compatibility_section.dart';
import 'widgets/celebrity_section.dart';
import 'widgets/fortune_section_widget.dart';
import 'widgets/input_widgets.dart';
import 'package:fortune/core/widgets/unified_blur_wrapper.dart';
import 'package:fortune/core/design_system/components/traditional/hanji_card.dart';
import 'package:fortune/core/design_system/tokens/ds_fortune_colors.dart';
import 'package:fortune/presentation/providers/subscription_provider.dart';
import 'package:fortune/core/services/fortune_haptic_service.dart';

class PersonalityDNAPageImpl extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialParams;

  const PersonalityDNAPageImpl({
    super.key,
    this.initialParams,
  });

  @override
  ConsumerState<PersonalityDNAPageImpl> createState() => _PersonalityDNAPageImplState();
}

class _PersonalityDNAPageImplState extends ConsumerState<PersonalityDNAPageImpl> {
  // 선택된 값들
  String? _selectedMbti;
  String? _selectedBloodType;
  String? _selectedZodiac;
  String? _selectedAnimal;

  PersonalityDNA? _currentDNA;

  // 운세 생성 중 플래그
  bool _isGenerating = false;

  // Blur 상태 관리
  bool _isBlurred = false;
  List<String> _blurredSections = [];
  String? _unlockedConditionsHash;

  // 아코디언 섹션
  late List<AccordionInputSection> _accordionSections;

  // 현재 조건의 해시값 생성
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

    // 프로필 먼저 확인 (동기 방식)
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

    _initializeAccordionSections();
  }

  void _initializeAccordionSections() {
    _accordionSections = [
      AccordionInputSection(
        id: 'mbti',
        title: 'MBTI',
        icon: Icons.psychology_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildMbtiInput(onComplete),
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
      title: '나의 성격 탐구',
      description: 'MBTI × 혈액형 × 별자리 × 띠 조합 분석',
      dataSource: FortuneDataSource.api,
      inputBuilder: (context, onComplete) => _buildInputForm(() {
        debugPrint('🔵 [버튼클릭] _isGenerating = true 설정 시작');
        setState(() {
          _isGenerating = true;
          debugPrint('🔵 [setState] _isGenerating = $_isGenerating');
        });

        debugPrint('🔵 [버튼클릭] onComplete() 호출 (0.1초 후)');
        Future.delayed(const Duration(milliseconds: 100), () {
          debugPrint('🔵 [딜레이완료] onComplete() 실행');
          onComplete();
        });

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

  /// 인기 순위 클릭 시 랭킹 상세 바텀시트 표시
  void _showRankingBottomSheet() {
    if (_currentDNA == null) return;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final rank = _currentDNA!.popularityRank ?? 0;
    const totalCombinations = 768; // 16 MBTI × 4 혈액형 × 12 띠
    final percentile = ((totalCombinations - rank) / totalCombinations * 100).clamp(0, 100).toInt();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 드래그 핸들
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),

            // 타이틀
            Text(
              '🏆 나의 성격 DNA 랭킹',
              style: TextStyle(
                fontFamily: FontConfig.primary,
                fontSize: FontConfig.heading4,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // 순위 표시
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    _currentDNA!.popularityColor,
                    _currentDNA!.popularityColor.withValues(alpha: 0.7),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: _currentDNA!.popularityColor.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    rank <= 10 ? '🥇' : rank <= 50 ? '🥈' : '🎖️',
                    style: const TextStyle(fontSize: FontConfig.emojiSmall),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$rank위',
                    style: const TextStyle(
                      fontFamily: FontConfig.primary,
                      fontSize: FontConfig.scoreMedium,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '전체 $totalCombinations개 조합 중',
                    style: TextStyle(
                      fontSize: FontConfig.labelMedium,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 백분위 설명
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '인기도 상위',
                        style: TextStyle(
                          fontSize: FontConfig.labelMedium,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      Text(
                        '$percentile%',
                        style: TextStyle(
                          fontSize: FontConfig.bodyMedium,
                          fontWeight: FontWeight.w700,
                          color: _currentDNA!.popularityColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // 프로그레스 바
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: percentile / 100,
                      backgroundColor: isDark ? Colors.grey[800] : Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation(_currentDNA!.popularityColor),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // DNA 코드
            Text(
              _currentDNA!.dnaCode,
              style: TextStyle(
                fontFamily: FontConfig.primary,
                fontSize: FontConfig.labelMedium,
                color: isDark ? Colors.grey[500] : Colors.grey[600],
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              rank <= 10
                  ? '✨ 희귀한 성격 조합이에요!'
                  : rank <= 50
                      ? '💫 특별한 성격 조합이네요!'
                      : '🌟 독특한 나만의 성격이에요!',
              style: TextStyle(
                fontSize: FontConfig.labelSmall,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),

            SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInputForm(VoidCallback onComplete) {
    debugPrint('🟢 [build] _buildInputForm - _isGenerating: $_isGenerating, _canGenerate: ${_canGenerate()}');

    return Stack(
      children: [
        Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: TitleSection(),
            ),
            Expanded(
              child: AccordionInputForm(
                sections: _accordionSections,
                onAllCompleted: null,
                completionButtonText: '🧬 나의 성격 탐구하기',
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
                text: '🧬 나의 성격 탐구하기',
                onPressed: _canGenerate() && !_isGenerating ? onComplete : null,
                isEnabled: _canGenerate() && !_isGenerating,
                showProgress: _isGenerating,
                isLoading: _isGenerating,
              );
            },
          ),
      ],
    );
  }

  Widget _buildMbtiInput(Function(dynamic) onComplete) {
    return GridSelectionWidget(
      options: _mbtiOptions,
      columns: 4,
      selectedValue: _selectedMbti,
      onSelect: (value) {
        setState(() {
          _selectedMbti = value;
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
    return GridSelectionWidget(
      options: _bloodTypeOptions,
      columns: 4,
      selectedValue: _selectedBloodType,
      onSelect: (value) {
        setState(() {
          _selectedBloodType = value;
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
    return GridSelectionWidget(
      options: _zodiacOptions,
      columns: 3,
      selectedValue: _selectedZodiac,
      onSelect: (value) {
        setState(() {
          _selectedZodiac = value;
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
    return GridSelectionWidget(
      options: _animalOptions,
      columns: 3,
      selectedValue: _selectedAnimal,
      onSelect: (value) {
        setState(() {
          _selectedAnimal = value;
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

  bool _canGenerate() {
    return _selectedMbti != null &&
        _selectedBloodType != null &&
        _selectedZodiac != null &&
        _selectedAnimal != null;
  }

  bool get canGenerateFortune => _canGenerate();

  Widget _buildResultView(FortuneResult result) {
    final data = result.data;
    final dnaCode = data['dnaCode'] as String? ?? PersonalityDNA.generateDNACode(
      mbti: _selectedMbti!,
      bloodType: _selectedBloodType!,
      zodiac: _selectedZodiac!,
      zodiacAnimal: _selectedAnimal!,
    );

    final loveStyleData = data['loveStyle'] as Map<String, dynamic>?;
    final workStyleData = data['workStyle'] as Map<String, dynamic>?;
    final dailyMatchingData = data['dailyMatching'] as Map<String, dynamic>?;
    final compatibilityData = data['compatibility'] as Map<String, dynamic>?;
    final funStatsData = data['funStats'] as Map<String, dynamic>?;
    final dailyFortuneData = data['dailyFortune'] as Map<String, dynamic>?;

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

    _currentDNA = dnaObject;

    final currentHash = _getCurrentConditionsHash();

    if (_unlockedConditionsHash != currentHash) {
      _isBlurred = result.isBlurred;
      _blurredSections = List<String>.from(result.blurredSections);

      // ✅ 결과 최초 표시 시 햅틱 피드백
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final score = result.score ?? 70;
        ref.read(fortuneHapticServiceProvider).scoreReveal(score);
      });
    }

    debugPrint('🔒 [성격DNA] isBlurred: $_isBlurred, blurredSections: $_blurredSections, currentHash: $currentHash, unlockedHash: $_unlockedConditionsHash');

    return buildFortuneResult();
  }

  Widget buildFortuneResult() {
    if (_currentDNA == null) return const SizedBox.shrink();

    debugPrint('🎨 [buildResult] _isBlurred: $_isBlurred, FloatingButton 표시: ${_isBlurred ? "YES" : "NO"}');

    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            children: [
              DnaHeaderWidget(
                dna: _currentDNA!,
                onPopularityTapped: () => _showRankingBottomSheet(),
              ),
              const SizedBox(height: 12),
              if (_currentDNA!.dailyFortune != null) ...[
                DailyFortuneSection(dailyFortune: _currentDNA!.dailyFortune!),
                const SizedBox(height: 12),
              ],
              if (_currentDNA!.todayHighlight != null) ...[
                _buildTodayHighlight(),
                const SizedBox(height: 12),
              ],
              if (_currentDNA!.loveStyle != null) ...[
                UnifiedBlurWrapper(
                  isBlurred: _isBlurred,
                  blurredSections: _blurredSections,
                  sectionKey: 'loveStyle',
                  child: LoveStyleSection(loveStyle: _currentDNA!.loveStyle!),
                ),
                const SizedBox(height: 12),
              ],
              if (_currentDNA!.workStyle != null) ...[
                UnifiedBlurWrapper(
                  isBlurred: _isBlurred,
                  blurredSections: _blurredSections,
                  sectionKey: 'workStyle',
                  child: WorkStyleSection(workStyle: _currentDNA!.workStyle!),
                ),
                const SizedBox(height: 12),
              ],
              if (_currentDNA!.dailyMatching != null) ...[
                UnifiedBlurWrapper(
                  isBlurred: _isBlurred,
                  blurredSections: _blurredSections,
                  sectionKey: 'dailyMatching',
                  child: DailyMatchingSection(dailyMatching: _currentDNA!.dailyMatching!),
                ),
                const SizedBox(height: 12),
              ],
              if (_currentDNA!.compatibility != null) ...[
                UnifiedBlurWrapper(
                  isBlurred: _isBlurred,
                  blurredSections: _blurredSections,
                  sectionKey: 'compatibility',
                  child: CompatibilitySection(compatibility: _currentDNA!.compatibility!),
                ),
                const SizedBox(height: 12),
              ],
              if (_currentDNA!.celebrity != null) ...[
                UnifiedBlurWrapper(
                  isBlurred: _isBlurred,
                  blurredSections: _blurredSections,
                  sectionKey: 'celebrity',
                  child: CelebritySection(celebrity: _currentDNA!.celebrity!),
                ),
                const SizedBox(height: 12),
              ],
              if (_currentDNA!.funnyFact != null) ...[
                UnifiedBlurWrapper(
                  isBlurred: _isBlurred,
                  blurredSections: _blurredSections,
                  sectionKey: 'funnyFact',
                  child: _buildFunnyFactSection(),
                ),
                const SizedBox(height: 12),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
        if (_isBlurred && !ref.watch(isPremiumProvider))
          UnifiedButton.floating(
            text: '광고 보고 전체 내용 확인하기',
            onPressed: _showAdAndUnblur,
            isEnabled: true,
            bottom: 20,
          ),
      ],
    );
  }

  Widget _buildTodayHighlight() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TossSectionWidget(
      title: '오늘의 하이라이트',
      hanja: '光',
      colorScheme: HanjiColorScheme.fortune,
      child: Text(
        _currentDNA!.todayHighlight!,
        style: context.bodyMedium.copyWith(
          color: DSFortuneColors.getInk(isDark),
          height: 1.5,
        ),
      ),
    );
  }

  Widget _buildFunnyFactSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TossSectionWidget(
      title: '재미있는 사실',
      hanja: '趣',
      colorScheme: HanjiColorScheme.fortune,
      child: Text(
        _currentDNA!.funnyFact!,
        style: context.bodyMedium.copyWith(
          color: DSFortuneColors.getInk(isDark),
          height: 1.5,
        ),
      ),
    );
  }

  Future<void> _showAdAndUnblur() async {
    debugPrint('[성격DNA] 광고 시청 후 블러 해제 시작');

    try {
      final adService = AdService.instance;

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
                backgroundColor: DSColors.error,
              ),
            );
          }
          return;
        }
      }

      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) async {
          debugPrint('[성격DNA] ✅ 광고 시청 완료, 블러 해제');

          // ✅ 블러 해제 햅틱 (5단계 상승 패턴)
          await ref.read(fortuneHapticServiceProvider).premiumUnlock();

          // NEW: 게이지 증가 호출
          if (mounted) {
            FortuneCompletionHelper.onFortuneViewed(context, ref, 'personality-dna');
          }

          if (mounted) {
            setState(() {
              _isBlurred = false;
              _blurredSections = [];
              _unlockedConditionsHash = _getCurrentConditionsHash();
              debugPrint('[성격DNA] 블러 해제된 조건: $_unlockedConditionsHash');
            });
            // 구독 유도 스낵바 표시 (구독자가 아닌 경우만)
            final tokenState = ref.read(tokenProvider);
            SubscriptionSnackbar.showAfterAd(
              context,
              hasUnlimitedAccess: tokenState.hasUnlimitedAccess,
            );
          }
        },
      );
    } catch (e, stackTrace) {
      Logger.error('[성격DNA] 광고 표시 실패', e, stackTrace);

      if (mounted) {
        setState(() {
          _isBlurred = false;
          _blurredSections = [];
          _unlockedConditionsHash = _getCurrentConditionsHash();
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('광고 표시 중 오류가 발생했지만, 콘텐츠를 확인하실 수 있습니다.'),
            backgroundColor: DSColors.warning,
          ),
        );
      }
    }
  }

  // ✅ UnifiedBlurWrapper로 마이그레이션 완료 (2024-12-07)
}
