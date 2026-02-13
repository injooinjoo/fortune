import 'package:flutter/material.dart';
import '../../theme/ds_extensions.dart';
import '../../tokens/ds_colors.dart';
import '../../../theme/font_config.dart';

// Legacy color helpers (ChatGPT style migration)
class _LegacyColors {
  static Color getGold(bool isDark) =>
      isDark ? const Color(0xFFFFD700) : DSColors.warning;
  static Color getHanjiBackground(bool isDark) =>
      isDark ? DSColors.background : DSColors.backgroundDark;
  static const Color luckyRed = DSColors.error;
  static const Color healthLuck = DSColors.success;

  // Love colors (from DSLoveColors)
  static Color getLovePrimary(bool isDark) =>
      isDark ? const Color(0xFFE91E63) : const Color(0xFFD81B60);
  static Color getLoveBackground(bool isDark) =>
      isDark ? const Color(0xFF2D1D26) : const Color(0xFFFCE4EC);
  static const Color rougePink = Color(0xFFE91E63);
}

/// Fortune header layout style
enum FortuneHeaderStyle {
  centered, // 중앙 정렬 (기본)
  leftAligned, // 좌측 정렬
  scroll, // 두루마리 스타일
  hanging, // 족자 스타일
  minimal, // 최소 스타일
}

/// Color scheme for fortune headers
enum FortuneHeaderColorScheme {
  fortune, // 자주색 (일반 운세)
  love, // 연지색 (연애/궁합)
  luck, // 황금색 (행운/길흉)
  health, // 청록색 (건강)
  custom, // 커스텀
}

/// Korean Traditional Fortune Page Header
///
/// Design Philosophy:
/// - Calligraphy style title with optional Hanja
/// - Traditional decorations (seal stamp, brush strokes)
/// - Hanji-like background
/// - Support for back navigation
///
/// Usage:
/// ```dart
/// FortuneHeader(
///   title: '오늘의 운세',
///   hanja: '今日運勢',
///   style: FortuneHeaderStyle.centered,
///   colorScheme: FortuneHeaderColorScheme.fortune,
/// )
/// ```
class FortuneHeader extends StatelessWidget {
  final String title;
  final String? hanja;
  final String? subtitle;
  final FortuneHeaderStyle style;
  final FortuneHeaderColorScheme colorScheme;
  final VoidCallback? onBackPressed;
  final bool showSealStamp;
  final String? sealText;
  final Widget? trailing;
  final Widget? leading;
  final Color? customPrimaryColor;
  final Color? customBackgroundColor;
  final EdgeInsets padding;
  final bool showDivider;
  final bool showDecoration;

