import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fortune/domain/entities/todo.dart';
import 'package:fortune/presentation/providers/todo_provider.dart';

class TodoStatsCard extends ConsumerWidget {
  const TodoStatsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final statsAsync = ref.watch(todoStatsProvider);

    return Card(
      elevation: 0,
      color: colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: statsAsync.when(
          data: (stats) => Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                icon: Icons.pending_actions,
                label: '대기중',
                count: stats[TodoStatus.pending] ?? 0,
                color: colorScheme.onPrimaryContainer),
              _buildDivider(colorScheme),
              _buildStatItem(
                context,
                icon: Icons.play_circle_outline,
                label: '진행중',
                count: stats[TodoStatus.inProgress] ?? 0,
                color: colorScheme.tertiary),
              _buildDivider(colorScheme),
              _buildStatItem(
                context,
                icon: Icons.check_circle_outline,
                label: '완료',
                count: stats[TodoStatus.completed] ?? 0,
                color: colorScheme.primary)]),
          loading: () => const Center(
            child: CircularProgressIndicator()),
          error: (_, __) => const Center(
            child: Text('통계를 불러올 수 없습니다')))));
  }

  Widget _buildStatItem(
    BuildContext context,
    {
      required IconData icon,
      required String label,
      required int count,
      required Color color}
  ) {
    final theme = Theme.of(context);
    
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: color),
        const SizedBox(height: 8),
        Text(
          count.toString(),
          style: theme.textTheme.headlineMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: color.withValues(alpha: 0.7)))]);
  }

  Widget _buildDivider(ColorScheme colorScheme) {
    return Container(
      height: 50,
      width: 1,
      color: colorScheme.onPrimaryContainer.withValues(alpha: 0.2));
  }
}