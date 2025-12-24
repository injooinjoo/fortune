import 'package:flutter/material.dart';
import '../../core/design_system/design_system.dart';
import '../../core/theme/app_theme_extensions.dart';

/// Entertainment disclaimer widget for App Store compliance
/// Displays "For Entertainment Only" message
class EntertainmentDisclaimer extends StatelessWidget {
  /// Full text version with icon
  final bool showIcon;

  /// Compact version (single line)
  final bool compact;

  /// Custom text override
  final String? customText;

  const EntertainmentDisclaimer({
    super.key,
    this.showIcon = true,
    this.compact = false,
    this.customText,
  });

  /// Default disclaimer text (Korean)
  static const String defaultTextKo = '본 콘텐츠는 AI가 생성한 재미 목적의 엔터테인먼트입니다.';

  /// Short disclaimer text (Korean)
  static const String shortTextKo = '재미 목적 엔터테인먼트';

  /// Default disclaimer text (English)
  static const String defaultTextEn = 'For entertainment purposes only. AI-generated content.';

  /// Short disclaimer text (English)
  static const String shortTextEn = 'For entertainment only';

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    final text = customText ?? (compact ? shortTextKo : defaultTextKo);

    if (compact) {
      return Text(
        text,
        style: typography.labelSmall.copyWith(
          color: colors.textTertiary,
          fontSize: 10,
        ),
        textAlign: TextAlign.center,
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(DSRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showIcon) ...[
            Icon(
              Icons.info_outline_rounded,
              size: 14,
              color: colors.textTertiary,
            ),
            const SizedBox(width: DSSpacing.xs),
          ],
          Flexible(
            child: Text(
              text,
              style: typography.labelSmall.copyWith(
                color: colors.textTertiary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Banner version of entertainment disclaimer
/// For use at bottom of result pages
class EntertainmentDisclaimerBanner extends StatelessWidget {
  const EntertainmentDisclaimerBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.lg,
        vertical: DSSpacing.md,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceVariant.withValues(alpha: 0.3),
        border: Border(
          top: BorderSide(
            color: colors.border,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lightbulb_outline_rounded,
                size: 16,
                color: colors.textTertiary,
              ),
              const SizedBox(width: DSSpacing.xs),
              Text(
                'Entertainment Only',
                style: typography.labelMedium.copyWith(
                  color: colors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: DSSpacing.xxs),
          Text(
            '본 콘텐츠는 AI가 생성한 재미 목적의 엔터테인먼트입니다.\n실제 예언, 조언, 가이드를 제공하지 않습니다.',
            style: typography.labelSmall.copyWith(
              color: colors.textTertiary,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Inline disclaimer for use within content
class InlineDisclaimer extends StatelessWidget {
  final String? text;

  const InlineDisclaimer({
    super.key,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final typography = context.typography;

    return Text(
      text ?? '※ 재미 목적 엔터테인먼트 콘텐츠',
      style: typography.labelSmall.copyWith(
        color: colors.textTertiary,
        fontStyle: FontStyle.italic,
      ),
      textAlign: TextAlign.center,
    );
  }
}
