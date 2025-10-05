import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;

import '../../../../domain/entities/fortune.dart';
import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/components/toast.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../shared/components/toss_button.dart';
import '../../../../core/components/toss_card.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/components/floating_bottom_button.dart';
import '../widgets/fortune_button.dart';
import '../constants/fortune_button_spacing.dart';
import '../../../../services/ad_service.dart';

// Step 관리를 위한 StateNotifier
class InvestmentStepNotifier extends StateNotifier<int> {
  InvestmentStepNotifier() : super(0);
  
  void nextStep() {
    if (state < 3) state++;
  }
  
  void previousStep() {
    if (state > 0) state--;
  }
  
  void setStep(int step) {
    state = step.clamp(0, 3);
  }
}

final investmentStepProvider = StateNotifierProvider<InvestmentStepNotifier, int>((ref) {
  return InvestmentStepNotifier();
});

// 투자 섹터 정의
enum InvestmentSector {
  stocks('주식', '국내/해외 주식', Icons.trending_up_rounded, [Color(0xFF059669), Color(0xFF047857)]),
  realestate('부동산', '아파트, 오피스텔, 토지', Icons.home_rounded, [Color(0xFF0284C7), Color(0xFF0369A1)]),
  crypto('암호화폐', '비트코인, 알트코인', Icons.currency_bitcoin_rounded, [Color(0xFFF59E0B), Color(0xFFEAB308)]),
  auction('경매', '부동산/물품 경매', Icons.gavel_rounded, [Color(0xFFEF4444), Color(0xFFDC2626)]),
  lottery('로또', '로또 번호 추천', Icons.confirmation_number_rounded, [Color(0xFFFFB300), Color(0xFFF57C00)]),
  funds('펀드/ETF', '인덱스, 섹터별 펀드', Icons.account_balance_rounded, [Color(0xFF7C3AED), Color(0xFF6D28D9)]),
  gold('금/원자재', '금, 은, 원유', Icons.diamond_rounded, [Color(0xFFF59E0B), Color(0xFFEAB308)]),
  bonds('채권', '국채, 회사채', Icons.article_rounded, [Color(0xFF475569), Color(0xFF334155)]),
  startup('스타트업', '크라우드펀딩', Icons.rocket_launch_rounded, [Color(0xFF3B82F6), Color(0xFF2563EB)]),
  art('예술품/NFT', 'NFT, 미술품, 명품', Icons.palette_rounded, [Color(0xFF8B5CF6), Color(0xFF7C3AED)]);
  
  final String label;
  final String description;
  final IconData icon;
  final List<Color> gradientColors;
  
  const InvestmentSector(this.label, this.description, this.icon, this.gradientColors);
}

// 데이터 모델
class InvestmentFortuneData {
  // Step 1: 투자 프로필
  String? riskTolerance; // conservative, moderate, aggressive
  String? investmentExperience; // beginner, intermediate, expert
  double? currentAssets; // 현재 자산 규모
  String? investmentGoal; // wealth, stability, speculation
  int? investmentHorizon; // 투자 기간 (개월)
  
  // Step 2: 관심 섹터
  List<String> selectedSectors = [];
  Map<String, double> sectorPriorities = {};
  
  // Step 3: 상세 분석
  bool wantPortfolioReview = false;
  bool wantMarketTiming = false;
  bool wantLuckyNumbers = false;
  bool wantRiskAnalysis = true;
  String? specificQuestion;
  
  // 사용자 정보
  String? userId;
  String? name;
  DateTime? birthDate;
  String? gender;
  String? birthTime;
}

final investmentDataProvider = StateProvider<InvestmentFortuneData>((ref) {
  return InvestmentFortuneData();
});

class InvestmentFortuneEnhancedPage extends ConsumerStatefulWidget {
  const InvestmentFortuneEnhancedPage({Key? key}) : super(key: key);

  @override
  ConsumerState<InvestmentFortuneEnhancedPage> createState() => _InvestmentFortuneEnhancedPageState();
}

