import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../shared/models/enums.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/escrow.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../bloc/escrow_cubit.dart';
import '../bloc/escrow_state.dart';


class HostDashboardPage extends StatelessWidget {
  const HostDashboardPage({
    super.key,
    required this.happeningUuid,
  });


  final String happeningUuid;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => EscrowCubit(
        ticketRepository: ctx.read<TicketRepository>(),
      )..loadEscrowByHappening(happeningUuid),
      child: _DashboardView(happeningUuid: happeningUuid),
    );
  }
}


class _DashboardView extends StatelessWidget {
  const _DashboardView({required this.happeningUuid});

  final String happeningUuid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocConsumer<EscrowCubit, EscrowState>(
          listener: (context, state) {
            if (state is EscrowError && state.previousEscrow != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
            if (state is EscrowLoaded &&
                state.escrow.status == EscrowStatus.awaitingCompletion) {

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Event marked as complete! Awaiting admin approval.',
                  ),
                  backgroundColor: AppColors.success,
                ),
              );

              if (context.mounted) {
                context.pop();
              }
            }
          },
          listenWhen: (prev, curr) {

            if (prev is EscrowActionLoading && curr is EscrowLoaded) {
              return true;
            }
            if (curr is EscrowError && curr.previousEscrow != null) {
              return true;
            }
            return false;
          },
          builder: (context, state) {
            if (state is EscrowLoading) {
              return _buildLoadingState();
            }

            if (state is EscrowEmpty) {
              return const Column(
                children: [
                  _AppBar(escrow: null),
                  Expanded(child: _PreSalesView()),
                ],
              );
            }

            if (state is EscrowError && state.previousEscrow == null) {
              return Column(
                children: [
                  const _AppBar(escrow: null),
                  Expanded(
                    child: MobErrorState(
                      message: state.message,
                      onRetry: () => context
                          .read<EscrowCubit>()
                          .loadEscrowByHappening(happeningUuid),
                    ),
                  ),
                ],
              );
            }


            final Escrow escrow;
            final bool isActionLoading;

            if (state is EscrowLoaded) {
              escrow = state.escrow;
              isActionLoading = false;
            } else if (state is EscrowActionLoading) {
              escrow = state.escrow;
              isActionLoading = true;
            } else if (state is EscrowError && state.previousEscrow != null) {
              escrow = state.previousEscrow!;
              isActionLoading = false;
            } else {
              return const SizedBox.shrink();
            }

            return _buildDashboardContent(context, escrow, isActionLoading);
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
                  width: 150,
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
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusLg),
              ),
            ),
            AppSpacing.verticalLg,

            Row(
              children: List.generate(3, (_) {
                return Expanded(
                  child: Container(
                    height: 100,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                  ),
                );
              }),
            ),
            AppSpacing.verticalXl,

            Container(
              width: double.infinity,
              height: 140,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusLg),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDashboardContent(
    BuildContext context,
    Escrow escrow,
    bool isActionLoading,
  ) {
    return Column(
      children: [
        _AppBar(escrow: escrow),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => context
                .read<EscrowCubit>()
                .loadEscrowByHappening(happeningUuid),
            color: AppColors.cyan,
            backgroundColor: AppColors.card,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.sm,
              ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                _EventHeaderCard(escrow: escrow),

                AppSpacing.verticalLg,


                _RevenueStatsRow(escrow: escrow),

                AppSpacing.verticalXl,


                _EscrowStatusCard(escrow: escrow),

                AppSpacing.verticalXl,


                _ActivityLogSection(escrow: escrow),

                AppSpacing.verticalXl,


                if (escrow.status == EscrowStatus.awaitingCompletion ||
                    escrow.status == EscrowStatus.released)
                  _EstimatedPayoutCard(escrow: escrow),

                if (escrow.status == EscrowStatus.awaitingCompletion ||
                    escrow.status == EscrowStatus.released)
                  AppSpacing.verticalXl,


                _ActionButtons(
                  escrow: escrow,
                  isActionLoading: isActionLoading,
                  happeningUuid: happeningUuid,
                ),


                AppSpacing.verticalXxl,
              ],
            ),
          ),
          ),
        ),
      ],
    );
  }
}


