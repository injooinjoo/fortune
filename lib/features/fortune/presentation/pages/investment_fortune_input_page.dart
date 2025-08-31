import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../domain/models/investment_fortune_model.dart';

class InvestmentFortuneInputPage extends ConsumerStatefulWidget {
  const InvestmentFortuneInputPage({super.key});

  @override
  ConsumerState<InvestmentFortuneInputPage> createState() =>
      _InvestmentFortuneInputPageState();
}

class _InvestmentFortuneInputPageState
    extends ConsumerState<InvestmentFortuneInputPage> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 5;

  // Form data
  InvestmentStyle? _investmentStyle;
  RiskTolerance? _riskTolerance;
  InvestmentGoal? _investmentGoal;
  double _monthlyAmount = 100;
  InvestmentExperience? _experience;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_canProceed()) {
      HapticFeedback.lightImpact();
      if (_currentStep < _totalSteps - 1) {
        setState(() {
          _currentStep++;
        });
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        _submitForm();
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      HapticFeedback.lightImpact();
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _investmentStyle != null;
      case 1:
        return _riskTolerance != null;
      case 2:
        return _investmentGoal != null;
      case 3:
        return true; // Amount is always valid
      case 4:
        return _experience != null;
      default:
        return false;
    }
  }

  void _submitForm() {
    HapticFeedback.mediumImpact();
    final params = InvestmentFortuneParams(
      style: _investmentStyle!,
      riskTolerance: _riskTolerance!,
      goal: _investmentGoal!,
      monthlyAmount: _monthlyAmount,
      experience: _experience!,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => InvestmentFortuneResultPage(params: params),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossTheme.backgroundWhite,
      appBar: AppBar(
        backgroundColor: TossTheme.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: TossTheme.textBlack),
          onPressed: () {
            if (_currentStep > 0) {
              _previousStep();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: _buildProgressBar(),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStyleStep(),
                  _buildRiskStep(),
                  _buildGoalStep(),
                  _buildAmountStep(),
                  _buildExperienceStep(),
                ],
              ),
            ),
            _buildBottomButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return Row(
      children: List.generate(
        _totalSteps,
        (index) => Expanded(
          child: Container(
            height: 3,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              color: index <= _currentStep
                  ? TossTheme.primaryBlue
                  : TossTheme.borderGray200,
            ),
          ).animate(target: index <= _currentStep ? 1 : 0)
            .scaleX(begin: 0.8, end: 1.0, duration: 200.ms),
        ),
      ),
    );
  }

  Widget _buildStyleStep() {
    return _buildStepContainer(
      title: '투자 스타일을\n선택해주세요',
      subtitle: '나와 맞는 투자 방식을 찾아드릴게요',
      child: Column(
        children: InvestmentStyle.values.map((style) {
          final isSelected = _investmentStyle == style;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _investmentStyle = style;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isSelected
                    ? TossTheme.primaryBlue.withOpacity(0.05)
                    : TossTheme.backgroundWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? TossTheme.primaryBlue
                      : TossTheme.borderGray200,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? TossTheme.primaryBlue.withOpacity(0.1)
                          : TossTheme.backgroundSecondary,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getStyleIcon(style),
                      color: isSelected
                          ? TossTheme.primaryBlue
                          : TossTheme.textGray600,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          style.displayName,
                          style: TossTheme.body2.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? TossTheme.primaryBlue
                                : TossTheme.textBlack,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getStyleDescription(style),
                          style: TossTheme.caption.copyWith(
                            color: TossTheme.textGray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: TossTheme.primaryBlue,
                      size: 24,
                    ),
                ],
              ),
            ).animate(delay: (style.index * 100).ms)
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.1, end: 0),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRiskStep() {
    return _buildStepContainer(
      title: '리스크 허용도를\n알려주세요',
      subtitle: '투자 성향을 파악하는데 도움이 됩니다',
      child: Column(
        children: RiskTolerance.values.map((risk) {
          final isSelected = _riskTolerance == risk;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _riskTolerance = risk;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isSelected
                    ? TossTheme.primaryBlue.withOpacity(0.05)
                    : TossTheme.backgroundWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? TossTheme.primaryBlue
                      : TossTheme.borderGray200,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getRiskColor(risk).withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _getRiskIcon(risk),
                      color: _getRiskColor(risk),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          risk.displayName,
                          style: TossTheme.body2.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? TossTheme.primaryBlue
                                : TossTheme.textBlack,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getRiskDescription(risk),
                          style: TossTheme.caption.copyWith(
                            color: TossTheme.textGray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: TossTheme.primaryBlue,
                      size: 24,
                    ),
                ],
              ),
            ).animate(delay: (risk.index * 100).ms)
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.1, end: 0),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildGoalStep() {
    return _buildStepContainer(
      title: '투자 목표가\n무엇인가요?',
      subtitle: '목표에 맞는 전략을 추천해드릴게요',
      child: Column(
        children: InvestmentGoal.values.map((goal) {
          final isSelected = _investmentGoal == goal;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _investmentGoal = goal;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isSelected
                    ? TossTheme.primaryBlue.withOpacity(0.05)
                    : TossTheme.backgroundWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? TossTheme.primaryBlue
                      : TossTheme.borderGray200,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    _getGoalEmoji(goal),
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      goal.displayName,
                      style: TossTheme.body2.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? TossTheme.primaryBlue
                            : TossTheme.textBlack,
                      ),
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: TossTheme.primaryBlue,
                      size: 24,
                    ),
                ],
              ),
            ).animate(delay: (goal.index * 100).ms)
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.1, end: 0),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAmountStep() {
    return _buildStepContainer(
      title: '월 투자 금액은\n얼마인가요?',
      subtitle: '대략적인 금액을 알려주세요',
      child: Column(
        children: [
          const SizedBox(height: 40),
          Text(
            '${_monthlyAmount.toInt()}만원',
            style: TossTheme.heading1.copyWith(
              fontSize: 48,
              fontWeight: FontWeight.w800,
              color: TossTheme.primaryBlue,
            ),
          ).animate()
            .fadeIn(duration: 300.ms)
            .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1)),
          const SizedBox(height: 40),
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: TossTheme.primaryBlue,
              inactiveTrackColor: TossTheme.borderGray200,
              thumbColor: TossTheme.primaryBlue,
              overlayColor: TossTheme.primaryBlue.withOpacity(0.1),
              trackHeight: 6,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
            ),
            child: Slider(
              value: _monthlyAmount,
              min: 10,
              max: 1000,
              divisions: 99,
              onChanged: (value) {
                HapticFeedback.selectionClick();
                setState(() {
                  _monthlyAmount = value;
                });
              },
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '10만원',
                style: TossTheme.caption.copyWith(
                  color: TossTheme.textGray600,
                ),
              ),
              Text(
                '1,000만원',
                style: TossTheme.caption.copyWith(
                  color: TossTheme.textGray600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          // Quick select buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [50, 100, 300, 500].map((amount) {
              final isSelected = _monthlyAmount.toInt() == amount;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() {
                    _monthlyAmount = amount.toDouble();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? TossTheme.primaryBlue
                        : TossTheme.backgroundSecondary,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${amount}만원',
                    style: TossTheme.caption.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? Colors.white
                          : TossTheme.textGray600,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildExperienceStep() {
    return _buildStepContainer(
      title: '투자 경험은\n어느 정도인가요?',
      subtitle: '경험에 맞는 조언을 해드릴게요',
      child: Column(
        children: InvestmentExperience.values.map((exp) {
          final isSelected = _experience == exp;
          return GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() {
                _experience = exp;
              });
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isSelected
                    ? TossTheme.primaryBlue.withOpacity(0.05)
                    : TossTheme.backgroundWhite,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? TossTheme.primaryBlue
                      : TossTheme.borderGray200,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? TossTheme.primaryBlue.withOpacity(0.1)
                          : TossTheme.backgroundSecondary,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      _getExperienceEmoji(exp),
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          exp.displayName,
                          style: TossTheme.body2.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? TossTheme.primaryBlue
                                : TossTheme.textBlack,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _getExperienceDescription(exp),
                          style: TossTheme.caption.copyWith(
                            color: TossTheme.textGray600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isSelected)
                    Icon(
                      Icons.check_circle,
                      color: TossTheme.primaryBlue,
                      size: 24,
                    ),
                ],
              ),
            ).animate(delay: (exp.index * 100).ms)
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.1, end: 0),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStepContainer({
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TossTheme.heading1.copyWith(
              fontSize: 28,
              height: 1.3,
            ),
          ).animate()
            .fadeIn(duration: 400.ms)
            .slideY(begin: -0.1, end: 0),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TossTheme.body3.copyWith(
              color: TossTheme.textGray600,
            ),
          ).animate()
            .fadeIn(duration: 400.ms, delay: 100.ms)
            .slideY(begin: -0.1, end: 0),
          const SizedBox(height: 40),
          child,
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    final canProceed = _canProceed();
    final isLastStep = _currentStep == _totalSteps - 1;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TossTheme.backgroundWhite,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            offset: const Offset(0, -4),
            blurRadius: 12,
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: canProceed ? _nextStep : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: canProceed
                  ? TossTheme.primaryBlue
                  : TossTheme.disabledGray,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              textStyle: TossTheme.button,
            ),
            child: Text(
              isLastStep ? '운세 보기' : '다음',
              style: TossTheme.button.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  IconData _getStyleIcon(InvestmentStyle style) {
    switch (style) {
      case InvestmentStyle.conservative:
        return Icons.shield;
      case InvestmentStyle.balanced:
        return Icons.balance;
      case InvestmentStyle.growth:
        return Icons.trending_up;
      case InvestmentStyle.aggressive:
        return Icons.rocket_launch;
    }
  }

  String _getStyleDescription(InvestmentStyle style) {
    switch (style) {
      case InvestmentStyle.conservative:
        return '안정적이고 꾸준한 수익 추구';
      case InvestmentStyle.balanced:
        return '위험과 수익의 균형';
      case InvestmentStyle.growth:
        return '성장 가능성이 높은 투자';
      case InvestmentStyle.aggressive:
        return '높은 수익률, 높은 위험 감수';
    }
  }

  Color _getRiskColor(RiskTolerance risk) {
    switch (risk) {
      case RiskTolerance.veryLow:
        return TossTheme.success;
      case RiskTolerance.low:
        return TossTheme.primaryBlue;
      case RiskTolerance.medium:
        return TossTheme.warning;
      case RiskTolerance.high:
        return TossTheme.error;
    }
  }

  IconData _getRiskIcon(RiskTolerance risk) {
    switch (risk) {
      case RiskTolerance.veryLow:
        return Icons.security;
      case RiskTolerance.low:
        return Icons.verified_user;
      case RiskTolerance.medium:
        return Icons.warning_amber;
      case RiskTolerance.high:
        return Icons.whatshot;
    }
  }

  String _getRiskDescription(RiskTolerance risk) {
    switch (risk) {
      case RiskTolerance.veryLow:
        return '원금 보존이 최우선';
      case RiskTolerance.low:
        return '작은 손실은 감수 가능';
      case RiskTolerance.medium:
        return '적당한 변동성 허용';
      case RiskTolerance.high:
        return '큰 변동성도 감수';
    }
  }

  String _getGoalEmoji(InvestmentGoal goal) {
    switch (goal) {
      case InvestmentGoal.retirement:
        return '🏖️';
      case InvestmentGoal.house:
        return '🏠';
      case InvestmentGoal.education:
        return '🎓';
      case InvestmentGoal.wealth:
        return '💰';
      case InvestmentGoal.passive:
        return '📈';
    }
  }

  String _getExperienceEmoji(InvestmentExperience exp) {
    switch (exp) {
      case InvestmentExperience.beginner:
        return '🌱';
      case InvestmentExperience.intermediate:
        return '🌿';
      case InvestmentExperience.advanced:
        return '🌳';
      case InvestmentExperience.expert:
        return '🏆';
    }
  }

  String _getExperienceDescription(InvestmentExperience exp) {
    switch (exp) {
      case InvestmentExperience.beginner:
        return '투자를 이제 막 시작';
      case InvestmentExperience.intermediate:
        return '1-3년 정도의 경험';
      case InvestmentExperience.advanced:
        return '3-5년 이상의 경험';
      case InvestmentExperience.expert:
        return '5년 이상의 전문 투자자';
    }
  }
}

// Models (to be added to the appropriate model file)
enum InvestmentStyle {
  conservative,
  balanced,
  growth,
  aggressive,
}

enum RiskTolerance {
  veryLow,
  low,
  medium,
  high,
}

enum InvestmentGoal {
  retirement,
  house,
  education,
  wealth,
  passive,
}

enum InvestmentExperience {
  beginner,
  intermediate,
  advanced,
  expert,
}

extension InvestmentStyleExtension on InvestmentStyle {
  String get displayName {
    switch (this) {
      case InvestmentStyle.conservative:
        return '보수적';
      case InvestmentStyle.balanced:
        return '균형적';
      case InvestmentStyle.growth:
        return '성장형';
      case InvestmentStyle.aggressive:
        return '공격적';
    }
  }
}

extension RiskToleranceExtension on RiskTolerance {
  String get displayName {
    switch (this) {
      case RiskTolerance.veryLow:
        return '매우 낮음';
      case RiskTolerance.low:
        return '낮음';
      case RiskTolerance.medium:
        return '보통';
      case RiskTolerance.high:
        return '높음';
    }
  }
}

extension InvestmentGoalExtension on InvestmentGoal {
  String get displayName {
    switch (this) {
      case InvestmentGoal.retirement:
        return '은퇴 준비';
      case InvestmentGoal.house:
        return '주택 마련';
      case InvestmentGoal.education:
        return '교육 자금';
      case InvestmentGoal.wealth:
        return '자산 증식';
      case InvestmentGoal.passive:
        return '월 수익 창출';
    }
  }
}

extension InvestmentExperienceExtension on InvestmentExperience {
  String get displayName {
    switch (this) {
      case InvestmentExperience.beginner:
        return '입문자';
      case InvestmentExperience.intermediate:
        return '중급자';
      case InvestmentExperience.advanced:
        return '숙련자';
      case InvestmentExperience.expert:
        return '전문가';
    }
  }
}

class InvestmentFortuneParams {
  final InvestmentStyle style;
  final RiskTolerance riskTolerance;
  final InvestmentGoal goal;
  final double monthlyAmount;
  final InvestmentExperience experience;

  const InvestmentFortuneParams({
    required this.style,
    required this.riskTolerance,
    required this.goal,
    required this.monthlyAmount,
    required this.experience,
  });
}

// Result page placeholder (to be implemented next)
class InvestmentFortuneResultPage extends StatelessWidget {
  final InvestmentFortuneParams params;

  const InvestmentFortuneResultPage({
    super.key,
    required this.params,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Result Page - To be implemented'),
      ),
    );
  }
}