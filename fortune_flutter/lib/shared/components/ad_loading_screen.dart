import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../glassmorphism/glass_container.dart';
import '../glassmorphism/glass_effects.dart';
import '../../core/theme/app_theme.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../presentation/widgets/ads/cross_platform_ad_widget.dart';

class AdLoadingScreen extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  final String fortuneType;
  final bool canSkip;

  const AdLoadingScreen({
    Key? key,
    required this.onComplete,
    required this.fortuneType,
    this.canSkip = false,
  }) : super(key: key);

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
      duration: const Duration(seconds: 5),
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));

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
    final user = ref.watch(userProvider).value;
    final isPremium = user?.userMetadata?['isPremium'] ?? false;

    // Premium users can skip immediately
    if (isPremium) {
      Future.microtask(() => widget.onComplete());
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Stack(
          children: [
            // Background Pattern
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [
                      theme.colorScheme.primary.withValues(alpha: 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: GridView.builder(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4,
                    childAspectRatio: 1,
                  ),
                  itemBuilder: (context, index) {
                    return Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            theme.colorScheme.primary.withValues(alpha: 0.05),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ).animate(
                      onPlay: (controller) => controller.repeat(),
                    ).shimmer(
                      duration: 3000.ms,
                      delay: Duration(milliseconds: index * 100),
                    );
                  },
                ),
              ),
            ),

            // Main Content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Fortune Icon
                    Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        _getFortuneIcon(widget.fortuneType),
                        color: Colors.white,
                        size: 60,
                      ),
                    ).animate()
                        .scale(
                          begin: const Offset(0.8, 0.8),
                          end: const Offset(1, 1),
                          duration: 500.ms,
                        )
                        .then()
                        .rotate(
                          begin: 0,
                          end: 1,
                          duration: 2000.ms,
                          curve: Curves.easeInOut,
                        ),

                    const SizedBox(height: 40),

                    // Loading Text
                    Text(
                      '${_getFortuneTitle(widget.fortuneType)} 준비 중...',
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate()
                        .fadeIn()
                        .slideY(begin: 0.2, end: 0),

                    const SizedBox(height: 16),

                    Text(
                      '잠시만 기다려주세요',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Progress Bar
                    GlassContainer(
                      width: 300,
                      height: 60,
                      padding: const EdgeInsets.all(8),
                      borderRadius: BorderRadius.circular(30),
                      blur: 20,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background Progress Track
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          // Animated Progress
                          AnimatedBuilder(
                            animation: _progressAnimation,
                            builder: (context, child) {
                              return FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: _progressAnimation.value,
                                child: Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        theme.colorScheme.primary,
                                        theme.colorScheme.secondary,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.colorScheme.primary
                                            .withValues(alpha: 0.3),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          // Countdown Text
                          Text(
                            _countdown > 0 ? '$_countdown' : '완료!',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Ad Message
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.info_outline_rounded,
                                color: Colors.white70,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '광고를 시청하고 무료로 운세를 확인하세요',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '프리미엄 회원은 광고 없이 이용 가능합니다',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Premium Upgrade Button
                    const SizedBox(height: 24),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/premium');
                      },
                      icon: const Icon(
                        Icons.diamond_rounded,
                        color: Colors.amber,
                      ),
                      label: Text(
                        '프리미엄으로 업그레이드',
                        style: TextStyle(
                          color: Colors.amber.shade400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Skip Button (if allowed)
            if (widget.canSkip && _countdown <= 3)
              Positioned(
                top: 20,
                right: 20,
                child: GlassButton(
                  onPressed: _skipAd,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '광고 건너뛰기',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.skip_next_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ).animate().fadeIn(duration: 300.ms),

            // Real Ad Banner (AdMob on mobile, AdSense on web)
            if (!isPremium)
              Positioned(
                bottom: 20,
                left: 20,
                right: 20,
                child: CommonAdPlacements.betweenContentAd(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  backgroundColor: Colors.black.withValues(alpha: 0.5),
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _getFortuneIcon(String type) {
    switch (type) {
      case 'daily':
      case 'today':
        return Icons.today_rounded;
      case 'love':
        return Icons.favorite_rounded;
      case 'saju':
        return Icons.auto_awesome_rounded;
      case 'compatibility':
        return Icons.people_rounded;
      case 'wealth':
        return Icons.attach_money_rounded;
      case 'mbti':
        return Icons.psychology_rounded;
      default:
        return Icons.stars_rounded;
    }
  }

  String _getFortuneTitle(String type) {
    switch (type) {
      case 'daily':
      case 'today':
        return '오늘의 운세';
      case 'love':
        return '연애운';
      case 'saju':
        return '사주팔자';
      case 'compatibility':
        return '궁합';
      case 'wealth':
        return '재물운';
      case 'mbti':
        return 'MBTI 운세';
      default:
        return '운세';
    }
  }
}

// Provider for ad state
final adLoadingProvider = StateProvider<bool>((ref) => false);