import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  List<Object?> get props => [message, code];
}

// General failures
class ServerFailure extends Failure {
  const ServerFailure(super.message, {super.code});
}

class CacheFailure extends Failure {
  const CacheFailure(super.message, {super.code});
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message, {super.code});
}

// Authentication failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(super.message, {super.code});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(super.message, {super.code});
}

// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, {super.code});
}

// Resource failures
class NotFoundFailure extends Failure {
  const NotFoundFailure(super.message, {super.code});
}

class ConflictFailure extends Failure {
  const ConflictFailure(super.message, {super.code});
}

// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure(super.message, {super.code});
}

// Rate limiting failures
class RateLimitFailure extends Failure {
  final DateTime? retryAfter;

  const RateLimitFailure(super.message, {super.code, this.retryAfter});

  @override
  List<Object?> get props => [message, code, retryAfter];
}

// Storage failures
class StorageFailure extends Failure {
  const StorageFailure(super.message, {super.code});
}

// Payment failures
class PaymentFailure extends Failure {
  const PaymentFailure(super.message, {super.code});
}

// General unexpected failure
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(super.message, {super.code});
}
