import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/app_notification.dart';


abstract class NotificationRepository {


  Future<
      Either<Failure,
          ({List<AppNotification> notifications, int total, int lastPage})>>
      getNotifications({int page = 1});


  Future<Either<Failure, AppNotification>> markAsRead(String uuid);


  Future<Either<Failure, void>> markAllAsRead();


  Future<Either<Failure, int>> getUnreadCount();
}
