import 'package:flutter/material.dart';
import '../design_system/design_system.dart';

/// 다크모드 관리를 위한 유틸리티 클래스
/// 전체 앱에서 통일성 있는 다크모드 처리를 제공합니다
class DarkModeHelper {
  /// 현재 테마가 다크모드인지 확인
  static bool isDark(BuildContext context) {
    return context.isDark;
  }

  /// 다크모드 상태에 따라 적절한 색상을 반환
  static Color getColor({
    required BuildContext context,
    required Color light,
    required Color dark,
  }) {
    return isDark(context) ? dark : light;
  }

  /// 다크모드 상태에 따라 적절한 텍스트 색상을 반환
  static Color getTextColor({
    required BuildContext context,
    Color? lightColor,
    Color? darkColor,
  }) {
    if (lightColor != null && darkColor != null) {
      return isDark(context) ? darkColor : lightColor;
    }

    // 기본 텍스트 색상
    return context.colors.textPrimary;
  }

  /// 다크모드 상태에 따라 적절한 배경 색상을 반환
  static Color getBackgroundColor({
    required BuildContext context,
    Color? lightColor,
    Color? darkColor,
  }) {
    if (lightColor != null && darkColor != null) {
      return isDark(context) ? darkColor : lightColor;
    }

    // 기본 배경 색상
    return context.colors.background;
  }
}
