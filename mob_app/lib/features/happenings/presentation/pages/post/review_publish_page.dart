import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../../../../core/constants/route_paths.dart';
import '../../../../../shared/widgets/mob_badge.dart';
import '../../../../../shared/widgets/mob_card.dart';
import '../../../../../shared/widgets/mob_gradient_button.dart';
import '../../../../../shared/widgets/mob_text_button.dart';
import '../../../../auth/presentation/bloc/auth_cubit.dart';
import '../../bloc/post_happening_cubit.dart';
import '../../bloc/post_happening_state.dart';


class ReviewPublishPage extends StatelessWidget {
  const ReviewPublishPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PostHappeningCubit, PostHappeningState>(
      listenWhen: (prev, curr) =>
          (!prev.isSuccess && curr.isSuccess) ||
          (prev.error != curr.error && curr.error != null),
      listener: (context, state) {
        if (state.isSuccess && state.createdHappening != null) {
          _onPublishSuccess(context, state.createdHappening!.uuid);
        } else if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              action: SnackBarAction(
                label: 'RETRY',
                textColor: AppColors.textPrimary,
                onPressed: () =>
                    context.read<PostHappeningCubit>().publish(),
              ),
            ),
          );
        }
      },
      child: BlocBuilder<PostHappeningCubit, PostHappeningState>(
        builder: (context, state) {
          return Stack(
            children: [
              Column(
                children: [
                  _buildAppBar(context),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: AppSpacing.screenPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppSpacing.verticalLg,
                          _buildPreviewCard(context, state),
                          AppSpacing.verticalXl,
                          _buildDetailsSummary(state),
                          AppSpacing.verticalLg,
                          _buildExpiryWarning(),
                          AppSpacing.verticalXxl,
                        ],
                      ),
                    ),
                  ),
                  _buildBottomBar(context, state),
                ],
              ),

              if (state.isSubmitting) _buildUploadOverlay(state),
            ],
          );
        },
      ),
    );
  }

  void _onPublishSuccess(BuildContext context, String uuid) {


    context.go(RoutePaths.feed);
    context.push(RoutePaths.happeningDetailPath(uuid));
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
            onTap: () => context.read<PostHappeningCubit>().previousStep(),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.elevated,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Review',
              style: AppTypography.h4,
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(width: 36),
        ],
      ),
    );
  }


  Widget _buildPreviewCard(BuildContext context, PostHappeningState state) {
    final user = context.read<AuthCubit>().currentUser;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'PREVIEW',
          style: AppTypography.overline.copyWith(
            color: AppColors.textTertiary,
            letterSpacing: 1.0,
          ),
        ),
        AppSpacing.verticalSm,
        ClipRRect(
          borderRadius: AppSpacing.cardRadius,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [

                      if (state.snapFiles.isNotEmpty)
                        Image.file(
                          state.snapFiles.first,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _buildPlaceholderCover(),
                        )
                      else
                        _buildPlaceholderCover(),


                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.7),
                              ],
                              stops: const [0.4, 1.0],
                            ),
                          ),
                        ),
                      ),


                      if (state.category != null)
                        Positioned(
                          top: AppSpacing.md,
                          left: AppSpacing.md,
                          child: MobBadge(
                            label: state.category!.displayName.toUpperCase(),
                            color: state.category!.color,
                            icon: Icons.circle,
                            fontSize: 9,
                          ),
                        ),


                      Positioned(
                        top: AppSpacing.md,
                        right: AppSpacing.md,
                        child: MobBadge(
                          label: state.isEvent ? 'EVENT' : 'CASUAL',
                          color: state.isEvent
                              ? AppColors.purple
                              : AppColors.success,
                        ),
                      ),


                      Positioned(
                        left: AppSpacing.base,
                        right: AppSpacing.base,
                        bottom: AppSpacing.base,
                        child: Text(
                          state.title ?? 'Untitled',
                          style: AppTypography.h3.copyWith(
                            color: AppColors.textPrimary,
                            shadows: [
                              Shadow(
                                color: Colors.black.withValues(alpha: 0.5),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),


                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [

                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.elevated,
                          border: Border.all(
                            color: AppColors.cyan.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          user?.initials ?? '?',
                          style: AppTypography.micro.copyWith(
                            color: AppColors.cyan,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      AppSpacing.horizontalSm,
                      Expanded(
                        child: Text(
                          user?.name ?? 'You',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        'Just now',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderCover() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.elevated,
            AppColors.card,
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: AppColors.textTertiary,
          size: 48,
        ),
      ),
    );
  }


  Widget _buildDetailsSummary(PostHappeningState state) {
    final dateFormat = DateFormat('EEE, MMM d \u2022 h:mm a');

    return MobCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Details', style: AppTypography.h4),
          AppSpacing.verticalMd,
          _detailRow(
            Icons.location_on_outlined,
            'Location',
            state.isAreaBased
                ? 'General area \u2248${_formatRadius(state.radiusMeters ?? 500)}'
                : (state.address ?? 'Not set'),
          ),
          _divider(),
          _detailRow(
            Icons.calendar_today_outlined,
            'When',
            state.isHappeningNow
                ? 'Happening Now'
                : state.startsAt != null
                    ? dateFormat.format(state.startsAt!)
                    : 'Not set',
          ),
          _divider(),
          _detailRow(
            Icons.category_outlined,
            'Category',
            state.category != null
                ? '${state.category!.emoji}  ${state.category!.displayName}'
                : 'Not set',
          ),
          _divider(),
          _detailRow(
            Icons.camera_alt_outlined,
            'Snaps',
            state.snapFiles.isEmpty
                ? 'No photos'
                : '${state.snapFiles.length} photo${state.snapFiles.length > 1 ? 's' : ''} attached',
          ),
          _divider(),
          _detailRow(
            Icons.confirmation_number_outlined,
            'Tickets',
            state.isTicketed && state.ticketPrice != null
                ? '\u20A6${_formatPrice(state.ticketPrice!)} \u2022 ${state.ticketQuantity ?? 0} available'
                : 'Free entry',
          ),
          _divider(),
          _detailRow(
            Icons.access_time,
            'Expires',
            '24 hours after publishing',
          ),
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.textTertiary, size: 18),
          AppSpacing.horizontalMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
                AppSpacing.verticalXs,
                Text(
                  value,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() {
    return const Divider(
      color: AppColors.surface,
      height: 1,
    );
  }


  Widget _buildExpiryWarning() {
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(
          color: AppColors.warning.withValues(alpha: 0.25),
          width: 0.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.schedule,
            color: AppColors.warning,
            size: 20,
          ),
          AppSpacing.horizontalMd,
          Expanded(
            child: Text(
              'This post will automatically expire 24 hours after publishing.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.warning,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildUploadOverlay(PostHappeningState state) {
    return Positioned.fill(
      child: Container(
        color: AppColors.background.withValues(alpha: 0.85),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              SizedBox(
                width: 80,
                height: 80,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: state.uploadProgress > 0
                          ? state.uploadProgress
                          : null,
                      color: AppColors.cyan,
                      strokeWidth: 4,
                      backgroundColor: AppColors.surface,
                    ),
                    Text(
                      '${(state.uploadProgress * 100).round()}%',
                      style: AppTypography.body.copyWith(
                        color: AppColors.cyan,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.verticalXl,
              Text(
                state.uploadStatusText ?? 'Publishing...',
                style: AppTypography.body.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              AppSpacing.verticalSm,
              Text(
                'Please don\u2019t close the app',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MobGradientButton(
            label: 'GO LIVE',
            isLarge: true,
            icon: Icons.rocket_launch,
            isLoading: state.isSubmitting,
            onPressed: state.isSubmitting
                ? null
                : () => context.read<PostHappeningCubit>().publish(),
          ),
          AppSpacing.verticalSm,
          MobTextButton(
            label: '\u2190 Back to Edit',
            onPressed: state.isSubmitting
                ? null
                : () => context.read<PostHappeningCubit>().previousStep(),
          ),
        ],
      ),
    );
  }


  String _formatRadius(double meters) {
    if (meters >= 1000) {
      return '${(meters / 1000).toStringAsFixed(1)}km';
    }
    return '${meters.round()}m';
  }

  String _formatPrice(double price) {
    if (price >= 1000) {
      final formatted = price.toStringAsFixed(0);

      final buffer = StringBuffer();
      int count = 0;
      for (int i = formatted.length - 1; i >= 0; i--) {
        buffer.write(formatted[i]);
        count++;
        if (count % 3 == 0 && i > 0) buffer.write(',');
      }
      return buffer.toString().split('').reversed.join();
    }
    return price.toStringAsFixed(0);
  }
}
