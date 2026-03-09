import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../core/utils/auth_guard.dart';
import '../../../../core/utils/happening_helpers.dart';
import '../../../../shared/models/enums.dart';
import '../../../../shared/widgets/happening_countdown.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../feed/domain/entities/happening.dart';
import '../../domain/repositories/profile_repository.dart';
import '../bloc/profile_cubit.dart';
import '../bloc/profile_state.dart';


const _kSwipeHintShown = 'my_happenings_swipe_hint_shown';


class MyHappeningsPage extends StatelessWidget {
  const MyHappeningsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => ProfileCubit(
        profileRepository: ctx.read<ProfileRepository>(),
      )..loadProfile(),
      child: const _MyHappeningsView(),
    );
  }
}


class _MyHappeningsView extends StatefulWidget {
  const _MyHappeningsView();

  @override
  State<_MyHappeningsView> createState() => _MyHappeningsViewState();
}

class _MyHappeningsViewState extends State<_MyHappeningsView> {

  HappeningStatus? _activeFilter;


  bool _showSwipeHint = false;

  @override
  void initState() {
    super.initState();
    _loadSwipeHintState();
  }

  Future<void> _loadSwipeHintState() async {
    final prefs = await SharedPreferences.getInstance();
    final hintShown = prefs.getBool(_kSwipeHintShown) ?? false;
    if (!hintShown && mounted) {
      setState(() => _showSwipeHint = true);
    }
  }

  Future<void> _dismissSwipeHint() async {
    if (!_showSwipeHint) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSwipeHintShown, true);
    if (mounted) {
      setState(() => _showSwipeHint = false);
    }
  }

  List<Happening> _filteredList(List<Happening> all) {
    if (_activeFilter == null) return all;
    return all.where((h) => h.status == _activeFilter).toList();
  }

  int _countByStatus(List<Happening> all, HappeningStatus status) {
    return all.where((h) => h.status == status).length;
  }

  void _setFilter(HappeningStatus? status) {
    setState(() {
      _activeFilter = _activeFilter == status ? null : status;
    });
  }

  void _handlePostTap(BuildContext context) {
    if (!requireAuth(context, action: 'post happenings')) return;
    context.push(RoutePaths.post);
  }

  Future<void> _refresh() async {
    await context.read<ProfileCubit>().loadProfile();
  }


  Future<bool?> _showDeleteConfirmation(Happening happening) {
    final hasActiveTickets =
        happening.isTicketed && happening.ticketsSold > 0;

    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: const Text('Delete Happening?', style: AppTypography.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Are you sure you want to delete "${happening.title}"? '
              'This action cannot be undone.',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            if (hasActiveTickets) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusSm),
                  border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.3),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 18,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This happening has ${happening.ticketsSold} '
                        'ticket${happening.ticketsSold != 1 ? 's' : ''} '
                        'sold. Ticket holders will be refunded.',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              'Delete',
              style: AppTypography.body.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Future<bool> _handleDelete(Happening happening) async {

    _dismissSwipeHint();

    final confirmed = await _showDeleteConfirmation(happening);
    if (confirmed != true) return false;

    if (!mounted) return false;

    final success =
        await context.read<ProfileCubit>().deleteHappening(happening.uuid);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? '"${happening.title}" deleted'
                : 'Failed to delete "${happening.title}"',
          ),
          backgroundColor: success ? AppColors.success : AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }


    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          color: AppColors.textPrimary,
          onPressed: () => context.pop(),
        ),
        title: const Text('My Happenings', style: AppTypography.h3),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            color: AppColors.cyan,
            onPressed: () => _handlePostTap(context),
          ),
        ],
      ),
      body: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return _buildShimmer();
          }

          if (state is ProfileError && state.happenings.isEmpty) {
            return Center(
              child: MobErrorState(
                message: state.message,
                onRetry: _refresh,
              ),
            );
          }

          final happenings = _extractHappenings(state);

          if (happenings.isEmpty) {
            return _buildEmpty();
          }

          final filtered = _filteredList(happenings);

          return RefreshIndicator(
            onRefresh: _refresh,
            color: AppColors.cyan,
            backgroundColor: AppColors.card,
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.sm,
              ),
              children: [

                _StatPillsRow(
                  activeCount: _countByStatus(
                    happenings,
                    HappeningStatus.active,
                  ),
                  completedCount: _countByStatus(
                    happenings,
                    HappeningStatus.completed,
                  ),
                  endedCount: _countByStatus(
                    happenings,
                    HappeningStatus.expired,
                  ),
                  hiddenCount: _countByStatus(
                    happenings,
                    HappeningStatus.hidden,
                  ),
                  activeFilter: _activeFilter,
                  onFilterTap: _setFilter,
                ),

                AppSpacing.verticalBase,


                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.huge),
                    child: Center(
                      child: Text(
                        'No ${_activeFilter?.value ?? ''} happenings',
                        style: AppTypography.body.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  )
                else
                  ...filtered.asMap().entries.map(
                    (entry) {
                      final index = entry.key;
                      final h = entry.value;
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: AppSpacing.md,
                            ),
                            child: _DismissibleHappeningCard(
                              happening: h,
                              onConfirmDismiss: () => _handleDelete(h),
                            ),
                          ),


                          if (index == 0 && _showSwipeHint)
                            Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSpacing.md,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.arrow_back_rounded,
                                    size: 14,
                                    color: AppColors.textTertiary
                                        .withValues(alpha: 0.6),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Swipe to delete',
                                    style: AppTypography.caption.copyWith(
                                      color: AppColors.textTertiary
                                          .withValues(alpha: 0.6),
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      );
                    },
                  ),

                AppSpacing.verticalXxl,
              ],
            ),
          );
        },
      ),
    );
  }

  List<Happening> _extractHappenings(ProfileState state) {
    if (state is ProfileLoaded) return state.happenings;
    if (state is ProfileUpdating) return state.happenings;
    if (state is ProfileUpdateSuccess) return state.happenings;
    if (state is ProfileError) return state.happenings;
    return const [];
  }

  Widget _buildEmpty() {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: MobEmptyState(
          icon: Icons.auto_awesome_outlined,
          title: 'No happenings yet',
          body: 'Create your first happening and share '
              'what\u2019s going on!',
          primaryLabel: 'Create Happening',
          onPrimary: () => _handlePostTap(context),
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.card,
      highlightColor: AppColors.elevated,
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.base),
        itemCount: 4,
        itemBuilder: (_, i) => Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Container(
            height: 110,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            ),
          ),
        ),
      ),
    );
  }
}


