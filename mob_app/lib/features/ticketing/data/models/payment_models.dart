import '../../../../shared/models/enums.dart';


class InitializePaymentRequest {

  final String happeningUuid;


  final PaymentGateway paymentGateway;


  final int quantity;


  final String? callbackUrl;

  const InitializePaymentRequest({
    required this.happeningUuid,
    required this.paymentGateway,
    this.quantity = 1,
    this.callbackUrl,
  });


  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'happening_uuid': happeningUuid,
      'payment_gateway': paymentGateway.value,
      'quantity': quantity,
    };
    if (callbackUrl != null) {
      json['callback_url'] = callbackUrl;
    }
    return json;
  }
}


class InitializePaymentResponse {

  final String paymentUrl;


  final String ticketUuid;


  final String? paymentReference;

  const InitializePaymentResponse({
    required this.paymentUrl,
    required this.ticketUuid,
    this.paymentReference,
  });


  factory InitializePaymentResponse.fromJson(Map<String, dynamic> json) {
    final ticket = json['ticket'] as Map<String, dynamic>?;

    return InitializePaymentResponse(
      paymentUrl: json['payment_url'] as String,
      ticketUuid: ticket?['uuid'] as String? ?? '',
      paymentReference: ticket?['payment_reference'] as String?,
    );
  }
}


class VerifyPaymentRequest {

  final String paymentReference;


  final PaymentGateway paymentGateway;

  const VerifyPaymentRequest({
    required this.paymentReference,
    required this.paymentGateway,
  });


  Map<String, dynamic> toJson() {
    return {
      'payment_reference': paymentReference,
      'payment_gateway': paymentGateway.value,
    };
  }
}
