import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../shared/widgets/mob_bottom_sheet.dart';
import '../../../../shared/widgets/mob_text_button.dart';
import '../../../feed/domain/entities/happening.dart';


class ShareSheet extends StatelessWidget {
  const ShareSheet({
    super.key,
    required this.happening,
  });

  final Happening happening;


  static Future<void> show(
    BuildContext context, {
    required Happening happening,
  }) {
    return MobBottomSheet.show(
      context,
      child: ShareSheet(happening: happening),
    );
  }


  String get _shareLink => AppConfig.happeningShareUrl(happening.uuid);


  String get _shareMessage {
    final address = happening.address ?? 'Lagos';
    return '${happening.title} is happening at $address! '
        'Check it out on Mob \uD83D\uDD25\n$_shareLink';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        _buildPreviewCard(),

        const SizedBox(height: AppSpacing.xl),


        Text(
          'Share via',
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),

        const SizedBox(height: AppSpacing.base),


        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _ShareOption(
              label: 'WhatsApp',
              icon: Icons.chat,
              backgroundColor: const Color(0xFF25D366),
              iconColor: AppColors.textPrimary,
              onTap: () => _shareViaWhatsApp(context),
            ),
            _ShareOption(
              label: 'Instagram',
              icon: Icons.camera_alt,
              gradient: const LinearGradient(
                colors: [Color(0xFFA855F7), Color(0xFFF97316)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              iconColor: AppColors.textPrimary,
              onTap: () => _shareViaInstagram(context),
            ),
            _ShareOption(
              label: 'X',
              icon: Icons.alternate_email,
              backgroundColor: const Color(0xFF000000),
              iconColor: AppColors.textPrimary,
              showBorder: true,
              onTap: () => _shareViaX(context),
            ),
            _ShareOption(
              label: 'Copy Link',
              icon: Icons.link,
              backgroundColor: AppColors.elevated,
              iconColor: AppColors.cyan,
              showBorder: true,
              onTap: () => _copyLink(context),
            ),
            _ShareOption(
              label: 'More',
              icon: Icons.more_horiz,
              backgroundColor: AppColors.elevated,
              iconColor: AppColors.textSecondary,
              onTap: () => _shareViaMore(context),
            ),
          ],
        ),

        const SizedBox(height: AppSpacing.lg),


        const Divider(color: AppColors.surface, height: 1),

        const SizedBox(height: AppSpacing.md),


        Center(
          child: MobTextButton(
            label: 'Cancel',
            color: AppColors.textSecondary,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),

        const SizedBox(height: AppSpacing.sm),
      ],
    );
  }


  Widget _buildPreviewCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Row(
        children: [

          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            child: SizedBox(
              width: 56,
              height: 56,
              child: happening.coverImageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: happening.coverImageUrl!,
                      fit: BoxFit.cover,
                      memCacheWidth: 112,
                      memCacheHeight: 112,
                      placeholder: (_, __) => Container(
                        color: AppColors.surface,
                        child: const Icon(
                          Icons.image,
                          color: AppColors.textTertiary,
                          size: 24,
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppColors.surface,
                        child: const Icon(
                          Icons.image,
                          color: AppColors.textTertiary,
                          size: 24,
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.surface,
                      child: Icon(
                        Icons.event,
                        color: AppColors.categoryColor(
                          happening.category.name,
                        ),
                        size: 24,
                      ),
                    ),
            ),
          ),

          const SizedBox(width: AppSpacing.md),


          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [

                Text(
                  happening.title,
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: 2),


                Text(
                  happening.address ?? 'Lagos, Nigeria',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const SizedBox(height: AppSpacing.xs),


                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.categoryColor(
                      happening.category.name,
                    ).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    happening.category.displayName,
                    style: AppTypography.micro.copyWith(
                      color: AppColors.categoryColor(
                        happening.category.name,
                      ),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Future<void> _shareViaWhatsApp(BuildContext context) async {
    Navigator.of(context).pop();
    final encoded = Uri.encodeComponent(_shareMessage);
    final uri = Uri.parse('whatsapp://send?text=$encoded');

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {

      final webUri = Uri.parse(
        'https://wa.me/?text=$encoded',
      );
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _shareViaInstagram(BuildContext context) async {
    Navigator.of(context).pop();


    await Share.share(_shareMessage);
  }

  Future<void> _shareViaX(BuildContext context) async {
    Navigator.of(context).pop();
    final encoded = Uri.encodeComponent(_shareMessage);
    final uri = Uri.parse(
      'https://twitter.com/intent/tweet?text=$encoded',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _copyLink(BuildContext context) async {
    await Clipboard.setData(ClipboardData(text: _shareLink));
    if (!context.mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Link copied!'),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _shareViaMore(BuildContext context) async {
    Navigator.of(context).pop();
    await Share.share(_shareMessage);
  }
}


class _ShareOption extends StatefulWidget {
  const _ShareOption({
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.onTap,
    this.backgroundColor,
    this.gradient,
    this.showBorder = false,
  });

  final String label;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final LinearGradient? gradient;
  final bool showBorder;

  @override
  State<_ShareOption> createState() => _ShareOptionState();
}

class _ShareOptionState extends State<_ShareOption> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.9 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: SizedBox(
          width: 60,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.gradient == null
                      ? widget.backgroundColor
                      : null,
                  gradient: widget.gradient,
                  border: widget.showBorder
                      ? Border.all(
                          color: AppColors.surface,
                          width: 1,
                        )
                      : null,
                ),
                child: Icon(
                  widget.icon,
                  color: widget.iconColor,
                  size: 24,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),


              Text(
                widget.label,
                style: AppTypography.micro.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
