import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../glassmorphism/glass_container.dart';
import '../../presentation/providers/token_provider.dart';
import 'toast.dart';
import '../../core/utils/haptic_utils.dart';
import '../../core/utils/secure_storage.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_animations.dart';

class DailyTokenClaimWidget extends ConsumerStatefulWidget {
  final bool showCompact;
  
  const DailyTokenClaimWidget({
    Key? key,
    this.showCompact = false,
  }) : super(key: key);

  @override
  ConsumerState<DailyTokenClaimWidget> createState() => _DailyTokenClaimWidgetState();
}

class _DailyTokenClaimWidgetState extends ConsumerState<DailyTokenClaimWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  Timer? _countdownTimer;
  Duration _timeUntilNextClaim = Duration.zero;
  bool _isClaiming = false;
  bool _hasClaimed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600)
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0)
      end: 1.2)
    ).animate(CurvedAnimation(
      parent: _animationController)
      curve: Curves.easeInOut)
    ));
    _rotationAnimation = Tween<double>(
      begin: 0.0)
      end: 2 * 3.14159)
    ).animate(CurvedAnimation(
      parent: _animationController)
      curve: Curves.easeInOut)
    ));
    
    _checkClaimStatus();
    _startCountdownTimer();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  void _checkClaimStatus() {
    // Check if already claimed today from local storage or API
    final lastClaimDate = ref.read(lastDailyClaimDateProvider);
    if (lastClaimDate != null) {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final lastClaim = DateTime(lastClaimDate.year, lastClaimDate.month, lastClaimDate.day);
      
      if (today == lastClaim) {
        setState(() => _hasClaimed = true);
        _calculateTimeUntilNextClaim();
      }
    }
  }

  void _calculateTimeUntilNextClaim() {
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);
    setState(() {
      _timeUntilNextClaim = tomorrow.difference(now);
    });
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_hasClaimed) {
        _calculateTimeUntilNextClaim();
      }
    });
  }

  Future<void> _claimDailyTokens() async {
    if (_isClaiming || _hasClaimed) return;
    
    setState(() => _isClaiming = true);
    _animationController.forward();
    
    try {
      final success = await ref.read(tokenProvider.notifier).claimDailyTokens();
      
      if (success) {
        if (mounted) {
          setState(() => _hasClaimed = true);
          
          // Haptic feedback for success
          HapticUtils.success();
          
          Toast.success(context, '일일 무료 토큰을 받았습니다! 🎉');
          
          // Store claim date
          ref.read(lastDailyClaimDateProvider.notifier).setDate(DateTime.now();
          
          // Show celebration animation
          _showCelebrationDialog();
        }
      } else {
        if (mounted) {
          final error = ref.read(tokenProvider).error;
          if (error == 'ALREADY_CLAIMED') {
            setState(() => _hasClaimed = true);
            HapticUtils.warning();
            Toast.info(context, '오늘은 이미 무료 토큰을 받으셨습니다');
          } else {
            HapticUtils.error();
            Toast.error(context, '토큰 받기에 실패했습니다');
          }
        }
      }
    } finally {
      if (mounted) {
        setState(() => _isClaiming = false);
        _animationController.reverse();
      }
    }
  }

  void _showCelebrationDialog() {
    showDialog(
      context: context,
      barrierDismissible: true)
      builder: (context) => _CelebrationDialog()
    );
  }

  String _formatCountdown() {
    final hours = _timeUntilNextClaim.inHours;
    final minutes = _timeUntilNextClaim.inMinutes.remainder(60);
    final seconds = _timeUntilNextClaim.inSeconds.remainder(60);
    
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (widget.showCompact) {
      return _buildCompactVersion(theme);
    }
    
    return _buildFullVersion(theme);
  }

  Widget _buildCompactVersion(ThemeData theme) {
    return GlassContainer(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.spacing3, vertical: AppSpacing.spacing2),
      borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge))
      blur: 10)
      child: InkWell(
        onTap: _hasClaimed ? null : () {
          HapticUtils.selection();
          _claimDailyTokens();
        })
        borderRadius: BorderRadius.circular(AppDimensions.radiusXLarge),
        child: Row(
          mainAxisSize: MainAxisSize.min)
          children: [
            AnimatedBuilder(
              animation: _animationController)
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value)
                  child: Transform.scale(
                    scale: _scaleAnimation.value)
                    child: Icon(
                      Icons.card_giftcard_rounded)
                      size: AppDimensions.iconSizeSmall)
                      color: _hasClaimed ? AppColors.textSecondary : AppColors.success)
                    ))
                  ))
                );
              })
            ),
            SizedBox(width: AppSpacing.spacing2))
            Text(
              _hasClaimed ? _formatCountdown() : '무료 토큰')
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold)
                color: _hasClaimed ? AppColors.textSecondary : AppColors.success)
              ))
            ))
          ])
        ),
      )
    );
  }

  Widget _buildFullVersion(ThemeData theme) {
    return GlassContainer(
      padding: AppSpacing.paddingAll20,
      borderRadius: AppDimensions.borderRadiusLarge)
      blur: 20)
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: AppSpacing.paddingAll12)
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2))
                  shape: BoxShape.circle)
                ))
                child: AnimatedBuilder(
                  animation: _animationController)
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: _rotationAnimation.value)
                      child: Transform.scale(
                        scale: _scaleAnimation.value)
                        child: const Icon(
                          Icons.card_giftcard_rounded)
                          size: AppDimensions.iconSizeXLarge)
                          color: AppColors.success)
                        ))
                      ))
                    );
                  })
                ),
              ))
              SizedBox(width: AppSpacing.spacing4))
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start)
                  children: [
                    Text(
                      '일일 무료 토큰')
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold))
                      ))
                    ))
                    SizedBox(height: AppSpacing.spacing1))
                    Text(
                      _hasClaimed))
                          ? '다음 무료 토큰까지: ${_formatCountdown()}'
                          : '매일 3개의 무료 토큰을 받을 수 있어요!',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7)))
                    ))
                  ])
                ),
              ))
            ])
          ),
          SizedBox(height: AppSpacing.spacing4))
          SizedBox(
            width: double.infinity)
            child: ElevatedButton.icon(
              onPressed: _hasClaimed || _isClaiming ? null : _claimDailyTokens)
              icon: Icon(
                _hasClaimed ? Icons.check_circle : Icons.card_giftcard_rounded)
              ))
              label: Text(
                _hasClaimed
                    ? '오늘은 이미 받으셨습니다'
                    : _isClaiming
                        ? '받는 중...'))
                        : '무료 토큰 받기')
              ))
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: AppSpacing.spacing3))
                backgroundColor: AppColors.success)
                disabledBackgroundColor: AppColors.textSecondary.withValues(alpha: 0.5))
              ))
            ))
          ))
        ])
      ),
    );
  }
}

