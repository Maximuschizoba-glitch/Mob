import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../bloc/ticket_cubit.dart';
import '../bloc/ticket_state.dart';
import '../widgets/payment_journey_timeline.dart';


class TicketDetailPage extends StatelessWidget {
  const TicketDetailPage({
    super.key,
    required this.ticketUuid,
  });


  final String ticketUuid;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => TicketCubit(
        ticketRepository: ctx.read<TicketRepository>(),
      )..loadTicketDetail(ticketUuid),
      child: const _TicketDetailView(),
    );
  }
}


class _TicketDetailView extends StatelessWidget {
  const _TicketDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<TicketCubit, TicketState>(
          listenWhen: (prev, curr) => curr is TicketError,
          listener: (context, state) {

            if (state is TicketError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          builder: (context, state) {
            if (state is TicketsLoading) {
              return _buildLoadingState();
            }

            if (state is TicketDetailLoaded) {
              return _buildDetailContent(context, state.ticket);
            }

            if (state is TicketError) {
              return Column(
                children: [
                  const _AppBar(ticket: null),
                  Expanded(
                    child: MobErrorState(
                      message: state.message,
                      onRetry: () => context
                          .read<TicketCubit>()
                          .loadTicketDetail(

                            context
                                .findAncestorWidgetOfExactType<
                                    TicketDetailPage>()!
                                .ticketUuid,
                          ),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }


  Widget _buildLoadingState() {
    return Shimmer.fromColors(
      baseColor: AppColors.card,
      highlightColor: AppColors.elevated,
      child: Padding(
        padding: AppSpacing.screenPaddingAll,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.elevated,
                    shape: BoxShape.circle,
                  ),
                ),
                AppSpacing.horizontalBase,
                Container(
                  width: 120,
                  height: 20,
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),
              ],
            ),
            AppSpacing.verticalXl,

            Container(
              width: double.infinity,
              height: 360,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusLg),
              ),
            ),
            AppSpacing.verticalXl,

            Container(
              width: 160,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.elevated,
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusSm),
              ),
            ),
            AppSpacing.verticalBase,

            for (int i = 0; i < 3; i++) ...[
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: AppColors.elevated,
                      shape: BoxShape.circle,
                    ),
                  ),
                  AppSpacing.horizontalBase,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.elevated,
                            borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSm),
                          ),
                        ),
                        AppSpacing.verticalSm,
                        Container(
                          width: 200,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.elevated,
                            borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSm),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalLg,
            ],
          ],
        ),
      ),
    );
  }


  Widget _buildDetailContent(BuildContext context, Ticket ticket) {
    return Column(
      children: [
        _AppBar(ticket: ticket),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                _TicketVisualCard(ticket: ticket),

                AppSpacing.verticalXl,


                const MobSectionLabel(label: 'Payment Journey'),
                AppSpacing.verticalBase,
                PaymentJourneyTimeline(ticket: ticket),

                AppSpacing.verticalXl,


                _BuyerProtectionCard(ticket: ticket),

                AppSpacing.verticalXl,


                _ActionButtons(ticket: ticket),


                AppSpacing.verticalXxl,
              ],
            ),
          ),
        ),
      ],
    );
  }
}


class _AppBar extends StatelessWidget {
  const _AppBar({required this.ticket});

