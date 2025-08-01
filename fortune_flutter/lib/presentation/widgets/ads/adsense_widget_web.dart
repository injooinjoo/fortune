import 'package:fortune/core/theme/app_spacing.dart';
import 'dart:html' as html;
import 'dart:ui_web' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../core/config/environment.dart';
import '../../../core/utils/logger.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_animations.dart';

/// Widget to display Google AdSense ads on Flutter Web
class AdSenseWidget extends StatefulWidget {
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
  }));

  @override
  State<AdSenseWidget> createState() => _AdSenseWidgetState();
}

class _AdSenseWidgetState extends State<AdSenseWidget> {
  late String _viewId;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb && Environment.enableAds) {
      _createAdSenseAd();
    }
  }

  void _createAdSenseAd() {
    try {
      // Generate unique view ID
      _viewId = 'adsense-${DateTime.now().millisecondsSinceEpoch}';
      
      // Create the AdSense container
      final adContainer = html.DivElement()
        ..id = _viewId
        ..style.width = widget.width?.toString() ?? '100%'
        ..style.height = widget.height?.toString() ?? 'auto'
        ..style.margin = '0 auto'
        ..style.textAlign = 'center';

      // Create the AdSense ins element
      final ins = html.Element.tag('ins')
        ..className = 'adsbygoogle'
        ..style.display = 'block'
        ..setAttribute('data-ad-client', Environment.adsenseClientId)
        ..setAttribute('data-ad-slot', widget.adSlot);

      // Set ad format
      if (widget.adFormat != null) {
        ins.setAttribute('data-ad-format', widget.adFormat!);
      }

      // Set responsive options
      if (widget.fullWidthResponsive) {
        ins.setAttribute('data-full-width-responsive', 'true');
      }

      // Set dimensions if provided
      if (widget.width != null) {
        ins.style.width = '${widget.width}px';
      }
      if (widget.height != null) {
        ins.style.height = '${widget.height}px';
      }

      adContainer.append(ins);

      // Register the HTML element view
      ui.platformViewRegistry.registerViewFactory(
        _viewId,
        (int viewId) => adContainer,
      );

      // Push the ad after a delay
      Future.delayed(AppAnimations.durationMicro, () {
        try {
          final script = html.ScriptElement()
            ..text = '(adsbygoogle = window.adsbygoogle || []).push({});';
          html.document.body?.append(script);
          script.remove();
          setState(() {
            _isAdLoaded = true;
          });
          Logger.info('AdSense ad loaded successfully');
        } catch (e) {
          Logger.error('Failed to push AdSense ad', e);
        }
      });
    } catch (e) {
      Logger.error('Failed to create AdSense ad', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!kIsWeb || !Environment.enableAds) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: widget.padding,
      child: SizedBox(
        width: widget.width ?? double.infinity,
        height: widget.height ?? 100, // Default height for auto ads
        child: HtmlElementView(
          viewType: _viewId,
        ),
      ),
    );
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
  }));

  @override
  Widget build(BuildContext context) {
    return AdSenseWidget(
      adSlot: Environment.adsenseSlotId,
      adFormat: size == AdSenseBannerSize.responsive ? 'auto' : 'rectangle',
      width: size.width,
      height: size.height,
      fullWidthResponsive: size == AdSenseBannerSize.responsive,
      padding: padding,
    );
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