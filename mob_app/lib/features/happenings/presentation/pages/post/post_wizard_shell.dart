import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../bloc/post_happening_cubit.dart';
import '../../bloc/post_happening_state.dart';
import 'add_details_page.dart';
import 'add_location_page.dart';
import 'add_snaps_page.dart';
import 'choose_type_page.dart';
import 'review_publish_page.dart';


class PostWizardShell extends StatelessWidget {
  const PostWizardShell({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostHappeningCubit, PostHappeningState>(
      buildWhen: (previous, current) =>
          previous.currentStep != current.currentStep,
      builder: (context, state) {
        return PopScope(

          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            _handleBack(context, state.currentStep);
          },
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                transitionBuilder: (child, animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _buildStepPage(state.currentStep),
              ),
            ),
          ),
        );
      },
    );
  }


  void _handleBack(BuildContext context, int currentStep) {
    if (currentStep == 0) {
      _showDiscardDialog(context);
    } else {
      context.read<PostHappeningCubit>().previousStep();
    }
  }


  Future<void> _showDiscardDialog(BuildContext context) async {
    final shouldDiscard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: const Text(
          'Discard post?',
          style: AppTypography.h3,
        ),
        content: Text(
          'Your progress will be lost if you leave now.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Keep Editing',
              style: AppTypography.button.copyWith(
                color: AppColors.cyan,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Discard',
              style: AppTypography.button.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );

    if (shouldDiscard == true && context.mounted) {
      context.pop();
    }
  }

  Widget _buildStepPage(int step) {
    switch (step) {
      case 0:
        return const ChooseTypePage(key: ValueKey(0));
      case 1:
        return const AddDetailsPage(key: ValueKey(1));
      case 2:
        return const AddLocationPage(key: ValueKey(2));
      case 3:
        return const AddSnapsPage(key: ValueKey(3));
      case 4:
        return const ReviewPublishPage(key: ValueKey(4));
      default:
        return const ChooseTypePage(key: ValueKey(0));
    }
  }
}
