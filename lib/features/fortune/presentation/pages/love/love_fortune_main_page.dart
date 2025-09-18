import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/toss_theme.dart';
import '../../../../../core/theme/toss_design_system.dart';
import '../../../../../shared/components/toss_button.dart';
import '../../../../../services/ad_service.dart';
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
  Map<String, dynamic> _loveFortuneData = {};

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
    print('[LoveFortune] _showResults called');

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
    print('[LoveFortune] Attempting to show interstitial ad...');
    await AdService.instance.showInterstitialAdWithCallback(
      onAdCompleted: () {
        print('[LoveFortune] Ad completed successfully');
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
      onAdFailed: () {
        print('[LoveFortune] Ad failed to load or show');
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
      backgroundColor: isDark ? TossDesignSystem.grayDark900 : TossTheme.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          child: IconButton(
            onPressed: _currentStep == 0 ? () => Navigator.pop(context) : _previousStep,
            style: IconButton.styleFrom(
              backgroundColor: isDark ? TossDesignSystem.grayDark700 : TossTheme.backgroundSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
              size: 20,
            ),
          ),
        ),
        title: Text(
          '연애운세',
          style: TossTheme.heading3.copyWith(
            color: isDark ? TossDesignSystem.white : TossTheme.textBlack,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
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
                LoveInputStep1Page(onNext: _nextStep),
                LoveInputStep2Page(onNext: _nextStep),
                LoveInputStep3Page(onNext: _nextStep),
                LoveInputStep4Page(onNext: _nextStep),
              ],
            ),
          ),
        ],
      ),
    );
  }
}