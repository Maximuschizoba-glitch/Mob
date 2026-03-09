import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/escrow.dart';
import '../../domain/entities/ticket.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../datasources/ticket_remote_data_source.dart';
import '../models/payment_models.dart';


class TicketRepositoryImpl implements TicketRepository {
  TicketRepositoryImpl({required TicketRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  final TicketRemoteDataSource _remoteDataSource;

  @override
  Future<Either<Failure, InitializePaymentResponse>> initializePayment(
    InitializePaymentRequest request,
  ) async {
    try {
      final result = await _remoteDataSource.initializePayment(request);
      return Right(result);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    }
  }

  @override
  Future<Either<Failure, List<Ticket>>> getMyTickets({
    String? status,
    int page = 1,
  }) async {
    try {
      final result = await _remoteDataSource.getMyTickets(
        status: status,
        page: page,
      );
      return Right(result.tickets);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    }
  }

  @override
  Future<Either<Failure, Ticket>> getTicketDetail(String uuid) async {
    try {
      final ticket = await _remoteDataSource.getTicketDetail(uuid);
      return Right(ticket);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    }
  }

  @override
  Future<Either<Failure, Escrow>> getEscrowDashboard(String uuid) async {
    try {
      final escrow = await _remoteDataSource.getEscrowDashboard(uuid);
      return Right(escrow);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    }
  }

  @override
  Future<Either<Failure, Escrow>> getEscrowByHappening(
      String happeningUuid) async {
    try {
      final escrow =
          await _remoteDataSource.getEscrowByHappening(happeningUuid);
      return Right(escrow);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {

      if (e.statusCode == 404) {
        return Left(NotFoundFailure(e.message));
      }
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    }
  }

  @override
  Future<Either<Failure, Escrow>> markEventComplete(String uuid) async {
    try {
      final escrow = await _remoteDataSource.markEventComplete(uuid);
      return Right(escrow);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    }
  }

  @override
  Future<Either<Failure, Ticket>> requestRefund(String ticketUuid) async {
    try {
      final ticket = await _remoteDataSource.requestRefund(ticketUuid);
      return Right(ticket);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    }
  }

  @override
  Future<Either<Failure, List<Ticket>>> verifyTicketPayment(
    String ticketUuid,
  ) async {
    try {
      final tickets =
          await _remoteDataSource.verifyTicketPayment(ticketUuid);
      return Right(tickets);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> verifyTicketCheckIn({
    required String happeningUuid,
    required String ticketUuid,
  }) async {
    try {
      final result = await _remoteDataSource.verifyTicketCheckIn(
        happeningUuid: happeningUuid,
        ticketUuid: ticketUuid,
      );
      return Right(result);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message, errors: e.errors));
    }
  }
}
