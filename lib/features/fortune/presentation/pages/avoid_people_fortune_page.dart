import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/unified_fortune_base_widget.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../domain/models/conditions/avoid_people_fortune_conditions.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/components/app_card.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../services/ad_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/widgets/unified_blur_wrapper.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/utils/fortune_text_cleaner.dart';
import 'package:flutter/services.dart'; // ✅ HapticFeedback

class AvoidPeopleFortunePage extends ConsumerStatefulWidget {
  const AvoidPeopleFortunePage({super.key});

  @override
  ConsumerState<AvoidPeopleFortunePage> createState() => _AvoidPeopleFortunePageState();
}

class _AvoidPeopleFortunePageState extends ConsumerState<AvoidPeopleFortunePage> {
  // ✅ PageView Controller
  final PageController _pageController = PageController();

  // ✅ 단계별 상태 (0: 환경, 1: 일정, 2: 기분, 3: 상황)
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
      title: '피해야 할 사람',
      description: '오늘 주의해야 할 사람 유형을 분석해드립니다',
      dataSource: FortuneDataSource.api,
      inputBuilder: (context, onComplete) {
        final isDark = Theme.of(context).brightness == Brightness.dark;

        return Stack(
          children: [
            // ✅ PageView로 단계별 입력
            Column(
              children: [
                // ✅ Step Indicator
                _buildStepIndicator(isDark),

                // ✅ PageView
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
        Logger.info('');
        Logger.info('🔍━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        Logger.info('🔍 [resultBuilder] 호출됨!');
        Logger.info('🔍━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        Logger.info('   📥 result.isBlurred: ${result.isBlurred}');
        Logger.info('   📦 result.blurredSections: ${result.blurredSections}');
        Logger.info('   📱 페이지 _isBlurred: $_isBlurred');
        Logger.info('   📱 페이지 _blurredSections: $_blurredSections');
        Logger.info('   🔒 _hasInitializedBlur: $_hasInitializedBlur');
        Logger.info('');

        // ✅ Blur 상태 초기화 (최초 한 번만!)
        // 조건: 아직 초기화되지 않았고 && result가 블러 상태일 때
        if (!_hasInitializedBlur && result.isBlurred == true) {
          Logger.info('   ✅ 조건 만족: !_hasInitializedBlur && result.isBlurred=true');
          Logger.info('   → 블러 상태를 result에서 가져옴 (최초 초기화)');
          Logger.info('   → PostFrameCallback 등록 중...');

          // 운세 생성 직후에만 result의 블러 상태를 가져옴
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Logger.info('');
            Logger.info('   🔄 [PostFrameCallback] 실행됨');
            Logger.info('      - mounted: $mounted');

            if (mounted) {
              Logger.info('      → setState 호출 중...');
              Logger.info('         이전 _isBlurred: $_isBlurred');
              Logger.info('         이전 _blurredSections: $_blurredSections');
              Logger.info('         이전 _hasInitializedBlur: $_hasInitializedBlur');

              setState(() {
                _isBlurred = result.isBlurred;
                _blurredSections = result.isBlurred
                    ? ['people_types', 'situation_tips', 'advice']
                    : [];
                _hasInitializedBlur = true; // ✅ 초기화 완료 플래그
              });

              Logger.info('         새 _isBlurred: $_isBlurred');
              Logger.info('         새 _blurredSections: $_blurredSections');
              Logger.info('         새 _hasInitializedBlur: $_hasInitializedBlur');
              Logger.info('      ✅ setState 완료!');
            } else {
              Logger.warning('      ⚠️ Widget이 이미 dispose됨. setState 스킵.');
            }
            Logger.info('');
          });

          Logger.info('   ✅ PostFrameCallback 등록 완료');
        } else {
          Logger.info('   ❌ 조건 불만족: _isBlurred를 변경하지 않음');
          Logger.info('      - _hasInitializedBlur=$_hasInitializedBlur');
          Logger.info('      - _isBlurred=$_isBlurred 유지 (사용자가 광고로 해제했을 수 있음)');
          Logger.info('      - result.isBlurred=${result.isBlurred} (DB에 저장된 원본 상태)');
          Logger.info('');
          Logger.info('   💡 해석:');
          if (_hasInitializedBlur) {
            Logger.info('      → 이미 초기화됨. 사용자 액션(광고 해제) 보호!');
          } else if (result.isBlurred == false) {
            Logger.info('      → 프리미엄 사용자 OR DB에 이미 블러 해제된 결과 저장됨');
          }
        }

        Logger.info('🔍━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
        Logger.info('');

        // ❌ result.isBlurred로 _isBlurred를 계속 덮어쓰지 않음!
        // _hasInitializedBlur 플래그로 최초 1회만 동기화
        // 사용자가 광고를 보고 블러를 해제하면 _isBlurred는 false로 유지됨

        final content = FortuneTextCleaner.cleanNullable(result.data['content'] as String?);

        return Stack(
          children: [
            // ✅ 중앙 정렬 + 반응형 레이아웃
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24).copyWith(bottom: 100),
                  child: Column(
                    children: [
                      // 섹션 1: 주의 지수 + 종합 요약 (무료)
                      GlassCard(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '피해야 할 사람 분석 결과',
                              style: context.heading2,
                            ),
                            if (result.score != null) ...[
                              const SizedBox(height: 16),
                              Text(
                                '주의 지수: ${result.score}/100',
                                style: context.heading3.copyWith(
                                  color: TossDesignSystem.warningOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                            const SizedBox(height: 16),
                            Text(
                              content.split('\n\n').first,
                              style: context.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 섹션 2: 피해야 할 사람 유형 (Premium)
                      UnifiedBlurWrapper(
                        isBlurred: _isBlurred,
                        blurredSections: _blurredSections,
                        sectionKey: 'people_types',
                        child: GlassCard(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.person_off, color: TossDesignSystem.errorRed, size: 28),
                                  const SizedBox(width: 12),
                                  Text(
                                    '피해야 할 사람 유형',
                                    style: context.heading3,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                FortuneTextCleaner.clean(result.data['people_types'] as String? ?? '오늘 특별히 주의해야 할 사람 유형 정보'),
                                style: context.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 섹션 3: 상황별 대처 방법 (Premium)
                      UnifiedBlurWrapper(
                        isBlurred: _isBlurred,
                        blurredSections: _blurredSections,
                        sectionKey: 'situation_tips',
                        child: GlassCard(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.lightbulb, color: TossDesignSystem.tossBlue, size: 28),
                                  const SizedBox(width: 12),
                                  Text(
                                    '상황별 대처 방법',
                                    style: context.heading3,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                FortuneTextCleaner.clean(result.data['situation_tips'] as String? ?? '상황별 대처 방법 정보'),
                                style: context.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 섹션 4: 오늘의 조언 (Premium)
                      UnifiedBlurWrapper(
                        isBlurred: _isBlurred,
                        blurredSections: _blurredSections,
                        sectionKey: 'advice',
                        child: GlassCard(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.tips_and_updates, color: TossDesignSystem.successGreen, size: 28),
                                  const SizedBox(width: 12),
                                  Text(
                                    '오늘의 조언',
                                    style: context.heading3,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                FortuneTextCleaner.clean(result.data['advice'] as String? ?? '오늘의 조언 정보'),
                                style: context.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 100), // 버튼 공간
                    ],
                  ),
                ),
              ),
            ),

            // ✅ FloatingBottomButton (블러 상태일 때만 표시)
            if (_isBlurred)
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

  // ===== Step Indicator =====
  Widget _buildStepIndicator(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;

          return Row(
            children: [
              Container(
                width: isActive ? 32 : 24,
                height: 8,
                decoration: BoxDecoration(
                  color: isCompleted || isActive
                      ? TossDesignSystem.tossBlue
                      : (isDark ? TossDesignSystem.gray600 : TossDesignSystem.gray300),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              if (index < 3) const SizedBox(width: 8),
            ],
          );
        }),
      ),
    );
  }

  // ===== Step 1: 환경 선택 =====
  Widget _buildStep1Environment(bool isDark) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24).copyWith(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 아이콘
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      TossDesignSystem.warningOrange,
                      TossDesignSystem.warningOrange.withValues(alpha: 0.8)
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.people_outline_rounded,
                    color: TossDesignSystem.white, size: 40),
              ),
              const SizedBox(height: 24),

              // 제목
              Text(
                '오늘의 주요 환경',
                style: context.heading2.copyWith(
                  color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                ),
              ),
              const SizedBox(height: 12),

              // 설명
              Text(
                '현재 상태와 일정을 입력하면\n오늘 주의해야 할 사람 유형을 분석해드립니다',
                style: context.bodyMedium.copyWith(
                  color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // 환경 선택
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: ['직장', '학교', '모임', '가족', '데이트', '집']
                    .map((env) => _buildChip(
                        env, _environment == env, () {
                          setState(() => _environment = env);
                          HapticFeedback.selectionClick();
                        }, isDark))
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
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24).copyWith(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 아이콘
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      TossDesignSystem.tossBlue,
                      TossDesignSystem.tossBlue.withValues(alpha: 0.8)
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.event_note,
                    color: TossDesignSystem.white, size: 40),
              ),
              const SizedBox(height: 24),

              // 제목
              Text(
                '중요한 일정',
                style: context.heading2.copyWith(
                  color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                ),
              ),
              const SizedBox(height: 12),

              // 설명
              Text(
                '오늘 예정된 중요한 일정을 선택해주세요',
                style: context.bodyMedium.copyWith(
                  color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // 일정 선택
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: ['면접', '프레젠테이션', '미팅', '시험', '데이트', '가족모임', '없음']
                    .map((schedule) => _buildChip(schedule, _importantSchedule == schedule,
                        () {
                          setState(() => _importantSchedule = schedule);
                          HapticFeedback.selectionClick();
                        }, isDark))
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
              // 아이콘
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      TossDesignSystem.successGreen,
                      TossDesignSystem.successGreen.withValues(alpha: 0.8)
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.mood,
                    color: TossDesignSystem.white, size: 40),
              ),
              const SizedBox(height: 24),

              // 제목
              Text(
                '현재 상태',
                style: context.heading2.copyWith(
                  color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                ),
              ),
              const SizedBox(height: 12),

              // 설명
              Text(
                '현재 기분과 상태를 솔직하게 알려주세요',
                style: context.bodyMedium.copyWith(
                  color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // 슬라이더들
              _buildSlider('기분 상태', _moodLevel, (v) => setState(() => _moodLevel = v), isDark),
              const SizedBox(height: 32),
              _buildSlider('스트레스 정도', _stressLevel, (v) => setState(() => _stressLevel = v), isDark),
              const SizedBox(height: 32),
              _buildSlider('사람 만나기 피로도', _socialFatigue,
                  (v) => setState(() => _socialFatigue = v), isDark),
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
              // 아이콘
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      TossDesignSystem.errorRed,
                      TossDesignSystem.errorRed.withValues(alpha: 0.8)
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: TossDesignSystem.white, size: 40),
              ),
              const SizedBox(height: 24),

              // 제목
              Text(
                '주의할 상황',
                style: context.heading2.copyWith(
                  color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                ),
              ),
              const SizedBox(height: 12),

              // 설명
              Text(
                '오늘 예상되는 특별한 상황이 있나요?',
                style: context.bodyMedium.copyWith(
                  color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // 체크박스
              AppCard(
                style: AppCardStyle.elevated,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildCheckbox('중요한 결정을 해야 함', _hasImportantDecision,
                        (v) => setState(() => _hasImportantDecision = v!), isDark),
                    const Divider(height: 1),
                    _buildCheckbox('민감한 대화가 예상됨', _hasSensitiveConversation,
                        (v) => setState(() => _hasSensitiveConversation = v!), isDark),
                    const Divider(height: 1),
                    _buildCheckbox('팀 프로젝트가 있음', _hasTeamProject,
                        (v) => setState(() => _hasTeamProject = v!), isDark),
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
    if (_currentStep < 3) {
      // 다음 버튼
      return UnifiedButton.floating(
        text: _currentStep == 0
            ? (_environment.isEmpty ? '환경을 선택해주세요' : '다음')
            : _currentStep == 1
                ? (_importantSchedule.isEmpty ? '일정을 선택해주세요' : '다음')
                : '다음',
        onPressed: () {
          if (_currentStep == 0 && _environment.isEmpty) return;
          if (_currentStep == 1 && _importantSchedule.isEmpty) return;
          _nextStep();
        },
        isEnabled: _currentStep == 0
            ? _environment.isNotEmpty
            : _currentStep == 1
                ? _importantSchedule.isNotEmpty
                : true,
      );
    } else {
      // 완료 버튼
      return UnifiedButton.floating(
        text: '오늘 피해야 할 사람 확인하기',
        onPressed: onComplete,
        isEnabled: _canSubmit,
      );
    }
  }

  // ===== Chip =====
  Widget _buildChip(String label, bool isSelected, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? TossDesignSystem.tossBlue.withValues(alpha: 0.15) : Colors.transparent,
          border: Border.all(
            color: isSelected ? TossDesignSystem.tossBlue : (isDark ? TossDesignSystem.gray600 : TossDesignSystem.gray300),
            width: 2,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: context.buttonMedium.copyWith(
            color: isSelected
                ? TossDesignSystem.tossBlue
                : (isDark ? TossDesignSystem.white : TossDesignSystem.gray900),
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ===== Slider =====
  Widget _buildSlider(String label, int value, Function(int) onChanged, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: context.heading4.copyWith(
            color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: value.toString(),
                onChanged: (v) {
                  onChanged(v.round());
                  HapticFeedback.selectionClick();
                },
                activeColor: TossDesignSystem.tossBlue,
              ),
            ),
            const SizedBox(width: 16),
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: TossDesignSystem.tossBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                value.toString(),
                style: context.numberMedium.copyWith(
                  color: TossDesignSystem.tossBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ===== Checkbox =====
  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged, bool isDark) {
    return CheckboxListTile(
      title: Text(
        label,
        style: context.bodyLarge.copyWith(
          color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
        ),
      ),
      value: value,
      onChanged: (v) {
        onChanged(v);
        HapticFeedback.selectionClick();
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      activeColor: TossDesignSystem.tossBlue,
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
        onUserEarnedReward: (ad, reward) {
          Logger.info('');
          Logger.info('3️⃣ 광고 시청 완료!');
          Logger.info('   - reward.type: ${reward.type}');
          Logger.info('   - reward.amount: ${reward.amount}');

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

            // 성공 메시지 표시
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('운세가 잠금 해제되었습니다!')),
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
}
