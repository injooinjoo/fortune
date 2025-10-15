import 'package:flutter/material.dart';
import 'package:fortune/core/theme/toss_design_system.dart';
import 'package:fortune/core/theme/app_typography.dart';

/// Base text widget with Toss Product Sans typography
class AppText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final Color? color;
  final double? fontSize;
  final FontWeight? fontWeight;
  final double? letterSpacing;
  final double? height;
  final bool selectable;

  const AppText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.color,
    this.fontSize,
    this.fontWeight,
    this.letterSpacing,
    this.height,
    this.selectable = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final defaultColor = isDarkMode ? TossDesignSystem.grayDark900 : TossDesignSystem.gray900;

    final textStyle = (style ?? AppTypography.bodyMedium).copyWith(
      color: color ?? style?.color ?? defaultColor,
      fontSize: fontSize ?? style?.fontSize,
      fontWeight: fontWeight ?? style?.fontWeight,
      letterSpacing: letterSpacing ?? style?.letterSpacing,
      height: height ?? style?.height,
    );

    if (selectable) {
      return SelectableText(
        text,
        style: textStyle,
        textAlign: textAlign,
        maxLines: maxLines,
      );
    }

    return Text(
      text,
      style: textStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}

/// Display text variants
class AppDisplayText extends AppText {
  const AppDisplayText.large(
    String text, {
    super.key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
    bool selectable = false,
  }) : super(
          text,
          style: AppTypography.displayLarge,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          color: color,
          selectable: selectable,
        );

  const AppDisplayText.medium(
    String text, {
    super.key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
    bool selectable = false,
  }) : super(
          text,
          style: AppTypography.displayMedium,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          color: color,
          selectable: selectable,
        );

  const AppDisplayText.small(
    String text, {
    super.key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
    bool selectable = false,
  }) : super(
          text,
          style: AppTypography.displaySmall,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          color: color,
          selectable: selectable,
        );
}

/// Headline text variants
class AppHeadlineText extends AppText {
  const AppHeadlineText.large(
    String text, {
    super.key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
    bool selectable = false,
  }) : super(
          text,
          style: AppTypography.headlineLarge,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          color: color,
          selectable: selectable,
        );

  const AppHeadlineText.medium(
    String text, {
    super.key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
    bool selectable = false,
  }) : super(
          text,
          style: AppTypography.headlineMedium,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          color: color,
          selectable: selectable,
        );

  const AppHeadlineText.small(
    String text, {
    super.key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
    bool selectable = false,
  }) : super(
          text,
          style: AppTypography.headlineSmall,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          color: color,
          selectable: selectable,
        );
}

/// Title text variants
class AppTitleText extends AppText {
  const AppTitleText.large(
    String text, {
    super.key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
    bool selectable = false,
  }) : super(
          text,
          style: AppTypography.titleLarge,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          color: color,
          selectable: selectable,
        );

  const AppTitleText.medium(
    String text, {
    super.key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
    bool selectable = false,
  }) : super(
          text,
          style: AppTypography.titleMedium,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          color: color,
          selectable: selectable,
        );

  const AppTitleText.small(
    String text, {
    super.key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
    bool selectable = false,
  }) : super(
          text,
          style: AppTypography.titleSmall,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          color: color,
          selectable: selectable,
        );
}

/// Body text variants
class AppBodyText extends AppText {
  const AppBodyText.large(
    String text, {
    super.key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
    bool selectable = false,
  }) : super(
          text,
          style: AppTypography.bodyLarge,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          color: color,
          selectable: selectable,
        );

  const AppBodyText.medium(
    String text, {
    super.key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
    bool selectable = false,
  }) : super(
          text,
          style: AppTypography.bodyMedium,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          color: color,
          selectable: selectable,
        );

  const AppBodyText.small(
    String text, {
    super.key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
    bool selectable = false,
  }) : super(
          text,
          style: AppTypography.bodySmall,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          color: color,
          selectable: selectable,
        );
}

/// Label text variants
class AppLabelText extends AppText {
  const AppLabelText.large(
    String text, {
    super.key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
    bool selectable = false,
  }) : super(
          text,
          style: AppTypography.labelLarge,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          color: color,
          selectable: selectable,
        );

  const AppLabelText.medium(
    String text, {
    super.key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
    bool selectable = false,
  }) : super(
          text,
          style: AppTypography.labelMedium,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          color: color,
          selectable: selectable,
        );

  const AppLabelText.small(
    String text, {
    super.key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
    bool selectable = false,
  }) : super(
          text,
          style: AppTypography.labelSmall,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          color: color,
          selectable: selectable,
        );
}

/// Caption text variants
class AppCaptionText extends AppText {
  const AppCaptionText.large(
    String text, {
    super.key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
    bool selectable = false,
  }) : super(
          text,
          style: AppTypography.captionLarge,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          color: color,
          selectable: selectable,
        );

  const AppCaptionText.medium(
    String text, {
    super.key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
    bool selectable = false,
  }) : super(
          text,
          style: AppTypography.captionMedium,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          color: color,
          selectable: selectable,
        );

  const AppCaptionText.small(
    String text, {
    super.key,
    TextAlign? textAlign,
    int? maxLines,
    TextOverflow? overflow,
    Color? color,
    bool selectable = false,
  }) : super(
          text,
          style: AppTypography.captionSmall,
          textAlign: textAlign,
          maxLines: maxLines,
          overflow: overflow,
          color: color,
          selectable: selectable,
        );
}

/// Button text
class AppButtonText extends AppText {
  const AppButtonText(
    String text, {
    super.key,
    TextAlign? textAlign,
    Color? color,
    bool small = false,
  }) : super(
          text,
          style: small ? AppTypography.buttonSmall : AppTypography.button,
          textAlign: textAlign,
          color: color,
        );
}

/// Number text variants
class AppNumberText extends AppText {
  const AppNumberText.large(
    String text, {
    super.key,
    TextAlign? textAlign,
    Color? color,
    bool selectable = false,
  }) : super(
          text,
          style: AppTypography.numberLarge,
          textAlign: textAlign,
          color: color,
          selectable: selectable,
        );

  const AppNumberText.medium(
    String text, {
    super.key,
    TextAlign? textAlign,
    Color? color,
    bool selectable = false,
  }) : super(
          text,
          style: AppTypography.numberMedium,
          textAlign: textAlign,
          color: color,
          selectable: selectable,
        );

  const AppNumberText.small(
    String text, {
    super.key,
    TextAlign? textAlign,
    Color? color,
    bool selectable = false,
  }) : super(
          text,
          style: AppTypography.numberSmall,
          textAlign: textAlign,
          color: color,
          selectable: selectable,
        );
}

/// Overline text
class AppOverlineText extends AppText {
  const AppOverlineText(
    String text, {
    super.key,
    TextAlign? textAlign,
    Color? color,
    bool selectable = false,
  }) : super(
          text,
          style: AppTypography.overline,
          textAlign: textAlign,
          color: color,
          selectable: selectable,
        );
}
