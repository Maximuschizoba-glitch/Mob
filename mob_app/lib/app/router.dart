import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../core/constants/route_paths.dart';
import '../features/auth/presentation/bloc/auth_cubit.dart';
import '../features/auth/presentation/bloc/auth_state.dart';
import '../features/auth/presentation/pages/email_verification_screen.dart';
import '../features/auth/presentation/pages/location_permission_screen.dart';
import '../features/auth/presentation/pages/login_screen.dart';
import '../features/auth/presentation/pages/onboarding_screen.dart';
import '../features/auth/presentation/pages/otp_verification_screen.dart';
import '../features/auth/presentation/pages/register_screen.dart';
import '../features/auth/presentation/pages/splash_screen.dart';
import '../features/auth/presentation/pages/welcome_screen.dart';
import '../features/feed/domain/entities/happening.dart';
import '../features/feed/domain/repositories/feed_repository.dart';
import '../features/feed/presentation/bloc/feed_cubit.dart';
import '../features/feed/presentation/bloc/feed_state.dart';
import '../features/feed/presentation/pages/category_selection_screen.dart';
import '../features/feed/presentation/pages/feed_screen.dart';
import '../core/services/firebase_storage_service.dart';
import '../features/happenings/domain/repositories/happening_repository.dart';
import '../features/happenings/presentation/bloc/happening_detail_cubit.dart';
import '../features/happenings/presentation/bloc/post_happening_cubit.dart';
import '../features/happenings/presentation/pages/happening_detail_screen.dart';
import '../features/happenings/presentation/pages/post/post_wizard_shell.dart';
import '../features/map/presentation/pages/map_screen.dart';
import '../features/profile/presentation/pages/edit_profile_page.dart';
import '../features/profile/presentation/pages/host_verification_request_page.dart';
import '../features/profile/presentation/pages/host_verification_status_page.dart';
import '../features/profile/presentation/pages/my_happenings_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/profile/presentation/pages/settings_page.dart';
import '../features/snaps/domain/repositories/snap_repository.dart';
import '../features/snaps/presentation/bloc/snaps_cubit.dart';
import '../features/snaps/presentation/pages/snap_upload_screen.dart';
import '../features/snaps/presentation/pages/snap_viewer_screen.dart';
import '../features/ticketing/presentation/bloc/payment_state.dart';
import '../features/ticketing/domain/entities/ticket.dart';
import '../features/ticketing/presentation/pages/payment_webview_page.dart';
import '../features/ticketing/presentation/pages/ticket_confirmation_page.dart';
import '../features/ticketing/presentation/pages/my_tickets_page.dart';
import '../features/ticketing/presentation/pages/host_dashboard_page.dart';
import '../features/ticketing/presentation/pages/ticket_detail_page.dart';
import '../features/ticketing/presentation/pages/ticket_purchase_page.dart';
import '../features/ticketing/presentation/pages/ticket_scanner_page.dart';
import '../features/notifications/presentation/pages/notifications_page.dart';
import '../features/system/presentation/pages/error_page.dart';
import '../features/system/presentation/pages/offline_page.dart';
import 'main_shell.dart';


class AppRouter {
  AppRouter._();


  static final GlobalKey<NavigatorState> rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');


