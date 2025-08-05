import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:fortune/core/error/failures.dart';
import 'package:fortune/core/usecases/usecase.dart';
import 'package:fortune/domain/repositories/todo_repository.dart';

class DeleteTodoUseCase implements UseCase<void, DeleteTodoParams> {
  final TodoRepository repository;

  DeleteTodoUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(DeleteTodoParams params) async {
    if (params.todoId.isEmpty) {
      return const Left(ValidationFailure('Todo ID cannot be empty'));
    }

    if (params.userId.isEmpty) {
      return const Left(ValidationFailure('User ID cannot be empty'));
    }

    return repository.deleteTodo(
      todoId: params.todoId,
      userId: params.userId);
  }
}

class DeleteTodoParams extends Equatable {
  final String todoId;
  final String userId;

  const DeleteTodoParams({
    required this.todoId,
    required this.userId});

  @override
  List<Object> get props => [todoId, userId];
}