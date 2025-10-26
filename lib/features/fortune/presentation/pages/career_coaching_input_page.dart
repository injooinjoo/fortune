import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/components/toss_card.dart';
import '../../domain/models/career_coaching_model.dart';
import '../widgets/standard_fortune_app_bar.dart';
import '../../../../shared/components/toss_floating_progress_button.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/widgets/accordion_input_section.dart';

class CareerCoachingInputPage extends ConsumerStatefulWidget {
  const CareerCoachingInputPage({super.key});

  @override
  ConsumerState<CareerCoachingInputPage> createState() => _CareerCoachingInputPageState();
}

class _CareerCoachingInputPageState extends ConsumerState<CareerCoachingInputPage> {
  // 현재 상황
  String? _currentRole;
  String? _experienceLevel;
  String? _primaryConcern;
  String? _industry;

  // 목표와 가치
  String? _shortTermGoal;
  String? _coreValue;
  final Set<String> _skillsToImprove = {};

  // Accordion sections
  List<AccordionInputSection> _accordionSections = [];

  bool _isAnalyzing = false;

  @override
  void initState() {
    super.initState();
    _initializeAccordionSections();
  }

  void _initializeAccordionSections() {
    _accordionSections = [
      // 1. 현재 포지션
      AccordionInputSection(
        id: 'currentRole',
        title: '현재 포지션',
        icon: Icons.work_outline,
        inputWidgetBuilder: (context, onComplete) => _buildCurrentRoleInput(onComplete),
        value: _currentRole,
        isCompleted: _currentRole != null,
        displayValue: _currentRole != null
            ? roleOptions.firstWhere((role) => role.id == _currentRole).title
            : null,
      ),

      // 2. 핵심 고민
      AccordionInputSection(
        id: 'primaryConcern',
        title: '핵심 고민',
        icon: Icons.psychology_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildPrimaryConcernInput(onComplete),
        value: _primaryConcern,
        isCompleted: _primaryConcern != null,
        displayValue: _primaryConcern != null
            ? concernCards.firstWhere((concern) => concern.id == _primaryConcern).title
            : null,
      ),

      // 3. 단기 목표 (3-6개월)
      AccordionInputSection(
        id: 'shortTermGoal',
        title: '단기 목표 (3-6개월)',
        icon: Icons.rocket_launch,
        inputWidgetBuilder: (context, onComplete) => _buildShortTermGoalInput(onComplete),
        value: _shortTermGoal,
        isCompleted: _shortTermGoal != null,
        displayValue: _shortTermGoal != null
            ? goalOptions.firstWhere((goal) => goal.id == _shortTermGoal).title
            : null,
      ),

      // 4. 핵심 가치
      AccordionInputSection(
        id: 'coreValue',
        title: '핵심 가치',
        icon: Icons.favorite_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildCoreValueInput(onComplete),
        value: _coreValue,
        isCompleted: _coreValue != null,
        displayValue: _coreValue != null
            ? valueOptions.firstWhere((value) => value.id == _coreValue).title
            : null,
      ),

      // 5. 개선하고 싶은 스킬 (다중 선택)
      AccordionInputSection(
        id: 'skillsToImprove',
        title: '개선하고 싶은 스킬',
        icon: Icons.trending_up_rounded,
        inputWidgetBuilder: (context, onComplete) => _buildSkillsToImproveInput(onComplete),
        value: _skillsToImprove.toList(),
        isCompleted: _skillsToImprove.isNotEmpty,
        displayValue: _skillsToImprove.isNotEmpty
            ? _skillsToImprove.join(', ')
            : null,
        isMultiSelect: true, // 다중 선택 - 선택 후에도 닫히지 않음
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
          isCompleted: value != null && (value is! String || value.isNotEmpty) && (value is! List || value.isNotEmpty),
          displayValue: displayValue,
          isMultiSelect: _accordionSections[index].isMultiSelect,
        );
      });
    }
  }

  bool _canGenerate() {
    // 필수: 현재 포지션, 핵심 고민, 단기 목표, 핵심 가치, 개선 스킬 1개 이상
    return _currentRole != null &&
        _primaryConcern != null &&
        _shortTermGoal != null &&
        _coreValue != null &&
        _skillsToImprove.isNotEmpty;
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

    setState(() {
      _isAnalyzing = true;
    });

    // 3초 후 결과 페이지로 이동 (실제로는 API 호출)
    await Future.delayed(const Duration(seconds: 3));

    final input = CareerCoachingInput(
      currentRole: _currentRole!,
      experienceLevel: _experienceLevel ?? 'mid',
      primaryConcern: _primaryConcern!,
      industry: _industry,
      shortTermGoal: _shortTermGoal!,
      coreValue: _coreValue!,
      skillsToImprove: _skillsToImprove.toList(),
    );

    if (mounted) {
      context.pushNamed(
        'career-coaching-result',
        extra: input,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_isAnalyzing) {
      return _buildAnalyzingView(isDark);
    }

    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.white,
      appBar: const StandardFortuneAppBar(
        title: '직업 운세',
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
                    completionButtonText: '분석 시작',
                  ),
            if (_canGenerate())
              TossFloatingProgressButtonPositioned(
                text: '🚀 분석 시작하기',
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
          '맞춤 직업 전략을\n제공해드릴게요',
          style: TypographyUnified.heading1.copyWith(
            fontWeight: FontWeight.w700,
            color: isDark ? TossDesignSystem.white : TossDesignSystem.gray900,
            height: 1.3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '현재 상황과 목표를 분석해서\n최적의 성장 로드맵을 제시해드려요',
          style: TypographyUnified.bodySmall.copyWith(
            color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.gray600,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  // ===== 입력 위젯들 =====

  Widget _buildCurrentRoleInput(Function(dynamic) onComplete) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      children: roleOptions.map((role) =>
        GestureDetector(
          onTap: () {
            setState(() {
              _currentRole = role.id;
              _updateAccordionSection('currentRole', role.id, role.title);
            });
            TossDesignSystem.hapticLight();
            onComplete(role.id);
          },
          child: TossCard(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            style: _currentRole == role.id ? TossCardStyle.filled : TossCardStyle.outlined,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(role.emoji, style: TypographyUnified.heading3),
                const SizedBox(height: 4),
                Text(
                  role.title,
                  style: TypographyUnified.labelMedium.copyWith(
                    fontWeight: _currentRole == role.id
                      ? FontWeight.bold
                      : FontWeight.normal,
                    color: _currentRole == role.id
                      ? TossDesignSystem.tossBlue
                      : null,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ).toList(),
    );
  }

  Widget _buildPrimaryConcernInput(Function(dynamic) onComplete) {
    return Column(
      children: concernCards.map((concern) =>
        GestureDetector(
          onTap: () {
            setState(() {
              _primaryConcern = concern.id;
              _updateAccordionSection('primaryConcern', concern.id, concern.title);
            });
            TossDesignSystem.hapticLight();
            onComplete(concern.id);
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: TossCard(
              padding: const EdgeInsets.all(16),
              style: _primaryConcern == concern.id ? TossCardStyle.filled : TossCardStyle.outlined,
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _primaryConcern == concern.id
                        ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
                        : TossDesignSystem.gray100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(concern.emoji, style: TypographyUnified.heading3),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          concern.title,
                          style: TypographyUnified.bodyMedium.copyWith(
                            fontWeight: _primaryConcern == concern.id
                              ? FontWeight.bold
                              : FontWeight.normal,
                            color: _primaryConcern == concern.id
                              ? TossDesignSystem.tossBlue
                              : null,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          concern.description,
                          style: TypographyUnified.labelSmall.copyWith(
                            color: TossDesignSystem.gray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_primaryConcern == concern.id)
                    Icon(
                      Icons.check_circle,
                      color: TossDesignSystem.tossBlue,
                      size: 24,
                    ),
                ],
              ),
            ),
          ),
        ),
      ).toList(),
    );
  }

  Widget _buildShortTermGoalInput(Function(dynamic) onComplete) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: goalOptions.map((goal) =>
        GestureDetector(
          onTap: () {
            setState(() {
              _shortTermGoal = goal.id;
              _updateAccordionSection('shortTermGoal', goal.id, goal.title);
            });
            TossDesignSystem.hapticLight();
            onComplete(goal.id);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _shortTermGoal == goal.id
                ? TossDesignSystem.tossBlue
                : TossDesignSystem.gray100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(goal.emoji, style: TypographyUnified.buttonSmall),
                SizedBox(width: 6),
                Text(
                  goal.title,
                  style: TypographyUnified.bodySmall.copyWith(
                    color: _shortTermGoal == goal.id
                      ? TossDesignSystem.white
                      : TossDesignSystem.gray800,
                    fontWeight: _shortTermGoal == goal.id
                      ? FontWeight.bold
                      : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ).toList(),
    );
  }

  Widget _buildCoreValueInput(Function(dynamic) onComplete) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: valueOptions.map((value) =>
        GestureDetector(
          onTap: () {
            setState(() {
              _coreValue = value.id;
              _updateAccordionSection('coreValue', value.id, value.title);
            });
            TossDesignSystem.hapticLight();
            onComplete(value.id);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _coreValue == value.id
                ? TossDesignSystem.tossBlue
                : TossDesignSystem.gray100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              value.title,
              style: TypographyUnified.bodySmall.copyWith(
                color: _coreValue == value.id
                  ? TossDesignSystem.white
                  : TossDesignSystem.gray800,
                fontWeight: _coreValue == value.id
                  ? FontWeight.bold
                  : FontWeight.normal,
              ),
            ),
          ),
        ),
      ).toList(),
    );
  }

  Widget _buildSkillsToImproveInput(Function(dynamic) onComplete) {
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
        ...skillCategories.entries.map((category) =>
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.key,
                  style: TypographyUnified.labelMedium.copyWith(
                    color: TossDesignSystem.gray600,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: category.value.map((skill) =>
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          if (_skillsToImprove.contains(skill)) {
                            _skillsToImprove.remove(skill);
                          } else {
                            _skillsToImprove.add(skill);
                          }
                          _updateAccordionSection(
                            'skillsToImprove',
                            _skillsToImprove.toList(),
                            _skillsToImprove.join(', '),
                          );
                        });
                        TossDesignSystem.hapticLight();
                        onComplete(_skillsToImprove.toList());
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _skillsToImprove.contains(skill)
                            ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
                            : TossDesignSystem.gray100,
                          borderRadius: BorderRadius.circular(16),
                          border: _skillsToImprove.contains(skill)
                            ? Border.all(color: TossDesignSystem.tossBlue, width: 1.5)
                            : null,
                        ),
                        child: Text(
                          skill,
                          style: TypographyUnified.labelSmall.copyWith(
                            color: _skillsToImprove.contains(skill)
                              ? TossDesignSystem.tossBlue
                              : TossDesignSystem.gray800,
                            fontWeight: _skillsToImprove.contains(skill)
                              ? FontWeight.bold
                              : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ).toList(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalyzingView(bool isDark) {
    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.gray50,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    TossDesignSystem.tossBlue,
                    TossDesignSystem.successGreen,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: TossDesignSystem.white,
                size: 48,
              ),
            ).animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 2000.ms, color: TossDesignSystem.white.withValues(alpha: 0.3))
              .rotate(duration: 3000.ms),

            SizedBox(height: 32),

            Text(
              '직업 전략 분석 중...',
              style: TypographyUnified.heading3.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? TossDesignSystem.textPrimaryDark : null,
              ),
            ).animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.2),

            SizedBox(height: 12),

            Text(
              '맞춤형 성장 로드맵을 준비하고 있어요',
              style: TypographyUnified.bodyMedium.copyWith(
                color: TossDesignSystem.gray600,
              ),
            ).animate(delay: 200.ms)
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.2),

            const SizedBox(height: 40),

            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                backgroundColor: TossDesignSystem.gray200,
                valueColor: AlwaysStoppedAnimation<Color>(TossDesignSystem.tossBlue),
              ),
            ).animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 1500.ms, color: TossDesignSystem.tossBlue.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }
}
