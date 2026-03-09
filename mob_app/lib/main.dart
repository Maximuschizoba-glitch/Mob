import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/router.dart';
import 'core/constants/api_endpoints.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_typography.dart';
import 'core/constants/route_paths.dart';
import 'features/auth/presentation/bloc/auth_cubit.dart';
import 'core/network/dio_client.dart';
import 'core/services/connectivity_service.dart';
import 'core/services/firebase_storage_service.dart';
import 'core/services/location_service.dart';
import 'core/services/push_notification_service.dart';
import 'core/services/storage_service.dart';
import 'features/auth/data/datasources/auth_local_data_source.dart';
import 'features/auth/data/datasources/auth_remote_data_source.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/feed/data/datasources/feed_remote_data_source.dart';
import 'features/feed/data/repositories/feed_repository_impl.dart';
import 'features/feed/domain/usecases/get_nearby_happenings.dart';
import 'features/happenings/data/datasources/report_remote_data_source.dart';
import 'features/happenings/data/repositories/report_repository_impl.dart';
import 'features/map/data/datasources/map_remote_data_source.dart';
import 'features/map/data/repositories/map_repository_impl.dart';
import 'features/happenings/data/datasources/happening_remote_data_source.dart';
import 'features/happenings/data/repositories/happening_repository_impl.dart';
import 'features/snaps/data/datasources/snap_remote_data_source.dart';
import 'features/snaps/data/repositories/snap_repository_impl.dart';
import 'features/notifications/data/datasources/notification_remote_data_source.dart';
import 'features/notifications/data/repositories/notification_repository_impl.dart';
import 'features/profile/data/datasources/host_verification_remote_data_source.dart';
import 'features/profile/data/datasources/profile_remote_data_source.dart';
import 'features/profile/data/repositories/host_verification_repository_impl.dart';
import 'features/profile/data/repositories/profile_repository_impl.dart';
import 'features/ticketing/data/datasources/ticket_remote_data_source.dart';
import 'features/ticketing/data/repositories/ticket_repository_impl.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();


  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);


  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF0A0E1A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );


  final prefs = await SharedPreferences.getInstance();

  const secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  final storageService = StorageService(
    secureStorage: secureStorage,
    prefs: prefs,
  );

  final dioClient = DioClient(
    baseUrl: ApiEndpoints.baseUrl,
    secureStorage: secureStorage,
    onUnauthorized: () {
      debugPrint('[Mob] Unauthorized — token expired or invalid');


      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = AppRouter.rootNavigatorKey.currentContext;
        if (context == null) return;


        try {
          context.read<AuthCubit>().forceLogout();
        } catch (_) {

        }


        AppRouter.router.go(RoutePaths.welcome);


        try {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Session expired. Please log in again.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              backgroundColor: AppColors.elevated,
              behavior: SnackBarBehavior.floating,
              duration: const Duration(seconds: 4),
            ),
          );
        } catch (_) {

        }
      });
    },
  );

  final locationService = LocationService();
  final connectivityService = ConnectivityService();


  final authRemoteDataSource = AuthRemoteDataSourceImpl(
    dioClient: dioClient,
  );

  final authLocalDataSource = AuthLocalDataSourceImpl(
    secureStorage: secureStorage,
    prefs: prefs,
  );


  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    localDataSource: authLocalDataSource,
  );


  final feedRemoteDataSource = FeedRemoteDataSourceImpl(
    dioClient: dioClient,
  );

  final feedRepository = FeedRepositoryImpl(
    remoteDataSource: feedRemoteDataSource,
  );

  final getNearbyHappenings = GetNearbyHappenings(feedRepository);


  final reportRemoteDataSource = ReportRemoteDataSourceImpl(
    dioClient: dioClient,
  );

  final reportRepository = ReportRepositoryImpl(
    remoteDataSource: reportRemoteDataSource,
  );


  final mapRemoteDataSource = MapRemoteDataSourceImpl(
    dioClient: dioClient,
  );

  final mapRepository = MapRepositoryImpl(
    remoteDataSource: mapRemoteDataSource,
  );


  final snapRemoteDataSource = SnapRemoteDataSourceImpl(
    dioClient: dioClient,
  );

  final snapRepository = SnapRepositoryImpl(
    remoteDataSource: snapRemoteDataSource,
  );


  final happeningRemoteDataSource = HappeningRemoteDataSourceImpl(
    dioClient: dioClient,
  );

  final happeningRepository = HappeningRepositoryImpl(
    remoteDataSource: happeningRemoteDataSource,
  );


  final ticketRemoteDataSource = TicketRemoteDataSourceImpl(
    dioClient: dioClient,
  );

  final ticketRepository = TicketRepositoryImpl(
    remoteDataSource: ticketRemoteDataSource,
  );


  final profileRemoteDataSource = ProfileRemoteDataSourceImpl(
    dioClient: dioClient,
  );

  final profileRepository = ProfileRepositoryImpl(
    remoteDataSource: profileRemoteDataSource,
  );


  final hostVerificationRemoteDataSource =
      HostVerificationRemoteDataSourceImpl(
    dioClient: dioClient,
  );

  final hostVerificationRepository = HostVerificationRepositoryImpl(
    remoteDataSource: hostVerificationRemoteDataSource,
  );


  final notificationRemoteDataSource = NotificationRemoteDataSourceImpl(
    dioClient: dioClient,
  );

  final notificationRepository = NotificationRepositoryImpl(
    remoteDataSource: notificationRemoteDataSource,
  );


  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  await FirebaseAuth.instance.signInAnonymously();


  final firebaseStorageService = FirebaseStorageService();


  final pushNotificationService = PushNotificationService(
    router: AppRouter.router,
  );
  await pushNotificationService.initialize();


  runApp(
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
      connectivityService: connectivityService,
    ),
  );
}
