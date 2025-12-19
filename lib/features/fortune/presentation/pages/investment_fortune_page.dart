import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/components/toast.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/widgets/unified_button.dart';
import '../../../../core/models/fortune_result.dart';
import '../widgets/standard_fortune_app_bar.dart';
import '../widgets/investment_category_grid.dart';
import '../widgets/ticker_search_widget.dart';
import '../../../../presentation/widgets/ads/interstitial_ad_helper.dart';
import '../../data/models/investment_ticker.dart';
import '../../../../core/services/fortune_haptic_service.dart';

// Step 관리를 위한 StateNotifier (v2: 2단계로 간소화)
class InvestmentStepNotifier extends StateNotifier<int> {
  InvestmentStepNotifier() : super(0);

  void nextStep() {
    if (state < 1) state++; // 0 → 1 (2단계)
  }

  void previousStep() {
    if (state > 0) state--;
  }

  void setStep(int step) {
    state = step.clamp(0, 1);
  }
}

final investmentStepProvider =
    StateNotifierProvider<InvestmentStepNotifier, int>((ref) {
  return InvestmentStepNotifier();
});

// 데이터 모델 (v2: 간소화 - 투자 프로필 제거)
class InvestmentFortuneData {
  // Step 1: 투자 카테고리
  InvestmentCategory? selectedCategory;

  // Step 2: 선택된 종목
  InvestmentTicker? selectedTicker;

  // 사용자 정보
  String? userId;
  String? name;
}

final investmentDataProvider = StateProvider<InvestmentFortuneData>((ref) {
  return InvestmentFortuneData();
});

class InvestmentFortunePage extends ConsumerStatefulWidget {
  const InvestmentFortunePage({super.key});

  @override
  ConsumerState<InvestmentFortunePage> createState() =>
      _InvestmentFortunePageState();
}

class _InvestmentFortunePageState
    extends ConsumerState<InvestmentFortunePage> {
  final PageController _pageController = PageController();

  // 로딩 상태 관리
  bool _isLoading = false;

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
    } else {
      final data = ref.read(investmentDataProvider);
      data.userId = 'test-user-123';
      data.name = '테스트 사용자';
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = ref.watch(investmentStepProvider);
    final colors = context.colors;

    return Scaffold(
      backgroundColor: colors.background,
      appBar: StandardFortuneAppBar(
        title: '재물운',
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

    // Step 2에서는 "운세 확인하기", Step 1에서는 "다음"
    final buttonText = currentStep == 1 ? '재물운 확인하기' : '다음';

    final onPressed = currentStep == 1
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
      totalSteps: 2,
      onPressed: _isLoading ? null : onPressed,
      isEnabled: isValid && !_isLoading,
      isFloating: true,
      isLoading: _isLoading,
    );
  }

  bool _validateStep(int step, InvestmentFortuneData data) {
    switch (step) {
      case 0:
        return data.selectedCategory != null;
      case 1:
        return data.selectedTicker != null;
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
              ..selectedCategory = category
              ..selectedTicker = null; // 카테고리 변경 시 종목 초기화
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
              ..selectedCategory = state.selectedCategory
              ..selectedTicker = ticker;
          });
        },
      ),
    );
  }

  // Generate fortune (v2: 간소화된 API 호출)
  void _generateFortune() async {
    final data = ref.read(investmentDataProvider);

    await InterstitialAdHelper.showInterstitialAdWithCallback(
      ref,
      onAdCompleted: () async {
        _proceedWithFortune(data);
      },
      onAdFailed: () async {
        _proceedWithFortune(data);
      },
    );
  }

  void _proceedWithFortune(InvestmentFortuneData data) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // v2: 간소화된 요청 (투자 프로필 제거)
      final params = {
        'userId': data.userId,
        'ticker': {
          'symbol': data.selectedTicker?.symbol ?? '',
          'name': data.selectedTicker?.name ?? '',
          'category': data.selectedCategory?.name ?? 'stock',
          'exchange': data.selectedTicker?.exchange,
        },
        'isPremium': false,
      };

      debugPrint('📊 [Investment v2] Calling Edge Function with params: $params');

      final response = await Supabase.instance.client.functions.invoke(
        'fortune-investment',
        body: params,
      );

      debugPrint('📊 [Investment v2] Response status: ${response.status}');

      if (response.status != 200) {
        throw Exception('Edge Function 호출 실패: ${response.status}');
      }

      final responseData = response.data as Map<String, dynamic>;
      final fortune = responseData['fortune'] as Map<String, dynamic>;

      // FortuneResult 생성 (v2 구조)
      final fortuneResult = FortuneResult(
        id: fortune['id'] as String?,
        type: 'investment',
        title: '재물운',
        summary: {
          'ticker_name': data.selectedTicker?.name ?? '',
          'ticker_symbol': data.selectedTicker?.symbol ?? '',
          'category': data.selectedCategory?.label ?? '',
        },
        data: fortune,
        score: fortune['overallScore'] as int? ?? fortune['overall_score'] as int?,
        isBlurred: fortune['isBlurred'] as bool? ?? true,
        blurredSections: (fortune['blurredSections'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ?? ['timing', 'outlook', 'risks', 'marketMood', 'advice', 'psychologyTip'],
        percentile: fortune['percentile'] as int?,
        isPercentileValid: fortune['is_percentile_valid'] as bool? ?? false,
      );

      if (mounted) {
        // ✅ 재물운 결과 생성 완료 시 동전 햅틱 피드백
        ref.read(fortuneHapticServiceProvider).investmentCoin();

        setState(() {
          _isLoading = false;
        });

        context.pushReplacement(
          '/fortune/investment/result',
          extra: fortuneResult,
        );
      }
    } catch (e) {
      debugPrint('❌ [Investment v2] Error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        Toast.show(
          context,
          message: '운세 생성 중 오류가 발생했습니다: $e',
          type: ToastType.error,
        );
      }
    }
  }
}
