import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/logger.dart';

class AdLoadingScreen extends ConsumerStatefulWidget {
  final String fortuneType;
  final String fortuneTitle;
  final VoidCallback onComplete;
  final VoidCallback onSkip;
  final bool isPremium;
  final Future<dynamic> Function()? fetchData;

  const AdLoadingScreen({
    super.key,
    required this.fortuneType,
    required this.fortuneTitle,
    required this.onComplete,
    required this.onSkip,
    required this.isPremium,
    this.fetchData,
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

  // 운세별 로딩 메시지
  final Map<String, List<String>> _loadingMessages = {
    'default': [
      'AI가 당신의 운세를 분석하고 있습니다...',
      '별들의 움직임을 읽고 있습니다...',
      '우주의 기운을 해석하고 있습니다...',
      '당신만을 위한 맞춤 운세를 준비중입니다...',
    ],
    'saju': [
      '사주팔자를 분석하고 있습니다...',
      '천간지지의 조화를 살펴보고 있습니다...',
      '오행의 균형을 확인하고 있습니다...',
      '당신의 운명을 해석하고 있습니다...',
    ],
    'tarot': [
      '타로 카드를 섞고 있습니다...',
      '운명의 카드를 뽑고 있습니다...',
      '카드의 의미를 해석하고 있습니다...',
      '당신에게 전하는 메시지를 준비중입니다...',
    ],
    'love': [
      '사랑의 별자리를 확인하고 있습니다...',
      '인연의 실을 찾고 있습니다...',
      '두 사람의 궁합을 분석중입니다...',
      '사랑의 운세를 준비하고 있습니다...',
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
        _completeLoading();
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

  void _completeLoading() {
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

    Logger.analytics('ad_loading_complete', {
      'fortune_type': widget.fortuneType,
      'is_premium': widget.isPremium,
    });

    widget.onComplete();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
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
                            Colors.purple.shade900.withOpacity(0.3),
                            Colors.indigo.shade900.withOpacity(0.3),
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
              
              // 메인 컨텐츠
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 아이콘 애니메이션
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.1),
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          size: 60,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ).animate(
                        onPlay: (controller) => controller.repeat(),
                      ).scale(
                        duration: 2.seconds,
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1.1, 1.1),
                      ).then().scale(
                        duration: 2.seconds,
                        begin: const Offset(1.1, 1.1),
                        end: const Offset(0.9, 0.9),
                      ),
                      
                      const SizedBox(height: 48),
                      
                      // 타이틀
                      Text(
                        widget.fortuneTitle,
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn(duration: 600.ms).slideY(begin: 0.3, end: 0),
                      
                      const SizedBox(height: 24),
                      
                      // 로딩 메시지
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 500),
                        child: Text(
                          _currentMessage,
                          key: ValueKey(_currentMessage),
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.white70,
                            height: 1.5,
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
                          color: Colors.white.withOpacity(0.2),
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
                                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // 남은 시간 표시 (무료 사용자만)
                      if (!widget.isPremium)
                        Text(
                          '${_remainingSeconds}초 후에 운세를 확인할 수 있습니다',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white60,
                          ),
                        ).animate().fadeIn(delay: 300.ms),
                    ],
                  ),
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
      ),
    );
  }
}