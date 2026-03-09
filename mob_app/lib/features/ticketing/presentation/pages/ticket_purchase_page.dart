import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../shared/widgets/mob_card.dart';
import '../../../../shared/widgets/mob_gradient_button.dart';
import 'gateway_selection_sheet.dart';


class TicketPurchaseArgs {
  final String happeningUuid;
  final String title;
  final String? coverImageUrl;
  final String? address;
  final DateTime? startsAt;
  final double ticketPrice;
  final int ticketQuantity;
  final int ticketsSold;

  const TicketPurchaseArgs({
    required this.happeningUuid,
    required this.title,
    this.coverImageUrl,
    this.address,
    this.startsAt,
    required this.ticketPrice,
    required this.ticketQuantity,
    required this.ticketsSold,
  });


  int get ticketsRemaining => ticketQuantity - ticketsSold;
}


class TicketPurchasePage extends StatefulWidget {
  const TicketPurchasePage({
    super.key,
    required this.args,
  });

  final TicketPurchaseArgs args;

  @override
  State<TicketPurchasePage> createState() => _TicketPurchasePageState();
}

class _TicketPurchasePageState extends State<TicketPurchasePage> {
  int _quantity = 1;

  static final _currencyFormat = NumberFormat('#,###', 'en_US');
  static final _dateFormat = DateFormat('EEE, MMM d');
  static final _timeFormat = DateFormat('h:mm a');


  static const int _maxPerOrder = 10;

  TicketPurchaseArgs get _args => widget.args;
  int get _maxQuantity =>
      _args.ticketsRemaining.clamp(1, _maxPerOrder);


  double get _subtotal => _args.ticketPrice * _quantity;
  double get _serviceFee => (_subtotal * 0.05).ceilToDouble();
  double get _total => _subtotal + _serviceFee;

  String _formatNaira(double amount) =>
      '\u20A6${_currencyFormat.format(amount.toInt())}';


  double get _availabilityRatio =>
      _args.ticketQuantity > 0
          ? _args.ticketsRemaining / _args.ticketQuantity
          : 1.0;

