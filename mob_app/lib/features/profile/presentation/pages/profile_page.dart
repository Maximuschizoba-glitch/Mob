import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../feed/domain/entities/happening.dart';
import '../../../feed/presentation/widgets/happening_list_card.dart';
import '../../../ticketing/domain/repositories/ticket_repository.dart';
import '../../../ticketing/presentation/bloc/ticket_cubit.dart';
import '../../../ticketing/presentation/bloc/ticket_state.dart';
import '../../../ticketing/presentation/widgets/ticket_list_card.dart';
import '../../domain/entities/host_verification.dart';
import '../../domain/repositories/host_verification_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import '../bloc/host_verification_cubit.dart';
import '../bloc/host_verification_state.dart';
import '../bloc/profile_cubit.dart';
import '../bloc/profile_state.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {

        if (authState is! Authenticated) {
          return const _GuestView();
        }


        return _AuthenticatedProfileProviders(
          user: authState.user,
        );
      },
    );
  }
}


class _AuthenticatedProfileProviders extends StatelessWidget {
  const _AuthenticatedProfileProviders({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (ctx) => ProfileCubit(
            profileRepository: ctx.read<ProfileRepository>(),
          )..loadProfile(),
        ),
        BlocProvider(
          create: (ctx) => HostVerificationCubit(
            hostVerificationRepository:
                ctx.read<HostVerificationRepository>(),
          )..loadVerificationStatus(),
        ),
        BlocProvider(
          create: (ctx) => TicketCubit(
            ticketRepository: ctx.read<TicketRepository>(),
          )..loadMyTickets(),
        ),
      ],
      child: const _AuthenticatedView(),
    );
  }
}


class _AuthenticatedView extends StatelessWidget {
  const _AuthenticatedView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const _ProfileShimmer();
            }

            if (state is ProfileError && state.previousUser == null) {
              return MobErrorState(
                message: state.message,
                onRetry: () =>
                    context.read<ProfileCubit>().loadProfile(),
              );
            }


            final user = _resolveUser(context, state);
            if (user == null) {
              return const _ProfileShimmer();
            }

            return _ProfileContent(user: user);
          },
        ),
      ),
    );
  }

  User? _resolveUser(BuildContext context, ProfileState state) {
    if (state is ProfileLoaded) return state.user;
    if (state is ProfileUpdating) return state.user;
    if (state is ProfileUpdateSuccess) return state.user;
    if (state is ProfileError && state.previousUser != null) {
      return state.previousUser;
    }

    return context.read<AuthCubit>().currentUser;
  }
}


class _ProfileContent extends StatelessWidget {
  const _ProfileContent({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [

        SliverToBoxAdapter(
          child: _AppBar(user: user),
        ),


        SliverToBoxAdapter(
          child: _ProfileHeader(user: user),
        ),


        const SliverToBoxAdapter(
          child: _StatsRow(),
        ),


        const SliverToBoxAdapter(
          child: _ContentTabs(),
        ),


        const SliverToBoxAdapter(
          child: _HostVerificationCTA(),
        ),


        const SliverPadding(
          padding: EdgeInsets.only(bottom: AppSpacing.huge + AppSpacing.xxl),
        ),
      ],
    );
  }
}


class _AppBar extends StatelessWidget {
  const _AppBar({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.base,
        AppSpacing.md,
        0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Profile', style: AppTypography.h1),
          IconButton(
            onPressed: () => context.push(RoutePaths.settings),
            icon: const Icon(
              Icons.settings_outlined,
              color: AppColors.textSecondary,
              size: 24,
            ),
            splashRadius: 20,
          ),
        ],
      ),
    );
  }
}


class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          AppSpacing.verticalLg,


          MobAvatar(
            imageUrl: user.avatarUrl,
            size: AppSpacing.avatarXl,
            showBorder: true,
            showVerifiedBadge: user.isHostVerified,
            initials: user.initials,
          ),

          AppSpacing.verticalBase,


          Text(
            user.name,
            style: AppTypography.h2,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          AppSpacing.verticalXs,


          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.location_on_outlined,
                size: 14,
                color: AppColors.textSecondary,
              ),
              AppSpacing.horizontalXs,
              Text(
                'Lagos, Nigeria',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),


          if (user.hasHostProfile) ...[
            AppSpacing.verticalSm,
            Text(
              user.isHostVerified
                  ? 'Verified Host'
                  : 'Host',
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],

          AppSpacing.verticalBase,


          SizedBox(
            width: 160,
            child: _EditProfilePill(
              onTap: () => context.push(RoutePaths.editProfile),
            ),
          ),

          AppSpacing.verticalLg,
        ],
      ),
    );
  }
}


