import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../../../../core/constants/route_paths.dart';
import '../../../../../shared/models/enums.dart';
import '../../../../../shared/widgets/mob_gradient_button.dart';
import '../../../../../shared/widgets/mob_outlined_button.dart';
import '../../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../../auth/presentation/bloc/auth_state.dart';
import '../../bloc/post_happening_cubit.dart';
import '../../bloc/post_happening_state.dart';


class ChooseTypePage extends StatefulWidget {
  const ChooseTypePage({super.key});

  @override
  State<ChooseTypePage> createState() => _ChooseTypePageState();
}

class _ChooseTypePageState extends State<ChooseTypePage> {
  @override
  void initState() {
    super.initState();

    context.read<AuthCubit>().refreshUser();
  }

  @override
  Widget build(BuildContext context) {


    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {
        return BlocBuilder<PostHappeningCubit, PostHappeningState>(
          builder: (context, state) {
            return Column(
              children: [
                _buildAppBar(context),
                _buildProgressBar(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: AppSpacing.screenPadding,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppSpacing.verticalXl,
                        _buildHeading(),
                        AppSpacing.verticalXl,
                        _buildTypeCards(context, state),
                        AppSpacing.verticalLg,
                        _buildProTip(state),
                      ],
                    ),
                  ),
                ),
                _buildBottomBar(context, state),
              ],
            );
          },
        );
      },
    );
  }


  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.elevated,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'New Happening',
              style: AppTypography.h4,
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            'Step 1 of 4',
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: SizedBox(
          height: 4,
          child: Stack(
            children: [

              Container(color: AppColors.card),

              FractionallySizedBox(
                widthFactor: 0.25,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildHeading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'What kind of happening?',
          style: AppTypography.h1,
        ),
        AppSpacing.verticalSm,
        Text(
          'Choose the type that best describes your post.',
          style: AppTypography.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }


  Widget _buildTypeCards(BuildContext context, PostHappeningState state) {
    final authState = context.read<AuthCubit>().state;
    final user =
        authState is Authenticated ? authState.user : null;
    final isVerifiedHost = user?.isHostVerified ?? false;

    return Row(
      children: [
        Expanded(
          child: _TypeCard(
            icon: Icons.theater_comedy,
            accentColor: AppColors.purple,
            label: 'OFFICIAL EVENT',
            subtitle: 'Organized with a set time, location, and optional tickets',
            isSelected: state.type == HappeningType.event,
            onTap: () => _onOfficialEventTapped(context, user),
            badge: !isVerifiedHost
                ? const _VerifiedHostBadge()
                : null,
          ),
        ),
        AppSpacing.horizontalMd,
        Expanded(
          child: _TypeCard(
            icon: Icons.auto_awesome,
            accentColor: AppColors.cyan,
            label: 'CASUAL HAPPENING',
            subtitle:
                'Something cool going on right now \u2014 food, vibe, scene',
            isSelected: state.type == HappeningType.casual,
            onTap: () => context
                .read<PostHappeningCubit>()
                .setType(HappeningType.casual),
          ),
        ),
      ],
    );
  }


  void _onOfficialEventTapped(
    BuildContext context,
    dynamic user,
  ) {
    final verificationStatus = user?.hostVerificationStatus as String?;

    if (verificationStatus == 'approved') {
      context.read<PostHappeningCubit>().setType(HappeningType.event);
      return;
    }

    if (verificationStatus == 'pending') {
      _showVerificationPendingDialog(context);
      return;
    }


    _showVerificationRequiredDialog(context);
  }

  void _showVerificationRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.verified_outlined,
                  color: AppColors.warning,
                  size: 32,
                ),
              ),
              AppSpacing.verticalBase,


              const Text(
                'Verification Required',
                style: AppTypography.h3,
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalSm,


              Text(
                'Official events can only be created by verified hosts. '
                'Get verified to unlock ticket sales and build trust '
                'with attendees.',
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              AppSpacing.verticalLg,


              MobGradientButton(
                label: 'Get Verified',
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.pop();
                  context.push(RoutePaths.hostVerification);
                },
              ),
              AppSpacing.verticalMd,


              MobOutlinedButton(
                label: 'Continue',
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showVerificationPendingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top,
                  color: AppColors.warning,
                  size: 32,
                ),
              ),
              AppSpacing.verticalBase,


              const Text(
                'Verification Pending',
                style: AppTypography.h3,
                textAlign: TextAlign.center,
              ),
              AppSpacing.verticalSm,


              Text(
                'Your verification is under review. You\u2019ll be able to '
                'create official events once approved.',
                textAlign: TextAlign.center,
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              AppSpacing.verticalLg,


              MobGradientButton(
                label: 'View Status',
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.pop();
                  context.push(RoutePaths.hostVerificationStatus);
                },
              ),
              AppSpacing.verticalMd,


              MobOutlinedButton(
                label: 'Continue',
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildProTip(PostHappeningState state) {
    final String tipText;
    if (state.type == HappeningType.event) {
      tipText =
          'Official events need an exact location and can sell tickets.';
    } else if (state.type == HappeningType.casual) {
      tipText =
          'Casual posts need at least one snap to show what\u2019s happening.';
    } else {
      tipText =
          'Not sure? Casual is great for anything happening right now.';
    }

    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: AppSpacing.cardRadius,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            color: AppColors.cyan,
            size: 20,
          ),
          AppSpacing.horizontalMd,
          Expanded(
            child: Text(
              tipText,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBottomBar(BuildContext context, PostHappeningState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(color: AppColors.surface, width: 0.5),
        ),
      ),
      child: MobGradientButton(
        label: 'Continue',
        onPressed: state.type != null
            ? () => context.read<PostHappeningCubit>().nextStep()
            : null,
      ),
    );
  }
}


class _TypeCard extends StatelessWidget {
  const _TypeCard({
    required this.icon,
    required this.accentColor,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
    this.badge,
  });

  final IconData icon;
  final Color accentColor;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget? badge;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: badge != null ? 200 : 180,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: AppSpacing.cardRadius,
          border: Border.all(
            color: isSelected ? AppColors.cyan : AppColors.surface,
            width: isSelected ? 1.5 : 0.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.cyan.withValues(alpha: 0.15),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ]
              : null,
        ),
        child: Stack(
          children: [

            Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      icon,
                      color: accentColor,
                      size: 22,
                    ),
                  ),
                  AppSpacing.verticalMd,

                  Text(
                    label,
                    style: AppTypography.bodySmall.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                  AppSpacing.verticalSm,

                  Expanded(
                    child: Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  if (badge != null) badge!,
                ],
              ),
            ),


            if (isSelected)
              Positioned(
                top: AppSpacing.sm,
                right: AppSpacing.sm,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.cyan,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: AppColors.background,
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}


class _VerifiedHostBadge extends StatelessWidget {
  const _VerifiedHostBadge();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.lock_outline,
            size: 12,
            color: AppColors.warning,
          ),
          const SizedBox(width: 4),
          Text(
            'Verified hosts only',
            style: AppTypography.micro.copyWith(
              color: AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}
