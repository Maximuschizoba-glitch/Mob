import 'package:flutter/foundation.dart';

import '../../../../shared/models/enums.dart';


class CreateHappeningRequest {
  const CreateHappeningRequest({
    required this.title,
    required this.category,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.description,
    this.radiusMeters,
    this.isHappeningNow = false,
    this.startsAt,
    this.endsAt,
    this.isTicketed = false,
    this.ticketPrice,
    this.ticketQuantity,
    this.snaps = const [],
  });

  final String title;


  final String? description;

  final HappeningCategory category;
  final HappeningType type;
  final double latitude;
  final double longitude;
  final String address;
  final int? radiusMeters;


  final bool isHappeningNow;

  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool isTicketed;
  final double? ticketPrice;
  final int? ticketQuantity;


  final List<SnapPayload> snaps;


  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'title': title,


      'description': (description != null && description!.trim().isNotEmpty)
          ? description!
          : ' ',
      'category': category.value,
      'type': type.value,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,

      'is_ticketed': isTicketed,
    };

    if (radiusMeters != null) {
      json['radius_meters'] = radiusMeters;
    }


    if (isHappeningNow) {
      json['starts_at'] = DateTime.now()
          .add(const Duration(seconds: 30))
          .toIso8601String();
    } else if (startsAt != null) {
      json['starts_at'] = startsAt!.toIso8601String();
    }

    debugPrint(
      '[Mob/CreateRequest] isHappeningNow=$isHappeningNow '
      'startsAt=$startsAt '
      'json starts_at=${json['starts_at']}',
    );

    if (endsAt != null) {
      json['ends_at'] = endsAt!.toIso8601String();
    }

    if (isTicketed) {
      if (ticketPrice != null) json['ticket_price'] = ticketPrice;
      if (ticketQuantity != null) json['ticket_quantity'] = ticketQuantity;
    }

    if (snaps.isNotEmpty) {
      json['snaps'] = snaps.map((s) => s.toJson()).toList();
    }

    return json;
  }
}


class SnapPayload {
  const SnapPayload({
    required this.mediaUrl,
    required this.mediaType,
  });


  final String mediaUrl;


  final String mediaType;

  Map<String, dynamic> toJson() => {
        'media_url': mediaUrl,
        'media_type': mediaType,
      };
}
