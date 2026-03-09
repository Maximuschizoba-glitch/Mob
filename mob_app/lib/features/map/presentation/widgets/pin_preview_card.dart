import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/activity_level_indicator.dart';
import '../../../../shared/widgets/happening_countdown.dart';
import '../../../../shared/widgets/mob_badge.dart';
import '../../../../shared/widgets/vibe_score_widget.dart';
import '../../../feed/domain/entities/happening.dart';


class PinPreviewCard extends StatelessWidget {
  const PinPreviewCard({
    super.key,
    required this.happening,
    required this.onViewDetails,
    required this.onClose,
  });


  final Happening happening;


  final VoidCallback onViewDetails;


  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onViewDetails,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.base),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(100),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 8),
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  _buildThumbnail(),

                  const SizedBox(width: 12),


                  Expanded(child: _buildContent()),


                  GestureDetector(
                    onTap: onClose,
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(
                        Icons.close,
                        color: AppColors.textTertiary,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),


            _buildViewDetailsBar(),
          ],
        ),
      ),
    );
  }


  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 80,
        height: 80,
        child: happening.coverImageUrl != null
            ? CachedNetworkImage(
                imageUrl: happening.coverImageUrl!,
                fit: BoxFit.cover,
                memCacheWidth: 160,
                memCacheHeight: 160,
                placeholder: (_, __) => Container(
                  color: AppColors.elevated,
                  child: const Center(
                    child: Icon(
                      Icons.image_outlined,
                      color: AppColors.textTertiary,
                      size: 24,
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => _thumbnailPlaceholder(),
              )
            : _thumbnailPlaceholder(),
      ),
    );
  }

  Widget _thumbnailPlaceholder() {
    return Container(
      color: AppColors.elevated,
      child: Center(
        child: Text(
          happening.category.emoji,
          style: const TextStyle(fontSize: 28),
        ),
      ),
    );
  }


  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [

        Row(
          children: [
            MobBadge(
              label: happening.category.displayName,
              color: happening.category.color,
            ),
            const Spacer(),
            HappeningCountdown(happening: happening),
          ],
        ),

        const SizedBox(height: 6),


        Text(
          happening.title,
          style: AppTypography.h3.copyWith(fontSize: 16),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4),


        if (happening.address != null)
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: AppColors.textTertiary,
                size: 14,
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

        const SizedBox(height: 8),


        Row(
          children: [
            VibeScoreWidget(score: happening.vibeScore),
            const SizedBox(width: 8),
            ActivityLevelIndicator(
              level: happening.activityLevel.value,
              showLabel: true,
            ),
            const Spacer(),
            _buildPrice(),
          ],
        ),
      ],
    );
  }

  Widget _buildPrice() {
    if (!happening.isTicketed) {
      return Text(
        'Free',
        style: AppTypography.caption.copyWith(
          color: AppColors.success,
          fontWeight: FontWeight.w600,
        ),
      );
    }


    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          happening.formattedPrice,
          style: AppTypography.body.copyWith(
            color: AppColors.cyan,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Get Ticket',
          style: AppTypography.micro.copyWith(
            color: AppColors.cyan,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }


  Widget _buildViewDetailsBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: AppColors.surface, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'View Details',
            style: AppTypography.caption.copyWith(
              color: AppColors.cyan,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 4),
          const Icon(
            Icons.arrow_forward_ios,
            color: AppColors.cyan,
            size: 12,
          ),
        ],
      ),
    );
  }
}
