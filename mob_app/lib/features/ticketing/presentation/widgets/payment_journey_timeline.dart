import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/models/enums.dart';
import '../../domain/entities/ticket.dart';


class PaymentJourneyTimeline extends StatelessWidget {
  const PaymentJourneyTimeline({
    super.key,
    required this.ticket,
  });


  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < steps.length; i++)
          _TimelineStep(
            step: steps[i],
            isLast: i == steps.length - 1,
          ),
      ],
    );
  }


  List<_StepData> _buildSteps() {
    final escrow = ticket.escrowStatus;
    final isRefunding = escrow == EscrowStatus.refunding;
    final isRefunded = escrow == EscrowStatus.refunded;

    if (isRefunding || isRefunded) {
      return _buildRefundSteps(isRefunded);
    }

    return _buildNormalSteps();
  }

  List<_StepData> _buildNormalSteps() {
    final escrow = ticket.escrowStatus;
    final isPaid = ticket.isPaid;


    final int currentIndex;
    if (escrow == EscrowStatus.released) {
      currentIndex = 4;
    } else if (escrow == EscrowStatus.awaitingCompletion) {
      currentIndex = 2;
    } else if (escrow == EscrowStatus.held) {
      currentIndex = 1;
    } else if (isPaid) {
      currentIndex = 1;
    } else {
      currentIndex = 0;
    }

    return [
      _StepData(
        title: 'Payment Secured',
        description:
            'Your ${ticket.formattedAmount} payment has been received '
            'and secured.',
        timestamp: ticket.paidAt,
        status: currentIndex >= 1
            ? _StepStatus.completed
            : (currentIndex == 0 && isPaid
                ? _StepStatus.current
                : _StepStatus.pending),
        icon: Icons.lock_outlined,
      ),
      _StepData(
        title: 'Funds Held in Escrow',
        description: 'Your funds are held safely. They cannot be '
            'accessed by the host yet.',
        status: currentIndex >= 2
            ? _StepStatus.completed
            : (currentIndex == 1
                ? _StepStatus.current
                : _StepStatus.pending),
        icon: Icons.account_balance_outlined,
      ),
      _StepData(
        title: 'Event Confirmed',
        description: 'The host has confirmed the event took place.',
        status: currentIndex >= 3
            ? _StepStatus.completed
            : (currentIndex == 2
                ? _StepStatus.current
                : _StepStatus.pending),
        icon: Icons.check_circle_outline,
      ),
      _StepData(
        title: 'Payout Released',
        description: 'Event verified! The host has been paid.',
        status: currentIndex >= 4
            ? _StepStatus.completed
            : (currentIndex == 3
                ? _StepStatus.current
                : _StepStatus.pending),
        icon: Icons.payments_outlined,
      ),
    ];
  }

  List<_StepData> _buildRefundSteps(bool isComplete) {
    return [

      _StepData(
        title: 'Payment Secured',
        description:
            'Your ${ticket.formattedAmount} payment was received.',
        timestamp: ticket.paidAt,
        status: _StepStatus.completed,
        icon: Icons.lock_outlined,
      ),

      const _StepData(
        title: 'Funds Held in Escrow',
        description: 'Your funds were held in escrow.',
        status: _StepStatus.completed,
        icon: Icons.account_balance_outlined,
      ),

      if (isComplete)
        _StepData(
          title: 'Refund Completed',
          description:
              'Refund of ${ticket.formattedAmount} completed'
              '${ticket.refundedAt != null ? ' on ${_formatDate(ticket.refundedAt!)}' : ''}.',
          timestamp: ticket.refundedAt,
          status: _StepStatus.completed,
          icon: Icons.undo_rounded,
          color: AppColors.warning,
        )
      else
        _StepData(
          title: 'Refund Processing',
          description:
              'A refund of ${ticket.formattedAmount} is being '
              'processed. Expected within 48 hours.',
          status: _StepStatus.current,
          icon: Icons.undo_rounded,
          color: AppColors.warning,
        ),
    ];
  }

  String _formatDate(DateTime dateTime) {
    return DateFormat('MMM d, yyyy').format(dateTime);
  }
}


enum _StepStatus { completed, current, pending }

class _StepData {
  const _StepData({
    required this.title,
    required this.description,
    required this.status,
    required this.icon,
    this.timestamp,
    this.color,
  });

  final String title;
  final String description;
  final _StepStatus status;
  final IconData icon;
  final DateTime? timestamp;


  final Color? color;
}


class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.step,
    this.isLast = false,
  });

  final _StepData step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _buildIndicatorColumn(),

          AppSpacing.horizontalBase,


          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : AppSpacing.lg,
              ),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorColumn() {
    return SizedBox(
      width: 36,
      child: Column(
        children: [

          _buildCircle(),


          if (!isLast)
            Expanded(
              child: Container(
                width: 2,
                color: step.status == _StepStatus.completed
                    ? _activeColor
                    : AppColors.surface,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCircle() {
    const size = 36.0;

    switch (step.status) {
      case _StepStatus.completed:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _activeColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            color: _activeColor,
            size: 20,
          ),
        );

      case _StepStatus.current:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: _activeColor.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: _activeColor.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: _activeColor.withValues(alpha: 0.25),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(
            step.icon,
            color: _activeColor,
            size: 18,
          ),
        );

      case _StepStatus.pending:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.surface,
              width: 2,
            ),
          ),
          child: Icon(
            step.icon,
            color: AppColors.textTertiary,
            size: 16,
          ),
        );
    }
  }

  Widget _buildContent() {
    final titleColor = step.status == _StepStatus.pending
        ? AppColors.textTertiary
        : AppColors.textPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Text(
            step.title,
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
        ),

        AppSpacing.verticalXs,


        Text(
          step.description,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),


        if (step.timestamp != null) ...[
          AppSpacing.verticalXs,
          Text(
            DateFormat('MMM d, yyyy \u2022 h:mm a').format(step.timestamp!),
            style: AppTypography.micro.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }

  Color get _activeColor {
    if (step.color != null) return step.color!;
    return step.status == _StepStatus.completed
        ? AppColors.success
        : AppColors.cyan;
  }
}
