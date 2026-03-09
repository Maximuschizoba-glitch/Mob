import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../../../../shared/widgets/mob_gradient_button.dart';
import '../../../../../shared/widgets/mob_outlined_button.dart';
import '../../../../../shared/widgets/mob_text_button.dart';
import '../../bloc/post_happening_cubit.dart';
import '../../bloc/post_happening_state.dart';


class AddSnapsPage extends StatefulWidget {
  const AddSnapsPage({super.key});

  @override
  State<AddSnapsPage> createState() => _AddSnapsPageState();
}

class _AddSnapsPageState extends State<AddSnapsPage> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFromCamera() async {
    final state = context.read<PostHappeningCubit>().state;
    if (!state.canAddSnap) return;

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (photo != null && mounted) {
        context.read<PostHappeningCubit>().addSnap(File(photo.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open camera: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _pickFromGallery() async {
    final state = context.read<PostHappeningCubit>().state;
    if (!state.canAddSnap) return;

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (photo != null && mounted) {
        context.read<PostHappeningCubit>().addSnap(File(photo.path));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not open gallery: $e'),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void _removeSnap(int index, PostHappeningState state) {

    if (state.isAreaBased && state.snapFiles.length == 1) {
      showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: AppSpacing.cardRadius),
          title: Text(
            'Remove snap?',
            style: AppTypography.h4.copyWith(color: AppColors.textPrimary),
          ),
          content: Text(
            'Area-based happenings need at least 1 snap. '
            'Removing this will block publishing.',
            style: AppTypography.body.copyWith(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(
                'Cancel',
                style: AppTypography.buttonSmall.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(
                'Remove',
                style: AppTypography.buttonSmall.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ).then((confirmed) {
        if (confirmed == true && mounted) {
          context.read<PostHappeningCubit>().removeSnap(index);
        }
      });
    } else {
      context.read<PostHappeningCubit>().removeSnap(index);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    _buildHeading(state),
                    AppSpacing.verticalXl,
                    _buildSnapGrid(state),
                    AppSpacing.verticalLg,
                    _buildSourceButtons(state),
                    AppSpacing.verticalXl,
                    _buildProTip(),
                    AppSpacing.verticalLg,
                    _buildContentGuidelines(),
                    if (state.error != null) ...[
                      AppSpacing.verticalLg,
                      _buildErrorMessage(state.error!),
                    ],
                    AppSpacing.verticalXxl,
                  ],
                ),
              ),
            ),
            _buildBottomBar(context, state),
          ],
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
              'Add Snaps',
              style: AppTypography.h4,
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            'Step 4 of 4',
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
          child: Container(
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildHeading(PostHappeningState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Show what\u2019s happening',
          style: AppTypography.h2,
        ),
        AppSpacing.verticalSm,
        Text(
          'Add photos to give people a real look.',
          style: AppTypography.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        if (state.isAreaBased) ...[
          AppSpacing.verticalMd,
          Container(
            width: double.infinity,
            padding: AppSpacing.cardPaddingCompact,
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.1),
              borderRadius: AppSpacing.cardRadius,
              border: Border.all(
                color: AppColors.warning.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.warning,
                  size: 18,
                ),
                AppSpacing.horizontalSm,
                Expanded(
                  child: Text(
                    'Area-based happenings require at least 1 snap.',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.warning,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }


  Widget _buildSnapGrid(PostHappeningState state) {
    final snapCount = state.snapFiles.length;
    const totalSlots = PostHappeningState.maxSnaps;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 1,
      ),
      itemCount: totalSlots,
      itemBuilder: (context, index) {
        if (index < snapCount) {
          return _FilledSnapSlot(
            file: state.snapFiles[index],
            isCover: index == 0,
            onRemove: () => _removeSnap(index, state),
          );
        }
        return _EmptySnapSlot(
          onTap: state.canAddSnap ? _pickFromGallery : null,
        );
      },
    );
  }


  Widget _buildSourceButtons(PostHappeningState state) {
    final canAdd = state.canAddSnap;
    return Row(
      children: [
        Expanded(
          child: MobOutlinedButton(
            label: '\uD83D\uDCF7 Take Photo',
            onPressed: canAdd ? _pickFromCamera : null,
          ),
        ),
        AppSpacing.horizontalSm,
        Expanded(
          child: MobOutlinedButton(
            label: '\uD83D\uDDBC From Gallery',
            onPressed: canAdd ? _pickFromGallery : null,
          ),
        ),
      ],
    );
  }


  Widget _buildProTip() {
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: AppSpacing.cardRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: AppColors.cyan,
                size: 20,
              ),
              AppSpacing.horizontalSm,
              Text(
                'Tips for great snaps:',
                style: AppTypography.body.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          AppSpacing.verticalSm,
          Text(
            'Show the crowd, the vibe, and the venue. '
            'Blurry or irrelevant snaps may be removed.',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildContentGuidelines() {
    return GestureDetector(
      onTap: _showContentGuidelines,
      child: Row(
        children: [
          const Icon(
            Icons.assignment_outlined,
            color: AppColors.cyan,
            size: 18,
          ),
          AppSpacing.horizontalSm,
          Text(
            'Content Guidelines',
            style: AppTypography.buttonSmall.copyWith(
              color: AppColors.cyan,
            ),
          ),
        ],
      ),
    );
  }

  void _showContentGuidelines() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.bottomSheetRadius,
      ),
      builder: (ctx) {
        return Padding(
          padding: AppSpacing.bottomSheetPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              AppSpacing.verticalLg,
              const Text('Content Guidelines', style: AppTypography.h3),
              AppSpacing.verticalMd,
              _guidelineItem(
                Icons.check_circle_outline,
                'Show real, unfiltered moments from the happening',
              ),
              _guidelineItem(
                Icons.check_circle_outline,
                'Capture the venue, crowd, and atmosphere',
              ),
              _guidelineItem(
                Icons.check_circle_outline,
                'Keep it relevant to the happening',
              ),
              AppSpacing.verticalSm,
              _guidelineItem(
                Icons.cancel_outlined,
                'No explicit, violent, or hateful content',
                isNegative: true,
              ),
              _guidelineItem(
                Icons.cancel_outlined,
                'No spam, ads, or misleading photos',
                isNegative: true,
              ),
              _guidelineItem(
                Icons.cancel_outlined,
                'No personally identifiable info of others',
                isNegative: true,
              ),
              SizedBox(height: MediaQuery.of(ctx).padding.bottom + AppSpacing.base),
            ],
          ),
        );
      },
    );
  }

  Widget _guidelineItem(IconData icon, String text, {bool isNegative = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: isNegative ? AppColors.error : AppColors.success,
            size: 18,
          ),
          AppSpacing.horizontalSm,
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildErrorMessage(String message) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPaddingCompact,
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          AppSpacing.horizontalSm,
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.error,
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MobGradientButton(
            label: 'Review & Publish',
            isLarge: true,
            icon: Icons.rocket_launch,
            onPressed: state.isSubmitting
                ? null
                : () => context.read<PostHappeningCubit>().nextStep(),
          ),
          AppSpacing.verticalSm,
          MobTextButton(
            label: '\u2190 Previous Step',
            onPressed: () {
              context.read<PostHappeningCubit>().previousStep();
            },
          ),
        ],
      ),
    );
  }
}


