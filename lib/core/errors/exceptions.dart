// Base Exception Class
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic data;

  const AppException({
    required this.message,
    this.code,
    this.data});

  @override
  String toString() =>
      '$runtimeType: $message${code != null ? ' (Code: $code)' : ''}';
}

// Server Exception
class ServerException extends AppException {
  final int? statusCode;

  const ServerException({
    required super.message,
    this.statusCode,
    super.code,
    super.data});

  @override
  String toString() => 'ServerException: $message (${statusCode ?? 'Unknown'})';
}

class CacheException implements Exception {
  final String message;

  CacheException(this.message);

  @override
  String toString() => 'CacheException: $message';
}

class NetworkException extends AppException {
  const NetworkException(String message, {String? code})
      : super(message: message, code: code ?? 'NETWORK_ERROR');

  @override
  String toString() => 'NetworkException: $message';
}

class TokenException implements Exception {
  final String message;
  final int? remainingTokens;

  TokenException({
    required this.message,
    this.remainingTokens});

  @override
  String toString() => 'TokenException: $message';
}

class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException({
    required this.message,
    this.code});

  @override
  String toString() => 'AuthException: $message';
}

class ValidationException extends AppException {
  final Map<String, dynamic>? errors;

  const ValidationException({
    required super.message,
    this.errors,
    super.code});

  @override
  String toString() => 'ValidationException: $message';
}

// Unauthorized Exception (401)
class UnauthorizedException extends AppException {
  const UnauthorizedException([String message = '인증이 필요합니다'])
      : super(message: message, code: 'UNAUTHORIZED');
}

// Forbidden Exception (403)
class ForbiddenException extends AppException {
  const ForbiddenException([String message = '접근 권한이 없습니다'])
      : super(message: message, code: 'FORBIDDEN');
}

// Not Found Exception (404)
class NotFoundException extends AppException {
  const NotFoundException([String message = '요청한 리소스를 찾을 수 없습니다'])
      : super(message: message, code: 'NOT_FOUND');
}

// Unknown Exception
class UnknownException extends AppException {
  const UnknownException([String message = '알 수 없는 오류가 발생했습니다'])
      : super(message: message, code: 'UNKNOWN');
}
