import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../core/utils/auth_guard.dart';
import '../../../../core/utils/happening_helpers.dart';
import '../../../../core/utils/navigation_helpers.dart';
import '../../../../shared/models/enums.dart';
import '../../../../shared/widgets/happening_countdown.dart';
import '../../../../shared/widgets/snap_ring_avatar.dart';
import '../../../../shared/widgets/mob_badge.dart';
import '../../../../shared/widgets/mob_card.dart';
import '../../../../shared/widgets/mob_error_state.dart';
import '../../../../shared/widgets/mob_gradient_button.dart';
import '../../../../shared/widgets/mob_outlined_button.dart';
import '../../../../shared/widgets/mob_section_label.dart';
import '../../../../shared/widgets/vibe_score_widget.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../feed/domain/entities/happening.dart';
import '../../../snaps/domain/entities/snap.dart';
import '../../../ticketing/presentation/pages/ticket_purchase_page.dart';
import '../../domain/repositories/report_repository.dart';
import '../bloc/happening_detail_cubit.dart';
import '../bloc/happening_detail_state.dart';
import '../widgets/report_sheet.dart';
import '../widgets/share_sheet.dart';
import 'edit_happening_screen.dart';


class HappeningDetailScreen extends StatelessWidget {
  const HappeningDetailScreen({
    super.key,
    required this.uuid,
  });

  final String uuid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocBuilder<HappeningDetailCubit, HappeningDetailState>(
        builder: (context, state) {
          if (state is HappeningDetailLoading) {
            return const _DetailShimmer();
          }

          if (state is HappeningDetailError) {
            final isNotFound =
                state.message.toLowerCase().contains('not found');

            if (isNotFound) {
              return _NotFoundError(
                onBrowseFeed: () => context.go(RoutePaths.feed),
              );
            }

            return MobErrorState(
              message: state.message,
              onRetry: () =>
                  context.read<HappeningDetailCubit>().loadDetail(),
            );
          }

          if (state is HappeningDetailLoaded) {
            return _DetailContent(
              happening: state.happening,
              snaps: state.snaps,
              isSnapsLoading: state.isSnapsLoading,
            );
          }


          return const _DetailShimmer();
        },
      ),
    );
  }
}


class _DetailContent extends StatefulWidget {
  const _DetailContent({
    required this.happening,
    required this.snaps,
    required this.isSnapsLoading,
  });

  final Happening happening;
  final List<Snap> snaps;
  final bool isSnapsLoading;

  @override
  State<_DetailContent> createState() => _DetailContentState();
}

class _DetailContentState extends State<_DetailContent> {
  bool _isDescriptionExpanded = false;
  bool _isViewingAsHost = true;

  Happening get h => widget.happening;


