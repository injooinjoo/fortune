import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import '../presentation/providers/navigation_visibility_provider.dart';

/// 최적화된 감성적인 로딩 체크리스트 위젯 (픽셀 깨짐 방지)
class EmotionalLoadingChecklist extends ConsumerStatefulWidget {
  final VoidCallback? onComplete;
  final VoidCallback? onPreviewComplete;
  final bool isLoggedIn;
  final bool isApiComplete;
  
  const EmotionalLoadingChecklist({
    super.key,
    this.onComplete,
    this.onPreviewComplete,
    this.isLoggedIn = true,
    this.isApiComplete = false,
  });

  @override
  ConsumerState<EmotionalLoadingChecklist> createState() => _EmotionalLoadingChecklistState();
}

class _EmotionalLoadingChecklistState extends ConsumerState<EmotionalLoadingChecklist> 
    with TickerProviderStateMixin {
  
  // 애니메이션 컨트롤러 최소화
  late AnimationController _checkController;
  late Animation<double> _checkAnimation;
  
  // 전체 50개 감성적 로딩 메시지 (픽셀 깨짐 방지 최적화 적용)
  static const List<LoadingStep> _emotionalLoadingMessages = [
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
    LoadingStep('천체 움직임 계산 중', '행성들의 위치를 파악하고 있어요'),
    LoadingStep('음양오행 밸런스 분석 중', '당신의 에너지 균형을 확인하고 있어요'),
    LoadingStep('생년월일 진동 측정 중', '태어난 날의 특별한 에너지를 읽고 있어요'),
    LoadingStep('이름 궁합 계산 중', '당신 이름의 운세를 분석하고 있어요'),
    LoadingStep('오늘의 럭키 넘버 선별 중', '행운을 부를 숫자를 찾고 있어요'),
    LoadingStep('타로카드 에너지 읽는 중', '카드들이 전하는 메시지를 받고 있어요'),
    LoadingStep('수호천사 연결 중', '당신을 지켜주는 존재와 소통하고 있어요'),
    LoadingStep('과거생 인연 탐색 중', '전생에서 이어진 인연을 찾고 있어요'),
    LoadingStep('미래 가능성 스캔 중', '앞으로 일어날 일들을 엿보고 있어요'),
    LoadingStep('직업운 흐름 분석 중', '일터에서의 운세를 살펴보고 있어요'),
    LoadingStep('학업운 에너지 체크 중', '공부와 배움의 기운을 확인하고 있어요'),
    LoadingStep('가족운 조화 측정 중', '가족과의 관계 운세를 보고 있어요'),
    LoadingStep('친구운 자기장 분석 중', '친구들과의 인연을 살펴보고 있어요'),
    LoadingStep('여행운 경로 탐색 중', '떠남과 돌아옴의 운세를 보고 있어요'),
    LoadingStep('창작운 영감 수신 중', '예술과 창작의 기운을 받고 있어요'),
    LoadingStep('시험운 집중력 측정 중', '중요한 순간의 운세를 확인하고 있어요'),
    LoadingStep('투자운 흐름 예측 중', '돈의 흐름과 투자 운세를 보고 있어요'),
    LoadingStep('부동산운 터 기운 분석 중', '땅과 집의 에너지를 읽고 있어요'),
    LoadingStep('차량운 이동 에너지 체크 중', '교통과 이동의 운세를 확인하고 있어요'),
    LoadingStep('반려동물운 교감 측정 중', '동물 친구들과의 인연을 보고 있어요'),
    LoadingStep('취미운 열정 에너지 분석 중', '즐거움과 취미의 운세를 읽고 있어요'),
    LoadingStep('운동운 체력 기운 체크 중', '몸의 건강과 활력을 확인하고 있어요'),
    LoadingStep('다이어트운 의지력 측정 중', '몸매 관리 운세를 살펴보고 있어요'),
    LoadingStep('패션운 스타일 감각 분석 중', '옷차림과 멋의 운세를 보고 있어요'),
    LoadingStep('뷰티운 매력 지수 계산 중', '아름다움의 기운을 측정하고 있어요'),
    LoadingStep('요리운 맛의 조화 체크 중', '음식과 요리의 운세를 확인하고 있어요'),
    LoadingStep('독서운 지식 흡수력 분석 중', '책과 배움의 인연을 읽고 있어요'),
    LoadingStep('영화운 감성 공명 측정 중', '영상과 이야기의 운세를 보고 있어요'),
    LoadingStep('음악운 리듬 진동 분석 중', '소리와 멜로디의 기운을 읽고 있어요'),
    LoadingStep('게임운 승부 기운 체크 중', '놀이와 경쟁의 운세를 확인하고 있어요'),
    LoadingStep('쇼핑운 선택 감각 측정 중', '구매와 소비의 운세를 보고 있어요'),
    LoadingStep('소셜미디어운 인기 지수 분석 중', '온라인 인연과 소통 운세를 읽고 있어요'),
    LoadingStep('카페운 휴식 에너지 체크 중', '여유와 힐링의 기운을 확인하고 있어요'),
    LoadingStep('날씨운 자연 조화 측정 중', '하늘과 바람의 메시지를 받고 있어요'),
    LoadingStep('꽃운 생명력 기운 분석 중', '꽃과 식물의 에너지를 읽고 있어요'),
    LoadingStep('물운 정화 에너지 체크 중', '물의 흐름과 정화 운세를 보고 있어요'),
    LoadingStep('불운 열정 기운 측정 중', '태양과 열정의 에너지를 확인하고 있어요'),
    LoadingStep('바람운 변화 흐름 분석 중', '바람이 가져올 변화를 읽고 있어요'),
    LoadingStep('마지막 총운 조합 중', '모든 운세를 하나로 엮고 있어요'),
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
    
    // 애니메이션 컨트롤러 초기화 (하나만 사용)
    _checkController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    // 부드러운 애니메이션 설정
    _checkAnimation = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );
    
    _startAnimation();
  }

  @override
  void didUpdateWidget(covariant EmotionalLoadingChecklist oldWidget) {
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
      for (int i = 0; i < _emotionalLoadingMessages.length; i++) {
        if (_isCompleted || !mounted || widget.isApiComplete) {
          if (widget.isApiComplete && !_isCompleted) {
            _completeLoading();
          }
          return;
        }
        
        // 현재 단계 업데이트 (부드럽게)
        if (mounted) {
          setState(() {
            _currentStep = i;
          });
          
          // 체크 애니메이션 실행
          _checkController.forward();
        }
        
        // 적절한 대기 시간
        await Future.delayed(const Duration(milliseconds: 1800));
        
        // API 완료 체크
        if (_isCompleted || !mounted || widget.isApiComplete) {
          if (widget.isApiComplete && !_isCompleted) {
            _completeLoading();
          }
          return;
        }
        
        // 다음 스텝 준비
        if (i < _emotionalLoadingMessages.length - 1) {
          _checkController.reset();
        }
      }
      
      // 한 사이클 완료 후 초기화
      if (!_isCompleted && mounted && !widget.isApiComplete) {
        setState(() {
          _currentStep = 0;
        });
        _checkController.reset();
        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }
  
  @override
  void dispose() {
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
                Colors.white,
                const Color(0xFFF5F5F5),
              ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 80),
            
            // 최적화된 로딩 리스트 (픽셀 깨짐 방지)
            Expanded(
              child: Center(
                child: _OptimizedLoadingList(
                  steps: _emotionalLoadingMessages,
                  currentStep: _currentStep,
                  checkAnimation: _checkAnimation,
                  isDark: isDark,
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
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: steps.asMap().entries.map((entry) {
          final index = entry.key;
          final step = entry.value;
          final isCompleted = index < currentStep;
          final isActive = index == currentStep;
          
          // 가시성 최적화 - 현재 단계 주변만 표시
          if ((index - currentStep).abs() > 3) {
            return const SizedBox(height: 80); // 빈 공간 유지
          }
          
          // 부드러운 투명도 계산 (픽셀 깨짐 방지)
          double opacity = 1.0;
          if (index < currentStep - 2) {
            opacity = 0.0;
          } else if (index == currentStep - 2) {
            opacity = 0.1;
          } else if (index == currentStep - 1) {
            opacity = 0.4;
          } else if (index == currentStep) {
            opacity = 1.0;
          } else if (index == currentStep + 1) {
            opacity = 0.4;
          } else if (index == currentStep + 2) {
            opacity = 0.1;
          } else {
            opacity = 0.0;
          }
          
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 600), // 부드러운 전환
            opacity: opacity,
            curve: Curves.easeInOutCubic,
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
      ),
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
        // 최적화된 체크박스 (픽셀 완벽 정렬)
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted 
              ? const Color(0xFF52C41A).withValues(alpha: 0.15)
              : Colors.transparent,
            border: Border.all(
              color: isCompleted
                ? const Color(0xFF52C41A)
                : isActive 
                  ? (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.6)
                  : (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.3),
              width: isCompleted ? 2.5 : isActive ? 2.2 : 1.8,
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
                          size: 18,
                          color: const Color(0xFF52C41A),
                        )
                      : (isActive 
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  isDark ? Colors.white.withValues(alpha: 0.7) : Colors.black54
                                ),
                              ),
                            )
                          : null),
                  );
                },
              )
            : (isCompleted
                ? Icon(
                    Icons.check,
                    size: 18,
                    color: const Color(0xFF52C41A),
                  )
                : null),
        ),
        
        const SizedBox(width: 20),
        
        // 최적화된 텍스트 (픽셀 완벽 정렬)
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                step.title,
                style: TextStyle(
                  fontSize: isActive ? 18 : 16,
                  fontWeight: isActive ? FontWeight.w500 : FontWeight.w400,
                  color: isCompleted || isActive
                    ? (isDark ? Colors.white : Colors.black87)
                    : (isDark ? Colors.white : Colors.black87).withValues(alpha: 0.5),
                  height: 1.3, // 라인 높이 고정으로 픽셀 깨짐 방지
                ),
              ),
              if (isActive) ...[
                const SizedBox(height: 4),
                AnimatedOpacity(
                  duration: const Duration(milliseconds: 400),
                  opacity: 1.0,
                  child: Text(
                    step.subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w300,
                      color: (isDark ? Colors.white : Colors.black87)
                          .withValues(alpha: 0.6),
                      height: 1.3, // 라인 높이 고정으로 픽셀 깨짐 방지
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