class _DismissibleHappeningCard extends StatelessWidget {
  const _DismissibleHappeningCard({
    required this.happening,
    required this.onConfirmDismiss,
  });

  final Happening happening;
  final Future<bool> Function() onConfirmDismiss;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(happening.uuid),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => onConfirmDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'Delete',
              style: AppTypography.body.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.delete_outline_rounded,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
      child: _HappeningManageCard(happening: happening),
    );
  }
}


class _StatPillsRow extends StatelessWidget {
  const _StatPillsRow({
    required this.activeCount,
    required this.completedCount,
    required this.endedCount,
    required this.hiddenCount,
    required this.activeFilter,
    required this.onFilterTap,
  });

  final int activeCount;
  final int completedCount;
  final int endedCount;
  final int hiddenCount;
  final HappeningStatus? activeFilter;
  final ValueChanged<HappeningStatus?> onFilterTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatPill(
          count: activeCount,
          label: 'Active',
          color: AppColors.cyan,
          isSelected: activeFilter == HappeningStatus.active,
          onTap: () => onFilterTap(HappeningStatus.active),
        ),
        if (completedCount > 0) ...[
          AppSpacing.horizontalSm,
          _StatPill(
            count: completedCount,
            label: 'Completed',
            color: AppColors.success,
            isSelected: activeFilter == HappeningStatus.completed,
            onTap: () => onFilterTap(HappeningStatus.completed),
          ),
        ],
        AppSpacing.horizontalSm,
        _StatPill(
          count: endedCount,
          label: 'Ended',
          color: AppColors.textTertiary,
          isSelected: activeFilter == HappeningStatus.expired,
          onTap: () => onFilterTap(HappeningStatus.expired),
        ),
        if (hiddenCount > 0) ...[
          AppSpacing.horizontalSm,
          _StatPill(
            count: hiddenCount,
            label: 'Hidden',
            color: AppColors.error,
            isSelected: activeFilter == HappeningStatus.hidden,
            onTap: () => onFilterTap(HappeningStatus.hidden),
          ),
        ],
      ],
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.count,
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final int count;
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: isSelected
              ? Border.all(color: color, width: 1)
              : null,
        ),
        child: Text(
          '$count $label',
          style: AppTypography.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}


