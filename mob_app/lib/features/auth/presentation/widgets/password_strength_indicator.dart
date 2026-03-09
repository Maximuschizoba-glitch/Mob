import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';


class PasswordStrengthIndicator extends StatelessWidget {
  const PasswordStrengthIndicator({
    super.key,
    required this.password,
  });


  final String password;


  int get _score {
    if (password.isEmpty) return 0;

    int score = 0;
    if (password.length >= 8) score++;
    if (password.contains(RegExp(r'[A-Z]'))) score++;
    if (password.contains(RegExp(r'[0-9]'))) score++;
    if (password.contains(RegExp(r'[!@#\$%\^&\*\(\)_\+\-=\[\]\{\};:,.<>?/\\|`~]'))) {
      score++;
    }
    return score;
  }


  Color get _color {
    switch (_score) {
      case 1:
        return AppColors.error;
      case 2:
        return AppColors.warning;
      case 3:
        return AppColors.cyan;
      case 4:
        return AppColors.success;
      default:
        return AppColors.surface;
    }
  }

  @override
  Widget build(BuildContext context) {
    final score = _score;
    final color = _color;

    return Row(
      children: List.generate(4, (index) {
        final isActive = index < score;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            height: 3,
            margin: EdgeInsets.only(
              right: index < 3 ? AppSpacing.xs : 0,
            ),
            decoration: BoxDecoration(
              color: isActive ? color : AppColors.surface,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
          ),
        );
      }),
    );
  }
}
