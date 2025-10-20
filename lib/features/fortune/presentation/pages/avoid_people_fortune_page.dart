import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/unified_fortune_base_widget.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../domain/models/conditions/avoid_people_fortune_conditions.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../shared/glassmorphism/glass_container.dart';

class AvoidPeopleFortunePage extends ConsumerStatefulWidget {
  const AvoidPeopleFortunePage({super.key});

  @override
  ConsumerState<AvoidPeopleFortunePage> createState() => _AvoidPeopleFortunePageState();
}

class _AvoidPeopleFortunePageState extends ConsumerState<AvoidPeopleFortunePage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  // Step 1
  String _environment = '';
  String _importantSchedule = '';

  // Step 2
  int _moodLevel = 3;
  int _stressLevel = 3;
  int _socialFatigue = 3;

  // Step 3
  bool _hasImportantDecision = false;
  bool _hasSensitiveConversation = false;
  bool _hasTeamProject = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep(VoidCallback onComplete) {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else {
      onComplete();
    }
  }

  bool _canProceed(int step) {
    if (step == 0) return _environment.isNotEmpty && _importantSchedule.isNotEmpty;
    return true;
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

        return Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? TossDesignSystem.tossBlue
                            : TossDesignSystem.gray300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // PageView
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

            // Next/Submit button
            Padding(
              padding: const EdgeInsets.all(20),
              child: TossButton.primary(
                text: _currentStep == 2 ? '분석 시작' : '다음',
                isEnabled: _canProceed(_currentStep),
                onPressed: () => _nextStep(onComplete),
              ),
            ),
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
        final theme = Theme.of(context);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: GlassCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '피해야 할 사람 분석 결과',
                  style: theme.textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),
                Text(
                  result.data['content'] as String? ?? '',
                  style: theme.textTheme.bodyMedium,
                ),
                if (result.score != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    '주의 지수: ${result.score}/100',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: TossDesignSystem.warningOrange,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
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
                      colors: [TossDesignSystem.errorRed, TossDesignSystem.errorRed.withValues(alpha: 0.8)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.location_on_rounded, color: TossDesignSystem.white, size: 32),
                ),
                const SizedBox(height: 16),
                Text('현재 상황 분석', style: TossDesignSystem.heading3.copyWith(
                  color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                )),
                const SizedBox(height: 8),
                Text('오늘 주로 있을 환경과 일정을 알려주세요', style: TossDesignSystem.body2.copyWith(
                  color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                ), textAlign: TextAlign.center),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text('오늘의 주요 환경', style: TossDesignSystem.body1.copyWith(
            color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
            fontWeight: FontWeight.w600,
          )),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['직장', '학교', '모임', '가족', '데이트', '집'].map((env) =>
              _buildChip(env, _environment == env, () => setState(() => _environment = env), isDark),
            ).toList(),
          ),
          const SizedBox(height: 32),
          Text('중요한 일정', style: TossDesignSystem.body1.copyWith(
            color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
            fontWeight: FontWeight.w600,
          )),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['면접', '프레젠테이션', '미팅', '시험', '데이트', '가족모임', '없음'].map((schedule) =>
              _buildChip(schedule, _importantSchedule == schedule, () => setState(() => _importantSchedule = schedule), isDark),
            ).toList(),
          ),
          const SizedBox(height: 80),
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
                      colors: [TossDesignSystem.warningOrange, TossDesignSystem.warningOrange.withValues(alpha: 0.8)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.mood_rounded, color: TossDesignSystem.white, size: 32),
                ),
                const SizedBox(height: 16),
                Text('감정 상태 체크', style: TossDesignSystem.heading3.copyWith(
                  color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                )),
                const SizedBox(height: 8),
                Text('현재 당신의 감정 상태를 평가해주세요', style: TossDesignSystem.body2.copyWith(
                  color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                ), textAlign: TextAlign.center),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildSlider('기분 상태', _moodLevel, (v) => setState(() => _moodLevel = v), isDark),
          const SizedBox(height: 24),
          _buildSlider('스트레스 정도', _stressLevel, (v) => setState(() => _stressLevel = v), isDark),
          const SizedBox(height: 24),
          _buildSlider('사람 만나기 피로도', _socialFatigue, (v) => setState(() => _socialFatigue = v), isDark),
          const SizedBox(height: 80),
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
                      colors: [TossDesignSystem.tossBlue, TossDesignSystem.tossBlue.withValues(alpha: 0.8)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.warning_rounded, color: TossDesignSystem.white, size: 32),
                ),
                const SizedBox(height: 16),
                Text('주의할 상황', style: TossDesignSystem.heading3.copyWith(
                  color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
                )),
                const SizedBox(height: 8),
                Text('오늘 있을 주요 상황을 선택해주세요', style: TossDesignSystem.body2.copyWith(
                  color: isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray600,
                ), textAlign: TextAlign.center),
              ],
            ),
          ),
          const SizedBox(height: 32),
          _buildCheckbox('중요한 결정을 해야 함', _hasImportantDecision, (v) => setState(() => _hasImportantDecision = v!), isDark),
          _buildCheckbox('민감한 대화가 예상됨', _hasSensitiveConversation, (v) => setState(() => _hasSensitiveConversation = v!), isDark),
          _buildCheckbox('팀 프로젝트가 있음', _hasTeamProject, (v) => setState(() => _hasTeamProject = v!), isDark),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildChip(String label, bool isSelected, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? TossDesignSystem.tossBlue.withValues(alpha: 0.1) : Colors.transparent,
          border: Border.all(color: isSelected ? TossDesignSystem.tossBlue : TossDesignSystem.gray300),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label, style: TextStyle(
          color: isSelected ? TossDesignSystem.tossBlue : (isDark ? TossDesignSystem.white : TossDesignSystem.gray900),
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        )),
      ),
    );
  }

  Widget _buildSlider(String label, int value, Function(int) onChanged, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TossDesignSystem.body1.copyWith(
          color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
          fontWeight: FontWeight.w600,
        )),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value.toDouble(),
                min: 1,
                max: 5,
                divisions: 4,
                label: value.toString(),
                onChanged: (v) => onChanged(v.round()),
              ),
            ),
            Container(
              width: 40,
              alignment: Alignment.center,
              child: Text(value.toString(), style: TossDesignSystem.heading2.copyWith(
                color: TossDesignSystem.tossBlue,
              )),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged, bool isDark) {
    return CheckboxListTile(
      title: Text(label, style: TossDesignSystem.body1.copyWith(
        color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
      )),
      value: value,
      onChanged: onChanged,
      contentPadding: EdgeInsets.zero,
    );
  }
}
