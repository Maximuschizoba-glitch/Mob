import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notification_repository.dart';
import 'notification_state.dart';


class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit({
    required NotificationRepository notificationRepository,
  })  : _notificationRepository = notificationRepository,
        super(const NotificationInitial());

  final NotificationRepository _notificationRepository;


  int _currentPage = 0;
  int _lastPage = 1;


  Future<void> loadNotifications({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 0;
      _lastPage = 1;
      emit(const NotificationsLoading());
    }


    if (_currentPage >= _lastPage) return;

    final nextPage = _currentPage + 1;

    final result = await _notificationRepository.getNotifications(
      page: nextPage,
    );

    result.fold(
      (failure) {

        final existingNotifications = state is NotificationsLoaded
            ? (state as NotificationsLoaded).notifications
            : null;

        emit(NotificationsError(
          failure.message,
          previousNotifications: existingNotifications,
        ));
      },
      (data) {
        _currentPage = nextPage;
        _lastPage = data.lastPage;


        final List<AppNotification> allNotifications;
        final int currentUnreadCount;

        if (refresh || state is! NotificationsLoaded) {
          allNotifications = data.notifications;
          currentUnreadCount =
              data.notifications.where((n) => n.isUnread).length;
        } else {
          final loaded = state as NotificationsLoaded;
          allNotifications = [...loaded.notifications, ...data.notifications];
          currentUnreadCount = loaded.unreadCount +
              data.notifications.where((n) => n.isUnread).length;
        }

        emit(NotificationsLoaded(
          notifications: allNotifications,
          unreadCount: currentUnreadCount,
          hasMore: _currentPage < _lastPage,
          currentPage: _currentPage,
        ));
      },
    );
  }


  Future<void> markAsRead(String uuid) async {

    if (state is NotificationsLoaded) {
      final loaded = state as NotificationsLoaded;
      final updatedNotifications = loaded.notifications.map((n) {
        if (n.uuid == uuid && n.isUnread) {
          return AppNotification(
            id: n.id,
            uuid: n.uuid,
            type: n.type,
            title: n.title,
            body: n.body,
            data: n.data,
            readAt: DateTime.now(),
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();

      final newUnreadCount =
          updatedNotifications.where((n) => n.isUnread).length;

      emit(loaded.copyWith(
        notifications: updatedNotifications,
        unreadCount: newUnreadCount,
      ));
    }


    final result = await _notificationRepository.markAsRead(uuid);

    result.fold(
      (failure) {

        loadNotifications(refresh: true);
      },
      (_) {

      },
    );
  }


  Future<void> markAllAsRead() async {

    if (state is NotificationsLoaded) {
      final loaded = state as NotificationsLoaded;
      final updatedNotifications = loaded.notifications.map((n) {
        if (n.isUnread) {
          return AppNotification(
            id: n.id,
            uuid: n.uuid,
            type: n.type,
            title: n.title,
            body: n.body,
            data: n.data,
            readAt: DateTime.now(),
            createdAt: n.createdAt,
          );
        }
        return n;
      }).toList();

      emit(loaded.copyWith(
        notifications: updatedNotifications,
        unreadCount: 0,
      ));
    }


    final result = await _notificationRepository.markAllAsRead();

    result.fold(
      (failure) {

        loadNotifications(refresh: true);
      },
      (_) {

      },
    );
  }


  Future<void> loadUnreadCount() async {
    final result = await _notificationRepository.getUnreadCount();

    result.fold(
      (failure) {

      },
      (count) {
        if (state is NotificationsLoaded) {
          emit((state as NotificationsLoaded).copyWith(unreadCount: count));
        }
      },
    );
  }
}
