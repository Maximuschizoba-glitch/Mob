import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mime/mime.dart';

import '../../../../core/services/firebase_storage_service.dart';
import '../../../../core/utils/image_compressor.dart';
import '../../../../shared/models/enums.dart';
import '../../data/models/create_happening_request.dart';
import '../../domain/repositories/happening_repository.dart';
import 'post_happening_state.dart';


class PostHappeningCubit extends Cubit<PostHappeningState> {
  PostHappeningCubit({
    required HappeningRepository happeningRepository,
    required FirebaseStorageService firebaseStorageService,
    required String userId,
  })  : _happeningRepository = happeningRepository,
        _firebaseStorageService = firebaseStorageService,
        _userId = userId,
        super(const PostHappeningState());

  final HappeningRepository _happeningRepository;
  final FirebaseStorageService _firebaseStorageService;
  final String _userId;


  void setType(HappeningType type) {

    emit(state.copyWith(
      type: type,

      useExactLocation: type == HappeningType.event,

      isTicketed: false,
      clearTicketPrice: true,
      clearTicketQuantity: true,

      clearRadiusMeters: type == HappeningType.event,
      clearError: true,
    ));
  }


  void setDetails({
    String? title,
    String? description,
    HappeningCategory? category,
    bool? isHappeningNow,
    DateTime? startsAt,
    DateTime? endsAt,
  }) {
    emit(state.copyWith(
      title: title,
      description: description,
      category: category,
      isHappeningNow: isHappeningNow,
      startsAt: startsAt,
      endsAt: endsAt,

      clearStartsAt: isHappeningNow == true,
      clearEndsAt: isHappeningNow == true,
      clearError: true,
    ));
  }

  void setTicketing({
    bool? isTicketed,
    double? ticketPrice,
    int? ticketQuantity,
  }) {
    emit(state.copyWith(
      isTicketed: isTicketed,
      ticketPrice: ticketPrice,
      ticketQuantity: ticketQuantity,
      clearTicketPrice: isTicketed == false,
      clearTicketQuantity: isTicketed == false,
      clearError: true,
    ));
  }


  void setLocation({
    double? latitude,
    double? longitude,
    String? address,
    double? radiusMeters,
    bool? useExactLocation,
  }) {
    emit(state.copyWith(
      latitude: latitude,
      longitude: longitude,
      address: address,
      radiusMeters: radiusMeters,
      useExactLocation: useExactLocation,
      clearRadiusMeters: useExactLocation == true,
      clearError: true,
    ));
  }


  void addSnap(File file) {
    if (!state.canAddSnap) return;
    emit(state.copyWith(
      snapFiles: [...state.snapFiles, file],
      clearError: true,
    ));
  }

  void removeSnap(int index) {
    if (index < 0 || index >= state.snapFiles.length) return;
    final updated = List<File>.from(state.snapFiles)..removeAt(index);
    emit(state.copyWith(snapFiles: updated, clearError: true));
  }


  bool nextStep() {
    final validationError = _validateStep(state.currentStep);
    if (validationError != null) {
      emit(state.copyWith(error: validationError));
      return false;
    }
    if (state.currentStep >= 4) return false;
    emit(state.copyWith(
      currentStep: state.currentStep + 1,
      clearError: true,
    ));
    return true;
  }


  void previousStep() {
    if (state.currentStep <= 0) return;
    emit(state.copyWith(
      currentStep: state.currentStep - 1,
      clearError: true,
    ));
  }


  void goToStep(int step) {
    if (step < 0 || step > 4 || step > state.currentStep) return;
    emit(state.copyWith(currentStep: step, clearError: true));
  }


  bool validateCurrentStep() {
    return _validateStep(state.currentStep) == null;
  }


