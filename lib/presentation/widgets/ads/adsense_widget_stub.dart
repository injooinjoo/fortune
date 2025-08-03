import 'package:fortune/core/theme/app_spacing.dart';
import 'package:flutter/material.dart';

/// Stub implementation for non-web platforms
class AdSenseWidget extends StatelessWidget {
  final String adSlot;
  final String? adFormat;
  final double? width;
  final double? height;
  final bool fullWidthResponsive;
  final EdgeInsets padding;

  const AdSenseWidget({
    super.key,
    required this.adSlot,
    this.adFormat = 'auto',
    this.width,
    this.height,
    this.fullWidthResponsive = true,
    this.padding = AppSpacing.paddingVertical8,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// Different AdSense ad formats
class AdSenseFormats {
  static const String auto = 'auto';
  static const String rectangle = 'rectangle';
  static const String horizontal = 'horizontal';
  static const String vertical = 'vertical';
  static const String fluid = 'fluid';
  static const String inArticle = 'in-article';
  static const String inFeed = 'in-feed';
}

/// AdSense banner widget with predefined sizes
class AdSenseBanner extends StatelessWidget {
  final AdSenseBannerSize size;
  final EdgeInsets padding;

  const AdSenseBanner({
    super.key,
    this.size = AdSenseBannerSize.responsive,
    this.padding = AppSpacing.paddingVertical8,
  });

  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

/// Predefined AdSense banner sizes
enum AdSenseBannerSize {
  responsive(null, null),
  banner(320, 50),
  largeBanner(320, 100),
  mediumRectangle(300, 250),
  fullBanner(468, 60),
  leaderboard(728, 90),
  largeLeaderboard(970, 90),
  skyscraper(120, 600),
  wideSkyscraper(160, 600),
  largeRectangle(336, 280),
  square(250, 250),
  smallSquare(200, 200);

  final double? width;
  final double? height;

  const AdSenseBannerSize(this.width, this.height);
}