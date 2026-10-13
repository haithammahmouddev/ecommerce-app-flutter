
class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}

class ServerException extends AppException {
  ServerException(super.message);
}

class AuthException extends AppException {
  final String? code;

  AuthException(super.message, {this.code});
}

class NetworkException extends AppException {
  NetworkException(super.message);
}