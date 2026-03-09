import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../features/feed/domain/entities/happening.dart';


class HappeningCountdown extends StatelessWidget {
  const HappeningCountdown({
    super.key,
    required this.happening,
  });

  final Happening happening;

  @override
  Widget build(BuildContext context) {


    if (happening.isUpcoming && happening.startsAt != null) {
      return _StartsInCountdown(startsAt: happening.startsAt!);
    }


    return _ExpiryCountdownInternal(expiresAt: happening.expiresAt);
  }
}


class _StartsInCountdown extends StatefulWidget {
  const _StartsInCountdown({required this.startsAt});

  final DateTime startsAt;

  @override
  State<_StartsInCountdown> createState() => _StartsInCountdownState();
}

class _StartsInCountdownState extends State<_StartsInCountdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.startsAt.difference(DateTime.now());

    if (remaining.isNegative) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.play_circle_outline, size: 14, color: AppColors.magenta),
          const SizedBox(width: 4),
          Text(
            'Starting now!',
            style: AppTypography.countdown.copyWith(color: AppColors.magenta),
          ),
        ],
      );
    }

    final text = _formatRemaining(remaining);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.event, size: 14, color: AppColors.cyan),
        const SizedBox(width: 4),
        Text(
          'Starts in $text',
          style: AppTypography.countdown.copyWith(color: AppColors.cyan),
        ),
      ],
    );
  }

  String _formatRemaining(Duration d) {
    if (d.inDays > 0) {
      return '${d.inDays}d ${d.inHours.remainder(24)}h';
    }
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m';
    }
    return '${d.inMinutes}m';
  }
}


class _ExpiryCountdownInternal extends StatefulWidget {
  const _ExpiryCountdownInternal({required this.expiresAt});

  final DateTime expiresAt;

  @override
  State<_ExpiryCountdownInternal> createState() =>
      _ExpiryCountdownInternalState();
}

class _ExpiryCountdownInternalState extends State<_ExpiryCountdownInternal> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final remaining = widget.expiresAt.difference(DateTime.now());
    final isExpired = remaining.isNegative;
    final isUrgent = !isExpired && remaining.inMinutes < 60;

    final color = (isExpired || isUrgent) ? AppColors.error : AppColors.warning;

    final text = isExpired ? 'Expired' : _formatRemaining(remaining);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isExpired ? Icons.timer_off_outlined : Icons.timer_outlined,
          color: color,
          size: 14,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTypography.countdown.copyWith(color: color),
        ),
      ],
    );
  }

  String _formatRemaining(Duration d) {
    if (d.inHours > 0) {
      return '${d.inHours}h ${d.inMinutes.remainder(60)}m left';
    }
    return '${d.inMinutes}m left';
  }
}
