import 'package:equatable/equatable.dart';

import '../../domain/entities/user.dart';


abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}


class AuthInitial extends AuthState {
  const AuthInitial();
}


class AuthLoading extends AuthState {
  const AuthLoading();
}


class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}


class Unauthenticated extends AuthState {
  const Unauthenticated();
}


class GuestMode extends AuthState {
  const GuestMode();
}


class AuthError extends AuthState {
  final String message;
  final Map<String, dynamic>? validationErrors;

  const AuthError({
    required this.message,
    this.validationErrors,
  });


  String? fieldError(String field) {
    final fieldErrors = validationErrors?[field];
    if (fieldErrors is List && fieldErrors.isNotEmpty) {
      return fieldErrors.first.toString();
    }
    return null;
  }


  bool get hasValidationErrors =>
      validationErrors != null && validationErrors!.isNotEmpty;

  @override
  List<Object?> get props => [message, validationErrors];
}


class OtpSent extends AuthState {
  final String phone;

  const OtpSent({required this.phone});

  @override
  List<Object?> get props => [phone];
}


class OtpVerified extends AuthState {
  final User user;

  const OtpVerified({required this.user});

  @override
  List<Object?> get props => [user];
}


class EmailVerificationSent extends AuthState {
  const EmailVerificationSent();
}
