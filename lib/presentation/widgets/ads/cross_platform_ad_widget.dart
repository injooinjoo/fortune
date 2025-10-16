import 'package:fortune/core/theme/app_spacing.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart' show AdSize;
import 'banner_ad_widget.dart';
import 'adsense_widget.dart';
import '../../../core/config/environment.dart';

/// Cross-platform ad widget that displays AdMob ads on mobile and AdSense ads on web
class CrossPlatformAdWidget extends StatelessWidget {
  final EdgeInsets padding;
  final AdSize mobileAdSize;
  final AdSenseBannerSize webAdSize;
  final Color? backgroundColor;

  const CrossPlatformAdWidget({
    super.key,
    this.padding = AppSpacing.paddingVertical8,
    this.mobileAdSize = AdSize.banner,
    this.webAdSize = AdSenseBannerSize.responsive,
    this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    // Check if ads are enabled
    if (!Environment.enableAds) {
      return const SizedBox.shrink();
    }

    // Return appropriate ad widget based on platform
    if (kIsWeb) {
      return AdSenseBanner(
        size: webAdSize,
        padding: padding);
    } else {
      return BannerAdWidget(
        adSize: mobileAdSize,
        padding: padding,
        backgroundColor: backgroundColor);
    }
  }
}

/// Utility class for common ad placements
class CommonAdPlacements {
  /// Ad placement at the bottom of lists or feeds
  static Widget listBottomAd({
    EdgeInsets? padding}) {
    return CrossPlatformAdWidget(
      padding: padding ?? AppSpacing.paddingVertical16,
      mobileAdSize: AdSize.banner,
      webAdSize: AdSenseBannerSize.responsive);
  }

  /// Ad placement between content sections
  static Widget betweenContentAd({
    EdgeInsets? padding,
    Color? backgroundColor}) {
    return CrossPlatformAdWidget(
      padding: padding ?? EdgeInsets.symmetric(vertical: AppSpacing.spacing6),
      mobileAdSize: AdSize.mediumRectangle,
      webAdSize: AdSenseBannerSize.mediumRectangle,
      backgroundColor: backgroundColor);
  }

  /// Small ad placement for sidebars or compact spaces
  static Widget compactAd({
    EdgeInsets? padding}) {
    return CrossPlatformAdWidget(
      padding: padding ?? AppSpacing.paddingAll8,
      mobileAdSize: AdSize.banner,
      webAdSize: AdSenseBannerSize.banner);
  }

  /// Large ad placement for main content areas
  static Widget largeAd({
    EdgeInsets? padding,
    Color? backgroundColor}) {
    return CrossPlatformAdWidget(
      padding: padding ?? EdgeInsets.symmetric(vertical: AppSpacing.spacing8),
      mobileAdSize: AdSize.largeBanner,
      webAdSize: AdSenseBannerSize.largeRectangle,
      backgroundColor: backgroundColor);
  }
}