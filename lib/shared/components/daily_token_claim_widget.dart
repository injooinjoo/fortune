import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../glassmorphism/glass_container.dart';
import '../../presentation/providers/token_provider.dart';
import '../../core/utils/haptic_utils.dart';
import '../../core/utils/secure_storage.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_animations.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

class DailyTokenClaimWidget extends ConsumerStatefulWidget {
  final bool showCompact;
  
  const DailyTokenClaimWidget({
    super.key,
    this.showCompact = false,
  });

  @override
  ConsumerState<DailyTokenClaimWidget> createState() => _DailyTokenClaimWidgetState();
}

class _DailyTokenClaimWidgetState extends ConsumerState<DailyTokenClaimWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  bool _isLoading = false;
  bool _canClaim = false;
  Timer? _checkTimer;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _checkClaimAvailability();
    
    // Check every minute if claiming becomes available
    _checkTimer = Timer.periodic(const Duration(minutes: 1), (_) {
      _checkClaimAvailability();
    });
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: AppAnimations.durationMedium,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 0.1,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    _checkTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkClaimAvailability() async {
    final lastClaimDate = await SecureStorage.getString('last_daily_claim_date');
    final today = DateTime.now();
    final todayString = '${today.year}-${today.month}-${today.day}';
    
    setState(() {
      _canClaim = lastClaimDate != todayString;
    });
  }

  Future<void> _claimDailyTokens() async {
    if (_isLoading || !_canClaim) return;

    setState(() => _isLoading = true);
    HapticUtils.lightImpact();

    try {
      // Animate the button
      await _animationController.forward();
      await _animationController.reverse();

      // Simulate API call
      await Future.delayed(const Duration(seconds: 1));

      // Mark as claimed for today
      final today = DateTime.now();
      final todayString = '${today.year}-${today.month}-${today.day}';
      await SecureStorage.setString('last_daily_claim_date', todayString);

      // Update token balance
      ref.refresh(tokenBalanceProvider);

      // Show success message
      if (mounted) {
        Toast.show(
          context: context,
          message: '일일 토큰 50개를 받았습니다!',
          type: ToastType.success,
        );
      }

      setState(() {
        _canClaim = false;
      });
    } catch (e) {
      if (mounted) {
        Toast.show(
          context: context,
          message: '토큰 지급에 실패했습니다. 다시 시도해주세요.',
          type: ToastType.error,
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_canClaim && widget.showCompact) {
      return const SizedBox.shrink();
    }

    return GlassContainer(
      padding: EdgeInsets.all(widget.showCompact ? AppSpacing.spacing3 : AppSpacing.spacing4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!widget.showCompact) ...[
            Icon(
              Icons.toll,
              size: 48,
              color: _canClaim ? AppColors.primary : AppColors.textSecondary,
            ),
            SizedBox(height: AppSpacing.spacing2),
            Text(
              '일일 토큰',
              style: AppTypography.titleMedium.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.spacing1),
            Text(
              _canClaim ? '오늘의 토큰을 받아보세요!' : '내일 다시 받을 수 있어요',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSpacing.spacing3),
          ],
          
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: _buildClaimButton(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClaimButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _canClaim && !_isLoading ? _claimDailyTokens : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _canClaim ? AppColors.primary : AppColors.surface,
          disabledBackgroundColor: AppColors.surface,
          foregroundColor: _canClaim ? Colors.white : AppColors.textSecondary,
          padding: EdgeInsets.symmetric(
            vertical: widget.showCompact ? AppSpacing.spacing2 : AppSpacing.spacing3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMedium),
          ),
          elevation: _canClaim ? 2 : 0,
        ),
        child: _isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _canClaim ? Colors.white : AppColors.textSecondary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _canClaim ? Icons.redeem : Icons.schedule,
                    size: widget.showCompact ? 16 : 20,
                  ),
                  SizedBox(width: AppSpacing.spacing1),
                  Text(
                    _canClaim ? '토큰 받기 (+50)' : '내일 다시',
                    style: AppTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: widget.showCompact ? 14 : 16,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// Helper enum for toast types if not defined elsewhere
enum ToastType { success, error, warning, info }

// Simple Toast class implementation if not defined elsewhere
class Toast {
  static void show({
    required BuildContext context,
    required String message,
    required ToastType type,
  }) {
    final color = switch (type) {
      ToastType.success => Colors.green,
      ToastType.error => Colors.red,
      ToastType.warning => Colors.orange,
      ToastType.info => Colors.blue,
    };

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}