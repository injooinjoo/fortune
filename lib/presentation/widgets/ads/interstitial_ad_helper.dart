import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/ad_provider.dart';
import '../../../core/utils/logger.dart';
import 'package:fortune/core/theme/app_animations.dart';

/// Helper class for showing interstitial ads with frequency capping
class InterstitialAdHelper {
  static Future<bool> showInterstitialAd(WidgetRef ref) async {
    final adService = ref.read(adServiceProvider);
    final frequencyCap = ref.read(adFrequencyCapProvider);
    
    // Check if we can show an interstitial ad
    if (!frequencyCap.canShowInterstitial()) {
      Logger.info('Interstitial ad frequency cap reached');
      return false;
    }
    
    // Check if ad is ready
    if (!adService.isInterstitialAdReady) {
      Logger.info('Interstitial ad not ready');
      // Try to load one for next time
      await adService.loadInterstitialAd();
      return false;
    }
    
    try {
      // Show the ad
      await adService.showInterstitialAd();
      
      // Record that we showed an ad
      ref.read(adFrequencyCapProvider.notifier).recordInterstitialShown();
      ref.read(adRevenueProvider.notifier).recordInterstitialImpression();
      
      return true;
    } catch (e) {
      Logger.error('Failed to show interstitial ad', e);
      return false;
    }
  }
  
  /// Show interstitial ad after fortune generation
  static Future<void> showAfterFortuneGeneration(WidgetRef ref) async {
    // Add a small delay to ensure smooth transition
    await Future.delayed(AppAnimations.durationLong);
    await showInterstitialAd(ref);
  }
  
  /// Preload an interstitial ad for later use
  static Future<void> preloadInterstitialAd(WidgetRef ref) async {
    final adService = ref.read(adServiceProvider);
    
    if (!adService.isInitialized) {
      Logger.warning('AdMob not initialized');
      return;
    }
    
    if (!adService.isInterstitialAdReady) {
      await adService.loadInterstitialAd();
    }
  }
}