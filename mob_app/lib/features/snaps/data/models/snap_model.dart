import '../../domain/entities/snap.dart';


class SnapModel extends Snap {
  const SnapModel({
    required super.uuid,
    required super.mediaUrl,
    required super.mediaType,
    super.thumbnailUrl,
    super.durationSeconds,
    required super.expiresAt,
    super.timeRemaining,
    super.uploaderUuid,
    super.uploaderName,
    super.uploaderAvatarUrl,
    super.createdAt,
  });


  factory SnapModel.fromJson(Map<String, dynamic> json) {
    final uploader = json['uploader'] as Map<String, dynamic>?;

    return SnapModel(
      uuid: json['uuid'] as String,
      mediaUrl: json['media_url'] as String,
      mediaType: json['media_type'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      durationSeconds: json['duration_seconds'] as int?,
      expiresAt: _parseDateTime(json['expires_at']) ?? DateTime.now(),
      timeRemaining: json['time_remaining'] as String?,
      uploaderUuid: uploader?['uuid'] as String?,
      uploaderName: uploader?['name'] as String?,
      uploaderAvatarUrl: uploader?['avatar_url'] as String?,
      createdAt: _parseDateTime(json['created_at']),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'media_url': mediaUrl,
      'media_type': mediaType,
      'thumbnail_url': thumbnailUrl,
      'duration_seconds': durationSeconds,
      'expires_at': expiresAt.toIso8601String(),
      'time_remaining': timeRemaining,
      'uploader': uploaderUuid != null
          ? {
              'uuid': uploaderUuid,
              'name': uploaderName,
              'avatar_url': uploaderAvatarUrl,
            }
          : null,
      'created_at': createdAt?.toIso8601String(),
    };
  }


  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
