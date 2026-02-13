import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/fortune.dart';
import '../../core/design_system/design_system.dart';

class BirthYearFortuneList extends StatelessWidget {
  final List<BirthYearFortune> fortunes;
  final String? title;
  final String? currentUserZodiac;

  const BirthYearFortuneList({
    super.key,
    required this.fortunes,
    this.title,
    this.currentUserZodiac,
  });

  @override
  Widget build(BuildContext context) {
    if (fortunes.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (title != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacing1,
              vertical: AppSpacing.spacing2,
            ),
            child: Text(
              title!,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
        SizedBox(
          height: AppSpacing.spacing24 * 1.25,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: fortunes.length,
            itemBuilder: (context, index) {
              final fortune = fortunes[index];
              final isCurrentUser = fortune.zodiacAnimal == currentUserZodiac;

              return BirthYearFortuneCard(
                fortune: fortune,
                isHighlighted: isCurrentUser,
              );
            },
          ),
        ),
      ],
    );
  }
}

class BirthYearFortuneCard extends StatelessWidget {
  final BirthYearFortune fortune;
  final bool isHighlighted;

  const BirthYearFortuneCard({
    super.key,
    required this.fortune,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSpacing.spacing1 * 70.0,
      margin: const EdgeInsets.only(
        right: AppSpacing.spacing3,
      ),
      child: Card(
        elevation: isHighlighted ? 4 : 2,
        shape: RoundedRectangleBorder(
          borderRadius: AppDimensions.borderRadiusLarge,
          side: isHighlighted
              ? const BorderSide(color: DSColors.accentDark, width: 2)
              : BorderSide.none,
        ),
        child: Container(
          padding: AppSpacing.paddingAll16,
          decoration: BoxDecoration(
            borderRadius: AppDimensions.borderRadiusLarge,
            gradient: isHighlighted
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      DSColors.accentDark.withValues(alpha: 0.1),
                      DSColors.accentDark.withValues(alpha: 0.05),
                    ],
                  )
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildZodiacIcon(context, fortune.zodiacAnimal),
                  const SizedBox(width: AppSpacing.spacing3),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${fortune.birthYear}년생 ${fortune.zodiacAnimal}띠',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        if (isHighlighted)
                          Text(
                            '나의 띠',
                            style:
                                Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: DSColors.accentDark,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.spacing3),
              Expanded(
                child: Text(
                  fortune.description,
                  style: Theme.of(context).textTheme.bodySmall,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (fortune.advice != null) ...[
                const SizedBox(height: AppSpacing.spacing2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.spacing2,
                    vertical: AppSpacing.spacing1,
                  ),
                  decoration: BoxDecoration(
                    color: DSColors.warning.withValues(alpha: 0.2),
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusXSmall),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.tips_and_updates,
                        size: 14,
                        color: DSColors.warning,
                      ),
                      const SizedBox(width: AppSpacing.spacing1),
                      Expanded(
                        child: Text(
                          fortune.advice!,
                          style: Theme.of(context).textTheme.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZodiacIcon(BuildContext context, String zodiac) {
    final zodiacEmojis = {
      '쥐': '🐭',
      '소': '🐮',
      '호랑이': '🐯',
      '토끼': '🐰',
      '용': '🐲',
      '뱀': '🐍',
      '말': '🐴',
      '양': '🐑',
      '원숭이': '🐵',
      '닭': '🐓',
      '개': '🐕',
      '돼지': '🐖',
    };

    return Container(
      width: AppDimensions.buttonHeightMedium,
      height: AppDimensions.buttonHeightMedium,
      decoration: BoxDecoration(
        color: DSColors.accentDark.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          zodiacEmojis[zodiac] ?? '🔮',
          style: context.displaySmall,
        ),
      ),
    );
  }
}

// Expanded view for a single birth year fortune
class BirthYearFortuneDetailCard extends StatelessWidget {
  final BirthYearFortune fortune;

  const BirthYearFortuneDetailCard({
    super.key,
    required this.fortune,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusLarge,
      ),
      child: Padding(
        padding: AppSpacing.paddingAll20,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildZodiacIcon(context, fortune.zodiacAnimal),
                const SizedBox(width: AppSpacing.spacing4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${fortune.birthYear}년생 ${fortune.zodiacAnimal}띠',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(height: AppSpacing.spacing1),
                      Text(
                        '특별 운세',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: DSColors.textSecondaryDark,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.spacing5),
            Text(
              fortune.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (fortune.advice != null) ...[
              const SizedBox(height: AppSpacing.spacing4),
              Container(
                padding: AppSpacing.paddingAll16,
                decoration: BoxDecoration(
                  color: DSColors.warning.withValues(alpha: 0.1),
                  borderRadius: AppDimensions.borderRadiusMedium,
                  border: Border.all(
                    color: DSColors.warning.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.tips_and_updates,
                      color: DSColors.warning,
                      size: AppDimensions.iconSizeSmall,
                    ),
                    const SizedBox(width: AppSpacing.spacing3),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '특별 조언',
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.spacing1),
                          Text(
                            fortune.advice!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildZodiacIcon(BuildContext context, String zodiac) {
    final zodiacEmojis = {
      '쥐': '🐭',
      '소': '🐮',
      '호랑이': '🐯',
      '토끼': '🐰',
      '용': '🐲',
      '뱀': '🐍',
      '말': '🐴',
      '양': '🐑',
      '원숭이': '🐵',
      '닭': '🐓',
      '개': '🐕',
      '돼지': '🐖',
    };

    return Container(
      width: AppDimensions.buttonHeightLarge,
      height: AppDimensions.buttonHeightLarge,
      decoration: BoxDecoration(
        color: DSColors.accentDark.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          zodiacEmojis[zodiac] ?? '🔮',
          style: context.displaySmall,
        ),
      ),
    );
  }
}
