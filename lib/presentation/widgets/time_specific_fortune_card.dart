import 'package:flutter/material.dart';
import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import '../../core/theme/fortune_design_system.dart';
import '../../domain/entities/fortune.dart';

class TimeSpecificFortuneCard extends StatelessWidget {
  final TimeSpecificFortune fortune;
  final VoidCallback? onTap;
  final bool isExpanded;

  const TimeSpecificFortuneCard({
    super.key,
    required this.fortune,
    this.onTap,
    this.isExpanded = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scoreColor = _getScoreColor(fortune.score);

    return Card(
      elevation: isExpanded ? 4 : 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: AppDimensions.borderRadiusMedium,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: AppDimensions.borderRadiusMedium,
        child: Container(
          padding: AppSpacing.paddingAll16,
          decoration: BoxDecoration(
            borderRadius: AppDimensions.borderRadiusMedium,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                scoreColor.withValues(alpha: 0.10),
                scoreColor.withValues(alpha: 0.05),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fortune.time,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.spacing1),
                        Text(
                          fortune.title,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildScoreIndicator(context, fortune.score),
                ],
              ),
              if (isExpanded) ...[
                const SizedBox(height: AppSpacing.spacing3),
                Text(
                  fortune.description,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
                if (fortune.recommendation != null) ...[
                  const SizedBox(height: AppSpacing.spacing2),
                  Container(
                    padding: AppSpacing.paddingAll12,
                    decoration: BoxDecoration(
                      color: scoreColor.withValues(alpha: 0.08),
                      borderRadius: AppDimensions.borderRadiusSmall,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: AppDimensions.iconSizeSmall,
                          color: scoreColor,
                        ),
                        const SizedBox(width: AppSpacing.spacing2),
                        Expanded(
                          child: Text(
                            fortune.recommendation!,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScoreIndicator(BuildContext context, int score) {
    final scoreColor = _getScoreColor(score);
    final theme = Theme.of(context);
    return Container(
      width: 60,
      height: AppSpacing.spacing15,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: scoreColor.withValues(alpha: 0.2),
        border: Border.all(color: scoreColor, width: 3),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$score',
              style: theme.textTheme.headlineSmall,
            ),
            Text(
              '점',
              style: theme.textTheme.bodyMedium?.copyWith(color: scoreColor),
            ),
          ],
        ),
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return TossDesignSystem.successGreen;
    if (score >= 60) return TossDesignSystem.tossBlue;
    if (score >= 40) return TossDesignSystem.warningOrange;
    return TossDesignSystem.errorRed;
  }
}

class TimeSpecificFortuneList extends StatefulWidget {
  final List<TimeSpecificFortune> fortunes;
  final String? title;

  const TimeSpecificFortuneList({
    super.key,
    required this.fortunes,
    this.title,
  });

  @override
  State<TimeSpecificFortuneList> createState() => _TimeSpecificFortuneListState();
}

class _TimeSpecificFortuneListState extends State<TimeSpecificFortuneList> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.title != null) ...[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.spacing1,
              vertical: AppSpacing.spacing2,
            ),
            child: Text(
              widget.title!,
              style: theme.textTheme.titleLarge,
            ),
          ),
        ],
        ...widget.fortunes.asMap().entries.map((entry) {
          final index = entry.key;
          final fortune = entry.value;
          final isExpanded = expandedIndex == index;
          return TimeSpecificFortuneCard(
            fortune: fortune,
            isExpanded: isExpanded,
            onTap: () {
              setState(() {
                expandedIndex = isExpanded ? null : index;
              });
            },
          );
        }),
      ],
    );
  }
}