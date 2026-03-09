import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../core/connectivity/connectivity_cubit.dart';
import '../core/network/dio_client.dart';
import '../core/services/connectivity_service.dart';
import '../core/services/firebase_storage_service.dart';
import '../core/services/location_service.dart';
import '../core/services/storage_service.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/presentation/bloc/auth_cubit.dart';
import '../features/feed/domain/repositories/feed_repository.dart';
import '../features/happenings/domain/repositories/happening_repository.dart';
import '../features/happenings/domain/repositories/report_repository.dart';
import '../features/feed/domain/usecases/get_nearby_happenings.dart';
import '../features/feed/presentation/bloc/feed_cubit.dart';
import '../features/map/domain/repositories/map_repository.dart';
import '../features/map/presentation/bloc/map_cubit.dart';
import '../features/snaps/domain/repositories/snap_repository.dart';
import '../features/notifications/domain/repositories/notification_repository.dart';
import '../features/notifications/presentation/bloc/notification_cubit.dart';
import '../features/profile/domain/repositories/host_verification_repository.dart';
import '../features/profile/domain/repositories/profile_repository.dart';
import '../features/ticketing/domain/repositories/ticket_repository.dart';
import 'router.dart';
import 'theme.dart';


class MobApp extends StatelessWidget {
  const MobApp({
    super.key,
    required this.authRepository,
    required this.storageService,
    required this.locationService,
    required this.dioClient,
    required this.getNearbyHappenings,
    required this.feedRepository,
    required this.reportRepository,
    required this.mapRepository,
    required this.snapRepository,
    required this.happeningRepository,
    required this.ticketRepository,
    required this.profileRepository,
    required this.hostVerificationRepository,
    required this.notificationRepository,
    required this.firebaseStorageService,
    required this.connectivityService,
  });

  final AuthRepository authRepository;
  final StorageService storageService;
  final LocationService locationService;
  final DioClient dioClient;
  final GetNearbyHappenings getNearbyHappenings;
  final FeedRepository feedRepository;
  final ReportRepository reportRepository;
  final MapRepository mapRepository;
  final SnapRepository snapRepository;
  final HappeningRepository happeningRepository;
  final TicketRepository ticketRepository;
  final ProfileRepository profileRepository;
  final HostVerificationRepository hostVerificationRepository;
  final NotificationRepository notificationRepository;
  final FirebaseStorageService firebaseStorageService;
  final ConnectivityService connectivityService;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<StorageService>.value(value: storageService),
        RepositoryProvider<LocationService>.value(value: locationService),
        RepositoryProvider<DioClient>.value(value: dioClient),
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<FeedRepository>.value(value: feedRepository),
        RepositoryProvider<ReportRepository>.value(value: reportRepository),
        RepositoryProvider<MapRepository>.value(value: mapRepository),
        RepositoryProvider<SnapRepository>.value(value: snapRepository),
        RepositoryProvider<HappeningRepository>.value(
            value: happeningRepository),
        RepositoryProvider<TicketRepository>.value(value: ticketRepository),
        RepositoryProvider<ProfileRepository>.value(value: profileRepository),
        RepositoryProvider<HostVerificationRepository>.value(
            value: hostVerificationRepository),
        RepositoryProvider<NotificationRepository>.value(
            value: notificationRepository),
        RepositoryProvider<FirebaseStorageService>.value(
            value: firebaseStorageService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(
            create: (_) => AuthCubit(
              authRepository: authRepository,
              storageService: storageService,
            ),
          ),
          BlocProvider<FeedCubit>(
            create: (_) => FeedCubit(
              getNearbyHappenings: getNearbyHappenings,
              locationService: locationService,
            ),
          ),
          BlocProvider<MapCubit>(
            create: (_) => MapCubit(
              mapRepository: mapRepository,
              locationService: locationService,
            ),
          ),
          BlocProvider<NotificationCubit>(
            create: (_) => NotificationCubit(
              notificationRepository: notificationRepository,
            )..loadUnreadCount(),
          ),
          BlocProvider<ConnectivityCubit>(
            create: (_) => ConnectivityCubit(connectivityService),
          ),
        ],
        child: MaterialApp.router(
          title: 'Mob',
          debugShowCheckedModeBanner: false,


          theme: MobTheme.darkTheme,
          themeMode: ThemeMode.dark,


          routerConfig: AppRouter.router,


          builder: (context, child) {
            return GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: child,
            );
          },
        ),
      ),
    );
  }
}
