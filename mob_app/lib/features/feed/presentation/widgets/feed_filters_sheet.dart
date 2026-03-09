import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/models/enums.dart';
import '../../../../shared/widgets/mob_bottom_sheet.dart';
import '../../../../shared/widgets/mob_chip.dart';
import '../../../../shared/widgets/mob_gradient_button.dart';
import '../../../../shared/widgets/mob_section_label.dart';
import '../bloc/feed_cubit.dart';


class FeedFiltersSheet extends StatefulWidget {
  const FeedFiltersSheet({super.key});


  static Future<void> show(BuildContext context) {
    return MobBottomSheet.show(
      context,
      maxHeight: 0.85,
      child: const FeedFiltersSheet(),
    );
  }

  @override
  State<FeedFiltersSheet> createState() => _FeedFiltersSheetState();
}


enum _TimeFilter {
  tonight,
  thisWeekend,
  happeningNow,
  custom;

  String get label {
    switch (this) {
      case _TimeFilter.tonight:
        return 'Tonight';
      case _TimeFilter.thisWeekend:
        return 'This Weekend';
      case _TimeFilter.happeningNow:
        return 'Happening Now';
      case _TimeFilter.custom:
        return 'Custom';
    }
  }

  IconData get icon {
    switch (this) {
      case _TimeFilter.tonight:
        return Icons.dark_mode_outlined;
      case _TimeFilter.thisWeekend:
        return Icons.calendar_today_outlined;
      case _TimeFilter.happeningNow:
        return Icons.sensors_rounded;
      case _TimeFilter.custom:
        return Icons.access_time_outlined;
    }
  }
}

class _FeedFiltersSheetState extends State<FeedFiltersSheet> {


  String? _selectedCategory;
  _TimeFilter? _selectedTime;
  double _distanceKm = 10.0;
  final Set<ActivityLevel> _selectedVibes = {};


  static const double _minDistance = 0.5;
  static const double _maxDistance = 25.0;

  @override
  void initState() {
    super.initState();

    final cubit = context.read<FeedCubit>();
    _selectedCategory = cubit.activeCategory;
    _distanceKm = cubit.radiusKm;
  }


  bool get _hasActiveFilters =>
      _selectedCategory != null ||
      _selectedTime != null ||
      _distanceKm != 10.0 ||
      _selectedVibes.isNotEmpty;

