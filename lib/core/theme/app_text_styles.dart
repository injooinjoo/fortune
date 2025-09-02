import 'package:flutter/material.dart';
import 'toss_design_system.dart';

class AppTextStyles {
  // Headline styles
  static const TextStyle headline1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: TossDesignSystem.gray900,
    height: 1.2);

  static const TextStyle headline2 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: TossDesignSystem.gray900,
    height: 1.3);

  static const TextStyle headline3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: TossDesignSystem.gray900,
    height: 1.3);

  static const TextStyle headline4 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: TossDesignSystem.gray900,
    height: 1.4);

  static const TextStyle headline5 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: TossDesignSystem.gray900,
    height: 1.4);

  static const TextStyle headline6 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: TossDesignSystem.gray900,
    height: 1.5);

  // Body styles
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: TossDesignSystem.gray900,
    height: 1.5);

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: TossDesignSystem.gray900,
    height: 1.5);

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: TossDesignSystem.gray600,
    height: 1.5);

  // Label styles
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: TossDesignSystem.gray900,
    height: 1.4);

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: TossDesignSystem.gray900,
    height: 1.4);

  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: TossDesignSystem.gray600,
    height: 1.4);

  // Button styles
  static const TextStyle buttonLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2);

  static const TextStyle buttonMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.2);

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 1.2);

  // Caption styles
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: TossDesignSystem.gray400,
    height: 1.4);

  static const TextStyle overline = TextStyle(
      fontSize: 10,
      fontWeight: FontWeight.w500,
      color: TossDesignSystem.gray400,
      letterSpacing: 1.5,
      height: 1.4);

  // Aliases for backward compatibility
  static const TextStyle body1 = bodyMedium;
  static const TextStyle body2 = bodySmall;
  static const TextStyle heading2 = headline2;
  static const TextStyle heading3 = headline3;
  static const TextStyle headlineLarge = headline1;
  static const TextStyle headlineMedium = headline3;
}