  final Ticket? ticket;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
        0,
      ),
      child: Row(
        children: [

          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: AppColors.textPrimary,
              size: 20,
            ),
          ),
          const Expanded(
            child: Text(
              'Ticket Details',
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
          ),

          IconButton(
            onPressed: ticket != null ? () => _shareTicket(ticket!) : null,
            icon: Icon(
              Icons.share_outlined,
              color: ticket != null
                  ? AppColors.textSecondary
                  : AppColors.textDisabled,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  void _shareTicket(Ticket ticket) {
    final title = ticket.happeningTitle ?? 'an event';
    final dateStr = ticket.happeningStartsAt != null
        ? ' on ${DateFormat('MMM d, yyyy').format(ticket.happeningStartsAt!)}'
        : '';
    final ticketUrl = AppConfig.ticketShareUrl(ticket.uuid);
    Share.share(
      'I got my ticket for $title$dateStr! Check it out on Mob.\n$ticketUrl',
    );
  }
}


class _TicketVisualCard extends StatelessWidget {
  const _TicketVisualCard({required this.ticket});

  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
        border: Border.all(
          color: AppColors.border,
          width: 0.5,
        ),
      ),
      child: Column(
        children: [

          _buildTopSection(),


          _buildDashedTearLine(),


          _buildBottomSection(),
        ],
      ),
    );
  }

  Widget _buildTopSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.cyan, AppColors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSpacing.radiusXl),
          topRight: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _buildStatusBadge(),
          AppSpacing.verticalMd,


          Text(
            ticket.happeningTitle ?? 'Event',
            style: AppTypography.h2.copyWith(
              color: Colors.white,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          AppSpacing.verticalBase,


          if (ticket.happeningAddress != null) ...[
            _buildInfoRow(
              icon: Icons.location_on_outlined,
              text: ticket.happeningAddress!,
            ),
            AppSpacing.verticalSm,
          ],


          if (ticket.happeningStartsAt != null)
            _buildInfoRow(
              icon: Icons.calendar_today_outlined,
              text: DateFormat('EEEE, MMM d, yyyy • h:mm a')
                  .format(ticket.happeningStartsAt!),
            ),

          AppSpacing.verticalBase,


          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Amount Paid',
                style: AppTypography.bodySmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
              Text(
                ticket.formattedAmount,
                style: AppTypography.h3.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final String label;

    if (ticket.isRefunded) {
      label = 'REFUNDED';
    } else if (ticket.isRefundInProgress) {
      label = 'REFUND PROCESSING';
    } else if (ticket.isPaid) {
      label = 'PAID';
    } else {
      label = 'PENDING';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      ),
      child: Text(
        label,
        style: AppTypography.micro.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildInfoRow({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white.withValues(alpha: 0.8),
          size: 16,
        ),
        AppSpacing.horizontalSm,
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: Colors.white.withValues(alpha: 0.9),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildDashedTearLine() {
    return SizedBox(
      height: 24,
      child: Row(
        children: [

          Container(
            width: 12,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
          ),

          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                const dashWidth = 6.0;
                const dashSpace = 4.0;
                final dashCount =
                    (constraints.maxWidth / (dashWidth + dashSpace)).floor();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(dashCount, (i) {
                    return Container(
                      width: dashWidth,
                      height: 1.5,
                      margin: EdgeInsets.only(
                        right: i < dashCount - 1 ? dashSpace : 0,
                      ),
                      color: AppColors.surface,
                    );
                  }),
                );
              },
            ),
          ),

          Container(
            width: 12,
            height: 24,
            decoration: const BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.sm,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      child: Column(
        children: [

          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: QrImageView(
              data: 'mob://ticket/${ticket.uuid}',
              version: QrVersions.auto,
              size: 180,
              backgroundColor: Colors.white,
              errorCorrectionLevel: QrErrorCorrectLevel.M,
            ),
          ),

          AppSpacing.verticalMd,


          Text(
            'Ticket #${_truncateUuid(ticket.uuid)}',
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w500,
              letterSpacing: 1,
            ),
          ),

          AppSpacing.verticalXs,


          Text(
            'Show this QR code at the event entrance',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  String _truncateUuid(String uuid) {
    return uuid.length >= 8 ? uuid.substring(0, 8).toUpperCase() : uuid;
  }
}


class _BuyerProtectionCard extends StatelessWidget {
  const _BuyerProtectionCard({required this.ticket});

  final Ticket ticket;

  @override
  Widget build(BuildContext context) {
    return MobCard(
      backgroundColor: AppColors.success.withValues(alpha: 0.08),
      borderColor: AppColors.success.withValues(alpha: 0.2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.shield_outlined,
              color: AppColors.success,
              size: 22,
            ),
          ),

          AppSpacing.horizontalMd,


          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Buyer Protection',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.success,
                  ),
                ),
                AppSpacing.verticalXs,
                Text(
                  'Your payment is held in escrow until the event is '
                  'confirmed. If the event is cancelled, you\'ll '
                  'receive a full refund within 48 hours.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.ticket});

  final Ticket ticket;


  bool get _canRequestRefund {
    return ticket.isPaid &&
        ticket.escrowStatus != null &&
        (ticket.escrowStatus!.name == 'collecting' ||
            ticket.escrowStatus!.name == 'held');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        if (ticket.isPaid)
          MobOutlinedButton(
            label: 'Contact Host',
            icon: Icons.chat_bubble_outline_rounded,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Host contact coming soon!'),
                  backgroundColor: AppColors.elevated,
                ),
              );
            },
          ),


        if (_canRequestRefund) ...[
          AppSpacing.verticalMd,
          MobTextButton(
            label: 'Request Refund',
            color: AppColors.error,
            onPressed: () => _showRefundConfirmation(context),
          ),
        ],
      ],
    );
  }

  void _showRefundConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Text(
          'Request Refund?',
          style: AppTypography.h3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to request a refund of '
          '${ticket.formattedAmount}? This action cannot be undone. '
          'Refunds are typically processed within 48 hours.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Cancel',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<TicketCubit>().requestRefund(ticket.uuid);
            },
            child: Text(
              'Request Refund',
              style: AppTypography.body.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
