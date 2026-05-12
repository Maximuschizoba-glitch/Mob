import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';
import '../../core/theme/theme_cubit.dart';

/// Discord-style accent color picker.
///
/// Drop this anywhere in your Settings screen:
/// ```dart
/// const AccentPalettePicker()
/// ```
class AccentPalettePicker extends StatelessWidget {
  const AccentPalettePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Accent Color', style: AppTypography.h4),
            AppSpacing.verticalSm,
            Text(
              'Choose a color that flows through the whole app.',
              style: AppTypography.bodySmall,
            ),
            AppSpacing.verticalBase,
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final color in AppColors.accentPresets)
                  // ignore: prefer_const_constructors
                  _AccentSwatch(
                    color: color,
                    isSelected: state.accentColor.toARGB32() == color.toARGB32(),
                    onTap: () =>
                        context.read<ThemeCubit>().setAccentColor(color),
                  ),
              ],
            ),
            AppSpacing.verticalMd,
            // Reset to default
            if (state.accentColor.toARGB32() != AppColors.primary.toARGB32())
              TextButton(
                onPressed: () => context.read<ThemeCubit>().resetAccent(),
                child: const Text('Reset to default'),
              ),
          ],
        );
      },
    );
  }
}

class _AccentSwatch extends StatelessWidget {
  const _AccentSwatch({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
            width: 2.5,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.55),
                    blurRadius: 12,
                    spreadRadius: 2,
                  )
                ]
              : null,
        ),
        child: isSelected
            ? const Icon(Icons.check_rounded, color: Colors.white, size: 20)
            : null,
      ),
    );
  }
}
