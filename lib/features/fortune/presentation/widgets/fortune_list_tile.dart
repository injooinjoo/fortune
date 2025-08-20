import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/fortune_card_images.dart';
import '../pages/fortune_list_page.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:fortune/core/theme/app_colors.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing4, vertical: AppSpacing.spacing3),
        child: Row(
          children: [
            // Small gradient thumbnail instead of image
            Container(
              width: 48,
              height: AppDimensions.buttonHeightMedium,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: gradientColors,
                ),
                borderRadius: AppDimensions.borderRadiusMedium,
                boxShadow: [
                  BoxShadow(
                    color: gradientColors.first.withOpacity(0.25),
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
                      color: Colors.white.withOpacity(0.9),
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
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.spacing4),
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
                          margin: const EdgeInsets.only(left: AppSpacing.spacing2),
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing2, vertical: AppSpacing.spacing0 * 0.5),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: AppDimensions.borderRadiusSmall),
                          child: Text(
                            'NEW',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                        ),
                      if (category.isPremium) Container(
                          margin: const EdgeInsets.only(left: AppSpacing.spacing2),
                          padding: AppSpacing.paddingAll4,
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: AppDimensions.borderRadiusMedium),
                          child: const Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: Colors.white),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.spacing1),
                  Text(
                    category.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.spacing2),
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