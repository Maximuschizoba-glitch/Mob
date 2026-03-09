import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../feed/domain/entities/happening.dart';
import '../../data/models/update_profile_request.dart';
import '../../domain/repositories/profile_repository.dart';
import 'profile_state.dart';


class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit({
    required ProfileRepository profileRepository,
  })  : _profileRepository = profileRepository,
        super(const ProfileInitial());

  final ProfileRepository _profileRepository;


  List<Happening> _currentHappenings() {
    final s = state;
    if (s is ProfileLoaded) return s.happenings;
    if (s is ProfileUpdating) return s.happenings;
    if (s is ProfileUpdateSuccess) return s.happenings;
    if (s is ProfileError) return s.happenings;
    return const [];
  }


  Future<void> loadProfile() async {
    emit(const ProfileLoading());


    final profileFuture = _profileRepository.getProfile();
    final happeningsFuture = _profileRepository.getMyHappenings();

    final profileResult = await profileFuture;
    final happeningsResult = await happeningsFuture;

    profileResult.fold(
      (failure) => emit(ProfileError(failure.message)),
      (user) {
        final happenings = happeningsResult.fold(
          (_) => <Happening>[],
          (list) => list,
        );
        emit(ProfileLoaded(user, happenings: happenings));
      },
    );
  }


  Future<void> updateProfile(UpdateProfileRequest request) async {
    final currentUser =
        state is ProfileLoaded ? (state as ProfileLoaded).user : null;
    final happenings = _currentHappenings();

    if (currentUser != null) {
      emit(ProfileUpdating(currentUser, happenings: happenings));
    } else {
      emit(const ProfileLoading());
    }

    final result = await _profileRepository.updateProfile(request);

    result.fold(
      (failure) => emit(ProfileError(
        failure.message,
        previousUser: currentUser,
        happenings: happenings,
      )),
      (user) => emit(ProfileUpdateSuccess(
        user,
        message: 'Profile updated successfully',
        happenings: happenings,
      )),
    );
  }


  Future<void> updateAvatar(String filePath) async {
    final currentUser =
        state is ProfileLoaded ? (state as ProfileLoaded).user : null;
    final happenings = _currentHappenings();

    if (currentUser != null) {
      emit(ProfileUpdating(currentUser, happenings: happenings));
    } else {
      emit(const ProfileLoading());
    }

    final result = await _profileRepository.updateAvatar(filePath);

    result.fold(
      (failure) => emit(ProfileError(
        failure.message,
        previousUser: currentUser,
        happenings: happenings,
      )),
      (user) => emit(ProfileUpdateSuccess(
        user,
        message: 'Avatar updated successfully',
        happenings: happenings,
      )),
    );
  }


  Future<bool> deleteHappening(String uuid) async {
    final result = await _profileRepository.deleteHappening(uuid);

    return result.fold(
      (failure) => false,
      (_) {

        final happenings =
            _currentHappenings().where((h) => h.uuid != uuid).toList();

        final s = state;
        if (s is ProfileLoaded) {
          emit(ProfileLoaded(s.user, happenings: happenings));
        } else if (s is ProfileUpdating) {
          emit(ProfileLoaded(s.user, happenings: happenings));
        } else if (s is ProfileUpdateSuccess) {
          emit(ProfileLoaded(s.user, happenings: happenings));
        }
        return true;
      },
    );
  }


  Future<void> deleteAccount() async {
    final currentUser =
        state is ProfileLoaded ? (state as ProfileLoaded).user : null;
    final happenings = _currentHappenings();

    if (currentUser != null) {
      emit(ProfileUpdating(currentUser, happenings: happenings));
    } else {
      emit(const ProfileLoading());
    }

    final result = await _profileRepository.deleteAccount();

    result.fold(
      (failure) => emit(ProfileError(
        failure.message,
        previousUser: currentUser,
        happenings: happenings,
      )),
      (_) => emit(const ProfileInitial()),
    );
  }
}
