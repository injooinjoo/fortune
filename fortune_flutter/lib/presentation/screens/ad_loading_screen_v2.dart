import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/utils/logger.dart';
import '../providers/ad_provider.dart';
import '../widgets/ads/interstitial_ad_helper.dart';
import '../../services/ad_service.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_animations.dart';

/// Enhanced Ad Loading Screen that integrates real AdMob ads
class AdLoadingScreenV2 extends ConsumerStatefulWidget {
  final String fortuneType;
  final String fortuneTitle;
  final VoidCallback onComplete;
  final VoidCallback onSkip;
  final bool isPremium;
  final Future<dynamic> Function()? fetchData;
  final Future<void> Function()? onAdComplete;
  final String? fortuneRoute;
  final Map<String, dynamic>? fortuneParams;

  const AdLoadingScreenV2({
    super.key,
    required this.fortuneType,
    required this.fortuneTitle,
    required this.onComplete,
    required this.onSkip,
    required this.isPremium,
    this.fetchData,
    this.onAdComplete,
    this.fortuneRoute,
    this.fortuneParams,
  });

  @override
  ConsumerState<AdLoadingScreenV2> createState() => _AdLoadingScreenV2State();
}

class _AdLoadingScreenV2State extends ConsumerState<AdLoadingScreenV2>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;
  bool _isLoading = true;
  dynamic _fetchedData;
  String? _errorMessage;
  bool _adShown = false;
  bool _dataFetched = false;

  // 운세별 로딩 메시지
  final Map<String, List<String>> _loadingMessages = {
    'default': [
      '✨ 우주의 신비로운 기운이 모이고 있습니다...',
      '🌙 달빛이 당신의 미래를 비추고 있습니다...',
      '⭐ 별들이 속삭이는 비밀을 해독하고 있습니다...',
      '🔮 수정구슬에 당신의 운명이 나타나고 있습니다...',
    ],
  };

  String _currentMessage = '';
  int _messageIndex = 0;

  @override
  void initState() {
    super.initState();
    Logger.info('AdLoadingScreenV2 opened for ${widget.fortuneType}');
    
    _animationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this
    );

    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _startLoading();
  }

  void _startLoading() async {
    // Set initial loading message
    final messages = _loadingMessages[widget.fortuneType] ?? _loadingMessages['default']!;
    _currentMessage = messages[0];

    // Start progress animation
    _animationController.forward();

    // Message rotation timer
    Timer.periodic(AppAnimations.durationSkeleton, (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      setState(() {
        _messageIndex = (_messageIndex + 1) % messages.length;
        _currentMessage = messages[_messageIndex];
      });
    });

    // Premium users skip ads
    if (widget.isPremium) {
      await _fetchFortuneData();
      if (mounted) {
        _completeLoading();
      }
      return;
    }

    // For free users, fetch data and show ad in parallel
    final futures = <Future>[];
    
    // Fetch fortune data
    if (widget.fetchData != null) {
      futures.add(_fetchFortuneData();
    }
    
    // Preload and show interstitial ad
    futures.add(_showInterstitialAd();
    
    // Wait for both operations
    await Future.wait(futures);
    
    // Small delay to ensure smooth transition
    await Future.delayed(AppAnimations.durationLong);
    
    if (mounted) {
      _completeLoading();
    }
  }

  Future<void> _fetchFortuneData() async {
    if (widget.fetchData == null) {
      setState(() {
        _dataFetched = true;
      });
      return;
    }

    try {
      final stopwatch = Logger.startTimer('Fortune data fetch');
      _fetchedData = await widget.fetchData!();
      Logger.endTimer('Fortune data fetch', stopwatch);
      
      setState(() {
        _dataFetched = true;
        _isLoading = false;
      });
    } catch (error) {
      Logger.error('Failed to fetch fortune data', error);
      setState(() {
        _dataFetched = true;
        _isLoading = false;
        _errorMessage = '운세 데이터를 불러오는데 실패했습니다.';
      });
    }
  }

  Future<void> _showInterstitialAd() async {
    try {
      // Ensure ad service is initialized
      final adService = ref.read(adServiceProvider);
      if (!adService.isInitialized) {
        Logger.warning('AdMob not initialized, skipping ad');
        setState(() {
          _adShown = true;
        });
        return;
      }

      // Check if we can show an ad
      final frequencyCap = ref.read(adFrequencyCapProvider);
      if (!frequencyCap.canShowInterstitial()) {
        Logger.info('Ad frequency cap reached, skipping ad');
        setState(() {
          _adShown = true;
        });
        return;
      }

      // Preload interstitial if not ready
      if (!adService.isInterstitialAdReady) {
        await InterstitialAdHelper.preloadInterstitialAd(ref);
        // Wait a bit for ad to load
        await Future.delayed(const Duration(seconds: 2);
      }

      // Show the interstitial ad
      final adShown = await InterstitialAdHelper.showInterstitialAd(ref);
      
      setState(() {
        _adShown = true;
      });

      // If ad was shown, give token reward
      if (adShown && widget.onAdComplete != null) {
        try {
          await widget.onAdComplete!();
          Logger.analytics('token_reward_for_ad', {
            'fortune_type': widget.fortuneType,
          });
        } catch (e) {
          Logger.error('Failed to reward tokens for ad', e);
        }
      }
    } catch (e) {
      Logger.error('Error showing interstitial ad', e);
      setState(() {
        _adShown = true;
      });
    }
  }

  void _completeLoading() async {
    if (_errorMessage != null) {
      // Show error and allow retry
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_errorMessage!),
          action: SnackBarAction(
            label: '다시 시도',
            onPressed: () {
              setState(() {
                _errorMessage = null;
                _isLoading = true;
                _adShown = false;
                _dataFetched = false;
              });
              _startLoading();
            },
          ),
        ,
      );
      return;
    }

    // Wait for both data fetch and ad to complete
    if (!_dataFetched || !_adShown) {
      Future.delayed(AppAnimations.durationLong, () {
        if (mounted) {
          _completeLoading();
        }
      });
      return;
    }

    Logger.analytics('ad_loading_complete', {
      'fortune_type': widget.fortuneType,
      'is_premium': widget.isPremium,
    });

    // Navigate to fortune page if route provided
    if (widget.fortuneRoute != null && mounted) {
      try {
        context.pushReplacement(
          widget.fortuneRoute!,
          extra: {
            'fortuneData': _fetchedData,
            'fortuneParams': widget.fortuneParams,
          }
        );
      } catch (e) {
        Logger.error('Navigation error', e);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('페이지 이동 중 오류가 발생했습니다: $e'),
              backgroundColor: Colors.red,
            ,
          );
          Navigator.of(context).pop();
        }
      }
    } else {
      widget.onComplete();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradient animation
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.purple.withValues(alpha: 0.92).withValues(alpha: 0.3),
                          Colors.indigo.withValues(alpha: 0.92).withValues(alpha: 0.3),
                        ],
                        transform: GradientRotation(
                          _animationController.value * 2 * 3.14159,
                        ),
                      ),
                    ,
                  );
                },
              ),
            ),
            
            // Main content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.spacing8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated icon
                    Container(
                      width: 100,
                      height: AppSpacing.spacing24 * 1.04,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.white.withValues(alpha: 0.2),
                            Colors.white.withValues(alpha: 0.05),
                          ],
                        ),
                      ),
                      child: Icon(
                        Icons.auto_awesome,
                        size: 50,
                        color: Colors.white,
                      ),
                    ).animate(
                      onPlay: (controller) => controller.repeat(),
                    ).scale(
                      duration: 2.seconds,
                      begin: const Offset(0.95, 0.95),
                      end: const Offset(1.05, 1.05),
                      curve: Curves.easeInOut,
                    ).shimmer(
                      duration: 2.seconds,
                      color: Colors.white.withValues(alpha: 0.3),
                    ),
                    
                    const SizedBox(height: AppSpacing.spacing12),
                    
                    // Title
                    Text(
                      widget.fortuneTitle,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: Colors.white),),
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate(,
                      .fadeIn(duration: 800.ms,
                      .slideY(begin: -0.3, end: 0),
                    
                    const SizedBox(height: AppSpacing.spacing6),
                    
                    // Loading message
                    AnimatedSwitcher(
                      duration: AppAnimations.durationXLong,
                      child: Text(
                        _currentMessage,
                        key: ValueKey(_currentMessage),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white70,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    
                    const SizedBox(height: AppSpacing.spacing12),
                    
                    // Progress bar
                    Container(
                      height: AppSpacing.spacing2,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: AppDimensions.borderRadiusSmall,
                      ),
                      child: AnimatedBuilder(
                        animation: _progressAnimation,
                        builder: (context, child) {
                          return FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: _progressAnimation.value,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Theme.of(context).colorScheme.primary,
                                    Theme.of(context).colorScheme.secondary,
                                  ],
                                ),
                                borderRadius: AppDimensions.borderRadiusSmall,
                              ),
                            ).animate(
                              onPlay: (controller) => controller.repeat(),
                            ).shimmer(
                              duration: 1.5.seconds,
                              color: Colors.white.withValues(alpha: 0.3),
                            ,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Skip button (top right,
            Positioned(
              top: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Colors.white70,
                  size: 28,
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            
            // Premium upgrade button (bottom,
            if (!widget.isPremium,
              Positioned(
                left: 32,
                right: 32,
                bottom: 48,
                child: Column(
                  children: [
                    Text(
                      '광고 없이 바로 운세를 확인하고 싶으신가요?',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white60),),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppSpacing.spacing4),
                    ElevatedButton(
                      onPressed: widget.onSkip,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Theme.of(context).colorScheme.primary,
                        minimumSize: const Size(double.infinity, 56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppSpacing.spacing7),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.rocket_launch, size: 20),
                          SizedBox(width: AppSpacing.spacing2),
                          Text(
                            '프리미엄으로 업그레이드',
                            style: Theme.of(context).textTheme.bodyMedium,
                        ],
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 1.seconds).slideY(begin: 0.3, end: 0),
              ),
          ],
        ),
      ,
    );
  }
}