import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';
import '../../core/constants/app_typography.dart';


class MobAvatar extends StatelessWidget {
  const MobAvatar({
    super.key,
    this.imageUrl,
    this.size = AppSpacing.avatarMd,
    this.showBorder = false,
    this.showVerifiedBadge = false,
    this.initials,
    this.onTap,
  });


  final String? imageUrl;


  final double size;


  final bool showBorder;


  final bool showVerifiedBadge;


  final String? initials;


  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final badgeSize = size * 0.3;

    Widget avatar = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(color: AppColors.cyan, width: 3)
            : null,
      ),
      child: ClipOval(
        child: _buildImage(),
      ),
    );


    if (showVerifiedBadge) {
      avatar = Stack(
        clipBehavior: Clip.none,
        children: [
          avatar,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: badgeSize,
              height: badgeSize,
              decoration: const BoxDecoration(
                color: AppColors.success,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: AppColors.textPrimary,
                size: badgeSize * 0.6,
              ),
            ),
          ),
        ],
      );
    }

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: avatar);
    }

    return avatar;
  }

  Widget _buildImage() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {

      final cacheSize = (size * 2).toInt();
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        width: size,
        height: size,
        memCacheWidth: cacheSize,
        memCacheHeight: cacheSize,
        fit: BoxFit.cover,
        placeholder: (_, __) => _buildFallback(),
        errorWidget: (_, __, ___) => _buildFallback(),
      );
    }
    return _buildFallback();
  }

  Widget _buildFallback() {
    return Container(
      width: size,
      height: size,
      color: AppColors.elevated,
      alignment: Alignment.center,
      child: Text(
        (initials ?? '?').substring(0, (initials ?? '?').length.clamp(0, 2)),
        style: AppTypography.buttonSmall.copyWith(
          color: AppColors.textPrimary,
          fontSize: size * 0.35,
        ),
      ),
    );
  }
}
