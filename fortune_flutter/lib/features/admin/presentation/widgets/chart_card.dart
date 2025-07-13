import 'package:flutter/material.dart';
import 'package:fortune/shared/glassmorphism/glass_container.dart';

class ChartCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget chart;
  final Widget? action;
  final double? height;
  final EdgeInsets? padding;

  const ChartCard({
    super.key,
    required this.title,
    required this.chart,
    this.subtitle,
    this.action,
    this.height,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GlassContainer(
      padding: padding ?? const EdgeInsets.all(20),
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
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (action != null) action!,
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: height ?? 300,
            child: chart,
          ),
        ],
      ),
    );
  }
}