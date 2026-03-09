import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../shared/widgets/activity_level_indicator.dart';
import '../../../../shared/widgets/happening_countdown.dart';
import '../../../../shared/widgets/mob_badge.dart';
import '../../../../shared/widgets/vibe_score_widget.dart';
import '../../domain/entities/happening.dart';


class HappeningListCard extends StatelessWidget {
  const HappeningListCard({
    super.key,
    required this.happening,
  });

  final Happening happening;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        RoutePaths.happeningDetailPath(happening.uuid),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border, width: 0.5),
        ),
        child: Row(
          children: [

            _buildThumbnail(),

            const SizedBox(width: AppSpacing.md),


            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [

                  Row(
                    children: [
                      MobBadge(
                        label: '${happening.category.emoji} ${happening.category.displayName}',
                        color: happening.category.color,
                      ),
                      const Spacer(),
                      HappeningCountdown(happening: happening),
                    ],
                  ),

                  const SizedBox(height: 4),


                  Text(
                    happening.title,
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),


                  if (happening.address != null)
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          size: 12,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            happening.address!,
                            style: AppTypography.caption,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 6),


                  Row(
                    children: [
                      VibeScoreWidget(score: happening.vibeScore),
                      const SizedBox(width: 8),
                      ActivityLevelIndicator(
                        level: happening.activityLevel.value,
                      ),
                      const Spacer(),
                      _buildTrailingMeta(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: SizedBox(
        width: 80,
        height: 80,
        child: happening.coverImageUrl != null &&
                happening.coverImageUrl!.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: happening.coverImageUrl!,
                fit: BoxFit.cover,
                memCacheWidth: 160,
                memCacheHeight: 160,
                placeholder: (_, __) =>
                    Container(color: AppColors.elevated),
                errorWidget: (_, __, ___) => _buildThumbnailPlaceholder(),
              )
            : _buildThumbnailPlaceholder(),
      ),
    );
  }

  Widget _buildThumbnailPlaceholder() {
    return Container(
      color: AppColors.elevated,
      alignment: Alignment.center,
      child: Text(
        happening.category.emoji,
        style: const TextStyle(fontSize: 24),
      ),
    );
  }


  Widget _buildTrailingMeta() {
    if (happening.isTicketed) {
      return Text(
        happening.formattedPrice,
        style: AppTypography.caption.copyWith(
          color: AppColors.cyan,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    if (happening.snapsCount > 0) {
      return Text(
        '\u{1F4F8} ${happening.snapsCount}',
        style: AppTypography.caption.copyWith(
          color: AppColors.cyan,
          fontWeight: FontWeight.w600,
        ),
      );
    }

    return const SizedBox.shrink();
  }
}
