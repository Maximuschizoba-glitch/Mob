import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/repositories/ticket_repository.dart';
import '../bloc/ticket_cubit.dart';
import '../bloc/ticket_state.dart';
import '../widgets/ticket_list_card.dart';


class MyTicketsPage extends StatelessWidget {
  const MyTicketsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, authState) {

        if (authState is! Authenticated) {
          return const _GuestView();
        }


        return BlocProvider(
          create: (ctx) => TicketCubit(
            ticketRepository: ctx.read<TicketRepository>(),
          )..loadMyTickets(),
          child: const _AuthenticatedView(),
        );
      },
    );
  }
}


class _AuthenticatedView extends StatelessWidget {
  const _AuthenticatedView();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _AppBar(),


            _FilterTabs(),

            AppSpacing.verticalSm,


            Expanded(child: _TicketListBody()),
          ],
        ),
      ),
    );
  }
}


class _AppBar extends StatelessWidget {
  const _AppBar();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.base,
        AppSpacing.lg,
        AppSpacing.sm,
      ),
      child: Text('My Tickets', style: AppTypography.h1),
    );
  }
}


class _FilterOption {
  const _FilterOption({
    required this.label,
    this.apiValue,
  });

  final String label;
  final String? apiValue;
}

const _filters = [
  _FilterOption(label: 'All'),
  _FilterOption(label: 'Upcoming', apiValue: 'paid'),
  _FilterOption(label: 'Completed', apiValue: 'completed'),
  _FilterOption(label: 'Refunded', apiValue: 'refunded'),
];

class _FilterTabs extends StatelessWidget {
  const _FilterTabs();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketCubit, TicketState>(
      buildWhen: (prev, curr) {

        final prevFilter =
            prev is TicketsLoaded ? prev.activeFilter : null;
        final currFilter =
            curr is TicketsLoaded ? curr.activeFilter : null;
        return prevFilter != currFilter;
      },
      builder: (context, state) {
        final activeFilter =
            state is TicketsLoaded ? state.activeFilter : null;

        return SizedBox(
          height: AppSpacing.chipHeight + AppSpacing.base,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.xs,
            ),
            itemCount: _filters.length,
            separatorBuilder: (_, __) => AppSpacing.horizontalSm,
            itemBuilder: (context, index) {
              final filter = _filters[index];
              final isActive = filter.apiValue == activeFilter;

              return MobChip(
                label: filter.label,
                isActive: isActive,
                onTap: () {
                  context
                      .read<TicketCubit>()
                      .loadMyTickets(status: filter.apiValue);
                },
              );
            },
          ),
        );
      },
    );
  }
}


class _TicketListBody extends StatelessWidget {
  const _TicketListBody();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TicketCubit, TicketState>(
      builder: (context, state) {
        if (state is TicketsLoading) {
          return _buildShimmer();
        }

        if (state is TicketError) {
          return MobErrorState(
            message: state.message,
            onRetry: () => context.read<TicketCubit>().loadMyTickets(
                  status: context.read<TicketCubit>().activeFilter,
                ),
          );
        }

        if (state is TicketsLoaded) {
          if (state.tickets.isEmpty) {
            return _buildEmptyState(context, state.activeFilter);
          }
          return _buildTicketList(context, state);
        }


        return const SizedBox.shrink();
      },
    );
  }


  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.card,
      highlightColor: AppColors.elevated,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        itemCount: 4,
        separatorBuilder: (_, __) => AppSpacing.verticalMd,
        itemBuilder: (_, __) => _buildShimmerCard(),
      ),
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        children: [

          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.elevated,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
          ),
          AppSpacing.horizontalMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: 16,
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),
                AppSpacing.verticalSm,
                Container(
                  width: 140,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),
                AppSpacing.verticalSm,
                Container(
                  width: 100,
                  height: 12,
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),
                AppSpacing.verticalMd,
                Container(
                  width: double.infinity,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppColors.elevated,
                    borderRadius:
                        BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildEmptyState(BuildContext context, String? activeFilter) {

    final String title;
    final String body;

    switch (activeFilter) {
      case 'paid':
        title = 'No upcoming tickets';
        body =
            'You don\'t have any upcoming events. Browse happenings to find something fun!';
      case 'completed':
        title = 'No completed tickets';
        body = 'Events you\'ve attended will appear here.';
      case 'refunded':
        title = 'No refunded tickets';
        body = 'Tickets that have been refunded will show up here.';
      default:
        title = 'No tickets yet';
        body =
            'When you purchase tickets for happenings, they\'ll show up here.';
    }

    return MobEmptyState(
      icon: Icons.confirmation_number_outlined,
      title: title,
      body: body,
      primaryLabel: 'Browse Happenings',
      onPrimary: () => context.go(RoutePaths.feed),
    );
  }


  Widget _buildTicketList(BuildContext context, TicketsLoaded state) {
    return RefreshIndicator(
      onRefresh: () => context.read<TicketCubit>().loadMyTickets(
            status: state.activeFilter,
          ),
      color: AppColors.cyan,
      backgroundColor: AppColors.card,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        itemCount: state.tickets.length,
        separatorBuilder: (_, __) => AppSpacing.verticalMd,
        itemBuilder: (context, index) {
          final ticket = state.tickets[index];
          return TicketListCard(
            ticket: ticket,
            onTap: () => context.push(
              RoutePaths.ticketDetailPath(ticket.uuid),
            ),
          );
        },
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
              child: Text('My Tickets', style: AppTypography.h1),
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
                          Icons.lock_outline_rounded,
                          size: 40,
                          color: AppColors.textTertiary,
                        ),
                      ),

                      AppSpacing.verticalLg,

                      const Text(
                        'Sign Up to View Tickets',
                        style: AppTypography.h3,
                        textAlign: TextAlign.center,
                      ),

                      AppSpacing.verticalSm,

                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 280),
                        child: Text(
                          'Create an account to purchase tickets, '
                          'track escrow payments, and get QR codes '
                          'for events.',
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