  const FortuneHeader({
    super.key,
    required this.title,
    this.hanja,
    this.subtitle,
    this.style = FortuneHeaderStyle.centered,
    this.colorScheme = FortuneHeaderColorScheme.fortune,
    this.onBackPressed,
    this.showSealStamp = false,
    this.sealText,
    this.trailing,
    this.leading,
    this.customPrimaryColor,
    this.customBackgroundColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    this.showDivider = false,
    this.showDecoration = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final colors = _getColors(isDark);

    switch (style) {
      case FortuneHeaderStyle.centered:
        return _buildCenteredHeader(context, isDark, colors);
      case FortuneHeaderStyle.leftAligned:
        return _buildLeftAlignedHeader(context, isDark, colors);
      case FortuneHeaderStyle.scroll:
        return _buildScrollHeader(context, isDark, colors);
      case FortuneHeaderStyle.hanging:
        return _buildHangingHeader(context, isDark, colors);
      case FortuneHeaderStyle.minimal:
        return _buildMinimalHeader(context, isDark, colors);
    }
  }

  /// Centered header - 중앙 정렬 기본 스타일
  Widget _buildCenteredHeader(
      BuildContext context, bool isDark, _HeaderColors colors) {
    return Container(
      decoration: showDecoration
          ? BoxDecoration(
              color: colors.background,
              borderRadius:
                  const BorderRadius.vertical(bottom: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : null,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: padding,
          child: Column(
            children: [
              Row(
                children: [
                  if (onBackPressed != null || leading != null)
                    leading ?? _buildBackButton(colors)
                  else
                    const SizedBox(width: 44),
                  Expanded(
                    child:
                        _buildTitleSection(colors, CrossAxisAlignment.center),
                  ),
                  if (trailing != null)
                    trailing!
                  else if (showSealStamp)
                    _buildSealStamp(colors)
                  else
                    const SizedBox(width: 44),
                ],
              ),
              if (showDivider) ...[
                const SizedBox(height: 16),
                _buildDivider(colors),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Left-aligned header - 좌측 정렬
  Widget _buildLeftAlignedHeader(
      BuildContext context, bool isDark, _HeaderColors colors) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (onBackPressed != null || leading != null)
                  leading ?? _buildBackButton(colors),
                if (onBackPressed != null) const SizedBox(width: 12),
                Expanded(
                  child: _buildTitleSection(colors, CrossAxisAlignment.start),
                ),
                if (trailing != null) trailing!,
                if (showSealStamp && trailing == null) _buildSealStamp(colors),
              ],
            ),
            if (showDivider) ...[
              const SizedBox(height: 16),
              _buildDivider(colors),
            ],
          ],
        ),
      ),
    );
  }

  /// Scroll header - 두루마리 스타일
  Widget _buildScrollHeader(
      BuildContext context, bool isDark, _HeaderColors colors) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            colors.background,
            colors.background.withValues(alpha: 0.95),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colors.primary.withValues(alpha: 0.3),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.primary.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Scroll roll decorations at top and bottom
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.2),
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 8,
              decoration: BoxDecoration(
                color: colors.primary.withValues(alpha: 0.2),
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(12)),
              ),
            ),
          ),
          // Content
          SafeArea(
            bottom: false,
            child: Padding(
              padding: padding.copyWith(
                  top: padding.top + 8, bottom: padding.bottom + 8),
              child: Row(
                children: [
                  if (onBackPressed != null || leading != null)
                    leading ?? _buildBackButton(colors)
                  else
                    const SizedBox(width: 44),
                  Expanded(
                    child:
                        _buildTitleSection(colors, CrossAxisAlignment.center),
                  ),
                  if (trailing != null)
                    trailing!
                  else if (showSealStamp)
                    _buildSealStamp(colors)
                  else
                    const SizedBox(width: 44),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Hanging scroll header - 족자 스타일
  Widget _buildHangingHeader(
      BuildContext context, bool isDark, _HeaderColors colors) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Top hanging rod
          Container(
            height: 12,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(6),
              boxShadow: [
                BoxShadow(
                  color: colors.primary.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          // Connecting strings
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 2,
                height: 16,
                margin: const EdgeInsets.only(left: 20),
                color: colors.primary.withValues(alpha: 0.5),
              ),
              Container(
                width: 2,
                height: 16,
                margin: const EdgeInsets.only(right: 20),
                color: colors.primary.withValues(alpha: 0.5),
              ),
            ],
          ),
          // Main content area
          Container(
            padding: padding,
            decoration: BoxDecoration(
              color: colors.background,
              border: Border.all(
                color: colors.primary.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                if (onBackPressed != null || leading != null)
                  leading ?? _buildBackButton(colors)
                else
                  const SizedBox(width: 44),
                Expanded(
                  child: _buildTitleSection(colors, CrossAxisAlignment.center),
                ),
                if (trailing != null)
                  trailing!
                else if (showSealStamp)
                  _buildSealStamp(colors)
                else
                  const SizedBox(width: 44),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Minimal header - 최소 스타일
  Widget _buildMinimalHeader(
      BuildContext context, bool isDark, _HeaderColors colors) {
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: padding.copyWith(top: 8, bottom: 8),
        child: Row(
          children: [
            if (onBackPressed != null || leading != null)
              leading ?? _buildBackButton(colors, minimal: true),
            if (onBackPressed != null) const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontFamily: FontConfig.primary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.textColor,
              ),
            ),
            if (hanja != null) ...[
              const SizedBox(width: 6),
              Text(
                '($hanja)',
                style: TextStyle(
                  fontFamily: FontConfig.primary,
                  fontSize: 14,
                  color: colors.textColor.withValues(alpha: 0.6),
                ),
              ),
            ],
            const Spacer(),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(
      _HeaderColors colors, CrossAxisAlignment alignment) {
    return Column(
      crossAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (hanja != null) ...[
          Text(
            hanja!,
            style: TextStyle(
              fontFamily: FontConfig.primary,
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: colors.primary.withValues(alpha: 0.7),
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          title,
          style: TextStyle(
            fontFamily: FontConfig.primary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: colors.textColor,
            letterSpacing: 1,
          ),
          textAlign: alignment == CrossAxisAlignment.center
              ? TextAlign.center
              : TextAlign.start,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: TextStyle(
              fontFamily: FontConfig.primary,
              fontSize: 13,
              color: colors.textColor.withValues(alpha: 0.6),
            ),
            textAlign: alignment == CrossAxisAlignment.center
                ? TextAlign.center
                : TextAlign.start,
          ),
        ],
      ],
    );
  }

  Widget _buildBackButton(_HeaderColors colors, {bool minimal = false}) {
    return GestureDetector(
      onTap: onBackPressed,
      child: Container(
        width: minimal ? 32 : 44,
        height: minimal ? 32 : 44,
        decoration: minimal
            ? null
            : BoxDecoration(
                color: colors.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: colors.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
        child: Center(
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: minimal ? 18 : 20,
            color: colors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildSealStamp(_HeaderColors colors) {
    final stampText = sealText ?? title.substring(0, 1);

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: colors.sealColor,
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          stampText,
          style: TextStyle(
            fontFamily: FontConfig.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: colors.sealColor,
          ),
        ),
      ),
    );
  }

  Widget _buildDivider(_HeaderColors colors) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  colors.primary.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colors.primary.withValues(alpha: 0.3),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  _HeaderColors _getColors(bool isDark) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    switch (colorScheme) {
      case FortuneHeaderColorScheme.fortune:
        return _HeaderColors(
          primary: DSColors.getAccentSecondary(brightness),
          background: DSColors.getBackground(brightness),
          textColor: DSColors.getTextPrimary(brightness),
          sealColor: DSColors.error,
        );
      case FortuneHeaderColorScheme.love:
        return _HeaderColors(
          primary: _LegacyColors.getLovePrimary(isDark),
          background: _LegacyColors.getLoveBackground(isDark),
          textColor: DSColors.getTextPrimary(brightness),
          sealColor: _LegacyColors.rougePink,
        );
      case FortuneHeaderColorScheme.luck:
        return _HeaderColors(
          primary: _LegacyColors.getGold(isDark),
          background: _LegacyColors.getHanjiBackground(isDark),
          textColor: DSColors.getTextPrimary(brightness),
          sealColor: _LegacyColors.luckyRed,
        );
      case FortuneHeaderColorScheme.health:
        return _HeaderColors(
          primary: _LegacyColors.healthLuck,
          background:
              isDark ? const Color(0xFF1D2D25) : const Color(0xFFF0F8F5),
          textColor: DSColors.getTextPrimary(brightness),
          sealColor: _LegacyColors.healthLuck,
        );
      case FortuneHeaderColorScheme.custom:
        return _HeaderColors(
          primary: customPrimaryColor ?? DSColors.accentSecondary,
          background: customBackgroundColor ?? DSColors.backgroundSecondaryDark,
          textColor: DSColors.getTextPrimary(brightness),
          sealColor: customPrimaryColor ?? DSColors.error,
        );
    }
  }
}

/// Internal color holder for header
class _HeaderColors {
  final Color primary;
  final Color background;
  final Color textColor;
  final Color sealColor;

  const _HeaderColors({
    required this.primary,
    required this.background,
    required this.textColor,
    required this.sealColor,
  });
}

/// SliverAppBar version of FortuneHeader for scrollable pages
class FortuneHeaderSliver extends StatelessWidget {
  final String title;
  final String? hanja;
  final String? subtitle;
  final FortuneHeaderColorScheme colorScheme;
  final VoidCallback? onBackPressed;
  final bool showSealStamp;
  final String? sealText;
  final Widget? trailing;
  final double expandedHeight;
  final bool pinned;
  final bool floating;

  const FortuneHeaderSliver({
    super.key,
    required this.title,
    this.hanja,
    this.subtitle,
    this.colorScheme = FortuneHeaderColorScheme.fortune,
    this.onBackPressed,
    this.showSealStamp = false,
    this.sealText,
    this.trailing,
    this.expandedHeight = 120,
    this.pinned = true,
    this.floating = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: pinned,
      floating: floating,
      backgroundColor: _getBackgroundColor(isDark),
      elevation: 0,
      leading: onBackPressed != null
          ? IconButton(
              icon: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: _getPrimaryColor(isDark),
              ),
              onPressed: onBackPressed,
            )
          : null,
      actions: trailing != null
          ? [trailing!]
          : showSealStamp
              ? [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: _buildSealStamp(isDark),
                  ),
                ]
              : null,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        title: Text(
          title,
          style: TextStyle(
            fontFamily: FontConfig.primary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _getTextColor(isDark),
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _getBackgroundColor(isDark),
                _getBackgroundColor(isDark).withValues(alpha: 0.95),
              ],
            ),
          ),
          child: hanja != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 20),
                    child: Text(
                      hanja!,
                      style: TextStyle(
                        fontFamily: FontConfig.primary,
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        color: _getPrimaryColor(isDark).withValues(alpha: 0.3),
                        letterSpacing: 4,
                      ),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildSealStamp(bool isDark) {
    final stampText = sealText ?? title.substring(0, 1);
    final sealColor = _getSealColor(isDark);

    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: sealColor, width: 2),
      ),
      child: Center(
        child: Text(
          stampText,
          style: TextStyle(
            fontFamily: FontConfig.primary,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: sealColor,
          ),
        ),
      ),
    );
  }

  Color _getPrimaryColor(bool isDark) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    switch (colorScheme) {
      case FortuneHeaderColorScheme.fortune:
        return DSColors.getAccentSecondary(brightness);
      case FortuneHeaderColorScheme.love:
        return _LegacyColors.getLovePrimary(isDark);
      case FortuneHeaderColorScheme.luck:
        return _LegacyColors.getGold(isDark);
      case FortuneHeaderColorScheme.health:
        return _LegacyColors.healthLuck;
      case FortuneHeaderColorScheme.custom:
        return DSColors.getAccentSecondary(brightness);
    }
  }

  Color _getBackgroundColor(bool isDark) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    switch (colorScheme) {
      case FortuneHeaderColorScheme.fortune:
        return DSColors.getBackground(brightness);
      case FortuneHeaderColorScheme.love:
        return _LegacyColors.getLoveBackground(isDark);
      case FortuneHeaderColorScheme.luck:
        return _LegacyColors.getHanjiBackground(isDark);
      case FortuneHeaderColorScheme.health:
        return isDark ? const Color(0xFF1D2D25) : const Color(0xFFF0F8F5);
      case FortuneHeaderColorScheme.custom:
        return DSColors.getBackground(brightness);
    }
  }

  Color _getTextColor(bool isDark) {
    final brightness = isDark ? Brightness.dark : Brightness.light;
    return DSColors.getTextPrimary(brightness);
  }

  Color _getSealColor(bool isDark) {
    switch (colorScheme) {
      case FortuneHeaderColorScheme.fortune:
        return DSColors.error;
      case FortuneHeaderColorScheme.love:
        return _LegacyColors.rougePink;
      case FortuneHeaderColorScheme.luck:
        return _LegacyColors.luckyRed;
      case FortuneHeaderColorScheme.health:
        return _LegacyColors.healthLuck;
      case FortuneHeaderColorScheme.custom:
        return DSColors.error;
    }
  }
}
