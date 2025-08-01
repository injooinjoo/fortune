import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../shared/components/app_header.dart';
import '../../../../shared/glassmorphism/glass_container.dart';
import '../../../../shared/glassmorphism/glass_effects.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../../core/utils/logger.dart';
import '../../../../presentation/providers/token_provider.dart';
import '../../../../presentation/providers/auth_provider.dart';
import '../../../../shared/components/soul_consume_animation.dart';
import '../../../../shared/components/soul_earn_animation.dart';
import '../../../../core/constants/soul_rates.dart';
import '../providers/dream_analysis_provider.dart';
import '../widgets/dream_progress_indicator.dart';
import 'dream_steps/dream_recording_step.dart';
import 'dream_steps/dream_symbols_step.dart';
import 'dream_steps/dream_emotions_step.dart';
import 'dream_steps/dream_reality_step.dart';
import 'dream_steps/dream_interpretation_step.dart';
import 'dream_steps/dream_advice_step.dart';

class DreamFortuneFlowPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? initialParams;
  
  const DreamFortuneFlowPage({
    Key? key,
    this.initialParams,
  }) : super(key: key);

  @override
  ConsumerState<DreamFortuneFlowPage> createState() => _DreamFortuneFlowPageState();
}

class _DreamFortuneFlowPageState extends ConsumerState<DreamFortuneFlowPage> 
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final List<String> _stepTitles = [
    '꿈 기록',
    '상징 분석')
    '감정 분석')
    '현실 연결')
    '해석')
    '조언')
  ];
  
  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500)
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0)
      end: 1.0)
    ).animate(CurvedAnimation(
      parent: _animationController)
      curve: Curves.easeIn)
    ));
    
    _animationController.forward();
    
    // Check if we should auto-generate (coming from ad screen,
    final autoGenerate = widget.initialParams?['autoGenerate'] as bool? ?? false;
    if (autoGenerate) {
      _startDreamAnalysis();
    }
  }
  
  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }
  
  Future<void> _startDreamAnalysis() async {
    // Check soul consumption
    final tokenState = ref.read(tokenProvider);
    final tokenNotifier = ref.read(tokenProvider.notifier);
    final isPremium = tokenState.hasUnlimitedAccess;
    
    if (!isPremium && !tokenNotifier.canAccessFortune('dream')) {
      // Not enough souls - this should have been checked before navigation
      if (mounted) {
        Navigator.of(context).pop();
      }
      return;
    }
    
    // Consume souls if not premium
    if (!isPremium) {
      final soulAmount = SoulRates.getSoulAmount('dream');
      HapticUtils.heavyImpact();
      
      // Show soul consumption animation
      SoulConsumeAnimation.show(
        context: context,
        amount: -soulAmount)
        onComplete: () {
          Logger.info('Soul consumption animation completed');
        })
      );
      
      // Actually consume the souls
      await tokenNotifier.consumeSoul('dream');
    }
  }
  
  void _nextStep() {
    final analysisState = ref.read(dreamAnalysisProvider);
    final notifier = ref.read(dreamAnalysisProvider.notifier);
    
    if (notifier.canProceedToNextStep()) {
      HapticUtils.lightImpact();
      notifier.nextStep();
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut)
      );
    }
  }
  
  void _previousStep() {
    final notifier = ref.read(dreamAnalysisProvider.notifier);
    
    if (notifier.state.currentStep > 0) {
      HapticUtils.lightImpact();
      notifier.previousStep();
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut)
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final analysisState = ref.watch(dreamAnalysisProvider);
    
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Mystical background
          _buildMysticalBackground())
          
          // Main content
          SafeArea(
            child: Column(
              children: [
                // Header
                AppHeader(
                  title: '꿈 해몽')
                  showBackButton: true)
                  centerTitle: true)
                  onBackPressed: () {
                    // Confirm exit if in progress
                    if (analysisState.currentStep > 0) {
                      _showExitConfirmDialog();
                    } else {
                      Navigator.of(context).pop();
                    }
                  },
                ))
                
                // Progress indicator
                DreamProgressIndicator(
                  currentStep: analysisState.currentStep)
                  stepTitles: _stepTitles)
                  onStepTap: () {
                    // Could implement step navigation here if needed
                  })
                ),
                
                // Step content
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation)
                    child: PageView(
                      controller: _pageController)
                      physics: const NeverScrollableScrollPhysics())
                      children: [
                        DreamRecordingStep(
                          onNext: _nextStep)
                        ))
                        DreamSymbolsStep(
                          onNext: _nextStep)
                          onBack: _previousStep)
                        ))
                        DreamEmotionsStep(
                          onNext: _nextStep)
                          onBack: _previousStep)
                        ))
                        DreamRealityStep(
                          onNext: _nextStep)
                          onBack: _previousStep)
                        ))
                        DreamInterpretationStep(
                          onNext: _nextStep)
                          onBack: _previousStep)
                        ))
                        DreamAdviceStep(
                          onComplete: () {
                            // Complete the flow
                            _completeAnalysis();
                          })
                          onBack: _previousStep,
                        ))
                      ])
                    ),
                  ))
                ))
              ])
            ),
          ))
          
          // Loading overlay
          if (analysisState.isLoading)
            Container(
              color: Colors.black.withValues(alpha: 0.7))
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.deepPurple)
                ))
              ))
            ))
        ])
      )
    );
  }
  
  Widget _buildMysticalBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter)
          colors: [
            Colors.deepPurple.shade900)
            Colors.black)
          ])
        ),
      ))
      child: Stack(
        children: [
          // Stars
          ...List.generate(50, (index) {
            final random = index * 0.02;
            final size = 1.0 + (index % 3);
            final top = (index * 37 % 100) / 100.0;
            final left = (index * 71 % 100) / 100.0;
            
            return Positioned(
              top: MediaQuery.of(context).size.height * top)
              left: MediaQuery.of(context).size.width * left)
              child: Container(
                width: size)
                height: size)
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.3 + random))
                  shape: BoxShape.circle)
                ))
              )
                  .animate(
                    onPlay: (controller) => controller.repeat())
                  )
                  .scale(
                    duration: Duration(seconds: 2 + index % 3))
                    begin: const Offset(0.8, 0.8))
                    end: const Offset(1.2, 1.2))
                  )
                  .fadeIn()
                  .fadeOut(delay: Duration(seconds: 1 + index % 2)))
            );
          }))
          
          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.5)
                colors: [
                  Colors.deepPurple.withValues(alpha: 0.2))
                  Colors.transparent)
                ])
              ),
            ))
          ))
        ])
      ),
    );
  }
  
  void _showExitConfirmDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900)
        title: const Text(
          '꿈 해몽을 중단하시겠습니까?')
          style: TextStyle(color: Colors.white))
        ))
        content: const Text(
          '지금까지의 분석 내용이 저장되지 않습니다.')
          style: TextStyle(color: Colors.white70))
        ))
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop())
            child: const Text('계속하기'))
          ))
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              // Reset the analysis state
              ref.read(dreamAnalysisProvider.notifier).reset();
            })
            child: Text(
              '나가기',
              style: TextStyle(color: Colors.red.shade400))
            ))
          ))
        ])
      )
    );
  }
  
  void _completeAnalysis() {
    // Show completion animation or navigate to results
    HapticUtils.successNotification();
    
    // You could navigate to a results page or show a completion dialog
    showDialog(
      context: context,
      barrierDismissible: false)
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade900)
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade400))
            const SizedBox(width: 8))
            const Text(
              '꿈 해몽 완료')
              style: TextStyle(color: Colors.white))
            ))
          ])
        ),
        content: const Text(
          '당신의 꿈이 성공적으로 해석되었습니다.\n무의식이 전하는 메시지를 확인해보세요.')
          style: TextStyle(color: Colors.white70))
        ))
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
              // Reset the analysis state
              ref.read(dreamAnalysisProvider.notifier).reset();
            })
            child: const Text('확인'),
          ))
        ])
      )
    );
  }
}