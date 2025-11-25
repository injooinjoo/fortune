import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:universal_io/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../core/config/environment.dart';
import '../core/utils/logger.dart';

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
      Logger.info('🎯 [AdMob] Starting AdMob SDK initialization...');
      Logger.info('🎯 [AdMob] ENABLE_ADS flag: ${Environment.enableAds}');
      Logger.info('🎯 [AdMob] AdMob App ID: ${Environment.admobAppId}');
      Logger.info('🎯 [AdMob] Banner Ad Unit ID: ${Environment.admobBannerAdUnitId}');

      // Check if ads are enabled
      if (!Environment.enableAds) {
        Logger.warning('⚠️ [AdMob] Ads are disabled via feature flag (ENABLE_ADS=false)');
        return;
      }

      // Check if AdMob App ID is configured
      if (Environment.admobAppId.isEmpty) {
        Logger.error('❌ [AdMob] AdMob App ID is not configured in .env file');
        return;
      }

      // Initialize MobileAds SDK with timeout - don't block the app
      try {
        Logger.info('🎯 [AdMob] Initializing MobileAds SDK...');
        final initFuture = MobileAds.instance.initialize();
        final status = await initFuture.timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            Logger.warning('⚠️ [AdMob] SDK initialization timed out after 5 seconds - continuing without ads');
            return InitializationStatus({});
          },
        );
        Logger.info('✅ [AdMob] MobileAds SDK initialized successfully: $status');
      } catch (e) {
        Logger.error('❌ [AdMob] SDK initialization failed: $e - continuing without ads', e);
        // Don't rethrow - let the app continue
      }

      // Configure test devices for development
      if (kDebugMode) {
        try {
          Logger.info('🎯 [AdMob] Debug mode: Configuring test device settings...');
          final testDeviceIds = <String>[];
          if (Platform.isAndroid) {
            // Add Android test device IDs here if needed
            // testDeviceIds.add('YOUR_ANDROID_TEST_DEVICE_ID');
          } else if (Platform.isIOS) {
            // Add iOS test device IDs here if needed
            // testDeviceIds.add('YOUR_IOS_TEST_DEVICE_ID');
          }

          final config = RequestConfiguration(
            testDeviceIds: testDeviceIds,
          );

          await MobileAds.instance.updateRequestConfiguration(config).timeout(
            const Duration(seconds: 1),
            onTimeout: () {
              Logger.warning('⚠️ [AdMob] Test device configuration timed out');
            },
          );
          Logger.info('✅ [AdMob] Test device configuration complete');
        } catch (e) {
          Logger.warning('⚠️ [AdMob] Failed to configure test devices: $e');
        }
      }

      _isInitialized = true;
      Logger.info('✅ [AdMob] AdService initialized successfully (isInitialized: $_isInitialized)');

      // Don't preload ads automatically - this can cause delays on real devices
      // Ads will be loaded on-demand when needed
    } catch (e) {
      Logger.error('❌ [AdMob] AdService initialization failed (continuing without ads): $e', e);
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

  /// Load a banner ad
  Future<void> loadBannerAd({
    AdSize adSize = AdSize.banner,
    void Function(Ad)? onAdLoaded,
    void Function(Ad, LoadAdError)? onAdFailedToLoad}) async {
    if (!_isInitialized) {
      Logger.warning('⚠️ [AdMob] SDK not initialized, cannot load banner ad');
      return;
    }

    final adUnitId = _getAdUnitId('banner');
    Logger.info('🎯 [AdMob] Loading banner ad with unit ID: $adUnitId');

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _isBannerAdReady = true;
          Logger.info('✅ [AdMob] Banner ad loaded successfully');
          onAdLoaded?.call(ad);
        },
        onAdFailedToLoad: (ad, error) {
          _isBannerAdReady = false;
          ad.dispose();
          Logger.error('❌ [AdMob] Banner ad failed to load: ${error.message} (code: ${error.code})', error);
          onAdFailedToLoad?.call(ad, error);
        },
        onAdOpened: (ad) => Logger.info('📱 [AdMob] Banner ad opened'),
        onAdClosed: (ad) => Logger.info('📱 [AdMob] Banner ad closed'),
        onAdImpression: (ad) => Logger.info('👁️ [AdMob] Banner ad impression'),
        onAdClicked: (ad) => Logger.info('👆 [AdMob] Banner ad clicked')));

    await _bannerAd!.load();
  }

  /// Load an interstitial ad
  Future<void> loadInterstitialAd({
    void Function(InterstitialAd)? onAdLoaded,
    void Function(LoadAdError)? onAdFailedToLoad}) async {
    if (!_isInitialized) {
      Logger.warning('⚠️ [AdMob] SDK not initialized, cannot load interstitial ad');
      return;
    }

    final adUnitId = _getAdUnitId('interstitial');
    Logger.info('🎯 [AdMob] Loading interstitial ad with unit ID: $adUnitId');

    await InterstitialAd.load(
      adUnitId: adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          Logger.info('✅ [AdMob] Interstitial ad loaded successfully');
          onAdLoaded?.call(ad);

          // Set full screen content callback
          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              _isInterstitialAdReady = false;
              Logger.info('📱 [AdMob] Interstitial ad dismissed');
              // Load next interstitial ad
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              ad.dispose();
              _isInterstitialAdReady = false;
              Logger.error('❌ [AdMob] Interstitial ad failed to show: ${error.message} (code: ${error.code})', error);
            },
            onAdShowedFullScreenContent: (ad) {
              Logger.info('📱 [AdMob] Interstitial ad showed');
            });
        },
        onAdFailedToLoad: (error) {
          _isInterstitialAdReady = false;
          Logger.error('❌ [AdMob] Interstitial ad failed to load: ${error.message} (code: ${error.code})', error);
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
    Future<void> Function()? onAdCompleted,
    Future<void> Function()? onAdFailed,
  }) async {
    if (_isInterstitialAdReady && _interstitialAd != null) {
      // Set up callback for when ad is completed
      _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) async {
          ad.dispose();
          _isInterstitialAdReady = false;
          Logger.info('Interstitial ad dismissed');
          // Execute callback when ad is completed
          try {
            await onAdCompleted?.call();
          } catch (e, stackTrace) {
            Logger.error('[AdService] Error in onAdCompleted callback', e, stackTrace);
          }
          // Load next interstitial ad
          loadInterstitialAd();
        },
        onAdFailedToShowFullScreenContent: (ad, error) async {
          ad.dispose();
          _isInterstitialAdReady = false;
          Logger.warning('[AdService] 전면 광고 표시 실패 (콜백 실행): $error');
          // Execute failure callback
          try {
            await onAdFailed?.call();
          } catch (e, stackTrace) {
            Logger.error('[AdService] Error in onAdFailed callback', e, stackTrace);
          }
        },
        onAdShowedFullScreenContent: (ad) {
          Logger.info('Interstitial ad showed');
        },
      );

      await _interstitialAd!.show();
    } else {
      // ✅ 광고 준비 안 됨 - onAdFailed 콜백 실행
      Logger.warning('⚠️ Interstitial ad not ready - executing onAdFailed callback');
      try {
        await onAdFailed?.call();
      } catch (e, stackTrace) {
        Logger.error('[AdService] Error in onAdFailed callback (ad not ready)', e, stackTrace);
      }
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
              Logger.warning('[AdService] 리워드 광고 표시 실패 (무시): $error');
            },
            onAdShowedFullScreenContent: (ad) {
              Logger.info('Rewarded ad showed');
            });
        },
        onAdFailedToLoad: (error) {
          _isRewardedAdReady = false;
          Logger.warning('[AdService] 리워드 광고 로드 실패 (광고 없이 진행): $error');
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
              textColor: TossDesignSystem.gray900.withValues(alpha: 0.87),
              style: NativeTemplateFontStyle.normal,
              size: 16.0),
            secondaryTextStyle: NativeTemplateTextStyle(
              textColor: TossDesignSystem.gray900.withValues(alpha: 0.54),
              style: NativeTemplateFontStyle.normal,
              size: 14.0),
            tertiaryTextStyle: NativeTemplateTextStyle(
              textColor: TossDesignSystem.gray900.withValues(alpha: 0.54),
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