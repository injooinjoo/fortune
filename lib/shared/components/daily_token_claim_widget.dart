import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import '../glassmorphism/glass_container.dart';
import '../../presentation/providers/token_provider.dart';
import '../../core/utils/haptic_utils.dart';
import '../../core/utils/secure_storage.dart';
import '../../core/design_system/design_system.dart';

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
      duration: DSAnimation.durationMedium,
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
      ref.invalidate(tokenBalanceProvider);

      // Show success message
      if (mounted) {
        Toast.show(
          context: context,
          message: '일일 복주머니 50개를 받았습니다!',
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
          message: '복주머니 지급에 실패했습니다. 다시 시도해주세요.',
          type: ToastType.error,
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    if (!_canClaim && widget.showCompact) {
      return const SizedBox.shrink();
    }

    return GlassContainer(
      padding: EdgeInsets.all(widget.showCompact ? DSSpacing.sm : DSSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!widget.showCompact) ...[
            Icon(
              Icons.auto_awesome,
              size: 48,
              color: _canClaim ? colors.accentTertiary : colors.textTertiary,
            ),
            const SizedBox(height: DSSpacing.sm),
            Text(
              '일일 복주머니',
              style: typography.headingSmall.copyWith(
                color: colors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: DSSpacing.xs),
            Text(
              _canClaim ? '오늘의 복주머니를 받아보세요!' : '내일 다시 받을 수 있어요',
              style: typography.bodySmall.copyWith(
                color: colors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: DSSpacing.sm),
          ],

          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: _buildClaimButton(colors, typography),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildClaimButton(DSColorScheme colors, DSTypographyScheme typography) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _canClaim && !_isLoading ? _claimDailyTokens : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _canClaim ? colors.accentTertiary : colors.surfaceSecondary,
          disabledBackgroundColor: colors.surfaceSecondary,
          foregroundColor: _canClaim ? colors.surface : colors.textTertiary,
          padding: EdgeInsets.symmetric(
            vertical: widget.showCompact ? DSSpacing.sm : DSSpacing.sm + 4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(DSRadius.md),
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
                    _canClaim ? colors.surface : colors.textTertiary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _canClaim ? Icons.auto_awesome : Icons.schedule,
                    size: widget.showCompact ? 16 : 20,
                  ),
                  const SizedBox(width: DSSpacing.xs),
                  Text(
                    _canClaim ? '복주머니 받기 (+50)' : '내일 다시',
                    style: typography.labelLarge.copyWith(
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
    final colors = context.colors;

    final color = switch (type) {
      ToastType.success => colors.success,
      ToastType.error => colors.error,
      ToastType.warning => colors.warning,
      ToastType.info => colors.accent,
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
