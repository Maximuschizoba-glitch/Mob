import 'package:equatable/equatable.dart';


class AppNotification extends Equatable {
  final int id;
  final String uuid;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic>? data;
  final DateTime? readAt;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.uuid,
    required this.type,
    required this.title,
    required this.body,
    this.data,
    this.readAt,
    required this.createdAt,
  });


  bool get isRead => readAt != null;


  bool get isUnread => readAt == null;


  String? get happeningUuid => data?['happening_uuid'] as String?;


  String? get ticketUuid => data?['ticket_uuid'] as String?;


  String? get escrowUuid => data?['escrow_uuid'] as String?;

  @override
  List<Object?> get props => [
        id,
        uuid,
        type,
        title,
        body,
        data,
        readAt,
        createdAt,
      ];
}
