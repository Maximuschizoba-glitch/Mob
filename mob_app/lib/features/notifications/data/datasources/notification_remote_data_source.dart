import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/dio_client.dart';
import '../models/app_notification_model.dart';


abstract class NotificationRemoteDataSource {


  Future<({List<AppNotificationModel> notifications, int total, int lastPage})>
      getNotifications({int page = 1});


  Future<AppNotificationModel> markAsRead(String uuid);


  Future<void> markAllAsRead();


  Future<int> getUnreadCount();
}


class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  NotificationRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  final DioClient _dioClient;

  @override
  Future<({List<AppNotificationModel> notifications, int total, int lastPage})>
      getNotifications({int page = 1}) async {
    final response = await _dioClient.get<List<dynamic>>(
      ApiEndpoints.notifications,
      queryParams: {'page': page},
      fromJson: (data) => data as List<dynamic>,
    );

    final notifications = (response.data ?? [])
        .map((e) => AppNotificationModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return (
      notifications: notifications,
      total: response.meta?.total ?? 0,
      lastPage: response.meta?.lastPage ?? 1,
    );
  }

  @override
  Future<AppNotificationModel> markAsRead(String uuid) async {
    final response = await _dioClient.put<Map<String, dynamic>>(
      ApiEndpoints.notificationRead(uuid),
      fromJson: (data) => data as Map<String, dynamic>,
    );

    return AppNotificationModel.fromJson(response.data!);
  }

  @override
  Future<void> markAllAsRead() async {
    await _dioClient.put<void>(ApiEndpoints.markAllRead);
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiEndpoints.unreadCount,
      fromJson: (data) => data as Map<String, dynamic>,
    );

    return (response.data?['count'] as int?) ?? 0;
  }
}
