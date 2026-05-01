class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => 'AppException: $message';
}

class AuthException extends AppException {
  const AuthException(super.message);
}

class NetworkException extends AppException {
  const NetworkException(super.message);
}

class ServerException extends AppException {
  final int? statusCode;
  const ServerException(super.message, {this.statusCode});
}

class CacheException extends AppException {
  const CacheException(super.message);
}

class NotFoundException extends AppException {
  const NotFoundException(super.message);
}
