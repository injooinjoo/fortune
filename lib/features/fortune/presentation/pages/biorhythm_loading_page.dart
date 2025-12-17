import 'dart:math' as math;
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/design_system/tokens/ds_biorhythm_colors.dart';
import '../../domain/models/conditions/biorhythm_fortune_conditions.dart';
import '../../../../core/services/unified_fortune_service.dart';
import '../../../../core/models/fortune_result.dart';
import 'biorhythm_result_page.dart';
import '../widgets/biorhythm/painters/ink_flow_animation_painter.dart';
import '../widgets/biorhythm/components/biorhythm_hanji_card.dart';

/// Biorhythm loading page with traditional Korean ink wash animation
///
/// Design Philosophy:
/// - Ink spreading on hanji paper animation
/// - Three colors representing 신체(火), 감정(木), 지적(水)
/// - Traditional calligraphy style typography
/// - Meditative, contemplative atmosphere
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

  late AnimationController _inkFlowController;
  late AnimationController _textFadeController;
  late AnimationController _pulseController;

  late Animation<double> _inkFlowAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _pulseAnimation;

  Timer? _stepTimer;
  int _currentStep = 0;
  int _currentPhase = 0;
  bool _isAnalysisComplete = false;
  FortuneResult? _fortuneResult;

  // Traditional Korean style analysis messages
  final List<Map<String, dynamic>> _analysisSteps = [
    {
      'text': '사주의 기운을 읽고 있습니다...',
      'hanja': '四柱',
      'description': '생년월일의 음양 조화 분석',
    },
    {
      'text': '신체 리듬(火)을 살피는 중...',
      'hanja': '火氣',
      'description': '23일 주기의 활력 흐름',
    },
    {
      'text': '감정 리듬(木)을 헤아리는 중...',
      'hanja': '木氣',
      'description': '28일 주기의 정서 흐름',
    },
    {
      'text': '지적 리듬(水)을 읽는 중...',
      'hanja': '水氣',
      'description': '33일 주기의 지혜 흐름',
    },
    {
      'text': '삼기(三氣)의 조화를 살피는 중...',
      'hanja': '三氣',
      'description': '세 기운의 상생상극 관계',
    },
    {
      'text': '주간 운세를 점치는 중...',
      'hanja': '週運',
      'description': '앞으로의 기운 흐름 예측',
    },
    {
      'text': '길흉을 판단하고 있습니다...',
      'hanja': '吉凶',
      'description': '오늘의 좋은 기운과 주의점',
    },
    {
      'text': '풀이가 완료되었습니다',
      'hanja': '完',
      'description': '바이오리듬 분석 완료',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnalysisSteps();
    _fetchFortune();
  }

  void _initAnimations() {
    // Main ink flow animation (3 seconds per cycle)
    _inkFlowController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _inkFlowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _inkFlowController,
      curve: Curves.easeInOut,
    ));

    // Text fade animation
    _textFadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textFadeController,
      curve: Curves.easeOut,
    ));

    // Pulse animation for the seal
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.08,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _inkFlowController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentPhase = (_currentPhase + 1) % 3;
        });
        _inkFlowController.forward(from: 0);
      }
    });

    _inkFlowController.forward();
    _textFadeController.forward();
    _pulseController.repeat(reverse: true);
  }

  Future<void> _fetchFortune() async {
    try {
      final service = UnifiedFortuneService(Supabase.instance.client);
      final conditions = BiorhythmFortuneConditions(
        birthDate: widget.birthDate.toIso8601String(),
        name: 'User',
      );

      final result = await service.getFortune(
        fortuneType: 'biorhythm',
        conditions: conditions,
        inputConditions: conditions.toJson(),
        dataSource: FortuneDataSource.api,
      );

      if (mounted) {
        setState(() {
          _fortuneResult = result;
        });
      }
    } catch (e) {
      debugPrint('Error fetching fortune: $e');
    }
  }

  void _startAnalysisSteps() {
    _stepTimer = Timer.periodic(const Duration(milliseconds: 900), (timer) {
      if (mounted) {
        _textFadeController.forward(from: 0);

        setState(() {
          _currentStep = (_currentStep + 1) % _analysisSteps.length;
        });

        // Navigate to result at the last step
        if (_currentStep == _analysisSteps.length - 1) {
          HapticFeedback.mediumImpact();
          Timer(const Duration(milliseconds: 1200), () {
            if (mounted) {
              _navigateToResult();
            }
          });
        }
      }
    });
  }

  Future<void> _navigateToResult() async {
    // Wait for result if not ready
    while (_fortuneResult == null) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
    }

    setState(() {
      _isAnalysisComplete = true;
    });
  }

  @override
  void dispose() {
    _stepTimer?.cancel();
    _inkFlowController.dispose();
    _textFadeController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show result page when analysis is complete
    if (_isAnalysisComplete && _fortuneResult != null) {
      return BiorhythmResultPage(
        birthDate: widget.birthDate,
        fortuneResult: _fortuneResult!,
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hanjiBackground = DSBiorhythmColors.getHanjiBackground(isDark);
    final textColor = DSBiorhythmColors.getInkBleed(isDark);

    return Scaffold(
      backgroundColor: hanjiBackground,
      body: Stack(
        children: [
          // Hanji texture background
          Positioned.fill(
            child: CustomPaint(
              painter: _HanjiTexturePainter(isDark: isDark),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Header with title
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    '운세를 풀이하고 있습니다',
                    style: TextStyle(
                      fontFamily: 'GowunBatang',
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),

                // Main content area
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Ink flow animation visualization
                        _buildInkFlowVisualization(isDark),

                        const SizedBox(height: 40),

                        // Current step card
                        _buildCurrentStepCard(isDark, textColor),

                        const SizedBox(height: 32),

                        // Progress indicator
                        _buildProgressIndicator(isDark),
                      ],
                    ),
                  ),
                ),

                // Bottom info
                _buildBottomInfo(isDark, textColor),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInkFlowVisualization(bool isDark) {
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Ink flow animation
          AnimatedBuilder(
            animation: _inkFlowAnimation,
            builder: (context, child) => CustomPaint(
              painter: InkFlowAnimationPainter(
                animationProgress: _inkFlowAnimation.value,
                currentPhase: _currentPhase,
                isDark: isDark,
                waveAmplitude: 1.0 + math.sin(_inkFlowAnimation.value * math.pi) * 0.5,
              ),
              size: const Size(280, 280),
            ),
          ),

          // Center seal with current Hanja
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) => Transform.scale(
              scale: _pulseAnimation.value,
              child: _buildCenterSeal(isDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterSeal(bool isDark) {
    final currentStepData = _analysisSteps[_currentStep];
    final sealColor = DSBiorhythmColors.physicalPrimary; // 다홍색 - traditional vermillion

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: sealColor.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        border: Border.all(
          color: sealColor.withValues(alpha: 0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: sealColor.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: FadeTransition(
          opacity: _textFadeAnimation,
          child: Text(
            currentStepData['hanja'] as String,
            key: ValueKey(_currentStep),
            style: const TextStyle(
              fontFamily: 'GowunBatang',
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStepCard(bool isDark, Color textColor) {
    final currentStepData = _analysisSteps[_currentStep];

    return BiorhythmHanjiCard(
      style: HanjiCardStyle.minimal,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      child: FadeTransition(
        opacity: _textFadeAnimation,
        child: Column(
          key: ValueKey(_currentStep),
          children: [
            // Main text
            Text(
              currentStepData['text'] as String,
              style: TextStyle(
                fontFamily: 'GowunBatang',
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            // Description
            Text(
              currentStepData['description'] as String,
              style: TextStyle(
                fontFamily: 'Pretendard',
                fontSize: 13,
                color: textColor.withValues(alpha: 0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(bool isDark) {
    final progress = (_currentStep + 1) / _analysisSteps.length;

    return Column(
      children: [
        // Traditional style progress bar
        Container(
          height: 6,
          width: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: DSBiorhythmColors.getInkWashGuide(isDark).withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    DSBiorhythmColors.getPhysical(isDark),
                    DSBiorhythmColors.getEmotional(isDark),
                    DSBiorhythmColors.getIntellectual(isDark),
                  ],
                ),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Step counter
        Text(
          '${_currentStep + 1} / ${_analysisSteps.length}',
          style: TextStyle(
            fontFamily: 'GowunBatang',
            fontSize: 14,
            color: DSBiorhythmColors.getInkBleed(isDark).withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomInfo(bool isDark, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: BiorhythmHanjiCard(
        style: HanjiCardStyle.minimal,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.auto_awesome,
              color: DSBiorhythmColors.goldAccent.withValues(alpha: 0.7),
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              '삼기(三氣)의 흐름을 읽고 있습니다',
              style: TextStyle(
                fontFamily: 'GowunBatang',
                fontSize: 13,
                color: textColor.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hanji paper texture background painter
class _HanjiTexturePainter extends CustomPainter {
  final bool isDark;

  _HanjiTexturePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(42);
    final textureColor = isDark
        ? Colors.white.withValues(alpha: 0.02)
        : DSBiorhythmColors.inkBleed.withValues(alpha: 0.025);

    // Draw subtle fiber texture
    for (var i = 0; i < 120; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      final length = 8 + random.nextDouble() * 20;
      final angle = random.nextDouble() * math.pi;

      canvas.drawLine(
        Offset(x, y),
        Offset(x + length * math.cos(angle), y + length * math.sin(angle)),
        Paint()
          ..color = textureColor
          ..strokeWidth = 0.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HanjiTexturePainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
