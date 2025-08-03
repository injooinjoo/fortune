import 'package:equatable/equatable.dart';

enum TodoPriority {
  
  high, medium, low
  
}

enum TodoStatus {
  
  pending, inProgress, completed
  
}

class Todo extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final TodoPriority priority;
  final TodoStatus status;
  final DateTime? dueDate;
  final List<String> tags;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isDeleted;

  const Todo({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.priority,
    required this.status,
    this.dueDate,
    required this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
  });

  Todo copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    TodoPriority? priority,
    TodoStatus? status,
    DateTime? dueDate,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Todo(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      dueDate: dueDate ?? this.dueDate,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }

  bool get isOverdue {
    if (dueDate == null) return false;
    return dueDate!.isBefore(DateTime.now()) && status != TodoStatus.completed;
  }

  bool get isDueToday {
    if (dueDate == null) return false;
    final now = DateTime.now();
    return dueDate!.year == now.year &&
        dueDate!.month == now.month &&
        dueDate!.day == now.day;
  }

  bool get isDueTomorrow {
    if (dueDate == null) return false;
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return dueDate!.year == tomorrow.year &&
        dueDate!.month == tomorrow.month &&
        dueDate!.day == tomorrow.day;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        priority,
        status,
        dueDate,
        tags,
        createdAt,
        updatedAt,
        isDeleted,
      ];
}