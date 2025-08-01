import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_animations.dart';

class SajuLoadingWidget extends StatefulWidget {
  const SajuLoadingWidget({super.key});

  @override
  State<SajuLoadingWidget> createState() => _SajuLoadingWidgetState();
}

class _SajuLoadingWidgetState extends State<SajuLoadingWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  final List<String> _fortuneTellerMessages = [
    '천간지지를 살펴보고 있습니다...',
    '오행의 조화를 분석하고 있습니다...',
    '대운의 흐름을 읽어들이고 있습니다...',
    '당신의 사주팔자를 풀이하고 있습니다...',
    '십신의 관계를 파악하고 있습니다...',
  ];
  
  int _currentMessageIndex = 0;
  Timer? _messageTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppAnimations.durationXLong),
        vsync: this
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0)).animate(CurvedAnimation(,
      parent: _animationController),
        curve: Curves.easeInOut)
    )
    
    _animationController.forward();
    _startMessageRotation();
  }

  void _startMessageRotation() {
    _messageTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _animationController.reverse().then((_) {
        setState(() {
          _currentMessageIndex = (_currentMessageIndex + 1) % _fortuneTellerMessages.length;
        });
        _animationController.forward();
      });
    });
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: AppSpacing.spacing24 * 3.125,
      alignment: Alignment.center,
      child: Column(,
      mainAxisAlignment: MainAxisAlignment.center,
              ),
              children: [
          // 음양 기호 애니메이션
          TweenAnimationBuilder<double>(
            tween: Tween(begi,
      n: 0, end: 1),
            duration: const Duration(second,
      s: 2),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 2 * 3.14159,
                child: Container(,
      width: 60,
                  height: AppSpacing.spacing15,
                  decoration: BoxDecoration(,
      shape: BoxShape.circle,
                    gradient: LinearGradient(,
      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary)
                        theme.colorScheme.secondary)
                      ])
                    ))
                  child: Center(,
      child: Text(
                      '☯',
        ),
        style: Theme.of(context).textTheme.displaySmall?.copyWith(,
      color: theme.colorScheme.onPrimary,
                          ))
            })
          SizedBox(height: AppSpacing.spacing6),
          
          // 로딩 메시지 with fade animation
          FadeTransition(
            opacity: _fadeAnimation),
        child: Container(,
      padding: EdgeInsets.symmetric(horizont,
      al: AppSpacing.spacing6, vertical: AppSpacing.spacing3),
              decoration: BoxDecoration(,
      color: theme.colorScheme.primary.withValues(alp,
      ha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
                border: Border.all(,
      color: theme.colorScheme.primary.withValues(alp,
      ha: 0.3),
                  width: 1)),
      child: Text(
                _fortuneTellerMessages[_currentMessageIndex],
        ),
        style: theme.textTheme.bodyLarge?.copyWith(,
      color: theme.colorScheme.primary,
                          ),
        fontWeight: FontWeight.w500),
      textAlign: TextAlign.center)))))
          
          SizedBox(height: AppSpacing.spacing4),
          
          // Progress indicator
          SizedBox(
            width: 200),
              child: LinearProgressIndicator(,
      backgroundColor: theme.colorScheme.primary.withValues(alp,
      ha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary))))
        ]
      )
  }
}