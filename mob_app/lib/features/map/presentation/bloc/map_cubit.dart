import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/location_service.dart';
import '../../domain/repositories/map_repository.dart';
import 'map_state.dart';


class MapCubit extends Cubit<MapState> {
  MapCubit({
    required MapRepository mapRepository,
    required LocationService locationService,
  })  : _mapRepository = mapRepository,
        _locationService = locationService,
        super(const MapInitial());

  final MapRepository _mapRepository;
  final LocationService _locationService;


  String? _activeCategory;


  Timer? _debounceTimer;


  Future<void> loadMap() async {
    emit(const MapLoading());

    final position = await _locationService.getPositionOrDefault();


    const delta = 0.045;
    await fetchHappeningsInViewport(
      neLat: position.lat + delta,
      neLng: position.lng + delta,
      swLat: position.lat - delta,
      swLng: position.lng - delta,
    );
  }


  void onCameraMove({
    required double neLat,
    required double neLng,
    required double swLat,
    required double swLng,
  }) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      fetchHappeningsInViewport(
        neLat: neLat,
        neLng: neLng,
        swLat: swLat,
        swLng: swLng,
      );
    });
  }


  Future<void> fetchHappeningsInViewport({
    required double neLat,
    required double neLng,
    required double swLat,
    required double swLng,
  }) async {
    final result = await _mapRepository.getMapHappenings(
      neLat: neLat,
      neLng: neLng,
      swLat: swLat,
      swLng: swLng,
      category: _activeCategory,
    );

    result.fold(
      (failure) => emit(MapError(failure.message)),
      (happenings) {


        final active = happenings.where((h) => !h.isExpired).toList();
        emit(MapLoaded(
          happenings: active,
          activeCategory: _activeCategory,
        ));
      },
    );
  }


  void filterByCategory(String? category) {
    _activeCategory = category;
  }


  Future<({double lat, double lng})> getUserPosition() async {
    return _locationService.getPositionOrDefault();
  }


  String? get activeCategory => _activeCategory;

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
