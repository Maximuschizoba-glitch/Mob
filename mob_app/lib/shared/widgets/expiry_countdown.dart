import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';


class ExpiryCountdown extends StatefulWidget {
  const ExpiryCountdown({
    super.key,
    required this.expiresAt,
    this.prefix = 'Expires in ',
  });


  final DateTime expiresAt;


  final String prefix;

  @override
  State<ExpiryCountdown> createState() => _ExpiryCountdownState();
}

class _ExpiryCountdownState extends State<ExpiryCountdown> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void didUpdateWidget(covariant ExpiryCountdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.expiresAt != widget.expiresAt) {
      _timer?.cancel();
      _startTimer();
    }
  }

  void _startTimer() {

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
    final now = DateTime.now();
    final remaining = widget.expiresAt.difference(now);

    final isExpired = remaining.isNegative;
    final isUrgent = !isExpired && remaining.inMinutes < 60;

    final color = isExpired
        ? AppColors.error
        : isUrgent
            ? AppColors.error
            : AppColors.warning;

    final text = isExpired
        ? 'Expired'
        : '${widget.prefix}${_formatDuration(remaining)}';

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isExpired
              ? Icons.timer_off_outlined
              : Icons.timer_outlined,
          color: color,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: AppTypography.countdown.copyWith(color: color),
        ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}
