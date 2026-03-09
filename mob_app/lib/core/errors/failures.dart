import 'package:equatable/equatable.dart';


abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}


class ServerFailure extends Failure {
  const ServerFailure(super.message);
}


class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Resource not found']);
}


class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection']);
}


class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication failed']);
}


class ValidationFailure extends Failure {
  final Map<String, dynamic>? errors;

  const ValidationFailure(super.message, {this.errors});


  String? fieldError(String field) {
    final fieldErrors = errors?[field];
    if (fieldErrors is List && fieldErrors.isNotEmpty) {
      return fieldErrors.first.toString();
    }
    return null;
  }

  @override
  List<Object> get props => [message, errors ?? {}];
}


class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error']);
}


class LocationFailure extends Failure {
  const LocationFailure([super.message = 'Location unavailable']);
}
