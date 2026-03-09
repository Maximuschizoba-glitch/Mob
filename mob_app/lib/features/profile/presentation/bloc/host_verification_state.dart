import 'package:equatable/equatable.dart';

import '../../domain/entities/host_verification.dart';


abstract class HostVerificationState extends Equatable {
  const HostVerificationState();

  @override
  List<Object?> get props => [];
}


class HostVerificationInitial extends HostVerificationState {
  const HostVerificationInitial();
}


class HostVerificationLoading extends HostVerificationState {
  const HostVerificationLoading();
}


class HostVerificationEmpty extends HostVerificationState {
  const HostVerificationEmpty();
}


class HostVerificationLoaded extends HostVerificationState {
  final HostVerification verification;

  const HostVerificationLoaded(this.verification);

  @override
  List<Object?> get props => [verification];
}


class HostVerificationSubmitting extends HostVerificationState {

  final HostVerification? previousVerification;

  const HostVerificationSubmitting({this.previousVerification});

  @override
  List<Object?> get props => [previousVerification];
}


class HostVerificationSubmitted extends HostVerificationState {
  final HostVerification verification;


  final String message;

  const HostVerificationSubmitted(
    this.verification, {
    this.message = 'Verification request submitted successfully',
  });

  @override
  List<Object?> get props => [verification, message];
}


class HostVerificationError extends HostVerificationState {

  final String message;


  final HostVerification? previousVerification;

  const HostVerificationError(
    this.message, {
    this.previousVerification,
  });

  @override
  List<Object?> get props => [message, previousVerification];
}
