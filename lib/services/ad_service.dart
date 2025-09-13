import 'package:fortune/core/theme/toss_design_system.dart';
import 'dart:io';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart' show VoidCallback;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/config/environment.dart';
import '../core/utils/logger.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';

/// Service for managing Google AdMob ads
class AdService {
  static final AdService _instance = AdService._internal();
  factory AdService() => _instance;
  AdService._internal();

  static AdService get instance => _instance;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // Test ad unit IDs
  static const String _testBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static const String _testInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String _testRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const String _testNativeAdUnitId = 'ca-app-pub-3940256099942544/2247696110';

  // Ad objects
  BannerAd? _bannerAd;
  InterstitialAd? _interstitialAd;
  RewardedAd? _rewardedAd;

  // Ad loading states
  bool _isBannerAdReady = false;
  bool _isInterstitialAdReady = false;
  bool _isRewardedAdReady = false;

  // Getters
  bool get isBannerAdReady => _isBannerAdReady;
  bool get isInterstitialAdReady => _isInterstitialAdReady;
  bool get isRewardedAdReady => _isRewardedAdReady;
  BannerAd? get bannerAd => _bannerAd;

  /// Initialize the AdMob SDK
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      Logger.info('Starting AdMob SDK initialization...');

      // Check if ads are enabled
      if (!Environment.enableAds) {
        Logger.info('Ads are disabled via feature flag');
        return;
      }

      // Initialize MobileAds SDK with timeout
      // Use Future.any to ensure we don't block indefinitely
      await Future.any([
        MobileAds.instance.initialize().then((status) {
          Logger.info('AdMob SDK initialized with status: ${status.adapterStatuses.keys.join(', ')}');
          return status;
        }),
        Future.delayed(const Duration(seconds: 3)).then((_) {
          Logger.warning('AdMob SDK initialization timed out after 3 seconds - continuing without ads');
          return InitializationStatus({});
        }),
      ]);

      // Configure test devices for development
      if (kDebugMode) {
        try {
          final testDeviceIds = <String>[];
          if (Platform.isAndroid) {
            // Add Android test device IDs here
            testDeviceIds.add('YOUR_ANDROID_TEST_DEVICE_ID');
          } else if (Platform.isIOS) {
            // Add iOS test device IDs here
            testDeviceIds.add('YOUR_IOS_TEST_DEVICE_ID');
          }

          await MobileAds.instance.updateRequestConfiguration(
            RequestConfiguration(testDeviceIds: testDeviceIds)).timeout(
              const Duration(seconds: 1),
              onTimeout: () {
                Logger.warning('Test device configuration timed out');
              },
            );
        } catch (e) {
          Logger.warning('Failed to configure test devices: $e');
        }
      }

      _isInitialized = true;
      Logger.info('AdMob SDK initialized successfully');

