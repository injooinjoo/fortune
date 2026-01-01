import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/unified_fortune_base_widget.dart';
import '../../../../core/widgets/app_widgets.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../domain/models/conditions/avoid_people_fortune_conditions.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../services/ad_service.dart';
import '../../../../core/utils/subscription_snackbar.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../presentation/providers/subscription_provider.dart';
import '../../../../core/services/fortune_haptic_service.dart';
import '../../../../core/utils/fortune_completion_helper.dart';
import '../../../../core/widgets/today_result_label.dart';

class AvoidPeopleFortunePage extends ConsumerStatefulWidget {
  const AvoidPeopleFortunePage({super.key});

  @override
  ConsumerState<AvoidPeopleFortunePage> createState() => _AvoidPeopleFortunePageState();
}

class _AvoidPeopleFortunePageState extends ConsumerState<AvoidPeopleFortunePage> {
  // ✅ PageView Controller
  final PageController _pageController = PageController();

  // ✅ 단계별 상태 (0: 장소, 1: 일정, 2: 기분, 3: 상황)
  int _currentStep = 0;

  // ✅ Blur 상태 관리
  bool _isBlurred = false;
  List<String> _blurredSections = [];

  // ✅ 초기화 여부 추적 (resultBuilder가 처음 호출되었는지)
  bool _hasInitializedBlur = false;

  // 입력 필드들
  String _environment = '';
  String _importantSchedule = '';
  int _moodLevel = 3;
  int _stressLevel = 3;
  int _socialFatigue = 3;
  bool _hasImportantDecision = false;
  bool _hasSensitiveConversation = false;
  bool _hasTeamProject = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _environment.isNotEmpty && _importantSchedule.isNotEmpty;

