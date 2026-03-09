import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/ticket.dart';


class TicketConfirmationPage extends StatefulWidget {
  const TicketConfirmationPage({
    super.key,
    required this.tickets,
  });


  final List<Ticket> tickets;

  @override
  State<TicketConfirmationPage> createState() =>
      _TicketConfirmationPageState();
}

class _TicketConfirmationPageState extends State<TicketConfirmationPage>
    with TickerProviderStateMixin {

  late final AnimationController _checkController;
  late final Animation<double> _checkScale;


  late final AnimationController _textController;
  late final Animation<double> _textOpacity;


  late final AnimationController _cardController;
  late final Animation<Offset> _cardSlide;
  late final Animation<double> _cardOpacity;

  Ticket get _firstTicket => widget.tickets.first;
  int get _ticketCount => widget.tickets.length;
  bool get _isMultiple => _ticketCount > 1;

  @override
  void initState() {
    super.initState();


    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _checkScale = CurvedAnimation(
      parent: _checkController,
      curve: Curves.elasticOut,
    );


    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _textOpacity = CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    );


    _cardController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _cardSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeOut,
    ));
    _cardOpacity = CurvedAnimation(
      parent: _cardController,
      curve: Curves.easeIn,
    );


    _checkController.forward();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _textController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _cardController.forward();
    });
  }

  @override
  void dispose() {
    _checkController.dispose();
    _textController.dispose();
    _cardController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          context.go(RoutePaths.tickets);
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              children: [
                AppSpacing.verticalXxl,


                _buildCelebrationHeader(),

                AppSpacing.verticalXxl,


                ...widget.tickets.asMap().entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: entry.key < _ticketCount - 1
                          ? AppSpacing.md
                          : 0,
                    ),
                    child: _buildTicketStubCard(
                      entry.value,
                      index: entry.key,
                    ),
                  );
                }),

                AppSpacing.verticalLg,


                _buildEscrowTrustBadge(),

                AppSpacing.verticalXxl,


                _buildActionButtons(),

                AppSpacing.verticalLg,


                _buildEmailNote(),

                AppSpacing.verticalXxl,
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildCelebrationHeader() {
    return Column(
      children: [

        ScaleTransition(
          scale: _checkScale,
          child: Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success.withValues(alpha: 0.15),
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.3),
                  blurRadius: 24,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.success,
              size: 48,
            ),
          ),
        ),

        AppSpacing.verticalXl,


        FadeTransition(
          opacity: _textOpacity,
          child: Column(
            children: [
              Text(
                "YOU'RE IN!",
                style: AppTypography.display.copyWith(
                  letterSpacing: 1.5,
                ),
              ),
              AppSpacing.verticalSm,
              Text(
                _isMultiple
                    ? '$_ticketCount tickets confirmed'
                    : 'Your ticket has been confirmed',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildTicketStubCard(Ticket ticket, {required int index}) {
    return SlideTransition(
      position: _cardSlide,
      child: FadeTransition(
        opacity: _cardOpacity,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            border: Border.all(
              color: AppColors.border,
              width: 0.5,
            ),
          ),
          child: Column(
            children: [

              if (index == 0) _buildTicketTopSection(ticket),


              if (index > 0)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.lg,
                    0,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.confirmation_number_outlined,
                        color: AppColors.cyan,
                        size: 16,
                      ),
                      AppSpacing.horizontalSm,
                      Text(
                        ticket.displayLabel,
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),


              _buildDashedDivider(),


              _buildTicketBottomSection(ticket),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketTopSection(Ticket ticket) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            ticket.happeningTitle ?? 'Event',
            style: AppTypography.h2,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),

          AppSpacing.verticalMd,


          if (ticket.happeningAddress != null) ...[
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  color: AppColors.textTertiary,
                  size: 16,
                ),
                AppSpacing.horizontalSm,
                Expanded(
                  child: Text(
                    ticket.happeningAddress!,
                    style: AppTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSm,
          ],


          if (ticket.happeningStartsAt != null)
            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  color: AppColors.textTertiary,
                  size: 16,
                ),
                AppSpacing.horizontalSm,
                Text(
                  _formatDateTime(ticket.happeningStartsAt!),
                  style: AppTypography.caption,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildDashedDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: LayoutBuilder(
        builder: (context, constraints) {
          const dashWidth = 6.0;
          const dashGap = 4.0;
          final dashCount =
              (constraints.maxWidth / (dashWidth + dashGap)).floor();

          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(dashCount, (_) {
              return Container(
                width: dashWidth,
                height: 1,
                color: AppColors.surface,
              );
            }),
          );
        },
      ),
    );
  }

  Widget _buildTicketBottomSection(Ticket ticket) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
              size: _isMultiple ? 120 : 160,
              backgroundColor: Colors.white,
              errorCorrectionLevel: QrErrorCorrectLevel.M,
            ),
          ),

          AppSpacing.verticalMd,


          Text(
            ticket.displayLabel,
            style: AppTypography.caption.copyWith(
              fontFamily: 'monospace',
              letterSpacing: 0.5,
            ),
          ),

          AppSpacing.verticalSm,


          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const MobBadge(
                label: 'CONFIRMED',
                color: AppColors.success,
                icon: Icons.check_circle_outline,
              ),
              AppSpacing.horizontalMd,
              GestureDetector(
                onTap: () => _shareIndividualTicket(ticket),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.cyan.withValues(alpha: 0.5),
                    ),
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.share_outlined,
                        color: AppColors.cyan,
                        size: 14,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Share',
                        style: TextStyle(
                          color: AppColors.cyan,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildEscrowTrustBadge() {
    final totalAmount = widget.tickets.fold<double>(
      0,
      (sum, t) => sum + t.amount,
    );
    final formattedTotal =
        '\u20A6${NumberFormat('#,###', 'en_US').format(totalAmount.toInt())}';

    return SlideTransition(
      position: _cardSlide,
      child: FadeTransition(
        opacity: _cardOpacity,
        child: MobCard(
          backgroundColor: AppColors.success.withValues(alpha: 0.08),
          borderColor: AppColors.success.withValues(alpha: 0.2),
          padding: const EdgeInsets.all(AppSpacing.base),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              AppSpacing.horizontalMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ESCROW PROTECTED',
                      style: AppTypography.overline.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    AppSpacing.verticalXs,
                    Text(
                      'Your $formattedTotal payment is held '
                      'securely. Funds are released to the host only after '
                      'the event is confirmed.',
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
        ),
      ),
    );
  }


  Widget _buildActionButtons() {
    return Column(
      children: [

        MobGradientButton(
          label: 'View My Tickets',
          onPressed: () => context.go(RoutePaths.tickets),
        ),

        AppSpacing.verticalMd,


        Row(
          children: [

            Expanded(
              child: MobOutlinedButton(
                label: 'Add to Calendar',
                icon: Icons.calendar_month_outlined,
                onPressed: _addToCalendar,
              ),
            ),

            AppSpacing.horizontalMd,


            Expanded(
              child: MobOutlinedButton(
                label: 'Share',
                icon: Icons.share_outlined,
                onPressed: _shareTicket,
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildEmailNote() {
    return Text(
      'A confirmation email has been sent to your registered email.',
      style: AppTypography.caption.copyWith(
        color: AppColors.textTertiary,
      ),
      textAlign: TextAlign.center,
    );
  }


  Future<void> _addToCalendar() async {
    final ticket = _firstTicket;
    final title = ticket.happeningTitle ?? 'Mob Event';
    final location = ticket.happeningAddress ?? '';
    final startsAt = ticket.happeningStartsAt;

    if (startsAt == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No date available for this event'),
            backgroundColor: AppColors.elevated,
          ),
        );
      }
      return;
    }


    final start = startsAt.toUtc();
    final end = start.add(const Duration(hours: 2));
    final startStr = DateFormat("yyyyMMdd'T'HHmmss'Z'").format(start);
    final endStr = DateFormat("yyyyMMdd'T'HHmmss'Z'").format(end);

    final calendarUrl = Uri.parse(
      'https://calendar.google.com/calendar/render'
      '?action=TEMPLATE'
      '&text=${Uri.encodeComponent(title)}'
      '&dates=$startStr/$endStr'
      '&location=${Uri.encodeComponent(location)}'
      '&details=${Uri.encodeComponent('Ticket confirmed on Mob')}',
    );

    if (await canLaunchUrl(calendarUrl)) {
      await launchUrl(calendarUrl, mode: LaunchMode.externalApplication);
    }
  }

  void _shareTicket() {
    final ticket = _firstTicket;
    final title = ticket.happeningTitle ?? 'an event';
    final dateStr = ticket.happeningStartsAt != null
        ? ' on ${_formatDateTime(ticket.happeningStartsAt!)}'
        : '';
    final ticketWord = _isMultiple ? '$_ticketCount tickets' : 'my ticket';
    final happeningUrl = ticket.happeningUuid != null
        ? '\n${AppConfig.happeningShareUrl(ticket.happeningUuid!)}'
        : '';

    Share.share(
      "I just got $ticketWord for $title$dateStr! "
      "Check it out on Mob.$happeningUrl",
    );
  }

  void _shareIndividualTicket(Ticket ticket) {
    final title = ticket.happeningTitle ?? 'an event';
    final label = ticket.displayLabel;
    final ticketUrl = AppConfig.ticketShareUrl(ticket.uuid);

    Share.share(
      "Here's a ticket ($label) for $title! "
      "Scan the QR code at the venue.\n$ticketUrl",
    );
  }


  String _formatDateTime(DateTime dateTime) {
    return DateFormat('EEE, MMM d \u2022 h:mm a').format(dateTime);
  }
}
