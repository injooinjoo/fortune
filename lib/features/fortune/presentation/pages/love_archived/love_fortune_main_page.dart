import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../../core/theme/toss_theme.dart';
import '../../../../../core/theme/toss_design_system.dart';
import '../../../../../core/services/unified_fortune_service.dart';
import '../../../../../core/services/debug_premium_service.dart';
import '../../../../../core/widgets/unified_button.dart';
import '../../../../../core/widgets/unified_button_enums.dart';
import '../../../../../presentation/providers/token_provider.dart';
import '../../../../../features/fortune/domain/models/conditions/love_fortune_conditions.dart';
import '../../widgets/standard_fortune_app_bar.dart';
import 'love_input_step1_page.dart';
import 'love_input_step2_page.dart';
import 'love_input_step3_page.dart';
import 'love_input_step4_page.dart';
import '../love/love_fortune_result_page.dart';

class LoveFortuneMainPage extends ConsumerStatefulWidget {
  const LoveFortuneMainPage({super.key});

  @override
  ConsumerState<LoveFortuneMainPage> createState() => _LoveFortuneMainPageState();
}

class _LoveFortuneMainPageState extends ConsumerState<LoveFortuneMainPage> {
  final PageController _pageController = PageController();

  int _currentStep = 0;
  final int _totalSteps = 4;

  // 전체 입력 데이터 저장
  final Map<String, dynamic> _loveFortuneData = {};

  // ValueNotifiers for tracking button activation state
  final _step1CanProceed = ValueNotifier<bool>(false);
  final _step2CanProceed = ValueNotifier<bool>(false);
  final _step3CanProceed = ValueNotifier<bool>(false);
  final _step4CanProceed = ValueNotifier<bool>(false);

  // GlobalKeys to access child state
  final _step1Key = GlobalKey<State<LoveInputStep1Page>>();
  final _step2Key = GlobalKey<State<LoveInputStep2Page>>();
  final _step3Key = GlobalKey<State<LoveInputStep3Page>>();
  final _step4Key = GlobalKey<State<LoveInputStep4Page>>();

  @override
  void dispose() {
    _pageController.dispose();
    _step1CanProceed.dispose();
    _step2CanProceed.dispose();
    _step3CanProceed.dispose();
    _step4CanProceed.dispose();
    super.dispose();
  }

