import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/location_service.dart';
import '../../../../shared/models/enums.dart';
import '../../domain/entities/happening.dart';
import '../../domain/usecases/get_nearby_happenings.dart';
import 'feed_state.dart';


class FeedCubit extends Cubit<FeedState> {
  FeedCubit({
    required GetNearbyHappenings getNearbyHappenings,
    required LocationService locationService,
  })  : _getNearbyHappenings = getNearbyHappenings,
        _locationService = locationService,
        super(const FeedInitial());

  final GetNearbyHappenings _getNearbyHappenings;
  final LocationService _locationService;


  double? _userLat;
  double? _userLng;
  double _radiusKm = 10.0;
  String? _activeCategory;


  static const int _perPage = 20;


  Future<void> loadFeed() async {
    emit(const FeedLoading());


    final position = await _locationService.getPositionOrDefault();
    _userLat = position.lat;
    _userLng = position.lng;

    await _fetchHappenings(page: 1);
  }


  Future<void> refreshFeed() async {
    if (state is FeedLoaded) {
      emit(const FeedRefreshing());
    }
    await _fetchHappenings(page: 1);
  }


  Future<void> loadMore() async {
    final currentState = state;
    if (currentState is FeedLoaded &&
        currentState.hasMore &&
        !currentState.isLoadingMore) {
      emit(currentState.copyWith(isLoadingMore: true));
      await _fetchHappenings(
        page: currentState.currentPage + 1,
        append: true,
      );
    }
  }


  Future<void> filterByCategory(String? category) async {
    _activeCategory = category;
    emit(const FeedLoading());
    await _fetchHappenings(page: 1);
  }


  Future<void> updateRadius(double radiusKm) async {
    _radiusKm = radiusKm;
    emit(const FeedLoading());
    await _fetchHappenings(page: 1);
  }


  String? get activeCategory => _activeCategory;


  double get radiusKm => _radiusKm;


  double? get userLat => _userLat;


  double? get userLng => _userLng;


  Future<void> _fetchHappenings({
    required int page,
    bool append = false,
  }) async {

    if (_userLat == null || _userLng == null) {
      emit(const FeedError('Location not available. Please try again.'));
      return;
    }

    final result = await _getNearbyHappenings(
      latitude: _userLat!,
      longitude: _userLng!,
      radiusKm: _radiusKm,
      category: _activeCategory,
      page: page,
    );

    result.fold(
      (failure) {


        if (append && state is FeedLoaded) {
          final loaded = state as FeedLoaded;
          emit(FeedError(
            failure.message,
            previousHappenings: loaded.happenings,
          ));
        } else {
          emit(FeedError(failure.message));
        }
      },
      (happenings) {


        final List<Happening> active = happenings
            .where((h) =>
                h.status == HappeningStatus.active &&
                !h.isExpired)
            .toList();

        if (active.isEmpty && page == 1) {
          emit(const FeedEmpty());
        } else {
          final allHappenings = append && state is FeedLoaded
              ? [...(state as FeedLoaded).happenings, ...active]
              : active;

          emit(FeedLoaded(
            happenings: allHappenings,
            hasMore: happenings.length >= _perPage,
            currentPage: page,
            activeCategory: _activeCategory,
          ));
        }
      },
    );
  }
}