  void _resetFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedTime = null;
      _distanceKm = 10.0;
      _selectedVibes.clear();
    });
  }

  void _applyFilters() {
    final cubit = context.read<FeedCubit>();


    if (cubit.activeCategory != _selectedCategory) {
      cubit.filterByCategory(_selectedCategory);
    }


    if (cubit.radiusKm != _distanceKm) {
      cubit.updateRadius(_distanceKm);
    }


    Navigator.of(context).pop();
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          _buildHeader(),

          const SizedBox(height: AppSpacing.xl),


          _buildCategorySection(),

          const SizedBox(height: AppSpacing.lg),


          _buildTimeSection(),

          const SizedBox(height: AppSpacing.lg),


          _buildDistanceSection(),

          const SizedBox(height: AppSpacing.lg),


          _buildCrowdVibeSection(),

          const SizedBox(height: AppSpacing.xxl),


          MobGradientButton(
            label: 'APPLY FILTERS \u26A1',
            onPressed: _applyFilters,
          ),

          const SizedBox(height: AppSpacing.base),
        ],
      ),
    );
  }


  Widget _buildHeader() {
    return Row(
      children: [
        const Text(
          'Filters',
          style: AppTypography.h3,
        ),
        const Spacer(),
        if (_hasActiveFilters)
          GestureDetector(
            onTap: _resetFilters,
            child: Text(
              'Reset',
              style: AppTypography.buttonSmall.copyWith(
                color: AppColors.cyan,
              ),
            ),
          ),
      ],
    );
  }


  Widget _buildCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MobSectionLabel(label: 'Category'),
        const SizedBox(height: AppSpacing.md),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [

            MobChip(
              label: 'All',
              isActive: _selectedCategory == null,
              onTap: () => setState(() => _selectedCategory = null),
            ),

            ...HappeningCategory.values.map((cat) {
              return MobChip(
                label: '${cat.emoji} ${cat.displayName}',
                isActive: _selectedCategory == cat.value,
                activeColor: cat.color,
                onTap: () {
                  setState(() {
                    _selectedCategory =
                        _selectedCategory == cat.value ? null : cat.value;
                  });
                },
              );
            }),
          ],
        ),
      ],
    );
  }


  Widget _buildTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MobSectionLabel(label: 'Time'),
        const SizedBox(height: AppSpacing.md),
        GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: AppSpacing.sm,
          mainAxisSpacing: AppSpacing.sm,
          childAspectRatio: _timeCardAspectRatio,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          children: _TimeFilter.values.map((filter) {
            final isActive = _selectedTime == filter;
            return _buildTimeCard(filter, isActive);
          }).toList(),
        ),
      ],
    );
  }


  double get _timeCardAspectRatio {


    final availableWidth =
        (MediaQuery.of(context).size.width - 40 - AppSpacing.sm) / 2;
    return availableWidth / 44;
  }

  Widget _buildTimeCard(_TimeFilter filter, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTime = _selectedTime == filter ? null : filter;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.cyan.withValues(alpha: 0.1)
              : AppColors.elevated,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isActive ? AppColors.cyan : AppColors.border,
            width: isActive ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              filter.icon,
              size: 16,
              color: isActive ? AppColors.cyan : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              filter.label,
              style: AppTypography.bodySmall.copyWith(
                color: isActive ? AppColors.cyan : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildDistanceSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MobSectionLabel(label: 'Distance'),
        const SizedBox(height: AppSpacing.md),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.cyan,
            inactiveTrackColor: AppColors.elevated,
            thumbColor: AppColors.textPrimary,
            thumbShape:
                const RoundSliderThumbShape(enabledThumbRadius: 10),
            trackHeight: 4,
            overlayColor: AppColors.cyan.withValues(alpha: 0.15),
            overlayShape:
                const RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Slider(
            value: _distanceKm,
            min: _minDistance,
            max: _maxDistance,
            onChanged: (value) => setState(() => _distanceKm = value),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
          child: Row(
            children: [
              const Text(
                '${_minDistance}km',
                style: AppTypography.caption,
              ),
              const Spacer(),
              Text(
                '${_distanceKm.toStringAsFixed(_distanceKm % 1 == 0 ? 0 : 1)}km',
                style: AppTypography.buttonSmall.copyWith(
                  color: AppColors.cyan,
                ),
              ),
              const Spacer(),
              Text(
                '${_maxDistance.round()}km',
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildCrowdVibeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const MobSectionLabel(label: 'Crowd Vibe'),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            _buildVibePill(
              label: '\u{1F60C} Chill',
              level: ActivityLevel.low,
            ),
            const SizedBox(width: AppSpacing.sm),
            _buildVibePill(
              label: '\u{1F525} Lively',
              level: ActivityLevel.medium,
            ),
            const SizedBox(width: AppSpacing.sm),
            _buildVibePill(
              label: '\u{1F92F} Packed',
              level: ActivityLevel.high,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildVibePill({
    required String label,
    required ActivityLevel level,
  }) {
    final isActive = _selectedVibes.contains(level);

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (isActive) {
              _selectedVibes.remove(level);
            } else {
              _selectedVibes.add(level);
            }
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: AppSpacing.chipHeight,
          decoration: BoxDecoration(
            color: isActive
                ? AppColors.cyan.withValues(alpha: 0.1)
                : AppColors.elevated,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            border: Border.all(
              color: isActive ? AppColors.cyan : AppColors.border,
              width: isActive ? 1.5 : 0.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: AppTypography.bodySmall.copyWith(
                color: isActive ? AppColors.cyan : AppColors.textSecondary,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
