import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/toss_design_system.dart';
import '../../core/providers/user_settings_provider.dart';

class SettingsListTile extends ConsumerWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showBadge;
  final bool isLast;

  const SettingsListTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.leading,
    this.trailing,
    this.onTap,
    this.showBadge = false,
    this.isLast = false,
  }) : assert(icon == null || leading == null, 'Cannot provide both icon and leading widget');

  bool _isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Color _getTextColor(BuildContext context) {
    return _isDarkMode(context)
        ? TossDesignSystem.grayDark900
        : TossDesignSystem.gray900;
  }

  Color _getSecondaryTextColor(BuildContext context) {
    return _isDarkMode(context)
        ? TossDesignSystem.grayDark400
        : TossDesignSystem.gray600;
  }

  Color _getDividerColor(BuildContext context) {
    return _isDarkMode(context)
        ? TossDesignSystem.grayDark200
        : TossDesignSystem.gray200;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(typographyThemeProvider);
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: TossDesignSystem.marginHorizontal,
            vertical: TossDesignSystem.spacingM,
          ),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isLast ? Colors.transparent : _getDividerColor(context),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // Leading (Icon or Custom Widget)
              if (icon != null)
                Icon(
                  icon,
                  size: 22,
                  color: _getSecondaryTextColor(context),
                )
              else if (leading != null)
                leading!,

              if (icon != null || leading != null)
                const SizedBox(width: TossDesignSystem.spacingM),

              // Title & Subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: typography.bodyMedium.copyWith(
                              color: _getTextColor(context),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (showBadge) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: TossDesignSystem.tossBlue,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'PRO',
                              style: typography.labelSmall.copyWith(
                                color: TossDesignSystem.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: typography.labelMedium.copyWith(
                          color: _getSecondaryTextColor(context),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing
              if (trailing != null)
                trailing!
              else if (onTap != null)
                Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: _getSecondaryTextColor(context),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
