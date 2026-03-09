import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../shared/widgets/mob_gradient_button.dart';
import '../../../../shared/widgets/mob_outlined_button.dart';
import '../bloc/auth_cubit.dart';


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [

          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 300,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    AppColors.cyan.withValues(alpha: 0.04),
                    AppColors.purple.withValues(alpha: 0.02),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),


          SafeArea(
            child: Column(
              children: [

                const Expanded(
                  child: Center(
                    child: _Branding(),
                  ),
                ),


                _BottomActions(
                  onSignUp: () => context.push(RoutePaths.register),
                  onLogIn: () => context.push(RoutePaths.login),
                  onGuest: () async {
                    await context.read<AuthCubit>().continueAsGuest();
                    if (context.mounted) context.go(RoutePaths.feed);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _Branding extends StatelessWidget {
  const _Branding();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [

        Text(
          'MOB',
          style: AppTypography.display.copyWith(
            fontSize: 48,
            letterSpacing: 8,
          ),
        ),

        AppSpacing.verticalMd,


        Container(
          width: 40,
          height: 2,
          color: AppColors.cyan,
        ),

        AppSpacing.verticalMd,


        Text(
          'Find the pulse of the city.',
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}


class _BottomActions extends StatelessWidget {
  const _BottomActions({
    required this.onSignUp,
    required this.onLogIn,
    required this.onGuest,
  });

  final VoidCallback onSignUp;
  final VoidCallback onLogIn;
  final VoidCallback onGuest;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.xxxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          MobGradientButton(
            label: 'Sign Up',
            onPressed: onSignUp,
          ),

          AppSpacing.verticalMd,


          MobOutlinedButton(
            label: 'Log In',
            onPressed: onLogIn,
          ),

          AppSpacing.verticalXl,


          GestureDetector(
            onTap: onGuest,
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.visibility_outlined,
                  size: 16,
                  color: AppColors.textTertiary,
                ),
                AppSpacing.horizontalSm,
                Text(
                  'Continue as Guest',
                  style: AppTypography.buttonSmall.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
