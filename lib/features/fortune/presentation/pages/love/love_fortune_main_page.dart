import 'package:flutter/material.dart';
import '../../../../../core/theme/toss_theme.dart';
import '../../../../../core/theme/toss_design_system.dart';
import '../../../../../services/ad_service.dart';
import '../../../../../shared/components/floating_bottom_button.dart';
import '../../../../../shared/components/toss_button.dart';
import '../../widgets/standard_fortune_app_bar.dart';
import 'love_input_step1_page.dart';
import 'love_input_step2_page.dart';
import 'love_input_step3_page.dart';
import 'love_input_step4_page.dart';
import 'love_fortune_result_page.dart';

class LoveFortuneMainPage extends StatefulWidget {
  const LoveFortuneMainPage({super.key});

  @override
  State<LoveFortuneMainPage> createState() => _LoveFortuneMainPageState();
}

class _LoveFortuneMainPageState extends State<LoveFortuneMainPage> {
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
    if (stepData != null) {
      _loveFortuneData.addAll(stepData);
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

  void _showResults() async {
    debugPrint('[LoveFortune] _showResults called');

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

    // 광고 표시
    debugPrint('[LoveFortune] Attempting to show interstitial ad...');
    await AdService.instance.showInterstitialAdWithCallback(
      onAdCompleted: () async {
        debugPrint('[LoveFortune] Ad completed successfully');
        // 로딩 다이얼로그 닫기
        Navigator.of(context).pop();

        // 결과 페이지로 이동
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LoveFortuneResultPage(
              fortuneData: _loveFortuneData,
            ),
          ),
        );
      },
      onAdFailed: () async {
        debugPrint('[LoveFortune] Ad failed to load or show');
        // 로딩 다이얼로그 닫기
        Navigator.of(context).pop();

        // 광고 실패해도 결과 페이지로 이동
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LoveFortuneResultPage(
              fortuneData: _loveFortuneData,
            ),
          ),
        );
      },
    );
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
          Column(
            children: [
              // Progress Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_currentStep + 1} / $_totalSteps',
                          style: TossTheme.body2.copyWith(
                            color: isDark ? TossDesignSystem.grayDark100 : TossTheme.textGray600,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '${((_currentStep + 1) / _totalSteps * 100).round()}%',
                          style: TossTheme.body2.copyWith(
                            color: TossTheme.primaryBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: (_currentStep + 1) / _totalSteps,
                      backgroundColor: isDark ? TossDesignSystem.grayDark600 : TossTheme.borderGray200,
                      valueColor: const AlwaysStoppedAnimation<Color>(TossTheme.primaryBlue),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ],
                ),
              ),

              // Page Content
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    LoveInputStep1Page(onNext: _nextStep, canProceedNotifier: _step1CanProceed),
                    LoveInputStep2Page(onNext: _nextStep, canProceedNotifier: _step2CanProceed),
                    LoveInputStep3Page(onNext: _nextStep, canProceedNotifier: _step3CanProceed),
                    LoveInputStep4Page(onNext: _nextStep, canProceedNotifier: _step4CanProceed),
                  ],
                ),
              ),
            ],
          ),

          // Floating Bottom Button (모든 스텝에서 표시)
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
        return FloatingBottomButton(
          text: buttonText,
          onPressed: canProceed ? _nextStep : null,
          style: canProceed ? TossButtonStyle.primary : TossButtonStyle.secondary,
        );
      },
    );
  }
}