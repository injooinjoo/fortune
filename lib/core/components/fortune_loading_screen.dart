import 'dart:math';

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

  // 재미있고 위트있는 공통 로딩 메시지 50개
  static const List<String> _funMessages = [
    // 우주/신비 테마
    '우주에서 당신의 별을 찾고 있어요 ✨',
    '은하수 저편에서 답을 가져오는 중...',
    '별똥별에게 부탁하는 중이에요',
    '달님께 여쭤보고 있어요 🌙',
    '북극성이 방향을 알려주는 중...',

    // 귀여운/재미있는
    '운세 요정이 열심히 일하고 있어요 🧚',
    'AI가 커피 한 잔 마시고 올게요 ☕',
    '점쟁이 할머니가 준비 중이에요',
    '수정 구슬을 닦고 있어요 🔮',
    '타로 카드가 스트레칭 중...',

    // 유머러스
    '로딩이 좀 걸리지만 결과는 찐이에요',
    '좋은 운세는 시간이 걸리는 법...',
    '급하게 먹은 떡이 체하듯... 기다려주세요',
    '천천히 가는 것도 멋진 일이에요',
    '우주의 와이파이가 좀 느려요 📡',

    // 동기부여/긍정
    '좋은 소식을 준비하고 있어요!',
    '오늘도 좋은 하루가 될 거예요',
    '행운이 당신을 찾아가는 중...',
    '긍정의 기운을 모으고 있어요 💪',
    '희망찬 메시지가 곧 도착해요',

    // 신비로운
    '고대의 지혜를 불러오는 중...',
    '점성술 계산기가 바쁘게 돌아가는 중',
    '음양오행의 조화를 맞추고 있어요',
    '천간지지가 회의 중이에요',
    '12지신들이 투표하고 있어요',

    // 재치있는
    '운명의 빨래를 개고 있어요 🧺',
    '행운의 배달부가 출발했어요 🚚',
    '운세 택배가 배송 중...',
    '당신의 미래가 렌더링 중입니다',
    '버퍼링... 아니 점보링 중! 🎱',

    // 계절/자연
    '봄바람에 운세를 실어 보내요 🍃',
    '무지개 너머에서 답을 찾는 중 🌈',
    '네잎클로버를 열심히 찾고 있어요 🍀',
    '행운의 바람이 불어오는 중...',
    '꽃잎이 당신의 운세를 알려줄 거예요 🌸',

    // 동물 테마
    '길냥이가 귀띔해주는 중... 🐱',
    '부엉이 박사가 분석 중이에요 🦉',
    '드래곤이 예언을 전해주러 와요 🐉',
    '행운의 두꺼비가 생각 중... 🐸',
    '황금거북이가 점괘를 내리는 중 🐢',

    // 테크+점술 믹스
    'AI 점쟁이가 딥러닝 중...',
    '클라우드 위 신선이 내려오는 중',
    '운세 서버가 열심히 연산 중...',
    '블록체인 위에 운명을 기록 중...',
    '알고리즘이 별자리를 계산 중...',

    // 감성적
    '소중한 당신을 위한 메시지 준비 중...',
    '마음을 담아 결과를 만들고 있어요 💝',
    '정성을 다해 분석하고 있어요',
    '당신의 행복을 빌며 기다려주세요',
    '좋은 기운을 담아 가져올게요',
  ];

  // 인사이트 타입별 감성 메시지
  static final Map<String, List<String>> _fortuneMessages = {
    'default': _funMessages,
    'daily': _funMessages,
    'love': _funMessages,
    'saju': _funMessages,
    'tarot': _funMessages,
    'compatibility': _funMessages,
    'wealth': _funMessages,
    'mbti': _funMessages,
  };

  @override
  void initState() {
    super.initState();

    // 메시지 초기화 + 랜덤 셔플
    final baseMessages =
        _fortuneMessages[widget.fortuneType] ?? _fortuneMessages['default']!;
    _messages = List<String>.from(baseMessages)..shuffle(Random());

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
                'ZPZG',
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