class _EditProfilePill extends StatelessWidget {
  const _EditProfilePill({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          border: Border.all(color: AppColors.cyan, width: 1),
        ),
        alignment: Alignment.center,
        child: Text(
          'Edit Profile',
          style: AppTypography.buttonSmall.copyWith(
            color: AppColors.cyan,
          ),
        ),
      ),
    );
  }
}


class _StatsRow extends StatelessWidget {
  const _StatsRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, profileState) {
              final count = _happeningsFromState(profileState).length;
              return _StatPill(
                count: count,
                label: 'Happenings',
                icon: Icons.explore_outlined,
                onTap: () async {
                  await context.push(RoutePaths.myHappenings);
                  if (context.mounted) {
                    context.read<ProfileCubit>().loadProfile();
                  }
                },
              );
            },
          ),
          AppSpacing.horizontalMd,
          BlocBuilder<TicketCubit, TicketState>(
            builder: (context, ticketState) {
              final ticketCount = ticketState is TicketsLoaded
                  ? ticketState.tickets.length
                  : 0;
              return _StatPill(
                count: ticketCount,
                label: 'Tickets',
                icon: Icons.confirmation_number_outlined,
              );
            },
          ),
        ],
      ),
    );
  }
}


List<Happening> _happeningsFromState(ProfileState state) {
  if (state is ProfileLoaded) return state.happenings;
  if (state is ProfileUpdating) return state.happenings;
  if (state is ProfileUpdateSuccess) return state.happenings;
  if (state is ProfileError) return state.happenings;
  return const [];
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.count,
    required this.label,
    required this.icon,
    this.onTap,
  });

  final int count;
  final String label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final pill = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: AppColors.textTertiary),
          AppSpacing.horizontalSm,
          Text(
            '$count',
            style: AppTypography.buttonSmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          AppSpacing.horizontalXs,
          Text(
            label,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: pill);
    }
    return pill;
  }
}


class _ContentTabs extends StatefulWidget {
  const _ContentTabs();

  @override
  State<_ContentTabs> createState() => _ContentTabsState();
}

class _ContentTabsState extends State<_ContentTabs>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppSpacing.verticalLg,


        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.cyan.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppColors.cyan,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: AppTypography.buttonSmall,
              unselectedLabelStyle: AppTypography.buttonSmall,
              dividerColor: Colors.transparent,
              splashBorderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              tabs: const [
                Tab(text: 'My Happenings'),
                Tab(text: 'My Tickets'),
              ],
            ),
          ),
        ),

        AppSpacing.verticalBase,


        AnimatedBuilder(
          animation: _tabController,
          builder: (context, _) {
            return IndexedStack(
              index: _tabController.index,
              children: const [
                _MyHappeningsTab(),
                _MyTicketsTab(),
              ],
            );
          },
        ),
      ],
    );
  }
}


