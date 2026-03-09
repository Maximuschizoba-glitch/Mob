import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import 'mob_gradient_button.dart';
import 'mob_outlined_button.dart';


class MobEmptyState extends StatelessWidget {
  const MobEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.primaryLabel,
    this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });


  final IconData icon;


  final String title;


  final String body;


  final String? primaryLabel;


  final VoidCallback? onPrimary;


  final String? secondaryLabel;


  final VoidCallback? onSecondary;

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
              decoration: const BoxDecoration(
                color: AppColors.elevated,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 40,
                color: AppColors.textTertiary,
              ),
            ),

            AppSpacing.verticalBase,


            Text(
              title,
              style: AppTypography.h4,
              textAlign: TextAlign.center,
            ),

            AppSpacing.verticalSm,


            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: Text(
                body,
                style: AppTypography.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),


            if (primaryLabel != null && onPrimary != null) ...[
              AppSpacing.verticalXl,
              SizedBox(
                width: 220,
                child: MobGradientButton(
                  label: primaryLabel!,
                  onPressed: onPrimary,
                ),
              ),
            ],


            if (secondaryLabel != null && onSecondary != null) ...[
              AppSpacing.verticalMd,
              SizedBox(
                width: 220,
                child: MobOutlinedButton(
                  label: secondaryLabel!,
                  onPressed: onSecondary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
