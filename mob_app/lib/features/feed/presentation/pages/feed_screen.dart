import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../core/services/tab_refresh.dart';
import '../../../../core/utils/auth_guard.dart';
import '../../../../shared/models/enums.dart';
import '../../../../shared/widgets/mob_chip.dart';
import '../../../../shared/widgets/mob_error_state.dart';
import '../../../notifications/presentation/bloc/notification_cubit.dart';
import '../../../notifications/presentation/bloc/notification_state.dart';
import '../../domain/entities/happening.dart';
import '../bloc/feed_cubit.dart';
import '../bloc/feed_state.dart';
import '../widgets/feed_empty_state.dart';
import '../widgets/feed_filters_sheet.dart';
import '../widgets/feed_shimmer.dart';
import '../widgets/happening_list_card.dart';
import '../widgets/hero_happening_card.dart';


class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();


    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FeedCubit>().loadFeed();
    });


    _scrollController.addListener(_onScroll);


    feedTabActiveNotifier.addListener(_onTabRefresh);
  }

  @override
  void dispose() {
    feedTabActiveNotifier.removeListener(_onTabRefresh);
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onTabRefresh() {
    context.read<FeedCubit>().refreshFeed();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    if (maxScroll - currentScroll <= 200) {
      context.read<FeedCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [

            _buildTopBar(),
            _buildLocationBar(),
            _buildCategoryChips(),


            Container(
              height: 1,
              color: AppColors.border,
            ),


            Expanded(
              child: BlocConsumer<FeedCubit, FeedState>(
                listenWhen: (prev, curr) => curr is FeedError,
                listener: _onFeedStateChanged,
                builder: (context, state) {
                  if (state is FeedLoading || state is FeedInitial) {
                    return const SingleChildScrollView(
                      child: FeedShimmer(),
                    );
                  }

                  if (state is FeedEmpty) {
                    return const FeedEmptyState();
                  }

                  if (state is FeedError &&
                      state.previousHappenings == null) {
                    return MobErrorState(
                      message: state.message,
                      onRetry: () =>
                          context.read<FeedCubit>().loadFeed(),
                    );
                  }


                  final happenings = _resolveHappenings(state);
                  if (happenings == null || happenings.isEmpty) {
                    return const SingleChildScrollView(
                      child: FeedShimmer(),
                    );
                  }

                  final isLoadingMore = state is FeedLoaded &&
                      state.isLoadingMore;

                  return RefreshIndicator(
                    onRefresh: () =>
                        context.read<FeedCubit>().refreshFeed(),
                    color: AppColors.cyan,
                    backgroundColor: AppColors.card,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.only(
                        top: AppSpacing.base,
                        bottom: AppSpacing.huge,
                      ),
                      itemCount: _itemCount(happenings, isLoadingMore),
                      itemBuilder: (context, index) {
                        return _buildFeedItem(
                          index,
                          happenings,
                          isLoadingMore,
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        top: AppSpacing.md,
        bottom: AppSpacing.sm,
      ),
      child: Row(
        children: [

          Text(
            'Mob',
            style: AppTypography.h2.copyWith(
              color: AppColors.cyan,
              letterSpacing: 2,
            ),
          ),

          const Spacer(),


          _TopBarIcon(
            icon: Icons.tune_rounded,
            onTap: () => FeedFiltersSheet.show(context),
          ),

          const SizedBox(width: AppSpacing.md),


          BlocBuilder<NotificationCubit, NotificationState>(
            buildWhen: (prev, curr) {

              final prevCount =
                  prev is NotificationsLoaded ? prev.unreadCount : 0;
              final currCount =
                  curr is NotificationsLoaded ? curr.unreadCount : 0;
              return prevCount != currCount;
            },
            builder: (context, notifState) {
              final unreadCount = notifState is NotificationsLoaded
                  ? notifState.unreadCount
                  : 0;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  _TopBarIcon(
                    icon: Icons.notifications_outlined,
                    onTap: () {
                      if (!requireAuth(context, action: 'view notifications')) {
                        return;
                      }
                      context.push(RoutePaths.notifications);
                    },
                  ),
                  if (unreadCount > 0)
                    Positioned(
                      right: -2,
                      top: -2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 1,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusFull,
                          ),
                          border: Border.all(
                            color: AppColors.background,
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          unreadCount > 99 ? '99+' : '$unreadCount',
                          style: AppTypography.micro.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }


  Widget _buildLocationBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [

          GestureDetector(
            onTap: () {

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Location picker coming soon'),
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 1),
                ),
              );
            },
            behavior: HitTestBehavior.opaque,
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppColors.cyan,
                ),
                SizedBox(width: 4),
                Text(
                  'Lagos',
                  style: AppTypography.buttonSmall,
                ),
                SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),

          const Spacer(),


          BlocBuilder<FeedCubit, FeedState>(
            buildWhen: (_, __) => false,
            builder: (context, _) {
              final radius = context.read<FeedCubit>().radiusKm;
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColors.elevated,
                  borderRadius:
                      BorderRadius.circular(AppSpacing.radiusFull),
                ),
                child: Text(
                  '${radius.round()}km',
                  style: AppTypography.micro.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }


  Widget _buildCategoryChips() {
    return SizedBox(
      height: AppSpacing.huge,
      child: BlocBuilder<FeedCubit, FeedState>(
        buildWhen: (prev, curr) {

          if (curr is FeedLoaded && prev is FeedLoaded) {
            return curr.activeCategory != prev.activeCategory;
          }
          return true;
        },
        builder: (context, state) {
          final activeCategory =
              context.read<FeedCubit>().activeCategory;

          return ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm,
            ),
            children: [

              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: MobChip(
                  label: 'All',
                  isActive: activeCategory == null,
                  onTap: () => context
                      .read<FeedCubit>()
                      .filterByCategory(null),
                ),
              ),


              ...HappeningCategory.values.map((cat) {
                return Padding(
                  padding:
                      const EdgeInsets.only(right: AppSpacing.sm),
                  child: MobChip(
                    label: '${cat.emoji} ${cat.displayName}',
                    isActive: activeCategory == cat.value,
                    activeColor: cat.color,
                    onTap: () => context
                        .read<FeedCubit>()
                        .filterByCategory(cat.value),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }


  List<Happening>? _resolveHappenings(FeedState state) {
    if (state is FeedLoaded) return state.happenings;
    if (state is FeedRefreshing) return null;
    if (state is FeedError) return state.previousHappenings;
    return null;
  }


  int _itemCount(List<Happening> happenings, bool isLoadingMore) {
    if (happenings.isEmpty) return 0;

    final listCards = happenings.length > 1 ? happenings.length - 1 : 0;
    return 1 + 1 + listCards + (isLoadingMore ? 1 : 0);
  }


  Widget _buildFeedItem(
    int index,
    List<Happening> happenings,
    bool isLoadingMore,
  ) {

    if (index == 0) {
      return Padding(
        padding: AppSpacing.screenPadding,
        child: HeroHappeningCard(happening: happenings.first),
      );
    }


    if (index == 1) {
      return Padding(
        padding: const EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: AppSpacing.sm,
        ),
        child: Row(
          children: [
            const Text(
              'Coming Up',
              style: AppTypography.buttonSmall,
            ),
            const Spacer(),
            GestureDetector(
              onTap: () {

              },
              child: Text(
                'See All \u203A',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.cyan,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }


    final listCardCount = happenings.length > 1
        ? happenings.length - 1
        : 0;
    if (isLoadingMore && index == 2 + listCardCount) {
      return const Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: AppColors.cyan,
              strokeWidth: 2.5,
            ),
          ),
        ),
      );
    }


    final happeningIndex = index - 2 + 1;
    if (happeningIndex < happenings.length) {
      return Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          bottom: index == 1 + listCardCount ? 0 : AppSpacing.md,
        ),
        child: HappeningListCard(
          happening: happenings[happeningIndex],
        ),
      );
    }

    return const SizedBox.shrink();
  }


  void _onFeedStateChanged(BuildContext context, FeedState state) {

    if (state is FeedError && state.previousHappenings != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}


class _TopBarIcon extends StatelessWidget {
  const _TopBarIcon({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 32,
        height: 32,
        child: Icon(
          icon,
          size: 24,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}