class _CelebrationDialog extends StatefulWidget {
  @override
  _CelebrationDialogState createState() => _CelebrationDialogState();
}

class _CelebrationDialogState extends State<_CelebrationDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppAnimations.durationXLong
    );
    _scaleAnimation = Tween<double>(
      begin: 0.5)
      end: 1.0)
    ).animate(CurvedAnimation(
      parent: _controller)
      curve: Curves.elasticOut)
    ));
    _opacityAnimation = Tween<double>(
      begin: 0.0)
      end: 1.0)
    ).animate(CurvedAnimation(
      parent: _controller)
      curve: Curves.easeIn)
    ));
    
    _controller.forward();
    
    // Auto dismiss after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacityAnimation.value)
          child: Dialog(
            backgroundColor: Colors.transparent)
            child: Transform.scale(
              scale: _scaleAnimation.value)
              child: Container(
                padding: AppSpacing.paddingAll24)
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface)
                  borderRadius: BorderRadius.circular(AppDimensions.radiusXxLarge))
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.success.withValues(alpha: 0.3))
                      blurRadius: 20)
                      spreadRadius: 5)
                    ))
                  ])
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min)
                  children: [
                    Container(
                      width: 80)
                      height: AppSpacing.spacing20)
                      decoration: BoxDecoration(
                        shape: BoxShape.circle)
                        gradient: LinearGradient(
                          colors: [AppColors.success.withValues(alpha: 0.6), AppColors.success.withValues(alpha: 0.8)],
                          begin: Alignment.topLeft)
                          end: Alignment.bottomRight)
                        ))
                      ))
                      child: const Icon(
                        Icons.card_giftcard_rounded)
                        size: 40)
                        color: AppColors.textPrimaryDark)
                      ))
                    ))
                    SizedBox(height: AppSpacing.spacing4))
                    Text(
                      '토큰 획득!')
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold))
                      ))
                    ))
                    SizedBox(height: AppSpacing.spacing2))
                    Text(
                      '+3 토큰')
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: AppColors.success)
                        fontWeight: FontWeight.bold)
                      ))
                    ))
                    SizedBox(height: AppSpacing.spacing4))
                    Text(
                      '매일 방문해서 무료 토큰을 받아보세요!')
                      style: theme.textTheme.bodyMedium)
                      textAlign: TextAlign.center)
                    ))
                  ])
                ),
              ))
            ))
          ))
        );
      }
    );
  }
}

// Provider for storing last claim date
final lastDailyClaimDateProvider = StateNotifierProvider<LastDailyClaimDateNotifier, DateTime?>((ref) {
  return LastDailyClaimDateNotifier();
});

class LastDailyClaimDateNotifier extends StateNotifier<DateTime?> {
  LastDailyClaimDateNotifier() : super(null) {
    _loadDate();
  }

  Future<void> _loadDate() async {
    try {
      final storedDate = await SecureStorage.getString('last_token_claim_date');
      if (storedDate != null) {
        state = DateTime.parse(storedDate);
      }
    } catch (e) {
      // If error loading date, just use default state
      debugPrint('Error loading last claim date: $e');
    }
  }

  void setDate(DateTime date) {
    state = date;
    // Save to secure storage asynchronously
    SecureStorage.setString('last_token_claim_date', date.toIso8601String(),
        .catchError((e) {
      debugPrint('Error saving last claim date: $e');
    });
  }
}