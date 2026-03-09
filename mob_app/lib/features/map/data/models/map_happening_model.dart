import '../../../../shared/models/enums.dart';
import '../../../feed/domain/entities/happening.dart';


class MapHappeningModel extends Happening {
  const MapHappeningModel({
    required super.uuid,
    required super.title,
    required super.category,
    required super.type,
    required super.latitude,
    required super.longitude,
    required super.activityLevel,
    required super.vibeScore,
    required super.snapsCount,
    required super.isTicketed,
    required super.hasSnaps,
    required super.expiresAt,
    super.coverImageUrl,
    super.ticketPrice,
    super.status = HappeningStatus.active,
  }) : super(
          ticketsSold: 0,
        );


  factory MapHappeningModel.fromJson(Map<String, dynamic> json) {
    final snapsCount = (json['snaps_count'] as num?)?.toInt() ?? 0;

    return MapHappeningModel(
      uuid: json['uuid'] as String,
      title: json['title'] as String,
      category: HappeningCategory.fromString(json['category'] as String?) ??
          HappeningCategory.hangoutsSocial,
      type: HappeningType.fromString(json['type'] as String?) ??
          HappeningType.casual,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      activityLevel:
          ActivityLevel.fromString(json['activity_level'] as String?),
      vibeScore: (json['vibe_score'] as num?)?.toDouble() ?? 0.0,
      snapsCount: snapsCount,
      isTicketed: json['is_ticketed'] as bool? ?? false,
      hasSnaps: snapsCount > 0,
      coverImageUrl: json['cover_image_url'] as String?,
      ticketPrice: (json['ticket_price'] as num?)?.toDouble(),
      status: HappeningStatus.fromString(json['status'] as String?) ??
          HappeningStatus.active,
      expiresAt: _parseDateTime(json['expires_at']) ??
          DateTime.now().add(const Duration(hours: 24)),
    );
  }

  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
