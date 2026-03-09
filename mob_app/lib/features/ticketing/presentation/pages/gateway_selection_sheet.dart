import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/models/enums.dart';
import '../../../../shared/widgets/mob_card.dart';
import '../../../../shared/widgets/mob_gradient_button.dart';
import '../../../../shared/widgets/mob_text_button.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../bloc/payment_cubit.dart';
import '../bloc/payment_state.dart';
import 'payment_webview_page.dart';


class GatewaySelectionSheet extends StatefulWidget {
  const GatewaySelectionSheet({
    super.key,
    required this.happeningUuid,
    required this.totalAmount,
    this.quantity = 1,
  });

  final String happeningUuid;
  final double totalAmount;
  final int quantity;


  static Future<PaymentInitialized?> show(
    BuildContext context, {
    required String happeningUuid,
    required double totalAmount,
    int quantity = 1,
  }) {
    return showModalBottomSheet<PaymentInitialized>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.card,
      barrierColor: Colors.black54,
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.bottomSheetRadius,
      ),
      builder: (sheetContext) {
        return BlocProvider(
          create: (_) => PaymentCubit(
            ticketRepository: context.read<TicketRepository>(),
          ),
          child: GatewaySelectionSheet(
            happeningUuid: happeningUuid,
            totalAmount: totalAmount,
            quantity: quantity,
          ),
        );
      },
    );
  }

  @override
  State<GatewaySelectionSheet> createState() => _GatewaySelectionSheetState();
}

class _GatewaySelectionSheetState extends State<GatewaySelectionSheet> {
  PaymentGateway? _selectedGateway;

  static final _currencyFormat = NumberFormat('#,###', 'en_US');

  String _formatNaira(double amount) =>
      '\u20A6${_currencyFormat.format(amount.toInt())}';

  @override
  Widget build(BuildContext context) {
    return BlocListener<PaymentCubit, PaymentState>(
      listener: _handlePaymentState,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            const SizedBox(height: AppSpacing.md),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),


            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  AppSpacing.verticalLg,
                  _buildGatewayCards(),
                  AppSpacing.verticalLg,
                  _buildSecurityBadge(),
                  AppSpacing.verticalLg,
                  _buildPayButton(),
                  AppSpacing.verticalSm,
                  _buildCancelButton(),
                ],
              ),
            ),


            SizedBox(
              height: MediaQuery.of(context).padding.bottom + AppSpacing.base,
            ),
          ],
        ),
      ),
    );
  }


  void _handlePaymentState(BuildContext context, PaymentState state) {
    debugPrint('[GatewaySheet] Payment state: $state');

    if (state is PaymentInitialized) {
      debugPrint('[GatewaySheet] Payment URL: ${state.paymentUrl}');
      debugPrint('[GatewaySheet] Ticket UUID: ${state.ticketUuid}');

      Navigator.of(context).pop(state);
    } else if (state is PaymentFailed) {
      debugPrint('[GatewaySheet] Payment FAILED: ${state.message}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(AppSpacing.base),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
        ),
      );
    }
  }


  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Choose Payment Method', style: AppTypography.h2),
        AppSpacing.verticalXs,
        Text(
          'Total: ${_formatNaira(widget.totalAmount)}',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.cyan,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }


  Widget _buildGatewayCards() {
    return Column(
      children: [
        _GatewayCard(
          gateway: PaymentGateway.paystack,
          title: 'Paystack',
          subtitle: 'Cards, Bank Transfer, USSD',
          iconColor: const Color(0xFF00C3F7),
          iconLetter: 'P',
          isSelected: _selectedGateway == PaymentGateway.paystack,
          onTap: () => setState(() => _selectedGateway = PaymentGateway.paystack),
        ),
        AppSpacing.verticalMd,
        _GatewayCard(
          gateway: PaymentGateway.flutterwave,
          title: 'Flutterwave',
          subtitle: 'Mobile Money, Cards',
          iconColor: const Color(0xFFF5A623),
          iconLetter: 'F',
          isSelected: _selectedGateway == PaymentGateway.flutterwave,
          onTap: () =>
              setState(() => _selectedGateway = PaymentGateway.flutterwave),
        ),
      ],
    );
  }


  Widget _buildSecurityBadge() {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.lock_outline, size: 14, color: AppColors.textTertiary),
        SizedBox(width: 6),
        Text(
          'SECURED BY 256-BIT ENCRYPTION',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: AppColors.textTertiary,
            letterSpacing: 1.0,
          ),
        ),
      ],
    );
  }


  Widget _buildPayButton() {
    return BlocBuilder<PaymentCubit, PaymentState>(
      builder: (context, state) {
        final isLoading = state is PaymentLoading;

        return MobGradientButton(
          label: 'Pay ${_formatNaira(widget.totalAmount)}',
          icon: Icons.arrow_forward,
          isLarge: true,
          isLoading: isLoading,
          onPressed: _selectedGateway != null && !isLoading
              ? () => _handlePay(context)
              : null,
        );
      },
    );
  }

  Widget _buildCancelButton() {
    return Center(
      child: MobTextButton(
        label: 'Cancel',
        color: AppColors.textSecondary,
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }


  void _handlePay(BuildContext context) {
    if (_selectedGateway == null) return;

    context.read<PaymentCubit>().initializePayment(
          happeningUuid: widget.happeningUuid,
          gateway: _selectedGateway!,
          quantity: widget.quantity,
          callbackUrl: PaymentWebViewPage.callbackUrl,
        );
  }
}


class _GatewayCard extends StatelessWidget {
  const _GatewayCard({
    required this.gateway,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.iconLetter,
    required this.isSelected,
    required this.onTap,
  });

  final PaymentGateway gateway;
  final String title;
  final String subtitle;
  final Color iconColor;
  final String iconLetter;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return MobCard(
      backgroundColor: isSelected ? AppColors.elevated : AppColors.card,
      borderColor: isSelected ? AppColors.cyan : AppColors.border,
      onTap: onTap,
      padding: AppSpacing.cardPadding,
      child: Row(
        children: [

          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            alignment: Alignment.center,
            child: Text(
              iconLetter,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: iconColor,
              ),
            ),
          ),
          AppSpacing.horizontalMd,


          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTypography.h4),
                AppSpacing.verticalXs,
                Text(subtitle, style: AppTypography.caption),
              ],
            ),
          ),


          Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? AppColors.cyan : AppColors.surface,
                width: 2,
              ),
            ),
            child: isSelected
                ? Center(
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.cyan,
                      ),
                    ),
                  )
                : null,
          ),
        ],
      ),
    );
  }
}
