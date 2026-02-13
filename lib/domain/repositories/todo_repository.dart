import 'package:dartz/dartz.dart';
import 'package:fortune/core/errors/failures.dart';
import 'package:fortune/domain/entities/todo.dart';

abstract class TodoRepository {
  Future<Either<Failure, List<Todo>>> getTodos(
      {required String userId,
      TodoStatus? status,
      TodoPriority? priority,
      DateTime? dueBefore,
      DateTime? dueAfter,
      List<String>? tags,
      String? searchQuery,
      int? limit,
      int? offset});

  Future<Either<Failure, Todo>> getTodoById(
      {required String todoId, required String userId});

  Future<Either<Failure, Todo>> createTodo(
      {required String userId,
      required String title,
      String? description,
      required TodoPriority priority,
      DateTime? dueDate,
      List<String>? tags});

  Future<Either<Failure, Todo>> updateTodo(
      {required String todoId,
      required String userId,
      String? title,
      String? description,
      TodoPriority? priority,
      TodoStatus? status,
      DateTime? dueDate,
      List<String>? tags});

  Future<Either<Failure, void>> deleteTodo(
      {required String todoId, required String userId});

  Future<Either<Failure, void>> deleteTodos(
      {required List<String> todoIds, required String userId});

  Future<Either<Failure, List<Todo>>> searchTodos(
      {required String userId, required String query, int? limit});

  Future<Either<Failure, Map<TodoStatus, int>>> getTodoStats(
      {required String userId});

  Future<Either<Failure, void>> toggleTodoStatus(
      {required String todoId, required String userId});

  Stream<Either<Failure, List<Todo>>> watchTodos(
      {required String userId, TodoStatus? status});
}