  void _nextStep([Map<String, dynamic>? stepData]) {
    // 현재 스텝의 데이터 수집
    Map<String, dynamic>? currentStepData = stepData;

    if (currentStepData == null) {
      // FloatingButton에서 호출된 경우, 현재 페이지에서 데이터 가져오기
      switch (_currentStep) {
        case 0:
          final state = _step1Key.currentState as dynamic;
          currentStepData = state?.getData();
          break;
        case 1:
          final state = _step2Key.currentState as dynamic;
          currentStepData = state?.getData();
          break;
        case 2:
          final state = _step3Key.currentState as dynamic;
          currentStepData = state?.getData();
          break;
        case 3:
          final state = _step4Key.currentState as dynamic;
          currentStepData = state?.getData();
          break;
      }
    }

    if (currentStepData != null) {
      _loveFortuneData.addAll(currentStepData);
      debugPrint('[_nextStep] Step ${_currentStep + 1} 데이터 수집: $currentStepData');
      debugPrint('[_nextStep] 누적 데이터: $_loveFortuneData');
    }

    if (_currentStep < _totalSteps - 1) {
      setState(() {
        _currentStep++;
      });
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _showResults();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _showResults() async {
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    debugPrint('📊 [연애운] 결과 생성 프로세스 시작');
    debugPrint('[1️⃣] 입력 데이터 확인: $_loveFortuneData');

    // 로딩 다이얼로그 표시
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      // 1. Premium 상태 확인
      debugPrint('[2️⃣] Premium 상태 확인 중...');

      // Debug 오버라이드 확인
      final debugOverride = await DebugPremiumService.getOverrideValue();

      // 실제 프리미엄 상태 확인
      final tokenState = ref.read(tokenProvider);
      final isPremium = debugOverride ?? tokenState.hasUnlimitedAccess;

      debugPrint('[2️⃣] Premium 상태: $isPremium (debug: $debugOverride, real: ${tokenState.hasUnlimitedAccess})');

      // 2. LoveFortuneConditions 생성
      debugPrint('[3️⃣] LoveFortuneConditions 생성 중...');
      final conditions = LoveFortuneConditions.fromInputData(_loveFortuneData);
      debugPrint('[3️⃣] Conditions 생성 완료: ${conditions.toJson()}');

      // 3. UnifiedFortuneService 인스턴스 생성
      debugPrint('[4️⃣] UnifiedFortuneService 인스턴스 생성...');
      final fortuneService = UnifiedFortuneService(
        Supabase.instance.client,
        enableOptimization: true,
      );

      // 4. API 호출
      debugPrint('[5️⃣] getFortune() 호출 중...');
      debugPrint('   - fortuneType: love');
      debugPrint('   - dataSource: FortuneDataSource.api');
      debugPrint('   - isPremium: $isPremium');

      // inputConditions에 isPremium 추가
      final inputConditionsWithPremium = {
        ..._loveFortuneData,
        'isPremium': isPremium,
      };

      final fortuneResult = await fortuneService.getFortune(
        fortuneType: 'love',
        dataSource: FortuneDataSource.api,
        inputConditions: inputConditionsWithPremium,
        conditions: conditions, // 최적화 활성화
        isPremium: isPremium,
      );
      debugPrint('[5️⃣] API 호출 완료 - isBlurred: ${fortuneResult.isBlurred}');

      // 로딩 다이얼로그 닫기
      if (mounted) {
        Navigator.of(context).pop();

        // 5. 결과 페이지로 이동
        debugPrint('[6️⃣] 결과 페이지로 이동...');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LoveFortuneResultPage(
              fortuneResult: fortuneResult,
            ),
          ),
        );
        debugPrint('✅ [연애운] 결과 페이지 표시 완료');
        debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      }
    } catch (e, stackTrace) {
      debugPrint('❌ [연애운] 에러 발생: $e');
      debugPrint('Stack trace: $stackTrace');

      // 로딩 다이얼로그 닫기
      if (mounted) {
        Navigator.of(context).pop();

        // 에러 다이얼로그 표시
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('오류 발생'),
              content: Text('연애운 생성 중 오류가 발생했습니다.\n$e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('확인'),
                ),
              ],
            );
          },
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? TossDesignSystem.backgroundDark : TossTheme.backgroundPrimary,
      appBar: StandardFortuneAppBar(
        title: '연애운',
        onBackPressed: _currentStep == 0 ? () => Navigator.pop(context) : _previousStep,
      ),
      body: Stack(
        children: [
          // Page Content (상단 프로그레스 바 제거)
          PageView(
            controller: _pageController,
            physics: const NeverScrollableScrollPhysics(),
            children: [
              LoveInputStep1Page(key: _step1Key, onNext: _nextStep, canProceedNotifier: _step1CanProceed),
              LoveInputStep2Page(key: _step2Key, onNext: _nextStep, canProceedNotifier: _step2CanProceed),
              LoveInputStep3Page(key: _step3Key, onNext: _nextStep, canProceedNotifier: _step3CanProceed),
              LoveInputStep4Page(key: _step4Key, onNext: _nextStep, canProceedNotifier: _step4CanProceed),
            ],
          ),

          // Floating Progress Button (프로그레스 통합)
          _buildFloatingButton(),
        ],
      ),
    );
  }

  Widget _buildFloatingButton() {
    String buttonText;
    ValueNotifier<bool> canProceedNotifier;

    switch (_currentStep) {
      case 0:
        buttonText = '다음 단계로';
        canProceedNotifier = _step1CanProceed;
        break;
      case 1:
        buttonText = '다음 단계로';
        canProceedNotifier = _step2CanProceed;
        break;
      case 2:
        buttonText = '다음 단계로';
        canProceedNotifier = _step3CanProceed;
        break;
      case 3:
        buttonText = '연애운세 보기';
        canProceedNotifier = _step4CanProceed;
        break;
      default:
        return const SizedBox.shrink();
    }

    return ValueListenableBuilder<bool>(
      valueListenable: canProceedNotifier,
      builder: (context, canProceed, child) {
        return UnifiedButton.floating(
          text: buttonText,
          onPressed: canProceed ? _nextStep : null,
          isEnabled: canProceed,
          isLoading: false,
          style: UnifiedButtonStyle.primary,
          size: UnifiedButtonSize.large,
          showProgress: true,
          currentStep: _currentStep + 1,
          totalSteps: _totalSteps,
        );
      },
    );
  }
}
