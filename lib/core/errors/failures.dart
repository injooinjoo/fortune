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
  const ServerFailure(String message, {String? code})
      : super(message, code: code);
}

class CacheFailure extends Failure {
  const CacheFailure(String message, {String? code})
      : super(message, code: code);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message, {String? code})
      : super(message, code: code);
}

// Authentication failures
class AuthenticationFailure extends Failure {
  const AuthenticationFailure(String message, {String? code})
      : super(message, code: code);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(String message, {String? code})
      : super(message, code: code);
}

// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure(String message, {String? code})
      : super(message, code: code);
}

// Resource failures
class NotFoundFailure extends Failure {
  const NotFoundFailure(String message, {String? code})
      : super(message, code: code);
}

class ConflictFailure extends Failure {
  const ConflictFailure(String message, {String? code})
      : super(message, code: code);
}

// Permission failures
class PermissionFailure extends Failure {
  const PermissionFailure(String message, {String? code})
      : super(message, code: code);
}

// Rate limiting failures
class RateLimitFailure extends Failure {
  final DateTime? retryAfter;

  const RateLimitFailure(String message, {String? code, this.retryAfter})
      : super(message, code: code);

  @override
  List<Object?> get props => [message, code, retryAfter];
}

// Storage failures
class StorageFailure extends Failure {
  const StorageFailure(String message, {String? code})
      : super(message, code: code);
}

// Payment failures
class PaymentFailure extends Failure {
  const PaymentFailure(String message, {String? code})
      : super(message, code: code);
}

// General unexpected failure
class UnexpectedFailure extends Failure {
  const UnexpectedFailure(String message, {String? code})
      : super(message, code: code);
}
