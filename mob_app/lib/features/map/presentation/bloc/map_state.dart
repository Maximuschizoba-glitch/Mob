import 'package:equatable/equatable.dart';

import '../../../feed/domain/entities/happening.dart';


abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}


class MapInitial extends MapState {
  const MapInitial();
}


class MapLoading extends MapState {
  const MapLoading();
}


class MapLoaded extends MapState {

  final List<Happening> happenings;


  final String? activeCategory;

  const MapLoaded({
    required this.happenings,
    this.activeCategory,
  });

  @override
  List<Object?> get props => [happenings, activeCategory];
}


class MapError extends MapState {

  final String message;

  const MapError(this.message);

  @override
  List<Object?> get props => [message];
}
