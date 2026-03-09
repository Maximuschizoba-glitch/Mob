import 'dart:io';

import 'package:equatable/equatable.dart';

import '../../../feed/domain/entities/happening.dart';
import '../../../../shared/models/enums.dart';


class PostHappeningState extends Equatable {
  const PostHappeningState({
    this.currentStep = 0,
    this.type,
    this.title,
    this.description,
    this.category,
    this.isHappeningNow = false,
    this.startsAt,
    this.endsAt,
    this.latitude,
    this.longitude,
    this.address,
    this.radiusMeters,
    this.useExactLocation = true,
    this.snapFiles = const [],
    this.isTicketed = false,
    this.ticketPrice,
    this.ticketQuantity,
    this.isSubmitting = false,
    this.isSuccess = false,
    this.error,
    this.createdHappening,
    this.uploadProgress = 0.0,
    this.uploadStatusText,
  });


  final int currentStep;


  final HappeningType? type;


  final String? title;
  final String? description;
  final HappeningCategory? category;


  final bool isHappeningNow;

  final DateTime? startsAt;
  final DateTime? endsAt;


  final double? latitude;
  final double? longitude;
  final String? address;


  final double? radiusMeters;


  final bool useExactLocation;


  final List<File> snapFiles;


  final bool isTicketed;


  final double? ticketPrice;


  final int? ticketQuantity;


  final bool isSubmitting;


  final bool isSuccess;


  final String? error;


  final Happening? createdHappening;


  final double uploadProgress;


  final String? uploadStatusText;


  bool get isCasual => type == HappeningType.casual;


  bool get isEvent => type == HappeningType.event;


  bool get isAreaBased => isCasual && !useExactLocation;


  static const int maxSnaps = 5;


  bool get canAddSnap => snapFiles.length < maxSnaps;


  PostHappeningState copyWith({
    int? currentStep,
    HappeningType? type,
    String? title,
    String? description,
    HappeningCategory? category,
    bool? isHappeningNow,
    DateTime? startsAt,
    DateTime? endsAt,
    double? latitude,
    double? longitude,
    String? address,
    double? radiusMeters,
    bool? useExactLocation,
    List<File>? snapFiles,
    bool? isTicketed,
    double? ticketPrice,
    int? ticketQuantity,
    bool? isSubmitting,
    bool? isSuccess,
    String? error,
    Happening? createdHappening,
    double? uploadProgress,
    String? uploadStatusText,

    bool clearStartsAt = false,
    bool clearEndsAt = false,
    bool clearRadiusMeters = false,
    bool clearTicketPrice = false,
    bool clearTicketQuantity = false,
    bool clearError = false,
    bool clearUploadStatusText = false,
  }) {
    return PostHappeningState(
      currentStep: currentStep ?? this.currentStep,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      isHappeningNow: isHappeningNow ?? this.isHappeningNow,
      startsAt: clearStartsAt ? null : (startsAt ?? this.startsAt),
      endsAt: clearEndsAt ? null : (endsAt ?? this.endsAt),
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      radiusMeters:
          clearRadiusMeters ? null : (radiusMeters ?? this.radiusMeters),
      useExactLocation: useExactLocation ?? this.useExactLocation,
      snapFiles: snapFiles ?? this.snapFiles,
      isTicketed: isTicketed ?? this.isTicketed,
      ticketPrice:
          clearTicketPrice ? null : (ticketPrice ?? this.ticketPrice),
      ticketQuantity:
          clearTicketQuantity ? null : (ticketQuantity ?? this.ticketQuantity),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      isSuccess: isSuccess ?? this.isSuccess,
      error: clearError ? null : (error ?? this.error),
      createdHappening: createdHappening ?? this.createdHappening,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      uploadStatusText: clearUploadStatusText
          ? null
          : (uploadStatusText ?? this.uploadStatusText),
    );
  }

  @override
  List<Object?> get props => [
        currentStep,
        type,
        title,
        description,
        category,
        isHappeningNow,
        startsAt,
        endsAt,
        latitude,
        longitude,
        address,
        radiusMeters,
        useExactLocation,
        snapFiles,
        isTicketed,
        ticketPrice,
        ticketQuantity,
        isSubmitting,
        isSuccess,
        error,
        createdHappening,
        uploadProgress,
        uploadStatusText,
      ];
}
