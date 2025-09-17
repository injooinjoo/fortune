import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import '../../../../core/components/toss_card.dart';
import '../../../../core/theme/toss_theme.dart';
import '../../../../core/theme/toss_design_system.dart';
import 'biorhythm_result_page.dart';

class BiorhythmLoadingPage extends StatefulWidget {
  final DateTime birthDate;
  
  const BiorhythmLoadingPage({
    super.key,
    required this.birthDate,
  });

  @override
  State<BiorhythmLoadingPage> createState() => _BiorhythmLoadingPageState();
}

class _BiorhythmLoadingPageState extends State<BiorhythmLoadingPage>
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _progressController;
  late AnimationController _waveController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _progressAnimation;
  late Animation<double> _waveAnimation;
  
  Timer? _stepTimer;
  int _currentStep = 0;
  bool _isAnalysisComplete = false;
  
  final List<Map<String, dynamic>> _analysisSteps = [
    {
      'text': '생년월일을 분석하고 있어요...',
      'icon': Icons.calendar_today_rounded,
      'color': const Color(0xFF0068FF),
    },
    {
      'text': '신체 리듬 주기를 계산 중...',
      'icon': Icons.fitness_center_rounded,
      'color': const Color(0xFFFF5A5F),
    },
    {
      'text': '감정 리듬 패턴 분석 중...',
      'icon': Icons.favorite_rounded,
      'color': const Color(0xFFFF9500),
    },
    {
      'text': '지적 리듬 상태 확인 중...',
      'icon': Icons.psychology_rounded,
      'color': const Color(0xFF00C896),
    },
    {
      'text': '오늘의 바이오리듬 계산 중...',
      'icon': Icons.timeline_rounded,
      'color': const Color(0xFF6B73FF),
    },
    {
      'text': '주간 예측 데이터 생성 중...',
      'icon': Icons.trending_up_rounded,
      'color': const Color(0xFF00B4D8),
    },
    {
      'text': '맞춤형 조언을 준비하고 있어요...',
      'icon': Icons.lightbulb_rounded,
      'color': const Color(0xFFFFB300),
    },
    {
      'text': '분석 완료!',
      'icon': Icons.check_circle_rounded,
      'color': const Color(0xFF00C851),
    },
  ];

  @override
  void initState() {
    super.initState();
    
    // 애니메이션 컨트롤러 초기화
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );
    
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    // 애니메이션 설정
    _pulseAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeOut,
    ));
    
    _waveAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _waveController,
      curve: Curves.easeInOut,
    ));
    
    // 애니메이션 시작
    _startAnimations();
    _startAnalysisSteps();
  }

  void _startAnimations() {
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    _progressController.forward();
    _waveController.repeat(reverse: true);
  }

  void _startAnalysisSteps() {
    _stepTimer = Timer.periodic(const Duration(milliseconds: 750), (timer) {
      if (mounted) {
        setState(() {
          _currentStep = (_currentStep + 1) % _analysisSteps.length;
        });
        
        // 마지막 단계에서 결과 페이지로 이동
        if (_currentStep == _analysisSteps.length - 1) {
          HapticFeedback.mediumImpact();
          Timer(const Duration(milliseconds: 1000), () {
            if (mounted) {
              _navigateToResult();
            }
          });
        }
      }
    });
  }

  void _navigateToResult() {
    // Navigator.pushReplacement 제거 - 상태 변경으로 처리
    setState(() {
      _isAnalysisComplete = true;
    });
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _pulseController.dispose();
    _rotationController.dispose();
    _progressController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 분석 완료 시 결과 페이지 표시
    if (_isAnalysisComplete) {
      return BiorhythmResultPage(birthDate: widget.birthDate);
    }

    final theme = Theme.of(context);
    final currentStepData = _analysisSteps[_currentStep];
    
    return Scaffold(
      backgroundColor: TossTheme.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: TossDesignSystem.white.withValues(alpha: 0.0),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          '바이오리듬 분석 중',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: TossTheme.textBlack,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              
              // 메인 분석 카드
              Expanded(
                child: TossCard(
                  style: TossCardStyle.elevated,
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 바이오리듬 시각화
                      _buildBiorhythmVisualization(),
                      const SizedBox(height: 40),
                      
                      // 진행률 표시
                      _buildProgressSection(),
                      const SizedBox(height: 32),
                      
                      // 현재 분석 단계
                      _buildCurrentStepText(),
                      const SizedBox(height: 24),
                      
                      // 설명 텍스트
                      _buildDescriptionText(),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // 하단 정보
              _buildBottomInfo(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBiorhythmVisualization() {
    final currentStepData = _analysisSteps[_currentStep];
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // 외곽 파동 효과
        ...List.generate(3, (index) => 
          AnimatedBuilder(
            animation: _waveAnimation,
            builder: (context, child) => Container(
              width: 250 + (index * 40) * _waveAnimation.value,
              height: 250 + (index * 40) * _waveAnimation.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: (currentStepData['color'] as Color).withValues(alpha: 0.1 - index * 0.03),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        
        // 메인 리듬 시각화
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) => Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: 160,
              height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    (currentStepData['color'] as Color).withValues(alpha: 0.8),
                    (currentStepData['color'] as Color).withValues(alpha: 0.3),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (currentStepData['color'] as Color).withValues(alpha: 0.4),
                    blurRadius: 30,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) => Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: Icon(
                    currentStepData['icon'] as IconData,
                    color: TossDesignSystem.white,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
        ),
        
        // 리듬 곡선들
        ...List.generate(3, (index) =>
          Positioned(
            top: 60 + index * 15,
            left: 20,
            right: 20,
            child: AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) => CustomPaint(
                painter: RhythmWavePainter(
                  progress: _rotationAnimation.value,
                  color: [
                    const Color(0xFFFF5A5F),  // Physical
                    const Color(0xFF00C896),  // Emotional
                    const Color(0xFF0068FF),  // Intellectual
                  ][index].withValues(alpha: 0.6),
                  phase: index * math.pi / 3,
                ),
                child: const SizedBox(height: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Column(
      children: [
        // 프로그레스 바
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: TossTheme.borderGray300,
            borderRadius: BorderRadius.circular(4),
          ),
          child: AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) => FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: _progressAnimation.value,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF0068FF),
                      const Color(0xFF00C896),
                      const Color(0xFFFF5A5F),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        // 진행률 퍼센트
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) => Text(
            '${(_progressAnimation.value * 100).round()}%',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: TossTheme.primaryBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrentStepText() {
    final currentStepData = _analysisSteps[_currentStep];
    
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Text(
        currentStepData['text'] as String,
        key: ValueKey(_currentStep),
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w600,
          color: TossTheme.textBlack,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildDescriptionText() {
    return Text(
      '23일, 28일, 33일 주기의 3가지 리듬을\n정밀하게 분석하고 있습니다',
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        color: TossTheme.textGray600,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildBottomInfo() {
    return TossCard(
      style: TossCardStyle.filled,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: TossTheme.primaryBlue,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '분석 결과는 참고용으로만 활용해 주세요',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: TossTheme.textGray600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RhythmWavePainter extends CustomPainter {
  final double progress;
  final Color color;
  final double phase;

  RhythmWavePainter({
    required this.progress,
    required this.color,
    required this.phase,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final width = size.width;
    final height = size.height;
    final centerY = height / 2;

    path.moveTo(0, centerY);

    for (double x = 0; x <= width; x += 2) {
      final y = centerY + 
          math.sin((x / width) * 4 * math.pi + progress * 2 * math.pi + phase) * 
          (height / 4);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}