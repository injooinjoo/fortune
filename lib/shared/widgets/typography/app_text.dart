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

  const AppDisplayText.medium(
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

  const AppDisplayText.small(
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
  const AppHeadlineText.large(
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

  const AppHeadlineText.medium(
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

  const AppHeadlineText.small(
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
  const AppTitleText.large(
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

  const AppTitleText.medium(
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

  const AppTitleText.small(
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
  const AppBodyText.large(
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

  const AppBodyText.medium(
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

  const AppBodyText.small(
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
  const AppLabelText.large(
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

  const AppLabelText.medium(
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

  const AppLabelText.small(
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
  const AppCaptionText.large(
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

  const AppCaptionText.medium(
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

  const AppCaptionText.small(
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
  const AppButtonText(
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
  const AppNumberText.large(
    super.text, {
    super.key,
    super.textAlign,
    super.color,
    super.selectable,
  }) : super(
          style: AppTypography.numberLarge,
        );

  const AppNumberText.medium(
    super.text, {
    super.key,
    super.textAlign,
    super.color,
    super.selectable,
  }) : super(
          style: AppTypography.numberMedium,
        );

  const AppNumberText.small(
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
  const AppOverlineText(
    super.text, {
    super.key,
    super.textAlign,
    super.color,
    super.selectable,
  }) : super(
          style: AppTypography.overline,
        );
}
