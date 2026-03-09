import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_paths.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../bloc/payment_cubit.dart';
import '../bloc/payment_state.dart';


class PaymentWebViewPage extends StatefulWidget {
  const PaymentWebViewPage({
    super.key,
    required this.paymentUrl,
    required this.ticketUuid,
    required this.gateway,
    this.paymentReference,
  });


  final String paymentUrl;


  final String ticketUuid;


  final String gateway;


  final String? paymentReference;


  static const String callbackUrl = 'https://mob.app/payment/callback';

  @override
  State<PaymentWebViewPage> createState() => _PaymentWebViewPageState();
}

class _PaymentWebViewPageState extends State<PaymentWebViewPage> {
  late final WebViewController _controller;
  late final PaymentCubit _paymentCubit;


  int _progress = 0;


  bool _pageLoaded = false;


  bool _loadError = false;


  bool _verificationTriggered = false;


  Timer? _timeoutTimer;
  static const Duration _paymentTimeout = Duration(minutes: 5);

  @override
  void initState() {
    super.initState();

    debugPrint('[PaymentWebView] Loading URL: ${widget.paymentUrl}');
    debugPrint('[PaymentWebView] Ticket UUID: ${widget.ticketUuid}');
    debugPrint('[PaymentWebView] Gateway: ${widget.gateway}');

    _paymentCubit = PaymentCubit(
      ticketRepository: context.read<TicketRepository>(),
    );

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(AppColors.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: _onProgress,
          onPageStarted: _onPageStarted,
          onPageFinished: _onPageFinished,
          onWebResourceError: _onWebResourceError,
          onNavigationRequest: _onNavigationRequest,
        ),
      )
      ..loadRequest(Uri.parse(widget.paymentUrl));