class _FilledSnapSlot extends StatelessWidget {
  const _FilledSnapSlot({
    required this.file,
    required this.isCover,
    required this.onRemove,
  });

  final File file;
  final bool isCover;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: AppSpacing.cardRadius,
      child: Stack(
        fit: StackFit.expand,
        children: [

          Image.file(
            file,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.elevated,
              child: const Icon(
                Icons.broken_image,
                color: AppColors.textTertiary,
                size: 32,
              ),
            ),
          ),


          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 48,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.5),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),


          if (isCover)
            Positioned(
              top: AppSpacing.sm,
              left: AppSpacing.sm,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cyan,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: Text(
                  'COVER',
                  style: AppTypography.micro.copyWith(
                    color: AppColors.background,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),


          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.sm,
            child: GestureDetector(
              onTap: onRemove,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: AppColors.textPrimary,
                  size: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _EmptySnapSlot extends StatelessWidget {
  const _EmptySnapSlot({this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: onTap != null ? 1.0 : 0.4,
        child: CustomPaint(
          painter: _DashedBorderPainter(
            color: AppColors.textTertiary,
            radius: AppSpacing.radiusLg,
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.surface,
                      width: 1,
                    ),
                  ),
                  child: const Icon(
                    Icons.add,
                    color: AppColors.textTertiary,
                    size: 24,
                  ),
                ),
                AppSpacing.verticalSm,
                Text(
                  'Add Snap',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class _DashedBorderPainter extends CustomPainter {
  _DashedBorderPainter({
    required this.color,
    required this.radius,
  });

  final Color color;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    const dashWidth = 6.0;
    const dashSpace = 4.0;

    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(radius),
    );

    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dashWidth).clamp(0.0, metric.length);
        canvas.drawPath(
          metric.extractPath(distance, end),
          paint,
        );
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter oldDelegate) =>
      color != oldDelegate.color || radius != oldDelegate.radius;
}
