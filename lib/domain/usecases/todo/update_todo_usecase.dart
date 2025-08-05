import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:fortune/core/error/failures.dart';
import 'package:fortune/core/usecases/usecase.dart';
import 'package:fortune/domain/entities/todo.dart';
import 'package:fortune/domain/repositories/todo_repository.dart';

class UpdateTodoUseCase implements UseCase<Todo, UpdateTodoParams> {
  final TodoRepository repository;

  UpdateTodoUseCase(this.repository);

  @override
  Future<Either<Failure, Todo>> call(UpdateTodoParams params) async {
    // Validate inputs
    if (params.title != null) {
      if (params.title!.trim().isEmpty) {
        return const Left(ValidationFailure('Title cannot be empty'));
      }
      if (params.title!.length > 200) {
        return const Left(ValidationFailure('Title cannot exceed 200 characters'));
      }
    }

    if (params.description != null && params.description!.length > 1000) {
      return const Left(ValidationFailure('Description cannot exceed 1000 characters'));
    }

    if (params.tags != null && params.tags!.length > 10) {
      return const Left(ValidationFailure('Cannot have more than 10 tags'));
    }

    if (params.dueDate != null) {
      // Check if trying to set due date in the past
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final dueDay = DateTime(
        params.dueDate!.year,
        params.dueDate!.month,
        params.dueDate!.day);
      
      if (dueDay.isBefore(today)) {
        return const Left(ValidationFailure('Due date cannot be in the past'));
      }
    }

    return repository.updateTodo(
      todoId: params.todoId,
      userId: params.userId,
      title: params.title?.trim(),
      description: params.description?.trim(),
      priority: params.priority,
      status: params.status,
      dueDate: params.dueDate,
      tags: params.tags?.where((tag) => tag.trim().isNotEmpty).toList());
  }
}

class UpdateTodoParams extends Equatable {
  final String todoId;
  final String userId;
  final String? title;
  final String? description;
  final TodoPriority? priority;
  final TodoStatus? status;
  final DateTime? dueDate;
  final List<String>? tags;

  const UpdateTodoParams({
    required this.todoId,
    required this.userId,
    this.title,
    this.description,
    this.priority,
    this.status,
    this.dueDate,
    this.tags});

  @override
  List<Object?> get props => [
        todoId,
        userId,
        title,
        description,
        priority,
        status,
        dueDate,
        tags];
}