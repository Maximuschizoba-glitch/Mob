import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../feed/domain/entities/happening.dart';
import '../../../feed/domain/repositories/feed_repository.dart';
import '../../../snaps/domain/repositories/snap_repository.dart';
import '../../domain/repositories/happening_repository.dart';
import 'happening_detail_state.dart';


class HappeningDetailCubit extends Cubit<HappeningDetailState> {
  HappeningDetailCubit({
    required FeedRepository feedRepository,
    required SnapRepository snapRepository,
    required HappeningRepository happeningRepository,
    required this.uuid,
    Happening? cachedHappening,
  })  : _feedRepository = feedRepository,
        _snapRepository = snapRepository,
        _happeningRepository = happeningRepository,
        super(const HappeningDetailInitial()) {

    if (cachedHappening != null) {
      emit(HappeningDetailLoaded(cachedHappening, isSnapsLoading: true));
      loadSnaps();
    } else {
      loadDetail();
    }
  }

  final FeedRepository _feedRepository;
  final SnapRepository _snapRepository;
  final HappeningRepository _happeningRepository;
  final String uuid;


  Future<void> loadDetail() async {
    emit(const HappeningDetailLoading());

    final result = await _feedRepository.getHappeningDetail(uuid);
    result.fold(
      (failure) => emit(HappeningDetailError(failure.message)),
      (happening) {
        emit(HappeningDetailLoaded(happening, isSnapsLoading: true));
        loadSnaps();
      },
    );
  }


  Future<void> loadSnaps() async {
    final current = state;
    if (current is! HappeningDetailLoaded) return;

    final result = await _snapRepository.getHappeningSnaps(uuid);
    result.fold(

      (_) {
        if (state is HappeningDetailLoaded) {
          emit((state as HappeningDetailLoaded).copyWith(
            isSnapsLoading: false,
          ));
        }
      },
      (snaps) {
        if (state is HappeningDetailLoaded) {
          emit((state as HappeningDetailLoaded).copyWith(
            snaps: snaps,
            isSnapsLoading: false,
          ));
        }
      },
    );
  }


  Future<void> refresh() async {
    final result = await _feedRepository.getHappeningDetail(uuid);
    result.fold(
      (failure) {

        if (state is! HappeningDetailLoaded) {
          emit(HappeningDetailError(failure.message));
        }
      },
      (happening) {
        emit(HappeningDetailLoaded(happening, isSnapsLoading: true));
        loadSnaps();
      },
    );
  }


  Future<bool> endHappening() async {
    final result = await _happeningRepository.endHappening(uuid);
    return result.fold(
      (failure) => false,
      (_) => true,
    );
  }


  Future<bool> deleteHappening() async {
    final result = await _happeningRepository.deleteHappening(uuid);
    return result.fold(
      (failure) => false,
      (_) => true,
    );
  }


  Future<bool> updateHappening({
    String? title,
    String? description,
    String? category,
  }) async {
    final result = await _happeningRepository.updateHappening(
      uuid,
      title: title,
      description: description,
      category: category,
    );
    return result.fold(
      (failure) => false,
      (happening) {
        emit(HappeningDetailLoaded(happening, isSnapsLoading: true));
        loadSnaps();
        return true;
      },
    );
  }
}
