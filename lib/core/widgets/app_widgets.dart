import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/toss_design_system.dart';

/// 앱 색상 정의 (ChatGPT 스타일 참고)
class AppColors {
  // Light Mode
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color surfaceLight = Color(0xFFF7F7F8);
  static const Color inputBackgroundLight = Color(0xFFF4F4F4);
  static const Color borderLight = Color(0xFFE5E5E5);
  static const Color textPrimaryLight = Color(0xFF0D0D0D);
  static const Color textSecondaryLight = Color(0xFF6E6E80);
  static const Color accentGreen = Color(0xFF10A37F);
  static const Color accentPurple = Color(0xFF6E56CF);

  // Dark Mode
  static const Color backgroundDark = Color(0xFF212121);
  static const Color surfaceDark = Color(0xFF2F2F2F);
  static const Color inputBackgroundDark = Color(0xFF3D3D3D);
  static const Color borderDark = Color(0xFF444444);
  static const Color textPrimaryDark = Color(0xFFECECEC);
  static const Color textSecondaryDark = Color(0xFF8E8EA0);

  // Selection Colors
  static const Color selectedLight = Color(0xFFECECEC);
  static const Color selectedDark = Color(0xFF444444);
  static const Color chipSelectedLight = Color(0xFF10A37F);
  static const Color chipSelectedDark = Color(0xFF10A37F);

  // ChatGPT 스타일 칩 배경색 (테두리 없음)
  static const Color chipUnselectedLight = Color(0xFFECECEC);
  static const Color chipUnselectedDark = Color(0xFF3A3A3A);
}

