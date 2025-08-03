import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../error/failures.dart';

/// Base class for all use cases in the application
///
/// Type [Type] is the return type of the use case
/// Type [Params] is the input parameters required by the use case
abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}

/// Base class for use cases that don't require any parameters
abstract class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}

/// Use this class when the use case doesn't require any parameters
class NoParamsImpl extends NoParams {}

/// Base class for stream use cases
abstract class StreamUseCase<Type, Params> {
  Stream<Either<Failure, Type>> call(Params params);
}
