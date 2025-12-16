import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../../core/design_system/design_system.dart';
import '../../../../../core/widgets/unified_button.dart';
import 'moving_fortune_data.dart';
import 'moving_fortune_generator.dart';
import 'moving_result_header.dart';
import 'moving_page_indicator.dart';
import 'moving_overview_page.dart';
import 'moving_timing_page.dart';
import 'moving_direction_page.dart';
import 'moving_checklist_page.dart';
import 'moving_budget_page.dart';

/// 인포그래픽 스타일 이사운 결과 페이지
class MovingResultInfographic extends StatefulWidget {
  final String name;
  final DateTime birthDate;
  final String currentArea;
  final String targetArea;
  final String movingPeriod;
  final String purpose;
  final VoidCallback onRetry;

  const MovingResultInfographic({
    super.key,
    required this.name,
    required this.birthDate,
    required this.currentArea,
    required this.targetArea,
    required this.movingPeriod,
    required this.purpose,
    required this.onRetry,
  });

  @override
  State<MovingResultInfographic> createState() => _MovingResultInfographicState();
}

class _MovingResultInfographicState extends State<MovingResultInfographic>
    with TickerProviderStateMixin {

  late PageController _pageController;
  int _currentPage = 0;

  // 운세 데이터
  late MovingFortuneData _fortuneData;

  // 애니메이션 컨트롤러들
  late AnimationController _fadeController;
  late AnimationController _scoreController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scoreAnimation;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _fortuneData = MovingFortuneGenerator.generateFortuneData(
      birthDate: widget.birthDate,
      purpose: widget.purpose,
    );
    _initAnimations();
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _scoreController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOut),
    );

    _scoreAnimation = Tween<double>(begin: 0, end: _fortuneData.overallScore / 100).animate(
      CurvedAnimation(parent: _scoreController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      _scoreController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DSColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // 상단 헤더
                MovingResultHeader(
                  name: widget.name,
                  onBack: () => Navigator.of(context).pop(),
                ),

                // 페이지 인디케이터
                MovingPageIndicator(currentPage: _currentPage),

                // 메인 콘텐츠 (PageView)
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: PageView(
                      controller: _pageController,
                      onPageChanged: (index) {
                        setState(() => _currentPage = index);
                        HapticFeedback.lightImpact();
                      },
                      children: [
                        MovingOverviewPage(
                          fortuneData: _fortuneData,
                          scoreAnimation: _scoreAnimation,
                          purpose: widget.purpose,
                        ),
                        MovingTimingPage(fortuneData: _fortuneData),
                        MovingDirectionPage(
                          fortuneData: _fortuneData,
                          currentArea: widget.currentArea,
                        ),
                        MovingChecklistPage(fortuneData: _fortuneData),
                        MovingBudgetPage(fortuneData: _fortuneData),
                      ],
                    ),
                  ),
                ),

                // 하단 버튼 공간 확보
                const BottomButtonSpacing(),
              ],
            ),

            // Floating 버튼
            UnifiedButton.floating(
              text: '다시 보기',
              onPressed: widget.onRetry,
              isEnabled: true,
              isLoading: false,
              icon: const Icon(Icons.refresh, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _fadeController.dispose();
    _scoreController.dispose();
    super.dispose();
  }
}