  void _nextStep() {
    if (_currentStep < 3) {
      HapticFeedback.lightImpact(); // ✅ 햅틱 피드백
      _pageController.animateToPage(
        _currentStep + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return UnifiedFortuneBaseWidget(
      fortuneType: 'avoid-people',
      title: '경계대상',
      description: '오늘 주의해야 할 사람 유형을 분석해드립니다',
      dataSource: FortuneDataSource.api,
      inputBuilder: (context, onComplete) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Stack(
          children: [
            // ✅ PageView로 단계별 입력
            Column(
              children: [
                // ✅ PageView (상단 indicator 제거, 버튼에 progress 표시)
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentStep = index;
                      });
                    },
                    children: [
                      _buildStep1Environment(isDark),
                      _buildStep2Schedule(isDark),
                      _buildStep3Mood(isDark),
                      _buildStep4Situation(isDark),
                    ],
                  ),
                ),
              ],
            ),

            // ✅ FloatingBottomButton
            _buildStepButton(onComplete, isDark),
          ],
        );
      },

      conditionsBuilder: () async {
        return AvoidPeopleFortuneConditions(
          environment: _environment,
          importantSchedule: _importantSchedule,
          moodLevel: _moodLevel,
          stressLevel: _stressLevel,
          socialFatigue: _socialFatigue,
          hasImportantDecision: _hasImportantDecision,
          hasSensitiveConversation: _hasSensitiveConversation,
          hasTeamProject: _hasTeamProject,
        );
      },

      resultBuilder: (context, result) {
        // ✅ Blur 상태 초기화 (최초 한 번만)
        if (!_hasInitializedBlur && result.isBlurred == true) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              final score = result.score ?? 70;
              ref.read(fortuneHapticServiceProvider).scoreReveal(score);

              setState(() {
                _isBlurred = result.isBlurred;
                _blurredSections = result.isBlurred
                    ? ['cautionPeople', 'cautionObjects', 'cautionColors', 'cautionNumbers',
                       'cautionAnimals', 'cautionPlaces', 'cautionTimes', 'cautionDirections',
                       'luckyElements', 'timeStrategy', 'dailyAdvice']
                    : [];
                _hasInitializedBlur = true;
              });
            }
          });
        }

        final summary = result.data['summary'] as String? ?? '오늘의 경계대상을 확인하세요.';

        return Stack(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24).copyWith(bottom: 100),
                  child: Column(
                    children: [
                      // 오늘 날짜 라벨 + 재방문 유도
                      const TodayResultLabel(showRevisitHint: true),
                      const SizedBox(height: 16),

                      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                      // 📊 경계지수 카드 (무료)
                      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                      GlassCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Text('⚠️', style: TextStyle(fontSize: 28)),
                                const SizedBox(width: 12),
                                Text('오늘의 경계 지수', style: DSTypography.headingMedium),
                              ],
                            ),
                            if (result.score != null) ...[
                              const SizedBox(height: 16),
                              _buildScoreIndicator(result.score!),
                            ],
                            const SizedBox(height: 16),
                            Text(summary, style: DSTypography.bodyMedium),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                      // 👀 무료 미리보기 섹션 (블러 상태일 때만 표시)
                      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                      if (_isBlurred) ...[
                        _buildPreviewSection(result.data),
                        const SizedBox(height: 16),
                      ],

                      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                      // 👤 경계인물 카드 (Premium)
                      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                      _buildCautionCard(
                        sectionKey: 'cautionPeople',
                        icon: '👤',
                        title: '경계인물',
                        subtitle: '오늘 피해야 할 사람 유형',
                        items: _parseCautionPeople(result.data['cautionPeople']),
                      ),

                      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                      // 📦 경계사물 카드 (Premium)
                      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                      _buildCautionCard(
                        sectionKey: 'cautionObjects',
                        icon: '📦',
                        title: '경계사물',
                        subtitle: '오늘 조심해야 할 물건',
                        items: _parseCautionObjects(result.data['cautionObjects']),
                      ),

                      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                      // 🎨 경계색상 카드 (Premium)
                      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                      _buildCautionCard(
                        sectionKey: 'cautionColors',
                        icon: '🎨',
                        title: '경계색상',
                        subtitle: '오늘 피해야 할 색상',
                        items: _parseCautionColors(result.data['cautionColors']),
                      ),

                      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                      // 🔢 경계숫자 카드 (Premium)
                      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                      _buildCautionCard(
                        sectionKey: 'cautionNumbers',
                        icon: '🔢',
                        title: '경계숫자',
                        subtitle: '오늘 피해야 할 숫자',
                        items: _parseCautionNumbers(result.data['cautionNumbers']),
                      ),

                      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                      // 🐾 경계동물 카드 (Premium)
                      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                      _buildCautionCard(
                        sectionKey: 'cautionAnimals',
                        icon: '🐾',
                        title: '경계동물',
                        subtitle: '오늘 조심해야 할 동물/띠',
                        items: _parseCautionAnimals(result.data['cautionAnimals']),
                      ),

                      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                      // 📍 경계장소 카드 (Premium)
                      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                      _buildCautionCard(
                        sectionKey: 'cautionPlaces',
                        icon: '📍',
                        title: '경계장소',
                        subtitle: '오늘 피해야 할 장소',
                        items: _parseCautionPlaces(result.data['cautionPlaces']),
                      ),

                      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                      // ⏰ 경계시간 카드 (Premium)
                      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                      _buildCautionCard(
                        sectionKey: 'cautionTimes',
                        icon: '⏰',
                        title: '경계시간',
                        subtitle: '오늘 조심해야 할 시간대',
                        items: _parseCautionTimes(result.data['cautionTimes']),
                      ),

                      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                      // 🧭 경계방향 카드 (Premium)
                      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                      _buildCautionCard(
                        sectionKey: 'cautionDirections',
                        icon: '🧭',
                        title: '경계방향',
                        subtitle: '오늘 피해야 할 방위',
                        items: _parseCautionDirections(result.data['cautionDirections']),
                      ),

                      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                      // ✨ 행운요소 카드 (Premium)
                      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                      _buildLuckyElementsCard(result.data['luckyElements']),

                      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                      // 📅 시간대별 전략 카드 (Premium)
                      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                      _buildTimeStrategyCard(result.data['timeStrategy']),

                      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                      // 💡 종합 조언 카드 (Premium)
                      // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
                      UnifiedBlurWrapper(
                        isBlurred: _isBlurred,
                        blurredSections: _blurredSections,
                        sectionKey: 'dailyAdvice',
                        child: GlassCard(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('💡', style: TextStyle(fontSize: 24)),
                                  const SizedBox(width: 12),
                                  Text('오늘의 종합 조언', style: DSTypography.headingSmall),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                result.data['dailyAdvice'] as String? ?? '오늘 하루 경계대상에 주의하세요.',
                                style: DSTypography.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ),

            // ✅ FloatingBottomButton (블러 상태일 때만 표시)
            if (_isBlurred && !ref.watch(isPremiumProvider))
              UnifiedButton.floating(
                text: '🎁 광고 보고 전체 내용 보기',
                onPressed: _showAdAndUnblur,
                isEnabled: true,
              ),
          ],
        );
      },
    );
  }

  // ===== Step 1: 장소 선택 =====
  Widget _buildStep1Environment(bool isDark) {
    // 장소 옵션 (이모지 + 라벨)
    const placeOptions = [
      ('🏢', '직장'),
      ('🏫', '학교'),
      ('🎉', '모임'),
      ('🏠', '집'),
      ('☕', '카페'),
      ('🚇', '대중교통'),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24).copyWith(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ChatGPT 스타일 헤더
              const PageHeaderSection(
                emoji: '📍',
                title: '오늘의 주요 장소',
                subtitle: '현재 상태와 일정을 입력하면\n오늘 주의해야 할 사람 유형을 분석해드립니다',
              ),
              const SizedBox(height: 40),

              // 장소 선택 라벨
              const FieldLabel(text: '주요 장소를 선택해주세요'),

              // 장소 선택
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: placeOptions
                    .map((option) => SelectionChip(
                        label: '${option.$1} ${option.$2}',
                        isSelected: _environment == option.$2,
                        onTap: () {
                          setState(() => _environment = option.$2);
                          HapticFeedback.selectionClick();
                        }))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Step 2: 중요 일정 선택 =====
  Widget _buildStep2Schedule(bool isDark) {
    // 일정 옵션 (이모지 + 라벨)
    const scheduleOptions = [
      ('💼', '면접'),
      ('📊', '프레젠테이션'),
      ('🤝', '미팅'),
      ('📝', '시험'),
      ('💕', '데이트'),
      ('👨‍👩‍👧‍👦', '가족모임'),
      ('✨', '없음'),
    ];

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24).copyWith(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ChatGPT 스타일 헤더
              const PageHeaderSection(
                emoji: '📅',
                title: '중요한 일정',
                subtitle: '오늘 예정된 중요한 일정을 선택해주세요',
              ),
              const SizedBox(height: 40),

              // 일정 선택 라벨
              const FieldLabel(text: '오늘의 일정'),

              // 일정 선택
              Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: scheduleOptions
                    .map((option) => SelectionChip(
                        label: '${option.$1} ${option.$2}',
                        isSelected: _importantSchedule == option.$2,
                        onTap: () {
                          setState(() => _importantSchedule = option.$2);
                          HapticFeedback.selectionClick();
                        }))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Step 3: 기분/스트레스 슬라이더 =====
  Widget _buildStep3Mood(bool isDark) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24).copyWith(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ChatGPT 스타일 헤더
              const PageHeaderSection(
                emoji: '😊',
                title: '현재 상태',
                subtitle: '현재 기분과 상태를 솔직하게 알려주세요',
              ),
              const SizedBox(height: 40),

              // 슬라이더들
              LabeledSlider(
                label: '기분 상태',
                value: _moodLevel,
                onChanged: (v) {
                  setState(() => _moodLevel = v);
                  HapticFeedback.selectionClick();
                },
              ),
              const SizedBox(height: 32),
              LabeledSlider(
                label: '스트레스 정도',
                value: _stressLevel,
                onChanged: (v) {
                  setState(() => _stressLevel = v);
                  HapticFeedback.selectionClick();
                },
              ),
              const SizedBox(height: 32),
              LabeledSlider(
                label: '사람 만나기 피로도',
                value: _socialFatigue,
                onChanged: (v) {
                  setState(() => _socialFatigue = v);
                  HapticFeedback.selectionClick();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Step 4: 상황 체크박스 =====
  Widget _buildStep4Situation(bool isDark) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24).copyWith(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ChatGPT 스타일 헤더
              const PageHeaderSection(
                emoji: '⚠️',
                title: '주의할 상황',
                subtitle: '오늘 예상되는 특별한 상황이 있나요?',
              ),
              const SizedBox(height: 40),

              // 체크박스
              ModernCard(
                child: Column(
                  children: [
                    CardCheckbox(
                      label: '중요한 결정을 해야 함',
                      value: _hasImportantDecision,
                      onChanged: (v) {
                        setState(() => _hasImportantDecision = v);
                        HapticFeedback.selectionClick();
                      },
                    ),
                    CardCheckbox(
                      label: '민감한 대화가 예상됨',
                      value: _hasSensitiveConversation,
                      onChanged: (v) {
                        setState(() => _hasSensitiveConversation = v);
                        HapticFeedback.selectionClick();
                      },
                    ),
                    CardCheckbox(
                      label: '팀 프로젝트가 있음',
                      value: _hasTeamProject,
                      onChanged: (v) {
                        setState(() => _hasTeamProject = v);
                        HapticFeedback.selectionClick();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===== Step Button =====
  Widget _buildStepButton(VoidCallback onComplete, bool isDark) {
    // 현재 단계의 활성화 여부
    final isEnabled = _currentStep == 0
        ? _environment.isNotEmpty
        : _currentStep == 1
            ? _importantSchedule.isNotEmpty
            : _currentStep == 3
                ? _canSubmit
                : true;

    // 버튼 텍스트
    final buttonText = _currentStep == 0
        ? (_environment.isEmpty ? '장소를 선택해주세요' : '다음')
        : _currentStep == 1
            ? (_importantSchedule.isEmpty ? '일정을 선택해주세요' : '다음')
            : _currentStep == 3
                ? '오늘 피해야 할 사람 확인하기'
                : '다음';

    return UnifiedButton.floating(
      text: buttonText,
      onPressed: () {
        if (_currentStep < 3) {
          if (_currentStep == 0 && _environment.isEmpty) return;
          if (_currentStep == 1 && _importantSchedule.isEmpty) return;
          _nextStep();
        } else {
          onComplete();
        }
      },
      isEnabled: isEnabled,
      showProgress: true,
      currentStep: _currentStep + 1,
      totalSteps: 4,
    );
  }

  // ===== 광고 & 블러 해제 =====
  Future<void> _showAdAndUnblur() async {
    try {
      Logger.info('');
      Logger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      Logger.info('📺 [피해야 할 사람] 광고 시청 & 블러 해제 프로세스 시작');
      Logger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

      // 광고 서비스 초기화 및 로드
      final adService = AdService();

      Logger.info('');
      Logger.info('1️⃣ 광고 준비 상태 확인');
      Logger.info('   - adService.isRewardedAdReady: ${adService.isRewardedAdReady}');

      // 광고가 아직 로드되지 않았으면 로드
      if (!adService.isRewardedAdReady) {
        Logger.info('   → 광고가 준비되지 않음. 로딩 시작...');

        // 로딩 중 사용자에게 표시
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('광고를 준비하는 중...'),
              duration: Duration(seconds: 3),
            ),
          );
        }

        await adService.loadRewardedAd();

        // 광고 로딩 완료 대기 (최대 5초)
        int waitCount = 0;
        while (!adService.isRewardedAdReady && waitCount < 10) {
          await Future.delayed(const Duration(milliseconds: 500));
          waitCount++;
          Logger.info('   ⏳ 광고 로딩 대기 중... (${waitCount * 500}ms)');
        }

        if (!adService.isRewardedAdReady) {
          Logger.error('   ❌ 광고 로딩 실패 - 타임아웃');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('광고를 불러오지 못했습니다. 다시 시도해주세요.'),
                duration: Duration(seconds: 2),
              ),
            );
          }
          return;
        }

        Logger.info('   ✅ 광고 로딩 완료');
      } else {
        Logger.info('   ✅ 광고가 이미 준비됨');
      }

      Logger.info('');
      Logger.info('2️⃣ 리워드 광고 표시');
      Logger.info('   - 현재 블러 상태: isBlurred=$_isBlurred');
      Logger.info('   - 블러된 섹션: $_blurredSections');
      Logger.info('   - 광고 준비 상태: ${adService.isRewardedAdReady}');
      Logger.info('   → 광고 표시 중...');

      // 리워드 광고 표시 및 완료 대기
      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) async {
          Logger.info('');
          Logger.info('3️⃣ 광고 시청 완료!');
          Logger.info('   - reward.type: ${reward.type}');
          Logger.info('   - reward.amount: ${reward.amount}');

          // ✅ 블러 해제 햅틱 (5단계 상승 패턴)
          await ref.read(fortuneHapticServiceProvider).premiumUnlock();

          // NEW: 게이지 증가 호출
          if (mounted) {
            FortuneCompletionHelper.onFortuneViewed(context, ref, 'avoid-people');
          }

          // ✅ 광고 시청 완료 시 블러만 해제 (로컬 상태 변경)
          if (mounted) {
            Logger.info('   → 블러 해제 중...');

            setState(() {
              _isBlurred = false;
              _blurredSections = [];
            });

            Logger.info('   ✅ 블러 해제 완료!');
            Logger.info('      - 새 상태: _isBlurred=false');
            Logger.info('      - 새 상태: _blurredSections=[]');

            // 구독 유도 스낵바 표시 (구독자가 아닌 경우만)
            final tokenState = ref.read(tokenProvider);
            SubscriptionSnackbar.showAfterAd(
              context,
              hasUnlimitedAccess: tokenState.hasUnlimitedAccess,
            );

            Logger.info('');
            Logger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            Logger.info('✅ [피해야 할 사람] 블러 해제 프로세스 완료!');
            Logger.info('   → 사용자는 이제 전체 운세 내용을 볼 수 있습니다');
            Logger.info('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
            Logger.info('');
          } else {
            Logger.warning('   ⚠️ Widget이 이미 dispose됨. 블러 해제 취소.');
          }
        },
      );
    } catch (e) {
      Logger.error('');
      Logger.error('❌ [피해야 할 사람] 광고 표시 실패!');
      Logger.error('   에러: $e');
      Logger.error('');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('광고를 불러올 수 없습니다. 잠시 후 다시 시도해주세요.')),
        );
      }
    }
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 👀 무료 미리보기 섹션 (Premium 유도)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildPreviewSection(Map<String, dynamic> data) {
    // severity가 'high'인 것 우선으로 정렬
    final allPeople = _parseCautionPeople(data['cautionPeople']);
    allPeople.sort((a, b) {
      const order = {'high': 0, 'medium': 1, 'low': 2};
      return (order[a.severity] ?? 2).compareTo(order[b.severity] ?? 2);
    });
    final previewPeople = allPeople.take(1).toList();
    final previewObjects = _parseCautionObjects(data['cautionObjects']).take(1).toList();

    if (previewPeople.isEmpty && previewObjects.isEmpty) {
      return const SizedBox.shrink();
    }

    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            children: [
              const Text('👀', style: TextStyle(fontSize: 24)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('오늘의 핵심 경계대상', style: DSTypography.headingSmall),
                    Text('광고 시청 시 8개 카테고리 전체 공개',
                        style: DSTypography.bodySmall.copyWith(color: DSColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // 경계인물 미리보기
          if (previewPeople.isNotEmpty) ...[
            _buildPreviewItem('👤', '경계인물', previewPeople.first),
            const SizedBox(height: 12),
          ],

          // 경계사물 미리보기
          if (previewObjects.isNotEmpty)
            _buildPreviewItem('📦', '경계사물', previewObjects.first),

          const SizedBox(height: 16),

          // 더 보기 유도
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DSColors.accent.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: DSColors.accent.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_open, size: 16, color: DSColors.accent),
                const SizedBox(width: 8),
                Text(
                  '색상, 숫자, 장소, 시간 등 6개 카테고리 더 보기',
                  style: DSTypography.labelMedium.copyWith(color: DSColors.accent),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewItem(String icon, String category, CautionItem item) {
    final severityColor = item.severity == 'high' ? DSColors.error
        : item.severity == 'medium' ? DSColors.warning
        : DSColors.textSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(icon, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 6, height: 6,
                    decoration: BoxDecoration(color: severityColor, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item.title, style: DSTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                item.description,
                style: DSTypography.bodySmall.copyWith(color: DSColors.textSecondary),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 📊 경계지수 점수 표시기
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildScoreIndicator(int score) {
    final color = score >= 70 ? DSColors.error
        : score >= 40 ? DSColors.warning
        : DSColors.success;

    final label = score >= 70 ? '매우 주의'
        : score >= 40 ? '주의 필요'
        : '안전';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '$score',
              style: DSTypography.displayLarge.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text('/100', style: DSTypography.bodySmall.copyWith(color: DSColors.textSecondary)),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(label, style: DSTypography.labelMedium.copyWith(color: color)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: score / 100,
            backgroundColor: DSColors.surface,
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🃏 경계대상 카드 위젯 (공통)
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildCautionCard({
    required String sectionKey,
    required String icon,
    required String title,
    required String subtitle,
    required List<CautionItem> items,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: UnifiedBlurWrapper(
        isBlurred: _isBlurred,
        blurredSections: _blurredSections,
        sectionKey: sectionKey,
        child: GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 헤더
              Row(
                children: [
                  Text(icon, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: DSTypography.headingSmall),
                        Text(subtitle, style: DSTypography.bodySmall.copyWith(color: DSColors.textSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(height: 1),
              const SizedBox(height: 16),
              // 항목 리스트
              ...items.map((item) => _buildCautionItemTile(item)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCautionItemTile(CautionItem item) {
    final severityColor = item.severity == 'high' ? DSColors.error
        : item.severity == 'medium' ? DSColors.warning
        : DSColors.textSecondary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: BoxDecoration(
              color: severityColor,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: DSTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600)),
                if (item.description.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(item.description, style: DSTypography.bodySmall.copyWith(color: DSColors.textSecondary)),
                ],
                if (item.tip.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('💡 ${item.tip}', style: DSTypography.bodySmall.copyWith(color: DSColors.accent)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // ✨ 행운요소 카드
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildLuckyElementsCard(dynamic luckyData) {
    if (luckyData == null) return const SizedBox.shrink();

    final Map<String, dynamic> lucky = luckyData is Map<String, dynamic>
        ? luckyData
        : {};

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: UnifiedBlurWrapper(
        isBlurred: _isBlurred,
        blurredSections: _blurredSections,
        sectionKey: 'luckyElements',
        child: GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('✨', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Text('오늘의 행운 요소', style: DSTypography.headingSmall),
                ],
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (lucky['color'] != null) _buildLuckyChip('🎨', lucky['color']),
                  if (lucky['number'] != null) _buildLuckyChip('🔢', lucky['number']),
                  if (lucky['direction'] != null) _buildLuckyChip('🧭', lucky['direction']),
                  if (lucky['time'] != null) _buildLuckyChip('⏰', lucky['time']),
                  if (lucky['item'] != null) _buildLuckyChip('🎁', lucky['item']),
                  if (lucky['person'] != null) _buildLuckyChip('👤', lucky['person']),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLuckyChip(String icon, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: DSColors.success.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: DSColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 6),
          Text(value, style: DSTypography.labelMedium.copyWith(color: DSColors.success)),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 📅 시간대별 전략 카드
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  Widget _buildTimeStrategyCard(dynamic strategyData) {
    if (strategyData == null) return const SizedBox.shrink();

    final Map<String, dynamic> strategy = strategyData is Map<String, dynamic>
        ? strategyData
        : {};

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: UnifiedBlurWrapper(
        isBlurred: _isBlurred,
        blurredSections: _blurredSections,
        sectionKey: 'timeStrategy',
        child: GlassCard(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text('📅', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 12),
                  Text('시간대별 전략', style: DSTypography.headingSmall),
                ],
              ),
              const SizedBox(height: 16),
              _buildTimeSlot('🌅', '오전', strategy['morning']),
              _buildTimeSlot('☀️', '오후', strategy['afternoon']),
              _buildTimeSlot('🌙', '저녁', strategy['evening']),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTimeSlot(String icon, String label, dynamic data) {
    if (data == null) return const SizedBox.shrink();

    final Map<String, dynamic> slotData = data is Map<String, dynamic> ? data : {};
    final caution = slotData['caution'] as String? ?? '';
    final advice = slotData['advice'] as String? ?? '';

    if (caution.isEmpty && advice.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(icon, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: DSTypography.labelMedium.copyWith(fontWeight: FontWeight.w600)),
                if (caution.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('⚠️ $caution', style: DSTypography.bodySmall.copyWith(color: DSColors.warning)),
                ],
                if (advice.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text('💡 $advice', style: DSTypography.bodySmall.copyWith(color: DSColors.accent)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  // 🔄 데이터 파싱 헬퍼 메서드
  // ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  List<CautionItem> _parseCautionPeople(dynamic data) {
    if (data == null || data is! List) return [];
    return data.map<CautionItem>((item) {
      final map = item as Map<String, dynamic>;
      return CautionItem(
        title: map['type'] as String? ?? '',
        description: map['reason'] as String? ?? '',
        tip: map['tip'] as String? ?? '',
        severity: map['severity'] as String? ?? 'medium',
      );
    }).toList();
  }

  List<CautionItem> _parseCautionObjects(dynamic data) {
    if (data == null || data is! List) return [];
    return data.map<CautionItem>((item) {
      final map = item as Map<String, dynamic>;
      return CautionItem(
        title: map['item'] as String? ?? '',
        description: '${map['reason'] ?? ''} ${map['situation'] != null ? '(${map['situation']})' : ''}',
        tip: map['tip'] as String? ?? '',
        severity: 'medium',
      );
    }).toList();
  }

  List<CautionItem> _parseCautionColors(dynamic data) {
    if (data == null || data is! List) return [];
    return data.map<CautionItem>((item) {
      final map = item as Map<String, dynamic>;
      return CautionItem(
        title: '${map['color'] ?? ''}',
        description: '${map['avoid'] ?? ''} - ${map['reason'] ?? ''}',
        tip: map['alternative'] != null ? '대신 ${map['alternative']}' : '',
        severity: 'medium',
      );
    }).toList();
  }

  List<CautionItem> _parseCautionNumbers(dynamic data) {
    if (data == null || data is! List) return [];
    return data.map<CautionItem>((item) {
      final map = item as Map<String, dynamic>;
      return CautionItem(
        title: '숫자 ${map['number'] ?? ''}',
        description: '${map['avoid'] ?? ''} - ${map['reason'] ?? ''}',
        tip: map['luckyNumber'] != null ? '대신 ${map['luckyNumber']}' : '',
        severity: 'medium',
      );
    }).toList();
  }

  List<CautionItem> _parseCautionAnimals(dynamic data) {
    if (data == null || data is! List) return [];
    return data.map<CautionItem>((item) {
      final map = item as Map<String, dynamic>;
      return CautionItem(
        title: map['animal'] as String? ?? '',
        description: '${map['context'] ?? ''} - ${map['reason'] ?? ''}',
        tip: map['tip'] as String? ?? '',
        severity: 'medium',
      );
    }).toList();
  }

  List<CautionItem> _parseCautionPlaces(dynamic data) {
    if (data == null || data is! List) return [];
    return data.map<CautionItem>((item) {
      final map = item as Map<String, dynamic>;
      return CautionItem(
        title: map['place'] as String? ?? '',
        description: '${map['timeSlot'] != null ? '(${map['timeSlot']}) ' : ''}${map['reason'] ?? ''}',
        tip: map['alternative'] != null ? '대신 ${map['alternative']}' : '',
        severity: 'medium',
      );
    }).toList();
  }

  List<CautionItem> _parseCautionTimes(dynamic data) {
    if (data == null || data is! List) return [];
    return data.map<CautionItem>((item) {
      final map = item as Map<String, dynamic>;
      return CautionItem(
        title: map['time'] as String? ?? '',
        description: '${map['activity'] ?? ''} - ${map['reason'] ?? ''}',
        tip: map['betterTime'] != null ? '대신 ${map['betterTime']}' : '',
        severity: 'high',
      );
    }).toList();
  }

  List<CautionItem> _parseCautionDirections(dynamic data) {
    if (data == null || data is! List) return [];
    return data.map<CautionItem>((item) {
      final map = item as Map<String, dynamic>;
      return CautionItem(
        title: '${map['direction'] ?? ''} 방향',
        description: '${map['avoid'] ?? ''} - ${map['reason'] ?? ''}',
        tip: map['goodDirection'] != null ? '대신 ${map['goodDirection']} 방향' : '',
        severity: 'medium',
      );
    }).toList();
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// 📦 CautionItem 데이터 클래스
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class CautionItem {
  final String title;
  final String description;
  final String tip;
  final String severity; // high, medium, low

  CautionItem({
    required this.title,
    required this.description,
    required this.tip,
    required this.severity,
  });
}
