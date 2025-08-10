import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// 감성적인 로딩 체크리스트 위젯 (Monarch 스타일 - 롤링 애니메이션)
class EmotionalLoadingChecklist extends StatefulWidget {
  final VoidCallback? onComplete;
  
  const EmotionalLoadingChecklist({
    super.key,
    this.onComplete,
  });

  @override
  State<EmotionalLoadingChecklist> createState() => _EmotionalLoadingChecklistState();
}

class _EmotionalLoadingChecklistState extends State<EmotionalLoadingChecklist> 
    with TickerProviderStateMixin {
  late AnimationController _scrollController;
  late AnimationController _fadeController;
  late List<AnimationController> _checkControllers;
  
  final List<LoadingStep> _steps = [
    LoadingStep('오늘의 날씨 확인 중', '하늘의 기운을 읽고 있어요'),
    LoadingStep('사주팔자 분석 중', '당신의 운명을 해석하고 있어요'),
    LoadingStep('우주의 기운 해석 중', '별들의 메시지를 받고 있어요'),
    LoadingStep('행운의 요소 탐색 중', '오늘의 행운을 찾고 있어요'),
    LoadingStep('오늘의 이야기 생성 중', '특별한 이야기를 만들고 있어요'),
  ];
  
  int _currentStep = 0;
  double _scrollOffset = 0;
  
  @override
  void initState() {
    super.initState();
    _scrollController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _checkControllers = List.generate(
      _steps.length,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ),
    );
    
    _scrollController.addListener(() {
      if (mounted) {
        setState(() {
          _scrollOffset = _scrollController.value * 80; // 각 항목의 높이
        });
      }
    });
    
    _startAnimation();
  }
  
  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    for (int i = 0; i < _steps.length; i++) {
      if (!mounted) return;
      
      // 체크 애니메이션
      _checkControllers[i].forward();
      
      await Future.delayed(const Duration(milliseconds: 1200));
      
      if (i < _steps.length - 1) {
        // 다음 단계로 스크롤
        if (mounted) {
          setState(() {
            _currentStep = i + 1;
          });
          _scrollController.forward(from: 0);
        }
      }
    }
    
    // 모든 단계 완료
    await Future.delayed(const Duration(milliseconds: 800));
    if (mounted && widget.onComplete != null) {
      widget.onComplete!();
    }
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _fadeController.dispose();
    for (var controller in _checkControllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark 
            ? [
                const Color(0xFF1a1a2e),
                const Color(0xFF0f1624),
              ]
            : [
                Colors.white,
                const Color(0xFFF5F5F5),
              ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // 상단 타이틀
            Padding(
              padding: const EdgeInsets.only(top: 60, bottom: 20),
              child: Column(
                children: [
                  Text(
                    '오늘의 운세',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w200,
                      color: isDark ? Colors.white : Colors.black87,
                      letterSpacing: 2,
                    ),
                  ).animate()
                    .fadeIn(duration: 1.seconds)
                    .slideY(begin: -0.2, end: 0),
                  
                  const SizedBox(height: 8),
                  
                  Text(
                    '준비하고 있어요',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w300,
                      color: (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.6),
                    ),
                  ).animate()
                    .fadeIn(delay: 300.ms, duration: 800.ms),
                ],
              ),
            ),
            
            // 롤링 체크리스트 영역
            Expanded(
              child: Stack(
                children: [
                  // 중앙 포커스 인디케이터 (옵션)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: screenHeight * 0.25,
                    child: Container(
                      height: 80,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            Colors.transparent,
                            (isDark ? Colors.white : Colors.black).withValues(alpha: 0.02),
                            (isDark ? Colors.white : Colors.black).withValues(alpha: 0.02),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // 스크롤되는 리스트
                  AnimatedBuilder(
                    animation: _scrollController,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, -_currentStep * 80.0 + screenHeight * 0.25),
                        child: Column(
                          children: _steps.asMap().entries.map((entry) {
                            final index = entry.key;
                            final step = entry.value;
                            final isCompleted = index <= _currentStep;
                            final isActive = index == _currentStep;
                            final isPending = index > _currentStep;
                            
                            // 위치에 따른 투명도 계산
                            double opacity = 1.0;
                            if (index < _currentStep - 1) {
                              opacity = 0.1; // 완료된 이전 항목들은 매우 흐리게
                            } else if (index == _currentStep - 1) {
                              opacity = 0.3; // 바로 이전 항목은 약간 흐리게
                            } else if (index == _currentStep) {
                              opacity = 1.0; // 현재 항목은 완전 불투명
                            } else if (index == _currentStep + 1) {
                              opacity = 0.5; // 다음 항목은 반투명
                            } else {
                              opacity = 0.2; // 나머지는 흐리게
                            }
                            
                            return Container(
                              height: 80,
                              padding: const EdgeInsets.symmetric(horizontal: 40),
                              child: Opacity(
                                opacity: opacity,
                                child: _buildStepItem(
                                  step: step,
                                  isCompleted: index < _currentStep,
                                  isActive: isActive,
                                  isPending: isPending,
                                  isDark: isDark,
                                  animationController: _checkControllers[index],
                                  index: index,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      );
                    },
                  ),
                  
                  // 상하 그라데이션 마스크
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isDark
                            ? [
                                const Color(0xFF1a1a2e),
                                const Color(0xFF1a1a2e).withValues(alpha: 0),
                              ]
                            : [
                                Colors.white,
                                Colors.white.withValues(alpha: 0),
                              ],
                        ),
                      ),
                    ),
                  ),
                  
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 100,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: isDark
                            ? [
                                const Color(0xFF0f1624),
                                const Color(0xFF0f1624).withValues(alpha: 0),
                              ]
                            : [
                                const Color(0xFFF5F5F5),
                                const Color(0xFFF5F5F5).withValues(alpha: 0),
                              ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // 하단 로딩 인디케이터
            Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDark 
                      ? Colors.white.withValues(alpha: 0.3)
                      : Colors.black.withValues(alpha: 0.2),
                  ),
                ),
              ).animate(onPlay: (controller) => controller.repeat())
                .rotate(duration: 2.seconds),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStepItem({
    required LoadingStep step,
    required bool isCompleted,
    required bool isActive,
    required bool isPending,
    required bool isDark,
    required AnimationController animationController,
    required int index,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 체크박스/로딩
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          width: isActive ? 32 : 28,
          height: isActive ? 32 : 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted 
              ? const Color(0xFF52C41A).withValues(alpha: 0.15)
              : Colors.transparent,
            border: Border.all(
              color: isCompleted
                ? const Color(0xFF52C41A)
                : isActive 
                  ? (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.5)
                  : (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.2),
              width: isCompleted ? 2.5 : isActive ? 2 : 1.5,
            ),
          ),
          child: Center(
            child: AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                return Transform.scale(
                  scale: animationController.value,
                  child: isCompleted
                    ? Icon(
                        Icons.check,
                        size: isActive ? 18 : 16,
                        color: const Color(0xFF52C41A),
                      )
                    : isActive
                      ? SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              (isDark ? Colors.white : Colors.black87)
                                .withValues(alpha: 0.5),
                            ),
                          ),
                        )
                      : null,
                );
              },
            ),
          ),
        ),
        
        const SizedBox(width: 20),
        
        // 텍스트
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 400),
              style: TextStyle(
                fontSize: isActive ? 18 : 16,
                fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                color: isCompleted || isActive
                  ? (isDark ? Colors.white : Colors.black87)
                  : (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.5),
              ),
              child: Text(step.title),
            ),
            if (isActive) ...[
              const SizedBox(height: 4),
              Text(
                step.subtitle,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w300,
                  color: (isDark ? Colors.white : Colors.black87)
                      .withValues(alpha: 0.6),
                ),
              ).animate()
                .fadeIn(duration: 600.ms)
                .slideY(begin: -0.1, end: 0),
            ],
          ],
        ),
      ],
    );
  }
}

class LoadingStep {
  final String title;
  final String subtitle;
  
  LoadingStep(this.title, this.subtitle);
}