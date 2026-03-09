import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/dio_client.dart';
import '../models/escrow_model.dart';
import '../models/payment_models.dart';
import '../models/ticket_model.dart';


abstract class TicketRemoteDataSource {


  Future<InitializePaymentResponse> initializePayment(
    InitializePaymentRequest request,
  );


  Future<PaginatedTickets> getMyTickets({
    String? status,
    int page = 1,
    int perPage = 20,
  });


  Future<TicketModel> getTicketDetail(String uuid);


  Future<EscrowModel> getEscrowDashboard(String uuid);


  Future<EscrowModel> getEscrowByHappening(String happeningUuid);


  Future<EscrowModel> markEventComplete(String uuid);


  Future<TicketModel> requestRefund(String ticketUuid);


  Future<List<TicketModel>> verifyTicketPayment(String ticketUuid);


  Future<Map<String, dynamic>> verifyTicketCheckIn({
    required String happeningUuid,
    required String ticketUuid,
  });
}


class PaginatedTickets {
  final List<TicketModel> tickets;
  final PaginationMeta? meta;

  const PaginatedTickets({
    required this.tickets,
    this.meta,
  });
}


class TicketRemoteDataSourceImpl implements TicketRemoteDataSource {
  TicketRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  final DioClient _dioClient;

  @override
  Future<InitializePaymentResponse> initializePayment(
    InitializePaymentRequest request,
  ) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiEndpoints.purchaseTicket,
      data: request.toJson(),
      fromJson: (data) => data as Map<String, dynamic>,
    );

    return InitializePaymentResponse.fromJson(response.data!);
  }

  @override
  Future<PaginatedTickets> getMyTickets({
    String? status,
    int page = 1,
    int perPage = 20,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'per_page': perPage,
    };

    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final response = await _dioClient.get<List<dynamic>>(
      ApiEndpoints.tickets,
      queryParams: queryParams,
      fromJson: (data) => data as List<dynamic>,
    );

    final tickets = (response.data ?? [])
        .map((e) => TicketModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return PaginatedTickets(
      tickets: tickets,
      meta: response.meta,
    );
  }

  @override
  Future<TicketModel> getTicketDetail(String uuid) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiEndpoints.ticketDetail(uuid),
      fromJson: (data) => data as Map<String, dynamic>,
    );

    return TicketModel.fromJson(response.data!);
  }

  @override
  Future<EscrowModel> getEscrowDashboard(String uuid) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiEndpoints.escrowStatus(uuid),
      fromJson: (data) => data as Map<String, dynamic>,
    );

    return _parseEscrowDashboardResponse(response.data!);
  }

  @override
  Future<EscrowModel> getEscrowByHappening(String happeningUuid) async {
    final response = await _dioClient.get<Map<String, dynamic>>(
      ApiEndpoints.escrowByHappening(happeningUuid),
      fromJson: (data) => data as Map<String, dynamic>,
    );

    return _parseEscrowDashboardResponse(response.data!);
  }


  EscrowModel _parseEscrowDashboardResponse(Map<String, dynamic> data) {
    final escrowJson = Map<String, dynamic>.from(
      data['escrow'] as Map<String, dynamic>,
    );


    final eventLog = data['event_log'] as List<dynamic>?;
    if (eventLog != null) {
      escrowJson['events'] = eventLog;
    }

    return EscrowModel.fromJson(escrowJson);
  }

  @override
  Future<EscrowModel> markEventComplete(String uuid) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiEndpoints.escrowComplete(uuid),
      fromJson: (data) => data as Map<String, dynamic>,
    );

    return EscrowModel.fromJson(response.data!);
  }

  @override
  Future<TicketModel> requestRefund(String ticketUuid) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      '${ApiEndpoints.ticketDetail(ticketUuid)}/refund',
      fromJson: (data) => data as Map<String, dynamic>,
    );

    return TicketModel.fromJson(response.data!);
  }

  @override
  Future<List<TicketModel>> verifyTicketPayment(String ticketUuid) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiEndpoints.verifyTicketPayment(ticketUuid),
      fromJson: (data) => data as Map<String, dynamic>,
    );

    final data = response.data!;
    final ticketsList = data['tickets'] as List<dynamic>?;

    if (ticketsList != null) {
      return ticketsList
          .map((e) => TicketModel.fromJson(e as Map<String, dynamic>))
          .toList();
    }


    return [TicketModel.fromJson(data)];
  }

  @override
  Future<Map<String, dynamic>> verifyTicketCheckIn({
    required String happeningUuid,
    required String ticketUuid,
  }) async {
    final response = await _dioClient.post<Map<String, dynamic>>(
      ApiEndpoints.verifyTicketCheckIn(happeningUuid),
      data: {'ticket_uuid': ticketUuid},
      fromJson: (data) => data as Map<String, dynamic>,
    );

    return response.data!;
  }
}