  bool get _isHost {
    final currentUser = context.read<AuthCubit>().currentUser;
    return currentUser != null &&
        h.hostUuid != null &&
        currentUser.uuid == h.hostUuid;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _buildHeroImage(context),


          _buildTitleAndHost(),


          if (_isHost) _buildHostBanner(),


          _buildQuickInfoCards(),


          _buildInfoRows(context),


          if (_isHost && _isViewingAsHost)
            _buildHostSection(context)
          else if (h.isTicketed)
            _buildTicketSection(context),


          if (_isHost && !_isViewingAsHost && h.isTicketed)
            _buildSwitchToHostView(),


          if (h.description != null && h.description!.isNotEmpty)
            _buildDescription(),


          _buildMapPreview(context),


          _buildSnapsSection(context),


          _buildReportLink(context),


          SizedBox(
            height: MediaQuery.of(context).padding.bottom + AppSpacing.xxxl,
          ),
        ],
      ),
    );
  }


  Widget _buildHeroImage(BuildContext context) {
    return SizedBox(
      height: 280,
      child: Stack(
        fit: StackFit.expand,
        children: [

          if (h.coverImageUrl != null && h.coverImageUrl!.isNotEmpty)
            CachedNetworkImage(
              imageUrl: h.coverImageUrl!,
              fit: BoxFit.cover,
              memCacheHeight: 560,
              placeholder: (_, __) => Container(color: AppColors.elevated),
              errorWidget: (_, __, ___) => _buildImageFallback(),
            )
          else
            _buildImageFallback(),


          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    AppColors.background.withValues(alpha: 0.7),
                    AppColors.background,
                  ],
                  stops: const [0.0, 0.4, 0.75, 1.0],
                ),
              ),
            ),
          ),


          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.sm,
            left: AppSpacing.base,
            child: _CircleIconButton(
              icon: Icons.arrow_back,
              onTap: () => context.safePop(),
            ),
          ),


          Positioned(
            top: MediaQuery.of(context).padding.top + AppSpacing.sm,
            right: AppSpacing.base,
            child: Row(
              children: [
                _CircleIconButton(
                  icon: Icons.share_outlined,
                  onTap: () {
                    ShareSheet.show(context, happening: h);
                  },
                ),
                const SizedBox(width: AppSpacing.sm),
                _CircleIconButton(
                  icon: Icons.more_horiz,
                  onTap: () => _showOptionsSheet(context),
                ),
              ],
            ),
          ),


          Positioned(
            bottom: AppSpacing.base,
            left: AppSpacing.lg,
            child: Row(
              children: [
                Builder(builder: (_) {
                  final displayStatus = getDisplayStatus(h);
                  final badge = getBadgeConfig(displayStatus);
                  if (displayStatus == HappeningDisplayStatus.live ||
                      displayStatus == HappeningDisplayStatus.upcoming ||
                      displayStatus == HappeningDisplayStatus.ended) {
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.sm),
                      child: MobBadge(
                        label: badge.label,
                        color: badge.color,
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                }),
                MobBadge(
                  label: '${h.category.emoji} ${h.category.displayName}',
                  color: h.category.color,
                ),
              ],
            ),
          ),


          Positioned(
            bottom: AppSpacing.base,
            right: AppSpacing.lg,
            child: VibeScoreWidget(
              score: h.vibeScore,
              large: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageFallback() {
    return Container(
      color: AppColors.elevated,
      alignment: Alignment.center,
      child: Text(
        h.category.emoji,
        style: const TextStyle(fontSize: 64),
      ),
    );
  }


  Widget _buildTitleAndHost() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Text(
            h.title,
            style: AppTypography.h2,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: AppSpacing.md),


          Row(
            children: [
              SnapRingAvatar(
                imageUrl: h.hostAvatarUrl,
                fallbackInitial: h.hostName?.isNotEmpty == true
                    ? h.hostName!.substring(0, 1).toUpperCase()
                    : '?',
                size: 52,
                snapCount: h.snapsCount,
                hasUnviewedSnaps: true,
                isVerifiedHost: h.hostIsVerified,
                onTap: () {
                  if (h.snapsCount > 0) {
                    context.push(RoutePaths.snapViewerPath(h.uuid));
                  }
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      h.hostName ?? 'Anonymous',
                      style: AppTypography.buttonSmall,
                    ),
                    const SizedBox(height: 2),
                    if (h.hostIsVerified)
                      Row(
                        children: [
                          const Icon(
                            Icons.verified,
                            size: 12,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'VERIFIED HOST',
                            style: AppTypography.overline.copyWith(
                              color: AppColors.success,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        'COMMUNITY HOST',
                        style: AppTypography.overline.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    if (h.snapsCount > 0) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Tap to view snaps',
                        style: AppTypography.micro.copyWith(
                          color: AppColors.cyan.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.base),
        ],
      ),
    );
  }


  Widget _buildQuickInfoCards() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          Row(
            children: [

              Expanded(
                child: MobCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MobSectionLabel(label: 'Crowd Level'),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: h.activityLevel.color,
                              shape: BoxShape.circle,
                              boxShadow: h.activityLevel ==
                                      ActivityLevel.high
                                  ? [
                                      BoxShadow(
                                        color: h.activityLevel.color
                                            .withValues(alpha: 0.6),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _activityLabel(h.activityLevel),
                            style: AppTypography.buttonSmall.copyWith(
                              color: h.activityLevel.color,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      _buildActivityBar(),
                    ],
                  ),
                ),
              ),

              const SizedBox(width: AppSpacing.sm),


              Expanded(
                child: MobCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const MobSectionLabel(label: 'Vibe Score'),
                      const SizedBox(height: 6),
                      VibeScoreWidget(
                        score: h.vibeScore,
                        large: true,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Based on ${h.snapsCount} snap${h.snapsCount == 1 ? '' : 's'}',
                        style: AppTypography.overline.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.base),
        ],
      ),
    );
  }

  Widget _buildActivityBar() {
    final level = h.activityLevel;
    final segments = level == ActivityLevel.high
        ? 3
        : level == ActivityLevel.medium
            ? 2
            : 1;

    return Row(
      children: List.generate(3, (i) {
        final isFilled = i < segments;
        return Expanded(
          child: Container(
            height: 4,
            margin: EdgeInsets.only(right: i < 2 ? 4 : 0),
            decoration: BoxDecoration(
              color: isFilled
                  ? level.color
                  : AppColors.elevated,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }

  String _activityLabel(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.high:
        return 'Hot';
      case ActivityLevel.medium:
        return 'Active';
      case ActivityLevel.low:
        return 'Chill';
    }
  }


  Widget _buildInfoRows(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [

          _buildInfoRow(
            icon: Icons.calendar_today_outlined,
            iconColor: AppColors.cyan,
            label: 'Date & Time',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Text(
                  _formatDateTime(),
                  style: AppTypography.body,
                ),

                if (h.isLive) ...[
                  const SizedBox(height: 4),
                  const MobBadge(
                    label: 'HAPPENING NOW',
                    color: AppColors.magenta,
                  ),
                ],

                if (h.isUpcoming) ...[
                  const SizedBox(height: 4),
                  const MobBadge(
                    label: 'UPCOMING',
                    color: AppColors.cyan,
                  ),
                ],
              ],
            ),
          ),

          _infoDivider(),


          _buildInfoRow(
            icon: Icons.location_on_outlined,
            iconColor: AppColors.cyan,
            label: 'Location',
            value: h.address ?? 'Location not specified',
            trailing: GestureDetector(
              onTap: () => _openDirections(),
              child: Text(
                'Directions',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.cyan,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          _infoDivider(),


          _buildInfoRow(
            icon: Icons.timer_outlined,
            iconColor: h.isUpcoming ? AppColors.cyan : AppColors.warning,
            label: h.isUpcoming ? 'Starts' : 'Expires',
            child: HappeningCountdown(happening: h),
          ),

          const SizedBox(height: AppSpacing.base),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    String? value,
    Widget? child,
    Widget? trailing,
    Widget? badge,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: iconColor),
          ),

          const SizedBox(width: AppSpacing.md),


          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTypography.overline.copyWith(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                if (badge != null)
                  badge
                else if (child != null)
                  child
                else
                  Text(
                    value ?? '',
                    style: AppTypography.body,
                  ),
              ],
            ),
          ),

          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _infoDivider() {
    return Container(
      height: 1,
      color: AppColors.border,
    );
  }

  String _formatDateTime() {
    if (h.startsAt == null) return 'Not specified';


    final dt = h.startsAt!.toLocal();
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];

    final weekday = weekdays[dt.weekday - 1];
    final month = months[dt.month - 1];
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    final minute = dt.minute.toString().padLeft(2, '0');

    return '$weekday, $month ${dt.day} \u00B7 $hour:$minute $amPm';
  }

  Future<void> _openDirections() async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${h.latitude},${h.longitude}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }


  Widget _buildTicketSection(BuildContext context) {
    final displayStatus = getDisplayStatus(h);
    final isEnded = displayStatus == HappeningDisplayStatus.ended ||
        displayStatus == HappeningDisplayStatus.expired;

    final isSoldOut = h.ticketQuantity != null &&
        h.ticketsSold >= h.ticketQuantity!;
    final remaining = h.ticketsRemaining ?? 0;
    final total = h.ticketQuantity ?? 0;
    final progress = total > 0 ? h.ticketsSold / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          MobCard(
            borderColor: isEnded
                ? AppColors.textTertiary.withValues(alpha: 0.2)
                : AppColors.cyan.withValues(alpha: 0.2),
            padding: const EdgeInsets.all(AppSpacing.base),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const MobSectionLabel(label: 'Tickets'),
                const SizedBox(height: AppSpacing.sm),


                Row(
                  children: [
                    Text(
                      h.formattedPrice,
                      style: AppTypography.price.copyWith(
                        color: isEnded
                            ? AppColors.textTertiary
                            : AppColors.cyan,
                      ),
                    ),
                    Text(
                      '/person',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    if (total > 0)
                      Text(
                        isEnded
                            ? '${h.ticketsSold} of $total sold'
                            : '$remaining of $total left',
                        style: AppTypography.bodySmall,
                      ),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm),


                if (total > 0)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      minHeight: 4,
                      backgroundColor: AppColors.elevated,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isEnded ? AppColors.textTertiary : AppColors.cyan,
                      ),
                    ),
                  ),

                const SizedBox(height: AppSpacing.base),


                if (isEnded)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.md,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.elevated,
                      borderRadius:
                          BorderRadius.circular(AppSpacing.radiusMd),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.event_busy_rounded,
                          size: 18,
                          color: AppColors.textTertiary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'This event has ended',
                          style: AppTypography.body.copyWith(
                            color: AppColors.textTertiary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  MobGradientButton(
                    label:
                        isSoldOut ? 'SOLD OUT' : 'GET TICKETS \uD83C\uDFAB',
                    isLarge: true,
                    onPressed: isSoldOut
                        ? null
                        : () => _handleTicketTap(context),
                  ),

                const SizedBox(height: AppSpacing.sm),


                if (!isEnded)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        size: 14,
                        color: AppColors.success,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Escrow protected \u2014 full refund if cancelled',
                        style: AppTypography.overline.copyWith(
                          color: AppColors.success,
                          fontSize: 11,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.base),
        ],
      ),
    );
  }

  void _handleTicketTap(BuildContext context) {
    if (!requireAuth(context, action: 'buy tickets and access escrow protection')) {
      return;
    }

    final ticketDisplayStatus = getDisplayStatus(h);
    if (h.status != HappeningStatus.active ||
        ticketDisplayStatus == HappeningDisplayStatus.ended ||
        ticketDisplayStatus == HappeningDisplayStatus.expired) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ticketDisplayStatus == HappeningDisplayStatus.ended
                ? 'This event has ended. Tickets are no longer available.'
                : 'This event has expired. Tickets are no longer available.',
          ),
        ),
      );
      return;
    }
    context.push(
      RoutePaths.ticketPurchasePath(h.uuid),
      extra: TicketPurchaseArgs(
        happeningUuid: h.uuid,
        title: h.title,
        coverImageUrl: h.coverImageUrl,
        address: h.address,
        startsAt: h.startsAt,
        ticketPrice: h.ticketPrice ?? 0,
        ticketQuantity: h.ticketQuantity ?? 0,
        ticketsSold: h.ticketsSold,
      ),
    );
  }


  Widget _buildHostBanner() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.base,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.cyan.withValues(alpha: 0.1),
                  AppColors.purple.withValues(alpha: 0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: AppColors.cyan.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                const Text('\uD83D\uDC51', style: TextStyle(fontSize: 18)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'You\'re hosting this event',
                    style: AppTypography.buttonSmall.copyWith(
                      color: AppColors.cyan,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.base),
        ],
      ),
    );
  }


  Widget _buildHostSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          if (h.isTicketed) ...[
            MobCard(
              borderColor: AppColors.cyan.withValues(alpha: 0.2),
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MobSectionLabel(label: 'Ticket Sales'),
                  const SizedBox(height: AppSpacing.sm),


                  Row(
                    children: [
                      Text(
                        '${h.ticketsSold}',
                        style: AppTypography.h2.copyWith(
                          color: AppColors.cyan,
                        ),
                      ),
                      Text(
                        ' / ${h.ticketQuantity ?? '\u221E'}',
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'tickets sold',
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),


                  if (h.ticketQuantity != null && h.ticketQuantity! > 0) ...[
                    const SizedBox(height: AppSpacing.sm),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(2),
                      child: LinearProgressIndicator(
                        value:
                            (h.ticketsSold / h.ticketQuantity!).clamp(0.0, 1.0),
                        minHeight: 4,
                        backgroundColor: AppColors.elevated,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.cyan,
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: AppSpacing.base),


                  MobGradientButton(
                    label: 'EVENT DASHBOARD \uD83D\uDCCA',
                    isLarge: true,
                    onPressed: () async {
                      await context.push(
                        RoutePaths.hostDashboardPath(h.uuid),
                      );
                      if (context.mounted) {
                        context
                            .read<HappeningDetailCubit>()
                            .refresh();
                      }
                    },
                  ),


                  if (h.isTicketed) ...[
                    const SizedBox(height: AppSpacing.sm),
                    MobOutlinedButton(
                      label: 'Scan Tickets',
                      icon: Icons.qr_code_scanner_rounded,
                      onPressed: () async {
                        await context.push(
                          RoutePaths.ticketScannerPath(h.uuid),
                        );
                        if (context.mounted) {
                          context
                              .read<HappeningDetailCubit>()
                              .refresh();
                        }
                      },
                    ),
                  ],

                  const SizedBox(height: AppSpacing.sm),


                  Center(
                    child: GestureDetector(
                      onTap: () => setState(() => _isViewingAsHost = false),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.xs,
                        ),
                        child: Text(
                          'View as Attendee',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[

            MobCard(
              borderColor: AppColors.cyan.withValues(alpha: 0.2),
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const MobSectionLabel(label: 'Your Happening'),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'This is a free happening \u2014 no ticketing.',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.base),
                  MobOutlinedButton(
                    label: 'Manage Happening',
                    icon: Icons.settings_outlined,
                    onPressed: () => _showManageSheet(context),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.base),
        ],
      ),
    );
  }


  Widget _buildSwitchToHostView() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Center(
        child: GestureDetector(
          onTap: () => setState(() => _isViewingAsHost = true),
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.base),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.swap_horiz,
                  size: 16,
                  color: AppColors.cyan,
                ),
                const SizedBox(width: 4),
                Text(
                  'Switch to Host View',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.cyan,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }


  void _showOptionsSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.base),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),


                if (_isHost) ...[
                  _OptionTile(
                    icon: Icons.edit_outlined,
                    label: 'Edit Event',
                    onTap: () {
                      Navigator.pop(ctx);
                      _navigateToEdit(context);
                    },
                  ),
                  if (h.isTicketed)
                    _OptionTile(
                      icon: Icons.dashboard_outlined,
                      label: 'View Dashboard',
                      onTap: () async {
                        Navigator.pop(ctx);
                        await context.push(
                          RoutePaths.hostDashboardPath(h.uuid),
                        );
                        if (context.mounted) {
                          context
                              .read<HappeningDetailCubit>()
                              .refresh();
                        }
                      },
                    ),
                  _OptionTile(
                    icon: Icons.stop_circle_outlined,
                    label: 'End Event',
                    color: AppColors.warning,
                    onTap: () {
                      Navigator.pop(ctx);
                      _confirmEndHappening(context);
                    },
                  ),
                  _OptionTile(
                    icon: Icons.delete_outline,
                    label: 'Delete Event',
                    color: AppColors.error,
                    onTap: () {
                      Navigator.pop(ctx);
                      _confirmDeleteHappening(context);
                    },
                  ),
                ],


                _OptionTile(
                  icon: Icons.share_outlined,
                  label: 'Share Event',
                  onTap: () {
                    Navigator.pop(ctx);
                    ShareSheet.show(context, happening: h);
                  },
                ),


                if (!_isHost)
                  _OptionTile(
                    icon: Icons.flag_outlined,
                    label: 'Report',
                    color: AppColors.error,
                    onTap: () {
                      Navigator.pop(ctx);
                      if (!requireAuth(context,
                          action: 'report happenings and keep Lagos safe')) {
                        return;
                      }
                      ReportSheet.show(
                        context,
                        happeningUuid: h.uuid,
                        reportRepository: context.read<ReportRepository>(),
                      );
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }


  void _showManageSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.radiusXl),
        ),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.base),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: AppSpacing.base),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                _OptionTile(
                  icon: Icons.edit_outlined,
                  label: 'Edit Happening',
                  onTap: () {
                    Navigator.pop(ctx);
                    _navigateToEdit(context);
                  },
                ),
                _OptionTile(
                  icon: Icons.share_outlined,
                  label: 'Share',
                  onTap: () {
                    Navigator.pop(ctx);
                    ShareSheet.show(context, happening: h);
                  },
                ),
                _OptionTile(
                  icon: Icons.stop_circle_outlined,
                  label: 'End Happening',
                  color: AppColors.warning,
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmEndHappening(context);
                  },
                ),
                _OptionTile(
                  icon: Icons.delete_outline,
                  label: 'Delete Happening',
                  color: AppColors.error,
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmDeleteHappening(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  void _confirmEndHappening(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          title: Text(
            'End Happening?',
            style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
          ),
          content: Text(
            'This will mark "${h.title}" as ended. '
            'It will no longer appear in feeds or on the map. '
            'This action cannot be undone.',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _executeEndHappening(context);
              },
              child: Text(
                'End Happening',
                style: AppTypography.body.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  Future<void> _executeEndHappening(BuildContext context) async {
    final cubit = context.read<HappeningDetailCubit>();
    final success = await cubit.endHappening();

    if (!context.mounted) return;

    if (success) {
      await cubit.refresh();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Happening ended',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Failed to end happening. Please try again.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }


  void _confirmDeleteHappening(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          title: Text(
            'Delete Happening?',
            style: AppTypography.h3.copyWith(color: AppColors.error),
          ),
          content: Text(
            'This will permanently remove "${h.title}". '
            'This action cannot be undone.',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: AppTypography.body.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await _executeDeleteHappening(context);
              },
              child: Text(
                'Delete',
                style: AppTypography.body.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  Future<void> _executeDeleteHappening(BuildContext context) async {
    final cubit = context.read<HappeningDetailCubit>();
    final success = await cubit.deleteHappening();

    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Happening deleted',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );

      if (context.mounted) context.pop();
    } else {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete happening. Please try again.',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
    }
  }


  void _navigateToEdit(BuildContext context) {
    Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(
          value: context.read<HappeningDetailCubit>(),
          child: EditHappeningScreen(happening: h),
        ),
      ),
    );
  }


  Widget _buildDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MobSectionLabel(label: 'About This Happening'),
          const SizedBox(height: AppSpacing.sm),

          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            crossFadeState: _isDescriptionExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: Text(
              h.description!,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            secondChild: Text(
              h.description!,
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),

          if (h.description!.length > 160)
            GestureDetector(
              onTap: () => setState(
                () => _isDescriptionExpanded = !_isDescriptionExpanded,
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _isDescriptionExpanded ? 'Show less' : 'Read more',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.cyan,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

          const SizedBox(height: AppSpacing.base),
        ],
      ),
    );
  }


  Widget _buildMapPreview(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MobSectionLabel(label: 'Location'),
          const SizedBox(height: AppSpacing.sm),


          GestureDetector(
            onTap: () => _openDirections(),
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.elevated,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                border: Border.all(
                  color: AppColors.border,
                  width: 0.5,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                child: Stack(
                  alignment: Alignment.center,
                  children: [

                    Container(color: AppColors.elevated),


                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 40,
                          color: h.category.color,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.card,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm,
                            ),
                          ),
                          child: Text(
                            'Tap to open map',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),


                    if (h.isAreaBased)
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: h.category.color.withValues(alpha: 0.1),
                          border: Border.all(
                            color: h.category.color.withValues(alpha: 0.3),
                            width: 1,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.sm),


          Row(
            children: [
              Expanded(
                child: Text(
                  h.address ?? 'Location on map',
                  style: AppTypography.bodySmall,
                ),
              ),
              GestureDetector(
                onTap: () => _openDirections(),
                child: Text(
                  'Get Directions',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.cyan,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.base),
        ],
      ),
    );
  }


  List<Snap> get _snaps => widget.snaps;
  bool get _isSnapsLoading => widget.isSnapsLoading;

  Widget _buildSnapsSection(BuildContext context) {
    final snapCount = _snaps.length;

    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.lg, right: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          MobSectionLabel(
            label: 'Live Snaps',
            trailing: snapCount > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Text(
                      '\uD83D\uDCF8 $snapCount',
                      style: AppTypography.micro.copyWith(
                        color: AppColors.cyan,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: AppSpacing.sm),


          if (_isSnapsLoading)
            _buildSnapsShimmer()
          else if (_snaps.isNotEmpty)
            _buildSnapThumbnails(context)
          else
            _buildNoSnaps(context),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }


  Widget _buildSnapsShimmer() {
    return SizedBox(
      height: 80,
      child: Row(
        children: List.generate(3, (i) {
          return Padding(
            padding: EdgeInsets.only(right: i < 2 ? AppSpacing.sm : 0),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.elevated,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildSnapThumbnails(BuildContext context) {
    return SizedBox(
      height: 80,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _snaps.length + 1,
        itemBuilder: (context, index) {

          if (index == _snaps.length) {
            return _buildAddSnapCard(context);
          }

          final snap = _snaps[index];

          final imageUrl = snap.isVideo
              ? (snap.thumbnailUrl ?? snap.mediaUrl)
              : snap.mediaUrl;

          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: GestureDetector(
              onTap: () async {
                await context.push(
                  '${RoutePaths.snapViewerPath(h.uuid)}?startIndex=$index',
                );

                if (context.mounted) {
                  context.read<HappeningDetailCubit>().refresh();
                }
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.elevated,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  border: Border.all(
                    color: AppColors.border,
                    width: 0.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [

                      CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        memCacheWidth: 300,
                        memCacheHeight: 300,
                        placeholder: (_, __) => Container(
                          color: AppColors.elevated,
                          child: const Icon(
                            Icons.image,
                            color: AppColors.textTertiary,
                            size: 20,
                          ),
                        ),
                        errorWidget: (_, __, ___) => Container(
                          color: AppColors.elevated,
                          child: const Icon(
                            Icons.image,
                            color: AppColors.textTertiary,
                            size: 20,
                          ),
                        ),
                      ),


                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        height: 28,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.6),
                              ],
                            ),
                          ),
                        ),
                      ),


                      if (snap.uploaderAvatarUrl != null)
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1,
                              ),
                            ),
                            child: ClipOval(
                              child: CachedNetworkImage(
                                imageUrl: snap.uploaderAvatarUrl!,
                                fit: BoxFit.cover,
                                memCacheWidth: 40,
                                memCacheHeight: 40,
                                placeholder: (_, __) => Container(
                                  color: AppColors.surface,
                                ),
                                errorWidget: (_, __, ___) => Container(
                                  color: AppColors.surface,
                                  child: const Icon(
                                    Icons.person,
                                    size: 12,
                                    color: AppColors.textTertiary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),


                      if (snap.isVideo)
                        Positioned.fill(
                          child: Center(
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.play_arrow,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),


                      if (snap.isVideo && snap.durationSeconds != null)
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.6),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${snap.durationSeconds! ~/ 60}:${(snap.durationSeconds! % 60).toString().padLeft(2, '0')}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAddSnapCard(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleSnapTap(context),
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: AppColors.cyan.withValues(alpha: 0.3),
            width: 1.5,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              color: AppColors.cyan,
              size: 24,
            ),
            SizedBox(height: 4),
            Text(
              'Add',
              style: TextStyle(
                color: AppColors.cyan,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoSnaps(BuildContext context) {
    return Column(
      children: [
        MobCard(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Icon(
                Icons.camera_alt_outlined,
                color: AppColors.cyan.withValues(alpha: 0.4),
                size: 32,
              ),
              const SizedBox(height: AppSpacing.sm),
              const Text(
                'Be the first to snap!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Show what\'s really happening',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                height: 36,
                width: 160,
                child: MobOutlinedButton(
                  label: 'Add Snap \uD83D\uDCF8',
                  icon: Icons.camera_alt_outlined,
                  onPressed: () => _handleSnapTap(context),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '\u26A0\uFE0F ',
              style: TextStyle(fontSize: 12),
            ),
            Flexible(
              child: Text(
                'No visual verification yet',
                style: AppTypography.caption.copyWith(
                  color: AppColors.warning,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _handleSnapTap(BuildContext context) async {
    if (!requireAuth(context, action: 'add snaps and show what\u2019s happening')) {
      return;
    }


    final snapDisplayStatus = getDisplayStatus(h);
    if (h.status != HappeningStatus.active ||
        snapDisplayStatus == HappeningDisplayStatus.ended ||
        snapDisplayStatus == HappeningDisplayStatus.expired) {
      if (context.mounted) {
        final reason = snapDisplayStatus == HappeningDisplayStatus.ended
            ? 'This event has ended.'
            : 'This happening has expired.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(reason)),
        );
      }
      return;
    }


    if (!_isHost &&
        h.startsAt != null &&
        h.startsAt!.isAfter(DateTime.now())) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Snaps open when this event goes live.',
            ),
            backgroundColor: AppColors.warning,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
          ),
        );
      }
      return;
    }

    await context.push(RoutePaths.snapCameraPath(h.uuid));

    if (context.mounted) {
      context.read<HappeningDetailCubit>().refresh();
    }
  }


  Widget _buildReportLink(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          if (!requireAuth(context, action: 'report happenings and keep Lagos safe')) {
            return;
          }
          ReportSheet.show(
            context,
            happeningUuid: h.uuid,
            reportRepository: context.read<ReportRepository>(),
          );
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          child: Text(
            '\uD83D\uDEA9 Report this happening',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}


class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.6),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: AppColors.textPrimary,
          size: 20,
        ),
      ),
    );
  }
}


class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tileColor = color ?? AppColors.textPrimary;
    return ListTile(
      leading: Icon(icon, color: tileColor, size: 22),
      title: Text(
        label,
        style: AppTypography.body.copyWith(color: tileColor),
      ),
      onTap: onTap,
    );
  }
}


class _NotFoundError extends StatelessWidget {
  const _NotFoundError({required this.onBrowseFeed});

  final VoidCallback onBrowseFeed;

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
                color: AppColors.warning.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.hourglass_disabled_rounded,
                size: 40,
                color: AppColors.warning,
              ),
            ),
            AppSpacing.verticalBase,
            const Text(
              'Happening Not Found',
              style: AppTypography.h4,
              textAlign: TextAlign.center,
            ),
            AppSpacing.verticalSm,
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 280),
              child: const Text(
                'This happening may have expired or been removed. '
                'Happenings on Mob are live for 24 hours.',
                style: AppTypography.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
            AppSpacing.verticalXl,
            SizedBox(
              width: 200,
              child: MobGradientButton(
                label: 'Browse Feed',
                onPressed: onBrowseFeed,
                icon: Icons.explore_rounded,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _DetailShimmer extends StatelessWidget {
  const _DetailShimmer();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            height: 280,
            color: AppColors.elevated,
          ),

          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Container(
                  height: 28,
                  width: 260,
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 20,
                  width: 180,
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),
                const SizedBox(height: 20),


                Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.elevated,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 14,
                          width: 120,
                          decoration: BoxDecoration(
                            color: AppColors.elevated,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 10,
                          width: 80,
                          decoration: BoxDecoration(
                            color: AppColors.elevated,
                            borderRadius:
                                BorderRadius.circular(AppSpacing.radiusSm),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),


                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusLg),
                          border: Border.all(
                            color: AppColors.border,
                            width: 0.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius:
                              BorderRadius.circular(AppSpacing.radiusLg),
                          border: Border.all(
                            color: AppColors.border,
                            width: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),


                ...List.generate(3, (i) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: AppColors.elevated,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: 10,
                              width: 60,
                              decoration: BoxDecoration(
                                color: AppColors.elevated,
                                borderRadius:
                                    BorderRadius.circular(4),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              height: 14,
                              width: 180,
                              decoration: BoxDecoration(
                                color: AppColors.elevated,
                                borderRadius:
                                    BorderRadius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