      // Preload ads asynchronously in the background
      // Don't await this - let it run in the background
      _preloadAdsInBackground();
    } catch (e) {
      Logger.error('Failed to initialize AdMob SDK: $e');
      // Don't throw - let the app continue without ads
      _isInitialized = false;
    }
  }

  /// Get the appropriate ad unit ID based on environment
  String _getAdUnitId(String type) {
    // Always use test ads in debug mode
    if (kDebugMode) {
      switch (type) {
        case 'banner':
          return _testBannerAdUnitId;
        case 'interstitial':
          return _testInterstitialAdUnitId;
        case 'rewarded':
          return _testRewardedAdUnitId;
        case 'native':
          return _testNativeAdUnitId;
        default:
          return _testBannerAdUnitId;
      }
    }

    // Use production ad unit IDs
    switch (type) {
      case 'banner':
        return Environment.admobBannerAdUnitId;
      case 'interstitial':
        return Environment.admobInterstitialAdUnitId;
      case 'rewarded':
        return Environment.admobRewardedAdUnitId;
      case 'native':
        // TODO: Add native ad unit ID to Environment
        return _testNativeAdUnitId;
      default:
        return Environment.admobBannerAdUnitId;
    }
  }

  /// Preload ads for better user experience
  Future<void> _preloadAds() async {
    await loadBannerAd();
    await loadInterstitialAd();
    await loadRewardedAd();
  }

  /// Preload ads in the background without blocking app startup
  void _preloadAdsInBackground() {
    // Load ads with timeout to prevent hanging
    Future.delayed(const Duration(milliseconds: 500), () async {
      try {
        Logger.info('Starting background ad preloading...');

        // Load banner ad with timeout
        Logger.info('Loading Banner ad...');
        loadBannerAd().timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            Logger.warning('Banner ad loading timed out');
          },
        );

        // Load interstitial ad with timeout
        Logger.info('Loading Interstitial ad...');
        loadInterstitialAd().timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            Logger.warning('Interstitial ad loading timed out');
          },
        );

        // Load rewarded ad with timeout
        Logger.info('Loading Rewarded ad...');
        loadRewardedAd().timeout(
          const Duration(seconds: 2),
          onTimeout: () {
            Logger.warning('Rewarded ad loading timed out');
          },
        );
      } catch (e) {
        Logger.error('Error preloading ads in background', e);
      }
    });
  }

  /// Load a banner ad
  Future<void> loadBannerAd({
    AdSize adSize = AdSize.banner,
    void Function(Ad)? onAdLoaded,
    void Function(Ad, LoadAdError)? onAdFailedToLoad}) async {
    if (!_isInitialized) {
      Logger.warning('AdMob SDK not initialized');
      return;
    }

    _bannerAd = BannerAd(
      adUnitId: _getAdUnitId('banner'),
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerAdReady = true;
          Logger.info('Banner ad loaded successfully');
          onAdLoaded?.call(ad);
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerAdReady = false;
          ad.dispose();
          Logger.error('Banner ad failed to load', error);
          onAdFailedToLoad?.call(ad, error);
        },
        onAdOpened: (ad) => Logger.info('Banner ad opened'),
        onAdClosed: (ad) => Logger.info('Banner ad closed'),
        onAdImpression: (ad) => Logger.info('Banner ad impression'),
        onAdClicked: (ad) => Logger.info('Banner ad clicked')));

    await _bannerAd!.load();
  }

  /// Load an interstitial ad
  Future<void> loadInterstitialAd({
    void Function(InterstitialAd)? onAdLoaded,
    void Function(LoadAdError)? onAdFailedToLoad}) async {
    if (!_isInitialized) {
      Logger.warning('AdMob SDK not initialized');
      return;
    }

    await InterstitialAd.load(
      adUnitId: _getAdUnitId('interstitial'),
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          Logger.info('Interstitial ad loaded successfully');
          onAdLoaded?.call(ad);

          // Set full screen content callback
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialAdReady = false;
              // Load next interstitial ad
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isInterstitialAdReady = false;
              Logger.error('Interstitial ad failed to show', error);
            },
            onAdShowedFullScreenContent: (ad) {
              Logger.info('Interstitial ad showed');
            });
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdReady = false;
          Logger.error('Interstitial ad failed to load', error);
          onAdFailedToLoad?.call(error);
        },
      ),
    );
  }

  /// Show an interstitial ad
  Future<void> showInterstitialAd() async {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      await _interstitialAd!.show();
    } else {
      Logger.warning('Interstitial ad not ready');
    }
  }

  /// Show an interstitial ad with callback when completed
  Future<void> showInterstitialAdWithCallback({
    VoidCallback? onAdCompleted,
    VoidCallback? onAdFailed,
  }) async {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      // Set up callback for when ad is completed
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          _isInterstitialAdReady = false;
          Logger.info('Interstitial ad dismissed');
          // Execute callback when ad is completed
          onAdCompleted?.call();
          // Load next interstitial ad
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) {
          ad.dispose();
          _isInterstitialAdReady = false;
          Logger.error('Interstitial ad failed to show', error);
          // Execute failure callback
          onAdFailed?.call();
        },
        onAdShowedFullScreenContent: (ad) {
          Logger.info('Interstitial ad showed');
        },
      );
      
      await _interstitialAd!.show();
    } else {
      Logger.warning('Interstitial ad not ready - executing callback immediately');
      // If ad is not ready, execute the callback immediately
      onAdCompleted?.call();
    }
  }

  /// Load a rewarded ad
  Future<void> loadRewardedAd({
    void Function(RewardedAd)? onAdLoaded,
    void Function(LoadAdError)? onAdFailedToLoad}) async {
    if (!_isInitialized) {
      Logger.warning('AdMob SDK not initialized');
      return;
    }

    await RewardedAd.load(
      adUnitId: _getAdUnitId('rewarded'),
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedAdReady = true;
          Logger.info('Rewarded ad loaded successfully');
          onAdLoaded?.call(ad);

          // Set full screen content callback
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isRewardedAdReady = false;
              // Load next rewarded ad
              loadRewardedAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isRewardedAdReady = false;
              Logger.error('Rewarded ad failed to show', error);
            },
            onAdShowedFullScreenContent: (ad) {
              Logger.info('Rewarded ad showed');
            });
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdReady = false;
          Logger.error('Rewarded ad failed to load', error);
          onAdFailedToLoad?.call(error);
        },
      ),
    );
  }

  /// Show a rewarded ad
  Future<void> showRewardedAd({
    required void Function(Ad ad, RewardItem reward) onUserEarnedReward}) async {
    if (_isRewardedAdReady && _rewardedAd != null) {
      await _rewardedAd!.show(onUserEarnedReward: onUserEarnedReward);
    } else {
      Logger.warning('Rewarded ad not ready');
    }
  }

  /// Create a native ad
  NativeAd createNativeAd({
    required NativeAdListener listener,
    NativeTemplateStyle? nativeTemplateStyle,
    TemplateType templateType = TemplateType.medium}) {
    if (!_isInitialized) {
      throw Exception('AdMob SDK not initialized');
    }

    return NativeAd(
      adUnitId: _getAdUnitId('native'),
      listener: listener,
      request: const AdRequest(),
      nativeTemplateStyle: nativeTemplateStyle ??
          NativeTemplateStyle(
            templateType: templateType,
            mainBackgroundColor: const material.Color(0xFFF5F5F5),
            cornerRadius: 8.0,
            callToActionTextStyle: NativeTemplateTextStyle(
              textColor: TossDesignSystem.gray900,
              backgroundColor: const material.Color(0xFF4285F4),
              style: NativeTemplateFontStyle.bold,
              size: 16.0),
            primaryTextStyle: NativeTemplateTextStyle(
              textColor: TossDesignSystem.gray900.withOpacity(0.87),
              style: NativeTemplateFontStyle.normal,
              size: 16.0),
            secondaryTextStyle: NativeTemplateTextStyle(
              textColor: TossDesignSystem.gray900.withOpacity(0.54),
              style: NativeTemplateFontStyle.normal,
              size: 14.0),
            tertiaryTextStyle: NativeTemplateTextStyle(
              textColor: TossDesignSystem.gray900.withOpacity(0.54),
              style: NativeTemplateFontStyle.normal,
              size: 12.0)));
  }

  /// Dispose of ads
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _isBannerAdReady = false;
    _isInterstitialAdReady = false;
    _isRewardedAdReady = false;
  }
}