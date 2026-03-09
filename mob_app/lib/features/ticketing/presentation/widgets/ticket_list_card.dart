import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/models/enums.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/ticket.dart';


class TicketListCard extends StatelessWidget {
  const TicketListCard({
    super.key,
    required this.ticket,
    this.onTap,
  });


  final Ticket ticket;


  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return MobCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _buildThumbnail(),

          AppSpacing.horizontalMd,


          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                _buildTitleRow(),

                AppSpacing.verticalSm,


                if (ticket.happeningAddress != null) ...[
                  _buildInfoRow(
                    Icons.location_on_outlined,
                    ticket.happeningAddress!,
                  ),
                  AppSpacing.verticalXs,
                ],


                if (ticket.happeningStartsAt != null)
                  _buildInfoRow(
                    Icons.calendar_today_outlined,
                    _formatDate(ticket.happeningStartsAt!),
                  ),

                AppSpacing.verticalMd,


                _buildBottomRow(),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildThumbnail() {

    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        gradient: LinearGradient(
          colors: [
            AppColors.elevated,
            AppColors.surface.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.confirmation_number_outlined,
          color: _statusColor.withValues(alpha: 0.7),
          size: 32,
        ),
      ),
    );
  }


  Widget _buildTitleRow() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                ticket.happeningTitle ?? 'Event',
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            AppSpacing.horizontalSm,
            _buildStatusBadge(),
          ],
        ),
        if (ticket.ticketNumber != null) ...[
          AppSpacing.verticalXs,
          Text(
            ticket.ticketNumber!,
            style: AppTypography.micro.copyWith(
              fontFamily: 'monospace',
              color: AppColors.textTertiary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatusBadge() {
    return MobBadge(
      label: _statusLabel,
      color: _statusColor,
    );
  }

  String get _statusLabel {

    if (ticket.status == TicketStatus.paid) {
      final escrow = ticket.escrowStatus;
      if (escrow == EscrowStatus.released) return 'COMPLETED';
      if (escrow == EscrowStatus.awaitingCompletion) return 'COMPLETING';
      return 'UPCOMING';
    }

    switch (ticket.status) {
      case TicketStatus.pending:
        return 'PENDING';
      case TicketStatus.refundProcessing:
        return 'REFUNDING';
      case TicketStatus.refunded:
        return 'REFUNDED';
      default:
        return ticket.status.displayName.toUpperCase();
    }
  }

  Color get _statusColor {
    if (ticket.status == TicketStatus.paid) {
      final escrow = ticket.escrowStatus;
      if (escrow == EscrowStatus.released) return AppColors.success;
      if (escrow == EscrowStatus.awaitingCompletion) return AppColors.purple;
      return AppColors.cyan;
    }

    return ticket.status.color;
  }


  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textTertiary, size: 14),
        AppSpacing.horizontalSm,
        Expanded(
          child: Text(
            text,
            style: AppTypography.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }


  Widget _buildBottomRow() {
    return Row(
      children: [

        if (ticket.escrowStatus != null)
          Expanded(
            child: EscrowProgressTracker(
              currentStatus: ticket.escrowStatus!.value,
              compact: true,
            ),
          )
        else
          const Spacer(),

        AppSpacing.horizontalMd,


        Text(
          'View \u2192',
          style: AppTypography.caption.copyWith(
            color: AppColors.cyan,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }


  String _formatDate(DateTime dateTime) {
    return DateFormat('EEE, MMM d \u2022 h:mm a').format(dateTime);
  }
}
