import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/theme/toss_design_system.dart';
import '../presentation/providers/navigation_visibility_provider.dart';
import '../core/theme/typography_unified.dart';

/// 최적화된 감성적인 로딩 체크리스트 위젯
class EmotionalLoadingChecklistOptimized extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;
  final VoidCallback? onPreviewComplete;
  final bool isLoggedIn;
  final bool isApiComplete;
  
  const EmotionalLoadingChecklistOptimized({
    super.key,
    this.onComplete,
    this.onPreviewComplete,
    this.isLoggedIn = true,
    this.isApiComplete = false,
  });

  @override
  ConsumerState<EmotionalLoadingChecklistOptimized> createState() => _EmotionalLoadingChecklistOptimizedState();
}

class _EmotionalLoadingChecklistOptimizedState extends ConsumerState<EmotionalLoadingChecklistOptimized> 
    with TickerProviderStateMixin {
  
  // 애니메이션 컨트롤러 최소화
  late AnimationController _scrollController;
  late AnimationController _checkController; // 하나의 체크 컨트롤러만 사용
  late Animation<double> _checkAnimation;
  
  // 로딩 메시지는 핵심만 12개로 줄임
  static const List<LoadingStep> _coreLoadingMessages = [
    LoadingStep('오늘의 날씨 확인 중', '하늘의 기운을 읽고 있어요'),
    LoadingStep('사주팔자 분석 중', '당신의 운명을 해석하고 있어요'),
    LoadingStep('우주의 기운 해석 중', '별들의 메시지를 받고 있어요'),
    LoadingStep('오늘의 행운 색상 선별 중', '당신만의 특별한 색을 찾고 있어요'),
    LoadingStep('길운 방향 탐색 중', '오늘의 좋은 방향을 확인하고 있어요'),
    LoadingStep('오늘의 귀인 찾는 중', '당신을 도울 사람을 찾고 있어요'),
    LoadingStep('금전운 파동 분석 중', '재물의 흐름을 읽고 있어요'),
    LoadingStep('연애운 기류 측정 중', '사랑의 에너지를 확인하고 있어요'),
    LoadingStep('건강운 지수 확인 중', '몸과 마음의 건강을 체크하고 있어요'),
    LoadingStep('시간대별 운세 정리 중', '하루 시간의 흐름을 정리하고 있어요'),
    LoadingStep('오늘의 조언 준비 중', '현명한 말씀을 준비하고 있어요'),
    LoadingStep('마지막 행운 체크 중', '모든 준비가 완료되었는지 확인하고 있어요'),
  ];
  
  int _currentStep = 0;
  bool _isCompleted = false;
  
  @override
  void initState() {
    super.initState();
    
    // 네비게이션 바 숨기기
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(navigationVisibilityProvider.notifier).hide();
    });
    
    // 애니메이션 컨트롤러 초기화
    _scrollController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    // 애니메이션 생성
    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );
    
    _startAnimation();
  }

  @override
  void didUpdateWidget(covariant EmotionalLoadingChecklistOptimized oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // API 완료 신호가 오면 로딩 완료 처리
    if (widget.isApiComplete && !oldWidget.isApiComplete && !_isCompleted) {
      _completeLoading();
    }
  }
  
  void _completeLoading() {
    if (_isCompleted || !mounted) return;
    
    setState(() {
      _isCompleted = true;
    });
    
    debugPrint('✅ Loading animation completed by API');
    if (widget.isLoggedIn) {
      widget.onComplete?.call();
    } else {
      widget.onPreviewComplete?.call();
    }
  }
  
  void _startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    while (!_isCompleted && mounted && !widget.isApiComplete) {
      for (int i = 0; i < _coreLoadingMessages.length; i++) {
        if (_isCompleted || !mounted || widget.isApiComplete) {
          if (widget.isApiComplete && !_isCompleted) {
            _completeLoading();
          }
          return;
        }
        
        // 현재 단계 업데이트
        if (mounted) {
          setState(() {
            _currentStep = i;
          });
          
          // 체크 애니메이션 실행
          _checkController.forward();
        }
        
        // 잠시 대기
        await Future.delayed(const Duration(milliseconds: 1500));
        
        // API 완료 체크
        if (_isCompleted || !mounted || widget.isApiComplete) {
          if (widget.isApiComplete && !_isCompleted) {
            _completeLoading();
          }
          return;
        }
        
        // 다음 스텝으로 스크롤 (마지막이 아닌 경우)
        if (i < _coreLoadingMessages.length - 1) {
          _scrollController.forward();
          await _scrollController.forward();
          _scrollController.reset();
          _checkController.reset();
        }
      }
      
      // 한 사이클 완료 후 초기화
      if (!_isCompleted && mounted && !widget.isApiComplete) {
        setState(() {
          _currentStep = 0;
        });
        _checkController.reset();
        await Future.delayed(const Duration(milliseconds: 300));
      }
    }
  }
  
  @override
  void dispose() {
    _scrollController.dispose();
    _checkController.dispose();
    
    // 네비게이션 바 복원
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(navigationVisibilityProvider.notifier).show();
      }
    });
    
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                TossDesignSystem.white,
                const Color(0xFFF5F5F5),
              ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 60),

            // 최적화된 로딩 리스트
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 40.0),
                child: Center(
                  child: _OptimizedLoadingList(
                    steps: _coreLoadingMessages,
                    currentStep: _currentStep,
                    checkAnimation: _checkAnimation,
                    isDark: isDark,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 최적화된 로딩 리스트 위젯 (별도 위젯으로 분리하여 리빌드 최소화)
class _OptimizedLoadingList extends StatelessWidget {
  final List<LoadingStep> steps;
  final int currentStep;
  final Animation<double> checkAnimation;
  final bool isDark;
  
  const _OptimizedLoadingList({
    required this.steps,
    required this.currentStep,
    required this.checkAnimation,
    required this.isDark,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;
        final isCompleted = index < currentStep;
        final isActive = index == currentStep;
        
        // 가시성 최적화 - 현재 단계 주변만 표시
        if ((index - currentStep).abs() > 2) {
          return const SizedBox(height: 80); // 빈 공간 유지
        }
        
        double opacity = 1.0;
        if (index < currentStep - 1) {
          opacity = 0.3;
        } else if (index == currentStep - 1) {
          opacity = 0.5;
        } else if (index == currentStep) {
          opacity = 1.0;
        } else if (index == currentStep + 1) {
          opacity = 0.5;
        } else {
          opacity = 0.2;
        }
        
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 300),
          opacity: opacity,
          child: Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: _OptimizedStepItem(
              step: step,
              isCompleted: isCompleted,
              isActive: isActive,
              isDark: isDark,
              checkAnimation: isActive ? checkAnimation : null,
            ),
          ),
        );
      }).toList(),
    );
  }
}

