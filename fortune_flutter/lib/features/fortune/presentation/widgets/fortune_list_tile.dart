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
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final imagePath = FortuneCardImages.getRandomThumbnail(category.type);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing4, vertical: AppSpacing.spacing3),
        child: Row(
          children: [
            // Small thumbnail
            Container(
              width: 48,
              height: AppDimensions.buttonHeightMedium,
              decoration: BoxDecoration(
                borderRadius: AppDimensions.borderRadiusMedium,
              ),
              child: ClipRRect(
                borderRadius: AppDimensions.borderRadiusMedium,
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: category.gradientColors,
                        ),
                        borderRadius: AppDimensions.borderRadiusMedium,
                      ),
                      child: Center(
                        child: Icon(
                          category.icon,
                          size: 24,
                          color: Colors.white,
                        ));
},
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
                          overflow: TextOverflow.ellipsis,
                        ),
                      if (category.isNew), Container(
                          margin: const EdgeInsets.only(left: AppSpacing.spacing2),
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing2, vertical: AppSpacing.spacing0 * 0.5),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: AppDimensions.borderRadiusSmall,
                          ),
                          child: const Text(
                            'NEW',
                            style: Theme.of(context).textTheme.bodyMedium,
                      if (category.isPremium), Container(
                          margin: const EdgeInsets.only(left: AppSpacing.spacing2),
                          padding: AppSpacing.paddingAll4,
                          decoration: BoxDecoration(
                            color: AppColors.warning,
                            borderRadius: AppDimensions.borderRadiusMedium,
                          ),
                          child: const Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: Colors.white,
                          ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.spacing1),
                  Text(
                    category.description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            const SizedBox(width: AppSpacing.spacing2),
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
              size: 24,
            ),
          ],
        ));
}
}