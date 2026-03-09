import 'package:dartz/dartz.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mob_app/app/app.dart';
import 'package:mob_app/core/errors/failures.dart';
import 'package:mob_app/core/network/dio_client.dart';
import 'package:mob_app/core/services/firebase_storage_service.dart';
import 'package:mob_app/core/services/location_service.dart';
import 'package:mob_app/core/services/storage_service.dart';
import 'package:mob_app/features/auth/domain/entities/user.dart';
import 'package:mob_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:mob_app/features/feed/domain/entities/happening.dart';
import 'package:mob_app/features/feed/domain/repositories/feed_repository.dart';
import 'package:mob_app/features/feed/domain/usecases/get_nearby_happenings.dart';
import 'package:mob_app/features/happenings/data/models/create_happening_request.dart';
import 'package:mob_app/features/happenings/domain/repositories/happening_repository.dart';
import 'package:mob_app/features/happenings/domain/repositories/report_repository.dart';
import 'package:mob_app/features/map/domain/repositories/map_repository.dart';
import 'package:mob_app/features/snaps/domain/entities/snap.dart';
import 'package:mob_app/features/snaps/domain/repositories/snap_repository.dart';
import 'package:mob_app/features/ticketing/data/models/payment_models.dart';
import 'package:mob_app/features/ticketing/domain/entities/escrow.dart';
import 'package:mob_app/features/ticketing/domain/entities/ticket.dart';
import 'package:mob_app/features/profile/data/models/host_verification_request.dart';
import 'package:mob_app/features/profile/data/models/update_profile_request.dart';
import 'package:mob_app/features/profile/domain/entities/host_verification.dart';
import 'package:mob_app/features/notifications/domain/entities/app_notification.dart';
import 'package:mob_app/features/notifications/domain/repositories/notification_repository.dart';
import 'package:mob_app/features/profile/domain/repositories/host_verification_repository.dart';
import 'package:mob_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:mob_app/features/ticketing/domain/repositories/ticket_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ═══════════════════════════════════════════════════════════════════════
// Fake AuthRepository — returns Unauthenticated for all auth checks
// ═══════════════════════════════════════════════════════════════════════

class FakeAuthRepository implements AuthRepository {
  @override
  Future<Either<Failure, User>> checkAuthStatus() async {
    return const Left(AuthFailure('No auth token found'));
  }

