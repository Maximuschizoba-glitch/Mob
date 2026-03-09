import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../shared/models/enums.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../domain/entities/host_verification.dart';
import '../../domain/repositories/host_verification_repository.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../bloc/host_verification_cubit.dart';
import '../bloc/host_verification_state.dart';


class HostVerificationStatusPage extends StatelessWidget {
  const HostVerificationStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => HostVerificationCubit(
        hostVerificationRepository: ctx.read<HostVerificationRepository>(),
      )..loadVerificationStatus(),
      child: const _StatusView(),
    );
  }
}


class _StatusView extends StatefulWidget {
  const _StatusView();

  @override
  State<_StatusView> createState() => _StatusViewState();
}

class _StatusViewState extends State<_StatusView> {
  @override
  void initState() {
    super.initState();

    context.read<AuthCubit>().refreshUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: const Text('Verification Status', style: AppTypography.h3),
        centerTitle: true,
      ),
      body: BlocListener<HostVerificationCubit, HostVerificationState>(
        listener: (context, state) {


          if ((state is HostVerificationLoaded &&
                  state.verification.isApproved) ||
              state is HostVerificationSubmitted) {
            context.read<AuthCubit>().refreshUser();
          }
        },
        child: BlocBuilder<HostVerificationCubit, HostVerificationState>(
          builder: (context, state) {
            if (state is HostVerificationLoading ||
                state is HostVerificationInitial) {
              return const _StatusShimmer();
            }

            if (state is HostVerificationError) {
              return MobErrorState(
                message: state.message,
                onRetry: () => context
                    .read<HostVerificationCubit>()
                    .loadVerificationStatus(),
              );
            }


            if (state is HostVerificationEmpty) {
              return _buildNoVerificationState(context);
            }


            final verification = _extractVerification(state);
            if (verification == null) {
              return _buildNoVerificationState(context);
            }

            return _StatusContent(verification: verification);
          },
        ),
      ),
    );
  }

  HostVerification? _extractVerification(HostVerificationState state) {
    if (state is HostVerificationLoaded) return state.verification;
    if (state is HostVerificationSubmitted) return state.verification;
    if (state is HostVerificationSubmitting) {
      return state.previousVerification;
    }
    if (state is HostVerificationError) return state.previousVerification;
    return null;
  }

  Widget _buildNoVerificationState(BuildContext context) {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            MobEmptyState(
              icon: Icons.verified_outlined,
              title: 'No Application Found',
              body: 'You haven\'t submitted a verification request yet.',
              primaryLabel: 'Apply Now',
              onPrimary: () =>
                  context.pushReplacement(RoutePaths.hostVerification),
            ),
          ],
        ),
      ),
    );
  }
}


class _StatusContent extends StatelessWidget {
  const _StatusContent({required this.verification});

  final HostVerification verification;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: AppSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppSpacing.verticalBase,


          _StatusHeader(verification: verification),
          AppSpacing.verticalXxl,


          if (verification.isRejected) ...[
            _AdminNotesCard(verification: verification),
            AppSpacing.verticalXl,
          ],


          _ApplicationSummaryCard(verification: verification),
          AppSpacing.verticalXl,


          const MobSectionLabel(label: 'Review Process'),
          AppSpacing.verticalBase,
          _ReviewTimeline(verification: verification),
          AppSpacing.verticalXxl,


          _ActionButtons(verification: verification),
          AppSpacing.verticalXl,


          Center(
            child: GestureDetector(
              onTap: () => _launchSupport(),
              child: Text(
                'Need help? Contact Support',
                style: AppTypography.buttonSmall.copyWith(
                  color: AppColors.cyan,
                ),
              ),
            ),
          ),
          AppSpacing.verticalXxl,
        ],
      ),
    );
  }

  Future<void> _launchSupport() async {
    final uri = Uri.parse('mailto:support@getmob.app?subject=Host Verification Help');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}


class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.verification});

  final HostVerification verification;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildIcon(),
        AppSpacing.verticalBase,
        _buildTitle(),
        AppSpacing.verticalSm,
        _buildSubtitle(),
      ],
    );
  }

  Widget _buildIcon() {
    if (verification.isApproved) {
      return _ApprovedIcon();
    }
    if (verification.isRejected) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: const Icon(
          Icons.close_rounded,
          color: AppColors.error,
          size: 36,
        ),
      );
    }

    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: const Text(
        '\u{23F3}',
        style: TextStyle(fontSize: 32),
      ),
    );
  }

  Widget _buildTitle() {
    if (verification.isApproved) {
      return Text(
        'Verified! \u{1F389}',
        style: AppTypography.h1.copyWith(color: AppColors.success),
        textAlign: TextAlign.center,
      );
    }
    if (verification.isRejected) {
      return Text(
        'Not Approved',
        style: AppTypography.h1.copyWith(color: AppColors.error),
        textAlign: TextAlign.center,
      );
    }
    return Text(
      'Under Review',
      style: AppTypography.h1.copyWith(color: AppColors.warning),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildSubtitle() {
    final String text;
    if (verification.isApproved) {
      text = 'Congratulations! You\'re now a verified host on Mob.';
    } else if (verification.isRejected) {
      text = 'Unfortunately, your application wasn\'t approved this time.';
    } else {
      text = 'Your application is being reviewed by our team.';
    }

    return Text(
      text,
      style: AppTypography.body.copyWith(color: AppColors.textSecondary),
      textAlign: TextAlign.center,
    );
  }
}


class _ApprovedIcon extends StatefulWidget {
  @override
  State<_ApprovedIcon> createState() => _ApprovedIconState();
}

class _ApprovedIconState extends State<_ApprovedIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _glowAnimation = Tween<double>(begin: 0.1, end: 0.35).animate(
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
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.success
                    .withValues(alpha: _glowAnimation.value),
                blurRadius: 16,
                spreadRadius: 2,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: const Icon(
            Icons.verified_rounded,
            color: AppColors.success,
            size: 36,
          ),
        );
      },
    );
  }
}


