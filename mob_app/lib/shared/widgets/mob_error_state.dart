import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import 'mob_gradient_button.dart';


class MobErrorState extends StatelessWidget {
  const MobErrorState({
    super.key,
    required this.message,
    this.onRetry,
    this.title,
    this.icon,
  });


  final String message;


  final VoidCallback? onRetry;


  final String? title;


  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                icon ?? Icons.error_outline_rounded,
                size: 40,
                color: AppColors.error,
              ),
            ),

            AppSpacing.verticalBase,


            Text(
              title ?? 'Something went wrong',
              style: AppTypography.h4,
              textAlign: TextAlign.center,
            ),

            AppSpacing.verticalSm,


            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                message,
                style: AppTypography.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),


            if (onRetry != null) ...[
              AppSpacing.verticalXl,
              SizedBox(
                width: 200,
                child: MobGradientButton(
                  label: 'Try Again',
                  onPressed: onRetry,
                  icon: Icons.refresh_rounded,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