  @override
  Future<Either<Failure, User>> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String passwordConfirmation,
  }) async {
    return const Left(AuthFailure('Not implemented in test'));
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
  }) async {
    return const Left(AuthFailure('Not implemented in test'));
  }

  @override
  Future<Either<Failure, void>> logout() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, User>> getUser() async {
    return const Left(AuthFailure('Not implemented in test'));
  }

  @override
  Future<Either<Failure, void>> sendOtp({required String phone}) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, User>> verifyOtp({
    required String phone,
    required String otp,
  }) async {
    return const Left(AuthFailure('Not implemented in test'));
  }

  @override
  Future<Either<Failure, User>> verifyEmail({required String token}) async {
    return const Left(AuthFailure('Not implemented in test'));
  }

  @override
  Future<Either<Failure, User>> guestLogin() async {
    return const Left(AuthFailure('Not implemented in test'));
  }

  @override
  Future<Either<Failure, void>> registerFcmToken({
    required String token,
    required String deviceType,
  }) async {
    return const Right(null);
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Fake FeedRepository — returns empty list for all feed queries
// ═══════════════════════════════════════════════════════════════════════

class FakeFeedRepository implements FeedRepository {
  @override
  Future<Either<Failure, List<Happening>>> getNearbyHappenings({
    required double latitude,
    required double longitude,
    double radiusKm = 10.0,
    String? category,
    int page = 1,
  }) async {
    return const Right(<Happening>[]);
  }

  @override
  Future<Either<Failure, Happening>> getHappeningDetail(String uuid) async {
    return const Left(ServerFailure('Not implemented in test'));
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Fake ReportRepository — returns success for all reports
// ═══════════════════════════════════════════════════════════════════════

class FakeReportRepository implements ReportRepository {
  @override
  Future<Either<Failure, void>> submitReport({
    required String happeningUuid,
    required String reason,
    String? details,
  }) async {
    return const Right(null);
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Fake MapRepository — returns empty list for all map queries
// ═══════════════════════════════════════════════════════════════════════

class FakeMapRepository implements MapRepository {
  @override
  Future<Either<Failure, List<Happening>>> getMapHappenings({
    required double neLat,
    required double neLng,
    required double swLat,
    required double swLng,
    String? category,
  }) async {
    return const Right(<Happening>[]);
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Fake HappeningRepository — returns error for all creates
// ═══════════════════════════════════════════════════════════════════════

class FakeHappeningRepository implements HappeningRepository {
  @override
  Future<Either<Failure, Happening>> createHappening(
    CreateHappeningRequest request,
  ) async {
    return const Left(ServerFailure('Not implemented in test'));
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Fake SnapRepository — returns empty list for all snap queries
// ═══════════════════════════════════════════════════════════════════════

class FakeSnapRepository implements SnapRepository {
  @override
  Future<Either<Failure, List<Snap>>> getHappeningSnaps(
    String happeningUuid,
  ) async {
    return const Right(<Snap>[]);
  }

  @override
  Future<Either<Failure, Snap>> createSnap({
    required String happeningUuid,
    required String mediaUrl,
    required String mediaType,
    String? thumbnailUrl,
    int? durationSeconds,
  }) async {
    return const Left(ServerFailure('Not implemented in test'));
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Fake TicketRepository — returns error for all ticket operations
// ═══════════════════════════════════════════════════════════════════════

class FakeTicketRepository implements TicketRepository {
  @override
  Future<Either<Failure, InitializePaymentResponse>> initializePayment(
    InitializePaymentRequest request,
  ) async {
    return const Left(ServerFailure('Not implemented in test'));
  }

  @override
  Future<Either<Failure, List<Ticket>>> getMyTickets({
    String? status,
    int page = 1,
  }) async {
    return const Right(<Ticket>[]);
  }

  @override
  Future<Either<Failure, Ticket>> getTicketDetail(String uuid) async {
    return const Left(ServerFailure('Not implemented in test'));
  }

  @override
  Future<Either<Failure, Escrow>> getEscrowDashboard(String uuid) async {
    return const Left(ServerFailure('Not implemented in test'));
  }

  @override
  Future<Either<Failure, Escrow>> getEscrowByHappening(
      String happeningUuid) async {
    return const Left(ServerFailure('Not implemented in test'));
  }

  @override
  Future<Either<Failure, Escrow>> markEventComplete(String uuid) async {
    return const Left(ServerFailure('Not implemented in test'));
  }

  @override
  Future<Either<Failure, Ticket>> requestRefund(String ticketUuid) async {
    return const Left(ServerFailure('Not implemented in test'));
  }

  @override
  Future<Either<Failure, Ticket>> verifyTicketPayment(
      String ticketUuid) async {
    return const Left(ServerFailure('Not implemented in test'));
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Fake ProfileRepository — returns error for all profile operations
// ═══════════════════════════════════════════════════════════════════════

class FakeProfileRepository implements ProfileRepository {
  @override
  Future<Either<Failure, User>> getProfile() async {
    return const Left(AuthFailure('Not implemented in test'));
  }

  @override
  Future<Either<Failure, User>> updateProfile(
    UpdateProfileRequest request,
  ) async {
    return const Left(ServerFailure('Not implemented in test'));
  }

  @override
  Future<Either<Failure, User>> updateAvatar(String filePath) async {
    return const Left(ServerFailure('Not implemented in test'));
  }

  @override
  Future<Either<Failure, List<Happening>>> getMyHappenings() async {
    return const Right(<Happening>[]);
  }

  @override
  Future<Either<Failure, void>> deleteHappening(String uuid) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    return const Right(null);
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Fake HostVerificationRepository — returns not-found for status
// ═══════════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════════
// Fake NotificationRepository — returns empty list for all queries
// ═══════════════════════════════════════════════════════════════════════

class FakeNotificationRepository implements NotificationRepository {
  @override
  Future<Either<Failure, ({List<AppNotification> notifications, int total, int lastPage})>>
      getNotifications({int page = 1}) async {
    return const Right((notifications: <AppNotification>[], total: 0, lastPage: 1));
  }

  @override
  Future<Either<Failure, AppNotification>> markAsRead(String uuid) async {
    return const Left(ServerFailure('Not implemented in test'));
  }

  @override
  Future<Either<Failure, void>> markAllAsRead() async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, int>> getUnreadCount() async {
    return const Right(0);
  }
}

// ═══════════════════════════════════════════════════════════════════════
// Fake HostVerificationRepository — returns not-found for status
// ═══════════════════════════════════════════════════════════════════════

class FakeHostVerificationRepository implements HostVerificationRepository {
  @override
  Future<Either<Failure, HostVerification>> submitVerification(
    HostVerificationRequest request,
  ) async {
    return const Left(ServerFailure('Not implemented in test'));
  }

  @override
  Future<Either<Failure, HostVerification>> getVerificationStatus() async {
    return const Left(NotFoundFailure('No verification request found'));
  }
}

void main() {
  testWidgets('Splash screen shows MOB branding then navigates to onboarding',
      (WidgetTester tester) async {
    // ── Setup dependencies ──────────────────────────────────────────
    // Onboarding NOT complete → should navigate to /onboarding
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    const secureStorage = FlutterSecureStorage();

    final storageService = StorageService(
      secureStorage: secureStorage,
      prefs: prefs,
    );

    final dioClient = DioClient(
      baseUrl: 'https://test.example.com/api/v1',
      secureStorage: secureStorage,
    );

    final locationService = LocationService();
    final authRepository = FakeAuthRepository();
    final feedRepository = FakeFeedRepository();
    final reportRepository = FakeReportRepository();
    final mapRepository = FakeMapRepository();
    final snapRepository = FakeSnapRepository();
    final happeningRepository = FakeHappeningRepository();
    final ticketRepository = FakeTicketRepository();
    final profileRepository = FakeProfileRepository();
    final hostVerificationRepository = FakeHostVerificationRepository();
    final notificationRepository = FakeNotificationRepository();
    final getNearbyHappenings = GetNearbyHappenings(feedRepository);
    final firebaseStorageService = FirebaseStorageService();

    // ── Pump the app ────────────────────────────────────────────────
    await tester.pumpWidget(
      MobApp(
        authRepository: authRepository,
        storageService: storageService,
        locationService: locationService,
        dioClient: dioClient,
        getNearbyHappenings: getNearbyHappenings,
        feedRepository: feedRepository,
        reportRepository: reportRepository,
        mapRepository: mapRepository,
        snapRepository: snapRepository,
        happeningRepository: happeningRepository,
        ticketRepository: ticketRepository,
        profileRepository: profileRepository,
        hostVerificationRepository: hostVerificationRepository,
        notificationRepository: notificationRepository,
        firebaseStorageService: firebaseStorageService,
      ),
    );

    // Verify the splash screen shows the MOB branding
    expect(find.text('MOB'), findsOneWidget);
    expect(find.text('SEE WHAT\u2019S HAPPENING NOW'), findsOneWidget);

    // Advance past the 2-second splash delay to trigger auth check
    await tester.pump(const Duration(seconds: 3));
    // Allow BlocListener to fire and navigation to settle
    await tester.pumpAndSettle();

    // Should navigate to onboarding (since onboarding is NOT complete)
    // Verify the first onboarding slide is showing
    expect(find.textContaining('Discover'), findsOneWidget);
    expect(find.text('Skip'), findsOneWidget);
  });
}
