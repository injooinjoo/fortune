import 'package:flutter/material.dart';
import '../../design_system/design_system.dart';

/// 키워드/테마를 칩 형태로 표시하는 인포그래픽 위젯
///
/// 사용 예시:
/// ```dart
/// ThemeChips(
///   themes: ['변화', '새시작', '희망'],
///   prefix: '#',
/// )
/// ```
class ThemeChips extends StatelessWidget {
  /// 테마/키워드 목록
  final List<String> themes;

  /// 칩 앞에 붙는 접두사 (기본값: '#')
  final String prefix;

  /// 칩 간 간격 (기본값: 8)
  final double spacing;

  /// 라인 간 간격 (기본값: 8)
  final double runSpacing;

  /// 스크롤 가능 여부 (기본값: false - Wrap 사용)
  final bool scrollable;

  /// 칩 탭 콜백
  final void Function(String theme)? onChipTap;

  /// 선택된 테마 목록 (강조 표시용)
  final List<String>? selectedThemes;

  /// 칩 스타일 변형
  final ThemeChipStyle style;

  const ThemeChips({
    super.key,
    required this.themes,
    this.prefix = '#',
    this.spacing = 8,
    this.runSpacing = 8,
    this.scrollable = false,
    this.onChipTap,
    this.selectedThemes,
    this.style = ThemeChipStyle.filled,
  });

  @override
  Widget build(BuildContext context) {
    if (themes.isEmpty) return const SizedBox.shrink();

    final chips = themes.map((theme) {
      final isSelected = selectedThemes?.contains(theme) ?? false;
      return _ThemeChip(
        theme: theme,
        prefix: prefix,
        isSelected: isSelected,
        style: style,
        onTap: onChipTap != null ? () => onChipTap!(theme) : null,
      );
    }).toList();

    if (scrollable) {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: chips.asMap().entries.map((entry) {
            final index = entry.key;
            return Padding(
              padding: EdgeInsets.only(right: index < chips.length - 1 ? spacing : 0),
              child: entry.value,
            );
          }).toList(),
        ),
      );
    }

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: chips,
    );
  }
}

/// 개별 테마 칩
class _ThemeChip extends StatelessWidget {
  final String theme;
  final String prefix;
  final bool isSelected;
  final ThemeChipStyle style;
  final VoidCallback? onTap;

  const _ThemeChip({
    required this.theme,
    required this.prefix,
    required this.isSelected,
    required this.style,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;

    final backgroundColor = _getBackgroundColor(isDark);
    final textColor = _getTextColor(isDark);
    final borderColor = _getBorderColor(isDark);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(16),
          border: style == ThemeChipStyle.outlined || isSelected
              ? Border.all(color: borderColor, width: 1)
              : null,
        ),
        child: Text(
          '$prefix$theme',
          style: context.labelMedium.copyWith(
            color: textColor,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor(bool isDark) {
    if (isSelected) {
      return isDark ? DSColors.accentLightDark : DSColors.accentLight;
    }

    switch (style) {
      case ThemeChipStyle.filled:
        return isDark ? DSColors.surfaceSecondaryDark : DSColors.surfaceSecondary;
      case ThemeChipStyle.outlined:
        return Colors.transparent;
      case ThemeChipStyle.subtle:
        return isDark
            ? DSColors.backgroundSecondaryDark.withValues(alpha: 0.5)
            : DSColors.backgroundSecondary.withValues(alpha: 0.5);
    }
  }

  Color _getTextColor(bool isDark) {
    if (isSelected) {
      return isDark ? DSColors.accentDark : DSColors.accent;
    }
    return isDark ? DSColors.textSecondaryDark : DSColors.textSecondary;
  }

  Color _getBorderColor(bool isDark) {
    if (isSelected) {
      return isDark ? DSColors.accentDark : DSColors.accent;
    }
    return isDark ? DSColors.borderDark : DSColors.border;
  }
}

/// 테마 칩 스타일
enum ThemeChipStyle {
  /// 채워진 배경
  filled,

  /// 테두리만 있음
  outlined,

  /// 미묘한 배경
  subtle,
}

/// 해시태그 스타일 칩 (타로, OOTD 등에서 사용)
class HashtagChips extends StatelessWidget {
  final List<String> hashtags;
  final double spacing;
  final bool scrollable;

  const HashtagChips({
    super.key,
    required this.hashtags,
    this.spacing = 8,
    this.scrollable = true,
  });

  @override
  Widget build(BuildContext context) {
    return ThemeChips(
      themes: hashtags,
      prefix: '#',
      spacing: spacing,
      scrollable: scrollable,
      style: ThemeChipStyle.subtle,
    );
  }
}

/// 키워드 칩 (접두사 없음)
class KeywordChips extends StatelessWidget {
  final List<String> keywords;
  final double spacing;
  final bool scrollable;
  final void Function(String keyword)? onKeywordTap;

  const KeywordChips({
    super.key,
    required this.keywords,
    this.spacing = 8,
    this.scrollable = false,
    this.onKeywordTap,
  });

  @override
  Widget build(BuildContext context) {
    return ThemeChips(
      themes: keywords,
      prefix: '',
      spacing: spacing,
      scrollable: scrollable,
      style: ThemeChipStyle.filled,
      onChipTap: onKeywordTap,
    );
  }
}
