import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/entities/app_notification.dart';


class NotificationCard extends StatelessWidget {
  const NotificationCard({
    super.key,
    required this.notification,
    required this.onTap,
  });

  final AppNotification notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isUnread = notification.isUnread;
    final typeConfig = _typeConfig(notification.type);

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: isUnread
              ? AppColors.cyan.withValues(alpha: 0.04)
              : Colors.transparent,
          border: const Border(
            bottom: BorderSide(
              color: AppColors.border,
              width: 0.5,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: typeConfig.color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                typeConfig.icon,
                size: 20,
                color: typeConfig.color,
              ),
            ),

            const SizedBox(width: AppSpacing.md),


            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Text(
                    notification.title,
                    style: AppTypography.buttonSmall.copyWith(
                      fontWeight:
                          isUnread ? FontWeight.w600 : FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 2),


                  Text(
                    notification.body,
                    style: AppTypography.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: AppSpacing.xs),


                  Text(
                    _relativeTime(notification.createdAt),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),


            if (isUnread) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: const BoxDecoration(
                  color: AppColors.cyan,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }


  static _NotificationTypeConfig _typeConfig(String type) {
    switch (type) {
      case 'ticket_confirmed':
        return const _NotificationTypeConfig(
          icon: Icons.confirmation_num_rounded,
          color: AppColors.cyan,
        );
      case 'escrow_update':
        return const _NotificationTypeConfig(
          icon: Icons.account_balance_wallet_rounded,
          color: AppColors.purple,
        );
      case 'happening_expiring':
        return const _NotificationTypeConfig(
          icon: Icons.timer_rounded,
          color: AppColors.warning,
        );
      case 'new_snap':
        return const _NotificationTypeConfig(
          icon: Icons.camera_alt_rounded,
          color: AppColors.magenta,
        );
      case 'verification_update':
        return const _NotificationTypeConfig(
          icon: Icons.verified_rounded,
          color: AppColors.success,
        );
      case 'refund_complete':
        return const _NotificationTypeConfig(
          icon: Icons.replay_rounded,
          color: AppColors.success,
        );
      default:
        return const _NotificationTypeConfig(
          icon: Icons.notifications_rounded,
          color: AppColors.cyan,
        );
    }
  }


  static String _relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return '${m}m ago';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return '${h}h ago';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays}d ago';


    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${dateTime.day} ${months[dateTime.month - 1]}';
  }
}


class _NotificationTypeConfig {
  const _NotificationTypeConfig({
    required this.icon,
    required this.color,
  });

  final IconData icon;
  final Color color;
}