class _PreSalesView extends StatelessWidget {
  const _PreSalesView();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.cyan.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.confirmation_number_outlined,
              color: AppColors.cyan.withValues(alpha: 0.6),
              size: 40,
            ),
          ),

          AppSpacing.verticalLg,


          Text(
            'No Ticket Sales Yet',
            style: AppTypography.h3.copyWith(
              color: AppColors.textPrimary,
            ),
          ),

          AppSpacing.verticalSm,


          Text(
            'Your escrow dashboard will appear here once\n'
            'the first ticket is purchased.',
            textAlign: TextAlign.center,
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),

          AppSpacing.verticalXl,


          MobCard(
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MobSectionLabel(label: 'What to expect'),
                AppSpacing.verticalBase,
                _infoRow(
                  Icons.shield_outlined,
                  AppColors.success,
                  'Funds are held securely in escrow',
                ),
                AppSpacing.verticalMd,
                _infoRow(
                  Icons.bar_chart_rounded,
                  AppColors.cyan,
                  'Track revenue and ticket sales in real-time',
                ),
                AppSpacing.verticalMd,
                _infoRow(
                  Icons.payments_outlined,
                  AppColors.purple,
                  'Receive payout after event completion',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, Color color, String text) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: color, size: 16),
        ),
        AppSpacing.horizontalMd,
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}


class _AppBar extends StatelessWidget {
  const _AppBar({required this.escrow});

  final Escrow? escrow;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.lg,
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
              'Event Dashboard',
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),
          ),
          if (escrow != null)
            _buildStatusBadge(escrow!)
          else
            const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(Escrow escrow) {

    final now = DateTime.now();
    final startsAt = escrow.happeningStartsAt;

    if (startsAt != null && startsAt.isAfter(now)) {
      return const MobBadge(label: 'UPCOMING', color: AppColors.cyan);
    }

    if (escrow.status == EscrowStatus.collecting ||
        escrow.status == EscrowStatus.held) {
      return const MobBadge(label: 'LIVE', color: AppColors.magenta);
    }

    return const MobBadge(
      label: 'ENDED',
      color: AppColors.textTertiary,
    );
  }
}


class _EventHeaderCard extends StatelessWidget {
  const _EventHeaderCard({required this.escrow});

  final Escrow escrow;

