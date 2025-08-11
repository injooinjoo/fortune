import 'package:dartz/dartz.dart';
import 'package:fortune/core/error/failures.dart';
import 'package:fortune/data/models/todo_model.dart';
import 'package:fortune/domain/entities/todo.dart';
import 'package:fortune/domain/repositories/todo_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

class TodoRepositoryImpl implements TodoRepository {
  final SupabaseClient supabase;
  final Uuid uuid = const Uuid();
  
  static const String _tableName = 'todos';
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 1);

  TodoRepositoryImpl({required this.supabase});

  @override
  Future<Either<Failure, List<Todo>>> getTodos({
    required String userId,
    TodoStatus? status,
    TodoPriority? priority,
    DateTime? dueBefore,
    DateTime? dueAfter,
    List<String>? tags,
    String? searchQuery,
    int? limit,
    int? offset}) async {
    try {
      // Validate userId
      if (userId.isEmpty || !_isValidUuid(userId)) {
        return const Left(ValidationFailure('Invalid user ID'));
      }

      final queryBuilder = supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('is_deleted', false);

      dynamic query = queryBuilder;

      if (status != null) {
        query = query.eq('status', status.name);
      }

      if (priority != null) {
        query = query.eq('priority', priority.name);
      }

      if (dueBefore != null) {
        query = query.lte('due_date', dueBefore.toIso8601String());
      }

      if (dueAfter != null) {
        query = query.gte('due_date', dueAfter.toIso8601String());
      }

      if (tags != null && tags.isNotEmpty) {
        query = query.contains('tags', tags);
      }

      if (searchQuery != null && searchQuery.isNotEmpty) {
        final sanitizedQuery = _sanitizeSearchQuery(searchQuery);
        query = query.textSearch('title', sanitizedQuery);
      }

      query = query.order('created_at', ascending: false);

      if (limit != null) {
        query = query.limit(limit);
      }

      if (offset != null) {
        query = query.range(offset, offset + (limit ?? 10) - 1);
      }

      final response = await _executeWithRetry(() => query);
      
      final todos = (response as List)
          .map((json) => TodoModel.fromJson(json))
          .toList();

      return Right(todos);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Todo>> getTodoById({
    required String todoId,
    required String userId}) async {
    try {
      if (!_isValidUuid(todoId) || !_isValidUuid(userId)) {
        return const Left(ValidationFailure('Invalid ID format'));
      }

      final response = await _executeWithRetry(() => supabase
          .from(_tableName)
          .select()
          .eq('id', todoId)
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .single());

      final todo = TodoModel.fromJson(response);
      return Right(todo);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return const Left(NotFoundFailure('Todo not found'));
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Todo>> createTodo({
    required String userId,
    required String title,
    String? description,
    required TodoPriority priority,
    DateTime? dueDate,
    List<String>? tags}) async {
    try {
      // Validate inputs
      if (!_isValidUuid(userId)) {
        return const Left(ValidationFailure('Invalid user ID'));
      }

      if (title.isEmpty || title.length > 200) {
        return const Left(ValidationFailure('Title must be between 1-200 characters'));
      }

      if (description != null && description.length > 1000) {
        return const Left(ValidationFailure('Description must be less than 1000 characters'));
      }

      final todoId = uuid.v4();
      final now = DateTime.now();

      final todoData = {
        'id': todoId,
        'user_id': userId,
        'title': _sanitizeInput(title),
        'description': description != null ? _sanitizeInput(description) : null,
        'priority': priority.name,
        'status': TodoStatus.pending.name,
        'due_date': dueDate?.toIso8601String(),
        'tags': tags?.map(_sanitizeInput).take(10).toList() ?? [],
        'created_at': now.toIso8601String(),
        'updated_at': DateTime.now().toIso8601String()};

      final response = await _executeWithRetry(() => supabase
          .from(_tableName)
          .insert(todoData)
          .select()
          .single());

      final todo = TodoModel.fromJson(response);
      return Right(todo);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Todo>> updateTodo({
    required String todoId,
    required String userId,
    String? title,
    String? description,
    TodoPriority? priority,
    TodoStatus? status,
    DateTime? dueDate,
    List<String>? tags}) async {
    try {
      if (!_isValidUuid(todoId) || !_isValidUuid(userId)) {
        return const Left(ValidationFailure('Invalid ID format'));
      }

      final updates = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String()};

      if (title != null) {
        if (title.isEmpty || title.length > 200) {
          return const Left(ValidationFailure('Title must be between 1-200 characters'));
        }
        updates['title'] = _sanitizeInput(title);
      }

      if (description != null) {
        if (description.length > 1000) {
          return const Left(ValidationFailure('Description must be less than 1000 characters'));
        }
        updates['description'] = _sanitizeInput(description);
      }

      if (priority != null) {
        updates['priority'] = priority.name;
      }

      if (status != null) {
        updates['status'] = status.name;
      }

      if (dueDate != null) {
        updates['due_date'] = dueDate.toIso8601String();
      }

      if (tags != null) {
        updates['tags'] = tags.map(_sanitizeInput).take(10).toList();
      }

      final response = await _executeWithRetry(() => supabase
          .from(_tableName)
          .update(updates)
          .eq('id', todoId)
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .select()
          .single());

      final todo = TodoModel.fromJson(response);
      return Right(todo);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        return const Left(NotFoundFailure('Todo not found'));
      }
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTodo({
    required String todoId,
    required String userId}) async {
    try {
      if (!_isValidUuid(todoId) || !_isValidUuid(userId)) {
        return const Left(ValidationFailure('Invalid ID format'));
      }

      // Soft delete
      await _executeWithRetry(() => supabase
          .from(_tableName)
          .update({
            'is_deleted': true,
            'updated_at': DateTime.now().toIso8601String()})
          .eq('id', todoId)
          .eq('user_id', userId));

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTodos({
    required List<String> todoIds,
    required String userId}) async {
    try {
      if (!_isValidUuid(userId)) {
        return const Left(ValidationFailure('Invalid user ID'));
      }

      if (todoIds.isEmpty) {
        return const Right(null);
      }

      // Validate all todo IDs
      for (final id in todoIds) {
        if (!_isValidUuid(id)) {
          return const Left(ValidationFailure('Invalid todo ID format'));
        }
      }

      // Soft delete multiple
      await _executeWithRetry(() => supabase
          .from(_tableName)
          .update({
            'is_deleted': true,
            'updated_at': DateTime.now().toIso8601String()})
          .eq('user_id', userId)
          .filter('id', 'in', '(${todoIds.join(',')})'));

      return const Right(null);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<Todo>>> searchTodos({
    required String userId,
    required String query,
    int? limit}) async {
    try {
      if (!_isValidUuid(userId)) {
        return const Left(ValidationFailure('Invalid user ID'));
      }

      final sanitizedQuery = _sanitizeSearchQuery(query);
      if (sanitizedQuery.isEmpty) {
        return const Right([]);
      }

      final response = await _executeWithRetry(() => supabase
          .from(_tableName)
          .select()
          .eq('user_id', userId)
          .eq('is_deleted', false)
          .textSearch('title', sanitizedQuery)
          .order('created_at', ascending: false)
          .limit(limit ?? 20));

      final todos = (response as List)
          .map((json) => TodoModel.fromJson(json))
          .toList();

      return Right(todos);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Map<TodoStatus, int>>> getTodoStats({
    required String userId}) async {
    try {
      if (!_isValidUuid(userId)) {
        return const Left(ValidationFailure('Invalid user ID'));
      }

      final response = await _executeWithRetry(() => 
          supabase.rpc('get_todo_stats', params: {'p_user_id': userId}));

      final stats = <TodoStatus, int>{};
      for (final row in response as List) {
        final status = TodoModel.parseStatus(row['status'] as String);
        stats[status] = row['count'] as int;
      }

      // Ensure all statuses are present
      for (final status in TodoStatus.values) {
        stats[status] ??= 0;
      }

      return Right(stats);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleTodoStatus({
    required String todoId,
    required String userId}) async {
    try {
      if (!_isValidUuid(todoId) || !_isValidUuid(userId)) {
        return const Left(ValidationFailure('Invalid ID format'));
      }

      // First get the current todo
      final todoResult = await getTodoById(todoId: todoId, userId: userId);
      
      return todoResult.fold(
        (failure) => Left(failure),
        (todo) async {
          final newStatus = todo.status == TodoStatus.completed
              ? TodoStatus.pending
              : TodoStatus.completed;

          final updateResult = await updateTodo(
            todoId: todoId,
            userId: userId,
            status: newStatus);

          return updateResult.fold(
            (failure) => Left(failure),
            (_) => const Right(null));
        }
      );
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Stream<Either<Failure, List<Todo>>> watchTodos({
    required String userId,
    TodoStatus? status}) {
    try {
      if (!_isValidUuid(userId)) {
        return Stream.value(const Left(ValidationFailure('Invalid user ID')));
      }

      // Stream all todos for the user and filter in memory
      return supabase
          .from(_tableName)
          .stream(primaryKey: ['id'])
          .map((data) {
        try {
          // Filter the data in memory
          var filteredData = data.where((item) => 
            item['user_id'] == userId && 
            item['is_deleted'] == false
          ).toList();
          
          // Apply status filter if provided
          if (status != null) {
            filteredData = filteredData.where((item) => 
              item['status'] == status.name
            ).toList();
          }
          
          final todos = filteredData
              .map((json) => TodoModel.fromJson(json))
              .toList();
          return Right<Failure, List<Todo>>(todos);
        } catch (e) {
          return Left<Failure, List<Todo>>(ServerFailure(e.toString()));
        }
      });
    } catch (e) {
      return Stream.value(Left(ServerFailure(e.toString()));
    }
  }

  // Helper methods
  bool _isValidUuid(String value) {
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$'
    );
    return uuidRegex.hasMatch(value);
  }

  String _sanitizeInput(String input) {
    return input
        .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
        .replaceAll('<', '')
        .replaceAll('>', '')
        .replaceAll('"', '')
        .replaceAll("'", '')
        .replaceAll('&', '')
        .trim();
  }

  String _sanitizeSearchQuery(String query) {
    // Remove SQL injection attempts and special characters
    return query
        .replaceAll(';', '')
        .replaceAll("'", '')
        .replaceAll('"', '')
        .replaceAll('\\', '')
        .replaceAll(RegExp(r'\b(DROP|DELETE|INSERT|UPDATE|ALTER|CREATE)\b', caseSensitive: false), '')
        .trim();
  }

  Future<dynamic> _executeWithRetry(Future<dynamic> Function() operation) async {
    int attempts = 0;
    
    while (attempts < _maxRetries) {
      try {
        return await operation();
      } on PostgrestException catch (e) {
        attempts++;
        if (attempts >= _maxRetries || !_isRetryableError(e)) {
          rethrow;
        }
        await Future.delayed(_retryDelay * attempts);
      }
    }
    
    throw Exception('Max retry attempts reached');
  }

  bool _isRetryableError(PostgrestException error) {
    // Retry on network errors or temporary database issues
    return error.code == 'PGRST301' || // Network error
           error.code == 'PGRST000' || // Unknown error
           error.message.contains('timeout') ||
           error.message.contains('connection');
  }
}