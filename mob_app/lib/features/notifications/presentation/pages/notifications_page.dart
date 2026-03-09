import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../shared/widgets/mob_empty_state.dart';
import '../../../../shared/widgets/mob_error_state.dart';
import '../../domain/entities/app_notification.dart';
import '../bloc/notification_cubit.dart';
import '../bloc/notification_state.dart';
import '../widgets/notification_card.dart';


class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);


    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationCubit>().loadNotifications(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll - currentScroll <= 200) {
      final state = context.read<NotificationCubit>().state;
      if (state is NotificationsLoaded && state.hasMore) {
        context.read<NotificationCubit>().loadNotifications();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Notifications', style: AppTypography.h4),
        centerTitle: false,
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              final hasUnread = state is NotificationsLoaded &&
                  state.unreadCount > 0;

              if (!hasUnread) return const SizedBox.shrink();

              return TextButton(
                onPressed: () {
                  context.read<NotificationCubit>().markAllAsRead();
                },
                child: Text(
                  'Mark all read',
                  style: AppTypography.buttonSmall.copyWith(
                    color: AppColors.cyan,
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<NotificationCubit, NotificationState>(
        listenWhen: (prev, curr) => curr is NotificationsError,
        listener: _onStateChanged,
        builder: (context, state) {

          if (state is NotificationsLoading || state is NotificationInitial) {
            return const _NotificationShimmer();
          }


          if (state is NotificationsError &&
              state.previousNotifications == null) {
            return MobErrorState(
              message: state.message,
              onRetry: () => context
                  .read<NotificationCubit>()
                  .loadNotifications(refresh: true),
            );
          }


          final notifications = _resolveNotifications(state);
          if (notifications == null || notifications.isEmpty) {
            return const MobEmptyState(
              icon: Icons.notifications_off_outlined,
              title: 'No Notifications Yet',
              body:
                  'When you get tickets, snaps, or updates on your happenings, they\u2019ll show up here.',
            );
          }


          final groups = _groupByDate(notifications);
          final hasMore = state is NotificationsLoaded && state.hasMore;

          return RefreshIndicator(
            onRefresh: () => context
                .read<NotificationCubit>()
                .loadNotifications(refresh: true),
            color: AppColors.cyan,
            backgroundColor: AppColors.card,
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.only(bottom: AppSpacing.huge),
              itemCount: _totalItemCount(groups, hasMore),
              itemBuilder: (context, index) =>
                  _buildItem(index, groups, hasMore),
            ),
          );
        },
      ),
    );
  }


  List<AppNotification>? _resolveNotifications(NotificationState state) {
    if (state is NotificationsLoaded) return state.notifications;
    if (state is NotificationsError) return state.previousNotifications;
    return null;
  }

  void _onStateChanged(BuildContext context, NotificationState state) {

    if (state is NotificationsError &&
        state.previousNotifications != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }


  List<_DateGroup> _groupByDate(List<AppNotification> notifications) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    final todayList = <AppNotification>[];
    final yesterdayList = <AppNotification>[];
    final earlierList = <AppNotification>[];

    for (final n in notifications) {
      final nDate = DateTime(n.createdAt.year, n.createdAt.month, n.createdAt.day);
      if (nDate == today) {
        todayList.add(n);
      } else if (nDate == yesterday) {
        yesterdayList.add(n);
      } else {
        earlierList.add(n);
      }
    }

    final groups = <_DateGroup>[];
    if (todayList.isNotEmpty) {
      groups.add(_DateGroup(label: 'Today', notifications: todayList));
    }
    if (yesterdayList.isNotEmpty) {
      groups.add(_DateGroup(label: 'Yesterday', notifications: yesterdayList));
    }
    if (earlierList.isNotEmpty) {
      groups.add(_DateGroup(label: 'Earlier', notifications: earlierList));
    }
    return groups;
  }


  int _totalItemCount(List<_DateGroup> groups, bool hasMore) {
    int count = 0;
    for (final g in groups) {
      count += 1 + g.notifications.length;
    }
    if (hasMore) count += 1;
    return count;
  }


  Widget _buildItem(int index, List<_DateGroup> groups, bool hasMore) {
    int offset = 0;

    for (final group in groups) {

      if (index == offset) {
        return _buildSectionHeader(group.label);
      }


      final cardIndex = index - offset - 1;
      if (cardIndex >= 0 && cardIndex < group.notifications.length) {
        final notification = group.notifications[cardIndex];
        return NotificationCard(
          notification: notification,
          onTap: () => _handleNotificationTap(notification),
        );
      }

      offset += 1 + group.notifications.length;
    }


    if (hasMore) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: AppColors.cyan,
              strokeWidth: 2.5,
            ),
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildSectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.lg,
        bottom: AppSpacing.sm,
      ),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.overline.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
    );
  }


  void _handleNotificationTap(AppNotification notification) {

    if (notification.isUnread) {
      context.read<NotificationCubit>().markAsRead(notification.uuid);
    }


    switch (notification.type) {
      case 'ticket_confirmed':
      case 'refund_complete':
        final ticketUuid = notification.ticketUuid;
        if (ticketUuid != null) {
          context.push(RoutePaths.ticketDetailPath(ticketUuid));
        }
        break;

      case 'escrow_update':
        final happeningUuid = notification.happeningUuid;
        if (happeningUuid != null) {
          context.push(RoutePaths.hostDashboardPath(happeningUuid));
        }
        break;

      case 'happening_expiring':
      case 'new_snap':
        final happeningUuid = notification.happeningUuid;
        if (happeningUuid != null) {
          context.push(RoutePaths.happeningDetailPath(happeningUuid));
        }
        break;

      case 'verification_update':
        context.push(RoutePaths.hostVerificationStatus);
        break;
    }
  }
}


class _DateGroup {
  const _DateGroup({required this.label, required this.notifications});

  final String label;
  final List<AppNotification> notifications;
}


class _NotificationShimmer extends StatelessWidget {
  const _NotificationShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.card,
      highlightColor: AppColors.elevated,
      child: ListView.builder(
        padding: const EdgeInsets.only(top: AppSpacing.lg),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 8,
        itemBuilder: (context, index) {

          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.lg,
                bottom: AppSpacing.md,
              ),
              child: Container(
                width: 60,
                height: 12,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.md,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.card,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      Container(
                        width: double.infinity,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      Container(
                        width: 200,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      Container(
                        width: 60,
                        height: 10,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusSm),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