class _AdminNotesCard extends StatelessWidget {
  const _AdminNotesCard({required this.verification});

  final HostVerification verification;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border, width: 0.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Container(
            width: 4,
            height: 120,
            decoration: const BoxDecoration(
              color: AppColors.error,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(AppSpacing.radiusLg),
                bottomLeft: Radius.circular(AppSpacing.radiusLg),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.base),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Feedback from our team:',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  AppSpacing.verticalSm,
                  Text(
                    verification.bio ?? 'No additional details provided.',
                    style: AppTypography.body.copyWith(
                      color: AppColors.textPrimary,
                      height: 1.5,
                    ),
                  ),
                  AppSpacing.verticalMd,
                  Text(
                    'You can submit a new application with updated information.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _ApplicationSummaryCard extends StatelessWidget {
  const _ApplicationSummaryCard({required this.verification});

  final HostVerification verification;

  @override
  Widget build(BuildContext context) {
    return MobCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Application Details',
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          AppSpacing.verticalBase,


          _InfoRow(
            label: 'Business Name',
            value: verification.businessName,
          ),
          AppSpacing.verticalMd,


          _InfoRow(
            label: 'Document Type',
            value: _formatDocumentType(verification.documentType),
          ),
          AppSpacing.verticalMd,


          _InfoRow(
            label: 'Submitted',
            value: verification.createdAt != null
                ? DateFormat('MMM d, yyyy').format(verification.createdAt!)
                : 'Unknown',
          ),
          AppSpacing.verticalMd,


          _InfoRow(
            label: 'Reviewed',
            value: _reviewedDisplayValue(verification),
            valueColor: _reviewedDisplayColor(verification),
          ),
        ],
      ),
    );
  }

  String _formatDocumentType(VerificationDocumentType? type) {
    if (type == null) return 'Not specified';
    switch (type) {
      case VerificationDocumentType.cac:
        return 'CAC Certificate';
      case VerificationDocumentType.instagram:
        return 'Instagram Profile';
      case VerificationDocumentType.website:
        return 'Website';
    }
  }

  String _reviewedDisplayValue(HostVerification v) {
    if (v.isApproved) {
      return v.verifiedAt != null
          ? 'Approved on ${DateFormat('MMM d, yyyy').format(v.verifiedAt!)}'
          : 'Approved';
    }
    if (v.isRejected) {
      return v.verifiedAt != null
          ? 'Rejected on ${DateFormat('MMM d, yyyy').format(v.verifiedAt!)}'
          : 'Rejected';
    }
    return 'Pending';
  }

  Color _reviewedDisplayColor(HostVerification v) {
    if (v.isApproved) return AppColors.success;
    if (v.isRejected) return AppColors.error;
    return AppColors.warning;
  }
}


class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w500,
              color: valueColor ?? AppColors.textPrimary,
            ),
            textAlign: TextAlign.end,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}


class _ReviewTimeline extends StatelessWidget {
  const _ReviewTimeline({required this.verification});

  final HostVerification verification;

  @override
  Widget build(BuildContext context) {
    final steps = _buildSteps();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < steps.length; i++)
          _TimelineStep(
            step: steps[i],
            isLast: i == steps.length - 1,
          ),
      ],
    );
  }

  List<_StepData> _buildSteps() {
    final isApproved = verification.isApproved;
    final isRejected = verification.isRejected;
    final isPending = verification.isPending;

    return [

      _StepData(
        title: 'Application Submitted',
        description: 'Your verification request has been received.',
        timestamp: verification.createdAt,
        status: _StepStatus.completed,
        icon: Icons.upload_file_outlined,
      ),


      _StepData(
        title: 'Under Review',
        description: 'Our team is reviewing your documents.',
        status: isPending
            ? _StepStatus.current
            : _StepStatus.completed,
        icon: Icons.rate_review_outlined,
      ),


      _StepData(
        title: 'Decision',
        description: isApproved
            ? 'Approved — You\'re now a verified host!'
            : isRejected
                ? 'Rejected — See feedback above.'
                : 'Awaiting decision from our review team.',
        timestamp: verification.verifiedAt,
        status: isApproved
            ? _StepStatus.completed
            : isRejected
                ? _StepStatus.rejected
                : _StepStatus.pending,
        icon: isApproved
            ? Icons.check_circle_outline
            : isRejected
                ? Icons.cancel_outlined
                : Icons.hourglass_empty_rounded,
      ),
    ];
  }
}


