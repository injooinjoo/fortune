import 'package:fortune/domain/entities/todo.dart';

class TodoModel extends Todo {
  const TodoModel({
    required super.id,
    required super.userId,
    required super.title,
    super.description,
    required super.priority,
    required super.status,
    super.dueDate,
    required super.tags,
    required super.createdAt,
    required super.updatedAt,
    super.isDeleted,
  });

  factory TodoModel.fromJson(Map<String, dynamic> json) {
    // Validate and sanitize input data for security
    final title = _sanitizeString(json['title'] as String? ?? '');
    final description = json['description'] != null
        ? _sanitizeString(json['description'] as String)
        : null;

    if (title.isEmpty) {
      throw ArgumentError('Todo title cannot be empty');
    }

    if (title.length > 200) {
      throw ArgumentError('Todo title cannot exceed 200 characters');
    }

    if (description != null && description.length > 1000) {
      throw ArgumentError('Todo description cannot exceed 1000 characters');
    }

    return TodoModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: title,
      description: description,
      priority: _parsePriority(json['priority'] as String? ?? 'medium'),
      status: parseStatus(json['status'] as String? ?? 'pending'),
      dueDate: json['due_date'] != null
          ? DateTime.parse(json['due_date'] as String)
          : null,
      tags: _parseTags(json['tags']),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      isDeleted: json['is_deleted'] as bool? ?? false
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': _sanitizeString(title),
      'description': description != null ? _sanitizeString(description!) : null,
      'priority': priority.name,
      'status': status.name,
      'due_date': dueDate?.toIso8601String(),
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'is_deleted': isDeleted,
    };
  }

  factory TodoModel.fromEntity(Todo todo) {
    return TodoModel(
      id: todo.id,
      userId: todo.userId,
      title: todo.title,
      description: todo.description,
      priority: todo.priority,
      status: todo.status,
      dueDate: todo.dueDate,
      tags: todo.tags,
      createdAt: todo.createdAt,
      updatedAt: todo.updatedAt,
      isDeleted: todo.isDeleted,
    );
  }

  static TodoPriority _parsePriority(String priority) {
    switch (priority.toLowerCase()) {
      case 'high':
        return TodoPriority.high;
      case 'low':
        return TodoPriority.low;
      case 'medium':
      default:
        return TodoPriority.medium;
    }
  }

  static TodoStatus parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'in_progress':
      case 'inprogress':
        return TodoStatus.inProgress;
      case 'completed':
        return TodoStatus.completed;
      case 'pending':
      default:
        return TodoStatus.pending;
    }
  }

  static List<String> _parseTags(dynamic tags) {
    if (tags == null) return [];
    if (tags is List) {
      return tags
          .where((tag) => tag is String && tag.isNotEmpty)
          .map((tag) => _sanitizeString(tag as String))
          .where((tag) => tag.length <= 50) // Limit tag length
          .take(10) // Limit number of tags
          .toList();
    }
    return [];
  }

  static String _sanitizeString(String input) {
    // Remove potentially dangerous characters and limit length
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('"', '')
        .replaceAll("'", '')
        .replaceAll('&', '')
        .trim();
  }
}