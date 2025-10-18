import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/components/toss_card.dart';
import '../../domain/models/career_coaching_model.dart';
import '../widgets/standard_fortune_app_bar.dart';
import '../../../../shared/components/floating_bottom_button.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../core/theme/typography_unified.dart';

class CareerCoachingInputPage extends ConsumerStatefulWidget {
  const CareerCoachingInputPage({super.key});

  @override
  ConsumerState<CareerCoachingInputPage> createState() => _CareerCoachingInputPageState();
}

class _CareerCoachingInputPageState extends ConsumerState<CareerCoachingInputPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Step 1: 현재 상황
  String? _currentRole;
  String? _experienceLevel;
  String? _primaryConcern;
  String? _industry;
  
  // Step 2: 목표와 가치
  String? _shortTermGoal;
  String? _coreValue;
  final List<String> _skillsToImprove = [];
  
  bool _isAnalyzing = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep == 0 && _validateStep1()) {
      setState(() {
        _currentStep = 1;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentStep == 1 && _validateStep2()) {
      _analyzeAndShowResult();
    }
  }


  bool _validateStep1() {
    if (_currentRole == null) {
      _showMessage('현재 역할을 선택해주세요');
      return false;
    }
    if (_primaryConcern == null) {
      _showMessage('핵심 고민을 선택해주세요');
      return false;
    }
    return true;
  }

  bool _validateStep2() {
    if (_shortTermGoal == null) {
      _showMessage('단기 목표를 선택해주세요');
      return false;
    }
    if (_coreValue == null) {
      _showMessage('중요한 가치를 선택해주세요');
      return false;
    }
    if (_skillsToImprove.isEmpty) {
      _showMessage('개선하고 싶은 스킬을 최소 1개 선택해주세요');
      return false;
    }
    return true;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: TossDesignSystem.warningOrange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  Future<void> _analyzeAndShowResult() async {
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
      skillsToImprove: _skillsToImprove,
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
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossDesignSystem.gray50,
      appBar: const StandardFortuneAppBar(
        title: '직업 운세',
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Progress indicator
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: _currentStep >= 0
                            ? TossDesignSystem.tossBlue
                            : TossDesignSystem.gray200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 3,
                        decoration: BoxDecoration(
                          color: _currentStep >= 1
                            ? TossDesignSystem.tossBlue
                            : TossDesignSystem.gray200,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 300.ms),

              // Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1(isDark),
                    _buildStep2(isDark),
                  ],
                ),
              ),

              // Bottom spacing for floating button
              const BottomButtonSpacing(),
            ],
          ),

          // Floating bottom button
          FloatingBottomButton(
            text: _currentStep == 1 ? '분석 시작' : '다음',
            onPressed: _nextStep,
            style: TossButtonStyle.primary,
            size: TossButtonSize.large,
          ),
        ],
      ),
    );
  }

  Widget _buildStep1(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                  TossDesignSystem.tossBlue.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: TossDesignSystem.tossBlue,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.work_outline,
                    color: TossDesignSystem.white,
                    size: 28,
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '현재 상황을 알려주세요',
                        style: TossDesignSystem.heading3.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? TossDesignSystem.textPrimaryDark : null,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '맞춤형 직업 전략을 제공해드려요',
                        style: TossDesignSystem.caption.copyWith(
                          color: TossDesignSystem.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),
          
          SizedBox(height: 32),
          
          // 현재 역할
          Text(
            '현재 포지션',
            style: TossDesignSystem.body1.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? TossDesignSystem.textPrimaryDark : null,
            ),
          ),
          const SizedBox(height: 12),
          
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 2.5,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: roleOptions.map((role) => 
              GestureDetector(
                onTap: () => setState(() => _currentRole = role.id),
                child: TossCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  style: _currentRole == role.id ? TossCardStyle.filled : TossCardStyle.outlined,
                  child: Row(
                    children: [
                      Text(role.emoji, style: TypographyUnified.heading3),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              role.title,
                              style: TossDesignSystem.body2.copyWith(
                                fontWeight: _currentRole == role.id 
                                  ? FontWeight.bold 
                                  : FontWeight.normal,
                                color: _currentRole == role.id 
                                  ? TossDesignSystem.tossBlue 
                                  : null,
                              ),
                            ),
                            Text(
                              role.description,
                              style: TossDesignSystem.caption.copyWith(
                                color: TossDesignSystem.gray600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: Duration(milliseconds: 50 * roleOptions.indexOf(role)))
                .fadeIn(duration: 300.ms)
                .slideX(begin: 0.1),
            ).toList(),
          ),
          
          SizedBox(height: 32),
          
          // 핵심 고민
          Text(
            '가장 큰 고민은?',
            style: TossDesignSystem.body1.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? TossDesignSystem.textPrimaryDark : null,
            ),
          ),
          const SizedBox(height: 12),
          
          ...concernCards.map((concern) => 
            GestureDetector(
              onTap: () => setState(() => _primaryConcern = concern.id),
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
                          child: Text(concern.emoji, style: TypographyUnified.displaySmall),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              concern.title,
                              style: TossDesignSystem.body1.copyWith(
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
                              style: TossDesignSystem.caption.copyWith(
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
              ).animate(delay: Duration(milliseconds: 50 * concernCards.indexOf(concern)))
                .fadeIn(duration: 300.ms)
                .slideY(begin: 0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2(bool isDark) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          
          // Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  TossDesignSystem.successGreen.withValues(alpha: 0.1),
                  TossDesignSystem.successGreen.withValues(alpha: 0.05),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: TossDesignSystem.successGreen,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.rocket_launch,
                    color: TossDesignSystem.white,
                    size: 28,
                  ),
                ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '목표와 가치를 들려주세요',
                        style: TossDesignSystem.heading3.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? TossDesignSystem.textPrimaryDark : null,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '성장 로드맵을 설계해드려요',
                        style: TossDesignSystem.caption.copyWith(
                          color: TossDesignSystem.gray600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.2),
          
          SizedBox(height: 32),
          
          // 단기 목표
          Text(
            '3-6개월 내 목표',
            style: TossDesignSystem.body1.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? TossDesignSystem.textPrimaryDark : null,
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: goalOptions.map((goal) =>
              GestureDetector(
                onTap: () => setState(() => _shortTermGoal = goal.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _shortTermGoal == goal.id
                      ? TossDesignSystem.tossBlue
                      : (isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.gray100),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(goal.emoji, style: TypographyUnified.buttonMedium),
                      SizedBox(width: 6),
                      Text(
                        goal.title,
                        style: TossDesignSystem.body2.copyWith(
                          color: _shortTermGoal == goal.id
                            ? TossDesignSystem.white
                            : (isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.gray800),
                          fontWeight: _shortTermGoal == goal.id
                            ? FontWeight.bold
                            : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: Duration(milliseconds: 50 * goalOptions.indexOf(goal)))
                .fadeIn(duration: 300.ms)
                .scale(begin: const Offset(0.9, 0.9)),
            ).toList(),
          ),
          
          SizedBox(height: 32),
          
          // 핵심 가치
          Text(
            '가장 중요한 가치',
            style: TossDesignSystem.body1.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? TossDesignSystem.textPrimaryDark : null,
            ),
          ),
          const SizedBox(height: 12),
          
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: valueOptions.map((value) =>
              GestureDetector(
                onTap: () => setState(() => _coreValue = value.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: _coreValue == value.id
                      ? TossDesignSystem.tossBlue
                      : (isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.gray100),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    value.title,
                    style: TossDesignSystem.body2.copyWith(
                      color: _coreValue == value.id
                        ? TossDesignSystem.white
                        : (isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.gray800),
                      fontWeight: _coreValue == value.id
                        ? FontWeight.bold
                        : FontWeight.normal,
                    ),
                  ),
                ),
              ).animate(delay: Duration(milliseconds: 50 * valueOptions.indexOf(value)))
                .fadeIn(duration: 300.ms)
                .scale(begin: const Offset(0.9, 0.9)),
            ).toList(),
          ),
          
          SizedBox(height: 32),
          
          // 개선하고 싶은 스킬
          Text(
            '개선하고 싶은 스킬 (복수 선택)',
            style: TossDesignSystem.body1.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? TossDesignSystem.textPrimaryDark : null,
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
                    style: TossDesignSystem.caption.copyWith(
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
                          });
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: _skillsToImprove.contains(skill)
                              ? TossDesignSystem.tossBlue.withValues(alpha: 0.1)
                              : (isDark ? TossDesignSystem.cardBackgroundDark : TossDesignSystem.gray100),
                            borderRadius: BorderRadius.circular(16),
                            border: _skillsToImprove.contains(skill)
                              ? Border.all(color: TossDesignSystem.tossBlue, width: 1.5)
                              : null,
                          ),
                          child: Text(
                            skill,
                            style: TossDesignSystem.caption.copyWith(
                              color: _skillsToImprove.contains(skill)
                                ? TossDesignSystem.tossBlue
                                : (isDark ? TossDesignSystem.textPrimaryDark : TossDesignSystem.gray800),
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
            ).animate(delay: Duration(milliseconds: 100 * skillCategories.keys.toList().indexOf(category.key)))
              .fadeIn(duration: 300.ms)
              .slideY(begin: 0.1),
          ),
        ],
      ),
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
              style: TossDesignSystem.heading3.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? TossDesignSystem.textPrimaryDark : null,
              ),
            ).animate()
              .fadeIn(duration: 500.ms)
              .slideY(begin: 0.2),
            
            SizedBox(height: 12),
            
            Text(
              '맞춤형 성장 로드맵을 준비하고 있어요',
              style: TossDesignSystem.body2.copyWith(
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