import 'package:fortune/core/theme/app_spacing.dart';
import 'package:fortune/core/theme/app_dimensions.dart';
import 'package:flutter/material.dart';
import '../../domain/entities/fortune.dart';
import '../../core/theme/app_theme.dart';
import 'package:fortune/core/theme/app_typography.dart';
import 'package:fortune/core/theme/app_colors.dart';
import 'package:fortune/core/theme/app_animations.dart';

class TimeSpecificFortuneCard extends StatelessWidget {
  final TimeSpecificFortune fortune;
  final VoidCallback? onTap;
  final bool isExpanded;

  const TimeSpecificFortuneCard(
    {
    Key? key,
    required this.fortune,
    this.onTap,
    this.isExpanded = false,
  )}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isExpanded ? 4 : 2),
        margin: EdgeInsets.symmetric(vertica,
      l: AppSpacing.spacing1),
      shape: RoundedRectangleBorder(,
      borderRadius: AppDimensions.borderRadiusMedium),
      child: InkWell(,
      onTap: onTap,
        borderRadius: AppDimensions.borderRadiusMedium,
        child: AnimatedContainer(,
      duration: AppAnimations.durationMedium,
          padding: AppSpacing.paddingAll16,
          decoration: BoxDecoration(,
      borderRadius: AppDimensions.borderRadiusMedium,
            gradient: LinearGradient(,
      begin: Alignment.topLeft,
              end: Alignment.bottomRight,
        ),
        colors: [
                _getScoreColor(fortune.score).withValues(alpha: 0.1),
                _getScoreColor(fortune.score).withValues(alpha: 0.05),
              ])))
          child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(,
      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fortune.time,
              ),
              style: Theme.of(context).textTheme.titleMedium,
                        SizedBox(height: AppSpacing.spacing1),
                        Text(
                          fortune.title,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(,
      color: AppColors.textSecondary)
                      ],
                          )))
                  _buildScoreIndicator(),
                ])
              if (isExpanded) ...[
                SizedBox(height: AppSpacing.spacing3),
                Text(
                  fortune.description),
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(,
      color: AppColors.textPrimary,
                          ),), height: 1.5),
                if (fortune.recommendation != null) ...[
                  SizedBox(height: AppSpacing.spacing2),
                  Container(
                    padding: AppSpacing.paddingAll12),
        decoration: BoxDecoration(,
      color: AppTheme.primaryColor.withValues(alp,
      ha: 0.1),
                      borderRadius: AppDimensions.borderRadiusSmall),
      child: Row(,
      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: AppDimensions.iconSizeSmall,
                          color: AppTheme.primaryColor)
                        SizedBox(width: AppSpacing.spacing2),
                        Expanded(
                          child: Text(
                            fortune.recommendation!,
        ),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(,
      color: AppColors.textPrimary)
                      ],
                          )))
                ]
              ]
            ])))))))
  }

  Widget _buildScoreIndicator() {
    return Container(
      width: 60,
      height: AppSpacing.spacing15,
      decoration: BoxDecoration(,
      shape: BoxShape.circle,
        ),
        color: _getScoreColor(fortune.score).withValues(alph,
      a: 0.2),
        border: Border.all(,
      color: _getScoreColor(fortune.score),
          width: 3)),
      child: Center(,
      child: Column(,
      mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${fortune.score}'),
        style: Theme.of(context).textTheme.headlineMedium,
            Text(
              '점'),
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(colo,
      r: _getScoreColor(fortune.score)
          ])
      )
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.primary;
    if (score >= 40) return AppColors.warning;
    return AppColors.error;
  }
}

// List widget for multiple time-specific fortunes
class TimeSpecificFortuneList extends StatefulWidget {
  final List<TimeSpecificFortune> fortunes;
  final String? title;

  const TimeSpecificFortuneList(
    {
    Key? key,
    required this.fortunes,
    this.title,
  )}) : super(key: key);

  @override
  _TimeSpecificFortuneListState createState() => _TimeSpecificFortuneListState();
}

class _TimeSpecificFortuneListState extends State<TimeSpecificFortuneList> {
  int? expandedIndex;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
                children: [
        if (widget.title != null) ...[
          Padding(
            padding: EdgeInsets.symmetric(horizonta,
      l: AppSpacing.spacing1, vertical: AppSpacing.spacing2),
            child: Text(
              widget.title!),
        style: Theme.of(context).textTheme.titleLarge,
        ]
        ...widget.fortunes.asMap().entries.map((entry) {
          final index = entry.key;
          final fortune = entry.value;
          final isExpanded = expandedIndex == index;

          return TimeSpecificFortuneCard(
            fortune: fortune,
            isExpanded: isExpanded),
        onTap: () {
              setState(() {
                expandedIndex = isExpanded ? null : index;
              });
            })
        }).toList(),
      ]
    );
  }
}