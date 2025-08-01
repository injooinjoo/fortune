import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;
import '../../../../../shared/glassmorphism/glass_container.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/utils/haptic_utils.dart';
import '../../../../../data/services/fortune_api_service.dart';
import '../../../../../core/constants/api_endpoints.dart';
import '../../../domain/models/talisman_models.dart';
import '../talisman_enhanced_page.dart';

class TalismanGenerationStep extends ConsumerStatefulWidget {
  final Function(TalismanResult) onComplete;
  final VoidCallback onBack;

  const TalismanGenerationStep({
    super.key,
    required this.onComplete,
    required this.onBack,
  });

  @override
  ConsumerState<TalismanGenerationStep> createState() => _TalismanGenerationStepState();
}

class _TalismanGenerationStepState extends ConsumerState<TalismanGenerationStep>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isGenerating = true;
  String _statusMessage = '부적을 준비하고 있습니다...';
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2))..repeat();
    
    // Start generation process
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _generateTalisman();
});
}

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
}

  Future<void> _generateTalisman() async {
    final state = ref.read(talismanCreationProvider);
    final apiService = ref.read(fortuneApiServiceProvider);
    
    // Check if required data is available
    if (state.selectedType == null) {
      setState(() {
        _isGenerating = false;
        _statusMessage = '부적 유형이 선택되지 않았습니다.';
      });
      return;
}
    
    // Simulate progress updates
    _updateProgress(0.2, '사용자 정보를 분석하고 있습니다...');
    await Future.delayed(const Duration(seconds: 1));
    
    _updateProgress(0.4, '부적 문양을 그리고 있습니다...');
    await Future.delayed(const Duration(seconds: 1));
    
    _updateProgress(0.6, '주술을 입히고 있습니다...');
    await Future.delayed(const Duration(seconds: 1));
    
    _updateProgress(0.8, '영적 에너지를 충전하고 있습니다...');
    
    try {
      // Call API to generate talisman
      final response = await apiService.post(
        ApiEndpoints.generateFortune,
        data: {
          'type': 'talisman',
          'userInfo': {
            'talismanType': state.selectedType!.name,
            'userName': state.userName,
            'birthDate': state.birthDate,
            'personalWish': state.personalWish,
            'customization': {
              'primaryColor': state.primaryColor?.value,
              'secondaryColor': state.secondaryColor?.value,
              'personalText': state.personalText,
            },
          },
        }
      );
      
      if (response['success'] == true) {
        _updateProgress(1.0, '부적이 완성되었습니다!');
        
        // Parse response and create TalismanResult
        final data = response['data'] ?? {};
        final fortune = data['fortune'] ?? {};
        
        final result = TalismanResult(
          type: state.selectedType!,
          design: TalismanDesign(
            baseSymbol: 'classic', // This would come from API
            primaryColor: state.primaryColor ?? state.selectedType!.gradientColors[0],
            secondaryColor: state.secondaryColor ?? state.selectedType!.gradientColors[1],
            personalText: state.personalText ?? '',
            protectionSymbol: '護', // This would come from API
            createdDate: DateTime.now(),
            userBirthInfo: state.birthDate,
            userName: state.userName,
          ),
          meaning: fortune['meaning'] ?? '이 부적은 당신의 소원을 이루어주고 행운을 가져다 줄 것입니다.',
          usage: fortune['usage'] ?? '항상 몸에 지니고 다니시거나, 집안의 깨끗한 곳에 보관하세요.',
          effectiveness: fortune['effectiveness'] ?? '이 부적은 당신의 긍정적인 에너지와 함께 작용하여 효과를 발휘합니다.',
          precautions: List<String>.from(fortune['precautions'] ?? [
            '부적을 타인에게 보여주지 마세요',
            '항상 깨끗하게 보관하세요',
            '부정적인 생각을 품지 마세요',
          ]);
        
        await Future.delayed(const Duration(seconds: 1));
        
        setState(() {
          _isGenerating = false;,
});
        
        // Haptic feedback for completion
        HapticUtils.successNotification();
        
        // Complete after a short delay
        await Future.delayed(const Duration(milliseconds: 500));
        widget.onComplete(result);
} else {
        throw Exception(response['error'] ?? '부적 생성에 실패했습니다');
}
    } catch (e) {
      setState(() {
        _isGenerating = false;
        _statusMessage = '오류가 발생했습니다: ${e.toString()}';
      });
      HapticUtils.errorNotification();
}
  }

  void _updateProgress(double progress, String message) {
    setState(() {
      _progress = progress;
      _statusMessage = message;,
});
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(talismanCreationProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Generation animation
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Talisman animation container
                      Container(
                        width: 250,
                        height: 250,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              state.selectedType!.gradientColors[0].withValues(alpha: 0.3),
                              state.selectedType!.gradientColors[1].withValues(alpha: 0.1),
                              Colors.transparent,
                            ],
                            stops: const [0.3, 0.7, 1.0],
                          ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // Rotating outer ring
                            AnimatedBuilder(
                              animation: _animationController,
                              builder: (context, child) {
                                return Transform.rotate(
                                  angle: _animationController.value * 2 * 3.14159,
                                  child: Container(
                                    width: 200,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: state.selectedType!.gradientColors[0]
                                            .withValues(alpha: 0.5),
                                        width: 2,
                                      ),
                                    child: CustomPaint(
                                      painter: _MagicCirclePainter(
                                        progress: _progress,
                                        color: state.selectedType!.gradientColors[0],
                                      ),
                                  ));
},
                            ),
                            
                            // Center icon
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: state.selectedType!.gradientColors,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: state.selectedType!.gradientColors[0]
                                        .withValues(alpha: 0.5),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                state.selectedType!.icon,
                                color: Colors.white,
                                size: 50,
                              )).animate(onPlay: (controller) => controller.repeat())
                              .shimmer(duration: 2000.ms, color: Colors.white.withValues(alpha: 0.3)
                              .scale(
                                begin: const Offset(0.9, 0.9),
                                end: const Offset(1.1, 1.1),
                                duration: 1000.ms,
                                curve: Curves.easeInOut,
                              ),
                          ],
                        ),
                      
                      const SizedBox(height: 40),
                      
                      // Status message
                      Text(
                        _statusMessage,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ).animate(onPlay: (controller) => controller.repeat())
                        .fadeIn(duration: 500.ms)
                        .then()
                        .fadeOut(duration: 500.ms),
                      
                      const SizedBox(height: 20),
                      
                      // Progress bar
                      Container(
                        width: 250,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(3),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: _progress,
                            backgroundColor: Colors.transparent,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              state.selectedType!.gradientColors[0],
                            ),
                        ),
                      
                      const SizedBox(height: 12),
                      
                      // Progress percentage
                      Text(
                        '${(_progress * 100).toInt()}%',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                    ],
                  ),
              ),
              
              // Bottom actions
              if (!_isGenerating), OutlinedButton(
                  onPressed: widget.onBack,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text('다시 만들기'),
            ],
          ),
      ));
}
}

class _MagicCirclePainter extends CustomPainter {
  final double progress;
  final Color color;

  _MagicCirclePainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw progress arc
    final progressPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 20),
      -3.14159 / 2,
      2 * 3.14159 * progress,
      false,
      progressPaint
    );

    // Draw decorative elements
    final elementCount = 8;
    for (int i = 0; i < elementCount; i++) {
      final angle = i * 2 * 3.14159 / elementCount;
      final x = center.dx + (radius - 10) * math.cos(angle);
      final y = center.dy + (radius - 10) * math.sin(angle);
      
      canvas.drawCircle(
        Offset(x, y),
        4,
        paint..style = PaintingStyle.fill,
      );
}
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;,
}