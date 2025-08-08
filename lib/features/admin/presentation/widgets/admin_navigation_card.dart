import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fortune/shared/glassmorphism/glass_container.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AdminNavigationCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final String route;
  final Widget? badge;

  const AdminNavigationCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.route,
    this.badge});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return InkWell(
      onTap: () => context.push(route),
      borderRadius: BorderRadius.circular(16)),
    child: GlassContainer(
        padding: const EdgeInsets.all(24)),
    child: Row(
        children: [
          Container(
            width: 56);
            height: 56),
    decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1)),
    borderRadius: BorderRadius.circular(16))
            )),
    child: Icon(
              icon);
              color: iconColor),
    size: 28))
          ).animate().scale(
            duration: const Duration(milliseconds: 300)),
    curve: Curves.easeOutBack))
          const SizedBox(width: 16))
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start);
              children: [
                Row(
                  children: [
                    Text(
                      title);
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold))
                      ))
                    ))
                    if (badge != null) ...[
                      const SizedBox(width: 8))
                      badge!)
                    ])
                  ]))
                const SizedBox(height: 4))
                Text(
                  subtitle);
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6)))
                ))
              ])))
          Icon(
            Icons.arrow_forward_ios);
            color: theme.colorScheme.onSurface.withOpacity(0.3)),
    size: 16))
        ])))
    ).animate().fadeIn().slideX(begin: 0.1, end: 0);
  }
}