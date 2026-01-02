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

// Insufficient Tokens Exception (토큰 부족)
class InsufficientTokensException extends AppException {
  final int? required;
  final int? available;
  final String? fortuneType;

  const InsufficientTokensException([
    String message = '복주머니가 부족합니다',
    this.required,
    this.available,
    this.fortuneType,
  ]) : super(message: message, code: 'INSUFFICIENT_TOKENS');

  /// 상세 정보가 포함된 팩토리 생성자
  factory InsufficientTokensException.withDetails({
    required int required,
    required int available,
    required String fortuneType,
    String message = '복주머니가 부족합니다',
  }) {
    return InsufficientTokensException(message, required, available, fortuneType);
  }

  @override
  String toString() => fortuneType != null
      ? 'InsufficientTokensException: $fortuneType 실행에 $required개 필요 (현재: $available개)'
      : 'InsufficientTokensException: $message';
}

// Already Claimed Exception (이미 수령함)
class AlreadyClaimedException extends AppException {
  const AlreadyClaimedException([String message = '이미 수령하셨습니다'])
      : super(message: message, code: 'ALREADY_CLAIMED');
}

// Too Many Requests Exception (요청 과다)
class TooManyRequestsException extends AppException {
  const TooManyRequestsException([String message = '요청이 너무 많습니다'])
      : super(message: message, code: 'TOO_MANY_REQUESTS');
}

// Wish Analysis Exception (소원 분석 오류)
class WishAnalysisException extends AppException {
  final String? missingField;
  final dynamic originalError;

  const WishAnalysisException({
    required super.message,
    String? code,
    this.missingField,
    this.originalError,
  }) : super(code: code ?? 'WISH_ANALYSIS_ERROR');

  @override
  String toString() => missingField != null
      ? 'WishAnalysisException: $message (필드: $missingField)'
      : 'WishAnalysisException: $message';
}
