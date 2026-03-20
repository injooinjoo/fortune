import 'package:flutter/material.dart';

import '../../../../core/design_system/design_system.dart';

class CharacterChatSurfaceStyle {
  const CharacterChatSurfaceStyle._();

  static const EdgeInsets bubblePadding = EdgeInsets.symmetric(
    horizontal: DSSpacing.md,
    vertical: DSSpacing.sm + DSSpacing.xxs,
  );

  static const EdgeInsets floatingSurfacePadding = EdgeInsets.all(
    DSSpacing.sm + DSSpacing.xxs,
  );

  static const double messageSideInset = 48;
  static const double avatarGap = DSSpacing.sm + DSSpacing.xxs;
  static const double mediaRadius = 16;
  static const double defaultShadowBlur = 16;
  static const Offset defaultShadowOffset = Offset(0, 6);

  static BorderRadius outgoingBubbleRadius() => const BorderRadius.only(
        topLeft: Radius.circular(DSRadius.xl),
        topRight: Radius.circular(DSRadius.xl),
        bottomLeft: Radius.circular(DSRadius.xl),
        bottomRight: Radius.circular(DSRadius.sm),
      );

  static BorderRadius incomingBubbleRadius({required bool hasLeadingMedia}) =>
      BorderRadius.only(
        topLeft: Radius.circular(hasLeadingMedia ? DSRadius.xl : DSRadius.sm),
        topRight: const Radius.circular(DSRadius.xl),
        bottomLeft: const Radius.circular(DSRadius.xl),
        bottomRight: const Radius.circular(DSRadius.xl),
      );

  static BorderRadius floatingSurfaceRadius({
    double radius = DSRadius.xl,
  }) =>
      BorderRadius.circular(radius);

  static BorderRadius mediaBorderRadius() => BorderRadius.circular(mediaRadius);

  static List<BoxShadow> shadow(
    BuildContext context, {
    double alpha = 0.05,
    double blurRadius = defaultShadowBlur,
    Offset offset = defaultShadowOffset,
  }) {
    return [
      BoxShadow(
        color: context.colors.textPrimary.withValues(alpha: alpha),
        blurRadius: blurRadius,
        offset: offset,
      ),
    ];
  }

  static BoxDecoration bubbleDecoration(
    BuildContext context, {
    required Color backgroundColor,
    required BorderRadius borderRadius,
    required double borderAlpha,
    double shadowAlpha = 0.05,
  }) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: borderRadius,
      border: Border.all(
        color: context.colors.border.withValues(alpha: borderAlpha),
      ),
      boxShadow: shadow(context, alpha: shadowAlpha),
    );
  }

  static BoxDecoration floatingSurfaceDecoration(
    BuildContext context, {
    Color? backgroundColor,
    double borderAlpha = 0.45,
    double shadowAlpha = 0.04,
    double radius = DSRadius.xl,
  }) {
    return bubbleDecoration(
      context,
      backgroundColor: backgroundColor ?? context.colors.surface,
      borderRadius: floatingSurfaceRadius(radius: radius),
      borderAlpha: borderAlpha,
      shadowAlpha: shadowAlpha,
    );
  }
}
