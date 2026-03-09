import 'package:equatable/equatable.dart';

import '../../../auth/domain/entities/user.dart';
import '../../../feed/domain/entities/happening.dart';


abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}


class ProfileInitial extends ProfileState {
  const ProfileInitial();
}


class ProfileLoading extends ProfileState {
  const ProfileLoading();
}


class ProfileLoaded extends ProfileState {
  final User user;
  final List<Happening> happenings;

  const ProfileLoaded(this.user, {this.happenings = const []});

  @override
  List<Object?> get props => [user, happenings];
}


class ProfileUpdating extends ProfileState {

  final User user;
  final List<Happening> happenings;

  const ProfileUpdating(this.user, {this.happenings = const []});

  @override
  List<Object?> get props => [user, happenings];
}


class ProfileUpdateSuccess extends ProfileState {

  final User user;


  final String? message;

  final List<Happening> happenings;

  const ProfileUpdateSuccess(
    this.user, {
    this.message,
    this.happenings = const [],
  });

  @override
  List<Object?> get props => [user, message, happenings];
}


class ProfileError extends ProfileState {

  final String message;


  final User? previousUser;
  final List<Happening> happenings;

  const ProfileError(
    this.message, {
    this.previousUser,
    this.happenings = const [],
  });

  @override
  List<Object?> get props => [message, previousUser, happenings];
}
