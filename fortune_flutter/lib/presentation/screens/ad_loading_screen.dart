import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/logger.dart';

class AdLoadingScreen extends ConsumerStatefulWidget {
  final String fortuneType;
  final String fortuneTitle;
  final VoidCallback onComplete;
  final VoidCallback onSkip;
  final bool isPremium;
  final Future<dynamic> Function()? fetchData;
  final Future<void> Function()? onAdComplete;
  final String? fortuneRoute; // Add route parameter for navigation
  final Map<String, dynamic>? fortuneParams; // Parameters for fortune generation

  const AdLoadingScreen({
    super.key,
    required this.fortuneType,
    required this.fortuneTitle,
    required this.onComplete,
    required this.onSkip,
    required this.isPremium,
    this.fetchData,
    this.onAdComplete,
    this.fortuneRoute,
    this.fortuneParams,
  });

  @override
  ConsumerState<AdLoadingScreen> createState() => _AdLoadingScreenState();
}

class _AdLoadingScreenState extends ConsumerState<AdLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  Timer? _timer;
  int _remainingSeconds = 5;
  bool _isLoading = true;
  dynamic _fetchedData;
  String? _errorMessage;
  bool _canProceed = false; // 버튼 활성화 상태

  // 운세별 로딩 메시지
  final Map<String, List<String>> _loadingMessages = {
    'default': [
      '✨ 우주의 신비로운 기운이 모이고 있습니다...',
      '🌙 달빛이 당신의 미래를 비추고 있습니다...',
      '⭐ 별들이 속삭이는 비밀을 해독하고 있습니다...',
      '🔮 수정구슬에 당신의 운명이 나타나고 있습니다...',
      '✨ 천상의 지혜가 당신만을 위해 내려오고 있습니다...',
      '🌟 운명의 실이 풀리고 있습니다... 거의 다 되었어요!',
    ],
    'saju': [
      '🎎 천간지지가 춤을 추며 배열되고 있습니다...',
      '☯️ 음양의 조화가 당신의 사주를 밝혀내고 있습니다...',
      '🌸 오행의 꽃이 피어나며 운명을 그려냅니다...',
      '🎋 백년의 지혜가 당신의 팔자를 읽고 있습니다...',
      '🏮 운명의 등불이 당신의 길을 비추고 있습니다...',
      '✨ 하늘이 내린 당신만의 사주가 완성되어갑니다...',
    ],
    'tarot': [
      '🃏 신비로운 힘이 카드를 섞고 있습니다...',
      '🌙 달의 여신이 당신의 카드를 선택하고 있습니다...',
      '✨ 운명의 카드가 빛을 발하며 떠오릅니다...',
      '🔮 고대의 지혜가 카드에 깃들고 있습니다...',
      '⚡ 우주의 메시지가 카드를 통해 전달되고 있습니다...',
      '🌟 당신만을 위한 신탁이 준비되었습니다...',
    ],
    'love': [
      '💕 큐피드가 사랑의 화살을 준비하고 있습니다...',
      '🌹 붉은 실이 인연을 찾아 헤매고 있습니다...',
      '💖 두 영혼의 주파수를 측정하고 있습니다...',
      '🦋 사랑의 나비가 운명의 꽃을 찾고 있습니다...',
      '💫 별똥별이 당신의 사랑을 축복하고 있습니다...',
      '💘 운명의 연인이 가까이 있습니다... 잠시만요!',
    ],
    'zodiac': [
      '♈ 열두 별자리가 춤을 추며 모이고 있습니다...',
      '🌌 은하수가 당신의 별자리를 비추고 있습니다...',
      '⚡ 행성들이 정렬하며 메시지를 전합니다...',
      '🪐 토성의 고리가 당신의 운명을 감싸고 있습니다...',
      '☄️ 혜성이 당신만의 특별한 운세를 싣고 옵니다...',
      '✨ 우주의 법칙이 당신의 미래를 그려냅니다...',
    ],
    'dream': [
      '🌙 꿈의 세계로 들어가고 있습니다...',
      '✨ 무의식의 메시지를 해독하고 있습니다...',
      '🔮 꿈속 상징들의 의미를 찾고 있습니다...',
      '💫 심리학적 통찰을 준비하고 있습니다...',
      '🌟 당신의 꿈이 전하는 메시지를 분석합니다...',
      '🎭 꿈의 비밀이 곧 밝혀집니다...',
    ],
  };

  String _currentMessage = '';
  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();
    Logger.info('AdLoadingScreen opened for ${widget.fortuneType}');
    
    _animationController = AnimationController(
      duration: Duration(seconds: widget.isPremium ? 2 : 5),
      vsync: this,
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _startLoading();
  }

  void _startLoading() async {
    // 로딩 메시지 설정
    final messages = _loadingMessages[widget.fortuneType] ?? _loadingMessages['default']!;
    _currentMessage = messages[0];

    // 메시지 변경 타이머
    Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _messageIndex = (_messageIndex + 1) % messages.length;
        _currentMessage = messages[_messageIndex];
      });
    });

    // 프리미엄 사용자는 바로 데이터 로드
    if (widget.isPremium) {
      _animationController.forward();
      await _fetchFortuneData();
      if (mounted) {
        widget.onComplete();
      }
      return;
    }

    // 무료 사용자는 광고 로딩
    _animationController.forward();
    
    // 카운트다운 타이머
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _remainingSeconds--;
      });

      if (_remainingSeconds <= 0) {
        timer.cancel();
        setState(() {
          _canProceed = true; // 버튼 활성화
        });
      }
    });

    // 동시에 데이터 페치
    _fetchFortuneData();
  }

  Future<void> _fetchFortuneData() async {
    if (widget.fetchData == null) return;

    try {
      final stopwatch = Logger.startTimer('Fortune data fetch');
      _fetchedData = await widget.fetchData!();
      Logger.endTimer('Fortune data fetch', stopwatch);
      
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      Logger.error('Failed to fetch fortune data', error);
      setState(() {
        _isLoading = false;
        _errorMessage = '운세 데이터를 불러오는데 실패했습니다.';
      });
    }
  }

  void _completeLoading() async {
    if (_errorMessage != null) {
      // 에러가 있으면 다시 시도하거나 뒤로 가기
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          action: SnackBarAction(
            label: '다시 시도',
            onPressed: () {
              setState(() {
                _errorMessage = null;
                _isLoading = true;
                _remainingSeconds = 5;
              });
              _startLoading();
            },
          ),
        ),
      );
      return;
    }

    // 데이터가 아직 로딩 중이면 잠시 대기
    if (_isLoading && widget.fetchData != null) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          _completeLoading();
        }
      });
      return;
    }

    // 무료 사용자의 경우 광고 시청 완료 후 토큰 보상
    if (!widget.isPremium && widget.onAdComplete != null) {
      try {
        await widget.onAdComplete!();
        Logger.analytics('token_reward_for_ad', {
          'fortune_type': widget.fortuneType,
        });
      } catch (e) {
        Logger.error('Failed to reward tokens for ad', e);
        // 토큰 보상 실패해도 운세는 보여줌
      }
    }

    Logger.analytics('ad_loading_complete', {
      'fortune_type': widget.fortuneType,
      'is_premium': widget.isPremium,
    });

    // If fortune route is provided, navigate to it
    if (widget.fortuneRoute != null && mounted) {
      try {
        print('[AdLoadingScreen] Navigating to: ${widget.fortuneRoute}');
        print('[AdLoadingScreen] Fortune params: ${widget.fortuneParams}');
        
        // Pass any fetched data or params to the fortune page
        // Add a flag to indicate fortune should be auto-generated
        context.pushReplacement(
          widget.fortuneRoute!,
          extra: {
            'fortuneData': _fetchedData,
            'fortuneParams': widget.fortuneParams,
            'autoGenerate': true, // Flag to auto-generate fortune
          },
        );
        print('[AdLoadingScreen] Navigation successful');
      } catch (e) {
        print('[AdLoadingScreen] Navigation error: $e');
        if (mounted) {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('페이지 이동 중 오류가 발생했습니다: $e'),
              backgroundColor: Colors.red,
            ),
          );
          // Navigate back
          Navigator.of(context).pop();
        }
      }
    } else {
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  // 별빛 파티클 생성을 위한 메서드
  Widget _buildStarParticle(int index) {
    final random = index * 0.1;
    final size = 2.0 + (index % 3) * 2.0;
    
    return Positioned(
      left: (index * 77 % 100) / 100 * MediaQuery.of(context).size.width,
      top: (index * 31 % 100) / 100 * MediaQuery.of(context).size.height,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.8),
              blurRadius: size * 2,
              spreadRadius: size / 2,
            ),
          ],
        ),
      )
          .animate(
            onPlay: (controller) => controller.repeat(),
          )
          .scale(
            duration: Duration(milliseconds: 2000 + (index * 200 % 1000)),
            begin: const Offset(0.0, 0.0),
            end: const Offset(1.0, 1.0),
            curve: Curves.easeInOut,
          )
          .then()
          .scale(
            duration: Duration(milliseconds: 2000 + (index * 200 % 1000)),
            begin: const Offset(1.0, 1.0),
            end: const Offset(0.0, 0.0),
            curve: Curves.easeInOut,
          )
          .shimmer(
            duration: 3.seconds,
            delay: Duration(milliseconds: index * 100),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black87,
        body: SafeArea(
          child: Stack(
            children: [
              // 배경 애니메이션
              Positioned.fill(
                child: AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.purple.shade900.withValues(alpha: 0.3),
                            Colors.indigo.shade900.withValues(alpha: 0.3),
                          ],
                          transform: GradientRotation(
                            _animationController.value * 2 * 3.14159,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // 별빛 파티클 효과
              ...List.generate(20, (index) => _buildStarParticle(index)),
              
              // 메인 컨텐츠
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 아이콘 애니메이션
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // 외부 광환 효과
                          Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.purple.withValues(alpha: 0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ).animate(
                            onPlay: (controller) => controller.repeat(),
                          ).scale(
                            duration: 3.seconds,
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.2, 1.2),
                          ).fadeOut(
                            duration: 3.seconds,
                            curve: Curves.easeOut,
                          ),
                          
                          // 중간 광환 효과
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.2),
                                width: 2,
                              ),
                            ),
                          ).animate(
                            onPlay: (controller) => controller.repeat(),
                          ).rotate(
                            duration: 10.seconds,
                          ).scale(
                            duration: 2.seconds,
                            begin: const Offset(1.0, 1.0),
                            end: const Offset(1.1, 1.1),
                          ).then().scale(
                            duration: 2.seconds,
                            begin: const Offset(1.1, 1.1),
                            end: const Offset(1.0, 1.0),
                          ),
                          
                          // 메인 아이콘
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.white.withValues(alpha: 0.2),
                                  Colors.white.withValues(alpha: 0.05),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.purple.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                  spreadRadius: 5,
                                ),
                              ],
                            ),
                            child: Icon(
                              Icons.auto_awesome,
                              size: 50,
                              color: Colors.white,
                            ),
                          ).animate(
                            onPlay: (controller) => controller.repeat(),
                          ).scale(
                            duration: 2.seconds,
                            begin: const Offset(0.95, 0.95),
                            end: const Offset(1.05, 1.05),
                            curve: Curves.easeInOut,
                          ).shimmer(
                            duration: 2.seconds,
                            color: Colors.white.withValues(alpha: 0.3),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // 타이틀
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          colors: [
                            Colors.white,
                            Theme.of(context).colorScheme.secondary,
                            Theme.of(context).colorScheme.primary,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(bounds),
                        child: Text(
                          widget.fortuneTitle,
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      )
                          .animate()
                          .fadeIn(duration: 800.ms)
                          .slideY(begin: -0.3, end: 0, curve: Curves.easeOutBack)
                          .scale(
                            begin: const Offset(0.8, 0.8),
                            end: const Offset(1.0, 1.0),
                            duration: 600.ms,
                            curve: Curves.easeOutBack,
                          )
                          .blur(begin: const Offset(5, 5), end: Offset.zero),
                      
                      const SizedBox(height: 24),
                      
                      // 로딩 메시지
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 800),
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0.0, 0.3),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              )),
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          _currentMessage,
                          key: ValueKey(_currentMessage),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                            height: 1.5,
                            letterSpacing: 0.5,
                            shadows: [
                              Shadow(
                                color: Colors.purple.withValues(alpha: 0.5),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // 프로그레스 바
                      Container(
                        height: 8,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: AnimatedBuilder(
                          animation: _progressAnimation,
                          builder: (context, child) {
                            return FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: _progressAnimation.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Theme.of(context).colorScheme.primary,
                                      Theme.of(context).colorScheme.secondary,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              )
                                  .animate(
                                    onPlay: (controller) => controller.repeat(),
                                  )
                                  .shimmer(
                                    duration: 1.5.seconds,
                                    color: Colors.white.withValues(alpha: 0.3),
                                  ),
                            );
                          },
                        ),
                      )
                          .animate()
                          .fadeIn()
                          .scale(
                            begin: const Offset(0.95, 0.95),
                            end: const Offset(1.0, 1.0),
                            duration: 500.ms,
                          ),
                      
                      const SizedBox(height: 16),
                      
                      // 남은 시간 표시 또는 버튼 (무료 사용자만)
                      if (!widget.isPremium) ...[
                        if (_remainingSeconds > 0)
                          Text(
                            '${_remainingSeconds}초 후에 운세를 확인할 수 있습니다',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white60,
                            ),
                          ).animate().fadeIn(delay: 300.ms),
                        
                        if (_canProceed) ...[
                          const SizedBox(height: 24),
                          // 운세 확인 버튼 컨테이너
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // 버튼 뒤 광환 효과
                              Container(
                                width: 250,
                                height: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40),
                                  gradient: RadialGradient(
                                    colors: [
                                      Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                      Colors.transparent,
                                    ],
                                  ),
                                ),
                              )
                                  .animate(
                                    onPlay: (controller) => controller.repeat(),
                                  )
                                  .scale(
                                    duration: 1.5.seconds,
                                    begin: const Offset(0.9, 0.9),
                                    end: const Offset(1.1, 1.1),
                                  )
                                  .fadeIn()
                                  .fadeOut(delay: 1.seconds),
                              
                              // 버튼
                              ElevatedButton(
                                onPressed: _completeLoading,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Theme.of(context).colorScheme.primary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 8,
                                  shadowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.stars, size: 24)
                                        .animate(
                                          onPlay: (controller) => controller.repeat(),
                                        )
                                        .rotate(duration: 3.seconds),
                                    const SizedBox(width: 8),
                                    Text(
                                      '운세 확인하기',
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                                  .animate()
                                  .fadeIn(duration: 500.ms)
                                  .scale(
                                    begin: const Offset(0.5, 0.5),
                                    end: const Offset(1.0, 1.0),
                                    duration: 800.ms,
                                    curve: Curves.elasticOut,
                                  )
                                  .shimmer(
                                    duration: 2.seconds,
                                    delay: 500.ms,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  )
                                  .shake(
                                    hz: 2,
                                    offset: const Offset(2, 0),
                                    duration: 500.ms,
                                    delay: 1.5.seconds,
                                  ),
                            ],
                          ),
                          
                          // 추가 안내 텍스트
                          const SizedBox(height: 16),
                          Text(
                            '✨ 운명의 문이 열렸습니다 ✨',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white70,
                              fontStyle: FontStyle.italic,
                            ),
                          )
                              .animate()
                              .fadeIn(delay: 800.ms)
                              .slideY(begin: 0.5, end: 0),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
              
              // 스킵 버튼 추가 (우상단)
              Positioned(
                top: 16,
                right: 16,
                child: IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white70,
                    size: 28,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              
              // 프리미엄 업그레이드 버튼 (무료 사용자만)
              if (!widget.isPremium)
                Positioned(
                  left: 32,
                  right: 32,
                  bottom: 48,
                  child: Column(
                    children: [
                      Text(
                        '광고 없이 바로 운세를 확인하고 싶으신가요?',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white60,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: widget.onSkip,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Theme.of(context).colorScheme.primary,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.rocket_launch, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              '프리미엄으로 업그레이드',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ).animate().fadeIn(delay: 1.seconds).slideY(begin: 0.3, end: 0),
                ),
            ],
          ),
        ),
      );
  }
}