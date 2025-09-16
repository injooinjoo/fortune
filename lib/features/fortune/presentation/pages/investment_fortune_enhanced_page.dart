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
  List<InvestmentSector> selectedSectors = [];
  Map<InvestmentSector, double> sectorPriorities = {};
  
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
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final currentStep = ref.watch(investmentStepProvider);
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? TossDesignSystem.grayDark50 : TossDesignSystem.gray50,
      body: SafeArea(
        child: Column(
          children: [
            // Header with back button and progress
            _buildHeader(context, currentStep),
            
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
            
            // Bottom navigation
            _buildBottomNavigation(context, currentStep),
          ],
        ),
      ),
    );
  }
  
  Widget _buildHeader(BuildContext context, int currentStep) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_rounded),
            onPressed: () {
              if (currentStep > 0) {
                ref.read(investmentStepProvider.notifier).previousStep();
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut
                );
              } else {
                context.pop();
              }
            }),
          Expanded(
            child: Text(
              '투자 운세',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48), // Balance the back button
        ],
      ),
    );
  }
  
  Widget _buildStepIndicator(int currentStep) {
    final steps = [
      '투자 프로필', '관심 섹터',
      '상세 분석', '운세 보기'
    ];
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                          color: isCompleted
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).dividerColor),
                      ),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isActive || isCompleted
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.surfaceContainerHighest,
                      ),
                      child: Center(
                        child: isCompleted
                            ? const Icon(Icons.check, size: 16, color: Colors.white)
                            : Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: isActive ? Colors.white : Theme.of(context).colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    if (index < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          color: isCompleted
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).dividerColor),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  steps[index],
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isActive
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
  
  Widget _buildBottomNavigation(BuildContext context, int currentStep) {
    final data = ref.watch(investmentDataProvider);
    final isValid = _validateStep(currentStep, data);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: currentStep == 3
          ? FortuneButton.viewFortune(
              onPressed: isValid ? _generateFortune : null,
              isEnabled: isValid,
              isLoading: false,
              text: '💰 나의 투자 운명 확인하기',
            )
          : FortuneButtonGroup.navigation(
              onPrevious: currentStep > 0
                  ? () {
                      ref.read(investmentStepProvider.notifier).previousStep();
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  : null,
              onNext: isValid
                  ? () {
                      ref.read(investmentStepProvider.notifier).nextStep();
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    }
                  : null,
              showPrevious: currentStep > 0,
              isNextEnabled: isValid,
              nextText: '다음',
              position: FortuneButtonPosition.inline,
            ),
    );
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
    
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '투자 성향을 알려주세요',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                '맞춤형 투자 운세를 위해 필요합니다',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 32),
              
              // Risk tolerance
              _buildSectionTitle('위험 성향'),
              const SizedBox(height: 12),
              _buildRiskToleranceSelector(data),
              const SizedBox(height: 24),
              
              // Investment experience
              _buildSectionTitle('투자 경험'),
              const SizedBox(height: 12),
              _buildExperienceSelector(data),
              const SizedBox(height: 24),
              
              // Investment goal
              _buildSectionTitle('투자 목표'),
              const SizedBox(height: 12),
              _buildGoalSelector(data),
              const SizedBox(height: 24),
              
              // Investment horizon
              _buildSectionTitle('투자 기간'),
              const SizedBox(height: 12),
              _buildHorizonSelector(data),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold),
    );
  }
  
  Widget _buildRiskToleranceSelector(InvestmentFortuneData data) {
    final options = [
      {'value': 'conservative', 'label': '안정형', 'description': '원금 보존 중시'},
      {'value': 'moderate', 'label': '중립형', 'description': '균형잡힌 수익과 안정'},
      {'value': 'aggressive', 'label': '공격형', 'description': '높은 수익 추구'},
    ];
    
    return Column(
      children: options.map((option) {
        final isSelected = data.riskTolerance == option['value'];
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: InkWell(
            onTap: () {
              ref.read(investmentDataProvider.notifier).update((state) {
                state.riskTolerance = option['value'] as String;
                return state;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).dividerColor,
                  width: isSelected ? 2 : 1,
                ),
                borderRadius: BorderRadius.circular(12),
                color: isSelected
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                    : null,
              ),
              child: Row(
                children: [
                  Radio<String>(
                    value: option['value'] as String,
                    groupValue: data.riskTolerance,
                    onChanged: (value) {
                      ref.read(investmentDataProvider.notifier).update((state) {
                        state.riskTolerance = value;
                        return state;
                      });
                    },
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          option['label'] as String? ?? '',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold),
                        ),
                        Text(
                          option['description'] as String? ?? '',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
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
    
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: options.map((option) {
        final isSelected = data.investmentExperience == option['value'];
        
        return ChoiceChip(
          label: Column(
            children: [
              Text(option['label'] as String? ?? ''),
              Text(
                option['description'] as String? ?? '',
                style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              ref.read(investmentDataProvider.notifier).update((state) {
                state.investmentExperience = option['value'] as String;
                return state;
              });
            }
          },
        );
      }).toList(),
    );
  }
  
  Widget _buildGoalSelector(InvestmentFortuneData data) {
    final options = [
      {'value': 'wealth', 'label': '자산 증식', 'icon': Icons.trending_up},
      {'value': 'stability', 'label': '안정적 수익', 'icon': Icons.shield},
      {'value': 'speculation', 'label': '단기 수익', 'icon': Icons.flash_on},
      {'value': 'retirement', 'label': '노후 준비', 'icon': Icons.home},
    ];
    
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.5,
      children: options.map((option) {
        final isSelected = data.investmentGoal == option['value'];
        
        return InkWell(
          onTap: () {
            ref.read(investmentDataProvider.notifier).update((state) {
              state.investmentGoal = option['value'] as String;
              return state;
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        Theme.of(context).colorScheme.primary,
                        Theme.of(context).colorScheme.primary.withOpacity(0.8),
                      ],
                    )
                  : null,
              border: Border.all(
                color: isSelected
                    ? Colors.transparent
                    : Theme.of(context).dividerColor,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  option['icon'] as IconData? ?? Icons.help,
                  size: 32,
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 8),
                Text(
                  option['label'] as String? ?? '',
                  style: TextStyle(
                    color: isSelected
                        ? Colors.white
                        : Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
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
    
    return Wrap(
      spacing: 12,
      children: horizons.map((horizon) {
        final isSelected = data.investmentHorizon == horizon['months'];
        
        return ChoiceChip(
          label: Text(horizon['label'] as String? ?? ''),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) {
              ref.read(investmentDataProvider.notifier).update((state) {
                state.investmentHorizon = horizon['months'] as int;
                return state;
              });
            }
          },
        );
      }).toList(),
    );
  }
  
  // Step 2: 관심 섹터 선택
  Widget _buildStep2() {
    final data = ref.watch(investmentDataProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '관심 있는 투자 섹터를 선택하세요',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '최대 5개까지 선택 가능합니다',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          
          // Sector grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.0,
            children: InvestmentSector.values.map((sector) {
              final isSelected = data.selectedSectors.contains(sector);
              final canSelect = data.selectedSectors.length < 5 || isSelected;
              
              return _buildSectorCard(sector, isSelected, canSelect);
            }).toList(),
          ),
          
          if (data.selectedSectors.isNotEmpty) ...[
            const SizedBox(height: 32),
            Text(
              '우선순위 설정',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...data.selectedSectors.map((sector) {
              return _buildPrioritySlider(sector, data);
            }).toList(),
          ],
        ],
      ),
    );
  }
  
  Widget _buildSectorCard(InvestmentSector sector, bool isSelected, bool canSelect) {
    return InkWell(
      onTap: canSelect
          ? () {
              ref.read(investmentDataProvider.notifier).update((state) {
                if (isSelected) {
                  state.selectedSectors.remove(sector);
                  state.sectorPriorities.remove(sector);
                } else {
                  state.selectedSectors.add(sector);
                  state.sectorPriorities[sector] = 50.0;
                }
                return state;
              });
            }
          : null,
      borderRadius: BorderRadius.circular(16),
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
              ? Theme.of(context).colorScheme.surfaceContainerHighest
              : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Theme.of(context).dividerColor,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: sector.gradientColors[0].withOpacity(0.4),
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
                    size: 48,
                    color: isSelected
                        ? Colors.white
                        : canSelect
                            ? Theme.of(context).colorScheme.onSurfaceVariant
                            : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)),
                  const SizedBox(height: 12),
                  Text(
                    sector.label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isSelected
                          ? Colors.white
                          : canSelect
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.onSurface.withOpacity(0.5)),
                    textAlign: TextAlign.center),
                  const SizedBox(height: 4),
                  Text(
                    sector.description,
                    style: TextStyle(
                      fontSize: 12,
                      color: isSelected
                          ? Colors.white.withOpacity(0.9)
                          : canSelect
                              ? Theme.of(context).colorScheme.onSurfaceVariant
                              : Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.5)),
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
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    size: 16,
                    color: sector.gradientColors[0],
                  ),
                ),
              ),
          ],
        ),
      ),
    ).animate()
      .fadeIn(duration: 300.ms, delay: (InvestmentSector.values.indexOf(sector) * 50).ms)
      .scale(begin: const Offset(0.8, 0.8), end: const Offset(1.0, 1.0));
  }
  
  Widget _buildPrioritySlider(InvestmentSector sector, InvestmentFortuneData data) {
    final priority = data.sectorPriorities[sector] ?? 50.0;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(sector.icon, size: 24, color: sector.gradientColors[0]),
              const SizedBox(width: 8),
              Text(
                sector.label,
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              Text(
                '${priority.round()}%',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: sector.gradientColors[0],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: sector.gradientColors[0],
              inactiveTrackColor: sector.gradientColors[0].withOpacity(0.3),
              thumbColor: sector.gradientColors[0],
              overlayColor: sector.gradientColors[0].withOpacity(0.3),
            ),
            child: Slider(
              value: priority,
              min: 0,
              max: 100,
              divisions: 20,
              onChanged: (value) {
                ref.read(investmentDataProvider.notifier).update((state) {
                  state.sectorPriorities[sector] = value;
                  return state;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
  
  // Step 3: 상세 분석 옵션
  Widget _buildStep3() {
    final data = ref.watch(investmentDataProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '추가 분석 옵션',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '더 정확한 운세를 위해 선택하세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          
          // Analysis options
          _buildAnalysisOption(
            '포트폴리오 검토',
            '현재 투자 포트폴리오 분석',
            Icons.pie_chart_rounded,
            data.wantPortfolioReview,
            (value) {
              ref.read(investmentDataProvider.notifier).update((state) {
                state.wantPortfolioReview = value;
                return state;
              });
            },
          ),
          const SizedBox(height: 16),
          
          _buildAnalysisOption(
            '시장 타이밍 분석',
            '매수/매도 적기 분석',
            Icons.access_time_rounded,
            data.wantMarketTiming,
            (value) {
              ref.read(investmentDataProvider.notifier).update((state) {
                state.wantMarketTiming = value;
                return state;
              });
            },
          ),
          const SizedBox(height: 16),
          
          _buildAnalysisOption(
            '행운의 숫자',
            '로또 번호 및 행운의 숫자',
            Icons.casino_rounded,
            data.wantLuckyNumbers,
            (value) {
              ref.read(investmentDataProvider.notifier).update((state) {
                state.wantLuckyNumbers = value;
                return state;
              });
            },
          ),
          const SizedBox(height: 16),
          
          _buildAnalysisOption(
            '위험 관리 분석',
            '투자 위험 요소 점검',
            Icons.warning_rounded,
            data.wantRiskAnalysis,
            (value) {
              ref.read(investmentDataProvider.notifier).update((state) {
                state.wantRiskAnalysis = value;
                return state;
              });
            },
          ),
          const SizedBox(height: 32),
          
          // Specific question
          Text(
            '궁금한 점이 있으신가요?',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: InputDecoration(
              hintText: '예: 올해 부동산 투자가 좋을까요?',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.help_outline_rounded),
            ),
            maxLines: 3,
            onChanged: (value) {
              ref.read(investmentDataProvider.notifier).update((state) {
                state.specificQuestion = value;
                return state;
              });
            },
          ),
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
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(
            color: value
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).dividerColor,
            width: value ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          color: value
              ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 32,
              color: value
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Switch(
              value: value,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
  
  // Step 4: 최종 확인
  Widget _buildStep4() {
    final data = ref.watch(investmentDataProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '투자 운세 준비 완료!',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '입력하신 정보를 확인해주세요',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),
          
          // Summary
          _buildSummaryCard('투자 프로필', [
            '성향: ${_getRiskToleranceLabel(data.riskTolerance)}',
            '경험: ${_getExperienceLabel(data.investmentExperience)}',
            '목표: ${_getGoalLabel(data.investmentGoal)}',
            '기간: ${_getHorizonLabel(data.investmentHorizon)}',
          ]),
          const SizedBox(height: 16),
          
          _buildSummaryCard('관심 섹터', [
            ...data.selectedSectors.map((sector) {
              final priority = data.sectorPriorities[sector] ?? 50.0;
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
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
                ),
              ),
              child: const Icon(
                Icons.auto_graph_rounded,
                size: 80,
                color: Colors.white,
              ),
            ).animate(onPlay: (controller) => controller.repeat())
              .shimmer(duration: 2000.ms, color: Colors.white.withOpacity(0.5))
              .rotate(duration: 20000.ms),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSummaryCard(String title, List<String> items) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item,
                        style: Theme.of(context).textTheme.bodySmall,
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
      onAdCompleted: () {
        _proceedWithFortune(data);
      },
      onAdFailed: () {
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
        'selectedSectors': data.selectedSectors.map((s) => s.name).toList(),
        'sectorPriorities': data.sectorPriorities.map((k, v) => MapEntry(k.name, v)),
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
        params: params);
      
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