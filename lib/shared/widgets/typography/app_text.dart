import 'package:flutter/material.dart';
import 'package:fortune/core/theme/fortune_design_system.dart';
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
  AppDisplayText.large(
    super.text, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    super.color,
    super.selectable,
  }) : super(
          style: AppTypography.displayLarge,
        );

  AppDisplayText.medium(
    super.text, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    super.color,
    super.selectable,
  }) : super(
          style: AppTypography.displayMedium,
        );

  AppDisplayText.small(
    super.text, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    super.color,
    super.selectable,
  }) : super(
          style: AppTypography.displaySmall,
        );
}

/// Headline text variants
class AppHeadlineText extends AppText {
  AppHeadlineText.large(
    super.text, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    super.color,
    super.selectable,
  }) : super(
          style: AppTypography.headlineLarge,
        );

  AppHeadlineText.medium(
    super.text, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    super.color,
    super.selectable,
  }) : super(
          style: AppTypography.headlineMedium,
        );

  AppHeadlineText.small(
    super.text, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    super.color,
    super.selectable,
  }) : super(
          style: AppTypography.headlineSmall,
        );
}

/// Title text variants
class AppTitleText extends AppText {
  AppTitleText.large(
    super.text, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    super.color,
    super.selectable,
  }) : super(
          style: AppTypography.titleLarge,
        );

  AppTitleText.medium(
    super.text, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    super.color,
    super.selectable,
  }) : super(
          style: AppTypography.titleMedium,
        );

  AppTitleText.small(
    super.text, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    super.color,
    super.selectable,
  }) : super(
          style: AppTypography.titleSmall,
        );
}

/// Body text variants
class AppBodyText extends AppText {
  AppBodyText.large(
    super.text, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    super.color,
    super.selectable,
  }) : super(
          style: AppTypography.bodyLarge,
        );

  AppBodyText.medium(
    super.text, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    super.color,
    super.selectable,
  }) : super(
          style: AppTypography.bodyMedium,
        );

  AppBodyText.small(
    super.text, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    super.color,
    super.selectable,
  }) : super(
          style: AppTypography.bodySmall,
        );
}

/// Label text variants
class AppLabelText extends AppText {
  AppLabelText.large(
    super.text, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    super.color,
    super.selectable,
  }) : super(
          style: AppTypography.labelLarge,
        );

  AppLabelText.medium(
    super.text, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    super.color,
    super.selectable,
  }) : super(
          style: AppTypography.labelMedium,
        );

  AppLabelText.small(
    super.text, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    super.color,
    super.selectable,
  }) : super(
          style: AppTypography.labelSmall,
        );
}

/// Caption text variants
class AppCaptionText extends AppText {
  AppCaptionText.large(
    super.text, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    super.color,
    super.selectable,
  }) : super(
          style: AppTypography.captionLarge,
        );

  AppCaptionText.medium(
    super.text, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    super.color,
    super.selectable,
  }) : super(
          style: AppTypography.captionMedium,
        );

  AppCaptionText.small(
    super.text, {
    super.key,
    super.textAlign,
    super.maxLines,
    super.overflow,
    super.color,
    super.selectable,
  }) : super(
          style: AppTypography.captionSmall,
        );
}

/// Button text
class AppButtonText extends AppText {
  AppButtonText(
    super.text, {
    super.key,
    super.textAlign,
    super.color,
    bool small = false,
  }) : super(
          style: small ? AppTypography.buttonSmall : AppTypography.button,
        );
}

/// Number text variants
class AppNumberText extends AppText {
  AppNumberText.large(
    super.text, {
    super.key,
    super.textAlign,
    super.color,
    super.selectable,
  }) : super(
          style: AppTypography.numberLarge,
        );

  AppNumberText.medium(
    super.text, {
    super.key,
    super.textAlign,
    super.color,
    super.selectable,
  }) : super(
          style: AppTypography.numberMedium,
        );

  AppNumberText.small(
    super.text, {
    super.key,
    super.textAlign,
    super.color,
    super.selectable,
  }) : super(
          style: AppTypography.numberSmall,
        );
}

/// Overline text
class AppOverlineText extends AppText {
  AppOverlineText(
    super.text, {
    super.key,
    super.textAlign,
    super.color,
    super.selectable,
  }) : super(
          style: AppTypography.overline,
        );
}
