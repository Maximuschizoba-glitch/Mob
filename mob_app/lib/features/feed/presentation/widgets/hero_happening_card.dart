import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../core/utils/happening_helpers.dart';
import '../../../../shared/widgets/activity_level_indicator.dart';
import '../../../../shared/widgets/happening_countdown.dart';
import '../../../../shared/widgets/mob_badge.dart';
import '../../../../shared/widgets/vibe_score_widget.dart';
import '../../domain/entities/happening.dart';


class HeroHappeningCard extends StatelessWidget {
  const HeroHappeningCard({
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
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          color: AppColors.card,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [

            _buildBackgroundImage(),


            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    AppColors.background.withValues(alpha: 0.7),
                    AppColors.background.withValues(alpha: 0.95),
                  ],
                  stops: const [0.0, 0.3, 0.65, 1.0],
                ),
              ),
            ),


            Positioned(
              top: AppSpacing.md,
              left: AppSpacing.md,
              right: AppSpacing.md,
              child: Row(
                children: [

                  Builder(builder: (_) {
                    final displayStatus = getDisplayStatus(happening);
                    final badge = getBadgeConfig(displayStatus);
                    if (displayStatus == HappeningDisplayStatus.live) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: _buildLiveBadge(),
                      );
                    }
                    if (displayStatus == HappeningDisplayStatus.upcoming) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 6),
                        child: MobBadge(label: badge.label, color: badge.color),
                      );
                    }
                    return const SizedBox.shrink();
                  }),


                  MobBadge(
                    label: '${happening.category.emoji} ${happening.category.displayName}',
                    color: happening.category.color,
                  ),

                  const Spacer(),


                  VibeScoreWidget(score: happening.vibeScore),
                ],
              ),
            ),


            Positioned(
              bottom: AppSpacing.md,
              left: AppSpacing.md,
              right: AppSpacing.md,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          happening.title,
                          style: AppTypography.h3,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (happening.address != null) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 12,
                                color: AppColors.textSecondary,
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
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(width: AppSpacing.md),


                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ActivityLevelIndicator(
                        level: happening.activityLevel.value,
                        showLabel: true,
                      ),
                      const SizedBox(height: 4),
                      HappeningCountdown(happening: happening),
                      if (happening.isTicketed) ...[
                        const SizedBox(height: 2),
                        Text(
                          happening.formattedPrice,
                          style: AppTypography.buttonSmall.copyWith(
                            color: AppColors.cyan,
                            fontSize: 12,
                          ),
                        ),
                      ] else if (happening.snapsCount > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          '\u{1F4F8} ${happening.snapsCount}',
                          style: AppTypography.micro.copyWith(
                            color: AppColors.cyan,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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


  Widget _buildBackgroundImage() {
    if (happening.coverImageUrl != null &&
        happening.coverImageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: happening.coverImageUrl!,
        fit: BoxFit.cover,
        memCacheHeight: 400,
        placeholder: (_, __) => Container(color: AppColors.elevated),
        errorWidget: (_, __, ___) => _buildPlaceholderBg(),
      );
    }
    return _buildPlaceholderBg();
  }

  Widget _buildPlaceholderBg() {
    return Container(
      color: AppColors.elevated,
      alignment: Alignment.center,
      child: Text(
        happening.category.emoji,
        style: const TextStyle(fontSize: 48),
      ),
    );
  }


  Widget _buildLiveBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.magenta.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.magenta,
              boxShadow: [
                BoxShadow(
                  color: AppColors.magenta.withValues(alpha: 0.6),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          Text(
            'LIVE',
            style: AppTypography.micro.copyWith(
              color: AppColors.magenta,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
