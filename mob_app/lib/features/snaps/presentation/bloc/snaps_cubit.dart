import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/snap_repository.dart';
import 'snaps_state.dart';


class SnapsCubit extends Cubit<SnapsState> {
  SnapsCubit(this._snapRepository) : super(SnapsInitial());

  final SnapRepository _snapRepository;


  String? _currentHappeningUuid;


  void setHappeningUuid(String uuid) {
    _currentHappeningUuid = uuid;
  }


  Future<void> loadSnaps(String happeningUuid) async {
    _currentHappeningUuid = happeningUuid;
    emit(SnapsLoading());

    final result = await _snapRepository.getHappeningSnaps(happeningUuid);
    result.fold(
      (failure) => emit(SnapsError(failure.message)),
      (snaps) {
        if (snaps.isEmpty) {
          emit(SnapsEmpty());
        } else {
          emit(SnapsLoaded(snaps: snaps, currentIndex: 0));
        }
      },
    );
  }


  void goToSnap(int index) {
    final current = state;
    if (current is SnapsLoaded) {
      if (index >= 0 && index < current.snaps.length) {
        emit(SnapsLoaded(snaps: current.snaps, currentIndex: index));
      }
    }
  }


  void nextSnap() {
    final current = state;
    if (current is SnapsLoaded) {
      if (current.currentIndex < current.snaps.length - 1) {
        goToSnap(current.currentIndex + 1);
      }
    }
  }


  void previousSnap() {
    final current = state;
    if (current is SnapsLoaded) {
      if (current.currentIndex > 0) {
        goToSnap(current.currentIndex - 1);
      }
    }
  }


  Future<void> uploadSnap({
    required String mediaUrl,
    required String mediaType,
    String? thumbnailUrl,
    int? durationSeconds,
  }) async {
    if (_currentHappeningUuid == null) return;

    emit(const SnapUploading(progress: 0.0));

    final result = await _snapRepository.createSnap(
      happeningUuid: _currentHappeningUuid!,
      mediaUrl: mediaUrl,
      mediaType: mediaType,
      thumbnailUrl: thumbnailUrl,
      durationSeconds: durationSeconds,
    );

    result.fold(
      (failure) => emit(SnapsError(failure.message)),
      (snap) {
        emit(SnapUploaded(snap));

        loadSnaps(_currentHappeningUuid!);
      },
    );
  }
}