class _HappeningManageCard extends StatelessWidget {
  const _HappeningManageCard({required this.happening});

  final Happening happening;

  bool get _isHidden => happening.status == HappeningStatus.hidden;
  bool get _isActive => happening.status == HappeningStatus.active;
  bool get _isExpired => happening.status == HappeningStatus.expired;
  bool get _isCompleted => happening.status == HappeningStatus.completed;

  @override
  Widget build(BuildContext context) {
    return MobCard(
      onTap: () => context.push(
        RoutePaths.happeningDetailPath(happening.uuid),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              _buildThumbnail(),
              const SizedBox(width: AppSpacing.md),


              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Row(
                      children: [
                        _buildStatusBadge(),
                        const Spacer(),
                        if (_isActive)
                          HappeningCountdown(happening: happening),
                      ],
                    ),

                    const SizedBox(height: 6),


                    Text(
                      happening.title,
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
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
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              happening.address!,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textTertiary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 6),


                    _buildStatsRow(),
                  ],
                ),
              ),
            ],
          ),


          if (_isHidden) ...[
            const SizedBox(height: AppSpacing.md),
            _buildModerationAlert(),
          ],
        ],
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
                errorWidget: (_, __, ___) => _buildThumbnailFallback(),
              )
            : _buildThumbnailFallback(),
      ),
    );
  }

  Widget _buildThumbnailFallback() {
    return Container(
      color: AppColors.elevated,
      alignment: Alignment.center,
      child: Text(
        happening.category.emoji,
        style: const TextStyle(fontSize: 28),
      ),
    );
  }


  Widget _buildStatusBadge() {
    if (_isActive) {
      final displayStatus = getDisplayStatus(happening);
      if (displayStatus == HappeningDisplayStatus.upcoming) {
        return MobBadge.upcoming();
      }
      return const _LiveBadge();
    }
    if (_isCompleted) {
      return const MobBadge(
        label: 'COMPLETED',
        color: AppColors.success,
        icon: Icons.check_circle_outline_rounded,
      );
    }
    if (_isExpired) {
      return MobBadge.ended();
    }
    if (_isHidden) {
      return const MobBadge(
        label: 'HIDDEN',
        color: AppColors.error,
        icon: Icons.warning_amber_rounded,
      );
    }

    return const MobBadge(
      label: 'REPORTED',
      color: AppColors.warning,
      icon: Icons.flag_outlined,
    );
  }


  Widget _buildStatsRow() {
    final parts = <String>[];

    if (happening.snapsCount > 0) {
      parts.add('${happening.snapsCount} snap${happening.snapsCount != 1 ? 's' : ''}');
    }

    if (happening.vibeScore > 0) {
      parts.add('\uD83D\uDD25 ${happening.vibeScore.toStringAsFixed(1)}');
    }

    if (happening.isTicketed) {
      parts.add('${happening.ticketsSold} sold');
    }

    if (parts.isEmpty) {
      final label = _isCompleted
          ? 'Payout pending review'
          : _isExpired
              ? 'Ended'
              : 'No activity yet';
      return Text(
        label,
        style: AppTypography.caption.copyWith(
          color: _isCompleted ? AppColors.success : AppColors.textTertiary,
        ),
      );
    }

    return Text(
      parts.join(' \u2022 '),
      style: AppTypography.caption.copyWith(
        color: AppColors.textSecondary,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }


  Widget _buildModerationAlert() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.gavel_rounded,
            size: 16,
            color: AppColors.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'MODERATION ALERT',
              style: AppTypography.micro.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
          ),
          Text(
            'View Details',
            style: AppTypography.caption.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 2),
          const Icon(
            Icons.chevron_right_rounded,
            size: 16,
            color: AppColors.error,
          ),
        ],
      ),
    );
  }
}


class _LiveBadge extends StatefulWidget {
  const _LiveBadge();

  @override
  State<_LiveBadge> createState() => _LiveBadgeState();
}

class _LiveBadgeState extends State<_LiveBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.categoryParty.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.categoryParty
                      .withValues(alpha: _animation.value),
                ),
              );
            },
          ),
          const SizedBox(width: 4),
          Text(
            'LIVE',
            style: AppTypography.micro.copyWith(
              color: AppColors.categoryParty,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
