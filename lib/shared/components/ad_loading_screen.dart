import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../glassmorphism/glass_container.dart';
import '../glassmorphism/glass_effects.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_theme_extensions.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/widgets/ads/cross_platform_ad_widget.dart';
import '../../presentation/widgets/ads/common_ad_placements.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import '../../core/components/toss_fortune_loading_screen.dart';

class AdLoadingScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  final String fortuneType;
  final bool canSkip;

  const AdLoadingScreen({
    Key? key,
    required this.onComplete,
    required this.fortuneType,
    this.canSkip = false}) : super(key: key);

  @override
  ConsumerState<AdLoadingScreen> createState() => _AdLoadingScreenState();
}

class _AdLoadingScreenState extends ConsumerState<AdLoadingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;
  Timer? _timer;
  int _countdown = 5;
  bool _isSkipped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5));

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear);

    _startCountdown();
    _controller.forward();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 0) {
        setState(() {
          _countdown--;
        });
      } else {
        _completeAd();
      }
    });
  }

  void _completeAd() {
    if (!_isSkipped) {
      _timer?.cancel();
      widget.onComplete();
    }
  }

  void _skipAd() {
    setState(() {
      _isSkipped = true;
    });
    _timer?.cancel();
    _controller.stop();
    widget.onComplete();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final userProfile = ref.watch(userProfileProvider).value;
    final isPremium = userProfile?.isPremiumActive ?? false;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Premium users can skip immediately
    if (isPremium) {
      Future.microtask(() => widget.onComplete());
      return const SizedBox.shrink();
    }

    return Scaffold(
      body: Stack(
        children: [
          // 토스 스타일 로딩 화면
          TossFortuneLoadingScreen(
            fortuneType: widget.fortuneType,
            duration: const Duration(seconds: 5),
            onComplete: widget.onComplete,
          ),
          
          // 하단 광고 영역 (작게)
          if (!isPremium)
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // 광고 카운트다운 (아주 작게)
                  AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 80),
                        height: 2,
                        child: LinearProgressIndicator(
                          value: _progressAnimation.value,
                          backgroundColor: Colors.grey.withOpacity(0.2),
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.primary.withOpacity(0.5),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _countdown > 0 ? '$_countdown초' : '',
                    style: TextStyle(
                      fontSize: 11,
                      color: (isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary).withOpacity(0.4),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // 실제 광고 배너
                  CommonAdPlacements().betweenContentAd(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    backgroundColor: Colors.transparent,
                  ),
                ],
              ),
            ),
          
          // Skip 버튼 (우측 상단, 작게)
          if (widget.canSkip && _countdown <= 3)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: TextButton(
                onPressed: _skipAd,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size.zero,
                ),
                child: Text(
                  '건너뛰기',
                  style: TextStyle(
                    fontSize: 13,
                    color: (isDarkMode ? AppColors.textPrimaryDark : AppColors.textPrimary).withOpacity(0.6),
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms),
            ),
        ],
      ),
    );
  }

}

// Provider for ad state
final adLoadingProvider = StateProvider<bool>((ref) => false);