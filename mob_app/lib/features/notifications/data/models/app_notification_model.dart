import '../../domain/entities/app_notification.dart';


class AppNotificationModel extends AppNotification {
  const AppNotificationModel({
    required super.id,
    required super.uuid,
    required super.type,
    required super.title,
    required super.body,
    super.data,
    super.readAt,
    required super.createdAt,
  });


  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'] as Map)
          : null,
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'type': type,
      'title': title,
      'body': body,
      'data': data,
      'read_at': readAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }


  factory AppNotificationModel.fromEntity(AppNotification entity) {
    return AppNotificationModel(
      id: entity.id,
      uuid: entity.uuid,
      type: entity.type,
      title: entity.title,
      body: entity.body,
      data: entity.data,
      readAt: entity.readAt,
      createdAt: entity.createdAt,
    );
  }
}
