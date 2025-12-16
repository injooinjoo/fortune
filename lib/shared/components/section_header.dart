import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune/core/design_system/design_system.dart';
import '../../core/providers/user_settings_provider.dart';

class SectionHeader extends ConsumerWidget {
  final String title;

  const SectionHeader({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final typography = ref.watch(typographyThemeProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        DSSpacing.pageHorizontal,
        DSSpacing.lg,
        DSSpacing.pageHorizontal,
        DSSpacing.sm,
      ),
      child: Text(
        title,
        style: typography.labelMedium.copyWith(
          color: colors.textSecondary,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
