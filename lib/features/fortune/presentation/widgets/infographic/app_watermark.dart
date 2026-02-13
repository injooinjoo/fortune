import 'package:flutter/material.dart';
import 'package:fortune/core/design_system/tokens/ds_spacing.dart';
import 'package:fortune/core/design_system/tokens/ds_radius.dart';
import 'package:fortune/core/design_system/theme/ds_extensions.dart';

/// 앱 워터마크 위젯
///
/// 인포그래픽 공유 시 앱 브랜딩을 위한 워터마크입니다.
/// 다양한 스타일과 위치 옵션을 지원합니다.
class AppWatermark extends StatelessWidget {
  const AppWatermark({
    super.key,
    this.style = WatermarkStyle.badge,
    this.size = WatermarkSize.small,
    this.opacity = 1.0,
    this.showIcon = true,
    this.showText = true,
    this.customText,
  });

  /// 워터마크 스타일
  final WatermarkStyle style;

  /// 워터마크 크기
  final WatermarkSize size;

  /// 투명도 (0.0 ~ 1.0)
  final double opacity;

  /// 아이콘 표시 여부
  final bool showIcon;

  /// 텍스트 표시 여부
  final bool showText;

  /// 커스텀 텍스트 (기본: "Fortune")
  final String? customText;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: opacity,
      child: switch (style) {
        WatermarkStyle.badge => _buildBadge(context),
        WatermarkStyle.minimal => _buildMinimal(context),
        WatermarkStyle.text => _buildText(context),
        WatermarkStyle.icon => _buildIcon(context),
        WatermarkStyle.branded => _buildBranded(context),
      },
    );
  }

  Widget _buildBadge(BuildContext context) {
    final (iconSize, fontSize, padding) = _getSizeParams();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: padding * 0.5,
      ),
      decoration: BoxDecoration(
        color: context.colors.textPrimary.withValues(alpha:0.1),
        borderRadius: DSRadius.smBorder,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              Icons.auto_awesome,
              size: iconSize,
              color: context.colors.textSecondary,
            ),
            if (showText) SizedBox(width: padding * 0.4),
          ],
          if (showText)
            Text(
              customText ?? 'Fortune',
              style: context.typography.labelSmall.copyWith(
                color: context.colors.textSecondary,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMinimal(BuildContext context) {
    final (iconSize, fontSize, _) = _getSizeParams();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showIcon) ...[
          Icon(
            Icons.auto_awesome,
            size: iconSize,
            color: context.colors.textTertiary,
          ),
          if (showText) const SizedBox(width: 4),
        ],
        if (showText)
          Text(
            customText ?? 'Fortune',
            style: context.typography.labelSmall.copyWith(
              color: context.colors.textTertiary,
              fontSize: fontSize,
              fontWeight: FontWeight.w400,
            ),
          ),
      ],
    );
  }

  Widget _buildText(BuildContext context) {
    final (_, fontSize, _) = _getSizeParams();

    return Text(
      customText ?? 'Fortune',
      style: context.typography.labelSmall.copyWith(
        color: context.colors.textSecondary,
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildIcon(BuildContext context) {
    final (iconSize, _, _) = _getSizeParams();

    return Icon(
      Icons.auto_awesome,
      size: iconSize,
      color: context.colors.textSecondary,
    );
  }

  Widget _buildBranded(BuildContext context) {
    final (iconSize, fontSize, padding) = _getSizeParams();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: padding * 1.2,
        vertical: padding * 0.6,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            context.colors.accent.withValues(alpha:0.8),
            context.colors.accentSecondary.withValues(alpha:0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: context.colors.accent.withValues(alpha:0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              Icons.auto_awesome,
              size: iconSize,
              color: Colors.white,
            ),
            if (showText) SizedBox(width: padding * 0.4),
          ],
          if (showText)
            Text(
              customText ?? 'Fortune',
              style: context.typography.labelSmall.copyWith(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w600,
              ),
            ),
        ],
      ),
    );
  }

  (double iconSize, double fontSize, double padding) _getSizeParams() {
    return switch (size) {
      WatermarkSize.tiny => (10.0, 8.0, DSSpacing.xs),
      WatermarkSize.small => (12.0, 10.0, DSSpacing.sm),
      WatermarkSize.medium => (16.0, 12.0, DSSpacing.sm),
      WatermarkSize.large => (20.0, 14.0, DSSpacing.md),
    };
  }
}

/// 워터마크 스타일
enum WatermarkStyle {
  /// 배지 스타일 (배경 있음)
  badge,

  /// 미니멀 스타일 (배경 없음)
  minimal,

  /// 텍스트만
  text,

  /// 아이콘만
  icon,

