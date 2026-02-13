import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:fortune/core/errors/failures.dart';
import 'package:fortune/core/usecases/usecase.dart';
import 'package:fortune/domain/repositories/todo_repository.dart';

class ToggleTodoStatusUseCase implements UseCase<void, ToggleTodoStatusParams> {
  final TodoRepository repository;

  ToggleTodoStatusUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(ToggleTodoStatusParams params) async {
    if (params.todoId.isEmpty) {
      return const Left(ValidationFailure('Todo ID cannot be empty'));
    }

    if (params.userId.isEmpty) {
      return const Left(ValidationFailure('User ID cannot be empty'));
    }

    return repository.toggleTodoStatus(
        todoId: params.todoId, userId: params.userId);
  }
}

class ToggleTodoStatusParams extends Equatable {
  final String todoId;
  final String userId;

  const ToggleTodoStatusParams({required this.todoId, required this.userId});

  @override
  List<Object> get props => [todoId, userId];
}
