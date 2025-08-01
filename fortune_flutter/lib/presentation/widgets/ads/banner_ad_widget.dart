import 'package:fortune/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../../providers/ad_provider.dart';
import '../../../services/ad_service.dart';
import '../../../core/utils/logger.dart';
import '../../../core/config/environment.dart';
import 'package:fortune/core/theme/app_dimensions.dart';

/// Widget to display banner ads
class BannerAdWidget extends ConsumerStatefulWidget {
  final AdSize adSize;
  final EdgeInsets padding;
  final Color? backgroundColor;

  const BannerAdWidget({
    super.key,
    this.adSize = AdSize.banner,
    this.padding = AppSpacing.paddingVertical8,
    this.backgroundColor,
  }));

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadBannerAd();
  }

  void _loadBannerAd() {
    final adService = ref.read(adServiceProvider);
    
    if (!adService.isInitialized) {
      Logger.warning('AdMob not initialized, skipping banner ad load');
      return;
    }

    // Use test ad unit ID in debug mode
    final adUnitId = kDebugMode 
        ? 'ca-app-pub-3940256099942544/6300978111'  // Test banner ad unit ID
        : Environment.admobBannerAdUnitId;
    
    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: widget.adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
          // Record impression for analytics
          ref.read(adRevenueProvider.notifier).recordBannerImpression();
        },
        onAdFailedToLoad: (ad, error) {
          Logger.error('Banner ad failed to load', error);
          ad.dispose();
          setState(() {
            _isAdLoaded = false;
          });
        },
        onAdOpened: (ad) => Logger.info('Banner ad opened'),
        onAdClosed: (ad) => Logger.info('Banner ad closed'),
        onAdImpression: (ad) => Logger.info('Banner ad impression'),
        onAdClicked: (ad) => Logger.info('Banner ad clicked'),
      ),
    );

    _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isAdLoaded || _bannerAd == null) {
      // Return empty container while loading
      return Container(
        height: widget.adSize.height.toDouble(),
        padding: widget.padding,
      );
    }

    return Container(
      color: widget.backgroundColor,
      padding: widget.padding,
      child: SizedBox(
        width: widget.adSize.width.toDouble(),
        height: widget.adSize.height.toDouble(),
        child: AdWidget(
          ad: _bannerAd!,
        ),
      ),
    );
  }
}