/// Pill 스타일 입력 필드
class PillTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final int maxLines;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final bool enabled;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final bool readOnly;

  const PillTextField({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.maxLines = 1,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.prefixIcon,
    this.suffixIcon,
    this.enabled = true,
    this.focusNode,
    this.onTap,
    this.readOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (labelText != null) ...[
          Text(
            labelText!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 8),
        ],
        TextField(
          controller: controller,
          maxLines: maxLines,
          obscureText: obscureText,
          keyboardType: keyboardType,
          onChanged: onChanged,
          enabled: enabled,
          focusNode: focusNode,
          onTap: onTap,
          readOnly: readOnly,
          style: TextStyle(
            fontSize: 16,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
            ),
            filled: true,
            fillColor: isDark
                ? AppColors.inputBackgroundDark
                : AppColors.inputBackgroundLight,
            prefixIcon: prefixIcon,
            suffixIcon: suffixIcon,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(24),
              borderSide: BorderSide(
                color: AppColors.accentGreen,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 선택 칩
class SelectionChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;
  final String? emoji;
  final IconData? icon;

  const SelectionChip({
    super.key,
    required this.label,
    this.isSelected = false,
    this.onTap,
    this.emoji,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accentGreen
              : (isDark
                  ? AppColors.chipUnselectedDark
                  : AppColors.chipUnselectedLight),
          borderRadius: BorderRadius.circular(20),
          // ChatGPT 스타일: 테두리 없음
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (emoji != null) ...[
              Text(emoji!, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 8),
            ],
            if (icon != null) ...[
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected
                    ? Colors.white
                    : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimaryLight),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 모던 스타일 카드
class ModernCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final bool isSelected;

  const ModernCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap != null
          ? () {
              HapticFeedback.lightImpact();
              onTap!();
            }
          : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark
              : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(16),
          // ChatGPT 스타일: 선택 시에만 테두리 표시
          border: isSelected
              ? Border.all(
                  color: AppColors.accentGreen,
                  width: 2,
                )
              : null,
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: child,
      ),
    );
  }
}

/// 선택 카드 (라디오 버튼 포함)
class SelectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? emoji;
  final IconData? icon;
  final bool isSelected;
  final VoidCallback? onTap;

  const SelectionCard({
    super.key,
    required this.title,
    this.subtitle,
    this.emoji,
    this.icon,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? AppColors.accentGreen.withValues(alpha: 0.15)
                  : AppColors.accentGreen.withValues(alpha: 0.1))
              : (isDark
                  ? AppColors.chipUnselectedDark
                  : AppColors.chipUnselectedLight),
          borderRadius: BorderRadius.circular(16),
          // ChatGPT 스타일: 선택 시에만 테두리 표시
          border: isSelected
              ? Border.all(
                  color: AppColors.accentGreen,
                  width: 2,
                )
              : null,
        ),
        child: Row(
          children: [
            if (emoji != null) ...[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentGreen.withValues(alpha: 0.2)
                      : (isDark
                          ? AppColors.surfaceDark
                          : AppColors.surfaceLight),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(emoji!, style: const TextStyle(fontSize: 22)),
                ),
              ),
              const SizedBox(width: 14),
            ],
            if (icon != null) ...[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.accentGreen.withValues(alpha: 0.2)
                      : (isDark
                          ? AppColors.surfaceDark
                          : AppColors.surfaceLight),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 22,
                  color: isSelected
                      ? AppColors.accentGreen
                      : (isDark
                          ? AppColors.textSecondaryDark
                          : AppColors.textSecondaryLight),
                ),
              ),
              const SizedBox(width: 14),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected
                    ? AppColors.accentGreen
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected
                      ? AppColors.accentGreen
                      : (isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight),
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// 페이지 헤더 섹션 (이모지/아이콘 + 제목)
class PageHeaderSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? emoji;
  final IconData? icon;
  final Color? iconBackgroundColor;

  const PageHeaderSection({
    super.key,
    required this.title,
    this.subtitle,
    this.emoji,
    this.icon,
    this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        if (emoji != null || icon != null)
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: iconBackgroundColor ??
                  (isDark
                      ? AppColors.surfaceDark
                      : AppColors.surfaceLight),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: emoji != null
                  ? Text(emoji!, style: const TextStyle(fontSize: 32))
                  : Icon(
                      icon,
                      size: 32,
                      color: AppColors.accentGreen,
                    ),
            ),
          ),
        if (emoji != null || icon != null) const SizedBox(height: 20),
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: isDark
                ? AppColors.textPrimaryDark
                : AppColors.textPrimaryLight,
          ),
          textAlign: TextAlign.center,
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 8),
          Text(
            subtitle!,
            style: TextStyle(
              fontSize: 16,
              color: isDark
                  ? AppColors.textSecondaryDark
                  : AppColors.textSecondaryLight,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// 필드 라벨
class FieldLabel extends StatelessWidget {
  final String text;
  final bool isRequired;

  const FieldLabel({
    super.key,
    required this.text,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          if (isRequired) ...[
            const SizedBox(width: 4),
            Text(
              '*',
              style: TextStyle(
                fontSize: 15,
                color: TossDesignSystem.errorRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// 라벨 슬라이더
class LabeledSlider extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final List<String>? labels;

  const LabeledSlider({
    super.key,
    required this.label,
    required this.value,
    this.min = 1,
    this.max = 5,
    required this.onChanged,
    this.labels,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.accentGreen.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                labels != null && value >= min && value <= max
                    ? labels![value - min]
                    : value.toString(),
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.accentGreen,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.accentGreen,
            inactiveTrackColor: isDark
                ? AppColors.borderDark
                : AppColors.borderLight,
            thumbColor: AppColors.accentGreen,
            overlayColor: AppColors.accentGreen.withOpacity(0.2),
            trackHeight: 6,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
          ),
          child: Slider(
            value: value.toDouble(),
            min: min.toDouble(),
            max: max.toDouble(),
            divisions: max - min,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onChanged(v.round());
            },
          ),
        ),
      ],
    );
  }
}

/// 카드 스타일 체크박스
class CardCheckbox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const CardCheckbox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onChanged(!value);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: value
              ? AppColors.accentGreen.withOpacity(0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value
                ? AppColors.accentGreen
                : (isDark
                    ? AppColors.borderDark
                    : AppColors.borderLight),
            width: value ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: value ? AppColors.accentGreen : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: value
                      ? AppColors.accentGreen
                      : (isDark
                          ? AppColors.borderDark
                          : AppColors.borderLight),
                  width: 2,
                ),
              ),
              child: value
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: value ? FontWeight.w600 : FontWeight.w400,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Phase 1: 핵심 컴포넌트 (HIGH PRIORITY)
// ============================================================================

/// 섹션 헤더 (아이콘 + 제목)
///
/// 40x40 아이콘 박스와 제목 텍스트를 포함하는 Row 컴포넌트
/// ```dart
/// SectionHeader(
///   icon: Icons.favorite,
///   iconColor: Colors.pink,
///   title: '연애 조언',
/// )
/// ```
class SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final TextStyle? titleStyle;
  final double iconSize;
  final double iconContainerSize;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    this.titleStyle,
    this.iconSize = 20,
    this.iconContainerSize = 40,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: iconContainerSize,
          height: iconContainerSize,
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: iconColor,
            size: iconSize,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            title,
            style: titleStyle ??
                TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
          ),
        ),
      ],
    );
  }
}

