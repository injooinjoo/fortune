import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/fortune_design_system.dart';
import 'loading_video_player.dart';

class FortuneLoadingScreen extends StatefulWidget {
  final String fortuneType;
  final VoidCallback? onComplete;
  final Duration? duration;

  const FortuneLoadingScreen({
    super.key,
    this.fortuneType = 'default',
    this.onComplete,
    this.duration,
  });

  @override
  State<FortuneLoadingScreen> createState() => _FortuneLoadingScreenState();
}

class _FortuneLoadingScreenState extends State<FortuneLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _messageController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  int _currentMessageIndex = 0;
  late List<String> _messages;

  // 운세 타입별 감성 메시지
  static final Map<String, List<String>> _fortuneMessages = {
    'default': [
      '운세를 준비하고 있어요',
      '오늘의 메시지를 해석하고 있어요',
      '행운의 기운을 모으고 있어요',
      '당신만을 위한 운세를 만들고 있어요',
      '잠시만 기다려주세요',
    ],
    'daily': [
      '오늘 하루를 들여다보고 있어요',
      '별자리의 움직임을 읽고 있어요',
      '행운의 숫자를 찾고 있어요',
      '오늘의 기운을 해석하고 있어요',
      '당신의 하루를 준비하고 있어요',
    ],
    'love': [
      '사랑의 기운을 읽고 있어요',
      '인연의 실을 찾고 있어요',
      '두 사람의 별자리를 분석해요',
      '애정운을 살펴보고 있어요',
      '마음의 신호를 해석하고 있어요',
    ],
    'saju': [
      '사주팔자를 풀이하고 있어요',
      '천간지지를 해석하고 있어요',
      '오행의 균형을 살펴보고 있어요',
      '당신의 운명을 읽고 있어요',
      '팔자의 흐름을 분석하고 있어요',
    ],
    'tarot': [
      '카드를 섞고 있어요',
      '운명의 카드를 뽑고 있어요',
      '타로의 메시지를 해석해요',
      '카드의 의미를 읽고 있어요',
      '당신의 질문에 답을 찾고 있어요',
    ],
    'compatibility': [
      '두 사람의 궁합을 보고 있어요',
      '인연의 깊이를 측정해요',
      '서로의 기운을 분석하고 있어요',
      '궁합점수를 계산하고 있어요',
      '두 분의 미래를 들여다봐요',
    ],
    'wealth': [
      '재물운을 살펴보고 있어요',
      '금전의 흐름을 읽고 있어요',
      '행운의 기회를 찾고 있어요',
      '재물복을 분석하고 있어요',
      '부의 에너지를 측정해요',
    ],
    'mbti': [
      '성격 유형을 분석하고 있어요',
      'MBTI별 운세를 준비해요',
      '당신의 성향을 파악하고 있어요',
      '유형별 행운을 찾고 있어요',
      '성격과 운세를 매칭해요',
    ],
  };

  @override
  void initState() {
    super.initState();
    
    // 메시지 초기화
    _messages = _fortuneMessages[widget.fortuneType] ?? _fortuneMessages['default']!;

    // 메시지 전환 애니메이션
    _messageController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _messageController,
      curve: Curves.easeInOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _messageController,
      curve: Curves.easeOutCubic,
    ));
    
    // 첫 메시지 표시
    _messageController.forward();
    
    // 메시지 롤링 시작
    _startMessageRolling();
    
    // 완료 타이머 (설정된 경우)
    if (widget.duration != null) {
      Future.delayed(widget.duration!, () {
        if (mounted) {
          widget.onComplete?.call();
        }
      });
    }
  }
  
  void _startMessageRolling() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      _nextMessage();
    });
  }
  
  void _nextMessage() async {
    // 페이드 아웃
    await _messageController.reverse();
    
    if (!mounted) return;
    
    // 다음 메시지로 변경
    setState(() {
      _currentMessageIndex = (_currentMessageIndex + 1) % _messages.length;
    });
    
    // 페이드 인
    await _messageController.forward();
    
    // 다음 롤링 예약
    if (mounted) {
      _startMessageRolling();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? TossDesignSystem.grayDark50 : TossDesignSystem.white;
    final textColor = isDarkMode ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 상단 여백
              const Spacer(flex: 2),
              
              // 로딩 비디오
              const LoadingVideoPlayer(
                width: 150,
                height: 150,
                loop: true,
              ),
              
              const SizedBox(height: TossDesignSystem.spacing4XL),
              
              // 감성 메시지 (롤링 애니메이션)
              Container(
                height: 50, // 고정 높이로 텍스트 점프 방지
                alignment: Alignment.center,
                child: AnimatedBuilder(
                  animation: _messageController,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Text(
                          _messages[_currentMessageIndex],
                          style: TossDesignSystem.body2.copyWith(
                            color: textColor.withValues(alpha: 0.7),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // 하단 여백
              const Spacer(flex: 3),
              
              // 아주 작은 부가 텍스트 (선택적)
              Text(
                '관상은 과학',
                style: TossDesignSystem.small.copyWith(
                  color: textColor.withValues(alpha: 0.3),
                  letterSpacing: 1.5,
                ),
              ).animate()
                .fadeIn(delay: 1000.ms, duration: 800.ms),
              
              const SizedBox(height: TossDesignSystem.spacing4XL),
            ],
          ),
        ),
      ),
    );
  }
}

// 간단한 로딩 위젯 (인라인용)
class TossFortuneLoadingWidget extends StatelessWidget {
  final String? message;
  final double size;

  const TossFortuneLoadingWidget({
    super.key,
    this.message,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        LoadingVideoPlayer(
          width: size,
          height: size,
          loop: true,
        ),
        if (message != null) ...[
          const SizedBox(height: TossDesignSystem.spacingM),
          Text(
            message!,
            style: TossDesignSystem.caption.copyWith(
              color: textColor.withValues(alpha: 0.6),
            ),
          ),
        ],
      ],
    );
  }
}