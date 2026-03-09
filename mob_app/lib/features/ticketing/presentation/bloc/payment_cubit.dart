import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../shared/models/enums.dart';
import '../../data/models/payment_models.dart';
import '../../domain/repositories/ticket_repository.dart';
import 'payment_state.dart';


class PaymentCubit extends Cubit<PaymentState> {
  PaymentCubit({
    required TicketRepository ticketRepository,
  })  : _ticketRepository = ticketRepository,
        super(const PaymentInitial());

  final TicketRepository _ticketRepository;


  Future<void> initializePayment({
    required String happeningUuid,
    required PaymentGateway gateway,
    int quantity = 1,
    String? callbackUrl,
  }) async {
    debugPrint('[PaymentCubit] initializePayment: '
        'happening=$happeningUuid, gateway=${gateway.value}, qty=$quantity');
    emit(const PaymentLoading());

    final request = InitializePaymentRequest(
      happeningUuid: happeningUuid,
      paymentGateway: gateway,
      quantity: quantity,
      callbackUrl: callbackUrl,
    );

    debugPrint('[PaymentCubit] Request body: ${request.toJson()}');

    final result = await _ticketRepository.initializePayment(request);

    result.fold(
      (failure) {
        debugPrint('[PaymentCubit] FAILED: ${failure.message}');
        emit(PaymentFailed(failure.message));
      },
      (response) {
        debugPrint('[PaymentCubit] SUCCESS: url=${response.paymentUrl}, '
            'ticket=${response.ticketUuid}');
        emit(PaymentInitialized(
          paymentUrl: response.paymentUrl,
          paymentReference: response.paymentReference,
          ticketUuid: response.ticketUuid,
          gateway: gateway.value,
        ));
      },
    );
  }


  Future<void> verifyPayment({required String ticketUuid}) async {
    emit(const PaymentVerifying());

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      debugPrint('[PaymentCubit] Verify attempt $attempt/$_maxRetries '
          'for ticket $ticketUuid');

      final result =
          await _ticketRepository.verifyTicketPayment(ticketUuid);

      final bool shouldStop = result.fold(
        (failure) {
          debugPrint('[PaymentCubit] Verify error: ${failure.message}');


          if (attempt >= _maxRetries) {
            emit(PaymentFailed(failure.message));
            return true;
          }


          debugPrint('[PaymentCubit] Will retry after delay...');
          return false;
        },
        (tickets) {
          final allPaid = tickets.isNotEmpty &&
              tickets.every((t) => t.isPaid);
          if (allPaid) {
            debugPrint(
                '[PaymentCubit] Payment confirmed on attempt $attempt '
                '(${tickets.length} tickets)');
            emit(PaymentSuccess(tickets));
            return true;
          }

          debugPrint('[PaymentCubit] Still pending (attempt $attempt)');
          return false;
        },
      );

      if (shouldStop) return;


      if (attempt < _maxRetries) {
        await Future<void>.delayed(_retryDelay);
      }
    }


    debugPrint('[PaymentCubit] All $_maxRetries attempts exhausted');
    emit(const PaymentFailed(
      'Payment could not be confirmed. '
      'If you were charged, your ticket will appear shortly.',
    ));
  }


  static const int _maxRetries = 4;


  static const Duration _retryDelay = Duration(seconds: 3);


  void reset() {
    emit(const PaymentInitial());
  }
}
