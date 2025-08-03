import 'package:flutter/material.dart';
import 'package:fortune/domain/entities/todo.dart';
import 'package:intl/intl.dart';

class TodoListItem extends StatelessWidget {
  final Todo todo;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const TodoListItem({
    super.key,
    required this.todo,
    required this.onToggle,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isCompleted = todo.status == TodoStatus.completed;
    final dateFormat = DateFormat('MM/dd');

    return Dismissible(
      key: ValueKey(todo.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        color: colorScheme.error,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        // Show confirmation dialog
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('할 일 삭제'),
            content: const Text('이 할 일을 삭제하시겠습니까?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.error,
                ),
                child: const Text('삭제'),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) => onDelete(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: colorScheme.outlineVariant,
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // Checkbox
              InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.circular(20),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Icon(
                    isCompleted
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: isCompleted
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and priority
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            todo.title,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              decoration: isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: isCompleted
                                  ? colorScheme.onSurfaceVariant
                                  : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (todo.priority == TodoPriority.high)
                          _buildPriorityBadge(context, todo.priority),
                      ],
                    ),

                    // Description
                    if (todo.description != null &&
                        todo.description!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        todo.description!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],

                    // Tags and due date
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        // Tags
                        if (todo.tags.isNotEmpty) ...[
                          Icon(
                            Icons.label_outline,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            todo.tags.take(2).join(': ',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          if (todo.tags.length > 2)
                            Text(
                              ' +${todo.tags.length - 2}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          const SizedBox(width: 12),
                        ],

                        // Due date
                        if (todo.dueDate != null) ...[
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: _getDueDateColor(context, todo),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _getDueDateText(todo, dateFormat),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _getDueDateColor(context, todo),
                              fontWeight: todo.isOverdue && !isCompleted
                                  ? FontWeight.bold
                                  : null,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriorityBadge(BuildContext context, TodoPriority priority) {
    final colorScheme = Theme.of(context).colorScheme;
    Color color;
    String label;

    switch (priority) {
      case TodoPriority.high:
        color = colorScheme.error;
        label = '높음';
        break;
      case TodoPriority.medium:
        color = colorScheme.primary;
        label = '중간';
        break;
      case TodoPriority.low:
        color = colorScheme.onSurfaceVariant;
        label = '낮음';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      margin: const EdgeInsets.only(left: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Color _getDueDateColor(BuildContext context, Todo todo) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (todo.status == TodoStatus.completed) {
      return colorScheme.onSurfaceVariant;
    }

    if (todo.isOverdue) {
      return colorScheme.error;
    }

    if (todo.isDueToday) {
      return colorScheme.primary;
    }

    if (todo.isDueTomorrow) {
      return colorScheme.tertiary;
    }

    return colorScheme.onSurfaceVariant;
  }

  String _getDueDateText(Todo todo, DateFormat dateFormat) {
    if (todo.isDueToday) {
      return '오늘';
    }

    if (todo.isDueTomorrow) {
      return '내일';
    }

    if (todo.isOverdue) {
      final daysOverdue = DateTime.now().difference(todo.dueDate!).inDays;
      return '${daysOverdue}일 지남';
    }

    return dateFormat.format(todo.dueDate!);
  }
}