import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../app/router.dart';
import '../../features/notifications/presentation/bloc/notification_cubit.dart';
import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_typography.dart';
import '../constants/route_paths.dart';


class PushNotificationService {
  PushNotificationService({
    required GoRouter router,
  }) : _router = router;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final GoRouter _router;


  Future<void> initialize() async {

    await _requestPermissions();


    await _messaging.setForegroundNotificationPresentationOptions(
      alert: false,
      badge: true,
      sound: true,
    );


    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);


    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);


    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {

      Future.delayed(
        const Duration(milliseconds: 500),
        () => _handleNotificationTap(initialMessage),
      );
    }
  }


  Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (_) {
      return null;
    }
  }


  Future<void> _requestPermissions() async {

    await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );


    final status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
    }
  }


  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    if (notification == null) return;


    _incrementUnreadCount();


    _showInAppBanner(
      title: notification.title ?? '',
      body: notification.body ?? '',
      type: message.data['type'] as String? ?? '',
      onTap: () => _handleNotificationTap(message),
    );
  }


  void _handleNotificationTap(RemoteMessage message) {
    final data = message.data;
    final type = data['type'] as String? ?? '';

    switch (type) {
      case 'ticket_confirmed':
      case 'refund_complete':
        final ticketUuid = data['ticket_uuid'] as String?;
        if (ticketUuid != null) {
          _router.push(RoutePaths.ticketDetailPath(ticketUuid));
        }
        break;

      case 'escrow_update':
        final happeningUuid = data['happening_uuid'] as String?;
        if (happeningUuid != null) {
          _router.push(RoutePaths.hostDashboardPath(happeningUuid));
        }
        break;

      case 'happening_expiring':
      case 'new_snap':
        final happeningUuid = data['happening_uuid'] as String?;
        if (happeningUuid != null) {
          _router.push(RoutePaths.happeningDetailPath(happeningUuid));
        }
        break;

      case 'verification_update':
        _router.push(RoutePaths.hostVerificationStatus);
        break;

      default:
        _router.push(RoutePaths.notifications);
    }
  }


  void _incrementUnreadCount() {
    final context = AppRouter.rootNavigatorKey.currentContext;
    if (context == null) return;

    try {
      final cubit = context.read<NotificationCubit>();

      cubit.loadUnreadCount();
    } catch (_) {

    }
  }


  OverlayEntry? _currentBanner;
  Timer? _autoDismissTimer;

  void _showInAppBanner({
    required String title,
    required String body,
    required String type,
    required VoidCallback onTap,
  }) {

    _dismissBanner();

    final overlay = AppRouter.rootNavigatorKey.currentState?.overlay;
    if (overlay == null) return;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _InAppNotificationBanner(
        title: title,
        body: body,
        type: type,
        onTap: () {
          _dismissBanner();
          onTap();
        },
        onDismiss: _dismissBanner,
      ),
    );

    _currentBanner = entry;
    overlay.insert(entry);


    _autoDismissTimer = Timer(
      const Duration(seconds: 4),
      _dismissBanner,
    );
  }

  void _dismissBanner() {
    _autoDismissTimer?.cancel();
    _autoDismissTimer = null;
    _currentBanner?.remove();
    _currentBanner = null;
  }
}


class _InAppNotificationBanner extends StatefulWidget {
  const _InAppNotificationBanner({
    required this.title,
    required this.body,
    required this.type,
    required this.onTap,
    required this.onDismiss,
  });

  final String title;
  final String body;
  final String type;
  final VoidCallback onTap;
  final VoidCallback onDismiss;

  @override
  State<_InAppNotificationBanner> createState() =>
      _InAppNotificationBannerState();
}

class _InAppNotificationBannerState extends State<_InAppNotificationBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final typeConfig = _notificationTypeConfig(widget.type);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: GestureDetector(
          onTap: widget.onTap,
          onVerticalDragEnd: (details) {

            if (details.velocity.pixelsPerSecond.dy < -100) {
              widget.onDismiss();
            }
          },
          child: Container(
            padding: EdgeInsets.only(
              top: topPadding + AppSpacing.sm,
              left: AppSpacing.lg,
              right: AppSpacing.md,
              bottom: AppSpacing.md,
            ),
            decoration: const BoxDecoration(
              color: AppColors.elevated,
              border: Border(
                left: BorderSide(
                  color: AppColors.cyan,
                  width: 3,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [

                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: typeConfig.color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    typeConfig.icon,
                    size: 18,
                    color: typeConfig.color,
                  ),
                ),

                const SizedBox(width: AppSpacing.md),


                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.title,
                        style: AppTypography.buttonSmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.body.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          widget.body,
                          style: AppTypography.bodySmall,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),


                GestureDetector(
                  onTap: widget.onDismiss,
                  behavior: HitTestBehavior.opaque,
                  child: const Padding(
                    padding: EdgeInsets.all(AppSpacing.sm),
                    child: Icon(
                      Icons.close,
                      size: 18,
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  static _TypeConfig _notificationTypeConfig(String type) {
    switch (type) {
      case 'ticket_confirmed':
        return const _TypeConfig(Icons.confirmation_num_rounded, AppColors.cyan);
      case 'escrow_update':
        return const _TypeConfig(
            Icons.account_balance_wallet_rounded, AppColors.purple);
      case 'happening_expiring':
        return const _TypeConfig(Icons.timer_rounded, AppColors.warning);
      case 'new_snap':
        return const _TypeConfig(Icons.camera_alt_rounded, AppColors.magenta);
      case 'verification_update':
        return const _TypeConfig(Icons.verified_rounded, AppColors.success);
      case 'refund_complete':
        return const _TypeConfig(Icons.replay_rounded, AppColors.success);
      default:
        return const _TypeConfig(Icons.notifications_rounded, AppColors.cyan);
    }
  }
}

class _TypeConfig {
  const _TypeConfig(this.icon, this.color);
  final IconData icon;
  final Color color;
}