enum _StepStatus { completed, current, pending, rejected }

class _StepData {
  const _StepData({
    required this.title,
    required this.description,
    required this.status,
    required this.icon,
    this.timestamp,
  });

  final String title;
  final String description;
  final _StepStatus status;
  final IconData icon;
  final DateTime? timestamp;
}


class _TimelineStep extends StatelessWidget {
  const _TimelineStep({
    required this.step,
    this.isLast = false,
  });

  final _StepData step;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _buildIndicatorColumn(),
          AppSpacing.horizontalBase,


          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : AppSpacing.lg,
              ),
              child: _buildContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorColumn() {
    return SizedBox(
      width: 36,
      child: Column(
        children: [
          _buildCircle(),
          if (!isLast)
            Expanded(
              child: Container(
                width: 2,
                color: step.status == _StepStatus.completed
                    ? AppColors.success
                    : step.status == _StepStatus.rejected
                        ? AppColors.error
                        : AppColors.surface,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCircle() {
    const size = 36.0;

    switch (step.status) {
      case _StepStatus.completed:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check,
            color: AppColors.success,
            size: 20,
          ),
        );

      case _StepStatus.current:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.warning.withValues(alpha: 0.5),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.warning.withValues(alpha: 0.25),
                blurRadius: 8,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(
            step.icon,
            color: AppColors.warning,
            size: 18,
          ),
        );

      case _StepStatus.rejected:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.close_rounded,
            color: AppColors.error,
            size: 20,
          ),
        );

      case _StepStatus.pending:
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.surface,
              width: 2,
            ),
          ),
          child: Icon(
            step.icon,
            color: AppColors.textTertiary,
            size: 16,
          ),
        );
    }
  }

  Widget _buildContent() {
    final titleColor = switch (step.status) {
      _StepStatus.pending => AppColors.textTertiary,
      _StepStatus.rejected => AppColors.error,
      _ => AppColors.textPrimary,
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppSpacing.sm),
          child: Text(
            step.title,
            style: AppTypography.body.copyWith(
              fontWeight: FontWeight.w600,
              color: titleColor,
            ),
          ),
        ),
        AppSpacing.verticalXs,
        Text(
          step.description,
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
        ),
        if (step.timestamp != null) ...[
          AppSpacing.verticalXs,
          Text(
            DateFormat('MMM d, yyyy \u2022 h:mm a').format(step.timestamp!),
            style: AppTypography.micro.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ],
    );
  }
}


class _ActionButtons extends StatelessWidget {
  const _ActionButtons({required this.verification});

  final HostVerification verification;

  @override
  Widget build(BuildContext context) {
    if (verification.isApproved) {
      return Column(
        children: [
          MobGradientButton(
            label: 'Create Your First Event',
            icon: Icons.add_circle_outline,
            onPressed: () async {
              await context.read<AuthCubit>().refreshUser();
              if (context.mounted) {
                context.push(RoutePaths.post);
              }
            },
          ),
          AppSpacing.verticalMd,
          MobTextButton(
            label: 'View Profile',
            onPressed: () => context.go(RoutePaths.profile),
          ),
        ],
      );
    }

    if (verification.isRejected) {
      return Column(
        children: [
          MobGradientButton(
            label: 'Submit New Application',
            onPressed: () =>
                context.pushReplacement(RoutePaths.hostVerification),
          ),
          AppSpacing.verticalMd,
          MobOutlinedButton(
            label: 'Contact Support',
            icon: Icons.mail_outline_rounded,
            onPressed: () => _launchSupport(),
          ),
        ],
      );
    }


    return Column(
      children: [
        MobOutlinedButton(
          label: 'Contact Support',
          icon: Icons.mail_outline_rounded,
          onPressed: () => _launchSupport(),
        ),
      ],
    );
  }

  Future<void> _launchSupport() async {
    final uri = Uri.parse(
      'mailto:support@getmob.app?subject=Host Verification Help',
    );
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}


class _StatusShimmer extends StatelessWidget {
  const _StatusShimmer();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.card,
      highlightColor: AppColors.elevated,
      child: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [
            AppSpacing.verticalXl,


            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.card,
                shape: BoxShape.circle,
              ),
            ),
            AppSpacing.verticalBase,


            Container(
              width: 180,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
            ),
            AppSpacing.verticalSm,


            Container(
              width: 260,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
            ),
            AppSpacing.verticalXxl,


            Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
              ),
            ),
            AppSpacing.verticalXl,


            ...List.generate(3, (index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: AppColors.card,
                        shape: BoxShape.circle,
                      ),
                    ),
                    AppSpacing.horizontalBase,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 140,
                            height: 16,
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusSm),
                            ),
                          ),
                          AppSpacing.verticalSm,
                          Container(
                            width: 200,
                            height: 12,
                            decoration: BoxDecoration(
                              color: AppColors.card,
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
            }),
          ],
        ),
      ),
    );
  }
}