    _startTimeoutTimer();
  }

  @override
  void dispose() {
    _timeoutTimer?.cancel();
    _paymentCubit.close();
    super.dispose();
  }


  void _onProgress(int progress) {
    if (mounted) setState(() => _progress = progress);
  }

  void _onPageStarted(String url) {
    debugPrint('[PaymentWebView] Page started: $url');
    if (mounted) {
      setState(() {
        _pageLoaded = false;
        _loadError = false;
      });
    }
  }

  void _onPageFinished(String url) {
    debugPrint('[PaymentWebView] Page finished: $url');
    if (mounted) setState(() => _pageLoaded = true);
  }

  void _onWebResourceError(WebResourceError error) {
    debugPrint('[PaymentWebView] Error: ${error.description} '
        '(code: ${error.errorCode}, type: ${error.errorType}, '
        'isMainFrame: ${error.isForMainFrame})');

    if (error.isForMainFrame ?? false) {
      if (mounted) {
        setState(() {
          _loadError = true;
          _pageLoaded = true;
        });
      }
    }
  }

  NavigationDecision _onNavigationRequest(NavigationRequest request) {
    final url = request.url;


    if (_isCallbackUrl(url)) {
      _handlePaymentCallback(url);
      return NavigationDecision.prevent;
    }

    return NavigationDecision.navigate;
  }

  bool _isCallbackUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.host == 'mob.app' && uri.path.startsWith('/payment/callback');
    } catch (_) {
      return false;
    }
  }


  void _handlePaymentCallback(String url) {
    if (_verificationTriggered) return;
    _verificationTriggered = true;
    _timeoutTimer?.cancel();

    _paymentCubit.verifyPayment(ticketUuid: widget.ticketUuid);
  }

  void _retryVerification() {
    setState(() => _verificationTriggered = false);
    _verificationTriggered = true;
    _paymentCubit.verifyPayment(ticketUuid: widget.ticketUuid);
  }


  void _startTimeoutTimer() {
    _timeoutTimer = Timer(_paymentTimeout, () {
      if (mounted && !_verificationTriggered) {
        _showTimeoutDialog();
      }
    });
  }

  void _showTimeoutDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: const Text('Payment Taking Too Long?', style: AppTypography.h4),
        content: const Text(
          'If you\'ve completed payment, tap "Verify" to check your payment status. '
          'Otherwise, you can continue waiting.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Keep Waiting',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _handlePaymentCallback('');
            },
            child: Text(
              'Verify Payment',
              style: AppTypography.body.copyWith(color: AppColors.cyan),
            ),
          ),
        ],
      ),
    );
  }


  Future<bool> _onWillPop() async {
    final shouldCancel = await _showCancelDialog();
    return shouldCancel ?? false;
  }

  Future<bool?> _showCancelDialog() {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: const Text('Cancel Payment?', style: AppTypography.h4),
        content: const Text(
          'Your payment may still be in progress. '
          'Are you sure you want to cancel?',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Continue Payment',
              style: AppTypography.body.copyWith(color: AppColors.cyan),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Yes, Cancel',
              style: AppTypography.body.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _paymentCubit,
      child: BlocListener<PaymentCubit, PaymentState>(
        listener: _handlePaymentState,
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop) return;
            final shouldPop = await _onWillPop();
            if (shouldPop && context.mounted) {
              _paymentCubit.reset();
              Navigator.of(context).pop();
            }
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            appBar: _buildAppBar(),
            body: Stack(
              children: [

                WebViewWidget(controller: _controller),


                if (!_pageLoaded) _buildProgressBar(),


                if (_loadError) _buildErrorOverlay(),


                BlocBuilder<PaymentCubit, PaymentState>(
                  builder: (context, state) {
                    if (state is PaymentVerifying) {
                      return _buildVerifyingOverlay();
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handlePaymentState(BuildContext context, PaymentState state) {
    if (state is PaymentSuccess) {
      _timeoutTimer?.cancel();


      final firstUuid = state.tickets.first.uuid;
      context.pushReplacement(
        RoutePaths.ticketConfirmationPath(firstUuid),
        extra: state.tickets,
      );
    } else if (state is PaymentFailed) {
      _showPaymentFailedDialog(state.message);
    }
  }

  void _showPaymentFailedDialog(String message) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: const Text('Payment Verification Failed', style: AppTypography.h4),
        content: Text(
          '$message\n\n'
          'If you were charged, please contact support.',
          style: AppTypography.body,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Go Back',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              _retryVerification();
            },
            child: Text(
              'Retry Verification',
              style: AppTypography.body.copyWith(color: AppColors.cyan),
            ),
          ),
        ],
      ),
    );
  }


  PreferredSizeWidget _buildAppBar() {
    final gatewayLabel = widget.gateway == 'paystack' ? 'Paystack' : 'Flutterwave';

    return AppBar(
      backgroundColor: AppColors.elevated,
      surfaceTintColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.close, color: AppColors.textPrimary),
        onPressed: () async {
          final shouldCancel = await _showCancelDialog();
          if ((shouldCancel ?? false) && mounted) {
            _paymentCubit.reset();
            Navigator.of(context).pop();
          }
        },
      ),
      title: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.lock, color: AppColors.success, size: 16),
          SizedBox(width: 6),
          Text('Secure Payment', style: AppTypography.h4),
        ],
      ),
      centerTitle: true,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.md),
          child: Center(
            child: Text(
              'via $gatewayLabel',
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildProgressBar() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SizedBox(
        height: 3,
        child: LinearProgressIndicator(
          value: _progress / 100.0,
          backgroundColor: Colors.transparent,
          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.cyan),
        ),
      ),
    );
  }


  Widget _buildErrorOverlay() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.wifi_off_rounded,
                color: AppColors.textTertiary,
                size: 48,
              ),
              AppSpacing.verticalLg,
              const Text(
                'Unable to load payment page',
                style: AppTypography.h4,
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalSm,
              Text(
                'Please check your internet connection and try again.',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalXl,
              SizedBox(
                width: 160,
                child: OutlinedButton(
                  onPressed: () {
                    setState(() => _loadError = false);
                    _controller.loadRequest(Uri.parse(widget.paymentUrl));
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.cyan,
                    side: const BorderSide(color: AppColors.cyan),
                    shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.buttonRadius,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                  child: const Text('Retry'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildVerifyingOverlay() {
    return Container(
      color: AppColors.background.withValues(alpha: 0.9),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                color: AppColors.cyan,
                strokeWidth: 3,
              ),
            ),
            AppSpacing.verticalXl,
            Text('Verifying payment...', style: AppTypography.h4),
            AppSpacing.verticalSm,
            Text(
              'Please wait while we confirm your payment.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