  @override
  Widget build(BuildContext context) {
    return MobCard(
      child: Row(
        children: [

          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.event_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),

          AppSpacing.horizontalMd,


          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  escrow.happeningTitle ?? 'Event',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                AppSpacing.verticalXs,
                if (escrow.happeningStartsAt != null)
                  Text(
                    DateFormat('EEE, MMM d • h:mm a')
                        .format(escrow.happeningStartsAt!),
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                if (escrow.happeningAddress != null) ...[
                  AppSpacing.verticalXs,
                  Text(
                    escrow.happeningAddress!,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _RevenueStatsRow extends StatelessWidget {
  const _RevenueStatsRow({required this.escrow});

  final Escrow escrow;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [

        Expanded(
          child: _StatCard(
            icon: Icons.confirmation_number_outlined,
            iconColor: AppColors.cyan,
            value: '${escrow.ticketsCount}',
            subtitle: 'tickets sold',
          ),
        ),
        AppSpacing.horizontalSm,


        Expanded(
          child: _StatCard(
            icon: Icons.account_balance_wallet_outlined,
            iconColor: AppColors.success,
            value: _formatAmount(escrow.totalAmount),
            valueColor: AppColors.success,
            subtitle: 'Total revenue',
          ),
        ),
        AppSpacing.horizontalSm,


        Expanded(
          child: _StatCard(
            icon: Icons.payments_outlined,
            iconColor: AppColors.cyan,
            value: _formatAmount(escrow.hostPayoutAmount),
            valueColor: AppColors.cyan,
            subtitle: 'After 10% fee',
            footnote: 'Fee: ${_formatAmount(escrow.platformFee)}',
          ),
        ),
      ],
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000) {
      final formatter = NumberFormat('#,##0', 'en_US');
      return '\u20A6${formatter.format(amount.toInt())}';
    }
    return '\u20A6${amount.toStringAsFixed(0)}';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.subtitle,
    this.valueColor,
    this.footnote,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final Color? valueColor;
  final String subtitle;
  final String? footnote;

  @override
  Widget build(BuildContext context) {
    return MobCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 20),
          AppSpacing.verticalSm,
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: AppTypography.h3.copyWith(
                color: valueColor ?? AppColors.textPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          AppSpacing.verticalXs,
          Text(
            subtitle,
            style: AppTypography.micro.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          if (footnote != null) ...[
            AppSpacing.verticalXs,
            Text(
              footnote!,
              style: AppTypography.micro.copyWith(
                color: AppColors.textTertiary,
                fontSize: 9,
              ),
            ),
          ],
        ],
      ),
    );
  }
}


class _EscrowStatusCard extends StatelessWidget {
  const _EscrowStatusCard({required this.escrow});

  final Escrow escrow;

  @override
  Widget build(BuildContext context) {
    return MobCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MobSectionLabel(label: 'Escrow Status'),
          AppSpacing.verticalBase,


          Row(
            children: [

              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: escrow.status.color.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(
                  _statusIcon(escrow.status),
                  color: escrow.status.color,
                  size: 22,
                ),
              ),
              AppSpacing.horizontalMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _statusLabel(escrow.status),
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: escrow.status.color,
                      ),
                    ),
                    AppSpacing.verticalXs,
                    Text(
                      _statusDescription(escrow.status),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          AppSpacing.verticalLg,


          EscrowProgressTracker(
            currentStatus: escrow.status.value,
            eventHasStarted: _eventHasStarted,
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(EscrowStatus status) {
    switch (status) {
      case EscrowStatus.collecting:
        return _eventHasStarted
            ? Icons.lock_outline_rounded
            : Icons.sync_rounded;
      case EscrowStatus.held:
        return Icons.lock_outline_rounded;
      case EscrowStatus.awaitingCompletion:
        return Icons.hourglass_bottom_rounded;
      case EscrowStatus.released:
        return Icons.check_circle_outline_rounded;
      case EscrowStatus.refunding:
        return Icons.undo_rounded;
      case EscrowStatus.refunded:
        return Icons.check_circle_outline_rounded;
      case EscrowStatus.disputed:
        return Icons.warning_amber_rounded;
    }
  }

  String _statusLabel(EscrowStatus status) {
    switch (status) {
      case EscrowStatus.collecting:
        return _eventHasStarted ? 'HELD' : 'COLLECTING';
      case EscrowStatus.held:
        return 'HELD';
      case EscrowStatus.awaitingCompletion:
        return 'AWAITING REVIEW';
      case EscrowStatus.released:
        return 'RELEASED';
      case EscrowStatus.refunding:
        return 'REFUNDING';
      case EscrowStatus.refunded:
        return 'REFUNDED';
      case EscrowStatus.disputed:
        return 'DISPUTED';
    }
  }


  bool get _eventHasStarted {
    final startsAt = escrow.happeningStartsAt;
    if (startsAt == null) return false;
    return startsAt.isBefore(DateTime.now());
  }

  String _statusDescription(EscrowStatus status) {
    switch (status) {
      case EscrowStatus.collecting:
        if (_eventHasStarted) {
          return 'Event is live. Funds are transitioning to held.';
        }
        return 'Tickets are being sold. Funds are accumulating.';
      case EscrowStatus.held:
        return 'Event is live. Funds are locked securely.';
      case EscrowStatus.awaitingCompletion:
        return "You've marked complete. Awaiting admin verification.";
      case EscrowStatus.released:
        return 'Funds released! Payout is being processed.';
      case EscrowStatus.refunding:
        return 'Refunds are being processed to all ticket holders.';
      case EscrowStatus.refunded:
        return 'All ticket holders have been refunded.';
      case EscrowStatus.disputed:
        return 'This transaction is under review by an admin.';
    }
  }
}


class _ActivityLogSection extends StatefulWidget {
  const _ActivityLogSection({required this.escrow});

  final Escrow escrow;

  @override
  State<_ActivityLogSection> createState() => _ActivityLogSectionState();
}

class _ActivityLogSectionState extends State<_ActivityLogSection> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final events = widget.escrow.events ?? [];

    return MobCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          GestureDetector(
            onTap: () => setState(() => _isExpanded = !_isExpanded),
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                MobSectionLabel(
                  label: 'Activity Log',
                  trailing: Text(
                    events.isEmpty
                        ? ''
                        : '${events.length} event${events.length == 1 ? '' : 's'}',
                    style: AppTypography.micro.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  ),
                ),
                Icon(
                  _isExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: AppColors.textTertiary,
                  size: 24,
                ),
              ],
            ),
          ),

          if (_isExpanded) ...[
            AppSpacing.verticalBase,

            if (events.isEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Text(
                  'No activity recorded yet',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              )
            else

              ...events.reversed.map(
                (event) => _ActivityLogEntry(event: event),
              ),
          ],
        ],
      ),
    );
  }
}

