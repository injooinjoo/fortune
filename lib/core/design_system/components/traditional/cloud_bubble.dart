import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../design_system.dart';
import '../../tokens/ds_fortune_colors.dart';

/// Traditional vintage banner-style chat bubble widget
///
/// Creates chat bubbles with:
/// - Double border frame
/// - Optional corner decoration assets (SVG/PNG)
///
/// Usage:
/// ```dart
/// CloudBubble(
///   type: CloudBubbleType.ai,
///   cornerAsset: 'assets/images/chat/corner_motif.svg',
///   child: Text('안녕하세요!'),
/// )
/// ```
class CloudBubble extends StatelessWidget {
  /// The content inside the bubble
  final Widget child;

  /// Type of bubble (ai or user)
  final CloudBubbleType type;

  /// Custom padding inside the bubble
  final EdgeInsets? padding;

  /// Whether to show ink bleed effect (subtle glow)
  final bool showInkBleed;

  /// Optional custom background color
  final Color? backgroundColor;

  /// Optional custom border color
  final Color? borderColor;

  /// Optional corner decoration asset path (SVG or PNG)
  /// If provided, displays in all 4 corners with appropriate rotation
  final String? cornerAsset;

  /// Size of corner decoration (default: 20)
  final double cornerSize;

  const CloudBubble({
    super.key,
    required this.child,
    required this.type,
    this.padding,
    this.showInkBleed = false,
    this.backgroundColor,
    this.borderColor,
    this.cornerAsset,
    this.cornerSize = 20,
  });

  /// Factory for AI message bubbles
  factory CloudBubble.ai({
    Key? key,
    required Widget child,
    EdgeInsets? padding,
    bool showInkBleed = true,
    String? cornerAsset,
    double cornerSize = 20,
  }) {
    return CloudBubble(
      key: key,
      type: CloudBubbleType.ai,
      padding: padding,
      showInkBleed: showInkBleed,
      cornerAsset: cornerAsset,
      cornerSize: cornerSize,
      child: child,
    );
  }

  /// Factory for user message bubbles
  factory CloudBubble.user({
    Key? key,
    required Widget child,
    EdgeInsets? padding,
    String? cornerAsset,
    double cornerSize = 20,
  }) {
    return CloudBubble(
      key: key,
      type: CloudBubbleType.user,
      padding: padding,
      showInkBleed: false,
      cornerAsset: cornerAsset,
      cornerSize: cornerSize,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final effectivePadding = padding ??
        EdgeInsets.symmetric(
          horizontal: DSSpacing.md,
          vertical: type == CloudBubbleType.ai ? DSSpacing.md : DSSpacing.sm,
        );

    // Base bubble with double border
    Widget bubble = CustomPaint(
      painter: CloudBubblePainter(
        isDark: isDark,
        bubbleType: type,
        backgroundColor: backgroundColor,
        borderColor: borderColor,
        borderWidth: 1.0,
        showInkBleed: showInkBleed,
      ),
      child: Padding(
        padding: effectivePadding,
        child: child,
      ),
    );

    // Add corner decorations if asset provided
    if (cornerAsset != null) {
      final brdColor = borderColor ?? DSFortuneColors.getBubbleBorder(isDark);

      bubble = Stack(
        clipBehavior: Clip.none,
        children: [
          bubble,
          // Top-left corner
          Positioned(
            left: 4,
            top: 4,
            child: _buildCornerImage(cornerAsset!, brdColor, 0),
          ),
          // Top-right corner
          Positioned(
            right: 4,
            top: 4,
            child: _buildCornerImage(cornerAsset!, brdColor, 90),
          ),
          // Bottom-right corner
          Positioned(
            right: 4,
            bottom: 4,
            child: _buildCornerImage(cornerAsset!, brdColor, 180),
          ),
          // Bottom-left corner
          Positioned(
            left: 4,
            bottom: 4,
            child: _buildCornerImage(cornerAsset!, brdColor, 270),
          ),
        ],
      );
    }

    return bubble;
  }

  Widget _buildCornerImage(String asset, Color color, double rotation) {
    final isSvg = asset.toLowerCase().endsWith('.svg');

    Widget image;
    if (isSvg) {
      image = SvgPicture.asset(
        asset,
        width: cornerSize,
        height: cornerSize,
        colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
      );
    } else {
      image = Image.asset(
        asset,
        width: cornerSize,
        height: cornerSize,
        color: color,
      );
    }

    if (rotation != 0) {
      image = Transform.rotate(
        angle: rotation * 3.14159 / 180,
        child: image,
      );
    }

    return image;
  }
}
