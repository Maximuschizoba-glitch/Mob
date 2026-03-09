import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/constants/route_paths.dart';
import 'mob_bottom_sheet.dart';
import 'mob_gradient_button.dart';
import 'mob_outlined_button.dart';
import 'mob_text_button.dart';


class GuestPromptSheet {
  GuestPromptSheet._();


  static Future<void> show(
    BuildContext context, {
    required String action,
  }) {
    return MobBottomSheet.show(
      context,
      child: _GuestPromptContent(action: action),
    );
  }
}

class _GuestPromptContent extends StatelessWidget {
  const _GuestPromptContent({required this.action});

  final String action;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: AppSpacing.sm),


        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.cyan.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.lock_outline_rounded,
            size: 28,
            color: AppColors.cyan,
          ),
        ),

        const SizedBox(height: AppSpacing.base),


        Text(
          'Sign Up to Continue',
          style: AppTypography.h3.copyWith(
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: AppSpacing.sm),


        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 300),
          child: Text(
            'Create an account to $action.',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        const SizedBox(height: AppSpacing.xl),


        const _BenefitRow(text: 'Buy tickets with escrow protection'),
        const SizedBox(height: AppSpacing.sm),
        const _BenefitRow(text: 'Post happenings and share snaps'),
        const SizedBox(height: AppSpacing.sm),
        const _BenefitRow(text: 'Get verified as a host'),

        const SizedBox(height: AppSpacing.xxl),


        MobGradientButton(
          label: 'Create Account',
          onPressed: () {
            final router = GoRouter.of(context);
            Navigator.of(context).pop();
            router.go(RoutePaths.register);
          },
        ),

        const SizedBox(height: AppSpacing.md),


        MobOutlinedButton(
          label: 'Log In',
          onPressed: () {
            final router = GoRouter.of(context);
            Navigator.of(context).pop();
            router.go(RoutePaths.login);
          },
        ),

        const SizedBox(height: AppSpacing.base),


        Center(
          child: MobTextButton(
            label: 'Continue Browsing',
            color: AppColors.textTertiary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),

        const SizedBox(height: AppSpacing.base),
      ],
    );
  }
}


class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        children: [

          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const Icon(
              Icons.check,
              size: 14,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(width: AppSpacing.md),


          Expanded(
            child: Text(
              text,
              style: AppTypography.body.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