class _InvestmentFortuneEnhancedPageState extends ConsumerState<InvestmentFortuneEnhancedPage> 
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  
  late AnimationController _fadeController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this);
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.95,
      end: 1.0).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutBack,
    ));
    
    // Start animations
    _fadeController.forward();
    _scaleController.forward();
    
    // Initialize user data
    _initializeUserData();
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
  
  void _initializeUserData() {
    final userProfile = ref.read(userProfileProvider).value;
    if (userProfile != null) {
      final data = ref.read(investmentDataProvider);
      data.userId = userProfile.id;
      data.name = userProfile.name;
      data.birthDate = userProfile.birthDate;
      data.gender = userProfile.gender;
      data.birthTime = userProfile.birthTime;
    } else {
      // 테스트용 임시 사용자 데이터
      final data = ref.read(investmentDataProvider);
      data.userId = 'test-user-123';
      data.name = '테스트 사용자';
      data.birthDate = DateTime(1990, 1, 1);
      data.gender = 'M';
      data.birthTime = '09:00';
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final currentStep = ref.watch(investmentStepProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.grayDark50 : TossDesignSystem.gray50,
      appBar: AppHeader(
        title: '투자 운세',
        showBackButton: true,
        centerTitle: true,
        onBackPressed: () {
          if (currentStep > 0) {
            ref.read(investmentStepProvider.notifier).previousStep();
            _pageController.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          } else {
            context.pop();
          }
        },
      ),
      body: Stack(
        children: [
          Column(
            children: [
              // Step indicator
              _buildStepIndicator(currentStep),

              // Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _buildStep1(),
                    _buildStep2(),
                    _buildStep3(),
                    _buildStep4(),
                  ],
                ),
              ),

              // Bottom spacing for floating button
              const BottomButtonSpacing(),
            ],
          ),

          // Floating bottom button
          _buildFloatingBottomButton(context, currentStep),
        ],
      ),
    );
  }
  
  
  Widget _buildStepIndicator(int currentStep) {
    final steps = ['투자 프로필', '관심 섹터', '상세 분석', '운세 보기'];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.grayDark100 : TossDesignSystem.white,
        borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
        boxShadow: [
          BoxShadow(
            color: TossDesignSystem.gray900.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index == currentStep;
          final isCompleted = index < currentStep;

          return Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    if (index > 0)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: isCompleted
                                ? TossDesignSystem.tossBlue
                                : isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive || isCompleted
                            ? TossDesignSystem.tossBlue
                            : isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
                        boxShadow: isActive || isCompleted
                            ? [
                                BoxShadow(
                                  color: TossDesignSystem.tossBlue.withValues(alpha: 0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : [],
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                size: 18,
                                color: TossDesignSystem.white,
                              )
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isActive
                                      ? TossDesignSystem.white
                                      : isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray500,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                      ),
                    ),
                    if (index < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: isCompleted && index < currentStep - 1
                                ? TossDesignSystem.tossBlue
                                : isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
                            borderRadius: BorderRadius.circular(1),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  steps[index],
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                    color: isActive
                        ? TossDesignSystem.tossBlue
                        : isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
  
  Widget _buildFloatingBottomButton(BuildContext context, int currentStep) {
    final data = ref.watch(investmentDataProvider);
    final isValid = _validateStep(currentStep, data);

    if (currentStep == 3) {
      return FloatingBottomButton(
        text: '💰 나의 투자 운명 확인하기',
        onPressed: isValid ? _generateFortune : null,
        isEnabled: isValid,
        isLoading: false,
        style: TossButtonStyle.primary,
      );
    } else {
      return FloatingBottomButton(
        text: '다음',
        onPressed: isValid
            ? () {
                ref.read(investmentStepProvider.notifier).nextStep();
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            : null,
        isEnabled: isValid,
        style: TossButtonStyle.primary,
      );
    }
  }
  
  bool _validateStep(int step, InvestmentFortuneData data) {
    switch (step) {
      case 0:
        return data.riskTolerance != null &&
               data.investmentExperience != null &&
               data.investmentGoal != null;
      case 1:
        return data.selectedSectors.isNotEmpty;
      case 2:
        return true; // Step 3 is optional
      case 3:
        return true; // Ready to generate
    default:
        return false;
    }
  }
  
  // Step 1: 투자 프로필
  Widget _buildStep1() {
    final data = ref.watch(investmentDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              TossCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                TossDesignSystem.tossBlue,
                                TossDesignSystem.tossBlue.withValues(alpha: 0.8),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.trending_up_rounded,
                            color: TossDesignSystem.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '투자 성향을 알려주세요',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '맞춤형 투자 운세를 위해 필요합니다',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Risk tolerance
              _buildSectionCard('위험 성향', _buildRiskToleranceSelector(data)),
              const SizedBox(height: 16),

              // Investment experience
              _buildSectionCard('투자 경험', _buildExperienceSelector(data)),
              const SizedBox(height: 16),

              // Investment goal
              _buildSectionCard('투자 목표', _buildGoalSelector(data)),
              const SizedBox(height: 16),

              // Investment horizon
              _buildSectionCard('투자 기간', _buildHorizonSelector(data)),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionCard(String title, Widget child) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TossCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
            ),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
  
  Widget _buildRiskToleranceSelector(InvestmentFortuneData data) {
    final options = [
      {'value': 'conservative', 'label': '안정형', 'description': '원금 보존 중시'},
      {'value': 'moderate', 'label': '중립형', 'description': '균형잡힌 수익과 안정'},
      {'value': 'aggressive', 'label': '공격형', 'description': '높은 수익 추구'},
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: options.map((option) {
        final isSelected = data.riskTolerance == option['value'];

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GestureDetector(
            onTap: () {
              print('🎯 위험 감수도 선택: ${option['value']}');
              ref.read(investmentDataProvider.notifier).update((state) {
                final newData = InvestmentFortuneData()
                  ..userId = state.userId
                  ..name = state.name
                  ..birthDate = state.birthDate
                  ..gender = state.gender
                  ..birthTime = state.birthTime
                  ..riskTolerance = option['value'] as String
                  ..investmentExperience = state.investmentExperience
                  ..investmentGoal = state.investmentGoal
                  ..investmentHorizon = state.investmentHorizon
                  ..selectedSectors = List.from(state.selectedSectors)
                  ..sectorPriorities = Map.from(state.sectorPriorities)
                  ..wantPortfolioReview = state.wantPortfolioReview
                  ..wantMarketTiming = state.wantMarketTiming
                  ..wantLuckyNumbers = state.wantLuckyNumbers
                  ..wantRiskAnalysis = state.wantRiskAnalysis
                  ..specificQuestion = state.specificQuestion;
                print('🔄 상태 업데이트 완료: riskTolerance = ${newData.riskTolerance}');
                return newData;
              });
            },
            child: TossCard(
              style: TossCardStyle.outlined,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: isSelected
                        ? TossDesignSystem.tossBlue
                        : Colors.transparent,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
                  color: isSelected
                      ? TossDesignSystem.tossBlue.withValues(alpha: 0.08)
                      : Colors.transparent,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? TossDesignSystem.tossBlue
                              : isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray400,
                          width: 2,
                        ),
                        color: isSelected ? TossDesignSystem.tossBlue : Colors.transparent,
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 12,
                              color: TossDesignSystem.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option['label'] as String? ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? TossDesignSystem.tossBlue
                                  : isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            option['description'] as String? ?? '',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildExperienceSelector(InvestmentFortuneData data) {
    final options = [
      {'value': 'beginner', 'label': '초보자', 'description': '1년 미만'},
      {'value': 'intermediate', 'label': '중급자', 'description': '1-5년'},
      {'value': 'expert', 'label': '전문가', 'description': '5년 이상'},
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((option) {
        final isSelected = data.investmentExperience == option['value'];

        return GestureDetector(
          onTap: () {
            ref.read(investmentDataProvider.notifier).update((state) {
              return InvestmentFortuneData()
                ..userId = state.userId
                ..name = state.name
                ..birthDate = state.birthDate
                ..gender = state.gender
                ..birthTime = state.birthTime
                ..riskTolerance = state.riskTolerance
                ..investmentExperience = option['value'] as String
                ..investmentGoal = state.investmentGoal
                ..investmentHorizon = state.investmentHorizon
                ..selectedSectors = List.from(state.selectedSectors)
                ..sectorPriorities = Map.from(state.sectorPriorities)
                ..wantPortfolioReview = state.wantPortfolioReview
                ..wantMarketTiming = state.wantMarketTiming
                ..wantLuckyNumbers = state.wantLuckyNumbers
                ..wantRiskAnalysis = state.wantRiskAnalysis
                ..specificQuestion = state.specificQuestion;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? TossDesignSystem.tossBlue
                  : isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray100,
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? Border.all(color: TossDesignSystem.tossBlue, width: 2)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: TossDesignSystem.tossBlue.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  option['label'] as String? ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? TossDesignSystem.white
                        : isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  option['description'] as String? ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: isSelected
                        ? TossDesignSystem.white.withValues(alpha: 0.9)
                        : isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildGoalSelector(InvestmentFortuneData data) {
    final options = [
      {'value': 'wealth', 'label': '자산 증식', 'icon': Icons.trending_up_rounded},
      {'value': 'stability', 'label': '안정적 수익', 'icon': Icons.shield_rounded},
      {'value': 'speculation', 'label': '단기 수익', 'icon': Icons.flash_on_rounded},
      {'value': 'retirement', 'label': '노후 준비', 'icon': Icons.home_rounded},
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: options.map((option) {
        final isSelected = data.investmentGoal == option['value'];

        return GestureDetector(
          onTap: () {
            ref.read(investmentDataProvider.notifier).update((state) {
              return InvestmentFortuneData()
                ..userId = state.userId
                ..name = state.name
                ..birthDate = state.birthDate
                ..gender = state.gender
                ..birthTime = state.birthTime
                ..riskTolerance = state.riskTolerance
                ..investmentExperience = state.investmentExperience
                ..investmentGoal = option['value'] as String
                ..investmentHorizon = state.investmentHorizon
                ..selectedSectors = List.from(state.selectedSectors)
                ..sectorPriorities = Map.from(state.sectorPriorities)
                ..wantPortfolioReview = state.wantPortfolioReview
                ..wantMarketTiming = state.wantMarketTiming
                ..wantLuckyNumbers = state.wantLuckyNumbers
                ..wantRiskAnalysis = state.wantRiskAnalysis
                ..specificQuestion = state.specificQuestion;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        TossDesignSystem.tossBlue,
                        TossDesignSystem.tossBlue.withValues(alpha: 0.8),
                      ],
                    )
                  : null,
              color: !isSelected
                  ? isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray100
                  : null,
              borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
              border: isSelected
                  ? Border.all(color: TossDesignSystem.tossBlue, width: 2)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: TossDesignSystem.tossBlue.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  option['icon'] as IconData? ?? Icons.help_rounded,
                  size: 32,
                  color: isSelected
                      ? TossDesignSystem.white
                      : isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                ),
                const SizedBox(height: 8),
                Text(
                  option['label'] as String? ?? '',
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected
                        ? TossDesignSystem.white
                        : isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
  
  Widget _buildHorizonSelector(InvestmentFortuneData data) {
    final horizons = [
      {'months': 3, 'label': '3개월'},
      {'months': 6, 'label': '6개월'},
      {'months': 12, 'label': '1년'},
      {'months': 36, 'label': '3년'},
      {'months': 60, 'label': '5년 이상'},
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: horizons.map((horizon) {
        final isSelected = data.investmentHorizon == horizon['months'];

        return GestureDetector(
          onTap: () {
            ref.read(investmentDataProvider.notifier).update((state) {
              return InvestmentFortuneData()
                ..userId = state.userId
                ..name = state.name
                ..birthDate = state.birthDate
                ..gender = state.gender
                ..birthTime = state.birthTime
                ..riskTolerance = state.riskTolerance
                ..investmentExperience = state.investmentExperience
                ..investmentGoal = state.investmentGoal
                ..investmentHorizon = horizon['months'] as int
                ..selectedSectors = List.from(state.selectedSectors)
                ..sectorPriorities = Map.from(state.sectorPriorities)
                ..wantPortfolioReview = state.wantPortfolioReview
                ..wantMarketTiming = state.wantMarketTiming
                ..wantLuckyNumbers = state.wantLuckyNumbers
                ..wantRiskAnalysis = state.wantRiskAnalysis
                ..specificQuestion = state.specificQuestion;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? TossDesignSystem.tossBlue
                  : isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray100,
              borderRadius: BorderRadius.circular(20),
              border: isSelected
                  ? Border.all(color: TossDesignSystem.tossBlue, width: 2)
                  : null,
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: TossDesignSystem.tossBlue.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: Text(
              horizon['label'] as String? ?? '',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? TossDesignSystem.white
                    : isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
  
  // Step 2: 관심 섹터 선택
  Widget _buildStep2() {
    final data = ref.watch(investmentDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          TossCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            TossDesignSystem.purple,
                            TossDesignSystem.purple.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.dashboard_rounded,
                        color: TossDesignSystem.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '관심 있는 투자 섹터를 선택하세요',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '최대 5개까지 선택 가능합니다',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Sector grid
          TossCard(
            padding: const EdgeInsets.all(20),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.0,
              children: InvestmentSector.values.map((sector) {
                final isSelected = data.selectedSectors.contains(sector.name);
                final canSelect = data.selectedSectors.length < 5 || isSelected;

                return _buildSectorCard(sector, isSelected, canSelect);
              }).toList(),
            ),
          ),

          if (data.selectedSectors.isNotEmpty) ...[
            const SizedBox(height: 24),
            TossCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '우선순위 설정',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...data.selectedSectors.map((sectorName) {
                    final sector = InvestmentSector.values.firstWhere((s) => s.name == sectorName);
                    return _buildPrioritySlider(sector, data);
                  }).toList(),
                ],
              ),
            ),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  Widget _buildSectorCard(InvestmentSector sector, bool isSelected, bool canSelect) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: canSelect
          ? () {
              ref.read(investmentDataProvider.notifier).update((state) {
                final newSelectedSectors = List<String>.from(state.selectedSectors);
                final newSectorPriorities = Map<String, double>.from(state.sectorPriorities);

                if (isSelected) {
                  newSelectedSectors.remove(sector.name);
                  newSectorPriorities.remove(sector.name);
                } else {
                  newSelectedSectors.add(sector.name);
                  newSectorPriorities[sector.name] = 50.0;
                }

                return InvestmentFortuneData()
                  ..userId = state.userId
                  ..name = state.name
                  ..birthDate = state.birthDate
                  ..gender = state.gender
                  ..birthTime = state.birthTime
                  ..riskTolerance = state.riskTolerance
                  ..investmentExperience = state.investmentExperience
                  ..investmentGoal = state.investmentGoal
                  ..investmentHorizon = state.investmentHorizon
                  ..selectedSectors = newSelectedSectors
                  ..sectorPriorities = newSectorPriorities
                  ..wantPortfolioReview = state.wantPortfolioReview
                  ..wantMarketTiming = state.wantMarketTiming
                  ..wantLuckyNumbers = state.wantLuckyNumbers
                  ..wantRiskAnalysis = state.wantRiskAnalysis
                  ..specificQuestion = state.specificQuestion;
              });
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: sector.gradientColors,
                )
              : null,
          color: !isSelected
              ? isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray100
              : null,
          borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
          border: isSelected
              ? Border.all(
                  color: sector.gradientColors[0],
                  width: 2,
                )
              : canSelect
                  ? Border.all(
                      color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
                      width: 1,
                    )
                  : Border.all(
                      color: isDark ? TossDesignSystem.grayDark300.withValues(alpha: 0.5) : TossDesignSystem.gray200.withValues(alpha: 0.5),
                      width: 1,
                    ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: sector.gradientColors[0].withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    sector.icon,
                    size: 40,
                    color: isSelected
                        ? TossDesignSystem.white
                        : canSelect
                            ? isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600
                            : isDark ? TossDesignSystem.grayDark400 : TossDesignSystem.gray400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    sector.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? TossDesignSystem.white
                          : canSelect
                              ? isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900
                              : isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sector.description,
                    style: TextStyle(
                      fontSize: 11,
                      color: isSelected
                          ? TossDesignSystem.white.withValues(alpha: 0.9)
                          : canSelect
                              ? isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600
                              : isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray500,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: TossDesignSystem.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_rounded,
                    size: 12,
                    color: sector.gradientColors[0],
                  ),
                ),
              ),
            if (!canSelect && !isSelected)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark ? TossDesignSystem.grayDark100.withValues(alpha: 0.8) : TossDesignSystem.white.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
                  ),
                ),
              ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms, delay: (InvestmentSector.values.indexOf(sector) * 50).ms)
      .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0));
  }
  
  Widget _buildPrioritySlider(InvestmentSector sector, InvestmentFortuneData data) {
    final priority = data.sectorPriorities[sector.name] ?? 50.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray50,
          borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
          border: Border.all(
            color: sector.gradientColors[0].withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: sector.gradientColors,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    sector.icon,
                    size: 18,
                    color: TossDesignSystem.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    sector.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sector.gradientColors[0].withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${priority.round()}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: sector.gradientColors[0],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: sector.gradientColors[0],
                inactiveTrackColor: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300,
                thumbColor: sector.gradientColors[0],
                overlayColor: sector.gradientColors[0].withValues(alpha: 0.2),
                trackHeight: 6,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
              ),
              child: Slider(
                value: priority,
                min: 0,
                max: 100,
                divisions: 20,
                onChanged: (value) {
                  ref.read(investmentDataProvider.notifier).update((state) {
                    final newSectorPriorities = Map<String, double>.from(state.sectorPriorities);
                    newSectorPriorities[sector.name] = value;

                    return InvestmentFortuneData()
                      ..userId = state.userId
                      ..name = state.name
                      ..birthDate = state.birthDate
                      ..gender = state.gender
                      ..birthTime = state.birthTime
                      ..riskTolerance = state.riskTolerance
                      ..investmentExperience = state.investmentExperience
                      ..investmentGoal = state.investmentGoal
                      ..investmentHorizon = state.investmentHorizon
                      ..selectedSectors = List.from(state.selectedSectors)
                      ..sectorPriorities = newSectorPriorities
                      ..wantPortfolioReview = state.wantPortfolioReview
                      ..wantMarketTiming = state.wantMarketTiming
                      ..wantLuckyNumbers = state.wantLuckyNumbers
                      ..wantRiskAnalysis = state.wantRiskAnalysis
                      ..specificQuestion = state.specificQuestion;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Step 3: 상세 분석 옵션
  Widget _buildStep3() {
    final data = ref.watch(investmentDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          TossCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            TossDesignSystem.warningOrange,
                            TossDesignSystem.warningOrange.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.analytics_rounded,
                        color: TossDesignSystem.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '추가 분석 옵션',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '더 정확한 운세를 위해 선택하세요',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Analysis options
          TossCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '분석 옵션',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  ),
                ),
                const SizedBox(height: 16),
                _buildAnalysisOption(
                  '포트폴리오 검토',
                  '현재 투자 포트폴리오 분석',
                  Icons.pie_chart_rounded,
                  data.wantPortfolioReview,
                  (value) {
                    ref.read(investmentDataProvider.notifier).update((state) {
                      return InvestmentFortuneData()
                        ..userId = state.userId
                        ..name = state.name
                        ..birthDate = state.birthDate
                        ..gender = state.gender
                        ..birthTime = state.birthTime
                        ..riskTolerance = state.riskTolerance
                        ..investmentExperience = state.investmentExperience
                        ..investmentGoal = state.investmentGoal
                        ..investmentHorizon = state.investmentHorizon
                        ..selectedSectors = List.from(state.selectedSectors)
                        ..sectorPriorities = Map.from(state.sectorPriorities)
                        ..wantPortfolioReview = value
                        ..wantMarketTiming = state.wantMarketTiming
                        ..wantLuckyNumbers = state.wantLuckyNumbers
                        ..wantRiskAnalysis = state.wantRiskAnalysis
                        ..specificQuestion = state.specificQuestion;
                    });
                  },
                ),
                const SizedBox(height: 12),
                _buildAnalysisOption(
                  '시장 타이밍 분석',
                  '매수/매도 적기 분석',
                  Icons.access_time_rounded,
                  data.wantMarketTiming,
                  (value) {
                    ref.read(investmentDataProvider.notifier).update((state) {
                      return InvestmentFortuneData()
                        ..userId = state.userId
                        ..name = state.name
                        ..birthDate = state.birthDate
                        ..gender = state.gender
                        ..birthTime = state.birthTime
                        ..riskTolerance = state.riskTolerance
                        ..investmentExperience = state.investmentExperience
                        ..investmentGoal = state.investmentGoal
                        ..investmentHorizon = state.investmentHorizon
                        ..selectedSectors = List.from(state.selectedSectors)
                        ..sectorPriorities = Map.from(state.sectorPriorities)
                        ..wantPortfolioReview = state.wantPortfolioReview
                        ..wantMarketTiming = value
                        ..wantLuckyNumbers = state.wantLuckyNumbers
                        ..wantRiskAnalysis = state.wantRiskAnalysis
                        ..specificQuestion = state.specificQuestion;
                    });
                  },
                ),
                const SizedBox(height: 12),
                _buildAnalysisOption(
                  '행운의 숫자',
                  '로또 번호 및 행운의 숫자',
                  Icons.casino_rounded,
                  data.wantLuckyNumbers,
                  (value) {
                    ref.read(investmentDataProvider.notifier).update((state) {
                      return InvestmentFortuneData()
                        ..userId = state.userId
                        ..name = state.name
                        ..birthDate = state.birthDate
                        ..gender = state.gender
                        ..birthTime = state.birthTime
                        ..riskTolerance = state.riskTolerance
                        ..investmentExperience = state.investmentExperience
                        ..investmentGoal = state.investmentGoal
                        ..investmentHorizon = state.investmentHorizon
                        ..selectedSectors = List.from(state.selectedSectors)
                        ..sectorPriorities = Map.from(state.sectorPriorities)
                        ..wantPortfolioReview = state.wantPortfolioReview
                        ..wantMarketTiming = state.wantMarketTiming
                        ..wantLuckyNumbers = value
                        ..wantRiskAnalysis = state.wantRiskAnalysis
                        ..specificQuestion = state.specificQuestion;
                    });
                  },
                ),
                const SizedBox(height: 12),
                _buildAnalysisOption(
                  '위험 관리 분석',
                  '투자 위험 요소 점검',
                  Icons.warning_rounded,
                  data.wantRiskAnalysis,
                  (value) {
                    ref.read(investmentDataProvider.notifier).update((state) {
                      return InvestmentFortuneData()
                        ..userId = state.userId
                        ..name = state.name
                        ..birthDate = state.birthDate
                        ..gender = state.gender
                        ..birthTime = state.birthTime
                        ..riskTolerance = state.riskTolerance
                        ..investmentExperience = state.investmentExperience
                        ..investmentGoal = state.investmentGoal
                        ..investmentHorizon = state.investmentHorizon
                        ..selectedSectors = List.from(state.selectedSectors)
                        ..sectorPriorities = Map.from(state.sectorPriorities)
                        ..wantPortfolioReview = state.wantPortfolioReview
                        ..wantMarketTiming = state.wantMarketTiming
                        ..wantLuckyNumbers = state.wantLuckyNumbers
                        ..wantRiskAnalysis = value
                        ..specificQuestion = state.specificQuestion;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Specific question
          TossCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '궁금한 점이 있으신가요?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: InputDecoration(
                    hintText: '예: 올해 부동산 투자가 좋을까요?',
                    hintStyle: TextStyle(
                      color: isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray500,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
                      borderSide: BorderSide(
                        color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
                      borderSide: BorderSide(
                        color: isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
                      borderSide: const BorderSide(
                        color: TossDesignSystem.tossBlue,
                        width: 2,
                      ),
                    ),
                    prefixIcon: Icon(
                      Icons.help_outline_rounded,
                      color: isDark ? TossDesignSystem.grayDark500 : TossDesignSystem.gray500,
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                  maxLines: 3,
                  style: TextStyle(
                    color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                  ),
                  onChanged: (value) {
                    ref.read(investmentDataProvider.notifier).update((state) {
                      return InvestmentFortuneData()
                        ..userId = state.userId
                        ..name = state.name
                        ..birthDate = state.birthDate
                        ..gender = state.gender
                        ..birthTime = state.birthTime
                        ..riskTolerance = state.riskTolerance
                        ..investmentExperience = state.investmentExperience
                        ..investmentGoal = state.investmentGoal
                        ..investmentHorizon = state.investmentHorizon
                        ..selectedSectors = List.from(state.selectedSectors)
                        ..sectorPriorities = Map.from(state.sectorPriorities)
                        ..wantPortfolioReview = state.wantPortfolioReview
                        ..wantMarketTiming = state.wantMarketTiming
                        ..wantLuckyNumbers = state.wantLuckyNumbers
                        ..wantRiskAnalysis = state.wantRiskAnalysis
                        ..specificQuestion = value;
                    });
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  Widget _buildAnalysisOption(
    String title,
    String description,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => onChanged(!value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: value
              ? TossDesignSystem.tossBlue.withValues(alpha: 0.08)
              : isDark ? TossDesignSystem.grayDark200 : TossDesignSystem.gray50,
          border: Border.all(
            color: value
                ? TossDesignSystem.tossBlue
                : isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
            width: value ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: value
                    ? TossDesignSystem.tossBlue
                    : isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                size: 20,
                color: value
                    ? TossDesignSystem.white
                    : isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: value
                          ? TossDesignSystem.tossBlue
                          : isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 50,
              height: 30,
              decoration: BoxDecoration(
                color: value
                    ? TossDesignSystem.tossBlue
                    : isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray300,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Stack(
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    left: value ? 22 : 2,
                    top: 2,
                    child: Container(
                      width: 26,
                      height: 26,
                      decoration: const BoxDecoration(
                        color: TossDesignSystem.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Step 4: 최종 확인
  Widget _buildStep4() {
    final data = ref.watch(investmentDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          TossCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            TossDesignSystem.successGreen,
                            TossDesignSystem.successGreen.withValues(alpha: 0.8),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        color: TossDesignSystem.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '투자 운세 준비 완료!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '입력하신 정보를 확인해주세요',
                            style: TextStyle(
                              fontSize: 14,
                              color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Summary
          _buildSummaryCard('투자 프로필', [
            '성향: ${_getRiskToleranceLabel(data.riskTolerance)}',
            '경험: ${_getExperienceLabel(data.investmentExperience)}',
            '목표: ${_getGoalLabel(data.investmentGoal)}',
            '기간: ${_getHorizonLabel(data.investmentHorizon)}',
          ]),

          const SizedBox(height: 16),

          _buildSummaryCard('관심 섹터', [
            ...data.selectedSectors.map((sectorName) {
              final sector = InvestmentSector.values.firstWhere((s) => s.name == sectorName);
              final priority = data.sectorPriorities[sectorName] ?? 50.0;
              return '${sector.label} (${priority.round()}%)';
            }).toList(),
          ]),

          const SizedBox(height: 16),

          if (_hasAnyAnalysisOption(data))
            _buildSummaryCard('추가 분석', [
              if (data.wantPortfolioReview) '포트폴리오 검토',
              if (data.wantMarketTiming) '시장 타이밍 분석',
              if (data.wantLuckyNumbers) '행운의 숫자',
              if (data.wantRiskAnalysis) '위험 관리 분석',
              if (data.specificQuestion?.isNotEmpty ?? false)
                '질문: ${data.specificQuestion}',
            ]),

          const SizedBox(height: 32),

          // Fortune preview animation
          Center(
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    TossDesignSystem.tossBlue,
                    TossDesignSystem.purple,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: TossDesignSystem.tossBlue.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_graph_rounded,
                size: 64,
                color: TossDesignSystem.white,
              ),
            ).animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 2000.ms, color: TossDesignSystem.white.withValues(alpha: 0.4))
              .rotate(duration: 20000.ms),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
  
  Widget _buildSummaryCard(String title, List<String> items) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return TossCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.summarize_rounded,
                  size: 18,
                  color: TossDesignSystem.tossBlue,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: TossDesignSystem.tossBlue,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? TossDesignSystem.grayDark700 : TossDesignSystem.gray700,
                        ),
                      ),
                    ),
                  ],
                ),
              )).toList(),
        ],
      ),
    );
  }
  
  // Helper methods
  String _getRiskToleranceLabel(String? value) {
    switch (value) {
      case 'conservative': return '안정형';
      case 'moderate':
        return '중립형';
      case 'aggressive':
        return '공격형';
      default:
        return '미선택';
    }
  }
  
  String _getExperienceLabel(String? value) {
    switch (value) {
      case 'beginner': return '초보자';
      case 'intermediate':
        return '중급자';
      case 'expert':
        return '전문가';
      default:
        return '미선택';
    }
  }
  
  String _getGoalLabel(String? value) {
    switch (value) {
      case 'wealth': return '자산 증식';
      case 'stability':
        return '안정적 수익';
      case 'speculation':
        return '단기 수익';
      case 'retirement':
        return '노후 준비';
      default:
        return '미선택';
    }
  }
  
  String _getHorizonLabel(int? months) {
    if (months == null) return '미선택';
    if (months <= 3) return '3개월';
    if (months <= 6) return '6개월';
    if (months <= 12) return '1년';
    if (months <= 36) return '3년';
    return '5년 이상';
  }
  
  bool _hasAnyAnalysisOption(InvestmentFortuneData data) {
    return data.wantPortfolioReview ||
           data.wantMarketTiming ||
           data.wantLuckyNumbers ||
           data.wantRiskAnalysis ||
           (data.specificQuestion?.isNotEmpty ?? false);
  }
  
  // Generate fortune
  void _generateFortune() async {
    final data = ref.read(investmentDataProvider);

    // Show ad first
    await AdService.instance.showInterstitialAdWithCallback(
      onAdCompleted: () async {
        _proceedWithFortune(data);
      },
      onAdFailed: () async {
        // Still proceed even if ad fails
        _proceedWithFortune(data);
      },
    );
  }

  void _proceedWithFortune(InvestmentFortuneData data) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
              Text(
                '투자 운세를 분석하고 있습니다...',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
    
    try {
      // Prepare parameters
      final params = {
        'userId': data.userId,
        'name': data.name,
        'birthDate': data.birthDate?.toIso8601String(),
        'gender': data.gender,
        'birthTime': data.birthTime,
        'riskTolerance': data.riskTolerance,
        'investmentExperience': data.investmentExperience,
        'investmentGoal': data.investmentGoal,
        'investmentHorizon': data.investmentHorizon,
        'selectedSectors': data.selectedSectors,
        'sectorPriorities': data.sectorPriorities,
        'wantPortfolioReview': data.wantPortfolioReview,
        'wantMarketTiming': data.wantMarketTiming,
        'wantLuckyNumbers': data.wantLuckyNumbers,
        'wantRiskAnalysis': data.wantRiskAnalysis,
        'specificQuestion': data.specificQuestion,
      };
      
      // Generate fortune
      final fortuneService = ref.read(fortuneServiceProvider);
      final fortune = await fortuneService.getInvestmentEnhancedFortune(
        userId: data.userId!,
        investmentData: params);
      
      // Navigate to result page
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        // Navigate to result page
        context.pushReplacement(
          '/fortune/investment-enhanced/result',
          extra: {
            'fortune': fortune,
            'investmentData': data,
          },
        );
      }
    } catch (e) {
      if (mounted) {
        Navigator.of(context).pop(); // Close loading dialog
        
        // Show error
        Toast.show(
          context,
          message: '운세 생성 중 오류가 발생했습니다: $e',
          type: ToastType.error,
        );
      }
    }
  }
}