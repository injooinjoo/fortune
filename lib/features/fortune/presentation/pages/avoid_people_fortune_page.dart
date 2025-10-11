import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../shared/components/floating_bottom_button.dart';
import '../../../../core/components/toss_card.dart';
import 'base_fortune_page.dart';
import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../data/services/fortune_api_service.dart';
import '../../../../presentation/providers/providers.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../core/models/fortune_result.dart';

class AvoidPeopleFortunePage extends BaseFortunePage {
  const AvoidPeopleFortunePage({super.key})
      : super(
          title: '피해야 할 사람',
          description: '오늘 주의해야 할 사람 유형을 분석해드립니다',
          fortuneType: 'avoid-people',
          requiresUserInfo: false,
        );

  @override
  ConsumerState<AvoidPeopleFortunePage> createState() => _AvoidPeopleFortunePageState();
}

class _AvoidPeopleFortunePageState extends BaseFortunePageState<AvoidPeopleFortunePage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1: 상황 및 환경
  String _environment = '';
  String _importantSchedule = '';

  // Step 2: 감정 상태
  int _moodLevel = 3;
  int _stressLevel = 3;
  int _socialFatigue = 3;

  // Step 3: 주의할 상황
  bool _hasImportantDecision = false;
  bool _hasSensitiveConversation = false;
  bool _hasTeamProject = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // 마지막 단계에서 운세 생성
      _generateFortune();
    }
  }

  Future<void> _generateFortune() async {
    final params = {
      'environment': _environment,
      'importantSchedule': _importantSchedule,
      'moodLevel': _moodLevel,
      'stressLevel': _stressLevel,
      'socialFatigue': _socialFatigue,
      'hasImportantDecision': _hasImportantDecision,
      'hasSensitiveConversation': _hasSensitiveConversation,
      'hasTeamProject': _hasTeamProject,
    };

    // BaseFortunePage의 generateFortuneAction 호출
    await generateFortuneAction(params: params);
  }

  @override
  Future<Fortune> generateFortune(Map<String, dynamic> params) async {
    final user = ref.read(userProvider).value;
    if (user == null) {
      throw Exception('로그인이 필요합니다');
    }

    Logger.info('🔮 [AvoidPeopleFortune] UnifiedFortuneService 호출', {'params': params});

    try {
      // UnifiedFortuneService 사용
      final fortuneService = UnifiedFortuneService(Supabase.instance.client);

      // input_conditions 정규화
      final inputConditions = {
        'environment': params['environment'],
        'important_schedule': params['importantSchedule'],
        'mood_level': params['moodLevel'],
        'stress_level': params['stressLevel'],
        'social_fatigue': params['socialFatigue'],
        'has_important_decision': params['hasImportantDecision'],
        'has_sensitive_conversation': params['hasSensitiveConversation'],
        'has_team_project': params['hasTeamProject'],
      };

      final fortuneResult = await fortuneService.getFortune(
        fortuneType: 'avoid_people',
        dataSource: FortuneDataSource.api,
        inputConditions: inputConditions,
      );

      Logger.info('✅ [AvoidPeopleFortune] UnifiedFortuneService 완료');

      // FortuneResult → Fortune 엔티티 변환
      final fortune = _convertToFortune(fortuneResult);

      Logger.info('✅ [AvoidPeopleFortune] API fortune loaded successfully');
      return fortune;

    } catch (e, stackTrace) {
      Logger.error('❌ [AvoidPeopleFortune] API failed', e, stackTrace);
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 운세 결과가 있으면 BaseFortunePage가 결과 표시
    if (fortune != null || isLoading || error != null) {
      return super.build(context);
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Input UI 표시
    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.white,
      appBar: AppBar(
        backgroundColor: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
            size: 20,
          ),
        ),
        title: Text(
          widget.title,
          style: TossDesignSystem.heading3.copyWith(
            color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Progress Indicator
              _buildProgressIndicator(isDark),

              // Page Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1(isDark),
                    _buildStep2(isDark),
                    _buildStep3(isDark),
                  ],
                ),
              ),
            ],
          ),

          // Floating 버튼
          FloatingBottomButton(
            text: _currentStep == 2 ? '분석 시작' : '다음',
            onPressed: _currentStep == 0
                ? (_environment.isNotEmpty && _importantSchedule.isNotEmpty ? _nextStep : null)
                : _nextStep,
            style: TossButtonStyle.primary,
            size: TossButtonSize.large,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Row(
            children: List.generate(3, (index) {
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: index <= _currentStep
                        ? TossDesignSystem.errorRed
                        : (isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray200),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ).animate(target: index <= _currentStep ? 1 : 0)
                  .scaleX(begin: 0, end: 1, duration: 300.ms),
              );
            }),
          ),
          const SizedBox(height: 8),
          Text(
            '${_currentStep + 1} / 3',
            style: TossDesignSystem.caption.copyWith(
              color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      colors: [TossDesignSystem.errorRed, TossDesignSystem.errorRed.withValues(alpha:0.8)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: TossDesignSystem.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '현재 상황 분석',
                  style: TossDesignSystem.heading3.copyWith(
                    color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '오늘 주로 있을 환경과 일정을 알려주세요',
                  style: TossDesignSystem.body2.copyWith(
                    color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          Text(
            '오늘의 주요 환경',
            style: TossDesignSystem.body1.copyWith(
              color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              '직장', '학교', '모임', '가족', '데이트', '집'
            ].map((env) => _buildChip(
              env,
              _environment == env,
              () => setState(() => _environment = env),
              isDark,
            )).toList(),
          ),

          const SizedBox(height: 32),

          Text(
            '중요한 일정',
            style: TossDesignSystem.body1.copyWith(
              color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              '면접', '프레젠테이션', '미팅', '시험', '데이트', '가족모임', '없음'
            ].map((schedule) => _buildChip(
              schedule,
              _importantSchedule == schedule,
              () => setState(() => _importantSchedule = schedule),
              isDark,
            )).toList(),
          ),

          const SizedBox(height: 80), // Floating 버튼 공간
        ],
      ),
    );
  }

  Widget _buildStep2(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      colors: [TossDesignSystem.warningOrange, TossDesignSystem.warningOrange.withValues(alpha:0.8)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mood_rounded,
                    color: TossDesignSystem.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '감정 상태 체크',
                  style: TossDesignSystem.heading3.copyWith(
                    color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '현재 당신의 감정 상태를 평가해주세요',
                  style: TossDesignSystem.body2.copyWith(
                    color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          _buildSliderSection(
            '현재 기분',
            _moodLevel,
            (value) => setState(() => _moodLevel = value.round()),
            ['😔', '😐', '😊', '😄', '🤩'],
            isDark,
          ),

          const SizedBox(height: 24),

          _buildSliderSection(
            '스트레스 레벨',
            _stressLevel,
            (value) => setState(() => _stressLevel = value.round()),
            ['😌', '🙂', '😰', '😣', '🤯'],
            isDark,
          ),

          const SizedBox(height: 24),

          _buildSliderSection(
            '대인관계 피로도',
            _socialFatigue,
            (value) => setState(() => _socialFatigue = value.round()),
            ['💪', '👍', '😑', '😩', '🥱'],
            isDark,
          ),

          const SizedBox(height: 80), // Floating 버튼 공간
        ],
      ),
    );
  }

  Widget _buildStep3(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      colors: [TossDesignSystem.purple, TossDesignSystem.purple.withValues(alpha:0.8)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: TossDesignSystem.white,
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  '주의할 상황',
                  style: TossDesignSystem.heading3.copyWith(
                    color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '오늘 예정된 중요한 활동을 선택해주세요',
                  style: TossDesignSystem.body2.copyWith(
                    color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          _buildCheckboxItem(
            '중요한 의사결정이 있다',
            _hasImportantDecision,
            (value) => setState(() => _hasImportantDecision = value ?? false),
            Icons.gavel_rounded,
            isDark,
          ),

          const SizedBox(height: 16),

          _buildCheckboxItem(
            '민감한 대화가 예정되어 있다',
            _hasSensitiveConversation,
            (value) => setState(() => _hasSensitiveConversation = value ?? false),
            Icons.chat_bubble_rounded,
            isDark,
          ),

          const SizedBox(height: 16),

          _buildCheckboxItem(
            '팀 프로젝트나 협업이 있다',
            _hasTeamProject,
            (value) => setState(() => _hasTeamProject = value ?? false),
            Icons.groups_rounded,
            isDark,
          ),

          const SizedBox(height: 16),

          Text(
            '분석 결과는 참고용으로만 활용해주세요',
            style: TossDesignSystem.caption.copyWith(
              color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 80), // Floating 버튼 공간
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? TossDesignSystem.errorRed.withValues(alpha:0.1)
              : (isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray50),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? TossDesignSystem.errorRed
                : (isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TossDesignSystem.body2.copyWith(
            color: isSelected
                ? TossDesignSystem.errorRed
                : (isDark ? TossDesignSystem.white : TossDesignSystem.gray900),
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Widget _buildSliderSection(
    String title,
    int value,
    ValueChanged<double> onChanged,
    List<String> emojis,
    bool isDark,
  ) {
    return TossCard(
      style: TossCardStyle.filled,
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TossDesignSystem.body1.copyWith(
                  color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                emojis[value - 1],
                style: const TextStyle(fontSize: 24),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: TossDesignSystem.errorRed,
              inactiveTrackColor: isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray200,
              thumbColor: TossDesignSystem.errorRed,
              overlayColor: TossDesignSystem.errorRed.withValues(alpha:0.1),
            ),
            child: Slider(
              value: value.toDouble(),
              min: 1,
              max: 5,
              divisions: 4,
              onChanged: onChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '낮음',
                style: TossDesignSystem.caption.copyWith(
                  color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                ),
              ),
              Text(
                '높음',
                style: TossDesignSystem.caption.copyWith(
                  color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxItem(
    String title,
    bool value,
    ValueChanged<bool?> onChanged,
    IconData icon,
    bool isDark,
  ) {
    return TossCard(
      style: TossCardStyle.filled,
      padding: const EdgeInsets.all(16),
      onTap: () => onChanged(!value),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: value
                  ? TossDesignSystem.errorRed.withValues(alpha:0.1)
                  : (isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray100),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: value
                  ? TossDesignSystem.errorRed
                  : (isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray400),
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: TossDesignSystem.body2.copyWith(
                color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
              ),
            ),
          ),
          Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: TossDesignSystem.errorRed,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }

  /// FortuneResult를 Fortune 엔티티로 변환
  Fortune _convertToFortune(FortuneResult result) {
    return Fortune(
      id: result.id ?? '',
      userId: ref.read(userProvider).value?.id ?? '',
      type: result.fortuneType,
      date: DateTime.now(),
      content: result.data['content'] as String? ?? result.summary.toString(),
      overallScore: result.score,
      createdAt: DateTime.now(),
      title: result.title,
      summary: result.summary,
    );
  }
}
