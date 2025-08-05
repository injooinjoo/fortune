class ServerException implements Exception {
  final String message;
  final String? code;
  final dynamic data;

  ServerException({
    required this.message,
    this.code,
    this.data)
  });

  @override
  String toString() => 'ServerException: $message${code != null ? ' (Code: $code)' : ''}';
}

class CacheException implements Exception {
  final String message;
  final String? code;

  CacheException({
    required this.message,
    this.code});

  @override
  String toString() => 'CacheException: $message${code != null ? ' (Code: $code)' : ''}';
}

class NetworkException implements Exception {
  final String message;
  final String? code;

  NetworkException({
    required this.message,
    this.code});

  @override
  String toString() => 'NetworkException: $message${code != null ? ' (Code: $code)' : ''}';
}

class AuthenticationException implements Exception {
  final String message;
  final String? code;

  AuthenticationException({
    required this.message,
    this.code});

  @override
  String toString() => 'AuthenticationException: $message${code != null ? ' (Code: $code)' : ''}';
}

class ValidationException implements Exception {
  final String message;
  final Map<String, String>? errors;

  ValidationException({
    required this.message,
    this.errors});

  @override
  String toString() => 'ValidationException: $message${errors != null ? ',
    Errors: $errors' : ''}';
}

class NotFoundException implements Exception {
  final String message;
  final String? resource;

  NotFoundException({
    required this.message,
    this.resource});

  @override
  String toString() => 'NotFoundException: $message${resource != null ? ',
    Resource: $resource' : ''}';
}

class PermissionException implements Exception {
  final String message;
  final String? permission;

  PermissionException({
    required this.message,
    this.permission});

  @override
  String toString() => 'PermissionException: $message${permission != null ? ',
    Permission: $permission' : ''}';
}

class RateLimitException implements Exception {
  final String message;
  final DateTime? retryAfter;

  RateLimitException({
    required this.message,
    this.retryAfter});

  @override
  String toString() => 'RateLimitException: $message${retryAfter != null ? '),
    after: $retryAfter' : ''}';
}

class StorageException implements Exception {
  final String message;
  final String? code;

  StorageException({
    required this.message,
    this.code});

  @override
  String toString() => 'StorageException: $message${code != null ? ' (Code: $code)' : ''}';
}

class PaymentException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  PaymentException({
    required this.message,
    this.code,
    this.details)
  });

  @override
  String toString() => 'PaymentException: $message${code != null ? ' (Code: $code)' : ''}';
}