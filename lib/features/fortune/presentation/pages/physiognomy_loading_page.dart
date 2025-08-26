import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'dart:async';
import '../../../../core/components/toss_card.dart';
import '../../../../core/theme/toss_theme.dart';
import 'physiognomy_result_enhanced_page.dart';

class PhysiognomyLoadingPage extends StatefulWidget {
  final File imageFile;
  
  const PhysiognomyLoadingPage({
    super.key,
    required this.imageFile,
  });

  @override
  State<PhysiognomyLoadingPage> createState() => _PhysiognomyLoadingPageState();
}

class _PhysiognomyLoadingPageState extends State<PhysiognomyLoadingPage>
    with TickerProviderStateMixin {
  
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late AnimationController _progressController;
  
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _progressAnimation;
  
  Timer? _stepTimer;
  int _currentStep = 0;
  
  final List<String> _analysisSteps = [
    '얼굴 인식 중...',
    '얼굴 형태 분석 중...',
    '눈 특징 분석 중...',
    '코 형태 분석 중...',
    '입술 특징 분석 중...',
    'AI가 관상을 해석 중...',
    '운세 결과 생성 중...',
    '분석 완료!',
  ];

  @override
  void initState() {
    super.initState();
    
    // 애니메이션 컨트롤러 초기화
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _progressController = AnimationController(
      duration: const Duration(seconds: 6),
      vsync: this,
    );
    
    // 애니메이션 설정
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
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
    
    // 애니메이션 시작
    _startAnimations();
    _startAnalysisSteps();
  }

  void _startAnimations() {
    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
    _progressController.forward();
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
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            PhysiognomyResultEnhancedPage(imageFile: widget.imageFile),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return SlideTransition(
            position: animation.drive(
              Tween(begin: const Offset(1.0, 0.0), end: Offset.zero)
                  .chain(CurveTween(curve: Curves.easeOutCubic)),
            ),
            child: FadeTransition(
              opacity: animation,
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _pulseController.dispose();
    _rotationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: TossTheme.backgroundPrimary,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'AI 분석 중',
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
                      // 사용자 이미지와 AI 아이콘
                      _buildAnalysisVisual(),
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

  Widget _buildAnalysisVisual() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // 배경 원
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) => Container(
            width: 200 * _pulseAnimation.value,
            height: 200 * _pulseAnimation.value,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TossTheme.primaryBlue.withOpacity(0.1),
            ),
          ),
        ),
        
        // 사용자 이미지
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: TossTheme.primaryBlue,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: TossTheme.primaryBlue.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.file(
              widget.imageFile,
              fit: BoxFit.cover,
            ),
          ),
        ),
        
        // AI 분석 아이콘
        Positioned(
          bottom: 10,
          right: 10,
          child: AnimatedBuilder(
            animation: _rotationAnimation,
            builder: (context, child) => Transform.rotate(
              angle: _rotationAnimation.value * 2 * 3.14159,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: TossTheme.primaryBlue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: TossTheme.primaryBlue.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 20,
                ),
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
          height: 6,
          decoration: BoxDecoration(
            color: TossTheme.borderGray300,
            borderRadius: BorderRadius.circular(3),
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
                      TossTheme.primaryBlue,
                      const Color(0xFF00C851),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(3),
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
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      child: Text(
        _analysisSteps[_currentStep],
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
      'AI가 당신의 얼굴 특징을 정밀하게\n분석하고 있습니다',
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