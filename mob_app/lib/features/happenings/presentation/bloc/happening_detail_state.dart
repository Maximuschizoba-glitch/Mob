import 'package:equatable/equatable.dart';

import '../../../feed/domain/entities/happening.dart';
import '../../../snaps/domain/entities/snap.dart';


abstract class HappeningDetailState extends Equatable {
  const HappeningDetailState();

  @override
  List<Object?> get props => [];
}


class HappeningDetailInitial extends HappeningDetailState {
  const HappeningDetailInitial();
}


class HappeningDetailLoading extends HappeningDetailState {
  const HappeningDetailLoading();
}


class HappeningDetailLoaded extends HappeningDetailState {
  final Happening happening;
  final List<Snap> snaps;
  final bool isSnapsLoading;

  const HappeningDetailLoaded(
    this.happening, {
    this.snaps = const [],
    this.isSnapsLoading = false,
  });

  HappeningDetailLoaded copyWith({
    Happening? happening,
    List<Snap>? snaps,
    bool? isSnapsLoading,
  }) {
    return HappeningDetailLoaded(
      happening ?? this.happening,
      snaps: snaps ?? this.snaps,
      isSnapsLoading: isSnapsLoading ?? this.isSnapsLoading,
    );
  }

  @override
  List<Object?> get props => [happening, snaps, isSnapsLoading];
}


class HappeningDetailError extends HappeningDetailState {
  final String message;

  const HappeningDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
