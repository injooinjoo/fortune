import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../presentation/providers/fortune_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/components/toast.dart';
import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';
import '../../../../core/widgets/unified_button.dart';
import '../widgets/standard_fortune_app_bar.dart';
import '../widgets/investment_category_grid.dart';
import '../widgets/ticker_search_widget.dart';
import '../../../../services/ad_service.dart';
import '../../data/models/investment_ticker.dart';

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

final investmentStepProvider =
    StateNotifierProvider<InvestmentStepNotifier, int>((ref) {
  return InvestmentStepNotifier();
});

// 데이터 모델 (리뉴얼)
class InvestmentFortuneData {
  // Step 1: 투자 카테고리
  InvestmentCategory? selectedCategory;

  // Step 2: 선택된 종목
  InvestmentTicker? selectedTicker;

  // Step 3: 투자 프로필
  String? riskTolerance; // conservative, moderate, aggressive
  String? investmentGoal; // wealth, stability, speculation, retirement
  int? investmentHorizon; // 투자 기간 (개월)

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
  const InvestmentFortuneEnhancedPage({super.key});

  @override
  ConsumerState<InvestmentFortuneEnhancedPage> createState() =>
      _InvestmentFortuneEnhancedPageState();
}

class _InvestmentFortuneEnhancedPageState
    extends ConsumerState<InvestmentFortuneEnhancedPage> {
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    _initializeUserData();
  }

  @override
  void dispose() {
    _pageController.dispose();
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
      backgroundColor:
          isDark ? TossDesignSystem.grayDark50 : const Color(0xFFF7F7F8),
      appBar: StandardFortuneAppBar(
        title: '투자 운세',
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
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              _buildStep1CategorySelection(),
              _buildStep2TickerSelection(),
              _buildStep3Profile(),
              _buildStep4Confirmation(),
            ],
          ),
          _buildFloatingButton(context, currentStep),
        ],
      ),
    );
  }

  Widget _buildFloatingButton(BuildContext context, int currentStep) {
    final data = ref.watch(investmentDataProvider);
    final isValid = _validateStep(currentStep, data);

    final buttonText = currentStep == 3 ? '투자 운세 확인하기' : '다음';

    final onPressed = currentStep == 3
        ? (isValid ? _generateFortune : null)
        : (isValid
            ? () {
                ref.read(investmentStepProvider.notifier).nextStep();
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
              }
            : null);

    return UnifiedButton.progress(
      text: buttonText,
      currentStep: currentStep + 1,
      totalSteps: 4,
      onPressed: onPressed,
      isEnabled: isValid,
      isFloating: true,
      isLoading: false,
    );
  }

  bool _validateStep(int step, InvestmentFortuneData data) {
    switch (step) {
      case 0:
        return data.selectedCategory != null;
      case 1:
        return data.selectedTicker != null;
      case 2:
        return data.riskTolerance != null && data.investmentGoal != null;
      case 3:
        return true;
      default:
        return false;
    }
  }

  // Step 1: 투자 카테고리 선택
  Widget _buildStep1CategorySelection() {
    final data = ref.watch(investmentDataProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      child: InvestmentCategoryGrid(
        selectedCategory: data.selectedCategory,
        onCategorySelected: (category) {
          ref.read(investmentDataProvider.notifier).update((state) {
            return InvestmentFortuneData()
              ..userId = state.userId
              ..name = state.name
              ..birthDate = state.birthDate
              ..gender = state.gender
              ..birthTime = state.birthTime
              ..selectedCategory = category
              ..selectedTicker = null // 카테고리 변경 시 종목 초기화
              ..riskTolerance = state.riskTolerance
              ..investmentGoal = state.investmentGoal
              ..investmentHorizon = state.investmentHorizon;
          });
        },
      ),
    );
  }

  // Step 2: 종목 선택
  Widget _buildStep2TickerSelection() {
    final data = ref.watch(investmentDataProvider);

    if (data.selectedCategory == null) {
      return const SizedBox.shrink();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      child: TickerSearchWidget(
        category: data.selectedCategory!.name,
        selectedTicker: data.selectedTicker,
        onTickerSelected: (ticker) {
          ref.read(investmentDataProvider.notifier).update((state) {
            return InvestmentFortuneData()
              ..userId = state.userId
              ..name = state.name
              ..birthDate = state.birthDate
              ..gender = state.gender
              ..birthTime = state.birthTime
              ..selectedCategory = state.selectedCategory
              ..selectedTicker = ticker
              ..riskTolerance = state.riskTolerance
              ..investmentGoal = state.investmentGoal
              ..investmentHorizon = state.investmentHorizon;
          });
        },
      ),
    );
  }

  // Step 3: 투자 프로필
  Widget _buildStep3Profile() {
    final data = ref.watch(investmentDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '투자 성향을 알려주세요',
            style: TypographyUnified.heading3.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark
                  ? TossDesignSystem.grayDark900
                  : TossDesignSystem.gray900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '맞춤형 운세 분석을 위해 필요합니다',
            style: TypographyUnified.bodySmall.copyWith(
              color: isDark
                  ? TossDesignSystem.grayDark500
                  : TossDesignSystem.gray500,
            ),
          ),

          const SizedBox(height: 32),

          // 위험 성향
          _buildSectionTitle('위험 성향', isDark),
          const SizedBox(height: 12),
          _buildRiskToleranceSelector(data, isDark),

          const SizedBox(height: 32),

          // 투자 목표
          _buildSectionTitle('투자 목표', isDark),
          const SizedBox(height: 12),
          _buildGoalSelector(data, isDark),

          const SizedBox(height: 32),

          // 투자 기간
          _buildSectionTitle('투자 기간', isDark),
          const SizedBox(height: 12),
          _buildHorizonSelector(data, isDark),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TypographyUnified.labelMedium.copyWith(
        fontWeight: FontWeight.w600,
        color: isDark ? TossDesignSystem.grayDark600 : TossDesignSystem.gray600,
      ),
    );
  }

  Widget _buildRiskToleranceSelector(InvestmentFortuneData data, bool isDark) {
    final options = [
      {'value': 'conservative', 'label': '안정형', 'desc': '원금 보존 중시'},
      {'value': 'moderate', 'label': '중립형', 'desc': '균형 잡힌 투자'},
      {'value': 'aggressive', 'label': '공격형', 'desc': '높은 수익 추구'},
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((option) {
        final isSelected = data.riskTolerance == option['value'];

        return GestureDetector(
          onTap: () => _updateRiskTolerance(option['value'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? TossDesignSystem.tossBlue
                  : (isDark ? TossDesignSystem.grayDark100 : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? TossDesignSystem.tossBlue
                    : (isDark
                        ? TossDesignSystem.grayDark300
                        : TossDesignSystem.gray200),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  option['label']!,
                  style: TypographyUnified.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? TossDesignSystem.grayDark900
                            : TossDesignSystem.gray900),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  option['desc']!,
                  style: TypographyUnified.labelSmall.copyWith(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.8)
                        : (isDark
                            ? TossDesignSystem.grayDark500
                            : TossDesignSystem.gray500),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _updateRiskTolerance(String value) {
    ref.read(investmentDataProvider.notifier).update((state) {
      return InvestmentFortuneData()
        ..userId = state.userId
        ..name = state.name
        ..birthDate = state.birthDate
        ..gender = state.gender
        ..birthTime = state.birthTime
        ..selectedCategory = state.selectedCategory
        ..selectedTicker = state.selectedTicker
        ..riskTolerance = value
        ..investmentGoal = state.investmentGoal
        ..investmentHorizon = state.investmentHorizon;
    });
  }

  Widget _buildGoalSelector(InvestmentFortuneData data, bool isDark) {
    final options = [
      {'value': 'wealth', 'label': '자산 증식', 'icon': Icons.trending_up_rounded},
      {
        'value': 'stability',
        'label': '안정적 수익',
        'icon': Icons.shield_rounded
      },
      {'value': 'speculation', 'label': '단기 수익', 'icon': Icons.flash_on_rounded},
      {'value': 'retirement', 'label': '노후 준비', 'icon': Icons.home_rounded},
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.0,
      children: options.map((option) {
        final isSelected = data.investmentGoal == option['value'];

        return GestureDetector(
          onTap: () => _updateInvestmentGoal(option['value'] as String),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: isSelected
                  ? TossDesignSystem.tossBlue
                  : (isDark ? TossDesignSystem.grayDark100 : Colors.white),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? TossDesignSystem.tossBlue
                    : (isDark
                        ? TossDesignSystem.grayDark300
                        : TossDesignSystem.gray200),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  option['icon'] as IconData,
                  size: 20,
                  color: isSelected
                      ? Colors.white
                      : (isDark
                          ? TossDesignSystem.grayDark600
                          : TossDesignSystem.gray600),
                ),
                const SizedBox(width: 8),
                Text(
                  option['label'] as String,
                  style: TypographyUnified.bodySmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Colors.white
                        : (isDark
                            ? TossDesignSystem.grayDark900
                            : TossDesignSystem.gray900),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  void _updateInvestmentGoal(String value) {
    ref.read(investmentDataProvider.notifier).update((state) {
      return InvestmentFortuneData()
        ..userId = state.userId
        ..name = state.name
        ..birthDate = state.birthDate
        ..gender = state.gender
        ..birthTime = state.birthTime
        ..selectedCategory = state.selectedCategory
        ..selectedTicker = state.selectedTicker
        ..riskTolerance = state.riskTolerance
        ..investmentGoal = value
        ..investmentHorizon = state.investmentHorizon;
    });
  }

  Widget _buildHorizonSelector(InvestmentFortuneData data, bool isDark) {
    final horizons = [
      {'months': 3, 'label': '3개월'},
      {'months': 6, 'label': '6개월'},
      {'months': 12, 'label': '1년'},
      {'months': 36, 'label': '3년'},
      {'months': 60, 'label': '5년+'},
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: horizons.map((horizon) {
        final isSelected = data.investmentHorizon == horizon['months'];

        return GestureDetector(
          onTap: () => _updateInvestmentHorizon(horizon['months'] as int),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? TossDesignSystem.tossBlue
                  : (isDark ? TossDesignSystem.grayDark100 : Colors.white),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? TossDesignSystem.tossBlue
                    : (isDark
                        ? TossDesignSystem.grayDark300
                        : TossDesignSystem.gray200),
                width: 1,
              ),
            ),
            child: Text(
              horizon['label'] as String,
              style: TypographyUnified.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? TossDesignSystem.grayDark900
                        : TossDesignSystem.gray900),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _updateInvestmentHorizon(int value) {
    ref.read(investmentDataProvider.notifier).update((state) {
      return InvestmentFortuneData()
        ..userId = state.userId
        ..name = state.name
        ..birthDate = state.birthDate
        ..gender = state.gender
        ..birthTime = state.birthTime
        ..selectedCategory = state.selectedCategory
        ..selectedTicker = state.selectedTicker
        ..riskTolerance = state.riskTolerance
        ..investmentGoal = state.investmentGoal
        ..investmentHorizon = value;
    });
  }

  // Step 4: 최종 확인
  Widget _buildStep4Confirmation() {
    final data = ref.watch(investmentDataProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '운세 분석 준비 완료',
            style: TypographyUnified.heading3.copyWith(
              fontWeight: FontWeight.w600,
              color: isDark
                  ? TossDesignSystem.grayDark900
                  : TossDesignSystem.gray900,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '아래 정보로 투자 운세를 분석합니다',
            style: TypographyUnified.bodySmall.copyWith(
              color: isDark
                  ? TossDesignSystem.grayDark500
                  : TossDesignSystem.gray500,
            ),
          ),

          const SizedBox(height: 32),

          // 선택된 종목 카드
          _buildSelectedTickerCard(data, isDark),

          const SizedBox(height: 20),

          // 투자 프로필 요약
          _buildProfileSummary(data, isDark),

          const SizedBox(height: 40),

          // 운세 아이콘
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.auto_graph_rounded,
                size: 48,
                color: TossDesignSystem.tossBlue,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTickerCard(InvestmentFortuneData data, bool isDark) {
    if (data.selectedTicker == null) return const SizedBox.shrink();

    final ticker = data.selectedTicker!;
    final category = data.selectedCategory;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.grayDark100 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
        ),
      ),
      child: Row(
        children: [
          // 종목 아이콘
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: TossDesignSystem.tossBlue.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(
                ticker.symbol.length > 3
                    ? ticker.symbol.substring(0, 2)
                    : ticker.symbol,
                style: TypographyUnified.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: TossDesignSystem.tossBlue,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticker.name,
                  style: TypographyUnified.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? TossDesignSystem.grayDark900
                        : TossDesignSystem.gray900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${category?.label ?? ''} · ${ticker.symbol}',
                  style: TypographyUnified.bodySmall.copyWith(
                    color: isDark
                        ? TossDesignSystem.grayDark500
                        : TossDesignSystem.gray500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.check_circle_rounded,
            color: TossDesignSystem.successGreen,
            size: 24,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileSummary(InvestmentFortuneData data, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? TossDesignSystem.grayDark100 : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color:
              isDark ? TossDesignSystem.grayDark300 : TossDesignSystem.gray200,
        ),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
              '위험 성향', _getRiskToleranceLabel(data.riskTolerance), isDark),
          const SizedBox(height: 12),
          _buildSummaryRow(
              '투자 목표', _getGoalLabel(data.investmentGoal), isDark),
          const SizedBox(height: 12),
          _buildSummaryRow(
              '투자 기간', _getHorizonLabel(data.investmentHorizon), isDark),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TypographyUnified.bodySmall.copyWith(
            color: isDark
                ? TossDesignSystem.grayDark500
                : TossDesignSystem.gray500,
          ),
        ),
        Text(
          value,
          style: TypographyUnified.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark
                ? TossDesignSystem.grayDark900
                : TossDesignSystem.gray900,
          ),
        ),
      ],
    );
  }

  // Helper methods
  String _getRiskToleranceLabel(String? value) {
    switch (value) {
      case 'conservative':
        return '안정형';
      case 'moderate':
        return '중립형';
      case 'aggressive':
        return '공격형';
      default:
        return '-';
    }
  }

  String _getGoalLabel(String? value) {
    switch (value) {
      case 'wealth':
        return '자산 증식';
      case 'stability':
        return '안정적 수익';
      case 'speculation':
        return '단기 수익';
      case 'retirement':
        return '노후 준비';
      default:
        return '-';
    }
  }

  String _getHorizonLabel(int? months) {
    if (months == null) return '-';
    if (months <= 3) return '3개월';
    if (months <= 6) return '6개월';
    if (months <= 12) return '1년';
    if (months <= 36) return '3년';
    return '5년 이상';
  }

  // Generate fortune
  void _generateFortune() async {
    final data = ref.read(investmentDataProvider);

    await AdService.instance.showInterstitialAdWithCallback(
      onAdCompleted: () async {
        _proceedWithFortune(data);
      },
      onAdFailed: () async {
        _proceedWithFortune(data);
      },
    );
  }

  void _proceedWithFortune(InvestmentFortuneData data) async {
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
      final params = {
        'userId': data.userId,
        'name': data.name,
        'birthDate': data.birthDate?.toIso8601String(),
        'gender': data.gender,
        'birthTime': data.birthTime,
        'investmentType': data.selectedCategory?.name ?? 'stock',
        'targetName': data.selectedTicker?.name ?? '',
        'ticker': {
          'symbol': data.selectedTicker?.symbol,
          'name': data.selectedTicker?.name,
          'category': data.selectedTicker?.category,
        },
        'riskTolerance': data.riskTolerance,
        'investmentGoal': data.investmentGoal,
        'investmentHorizon': data.investmentHorizon,
        'amount': 10000000, // 기본값
        'timeframe': _getHorizonLabel(data.investmentHorizon),
        'purpose': _getGoalLabel(data.investmentGoal),
        'experience': 'intermediate', // 기본값
      };

      final fortuneService = ref.read(fortuneServiceProvider);
      final fortune = await fortuneService.getInvestmentEnhancedFortune(
          userId: data.userId!, investmentData: params);

      if (mounted) {
        Navigator.of(context).pop();

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
        Navigator.of(context).pop();

        Toast.show(
          context,
          message: '운세 생성 중 오류가 발생했습니다: $e',
          type: ToastType.error,
        );
      }
    }
  }
}
