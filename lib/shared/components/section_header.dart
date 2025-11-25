import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/toss_design_system.dart';
import '../../core/providers/user_settings_provider.dart';

class SectionHeader extends ConsumerWidget {
  final String title;

  const SectionHeader({
    super.key,
    required this.title,
  });

  bool _isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  Color _getSecondaryTextColor(BuildContext context) {
    return _isDarkMode(context)
        ? TossDesignSystem.grayDark400
        : TossDesignSystem.gray600;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final typography = ref.watch(typographyThemeProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        TossDesignSystem.marginHorizontal,
        TossDesignSystem.spacingL,
        TossDesignSystem.marginHorizontal,
        TossDesignSystem.spacingS,
      ),
      child: Text(
        title,
        style: typography.labelMedium.copyWith(
          color: _getSecondaryTextColor(context),
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