/// 섹션 카드 (헤더 + 콘텐츠)
///
/// 아이콘, 제목, 콘텐츠를 포함하는 완전한 섹션 카드
/// ```dart
/// IconSectionCard(
///   icon: Icons.lightbulb,
///   iconColor: Colors.amber,
///   title: '오늘의 팁',
///   child: Text('긍정적인 마음가짐을 유지하세요'),
/// )
/// ```
class IconSectionCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final Widget child;
  final EdgeInsets? padding;
  final EdgeInsets? contentPadding;
  final VoidCallback? onTap;

  const IconSectionCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.child,
    this.padding,
    this.contentPadding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap != null
          ? () {
              HapticFeedback.lightImpact();
              onTap!();
            }
          : null,
      child: Container(
        padding: padding ?? const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.surfaceDark
              : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              icon: icon,
              iconColor: iconColor,
              title: title,
            ),
            Padding(
              padding: contentPadding ?? const EdgeInsets.only(top: 16),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}

/// 원형 점수 표시
///
/// 원형 프로그레스와 점수를 표시하는 컴포넌트
/// ```dart
/// CircularScore(
///   score: 85,
///   maxScore: 100,
///   label: '궁합',
///   color: Colors.pink,
/// )
/// ```
class CircularScore extends StatelessWidget {
  final int score;
  final int maxScore;
  final String? label;
  final String? sublabel;
  final Color color;
  final double size;
  final double strokeWidth;

