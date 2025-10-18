import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/fortune_card_images.dart';
import '../pages/fortune_list_page.dart';


import '../../../../core/theme/toss_design_system.dart';
import '../../../../core/theme/typography_unified.dart';

class FortuneListTile extends ConsumerWidget {
  final FortuneCategory category;
  final VoidCallback onTap;

  const FortuneListTile({
    super.key,
    required this.category,
    required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final gradientColors = FortuneCardImages.getGradientColors(category.type);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: TossDesignSystem.spacingM, vertical: TossDesignSystem.spacingS),
        child: Row(
          children: [
            // Small gradient thumbnail instead of image
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                borderRadius: BorderRadius.circular(TossDesignSystem.radiusM),
                boxShadow: [
                  BoxShadow(
                    color: gradientColors.first.withValues(alpha: 0.25),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(
                      category.icon,
                      size: 24,
                      color: TossDesignSystem.white.withValues(alpha: 0.9),
                    ),
                  ),
                  // Small decorative element
                  Positioned(
                    right: -5,
                    bottom: -5,
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: TossDesignSystem.white.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: TossDesignSystem.spacingM),
            // Title and description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          category.title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      ),
                      if (category.isNew) Container(
                          margin: const EdgeInsets.only(left: TossDesignSystem.spacingS),
                          padding: const EdgeInsets.symmetric(horizontal: TossDesignSystem.spacingS, vertical: 4 * 0.5),
                          decoration: BoxDecoration(
                            color: TossDesignSystem.errorRed,
                            borderRadius: BorderRadius.circular(TossDesignSystem.radiusS)),
                          child: Text(
                            'NEW',
                            style: TextStyle(
                              color: TossDesignSystem.white,
                              
                              fontWeight: FontWeight.bold)),
                        ),
                      if (category.isPremium) Container(
                          margin: const EdgeInsets.only(left: TossDesignSystem.spacingS),
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: TossDesignSystem.warningOrange,
                            borderRadius: BorderRadius.circular(TossDesignSystem.radiusM)),
                          child: const Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: TossDesignSystem.white),
                        ),
                    ],
                  ),
                  const SizedBox(height: TossDesignSystem.spacingXS),
                  Text(
                    category.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: TossDesignSystem.spacingS),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              size: 24),
          ],
        ),
      ),
    );
  }
}