  Future<void> publish() async {

    for (int step = 0; step <= 3; step++) {
      final error = _validateStep(step);
      if (error != null) {
        emit(state.copyWith(error: error, currentStep: step));
        return;
      }
    }

    emit(state.copyWith(
      isSubmitting: true,
      clearError: true,
      uploadProgress: 0.0,
      uploadStatusText: 'Preparing...',
    ));

    try {

      final snapPayloads = <SnapPayload>[];

      if (state.snapFiles.isNotEmpty) {

        emit(state.copyWith(
          uploadStatusText: 'Compressing images...',
        ));
        final compressedFiles = <File>[];
        for (final file in state.snapFiles) {
          final mediaType = _resolveMediaType(file);
          if (mediaType == 'image') {
            compressedFiles.add(await ImageCompressor.compress(file));
          } else {
            compressedFiles.add(file);
          }
        }

        for (int i = 0; i < compressedFiles.length; i++) {
          final file = compressedFiles[i];
          final mediaType = _resolveMediaType(state.snapFiles[i]);

          emit(state.copyWith(
            uploadStatusText:
                'Uploading snap ${i + 1} of ${state.snapFiles.length}...',
            uploadProgress: i / state.snapFiles.length,
          ));

          final url = await _firebaseStorageService.uploadSnapMedia(
            file: file,
            userId: _userId,
            mediaType: mediaType,
            onProgress: (progress) {
              final overallProgress =
                  (i + progress) / state.snapFiles.length;
              emit(state.copyWith(uploadProgress: overallProgress));
            },
          );

          snapPayloads.add(SnapPayload(
            mediaUrl: url,
            mediaType: mediaType,
          ));
        }
      }


      emit(state.copyWith(
        uploadStatusText: 'Creating happening...',
        uploadProgress: 1.0,
      ));

      final request = CreateHappeningRequest(
        title: state.title!,
        description: state.description,
        category: state.category!,
        type: state.type!,
        latitude: state.latitude!,
        longitude: state.longitude!,
        address: state.address!,
        radiusMeters: state.isAreaBased && state.radiusMeters != null
            ? state.radiusMeters!.round()
            : null,
        isHappeningNow: state.isHappeningNow,
        startsAt: state.isHappeningNow ? null : state.startsAt,
        endsAt: state.endsAt,
        isTicketed: state.isTicketed,
        ticketPrice: state.isTicketed ? state.ticketPrice : null,
        ticketQuantity: state.isTicketed ? state.ticketQuantity : null,
        snaps: snapPayloads,
      );


      final result = await _happeningRepository.createHappening(request);

      result.fold(
        (failure) {
          emit(state.copyWith(
            isSubmitting: false,
            error: failure.message,
            clearUploadStatusText: true,
          ));
        },
        (happening) {
          emit(state.copyWith(
            isSubmitting: false,
            isSuccess: true,
            createdHappening: happening,
            clearUploadStatusText: true,
          ));
        },
      );
    } catch (e) {
      debugPrint('[Mob] Publish failed: $e');
      emit(state.copyWith(
        isSubmitting: false,
        error: 'Failed to publish happening: $e',
        clearUploadStatusText: true,
      ));
    }
  }


  void reset() {
    emit(const PostHappeningState());
  }


  String? _validateStep(int step) {
    switch (step) {
      case 0:
        if (state.type == null) return 'Please select a happening type.';
        break;

      case 1:
        if (state.title == null || state.title!.trim().isEmpty) {
          return 'Title is required.';
        }
        if (state.title!.trim().length > 255) {
          return 'Title must be under 255 characters.';
        }
        if (state.category == null) return 'Please select a category.';
        if (!state.isHappeningNow && state.startsAt == null) {
          return 'Start time is required unless "Happening Now" is on.';
        }
        if (state.isTicketed && state.isEvent) {
          if (state.ticketPrice == null || state.ticketPrice! < 100) {
            return 'Ticket price must be at least \u20A6100.';
          }
          if (state.ticketQuantity == null || state.ticketQuantity! < 1) {
            return 'Ticket quantity must be at least 1.';
          }
        }
        break;

      case 2:
        if (state.latitude == null || state.longitude == null) {
          return 'Please set a location on the map.';
        }
        if (state.address == null || state.address!.trim().isEmpty) {
          return 'Address is required.';
        }
        if (state.isAreaBased) {
          if (state.radiusMeters == null ||
              state.radiusMeters! < 100 ||
              state.radiusMeters! > 5000) {
            return 'Radius must be between 100m and 5km for area-based happenings.';
          }
        }
        break;

      case 3:

        if (state.isAreaBased && state.snapFiles.isEmpty) {
          return 'Area-based happenings require at least one snap.';
        }
        break;

      case 4:

        for (int i = 0; i < 4; i++) {
          final error = _validateStep(i);
          if (error != null) return error;
        }
        break;
    }
    return null;
  }


  String _resolveMediaType(File file) {
    final mimeType = lookupMimeType(file.path);
    if (mimeType != null && mimeType.startsWith('video/')) return 'video';
    return 'image';
  }
}
