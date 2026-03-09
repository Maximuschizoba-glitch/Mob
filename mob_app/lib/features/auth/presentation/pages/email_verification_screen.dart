import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../shared/widgets/mob_gradient_button.dart';
import '../../../../shared/widgets/mob_text_button.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';


class EmailVerificationScreen extends StatelessWidget {
  const EmailVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email = context.read<AuthCubit>().currentUser?.email ?? '';

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is EmailVerificationSent) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Verification email sent!'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: MobTextButton(
                label: 'Skip',
                color: AppColors.textSecondary,
                onPressed: () => context.go(RoutePaths.locationPermission),
              ),
            ),
          ],
        ),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: AppSpacing.screenPadding,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  _buildIcon(),

                  AppSpacing.verticalLg,


                  const Text(
                    'Check Your Email',
                    style: AppTypography.h2,
                    textAlign: TextAlign.center,
                  ),

                  AppSpacing.verticalMd,


                  Text(
                    'We sent a verification link to',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  AppSpacing.verticalXs,


                  Text(
                    email,
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.cyan,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  AppSpacing.verticalSm,


                  Text(
                    'Link expires in 24 hours',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  AppSpacing.verticalXxl,


                  if (AppConfig.otpBypassEnabled) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.build_rounded,
                                size: 14,
                                color: AppColors.warning,
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Text(
                                'Dev Mode',
                                style: AppTypography.caption.copyWith(
                                  color: AppColors.warning,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton(
                              onPressed: () =>
                                  context.go(RoutePaths.locationPermission),
                              style: TextButton.styleFrom(
                                backgroundColor:
                                    AppColors.warning.withValues(alpha: 0.2),
                                foregroundColor: AppColors.warning,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      AppSpacing.radiusSm),
                                ),
                              ),
                              child: Text(
                                'Skip Verification (Dev Mode)',
                                style: AppTypography.buttonSmall.copyWith(
                                  color: AppColors.warning,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    AppSpacing.verticalBase,
                  ],


                  MobGradientButton(
                    label: 'Open Email App',
                    onPressed: _openEmailApp,
                  ),

                  AppSpacing.verticalBase,


                  MobTextButton(
                    label: 'Resend Email',
                    color: AppColors.cyan,
                    onPressed: () {
                      context.read<AuthCubit>().resendEmailVerification();
                    },
                  ),

                  AppSpacing.verticalXxl,


                  GestureDetector(
                    onTap: () => context.go(RoutePaths.locationPermission),
                    child: Text(
                      'I\u2019ll verify later \u2014 Skip for now',
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildIcon() {
    return SizedBox(
      width: 72,
      height: 72,
      child: Stack(
        children: [

          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.cyan.withValues(alpha: 0.1),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.mail_outline,
                size: 28,
                color: AppColors.cyan,
              ),
            ),
          ),


          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 22,
              height: 22,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.success,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.check,
                size: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _openEmailApp() async {
    final uri = Uri(scheme: 'mailto');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
