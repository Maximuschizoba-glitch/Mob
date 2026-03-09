import 'package:equatable/equatable.dart';


class Snap extends Equatable {
  final String uuid;
  final String mediaUrl;
  final String mediaType;
  final String? thumbnailUrl;
  final int? durationSeconds;
  final DateTime expiresAt;
  final String? timeRemaining;


  final String? uploaderUuid;
  final String? uploaderName;
  final String? uploaderAvatarUrl;

  final DateTime? createdAt;

  const Snap({
    required this.uuid,
    required this.mediaUrl,
    required this.mediaType,
    this.thumbnailUrl,
    this.durationSeconds,
    required this.expiresAt,
    this.timeRemaining,
    this.uploaderUuid,
    this.uploaderName,
    this.uploaderAvatarUrl,
    this.createdAt,
  });


  bool get isVideo => mediaType == 'video';


  bool get isImage => mediaType == 'image';


  bool get isExpired => DateTime.now().isAfter(expiresAt);

  @override
  List<Object?> get props => [
        uuid,
        mediaUrl,
        mediaType,
        thumbnailUrl,
        durationSeconds,
        expiresAt,
        timeRemaining,
        uploaderUuid,
        uploaderName,
        uploaderAvatarUrl,
        createdAt,
      ];
}
