import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/payment_models.dart';
import '../entities/escrow.dart';
import '../entities/ticket.dart';


abstract class TicketRepository {


  Future<Either<Failure, InitializePaymentResponse>> initializePayment(
    InitializePaymentRequest request,
  );


  Future<Either<Failure, List<Ticket>>> getMyTickets({
    String? status,
    int page = 1,
  });


  Future<Either<Failure, Ticket>> getTicketDetail(String uuid);


  Future<Either<Failure, Escrow>> getEscrowDashboard(String uuid);


  Future<Either<Failure, Escrow>> getEscrowByHappening(
      String happeningUuid);


  Future<Either<Failure, Escrow>> markEventComplete(String uuid);


  Future<Either<Failure, Ticket>> requestRefund(String ticketUuid);


  Future<Either<Failure, List<Ticket>>> verifyTicketPayment(
      String ticketUuid);


  Future<Either<Failure, Map<String, dynamic>>> verifyTicketCheckIn({
    required String happeningUuid,
    required String ticketUuid,
  });
}
