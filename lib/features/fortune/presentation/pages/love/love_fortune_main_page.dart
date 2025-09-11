import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/toss_theme.dart';
import '../../../../../shared/components/toss_button.dart';
import 'love_input_step1_page.dart';
import 'love_input_step2_page.dart';
import 'love_input_step3_page.dart';
import 'love_input_step4_page.dart';
// import 'love_fortune_result_page.dart'; // Removed - unused

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

  void _showResults() {
    // 결과 표시 - 현재 페이지에서 처리하거나 다이얼로그로 표시
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('연애운세 결과'),
        content: Text('결과가 저장되었습니다.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text('확인'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossTheme.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Container(
          margin: const EdgeInsets.only(left: 16),
          child: IconButton(
            onPressed: _currentStep == 0 ? () => Navigator.pop(context) : _previousStep,
            style: IconButton.styleFrom(
              backgroundColor: TossTheme.backgroundSecondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: TossTheme.textBlack,
              size: 20,
            ),
          ),
        ),
        title: Text(
          '연애운세',
          style: TossTheme.heading3.copyWith(
            color: TossTheme.textBlack,
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
                        color: TossTheme.textGray600,
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
                  backgroundColor: TossTheme.borderGray200,
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