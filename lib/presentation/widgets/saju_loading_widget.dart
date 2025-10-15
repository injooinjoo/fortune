import 'package:flutter/material.dart';
import 'dart:async';
import 'package:fortune/core/theme/app_theme_extensions.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class SajuLoadingWidget extends StatefulWidget {
  const SajuLoadingWidget({super.key});

  @override
  State<SajuLoadingWidget> createState() => _SajuLoadingWidgetState();
}

class _SajuLoadingWidgetState extends State<SajuLoadingWidget> 
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  int _currentMessageIndex = 0;
  Timer? _messageTimer;
  
  final List<String> _fortuneTellerMessages = [
    '사주를 분석하고 있습니다...',
    '천간지지를 해석하는 중...',
    '오행의 기운을 살펴보는 중...',
    '운세의 흐름을 파악하는 중...'];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
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
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 태극 심볼 애니메이션
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 2 * 3.14159,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary,
                        theme.colorScheme.secondary],
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '☯',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: theme.colorScheme.onPrimary),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: AppSpacing.spacing6),
          
          // 로딩 메시지 with fade animation
          FadeTransition(
            opacity: _fadeAnimation,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.spacing6,
                vertical: AppSpacing.spacing3),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                borderRadius: AppDimensions.borderRadiusMedium,
                border: Border.all(
                  color: theme.colorScheme.primary.withValues(alpha: 0.3)),
              ),
              child: Text(
                _fortuneTellerMessages[_currentMessageIndex],
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}