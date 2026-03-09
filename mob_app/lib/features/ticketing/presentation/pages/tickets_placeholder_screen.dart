import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../shared/widgets/mob_gradient_button.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';


class TicketsPlaceholderScreen extends StatelessWidget {
  const TicketsPlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            return _buildAuthenticatedView();
          }
          return _buildGuestView(context);
        },
      ),
    );
  }

  Widget _buildAuthenticatedView() {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.elevated,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.confirmation_number_outlined,
                size: 40,
                color: AppColors.cyan,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            const Text(
              'My Tickets',
              style: AppTypography.h3,
            ),

            const SizedBox(height: AppSpacing.sm),

            Text(
              'My Tickets coming in Phase F7',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textTertiary,
              ),
            ),

            const SizedBox(height: AppSpacing.base),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.elevated,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                'QR Codes \u2022 Escrow Tracking \u2022 Refunds',
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

  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AppColors.elevated,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 40,
                color: AppColors.textTertiary,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            const Text(
              'Sign Up to View Tickets',
              style: AppTypography.h3,
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppSpacing.sm),

            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                'Create an account to purchase tickets, track escrow payments, and get QR codes for events.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            SizedBox(
              width: 220,
              child: MobGradientButton(
                label: 'Create Account',
                onPressed: () => context.push(RoutePaths.register),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            GestureDetector(
              onTap: () => context.push(RoutePaths.login),
              child: Text(
                'Already have an account? Log In',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.cyan,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