class _MyHappeningsTab extends StatelessWidget {
  const _MyHappeningsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileLoading) {
          return _buildHappeningShimmer();
        }

        final happenings = _happeningsFromState(state);

        if (happenings.isEmpty) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: MobEmptyState(
              icon: Icons.explore_outlined,
              title: 'No happenings yet',
              body: 'You haven\'t posted any happenings yet. '
                  'Share what\'s happening around you!',
              primaryLabel: 'Create One +',
              onPrimary: () => context.push(RoutePaths.post),
            ),
          );
        }


        final displayHappenings = happenings.take(5).toList();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Column(
            children: [

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${happenings.length} Happening${happenings.length == 1 ? '' : 's'}',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await context.push(RoutePaths.myHappenings);
                      if (context.mounted) {
                        context.read<ProfileCubit>().loadProfile();
                      }
                    },
                    child: Text(
                      'See All \u2192',
                      style: AppTypography.buttonSmall.copyWith(
                        color: AppColors.cyan,
                      ),
                    ),
                  ),
                ],
              ),
              AppSpacing.verticalMd,


              for (int i = 0; i < displayHappenings.length; i++) ...[
                HappeningListCard(happening: displayHappenings[i]),
                if (i < displayHappenings.length - 1)
                  AppSpacing.verticalMd,
              ],
              if (happenings.length > 5) ...[
                AppSpacing.verticalBase,
                MobTextButton(
                  label: 'View All Happenings',
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () async {
                    await context.push(RoutePaths.myHappenings);
                    if (context.mounted) {
                      context.read<ProfileCubit>().loadProfile();
                    }
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHappeningShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.card,
      highlightColor: AppColors.elevated,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          children: List.generate(3, (index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < 2 ? AppSpacing.md : 0,
              ),
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}


class _MyTicketsTab extends StatelessWidget {
  const _MyTicketsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketCubit, TicketState>(
      builder: (context, state) {
        if (state is TicketsLoading) {
          return _buildTicketShimmer();
        }

        if (state is TicketError) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: MobErrorState(
              message: state.message,
              onRetry: () =>
                  context.read<TicketCubit>().loadMyTickets(),
            ),
          );
        }

        if (state is TicketsLoaded) {
          if (state.tickets.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: MobEmptyState(
                icon: Icons.confirmation_number_outlined,
                title: 'No tickets yet',
                body: 'When you purchase tickets for happenings, '
                    'they\'ll show up here.',
                primaryLabel: 'Browse Happenings',
                onPrimary: () => context.go(RoutePaths.feed),
              ),
            );
          }


          final displayTickets = state.tickets.take(5).toList();

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                for (int i = 0; i < displayTickets.length; i++) ...[
                  TicketListCard(
                    ticket: displayTickets[i],
                    onTap: () => context.push(
                      RoutePaths.ticketDetailPath(displayTickets[i].uuid),
                    ),
                  ),
                  if (i < displayTickets.length - 1)
                    AppSpacing.verticalMd,
                ],
                if (state.tickets.length > 5) ...[
                  AppSpacing.verticalBase,
                  MobTextButton(
                    label: 'View All Tickets',
                    icon: Icons.arrow_forward_rounded,
                    onPressed: () => context.go(RoutePaths.tickets),
                  ),
                ],
              ],
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildTicketShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.card,
      highlightColor: AppColors.elevated,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          children: List.generate(3, (index) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: index < 2 ? AppSpacing.md : 0,
              ),
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}


class _HostVerificationCTA extends StatelessWidget {
  const _HostVerificationCTA();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HostVerificationCubit, HostVerificationState>(
      builder: (context, state) {
        if (state is HostVerificationLoading) {
          return const SizedBox.shrink();
        }

        if (state is HostVerificationError) {

          return const SizedBox.shrink();
        }


        if (state is HostVerificationEmpty ||
            state is HostVerificationInitial) {
          return const _VerificationCTANotHost();
        }

        if (state is HostVerificationLoaded) {
          return _buildForStatus(state.verification);
        }

        if (state is HostVerificationSubmitted) {
          return _buildForStatus(state.verification);
        }

        return const _VerificationCTANotHost();
      },
    );
  }

  Widget _buildForStatus(HostVerification verification) {
    if (verification.isApproved) {
      return const _VerificationCTAVerified();
    }
    if (verification.isPending) {
      return const _VerificationCTAPending();
    }

    return const _VerificationCTANotHost();
  }
}


class _VerificationCTANotHost extends StatelessWidget {
  const _VerificationCTANotHost();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          AppSpacing.verticalXl,
          MobCard(
            child: Column(
              children: [

                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.cyan.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '\u{1F451}',
                    style: TextStyle(fontSize: 24),
                  ),
                ),

                AppSpacing.verticalMd,

                const Text(
                  'Become a Verified Host',
                  style: AppTypography.h3,
                  textAlign: TextAlign.center,
                ),

                AppSpacing.verticalSm,

                Text(
                  'Get a trust badge, sell tickets, and reach more people.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                AppSpacing.verticalLg,

                MobGradientButton(
                  label: 'Get Verified \u2192',
                  onPressed: () =>
                      context.push(RoutePaths.hostVerification),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _VerificationCTAPending extends StatelessWidget {
  const _VerificationCTAPending();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          AppSpacing.verticalXl,
          MobCard(
            borderColor: AppColors.warning.withValues(alpha: 0.3),
            child: Column(
              children: [

                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    '\u{23F3}',
                    style: TextStyle(fontSize: 24),
                  ),
                ),

                AppSpacing.verticalMd,

                Text(
                  'Verification Pending',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.warning,
                  ),
                  textAlign: TextAlign.center,
                ),

                AppSpacing.verticalSm,

                Text(
                  'Your application is under review. '
                  'This usually takes 24-48 hours.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                AppSpacing.verticalLg,

                MobOutlinedButton(
                  label: 'View Application \u2192',
                  borderColor: AppColors.warning,
                  textColor: AppColors.warning,
                  onPressed: () => context.push(
                    RoutePaths.hostVerificationStatus,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class _VerificationCTAVerified extends StatelessWidget {
  const _VerificationCTAVerified();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          AppSpacing.verticalXl,
          MobCard(
            borderColor: AppColors.success.withValues(alpha: 0.3),
            backgroundColor: AppColors.success.withValues(alpha: 0.05),
            child: Column(
              children: [

                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.verified_rounded,
                    color: AppColors.success,
                    size: 28,
                  ),
                ),

                AppSpacing.verticalMd,

                Text(
                  'Verified Host',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.success,
                  ),
                  textAlign: TextAlign.center,
                ),

                AppSpacing.verticalSm,

                Text(
                  'You\'re a verified host. Your badge appears '
                  'on all your happenings.',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                AppSpacing.verticalMd,

                GestureDetector(
                  onTap: () => context.push(
                    RoutePaths.hostVerificationStatus,
                  ),
                  child: Text(
                    'View Status \u2192',
                    style: AppTypography.buttonSmall.copyWith(
                      color: AppColors.success,
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
}


class _ProfileShimmer extends StatelessWidget {
  const _ProfileShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.card,
      highlightColor: AppColors.elevated,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Column(
          children: [

            AppSpacing.verticalBase,
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 80,
                  height: 28,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: AppColors.card,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),

            AppSpacing.verticalXxl,


            Container(
              width: AppSpacing.avatarXl,
              height: AppSpacing.avatarXl,
              decoration: const BoxDecoration(
                color: AppColors.card,
                shape: BoxShape.circle,
              ),
            ),

            AppSpacing.verticalBase,


            Container(
              width: 160,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
            ),

            AppSpacing.verticalSm,


            Container(
              width: 120,
              height: 14,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
            ),

            AppSpacing.verticalLg,


            Container(
              width: 160,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius:
                    BorderRadius.circular(AppSpacing.radiusFull),
              ),
            ),

            AppSpacing.verticalXl,


            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 120,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                ),
                AppSpacing.horizontalMd,
                Container(
                  width: 100,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                ),
              ],
            ),

            AppSpacing.verticalXxl,


            Container(
              width: double.infinity,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
            ),

            AppSpacing.verticalLg,


            ...List.generate(3, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                child: Container(
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}


class _GuestView extends StatelessWidget {
  const _GuestView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.base,
                AppSpacing.lg,
                AppSpacing.sm,
              ),
              child: Text('Profile', style: AppTypography.h1),
            ),

            Expanded(
              child: Center(
                child: Padding(
                  padding: AppSpacing.screenPadding,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [

                      Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          color: AppColors.elevated,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: const Icon(
                          Icons.person_outline_rounded,
                          size: 40,
                          color: AppColors.textTertiary,
                        ),
                      ),

                      AppSpacing.verticalLg,

                      const Text(
                        'Create Your Profile',
                        style: AppTypography.h3,
                        textAlign: TextAlign.center,
                      ),

                      AppSpacing.verticalSm,

                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: Text(
                          'Create an account to build your profile, '
                          'post happenings, and get verified as a host.',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      AppSpacing.verticalXl,

                      SizedBox(
                        width: 220,
                        child: MobGradientButton(
                          label: 'Create Account',
                          onPressed: () =>
                              context.push(RoutePaths.register),
                        ),
                      ),

                      AppSpacing.verticalMd,

                      GestureDetector(
                        onTap: () => context.push(RoutePaths.login),
                        child: Text(
                          'Already have an account? Log In',
                          style: AppTypography.bodySmall.copyWith(
                            color: AppColors.cyan,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
