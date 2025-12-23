import 'package:flutter/material.dart';
import '../../../../core/design_system/design_system.dart';
import '../../../../core/utils/fortune_text_cleaner.dart';
import '../../../../domain/entities/fortune.dart';

class FortuneContentCard extends StatelessWidget {
  final Fortune fortune;

  const FortuneContentCard({super.key, required this.fortune});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (fortune.content.isNotEmpty) ...[
              Text(
                '상세 운세',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: DSSpacing.sm),
              Text(
                FortuneTextCleaner.clean(fortune.content),
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(height: 1.6),
              ),
              const SizedBox(height: DSSpacing.lg),
            ],

            if (fortune.scoreBreakdown != null &&
                fortune.scoreBreakdown!.isNotEmpty) ...[
              Text(
                '분야별 운세',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: DSSpacing.md),
              ..._buildScoreBreakdown(context),
              const SizedBox(height: DSSpacing.lg),
            ],

            if (fortune.luckyItems != null &&
                fortune.luckyItems!.isNotEmpty) ...[
              Text(
                '행운의 아이템',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: DSSpacing.md),
              _buildLuckyItems(context),
              const SizedBox(height: DSSpacing.lg),
            ],

            if (fortune.recommendations != null &&
                fortune.recommendations!.isNotEmpty) ...[
              Text(
                '추천 사항',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: DSSpacing.sm),
              ...fortune.recommendations!.map(
                (rec) => Padding(
                  padding:
                      const EdgeInsets.only(bottom: DSSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        size: 20,
                        color: DSColors.success,
                      ),
                      const SizedBox(width: DSSpacing.sm),
                      Expanded(
                        child: Text(
                          FortuneTextCleaner.clean(rec),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: DSSpacing.md),
            ],

            if (fortune.warnings != null &&
                fortune.warnings!.isNotEmpty) ...[
              Text(
                '주의 사항',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: DSSpacing.sm),
              ...fortune.warnings!.map(
                (warning) => Padding(
                  padding:
                      const EdgeInsets.only(bottom: DSSpacing.sm),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.warning_amber,
                        size: 20,
                        color: DSColors.warning,
                      ),
                      const SizedBox(width: DSSpacing.sm),
                      Expanded(
                        child: Text(
                          FortuneTextCleaner.clean(warning),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<Widget> _buildScoreBreakdown(BuildContext context) {
    final scoreBreakdown = fortune.scoreBreakdown!;
    final categories = [
      ('총운', '종합적인 운세', Icons.stars, DSColors.accent),
      ('애정운', '연애와 인간관계', Icons.favorite, DSColors.accentSecondary),
      ('금전운', '재물과 금전', Icons.attach_money, DSColors.warning),
      ('직장운', '직장과 업무', Icons.work, DSColors.accentSecondary),
      ('건강운', '건강과 체력', Icons.favorite_border, DSColors.success),
    ];

    return categories.map((category) {
      final raw = scoreBreakdown[category.$1];
      final int? score = (raw is num) ? raw.toInt() : null;
      if (score == null) return const SizedBox.shrink();

      return Padding(
        padding: const EdgeInsets.only(bottom: DSSpacing.sm),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: category.$4.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(DSRadius.sm),
              ),
              child: Icon(category.$3, size: 20, color: category.$4),
            ),
            const SizedBox(width: DSSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        category.$1,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Text(
                        '$score/100',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(fontWeight: FontWeight.bold, color: category.$4),
                      ),
                    ],
                  ),
                  const SizedBox(height: DSSpacing.xs),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(DSRadius.sm),
                    child: LinearProgressIndicator(
                      value: score.toDouble() / 100,
                      backgroundColor: category.$4.withValues(alpha: 0.2),
                      valueColor: AlwaysStoppedAnimation<Color>(category.$4),
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _buildLuckyItems(BuildContext context) {
    final luckyItems = fortune.luckyItems!;
    final itemTypes = [
      ('색상', Icons.palette, DSColors.accentSecondary),
      ('숫자', Icons.looks_one, DSColors.accent),
      ('방향', Icons.explore, DSColors.success),
      ('음식', Icons.restaurant, DSColors.warning),
    ];

    return Wrap(
      spacing: DSSpacing.sm,
      runSpacing: DSSpacing.sm,
      children: itemTypes.map((type) {
        final value = luckyItems[type.$1];
        if (value == null) return const SizedBox.shrink();

        return _buildLuckyItemChip(
          context,
          type.$1,
          type.$2,
          value.toString(),
          type.$3,
        );
      }).toList(),
    );
  }

  Widget _buildLuckyItemChip(
    BuildContext context,
    String label,
    IconData icon,
    String value,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: DSSpacing.md,
        vertical: DSSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DSRadius.md),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: DSSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}