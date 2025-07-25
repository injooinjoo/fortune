import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../providers/ad_provider.dart';
import '../../providers/token_provider.dart';
import '../../../services/ad_service.dart';
import '../../../core/utils/logger.dart';
import '../../../core/theme/app_theme.dart';

/// Button widget for watching rewarded ads to earn tokens
class RewardedAdButton extends ConsumerStatefulWidget {
  final String label;
  final int tokenReward;
  final VoidCallback? onRewardEarned;
  final bool showTokenAmount;

  const RewardedAdButton({
    super.key,
    this.label = '광고 보고 토큰 받기',
    this.tokenReward = 5,
    this.onRewardEarned,
    this.showTokenAmount = true,
  });

  @override
  ConsumerState<RewardedAdButton> createState() => _RewardedAdButtonState();
}

class _RewardedAdButtonState extends ConsumerState<RewardedAdButton> {
  bool _isLoading = false;

  Future<void> _showRewardedAd() async {
    final adService = ref.read(adServiceProvider);
    final frequencyCap = ref.read(adFrequencyCapProvider);
    
    // Check if we can show a rewarded ad
    if (!frequencyCap.canShowRewardedAd()) {
      _showSnackBar('잠시 후 다시 시도해주세요');
      return;
    }
    
    setState(() {
      _isLoading = true;
    });
    
    try {
      // Check if ad is ready
      if (!adService.isRewardedAdReady) {
        // Load a rewarded ad
        await adService.loadRewardedAd();
        
        // Wait a bit for ad to load
        await Future.delayed(const Duration(seconds: 2));
        
        if (!adService.isRewardedAdReady) {
          _showSnackBar('광고를 불러올 수 없습니다');
          return;
        }
      }
      
      // Show the ad
      await adService.showRewardedAd(
        onUserEarnedReward: (ad, reward) async {
          Logger.info('User earned reward: ${reward.amount} ${reward.type}');
          
          // Add tokens to user's balance
          await ref.read(tokenServiceProvider).earnTokensFromAd(widget.tokenReward);
          
          // Update providers
          ref.read(adFrequencyCapProvider.notifier).recordRewardedAdShown();
          ref.read(adRevenueProvider.notifier).recordRewardedAdImpression();
          
          // Call custom callback if provided
          widget.onRewardEarned?.call();
          
          // Show success message
          _showSnackBar('${widget.tokenReward} 토큰을 받았습니다!');
        },
      );
    } catch (e) {
      Logger.error('Failed to show rewarded ad', e);
      _showSnackBar('광고 재생 중 오류가 발생했습니다');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
  
  void _showSnackBar(String message) {
    if (!mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final extensions = theme.extension<AppThemeExtensions>()!;
    
    return ElevatedButton.icon(
      onPressed: _isLoading ? null : _showRewardedAd,
      icon: _isLoading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  theme.colorScheme.onPrimary,
                ),
              ),
            )
          : Icon(
              Icons.play_circle_outline,
              color: theme.colorScheme.onPrimary,
            ),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.label,
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (widget.showTokenAmount) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.onPrimary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '+${widget.tokenReward}',
                style: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 2,
      ),
    );
  }
}