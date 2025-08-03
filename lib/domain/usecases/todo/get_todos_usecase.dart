import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:fortune/core/error/failures.dart';
import 'package:fortune/core/usecases/usecase.dart';
import 'package:fortune/domain/entities/todo.dart';
import 'package:fortune/domain/repositories/todo_repository.dart';

class GetTodosUseCase implements UseCase<List<Todo>, GetTodosParams> {
  final TodoRepository repository;

  GetTodosUseCase(this.repository);

  @override
  Future<Either<Failure, List<Todo>>> call(GetTodosParams params) async {
    // Validate pagination parameters
    if (params.limit != null && params.limit! <= 0) {
      return const Left(ValidationFailure('Limit must be greater than 0'));
    }

    if (params.offset != null && params.offset! < 0) {
      return const Left(ValidationFailure('Offset cannot be negative'));
    }

    if (params.searchQuery != null && params.searchQuery!.length > 100) {
      return const Left(ValidationFailure('Search query too long'));
    }

    return repository.getTodos(
      userId: params.userId,
      status: params.status,
      priority: params.priority,
      dueBefore: params.dueBefore,
      dueAfter: params.dueAfter,
      tags: params.tags,
      searchQuery: params.searchQuery,
      limit: params.limit,
      offset: params.offset,
    );
  }
}

class GetTodosParams extends Equatable {
  final String userId;
  final TodoStatus? status;
  final TodoPriority? priority;
  final DateTime? dueBefore;
  final DateTime? dueAfter;
  final List<String>? tags;
  final String? searchQuery;
  final int? limit;
  final int? offset;

  const GetTodosParams({
    required this.userId,
    this.status,
    this.priority,
    this.dueBefore,
    this.dueAfter,
    this.tags,
    this.searchQuery,
    this.limit = 50,
    this.offset = 0,
  });

  @override
  List<Object?> get props => [
        userId,
        status,
        priority,
        dueBefore,
        dueAfter,
        tags,
        searchQuery,
        limit,
        offset,
      ];
}