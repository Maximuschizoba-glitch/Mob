import 'package:equatable/equatable.dart';

import '../../domain/entities/snap.dart';


sealed class SnapsState extends Equatable {
  const SnapsState();

  @override
  List<Object?> get props => [];
}


class SnapsInitial extends SnapsState {}


class SnapsLoading extends SnapsState {}


class SnapsLoaded extends SnapsState {
  final List<Snap> snaps;
  final int currentIndex;

  const SnapsLoaded({
    required this.snaps,
    this.currentIndex = 0,
  });

  @override
  List<Object?> get props => [snaps, currentIndex];
}


class SnapsEmpty extends SnapsState {}


class SnapsError extends SnapsState {
  final String message;

  const SnapsError(this.message);

  @override
  List<Object?> get props => [message];
}


class SnapUploading extends SnapsState {
  final double progress;

  const SnapUploading({this.progress = 0.0});

  @override
  List<Object?> get props => [progress];
}


class SnapUploaded extends SnapsState {
  final Snap snap;

  const SnapUploaded(this.snap);

  @override
  List<Object?> get props => [snap];
}