  static final GlobalKey<NavigatorState> _feedNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'feed');
  static final GlobalKey<NavigatorState> _mapNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'map');
  static final GlobalKey<NavigatorState> _ticketsNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'tickets');
  static final GlobalKey<NavigatorState> _profileNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'profile');

  static final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [


      GoRoute(
        path: '/',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),


      GoRoute(
        path: RoutePaths.onboarding,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: RoutePaths.welcome,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: RoutePaths.login,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RoutePaths.register,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RoutePaths.phoneOtp,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OtpVerificationScreen(),
      ),
      GoRoute(
        path: RoutePaths.emailVerification,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const EmailVerificationScreen(),
      ),
      GoRoute(
        path: RoutePaths.locationPermission,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LocationPermissionScreen(),
      ),
      GoRoute(
        path: RoutePaths.categorySelection,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const CategorySelectionScreen(),
      ),


      StatefulShellRoute.indexedStack(
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [

          StatefulShellBranch(
            navigatorKey: _feedNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.feed,
                builder: (context, state) => const FeedScreen(),
              ),
            ],
          ),


          StatefulShellBranch(
            navigatorKey: _mapNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.map,
                builder: (context, state) =>
                    const MapScreen(),
              ),
            ],
          ),


          StatefulShellBranch(
            navigatorKey: _ticketsNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.tickets,
                builder: (context, state) =>
                    const MyTicketsPage(),
              ),
            ],
          ),


          StatefulShellBranch(
            navigatorKey: _profileNavigatorKey,
            routes: [
              GoRoute(
                path: RoutePaths.profile,
                builder: (context, state) =>
                    const ProfilePage(),
              ),
            ],
          ),
        ],
      ),


      GoRoute(
        path: RoutePaths.post,
        parentNavigatorKey: rootNavigatorKey,
        redirect: (context, state) {
          final authState = context.read<AuthCubit>().state;
          if (authState is GuestMode || authState is Unauthenticated) {
            return RoutePaths.feed;
          }
          return null;
        },
        builder: (context, state) {

          final authCubit = context.read<AuthCubit>();
          final userId = authCubit.currentUser?.uuid ?? '';

          return BlocProvider(
            create: (ctx) => PostHappeningCubit(
              happeningRepository: ctx.read<HappeningRepository>(),
              firebaseStorageService: ctx.read<FirebaseStorageService>(),
              userId: userId,
            ),
            child: const PostWizardShell(),
          );
        },
      ),


      GoRoute(
        path: RoutePaths.happeningDetail,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final uuid = state.pathParameters['uuid'] ?? '';


          Happening? cached;
          try {
            final feedState = context.read<FeedCubit>().state;
            if (feedState is FeedLoaded) {
              cached = feedState.happenings
                  .where((h) => h.uuid == uuid)
                  .firstOrNull;
            }
          } catch (_) {

          }

          return BlocProvider(
            create: (ctx) => HappeningDetailCubit(
              feedRepository: ctx.read<FeedRepository>(),
              snapRepository: ctx.read<SnapRepository>(),
              happeningRepository: ctx.read<HappeningRepository>(),
              uuid: uuid,
              cachedHappening: cached,
            ),
            child: HappeningDetailScreen(uuid: uuid),
          );
        },
      ),


      GoRoute(
        path: RoutePaths.snapViewer,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final happeningUuid =
              state.pathParameters['happeningUuid'] ?? '';
          final startIndex = int.tryParse(
                state.uri.queryParameters['startIndex'] ?? '',
              ) ??
              0;


          String happeningTitle = '';
          try {
            final feedState = context.read<FeedCubit>().state;
            if (feedState is FeedLoaded) {
              happeningTitle = feedState.happenings
                      .where((h) => h.uuid == happeningUuid)
                      .firstOrNull
                      ?.title ??
                  '';
            }
          } catch (_) {}

          return BlocProvider(
            create: (ctx) => SnapsCubit(
              ctx.read<SnapRepository>(),
            ),
            child: SnapViewerScreen(
              happeningUuid: happeningUuid,
              happeningTitle: happeningTitle,
              startIndex: startIndex,
            ),
          );
        },
      ),
      GoRoute(
        path: RoutePaths.snapCamera,
        parentNavigatorKey: rootNavigatorKey,
        redirect: (context, state) {
          final authState = context.read<AuthCubit>().state;
          if (authState is GuestMode || authState is Unauthenticated) {
            return RoutePaths.feed;
          }
          return null;
        },
        builder: (context, state) {
          final happeningUuid =
              state.pathParameters['happeningUuid'] ?? '';


          String happeningTitle = '';
          try {
            final feedState = context.read<FeedCubit>().state;
            if (feedState is FeedLoaded) {
              happeningTitle = feedState.happenings
                      .where((h) => h.uuid == happeningUuid)
                      .firstOrNull
                      ?.title ??
                  '';
            }
          } catch (_) {}

          return BlocProvider(
            create: (ctx) => SnapsCubit(
              ctx.read<SnapRepository>(),
            )..setHappeningUuid(happeningUuid),
            child: SnapUploadScreen(
              happeningUuid: happeningUuid,
              happeningTitle: happeningTitle,
            ),
          );
        },
      ),


      GoRoute(
        path: RoutePaths.ticketPurchase,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final args = state.extra as TicketPurchaseArgs?;


          if (args == null) {
            return const _PlaceholderScreen(
              title: 'Ticket Purchase',
              subtitle: 'Missing event data. Please try again.',
            );
          }

          return TicketPurchasePage(args: args);
        },
      ),
      GoRoute(
        path: RoutePaths.paymentWebView,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final paymentData = state.extra as PaymentInitialized?;

          if (paymentData == null) {
            return const _PlaceholderScreen(
              title: 'Payment',
              subtitle: 'Missing payment data. Please try again.',
            );
          }

          return PaymentWebViewPage(
            paymentUrl: paymentData.paymentUrl,
            ticketUuid: paymentData.ticketUuid,
            gateway: paymentData.gateway,
            paymentReference: paymentData.paymentReference,
          );
        },
      ),
      GoRoute(
        path: RoutePaths.ticketConfirmation,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra;
          List<Ticket>? tickets;

          if (extra is List<Ticket>) {
            tickets = extra;
          } else if (extra is Ticket) {

            tickets = [extra];
          }

          if (tickets == null || tickets.isEmpty) {
            return const _PlaceholderScreen(
              title: 'Ticket Confirmation',
              subtitle: 'Missing ticket data. Please check My Tickets.',
            );
          }

          return TicketConfirmationPage(tickets: tickets);
        },
      ),
      GoRoute(
        path: RoutePaths.ticketDetail,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final uuid = state.pathParameters['uuid'] ?? '';
          return TicketDetailPage(ticketUuid: uuid);
        },
      ),


      GoRoute(
        path: RoutePaths.hostDashboard,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final happeningUuid =
              state.pathParameters['happeningUuid'] ?? '';
          return HostDashboardPage(happeningUuid: happeningUuid);
        },
      ),


      GoRoute(
        path: RoutePaths.ticketScanner,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final happeningUuid =
              state.pathParameters['happeningUuid'] ?? '';
          return TicketScannerPage(happeningUuid: happeningUuid);
        },
      ),


      GoRoute(
        path: RoutePaths.editProfile,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const EditProfilePage(),
      ),
      GoRoute(
        path: RoutePaths.settings,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: RoutePaths.myHappenings,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const MyHappeningsPage(),
      ),
      GoRoute(
        path: RoutePaths.hostVerification,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            const HostVerificationRequestPage(),
      ),
      GoRoute(
        path: RoutePaths.hostVerificationStatus,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            const HostVerificationStatusPage(),
      ),


      GoRoute(
        path: RoutePaths.notifications,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const NotificationsPage(),
      ),


      GoRoute(
        path: RoutePaths.offline,
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const OfflinePage(),
      ),
    ],


    redirect: (context, state) {
      final location = state.uri.path;


      if (location == '/') return null;


      final authState = context.read<AuthCubit>().state;
      final isAuthenticated = authState is Authenticated;
      final isGuest = authState is GuestMode;


      if (isAuthenticated) {
        const authRoutes = [
          RoutePaths.onboarding,
          RoutePaths.welcome,
          RoutePaths.login,
          RoutePaths.register,
        ];
        if (authRoutes.contains(location)) {
          return RoutePaths.feed;
        }
      }


      if (isGuest) {
        const guestBlockedRoutes = [
          RoutePaths.onboarding,
          RoutePaths.welcome,
        ];
        if (guestBlockedRoutes.contains(location)) {
          return RoutePaths.feed;
        }
      }


      return null;
    },


    errorBuilder: (context, state) => ErrorPage(
      title: 'Page Not Found',
      message: 'The page you\u2019re looking for doesn\u2019t exist.',
      onGoHome: () => router.go(RoutePaths.feed),
    ),
  );
}


class _PlaceholderScreen extends StatelessWidget {
  const _PlaceholderScreen({
    required this.title,
    this.subtitle,
  });

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                'M',
                style: AppTypography.h1.copyWith(
                  color: AppColors.background,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: AppTypography.h2,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppColors.elevated,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Placeholder',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