  const CircularScore({
    super.key,
    required this.score,
    this.maxScore = 100,
    this.label,
    this.sublabel,
    required this.color,
    this.size = 80,
    this.strokeWidth = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (score / maxScore).clamp(0.0, 1.0);

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(
                color.withValues(alpha: 0.15),
              ),
            ),
          ),
          // Progress circle
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: strokeWidth,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation(color),
              strokeCap: StrokeCap.round,
            ),
          ),
          // Score text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  fontSize: size * 0.28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (label != null)
                Text(
                  label!,
                  style: TextStyle(
                    fontSize: size * 0.12,
                    fontWeight: FontWeight.w500,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
              if (sublabel != null)
                Text(
                  sublabel!,
                  style: TextStyle(
                    fontSize: size * 0.1,
                    color: isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondaryLight,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Phase 2: 콘텐츠 컴포넌트 (MEDIUM PRIORITY)
// ============================================================================

/// 힌트/팁 카드 타입
enum HintType {
  info,
  success,
  warning,
  tip,
}

/// 힌트/팁 카드
///
/// 컬러 배경과 아이콘이 있는 정보 카드
/// ```dart
/// HintCard(
///   text: '첫 만남에서는 자연스러운 대화가 중요해요',
///   type: HintType.tip,
/// )
/// ```
class HintCard extends StatelessWidget {
  final String text;
  final IconData? icon;
  final Color? color;
  final HintType type;
  final EdgeInsets? padding;

  const HintCard({
    super.key,
    required this.text,
    this.icon,
    this.color,
    this.type = HintType.info,
    this.padding,
  });

  Color get _typeColor {
    if (color != null) return color!;
    switch (type) {
      case HintType.info:
        return const Color(0xFF3B82F6); // Blue
      case HintType.success:
        return AppColors.accentGreen;
      case HintType.warning:
        return const Color(0xFFF59E0B); // Amber
      case HintType.tip:
        return AppColors.accentPurple;
    }
  }

  IconData get _typeIcon {
    if (icon != null) return icon!;
    switch (type) {
      case HintType.info:
        return Icons.info_outline_rounded;
      case HintType.success:
        return Icons.check_circle_outline_rounded;
      case HintType.warning:
        return Icons.warning_amber_rounded;
      case HintType.tip:
        return Icons.lightbulb_outline_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveColor = _typeColor;

    return Container(
      padding: padding ?? const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: effectiveColor.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: effectiveColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            _typeIcon,
            color: effectiveColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 라벨 프로그레스 바
///
/// 라벨과 퍼센트 표시가 있는 프로그레스 바
/// ```dart
/// LabeledProgressBar(
///   label: '호감도',
///   percentage: 75,
///   color: Colors.pink,
/// )
/// ```
class LabeledProgressBar extends StatelessWidget {
  final String label;
  final int percentage;
  final Color color;
  final bool showPercentage;
  final double height;

  const LabeledProgressBar({
    super.key,
    required this.label,
    required this.percentage,
    required this.color,
    this.showPercentage = true,
    this.height = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = (percentage / 100).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark
                    ? AppColors.textPrimaryDark
                    : AppColors.textPrimaryLight,
              ),
            ),
            if (showPercentage)
              Text(
                '$percentage%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(height / 2),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: height,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }
}

/// 리스트 섹션
///
/// 불릿 포인트 리스트를 표시하는 섹션
/// ```dart
/// BulletListSection(
///   title: '추천 대화 주제',
///   icon: Icons.chat_bubble_outline,
///   iconColor: Colors.blue,
///   items: ['취미 이야기', '최근 본 영화', '여행 경험'],
/// )
/// ```
class BulletListSection extends StatelessWidget {
  final String? title;
  final IconData? icon;
  final Color? iconColor;
  final List<String> items;
  final String bulletStyle;
  final Widget? customBullet;

  const BulletListSection({
    super.key,
    this.title,
    this.icon,
    this.iconColor,
    required this.items,
    this.bulletStyle = '•',
    this.customBullet,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null && icon != null && iconColor != null) ...[
          SectionHeader(
            icon: icon!,
            iconColor: iconColor!,
            title: title!,
          ),
          const SizedBox(height: 16),
        ] else if (title != null) ...[
          Text(
            title!,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? AppColors.textPrimaryDark
                  : AppColors.textPrimaryLight,
            ),
          ),
          const SizedBox(height: 12),
        ],
        ...items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Padding(
            padding: EdgeInsets.only(bottom: index < items.length - 1 ? 10 : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                customBullet ??
                    Text(
                      bulletStyle == 'number' ? '${index + 1}.' : bulletStyle,
                      style: TextStyle(
                        fontSize: 14,
                        color: iconColor ??
                            (isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondaryLight),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimaryLight,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

// ============================================================================
// Phase 3: 레이아웃 컴포넌트 (LOW PRIORITY)
// ============================================================================

/// 메트릭 데이터 모델
class ScoreMetric {
  final String label;
  final int score;
  final Color color;
  final int? maxScore;

  const ScoreMetric({
    required this.label,
    required this.score,
    required this.color,
    this.maxScore = 100,
  });
}

/// 메트릭 Row
///
/// 여러 개의 작은 점수 표시를 한 줄에 배치
/// ```dart
/// ScoreMetricsRow(
///   metrics: [
///     ScoreMetric(label: '체력', score: 80, color: Colors.red),
///     ScoreMetric(label: '정신', score: 75, color: Colors.blue),
///     ScoreMetric(label: '감정', score: 90, color: Colors.pink),
///   ],
/// )
/// ```
class ScoreMetricsRow extends StatelessWidget {
  final List<ScoreMetric> metrics;
  final double scoreSize;
  final MainAxisAlignment alignment;

  const ScoreMetricsRow({
    super.key,
    required this.metrics,
    this.scoreSize = 56,
    this.alignment = MainAxisAlignment.spaceEvenly,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: alignment,
      children: metrics
          .map((metric) => CircularScore(
                score: metric.score,
                maxScore: metric.maxScore ?? 100,
                label: metric.label,
                color: metric.color,
                size: scoreSize,
                strokeWidth: 5,
              ))
          .toList(),
    );
  }
}