  Color get _availabilityColor {
    if (_availabilityRatio > 0.5) return AppColors.cyan;
    if (_availabilityRatio > 0.2) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSpacing.verticalBase,
                  _buildEventSummary(),
                  AppSpacing.verticalLg,
                  _buildTicketSelectionCard(),
                  AppSpacing.verticalLg,
                  _buildPriceBreakdown(),
                  AppSpacing.verticalLg,
                  _buildEscrowBadge(),
                  AppSpacing.verticalXxl,
                ],
              ),
            ),
          ),
          _buildBottomBar(context),
        ],
      ),
    );
  }


  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.background,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
        onPressed: () => context.pop(),
      ),
      title: const Text('Get Tickets', style: AppTypography.h4),
      centerTitle: true,
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: AppSpacing.md),
          child: Icon(
            Icons.lock_outline,
            color: AppColors.success,
            size: 20,
          ),
        ),
      ],
    );
  }


  Widget _buildEventSummary() {
    return MobCard(
      padding: AppSpacing.cardPaddingCompact,
      child: Row(
        children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            child: _args.coverImageUrl != null
                ? CachedNetworkImage(
                    imageUrl: _args.coverImageUrl!,
                    width: 64,
                    height: 64,
                    memCacheWidth: 128,
                    memCacheHeight: 128,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 64,
                      height: 64,
                      color: AppColors.elevated,
                      child: const Icon(
                        Icons.event,
                        color: AppColors.textTertiary,
                        size: 24,
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 64,
                      height: 64,
                      color: AppColors.elevated,
                      child: const Icon(
                        Icons.event,
                        color: AppColors.textTertiary,
                        size: 24,
                      ),
                    ),
                  )
                : Container(
                    width: 64,
                    height: 64,
                    color: AppColors.elevated,
                    child: const Icon(
                      Icons.event,
                      color: AppColors.textTertiary,
                      size: 24,
                    ),
                  ),
          ),
          AppSpacing.horizontalMd,

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _args.title,
                  style: AppTypography.h4,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_args.address != null) ...[
                  AppSpacing.verticalXs,
                  Text(
                    _args.address!,
                    style: AppTypography.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                if (_args.startsAt != null) ...[
                  AppSpacing.verticalXs,
                  Text(
                    '${_dateFormat.format(_args.startsAt!)} \u2022 ${_timeFormat.format(_args.startsAt!)}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.cyan,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildTicketSelectionCard() {
    return MobCard(
      backgroundColor: AppColors.elevated,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            'STANDARD ENTRY',
            style: AppTypography.overline.copyWith(
              color: AppColors.cyan,
              letterSpacing: 1.5,
            ),
          ),
          AppSpacing.verticalSm,


          Text(
            '${_formatNaira(_args.ticketPrice)} / ticket',
            style: AppTypography.price,
          ),

          AppSpacing.verticalBase,


          _buildDashedLine(),

          AppSpacing.verticalBase,


          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQuantityButton(
                icon: Icons.remove,
                onTap: _quantity > 1
                    ? () => setState(() => _quantity--)
                    : null,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xxl,
                ),
                child: Text(
                  '$_quantity',
                  style: AppTypography.h3.copyWith(fontSize: 20),
                ),
              ),
              _buildQuantityButton(
                icon: Icons.add,
                onTap: _quantity < _maxQuantity
                    ? () => setState(() => _quantity++)
                    : null,
              ),
            ],
          ),

          AppSpacing.verticalBase,


          _buildAvailabilityBar(),
        ],
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: isDisabled ? 0.3 : 1.0,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: isDisabled ? AppColors.surface : AppColors.cyan,
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: isDisabled ? AppColors.textDisabled : AppColors.cyan,
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildDashedLine() {
    return LayoutBuilder(
      builder: (context, constraints) {
        const dashWidth = 6.0;
        const dashSpace = 4.0;
        final dashCount =
            (constraints.maxWidth / (dashWidth + dashSpace)).floor();
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
    );
  }

  Widget _buildAvailabilityBar() {
    return Column(
      children: [

        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _availabilityRatio,
            minHeight: 6,
            backgroundColor: AppColors.surface,
            valueColor: AlwaysStoppedAnimation<Color>(_availabilityColor),
          ),
        ),
        AppSpacing.verticalSm,

        Text(
          '${_args.ticketsRemaining} of ${_args.ticketQuantity} tickets remaining',
          style: AppTypography.caption.copyWith(
            color: _availabilityColor,
          ),
        ),
      ],
    );
  }


  Widget _buildPriceBreakdown() {
    return MobCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PRICE BREAKDOWN',
            style: AppTypography.overline.copyWith(
              letterSpacing: 1.5,
            ),
          ),
          AppSpacing.verticalBase,


          _buildPriceRow(
            label: 'Tickets ($_quantity \u00D7 ${_formatNaira(_args.ticketPrice)})',
            amount: _formatNaira(_subtotal),
          ),
          AppSpacing.verticalSm,


          _buildPriceRow(
            label: 'Service fee',
            amount: _formatNaira(_serviceFee),
          ),
          AppSpacing.verticalMd,


          Container(
            height: 0.5,
            color: AppColors.surface,
          ),
          AppSpacing.verticalMd,


          _buildPriceRow(
            label: 'Total',
            amount: _formatNaira(_total),
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow({
    required String label,
    required String amount,
    bool isBold = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? AppTypography.bodyLarge
                  .copyWith(fontWeight: FontWeight.w600)
              : AppTypography.body
                  .copyWith(color: AppColors.textSecondary),
        ),
        Text(
          amount,
          style: isBold
              ? AppTypography.h4
              : AppTypography.body,
        ),
      ],
    );
  }


  Widget _buildEscrowBadge() {
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.shield_outlined,
            color: AppColors.success,
            size: 20,
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
                    letterSpacing: 1.5,
                  ),
                ),
                AppSpacing.verticalXs,
                Text(
                  'Your payment is held securely until the event is confirmed.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.success.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBottomBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(color: AppColors.surface, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MobGradientButton(
              label: 'PROCEED TO PAYMENT',
              isLarge: true,
              icon: Icons.arrow_forward,
              onPressed: () => _handleProceedToPayment(context),
            ),
            AppSpacing.verticalSm,
            Text(
              'You\u2019ll pay ${_formatNaira(_total)} for $_quantity ticket${_quantity > 1 ? 's' : ''}',
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleProceedToPayment(BuildContext context) async {
    final navigator = GoRouter.of(context);

    final result = await GatewaySelectionSheet.show(
      context,
      happeningUuid: _args.happeningUuid,
      totalAmount: _total,
      quantity: _quantity,
    );

    if (result != null && mounted) {
      final reference = result.paymentReference ?? result.ticketUuid;
      navigator.push(
        RoutePaths.paymentWebViewPath(reference),
        extra: result,
      );
    }
  }
}
