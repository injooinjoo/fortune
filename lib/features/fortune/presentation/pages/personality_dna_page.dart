import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../core/models/personality_dna_model.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/components/toss_floating_progress_button.dart';
import '../widgets/standard_fortune_app_bar.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../domain/models/conditions/personality_dna_fortune_conditions.dart';
import '../../../../core/widgets/accordion_input_section.dart';

class PersonalityDNAPage extends BaseFortunePage {
  const PersonalityDNAPage({
    super.key,
    super.initialParams,
  }) : super(
          title: '성격 DNA',
          description: 'MBTI, 혈액형, 별자리, 띠를 조합한 특별한 성격 분석',
          fortuneType: 'personality-dna',
          requiresUserInfo: false,
        );

  @override
  ConsumerState<PersonalityDNAPage> createState() => _PersonalityDNAPageState();
}

class _PersonalityDNAPageState extends BaseFortunePageState<PersonalityDNAPage> {
  // 선택된 값들
  String? _selectedMbti;
  String? _selectedBloodType;
  String? _selectedZodiac;
  String? _selectedAnimal;

  PersonalityDNA? _currentDNA;

  // 아코디언 섹션
  late List<AccordionInputSection> _accordionSections;

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
    _initializeAccordionSections();
  }

  void _initializeAccordionSections() {
    _accordionSections = [
      AccordionInputSection(
        id: 'mbti',
        title: 'MBTI',
        icon: Icons.psychology_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildMbtiInput(onComplete),
      ),
      AccordionInputSection(
        id: 'blood_type',
        title: '혈액형',
        icon: Icons.bloodtype_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildBloodTypeInput(onComplete),
      ),
      AccordionInputSection(
        id: 'zodiac',
        title: '별자리',
        icon: Icons.star_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildZodiacInput(onComplete),
      ),
      AccordionInputSection(
        id: 'animal',
        title: '띠',
        icon: Icons.pets_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildAnimalInput(onComplete),
      ),
    ];
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      throw Exception('사용자 정보를 찾을 수 없습니다.');
    }

    final userProfile = await ref.read(userProfileProvider.future);
    final userName = userProfile?.name ?? 'Unknown';

    // UnifiedFortuneService 사용
    final fortuneService = UnifiedFortuneService(Supabase.instance.client);

    final inputConditions = {
      'userId': user.id,
      'name': userName,
      'mbti': _selectedMbti,
      'bloodType': _selectedBloodType,
      'zodiac': _selectedZodiac,
      'zodiacAnimal': _selectedAnimal,
    };

    // Optimization conditions 생성
    final conditions = PersonalityDnaFortuneConditions(
      mbti: _selectedMbti,
      bloodType: _selectedBloodType,
      zodiac: _selectedZodiac,
      animal: _selectedAnimal,
      date: DateTime.now(),
    );

    final fortuneResult = await fortuneService.getFortune(
      fortuneType: 'personality-dna',
      dataSource: FortuneDataSource.api,
      inputConditions: inputConditions,
      conditions: conditions,
    );

    // FortuneResult의 data 필드에서 PersonalityDNA 정보 추출
    final data = fortuneResult.data;

    final dnaCode = data['dnaCode'] as String? ?? PersonalityDNA.generateDNACode(
      mbti: _selectedMbti!,
      bloodType: _selectedBloodType!,
      zodiac: _selectedZodiac!,
      zodiacAnimal: _selectedAnimal!,
    );

    // Edge Function 응답 구조 확인 - 두 가지 버전 지원
    final bool isNewFormat = data.containsKey('loveStyle');

    Map<String, dynamic>? loveStyleMap;
    Map<String, dynamic>? workStyleMap;
    Map<String, dynamic>? dailyMatchingMap;
    Map<String, dynamic>? compatibilityMap;
    Map<String, dynamic> funStatsMap = {};

    if (isNewFormat) {
      // 새로운 형식 (loveStyle, workStyle 등)
      loveStyleMap = data['loveStyle'] as Map<String, dynamic>?;
      workStyleMap = data['workStyle'] as Map<String, dynamic>?;
      dailyMatchingMap = data['dailyMatching'] as Map<String, dynamic>?;
      compatibilityMap = data['compatibility'] as Map<String, dynamic>?;
      funStatsMap = data['funStats'] as Map<String, dynamic>? ?? {};
    } else {
      // 구 형식 (title이 "undefined DNA"로 나오는 경우) - 기본값 사용
      print('⚠️ [WARNING] Old format detected, using fallback data');
    }

    // 모델 객체로 변환
    LoveStyle? loveStyle;
    if (loveStyleMap != null) {
      loveStyle = LoveStyle.fromJson(loveStyleMap);
    }

    WorkStyle? workStyle;
    if (workStyleMap != null) {
      workStyle = WorkStyle.fromJson(workStyleMap);
    }

    DailyMatching? dailyMatching;
    if (dailyMatchingMap != null) {
      dailyMatching = DailyMatching.fromJson(dailyMatchingMap);
    }

    Compatibility? compatibility;
    if (compatibilityMap != null) {
      compatibility = Compatibility.fromJson(compatibilityMap);
    }

    Celebrity? celebrity;
    if (funStatsMap['celebrity_match'] != null) {
      celebrity = Celebrity(
        name: funStatsMap['celebrity_match'] as String,
        reason: '비슷한 성격 유형',
      );
    }

    // 상세 설명 생성
    final detailedDescription = '''
${data['todayHighlight'] ?? '당신의 성격 DNA를 분석했습니다.'}

💕 연애 스타일: ${loveStyle?.title ?? ''}
${loveStyle?.description ?? ''}

👔 직장 생활: ${workStyle?.title ?? ''}
${workStyle?.asBoss ?? ''}

🎯 오늘의 조언
${data['todayAdvice'] ?? '평소와 다른 작은 도전을 해보세요.'}

✨ 재미있는 통계
• 희귀도: ${funStatsMap['rarity_rank'] ?? ''}
• 유명인 매칭: ${funStatsMap['celebrity_match'] ?? ''}
• 한국 내 비율: ${funStatsMap['percentage_in_korea'] ?? ''}%
    '''.trim();

    // title 처리 - "undefined DNA" 방지
    String finalTitle = data['title'] as String? ?? '성격 DNA';
    if (finalTitle.contains('undefined')) {
      finalTitle = '${_selectedMbti} 성격 DNA';
      print('⚠️ [WARNING] Fixed undefined title to: $finalTitle');
    }

    _currentDNA = PersonalityDNA(
      mbti: _selectedMbti!,
      bloodType: _selectedBloodType!,
      zodiac: _selectedZodiac!,
      zodiacAnimal: _selectedAnimal!,
      dnaCode: dnaCode,
      title: finalTitle,
      emoji: data['emoji'] as String? ?? '🧬',
      description: detailedDescription,
      traits: [], // Edge Function에서 traits 대신 loveStyle, workStyle 사용
      gradientColors: [], // 로컬에서 생성
      scores: {
        'socialRanking': (data['socialRanking'] as num?)?.toInt() ?? 50,
      },
      todaysFortune: data['todayAdvice'] as String? ?? '평소와 다른 작은 도전을 해보세요.',
      // Edge Function 데이터를 모델 객체로 전달
      todayHighlight: data['todayHighlight'] as String?,
      loveStyle: loveStyle,
      workStyle: workStyle,
      dailyMatching: dailyMatching,
      compatibility: compatibility,
      celebrity: celebrity,
      funnyFact: '${funStatsMap['rarity_rank']} • 한국 내 ${funStatsMap['percentage_in_korea']}%',
      popularityRank: (data['socialRanking'] as num?)?.toInt() ?? 50,
    );

    // Fortune 객체로 변환
    return Fortune(
      id: 'personality_dna_${DateTime.now().millisecondsSinceEpoch}',
      userId: user.id,
      type: 'personality-dna',
      content: detailedDescription,
      createdAt: DateTime.now(),
      category: 'personality-dna',
      overallScore: _currentDNA!.popularityRank ?? 50,
      description: '${_currentDNA!.emoji} ${_currentDNA!.title}\n\n$detailedDescription',
      metadata: {
        'mbti': _selectedMbti,
        'blood_type': _selectedBloodType,
        'zodiac': _selectedZodiac,
        'animal': _selectedAnimal,
        'dna_code': dnaCode,
        'love_style': loveStyle?.toJson(),
        'work_style': workStyle?.toJson(),
        'daily_matching': dailyMatching?.toJson(),
        'compatibility': compatibility?.toJson(),
        'fun_stats': funStatsMap,
        'rarity_level': data['rarityLevel'],
        'social_ranking': data['socialRanking'],
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // If fortune exists, show result
    if (fortune != null || isLoading || error != null) {
      return super.build(context);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Show selection UI with Accordion
    return Scaffold(
      backgroundColor: widget.backgroundColor ?? (isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.white),
      appBar: StandardFortuneAppBar(
        title: widget.title,
      ),
      body: SafeArea(
        child: Stack(
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
                    onAllCompleted: null, // floating button으로 운세 생성
                    completionButtonText: '🧬 나만의 성격 DNA 발견하기',
                  ),
                ),
              ],
            ),
            if (_canGenerate())
              TossFloatingProgressButtonPositioned(
                text: '🧬 나만의 성격 DNA 발견하기',
                onPressed: canGenerateFortune ? () => _handleGenerateFortune() : null,
                isEnabled: canGenerateFortune,
                showProgress: false,
                isVisible: canGenerateFortune,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleGenerateFortune() async {
    await generateFortuneAction();
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
      onSelect: (value) {
        setState(() => _selectedMbti = value);
        onComplete(value);
      },
    );
  }

  Widget _buildBloodTypeInput(Function(dynamic) onComplete) {
    return _buildGridSelection(
      options: _bloodTypeOptions,
      columns: 4,
      onSelect: (value) {
        setState(() => _selectedBloodType = value);
        onComplete(value);
      },
    );
  }

  Widget _buildZodiacInput(Function(dynamic) onComplete) {
    return _buildGridSelection(
      options: _zodiacOptions,
      columns: 3,
      onSelect: (value) {
        setState(() => _selectedZodiac = value);
        onComplete(value);
      },
    );
  }

  Widget _buildAnimalInput(Function(dynamic) onComplete) {
    return _buildGridSelection(
      options: _animalOptions,
      columns: 3,
      onSelect: (value) {
        setState(() => _selectedAnimal = value);
        onComplete(value);
      },
    );
  }

  Widget _buildGridSelection({
    required List<String> options,
    required int columns,
    required Function(String) onSelect,
  }) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: columns,
      childAspectRatio: 2.2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: options.map((option) {
        return _buildOptionChip(option, onSelect);
      }).toList(),
    );
  }

  Widget _buildOptionChip(String option, Function(String) onSelect) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.mediumImpact();
        onSelect(option);
      },
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray200,
            width: 1.5,
          ),
        ),
        child: Center(
          child: Text(
            option,
            style: TypographyUnified.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.textPrimaryLight,
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

  @override
  Widget buildFortuneResult() {
    if (_currentDNA == null) return const SizedBox.shrink();

    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          _buildDNAHeader(),
          const SizedBox(height: 8),
          if (_currentDNA!.todayHighlight != null) ...[
            _buildTodayHighlight(),
            const SizedBox(height: 8),
          ],
          if (_currentDNA!.loveStyle != null) ...[
            _buildLoveStyleSection(),
            const SizedBox(height: 8),
          ],
          if (_currentDNA!.workStyle != null) ...[
            _buildWorkStyleSection(),
            const SizedBox(height: 8),
          ],
          if (_currentDNA!.dailyMatching != null) ...[
            _buildDailyMatchingSection(),
            const SizedBox(height: 8),
          ],
          if (_currentDNA!.compatibility != null) ...[
            _buildCompatibilitySection(),
            const SizedBox(height: 8),
          ],
          if (_currentDNA!.celebrity != null) ...[
            _buildCelebritySection(),
            const SizedBox(height: 8),
          ],
          if (_currentDNA!.funnyFact != null) ...[
            _buildFunnyFactSection(),
            const SizedBox(height: 8),
          ],
          const SizedBox(height: 32),
        ],
      ),
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
}