  /// 브랜드 스타일 (그라데이션 배경)
  branded,
}

/// 워터마크 크기
enum WatermarkSize {
  tiny,
  small,
  medium,
  large,
}

/// 위치 지정 워터마크 (Positioned와 함께 사용)
class PositionedWatermark extends StatelessWidget {
  const PositionedWatermark({
    super.key,
    this.position = WatermarkPosition.bottomRight,
    this.style = WatermarkStyle.badge,
    this.size = WatermarkSize.small,
    this.margin = DSSpacing.sm,
    this.opacity = 1.0,
  });

  /// 워터마크 위치
  final WatermarkPosition position;

  /// 워터마크 스타일
  final WatermarkStyle style;

  /// 워터마크 크기
  final WatermarkSize size;

  /// 가장자리 여백
  final double margin;

  /// 투명도
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final watermark = AppWatermark(
      style: style,
      size: size,
      opacity: opacity,
    );

    return Positioned(
      top: position.isTop ? margin : null,
      bottom: position.isBottom ? margin : null,
      left: position.isLeft ? margin : null,
      right: position.isRight ? margin : null,
      child: watermark,
    );
  }
}

/// 워터마크 위치
enum WatermarkPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  topCenter,
  bottomCenter,
}

extension WatermarkPositionExtension on WatermarkPosition {
  bool get isTop =>
      this == WatermarkPosition.topLeft ||
      this == WatermarkPosition.topRight ||
      this == WatermarkPosition.topCenter;

  bool get isBottom =>
      this == WatermarkPosition.bottomLeft ||
      this == WatermarkPosition.bottomRight ||
      this == WatermarkPosition.bottomCenter;

  bool get isLeft =>
      this == WatermarkPosition.topLeft ||
      this == WatermarkPosition.bottomLeft;

  bool get isRight =>
      this == WatermarkPosition.topRight ||
      this == WatermarkPosition.bottomRight;

  bool get isCenter =>
      this == WatermarkPosition.topCenter ||
      this == WatermarkPosition.bottomCenter;
}

/// 날짜 + 워터마크 조합 위젯
class DateWatermark extends StatelessWidget {
  const DateWatermark({
    super.key,
    required this.date,
    this.style = WatermarkStyle.minimal,
    this.size = WatermarkSize.small,
    this.dateFormat = DateWatermarkFormat.short,
    this.showAppName = true,
  });

  /// 날짜
  final DateTime date;

  /// 워터마크 스타일
  final WatermarkStyle style;

  /// 워터마크 크기
  final WatermarkSize size;

  /// 날짜 포맷
  final DateWatermarkFormat dateFormat;

  /// 앱 이름 표시 여부
  final bool showAppName;

  String _formatDate() {
    return switch (dateFormat) {
      DateWatermarkFormat.short =>
        '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}',
      DateWatermarkFormat.long =>
        '${date.year}년 ${date.month}월 ${date.day}일',
      DateWatermarkFormat.monthDay =>
        '${date.month}월 ${date.day}일',
    };
  }

  @override
  Widget build(BuildContext context) {
    final (_, fontSize, padding) = _getSizeParams();

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: padding,
        vertical: padding * 0.5,
      ),
      decoration: BoxDecoration(
        color: context.colors.textPrimary.withValues(alpha:0.1),
        borderRadius: DSRadius.smBorder,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatDate(),
            style: context.typography.labelSmall.copyWith(
              color: context.colors.textSecondary,
              fontSize: fontSize,
            ),
          ),
          if (showAppName) ...[
            Padding(
              padding: EdgeInsets.symmetric(horizontal: padding * 0.5),
              child: Text(
                '·',
                style: TextStyle(
                  color: context.colors.textTertiary,
                  fontSize: fontSize,
                ),
              ),
            ),
            Icon(
              Icons.auto_awesome,
              size: fontSize * 1.1,
              color: context.colors.textSecondary,
            ),
            SizedBox(width: padding * 0.3),
            Text(
              'Fortune',
              style: context.typography.labelSmall.copyWith(
                color: context.colors.textSecondary,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  (double iconSize, double fontSize, double padding) _getSizeParams() {
    return switch (size) {
      WatermarkSize.tiny => (10.0, 8.0, DSSpacing.xs),
      WatermarkSize.small => (12.0, 10.0, DSSpacing.sm),
      WatermarkSize.medium => (16.0, 12.0, DSSpacing.sm),
      WatermarkSize.large => (20.0, 14.0, DSSpacing.md),
    };
  }
}

/// 날짜 워터마크 포맷
enum DateWatermarkFormat {
  /// 2025.01.08
  short,

  /// 2025년 1월 8일
  long,

  /// 1월 8일
  monthDay,
}
