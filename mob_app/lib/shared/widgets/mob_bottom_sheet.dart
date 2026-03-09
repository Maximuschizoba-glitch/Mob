import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';


class MobBottomSheet {
  MobBottomSheet._();


  static Future<T?> show<T>(
    BuildContext context, {
    required Widget child,
    double? maxHeight,
    bool enableDrag = true,
    bool showDragHandle = true,
    bool isScrollControlled = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      enableDrag: enableDrag,
      backgroundColor: AppColors.card,
      barrierColor: Colors.black54,
      shape: const RoundedRectangleBorder(
        borderRadius: AppSpacing.bottomSheetRadius,
      ),
      builder: (context) {
        Widget content = Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            if (showDragHandle) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.base),
            ],


            Flexible(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                child: child,
              ),
            ),


            SizedBox(height: MediaQuery.of(context).padding.bottom + AppSpacing.base),
          ],
        );


        if (maxHeight != null) {
          content = ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * maxHeight,
            ),
            child: content,
          );
        }

        return content;
      },
    );
  }


  static Future<T?> showWithTitle<T>(
    BuildContext context, {
    required String title,
    required Widget child,
    double? maxHeight,
    VoidCallback? onClose,
  }) {
    return show<T>(
      context,
      maxHeight: maxHeight,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (onClose != null)
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(
                    Icons.close,
                    color: AppColors.textSecondary,
                    size: 24,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.base),
          Flexible(child: child),
        ],
      ),
    );
  }
}
