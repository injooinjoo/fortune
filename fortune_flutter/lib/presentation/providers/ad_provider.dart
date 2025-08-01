import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../services/ad_service.dart';
import '../../core/utils/logger.dart';
import '../../services/analytics_service.dart';

/// Provider for AdService instance
final adServiceProvider = Provider<AdService>((ref) {
  return AdService.instance;
});

/// Provider for ad initialization state
final adInitializedProvider = StateProvider<bool>((ref) => false);

/// Provider for banner ad ready state
final bannerAdReadyProvider = StateProvider<bool>((ref) => false);

/// Provider for interstitial ad ready state
final interstitialAdReadyProvider = StateProvider<bool>((ref) => false);

/// Provider for rewarded ad ready state
final rewardedAdReadyProvider = StateProvider<bool>((ref) => false);

/// Provider for current banner ad
final bannerAdProvider = StateProvider<BannerAd?>((ref) => null);

/// Provider for ad loading states
class AdLoadingState {
  final bool isBannerLoading;
  final bool isInterstitialLoading;
  final bool isRewardedLoading;

  const AdLoadingState({
    this.isBannerLoading = false,
    this.isInterstitialLoading = false,
    this.isRewardedLoading = false,
  });

  AdLoadingState copyWith({
    bool? isBannerLoading,
    bool? isInterstitialLoading,
    bool? isRewardedLoading,
  }) {
    return AdLoadingState(
      isBannerLoading: isBannerLoading ?? this.isBannerLoading,
      isInterstitialLoading: isInterstitialLoading ?? this.isInterstitialLoading,
      isRewardedLoading: isRewardedLoading ?? this.isRewardedLoading,
    );
  }
}

final adLoadingStateProvider = StateNotifierProvider<AdLoadingStateNotifier, AdLoadingState>((ref) {
  return AdLoadingStateNotifier();
});

class AdLoadingStateNotifier extends StateNotifier<AdLoadingState> {
  AdLoadingStateNotifier() : super(const AdLoadingState());

  void setBannerLoading(bool loading) {
    state = state.copyWith(isBannerLoading: loading);
  }

  void setInterstitialLoading(bool loading) {
    state = state.copyWith(isInterstitialLoading: loading);
  }

  void setRewardedLoading(bool loading) {
    state = state.copyWith(isRewardedLoading: loading);
  }
}

/// Provider for ad revenue tracking
class AdRevenue {
  final double totalRevenue;
  final int bannersShown;
  final int interstitialsShown;
  final int rewardedAdsShown;
  final int rewardsEarned;

  const AdRevenue({
    this.totalRevenue = 0.0,
    this.bannersShown = 0,
    this.interstitialsShown = 0,
    this.rewardedAdsShown = 0,
    this.rewardsEarned = 0,
  });

  AdRevenue copyWith({
    double? totalRevenue,
    int? bannersShown,
    int? interstitialsShown,
    int? rewardedAdsShown,
    int? rewardsEarned,
  }) {
    return AdRevenue(
      totalRevenue: totalRevenue ?? this.totalRevenue,
      bannersShown: bannersShown ?? this.bannersShown,
      interstitialsShown: interstitialsShown ?? this.interstitialsShown,
      rewardedAdsShown: rewardedAdsShown ?? this.rewardedAdsShown,
      rewardsEarned: rewardsEarned ?? this.rewardsEarned,
    );
  }
}

final adRevenueProvider = StateNotifierProvider<AdRevenueNotifier, AdRevenue>((ref) {
  return AdRevenueNotifier();
});

class AdRevenueNotifier extends StateNotifier<AdRevenue> {
  AdRevenueNotifier() : super(const AdRevenue());

  void recordBannerImpression() {
    state = state.copyWith(
      bannersShown: state.bannersShown + 1,
      // Estimated revenue per banner impression
      totalRevenue: state.totalRevenue + 0.001,
    );
    Logger.info('Banner impression recorded. Total: ${state.bannersShown}');
    
    // Track in analytics
    AnalyticsService.instance.logAdImpression(
      adType: 'banner',
      placement: 'general',
    );
  }