/// 최적화된 스텝 아이템 (StatelessWidget으로 변경하여 성능 향상)
class _OptimizedStepItem extends StatelessWidget {
  final LoadingStep step;
  final bool isCompleted;
  final bool isActive;
  final bool isDark;
  final Animation<double>? checkAnimation;
  
  const _OptimizedStepItem({
    required this.step,
    required this.isCompleted,
    required this.isActive,
    required this.isDark,
    this.checkAnimation,
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 최적화된 체크박스
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: isActive ? 32 : 28,
          height: isActive ? 32 : 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted 
              ? const Color(0xFF52C41A).withValues(alpha: 0.15)
              : TossDesignSystem.transparent,
            border: Border.all(
              color: isCompleted
                ? const Color(0xFF52C41A)
                : isActive 
                  ? (isDark ? TossDesignSystem.white : TossDesignSystem.black).withValues(alpha: 0.5)
                  : (isDark ? TossDesignSystem.white : TossDesignSystem.black).withValues(alpha: 0.2),
              width: isCompleted ? 2.5 : isActive ? 2 : 1.5,
            ),
          ),
          child: checkAnimation != null
            ? AnimatedBuilder(
                animation: checkAnimation!,
                builder: (context, child) {
                  return Transform.scale(
                    scale: checkAnimation!.value,
                    child: isCompleted || checkAnimation!.value > 0.5
                      ? Icon(
                          Icons.check,
                          size: isActive ? 18 : 16,
                          color: const Color(0xFF52C41A),
                        )
                      : null,
                  );
                },
              )
            : (isCompleted
                ? Icon(
                    Icons.check,
                    size: isActive ? 18 : 16,
                    color: const Color(0xFF52C41A),
                  )
                : null),
        ),
        
        const SizedBox(width: 20),
        
        // 최적화된 텍스트
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: isActive ? 18 : 16,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                  color: isCompleted || isActive
                    ? (isDark ? TossDesignSystem.white : TossDesignSystem.black)
                    : (isDark ? TossDesignSystem.white : TossDesignSystem.black).withValues(alpha: 0.5),
                ),
                child: Text(step.title),
              ),
              if (isActive) ...[
                const SizedBox(height: 4),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 300),
                  opacity: 1.0,
                  child: Text(
                    step.subtitle,
                    style: TypographyUnified.bodySmall.copyWith(
                      fontWeight: FontWeight.w300,
                      color: (isDark ? TossDesignSystem.white : TossDesignSystem.black)
                          .withValues(alpha: 0.6),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class LoadingStep {
  final String title;
  final String subtitle;
  
  const LoadingStep(this.title, this.subtitle);
}