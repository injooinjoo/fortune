import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../../core/theme/toss_theme.dart';

/// 사주팔자 계산 로딩 애니메이션 위젯
class SajuLoadingAnimation extends StatefulWidget {
  final String name;

  const SajuLoadingAnimation({
    super.key,
    required this.name,
  });

  @override
  State<SajuLoadingAnimation> createState() => _SajuLoadingAnimationState();
}

class _SajuLoadingAnimationState extends State<SajuLoadingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late AnimationController _textController;
  
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _textOpacityAnimation;

  int _currentMessageIndex = 0;
  final List<String> _loadingMessages = [
    '만세력을 분석하고 있습니다',
    '천간지지를 계산하고 있습니다',
    '사주팔자를 구성하고 있습니다',
    '오행 균형을 확인하고 있습니다',
    '십신을 분석하고 있습니다',
    '대운의 흐름을 계산하고 있습니다',
    '종합 해석을 준비하고 있습니다',
  ];

  // 천간
  final List<String> _heavenlyStems = [
    '甲', '乙', '丙', '丁', '戊', '己', '庚', '辛', '壬', '癸'
  ];

  // 지지
  final List<String> _earthlyBranches = [
    '子', '丑', '寅', '卯', '辰', '巳', '午', '未', '申', '酉', '戌', '亥'
  ];

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _textController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _textOpacityAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeOut,
    ));

    _startAnimations();
  }

  void _startAnimations() {
    _rotationController.repeat();
    _pulseController.repeat(reverse: true);
    _textController.forward();
    
    // 메시지 변경 타이머
    _startMessageCycle();
  }

  void _startMessageCycle() {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _changeMessage();
      }
    });
  }

  void _changeMessage() {
    if (!mounted) return;
    
    _textController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _currentMessageIndex = (_currentMessageIndex + 1) % _loadingMessages.length;
        });
        _textController.forward();
        
        // 다음 메시지로 변경할 타이머 설정
        if (_currentMessageIndex < _loadingMessages.length - 1) {
          Future.delayed(const Duration(milliseconds: 800), _changeMessage);
        }
      }
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TossTheme.backgroundPrimary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 메인 애니메이션
            _buildMainAnimation(),
            
            const SizedBox(height: TossTheme.spacingXXL),
            
            // 이름 표시
            Text(
              '${widget.name}님의',
              style: TossTheme.heading2.copyWith(
                color: TossTheme.textBlack,
              ),
            ),
            
            const SizedBox(height: TossTheme.spacingS),
            
            Text(
              '사주팔자를 분석 중입니다',
              style: TossTheme.heading2.copyWith(
                color: TossTheme.brandBlue,
                fontWeight: FontWeight.bold,
              ),
            ),
            
            const SizedBox(height: TossTheme.spacingXL),
            
            // 진행 상황 메시지
            AnimatedBuilder(
              animation: _textOpacityAnimation,
              builder: (context, child) {
                return Opacity(
                  opacity: _textOpacityAnimation.value,
                  child: Text(
                    _loadingMessages[_currentMessageIndex],
                    style: TossTheme.body1.copyWith(
                      color: TossTheme.textGray600,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
            
            const SizedBox(height: TossTheme.spacingL),
            
            // 진행 바
            _buildProgressBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildMainAnimation() {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _rotationAnimation,
        _pulseAnimation,
      ]),
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            width: 250,
            height: 250,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // 외부 원 (천간)
                Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: _buildStemCircle(),
                ),
                
                // 내부 원 (지지)
                Transform.rotate(
                  angle: -_rotationAnimation.value * 0.8,
                  child: _buildBranchCircle(),
                ),
                
                // 중앙 태극
                _buildCenterTaegeuk(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStemCircle() {
    return Container(
      width: 250,
      height: 250,
      child: Stack(
        children: List.generate(_heavenlyStems.length, (index) {
          final angle = (index * 36.0) * math.pi / 180;
          final radius = 105.0;
          final x = radius * math.cos(angle);
          final y = radius * math.sin(angle);
          
          return Transform.translate(
            offset: Offset(x, y),
            child: Transform.rotate(
              angle: -_rotationAnimation.value,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: _getStemColor(index).withValues(alpha: 0.8),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: _getStemColor(index).withValues(alpha: 0.3),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    _heavenlyStems[index],
                    style: TossTheme.caption.copyWith(
                      color: TossDesignSystem.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildBranchCircle() {
    return Container(
      width: 180,
      height: 180,
      child: Stack(
        children: List.generate(_earthlyBranches.length, (index) {
          final angle = (index * 30.0) * math.pi / 180;
          final radius = 70.0;
          final x = radius * math.cos(angle);
          final y = radius * math.sin(angle);
          
          return Transform.translate(
            offset: Offset(x, y),
            child: Transform.rotate(
              angle: _rotationAnimation.value * 0.8,
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: _getBranchColor(index).withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: TossDesignSystem.white.withValues(alpha: 0.5),
                    width: 1,
                  ),
                ),
                child: Center(
                  child: Text(
                    _earthlyBranches[index],
                    style: TossTheme.caption.copyWith(
                      color: TossDesignSystem.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCenterTaegeuk() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            TossTheme.brandBlue,
            TossTheme.brandBlue.withValues(alpha: 0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: TossTheme.brandBlue.withValues(alpha: 0.4),
            blurRadius: 15,
            spreadRadius: 3,
          ),
        ],
      ),
      child: Center(
        child: Text(
          '사주\n팔자',
          style: TossTheme.caption.copyWith(
            color: TossDesignSystem.white,
            fontWeight: FontWeight.bold,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (_currentMessageIndex + 1) / _loadingMessages.length;
    
    return Column(
      children: [
        Container(
          width: 200,
          height: 6,
          decoration: BoxDecoration(
            color: TossTheme.backgroundSecondary,
            borderRadius: BorderRadius.circular(3),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 200 * progress,
                height: 6,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      TossTheme.brandBlue,
                      TossTheme.brandBlue.withValues(alpha: 0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: TossTheme.spacingM),
        
        Text(
          '${(_currentMessageIndex + 1)}/${_loadingMessages.length}',
          style: TossTheme.caption.copyWith(
            color: TossTheme.textGray500,
          ),
        ),
      ],
    );
  }

  Color _getStemColor(int index) {
    // 오행 색상으로 천간 색상 결정
    final elementColors = [
      TossTheme.success, TossTheme.success, // 갑을 - 목
      TossTheme.error, TossTheme.error,     // 병정 - 화
      TossTheme.warning, TossTheme.warning, // 무기 - 토
      TossTheme.textGray600, TossTheme.textGray600, // 경신 - 금
      TossTheme.brandBlue, TossTheme.brandBlue,     // 임계 - 수
    ];
    return elementColors[index];
  }

  Color _getBranchColor(int index) {
    // 계절과 오행으로 지지 색상 결정
    final seasonColors = [
      TossTheme.brandBlue, TossTheme.warning, TossTheme.success, // 겨울, 토, 봄
      TossTheme.success, TossTheme.warning, TossTheme.error,     // 봄, 토, 여름
      TossTheme.error, TossTheme.warning, TossTheme.textGray600, // 여름, 토, 가을
      TossTheme.textGray600, TossTheme.warning, TossTheme.brandBlue, // 가을, 토, 겨울
    ];
    return seasonColors[index];
  }
}