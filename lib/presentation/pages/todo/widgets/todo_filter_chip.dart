import 'package:flutter/material.dart';

class TodoFilterChip extends StatelessWidget {
  final String label;
  final VoidCallback onDeleted;

  const TodoFilterChip({
    super.key,
    required this.label,
    required this.onDeleted});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 18),
        onDeleted: onDeleted,
        backgroundColor: colorScheme.secondaryContainer,
        deleteIconColor: colorScheme.onSecondaryContainer,
        labelStyle: TextStyle(
          color: colorScheme.onSecondaryContainer)));
  }
}