class _ActivityLogEntry extends StatelessWidget {
  const _ActivityLogEntry({required this.event});

  final EscrowEvent event;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: _actionColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(
              _actionIcon,
              color: _actionColor,
              size: 16,
            ),
          ),

          AppSpacing.horizontalMd,


          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _actionDescription,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
                AppSpacing.verticalXs,
                Row(
                  children: [
                    Text(
                      DateFormat('MMM d, h:mm a').format(event.createdAt),
                      style: AppTypography.micro.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                    if (event.performedByName != null) ...[
                      Text(
                        ' \u2022 ',
                        style: AppTypography.micro.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                      Text(
                        event.performedByName!,
                        style: AppTypography.micro.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String get _actionDescription {
    switch (event.action) {
      case EscrowAction.created:
        return 'Escrow created for this event';
      case EscrowAction.ticketAdded:
        final amount = event.metadata?['amount'];
        if (amount != null) {
          return 'Ticket purchased (\u20A6${_formatNum(amount)})';
        }
        return 'Ticket purchased';
      case EscrowAction.ticketRefunded:
        return 'Ticket refunded';
      case EscrowAction.hostMarkedComplete:
        return 'Event marked as complete by host';
      case EscrowAction.adminApproved:
        return 'Admin approved — funds released';
      case EscrowAction.adminRejected:
        final reason = event.metadata?['reason'] ?? '';
        return 'Admin rejected${reason.isNotEmpty ? ': $reason' : ''}';
      case EscrowAction.fundsReleased:
        return 'Funds released to host';
      case EscrowAction.refundInitiated:
        return 'Refund process initiated';
      case EscrowAction.refundCompleted:
        return 'All refunds completed';
      case EscrowAction.adminOverride:
        return 'Admin override action';
      case EscrowAction.eventStarted:
        return 'Event started — funds held';
      case null:
        return 'Unknown activity';
    }
  }

  String _formatNum(dynamic value) {
    final num = double.tryParse(value.toString()) ?? 0;
    if (num >= 1000) {
      return NumberFormat('#,##0', 'en_US').format(num.toInt());
    }
    return num.toStringAsFixed(0);
  }

  IconData get _actionIcon {
    switch (event.action) {
      case EscrowAction.created:
        return Icons.add_circle_outline_rounded;
      case EscrowAction.ticketAdded:
        return Icons.confirmation_number_outlined;
      case EscrowAction.ticketRefunded:
        return Icons.undo_rounded;
      case EscrowAction.hostMarkedComplete:
        return Icons.check_circle_outline_rounded;
      case EscrowAction.adminApproved:
        return Icons.verified_outlined;
      case EscrowAction.adminRejected:
        return Icons.cancel_outlined;
      case EscrowAction.fundsReleased:
        return Icons.payments_outlined;
      case EscrowAction.refundInitiated:
        return Icons.undo_rounded;
      case EscrowAction.refundCompleted:
        return Icons.check_circle_outline_rounded;
      case EscrowAction.adminOverride:
        return Icons.admin_panel_settings_outlined;
      case EscrowAction.eventStarted:
        return Icons.play_circle_outline_rounded;
      case null:
        return Icons.info_outline_rounded;
    }
  }

  Color get _actionColor {
    switch (event.action) {
      case EscrowAction.created:
        return AppColors.cyan;
      case EscrowAction.ticketAdded:
        return AppColors.success;
      case EscrowAction.ticketRefunded:
        return AppColors.warning;
      case EscrowAction.hostMarkedComplete:
        return AppColors.purple;
      case EscrowAction.adminApproved:
        return AppColors.success;
      case EscrowAction.adminRejected:
        return AppColors.error;
      case EscrowAction.fundsReleased:
        return AppColors.success;
      case EscrowAction.refundInitiated:
        return AppColors.warning;
      case EscrowAction.refundCompleted:
        return AppColors.textSecondary;
      case EscrowAction.adminOverride:
        return AppColors.purple;
      case EscrowAction.eventStarted:
        return AppColors.success;
      case null:
        return AppColors.textTertiary;
    }
  }
}


class _EstimatedPayoutCard extends StatelessWidget {
  const _EstimatedPayoutCard({required this.escrow});

  final Escrow escrow;

  @override
  Widget build(BuildContext context) {
    return MobCard(
      backgroundColor: AppColors.cyan.withValues(alpha: 0.06),
      borderColor: AppColors.cyan.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MobSectionLabel(
            label: 'Estimated Payout',
            color: AppColors.cyan,
          ),
          AppSpacing.verticalBase,


          Text(
            escrow.formattedHostPayout,
            style: AppTypography.h1.copyWith(
              color: AppColors.cyan,
              fontWeight: FontWeight.w700,
            ),
          ),

          AppSpacing.verticalSm,

          Text(
            'Platform fee (10%): ${escrow.formattedPlatformFee}',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          AppSpacing.verticalSm,

          Text(
            escrow.status == EscrowStatus.released
                ? 'Payout has been initiated and is being processed.'
                : 'Payout will be processed within 24-48 hours after admin approval.',
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}


class _ActionButtons extends StatelessWidget {
  const _ActionButtons({
    required this.escrow,
    required this.isActionLoading,
    required this.happeningUuid,
  });

  final Escrow escrow;
  final bool isActionLoading;
  final String happeningUuid;


  bool get _eventHasStarted {
    final startsAt = escrow.happeningStartsAt;
    if (startsAt == null) return false;
    return startsAt.isBefore(DateTime.now());
  }


  bool get _canMarkComplete {
    if (escrow.status != EscrowStatus.held &&
        escrow.status != EscrowStatus.collecting) {
      return false;
    }
    if (escrow.hostCompletedAt != null) {
      return false;
    }
    return _eventHasStarted;
  }


  bool get _canCancel {
    return escrow.status == EscrowStatus.collecting ||
        escrow.status == EscrowStatus.held;
  }


  bool get _canScan {
    return escrow.status == EscrowStatus.collecting ||
        escrow.status == EscrowStatus.held;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [

        if (_canScan) ...[
          MobOutlinedButton(
            label: 'Scan Tickets',
            icon: Icons.qr_code_scanner_rounded,
            onPressed: () => context.push(
              RoutePaths.ticketScannerPath(happeningUuid),
            ),
          ),
          AppSpacing.verticalBase,
        ],


        _buildPrimaryAction(context),

        AppSpacing.verticalBase,


        _buildStatusIndicator(),


        if (_canCancel) ...[
          AppSpacing.verticalLg,
          Center(
            child: MobTextButton(
              label: 'Cancel Event & Refund All',
              color: AppColors.error,
              onPressed: () => _showCancelDialog(context),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildPrimaryAction(BuildContext context) {
    switch (escrow.status) {

      case EscrowStatus.collecting:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MobGradientButton(
              label: 'Mark Event Complete',
              onPressed: _canMarkComplete
                  ? () => _showMarkCompleteDialog(context)
                  : null,
              isLoading: isActionLoading,
            ),
            if (!_canMarkComplete) ...[
              AppSpacing.verticalSm,
              Text(
                'Available after event starts',
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ],
        );


      case EscrowStatus.held:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            MobGradientButton(
              label: 'Mark Event Complete',
              onPressed: _canMarkComplete
                  ? () => _showMarkCompleteDialog(context)
                  : null,
              isLoading: isActionLoading,
            ),
            if (!_canMarkComplete) ...[
              AppSpacing.verticalSm,
              Text(
                'Available after event starts',
                textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ],
        );


      case EscrowStatus.awaitingCompletion:
        return _statusBanner(
          icon: Icons.hourglass_bottom_rounded,
          label: 'Awaiting Admin Review',
          color: AppColors.purple,
        );


      case EscrowStatus.released:
        return _statusBanner(
          icon: Icons.check_circle_rounded,
          label: 'EVENT COMPLETED \u2705',
          color: AppColors.success,
        );


      case EscrowStatus.refunding:
        return _statusBanner(
          icon: Icons.undo_rounded,
          label: 'Refunds In Progress',
          color: AppColors.warning,
        );
      case EscrowStatus.refunded:
        return _statusBanner(
          icon: Icons.check_circle_outline_rounded,
          label: 'All Buyers Refunded',
          color: AppColors.warning,
        );


      case EscrowStatus.disputed:
        return _statusBanner(
          icon: Icons.warning_amber_rounded,
          label: 'Under Review',
          color: AppColors.error,
        );
    }
  }

  Widget _statusBanner({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.base,
        horizontal: AppSpacing.lg,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          AppSpacing.horizontalSm,
          Text(
            label,
            style: AppTypography.body.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildStatusIndicator() {
    final String emoji;
    final String text;
    final Color color;

    switch (escrow.status) {
      case EscrowStatus.collecting:
        if (_eventHasStarted) {
          emoji = '\uD83D\uDFE2';
          text = 'Event is LIVE \u2014 mark complete when it ends';
          color = AppColors.success;
        } else {
          emoji = '\uD83D\uDFE1';
          text = 'Tickets on sale \u2014 event hasn\u2019t started yet';
          color = AppColors.warning;
        }
      case EscrowStatus.held:
        emoji = '\uD83D\uDFE2';
        text = 'Event is LIVE \u2014 mark complete when it ends';
        color = AppColors.success;
      case EscrowStatus.awaitingCompletion:
        emoji = '\uD83D\uDD35';
        text = 'Awaiting admin review for payout';
        color = AppColors.purple;
      case EscrowStatus.released:
        emoji = '\u2705';
        text = 'Payout released!';
        color = AppColors.success;
      case EscrowStatus.refunding:
        emoji = '\uD83D\uDD34';
        text = 'Event cancelled \u2014 refunds in progress';
        color = AppColors.error;
      case EscrowStatus.refunded:
        emoji = '\uD83D\uDD34';
        text = 'Event cancelled \u2014 all buyers refunded';
        color = AppColors.error;
      case EscrowStatus.disputed:
        emoji = '\u26A0\uFE0F';
        text = 'Under admin review';
        color = AppColors.warning;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              text,
              style: AppTypography.caption.copyWith(color: color),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _showMarkCompleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Text(
          'Mark Event as Complete?',
          style: AppTypography.h3.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'This confirms your event has ended. Your payout will be '
          'processed after admin review (typically 24\u201348 hours).',
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
              context
                  .read<EscrowCubit>()
                  .markEventComplete(escrow.uuid);
            },
            child: Text(
              'Yes, Event is Complete',
              style: AppTypography.body.copyWith(
                color: AppColors.success,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Text(
          'Cancel Event & Refund?',
          style: AppTypography.h3.copyWith(
            color: AppColors.error,
          ),
        ),
        content: Text(
          'This will cancel your event and automatically refund ALL '
          'ticket holders. This action cannot be undone.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'Keep Event',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Event cancellation requested. '
                    'All ticket holders will be refunded.',
                  ),
                  backgroundColor: AppColors.warning,
                ),
              );
            },
            child: Text(
              'Cancel Event',
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
