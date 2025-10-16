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

  @override
  void dispose() {
    _pageController.dispose();
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
                    LoveInputStep1Page(onNext: _nextStep, key: ValueKey('step1_$_currentStep')),
                    LoveInputStep2Page(onNext: _nextStep, key: ValueKey('step2_$_currentStep')),
                    LoveInputStep3Page(onNext: _nextStep, key: ValueKey('step3_$_currentStep')),
                    LoveInputStep4Page(onNext: _nextStep, key: ValueKey('step4_$_currentStep')),
                  ],
                ),
              ),
            ],
          ),

          // Floating Bottom Button
          if (_currentStep < 3) _buildFloatingButton(),
        ],
      ),
    );
  }

  Widget _buildFloatingButton() {
    // Step 4는 인라인 버튼 사용, Step 1-3만 FloatingBottomButton 사용
    if (_currentStep >= 3) return const SizedBox.shrink();

    String buttonText;
    bool canProceed = false;

    switch (_currentStep) {
      case 0: // Step 1: 나이, 성별, 연애 상태
        canProceed = _loveFortuneData['gender'] != null &&
                     _loveFortuneData['relationshipStatus'] != null;
        buttonText = '다음 단계로';
        break;
      case 1: // Step 2: 연애 스타일, 중요한 가치
        canProceed = _loveFortuneData['datingStyles'] != null &&
                     (_loveFortuneData['datingStyles'] as List).isNotEmpty;
        buttonText = '다음 단계로';
        break;
      case 2: // Step 3: 이상형, 만남 장소, 원하는 관계
        canProceed = _loveFortuneData['preferredPersonality'] != null &&
                     (_loveFortuneData['preferredPersonality'] as List).isNotEmpty &&
                     _loveFortuneData['preferredMeetingPlaces'] != null &&
                     (_loveFortuneData['preferredMeetingPlaces'] as List).isNotEmpty &&
                     _loveFortuneData['relationshipGoal'] != null;
        buttonText = '다음 단계로';
        break;
      default:
        return const SizedBox.shrink();
    }

    return FloatingBottomButton(
      text: buttonText,
      onPressed: canProceed ? _nextStep : null,
      style: canProceed ? TossButtonStyle.primary : TossButtonStyle.secondary,
    );
  }
}