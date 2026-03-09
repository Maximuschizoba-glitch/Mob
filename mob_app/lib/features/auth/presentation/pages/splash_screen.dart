import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../core/services/storage_service.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();


    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));


    _startAuthCheck();
  }

  Future<void> _startAuthCheck() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    context.read<AuthCubit>().checkAuthStatus();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _navigateTo(String path) {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;
    context.go(path);
  }

  void _handleAuthState(AuthState state) {
    if (state is Authenticated) {
      _navigateTo(RoutePaths.feed);
    } else if (state is GuestMode) {
      _navigateTo(RoutePaths.feed);
    } else if (state is Unauthenticated) {
      final storageService = context.read<StorageService>();
      if (storageService.isOnboardingComplete()) {
        _navigateTo(RoutePaths.welcome);
      } else {
        _navigateTo(RoutePaths.onboarding);
      }
    } else if (state is AuthError) {
      _navigateTo(RoutePaths.welcome);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) => _handleAuthState(state),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [

            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    Text(
                      'MOB',
                      style: AppTypography.display.copyWith(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 8,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 12),

                    Text(
                      'SEE WHAT\u2019S HAPPENING NOW',
                      style: AppTypography.overline.copyWith(
                        fontSize: 12,
                        letterSpacing: 3,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),


            Padding(
              padding: const EdgeInsets.only(bottom: 60),
              child: FadeTransition(
                opacity: _pulseAnimation,
                child: Container(
                  width: 48,
                  height: 2,
                  decoration: BoxDecoration(
                    color: AppColors.cyan,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
