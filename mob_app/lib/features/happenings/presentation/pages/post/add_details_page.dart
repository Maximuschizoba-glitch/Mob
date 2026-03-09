import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../shared/models/enums.dart';
import '../../../../../shared/widgets/mob_bottom_sheet.dart';
import '../../../../../shared/widgets/mob_gradient_button.dart';
import '../../../../../shared/widgets/mob_text_button.dart';
import '../../../../../shared/widgets/mob_text_field.dart';
import '../../bloc/post_happening_cubit.dart';
import '../../bloc/post_happening_state.dart';


class AddDetailsPage extends StatefulWidget {
  const AddDetailsPage({super.key});

  @override
  State<AddDetailsPage> createState() => _AddDetailsPageState();
}

class _AddDetailsPageState extends State<AddDetailsPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _quantityController;

  @override
  void initState() {
    super.initState();
    final state = context.read<PostHappeningCubit>().state;
    _titleController = TextEditingController(text: state.title ?? '');
    _descriptionController =
        TextEditingController(text: state.description ?? '');
    _priceController = TextEditingController(
      text: state.ticketPrice != null
          ? NumberFormat('#,###').format(state.ticketPrice!.toInt())
          : '',
    );
    _quantityController = TextEditingController(
      text: state.ticketQuantity != null
          ? state.ticketQuantity.toString()
          : '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostHappeningCubit, PostHappeningState>(
      builder: (context, state) {
        return Column(
          children: [
            _buildAppBar(context),
            _buildProgressBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppSpacing.verticalXl,
                    _buildHeading(state),
                    AppSpacing.verticalXl,
                    _buildHappeningNowToggle(context, state),
                    AppSpacing.verticalLg,
                    _buildTitleField(state),
                    AppSpacing.verticalLg,
                    _buildCategorySelector(context, state),
                    if (!state.isHappeningNow) ...[
                      AppSpacing.verticalLg,
                      _buildDateTimeSection(context, state),
                    ],
                    AppSpacing.verticalLg,
                    _buildDescriptionField(state),
                    if (state.isEvent) ...[
                      AppSpacing.verticalLg,
                      _buildTicketingSection(context, state),
                    ],

                    if (state.error != null) ...[
                      AppSpacing.verticalLg,
                      _buildErrorMessage(state.error!),
                    ],
                    AppSpacing.verticalXxl,
                  ],
                ),
              ),
            ),
            _buildBottomBar(context, state),
          ],
        );
      },
    );
  }


  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              final cubit = context.read<PostHappeningCubit>();
              cubit.previousStep();
            },
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.elevated,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Add Details',
              style: AppTypography.h4,
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            'Step 2 of 4',
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: SizedBox(
          height: 4,
          child: Stack(
            children: [
              Container(color: AppColors.card),
              FractionallySizedBox(
                widthFactor: 0.50,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildHeading(PostHappeningState state) {
    final typeLabel =
        state.isEvent ? 'official event' : 'casual happening';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fill in the details',
          style: AppTypography.h1,
        ),
        AppSpacing.verticalSm,
        Text(
          'Tell people about your $typeLabel.',
          style: AppTypography.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }


  Widget _buildHappeningNowToggle(
    BuildContext context,
    PostHappeningState state,
  ) {
    return Container(
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(
          color: state.isHappeningNow ? AppColors.cyan : AppColors.surface,
          width: state.isHappeningNow ? 1.0 : 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.cyan.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.bolt,
              color: AppColors.cyan,
              size: 22,
            ),
          ),
          AppSpacing.horizontalMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Happening Now?',
                  style: AppTypography.body.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'Skip date & time \u2014 post goes live immediately',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: state.isHappeningNow,
            onChanged: (value) {
              context.read<PostHappeningCubit>().setDetails(
                    isHappeningNow: value,
                  );
            },
            activeThumbColor: AppColors.cyan,
            activeTrackColor: AppColors.cyan.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.textTertiary,
            inactiveTrackColor: AppColors.surface,
          ),
        ],
      ),
    );
  }


  Widget _buildTitleField(PostHappeningState state) {
    return MobTextField(
      label: 'Event Title',
      hint: "What's the move?",
      controller: _titleController,
      maxLength: 100,
      textInputAction: TextInputAction.next,

      onChanged: (_) => setState(() {}),
    );
  }


  Widget _buildCategorySelector(
    BuildContext context,
    PostHappeningState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'CATEGORY',
          style: AppTypography.overline.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
            fontSize: 11,
          ),
        ),
        AppSpacing.verticalSm,
        GestureDetector(
          onTap: () => _showCategorySheet(context, state),
          child: Container(
            width: double.infinity,
            height: AppSpacing.inputHeight,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
            decoration: BoxDecoration(
              color: AppColors.elevated,
              borderRadius: AppSpacing.inputRadius,
              border: Border.all(color: AppColors.surface, width: 0.5),
            ),
            child: Row(
              children: [
                Expanded(
                  child: state.category != null
                      ? Text(
                          '${state.category!.emoji}  ${state.category!.displayName}',
                          style: AppTypography.body.copyWith(
                            color: AppColors.textPrimary,
                          ),
                        )
                      : Text(
                          'Select a category',
                          style: AppTypography.body.copyWith(
                            color: AppColors.textTertiary,
                          ),
                        ),
                ),
                const Icon(
                  Icons.keyboard_arrow_down,
                  color: AppColors.textTertiary,
                  size: 24,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showCategorySheet(BuildContext pageContext, PostHappeningState state) {
    final cubit = pageContext.read<PostHappeningCubit>();
    MobBottomSheet.showWithTitle(
      pageContext,
      title: 'Select Category',
      onClose: () => Navigator.of(pageContext).pop(),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: HappeningCategory.values.length,
        separatorBuilder: (_, __) => const Divider(
          color: AppColors.surface,
          height: 1,
        ),
        itemBuilder: (context, index) {
          final category = HappeningCategory.values[index];
          final isSelected = state.category == category;
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: category.color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                category.emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            title: Text(
              category.displayName,
              style: AppTypography.body.copyWith(
                color: isSelected ? AppColors.cyan : AppColors.textPrimary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            trailing: isSelected
                ? const Icon(Icons.check_circle, color: AppColors.cyan, size: 22)
                : null,
            onTap: () {
              cubit.setDetails(category: category);
              Navigator.of(context).pop();
            },
          );
        },
      ),
    );
  }


  Widget _buildDateTimeSection(
    BuildContext context,
    PostHappeningState state,
  ) {
    final dateFormat = DateFormat('EEE, MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'DATE & TIME',
          style: AppTypography.overline.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
            fontSize: 11,
          ),
        ),
        AppSpacing.verticalSm,

        Row(
          children: [
            Expanded(
              child: _DateTimePickerField(
                icon: Icons.calendar_today,
                label: state.startsAt != null
                    ? dateFormat.format(state.startsAt!)
                    : 'Start date',
                hasValue: state.startsAt != null,
                onTap: () => _pickStartDate(context, state),
              ),
            ),
            AppSpacing.horizontalMd,
            Expanded(
              child: _DateTimePickerField(
                icon: Icons.access_time,
                label: state.startsAt != null
                    ? timeFormat.format(state.startsAt!)
                    : 'Start time',
                hasValue: state.startsAt != null,
                onTap: () => _pickStartTime(context, state),
              ),
            ),
          ],
        ),
        AppSpacing.verticalMd,

        Row(
          children: [
            Expanded(
              child: _DateTimePickerField(
                icon: Icons.calendar_today,
                label: state.endsAt != null
                    ? dateFormat.format(state.endsAt!)
                    : 'End date (optional)',
                hasValue: state.endsAt != null,
                onTap: () => _pickEndDate(context, state),
              ),
            ),
            AppSpacing.horizontalMd,
            Expanded(
              child: _DateTimePickerField(
                icon: Icons.access_time,
                label: state.endsAt != null
                    ? timeFormat.format(state.endsAt!)
                    : 'End time',
                hasValue: state.endsAt != null,
                onTap: () => _pickEndTime(context, state),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _pickStartDate(
    BuildContext context,
    PostHappeningState state,
  ) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: state.startsAt ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: _datePickerTheme,
    );
    if (picked != null && context.mounted) {
      final existing = state.startsAt ?? now;
      final combined = DateTime(
        picked.year,
        picked.month,
        picked.day,
        existing.hour,
        existing.minute,
      );
      context.read<PostHappeningCubit>().setDetails(startsAt: combined);
    }
  }

  Future<void> _pickStartTime(
    BuildContext context,
    PostHappeningState state,
  ) async {
    final now = DateTime.now();
    final initial = state.startsAt ?? now;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: _datePickerTheme,
    );
    if (picked != null && context.mounted) {
      final date = state.startsAt ?? now;
      final combined = DateTime(
        date.year,
        date.month,
        date.day,
        picked.hour,
        picked.minute,
      );
      context.read<PostHappeningCubit>().setDetails(startsAt: combined);
    }
  }

  Future<void> _pickEndDate(
    BuildContext context,
    PostHappeningState state,
  ) async {
    final now = DateTime.now();
    final firstDate = state.startsAt ?? now;
    final picked = await showDatePicker(
      context: context,
      initialDate: state.endsAt ?? firstDate,
      firstDate: firstDate,
      lastDate: firstDate.add(const Duration(days: 365)),
      builder: _datePickerTheme,
    );
    if (picked != null && context.mounted) {
      final existing = state.endsAt ?? firstDate;
      final combined = DateTime(
        picked.year,
        picked.month,
        picked.day,
        existing.hour,
        existing.minute,
      );
      context.read<PostHappeningCubit>().setDetails(endsAt: combined);
    }
  }

  Future<void> _pickEndTime(
    BuildContext context,
    PostHappeningState state,
  ) async {
    final now = DateTime.now();
    final initial = state.endsAt ?? state.startsAt ?? now;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
      builder: _datePickerTheme,
    );
    if (picked != null && context.mounted) {
      final date = state.endsAt ?? state.startsAt ?? now;
      final combined = DateTime(
        date.year,
        date.month,
        date.day,
        picked.hour,
        picked.minute,
      );
      context.read<PostHappeningCubit>().setDetails(endsAt: combined);
    }
  }

  Widget _datePickerTheme(BuildContext context, Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.dark(
          primary: AppColors.cyan,
          onPrimary: AppColors.background,
          surface: AppColors.card,
          onSurface: AppColors.textPrimary,
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: AppColors.card,
        ),
      ),
      child: child!,
    );
  }


  Widget _buildDescriptionField(PostHappeningState state) {
    return MobTextField(
      label: 'Description',
      hint: 'What should people know?',
      controller: _descriptionController,
      maxLength: 500,
      maxLines: 5,
      textInputAction: TextInputAction.newline,
      keyboardType: TextInputType.multiline,

      onChanged: (_) => setState(() {}),
    );
  }


  Widget _buildTicketingSection(
    BuildContext context,
    PostHappeningState state,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Container(
          padding: AppSpacing.cardPadding,
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: AppSpacing.cardRadius,
            border: Border.all(
              color:
                  state.isTicketed ? AppColors.purple : AppColors.surface,
              width: state.isTicketed ? 1.0 : 0.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.confirmation_number_outlined,
                  color: AppColors.purple,
                  size: 22,
                ),
              ),
              AppSpacing.horizontalMd,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Sell Tickets',
                      style: AppTypography.body.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Set a price and quantity for your event',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: state.isTicketed,
                onChanged: (value) {
                  context.read<PostHappeningCubit>().setTicketing(
                        isTicketed: value,
                      );
                },
                activeThumbColor: AppColors.purple,
                activeTrackColor: AppColors.purple.withValues(alpha: 0.3),
                inactiveThumbColor: AppColors.textTertiary,
                inactiveTrackColor: AppColors.surface,
              ),
            ],
          ),
        ),

        if (state.isTicketed) ...[
          AppSpacing.verticalMd,
          Row(
            children: [
              Expanded(
                child: MobTextField(
                  label: 'Ticket Price',
                  hint: 'e.g. 5,000',
                  keyboardType: TextInputType.number,
                  controller: _priceController,
                  prefixText: '\u20A6 ',
                  inputFormatters: [
                    ThousandSeparatorFormatter(),
                  ],
                ),
              ),
              AppSpacing.horizontalMd,
              Expanded(
                child: MobTextField(
                  label: 'Quantity',
                  hint: 'e.g. 100',
                  keyboardType: TextInputType.number,
                  controller: _quantityController,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }


  Widget _buildErrorMessage(String message) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPaddingCompact,
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          AppSpacing.horizontalSm,
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBottomBar(BuildContext context, PostHappeningState state) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(color: AppColors.surface, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MobGradientButton(
            label: 'Continue',
            onPressed: () {
              _syncFieldsToCubit();
              final cubit = context.read<PostHappeningCubit>();
              cubit.nextStep();
            },
          ),
          AppSpacing.verticalSm,
          MobTextButton(
            label: '\u2190 Previous Step',
            onPressed: () {
              context.read<PostHappeningCubit>().previousStep();
            },
          ),
        ],
      ),
    );
  }


  void _syncFieldsToCubit() {
    final cubit = context.read<PostHappeningCubit>();
    cubit.setDetails(
      title: _titleController.text,
      description: _descriptionController.text,
    );

    final rawPrice = ThousandSeparatorFormatter.rawValue(_priceController.text);
    final price = double.tryParse(rawPrice);
    final quantity = int.tryParse(_quantityController.text);
    cubit.setTicketing(
      ticketPrice: price,
      ticketQuantity: quantity,
    );
  }
}


class _DateTimePickerField extends StatelessWidget {
  const _DateTimePickerField({
    required this.icon,
    required this.label,
    required this.hasValue,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool hasValue;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: AppSpacing.inputHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.elevated,
          borderRadius: AppSpacing.inputRadius,
          border: Border.all(color: AppColors.surface, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: hasValue ? AppColors.cyan : AppColors.textTertiary,
              size: 18,
            ),
            AppSpacing.horizontalSm,
            Expanded(
              child: Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: hasValue
                      ? AppColors.textPrimary
                      : AppColors.textTertiary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