  void recordInterstitialImpression() {
    state = state.copyWith(
      interstitialsShown: state.interstitialsShown + 1,
      // Estimated revenue per interstitial impression
      totalRevenue: state.totalRevenue + 0.01,
    );
    Logger.info('Interstitial impression recorded. Total: ${state.interstitialsShown}');
    
    // Track in analytics
    AnalyticsService.instance.logAdImpression(
      adType: 'interstitial',
      placement: 'fortune_generation',
    );
  }

  void recordRewardedAdImpression() {
    state = state.copyWith(
      rewardedAdsShown: state.rewardedAdsShown + 1,
      rewardsEarned: state.rewardsEarned + 1,
      // Estimated revenue per rewarded ad
      totalRevenue: state.totalRevenue + 0.02,
    );
    Logger.info('Rewarded ad impression recorded. Total: ${state.rewardedAdsShown}');
    
    // Track in analytics
    AnalyticsService.instance.logAdImpression(
      adType: 'rewarded',
      placement: 'token_earn',
    );
    
    // Track reward earned
    AnalyticsService.instance.logAdReward(
      adType: 'rewarded',
      rewardAmount: 5, // Default token reward
    );
  }
}

/// Provider for ad frequency capping
class AdFrequencyCap {
  final DateTime? lastInterstitialShown;
  final int interstitialsShownToday;
  final DateTime? lastRewardedAdShown;
  final int rewardedAdsShownToday;

  const AdFrequencyCap({
    this.lastInterstitialShown,
    this.interstitialsShownToday = 0,
    this.lastRewardedAdShown,
    this.rewardedAdsShownToday = 0,
  });

  bool canShowInterstitial() {
    // Max 5 interstitials per day
    if (interstitialsShownToday >= 5) return false;
    
    // Minimum 3 minutes between interstitials
    if (lastInterstitialShown != null) {
      final timeSinceLastAd = DateTime.now().difference(lastInterstitialShown!);
      if (timeSinceLastAd.inMinutes < 3) return false;
    }
    
    return true;
  }

  bool canShowRewardedAd() {
    // Max 10 rewarded ads per day
    if (rewardedAdsShownToday >= 10) return false;
    
    // Minimum 1 minute between rewarded ads
    if (lastRewardedAdShown != null) {
      final timeSinceLastAd = DateTime.now().difference(lastRewardedAdShown!);
      if (timeSinceLastAd.inMinutes < 1) return false;
    }
    
    return true;
  }

  AdFrequencyCap copyWith({
    DateTime? lastInterstitialShown,
    int? interstitialsShownToday,
    DateTime? lastRewardedAdShown,
    int? rewardedAdsShownToday,
  }) {
    return AdFrequencyCap(
      lastInterstitialShown: lastInterstitialShown ?? this.lastInterstitialShown,
      interstitialsShownToday: interstitialsShownToday ?? this.interstitialsShownToday,
      lastRewardedAdShown: lastRewardedAdShown ?? this.lastRewardedAdShown,
      rewardedAdsShownToday: rewardedAdsShownToday ?? this.rewardedAdsShownToday,
    );
  }
}

final adFrequencyCapProvider = StateNotifierProvider<AdFrequencyCapNotifier, AdFrequencyCap>((ref) {
  return AdFrequencyCapNotifier();
});

class AdFrequencyCapNotifier extends StateNotifier<AdFrequencyCap> {
  AdFrequencyCapNotifier() : super(const AdFrequencyCap());

  void recordInterstitialShown() {
    state = state.copyWith(
      lastInterstitialShown: DateTime.now(),
      interstitialsShownToday: state.interstitialsShownToday + 1,
    );
  }

  void recordRewardedAdShown() {
    state = state.copyWith(
      lastRewardedAdShown: DateTime.now(),
      rewardedAdsShownToday: state.rewardedAdsShownToday + 1,
    );
  }

  void resetDailyCounters() {
    state = state.copyWith(
      interstitialsShownToday: 0,
      rewardedAdsShownToday: 0,
    );
  }
}