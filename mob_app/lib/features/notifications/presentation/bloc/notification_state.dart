import 'package:equatable/equatable.dart';

import '../../domain/entities/app_notification.dart';


abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}


class NotificationInitial extends NotificationState {
  const NotificationInitial();
}


class NotificationsLoading extends NotificationState {
  const NotificationsLoading();
}


class NotificationsLoaded extends NotificationState {

  final List<AppNotification> notifications;


  final int unreadCount;


  final bool hasMore;


  final int currentPage;

  const NotificationsLoaded({
    required this.notifications,
    required this.unreadCount,
    required this.hasMore,
    required this.currentPage,
  });


  NotificationsLoaded copyWith({
    List<AppNotification>? notifications,
    int? unreadCount,
    bool? hasMore,
    int? currentPage,
  }) {
    return NotificationsLoaded(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  List<Object?> get props => [notifications, unreadCount, hasMore, currentPage];
}


class NotificationsError extends NotificationState {

  final String message;


  final List<AppNotification>? previousNotifications;

  const NotificationsError(
    this.message, {
    this.previousNotifications,
  });

  @override
  List<Object?> get props => [message, previousNotifications];
}
