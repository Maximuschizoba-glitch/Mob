import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/widgets/mob_gradient_button.dart';
import '../../../../shared/widgets/mob_text_button.dart';


class CategorySelectionScreen extends StatefulWidget {
  const CategorySelectionScreen({super.key});

  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {

  final Set<String> _selected = {};


  static const int _minRequired = 2;


  static const List<_CategoryItem> _categories = [
    _CategoryItem(
      key: 'party_nightlife',
      emoji: '🎉',
      name: 'Party / Nightlife',
      tagline: 'Clubs, bars & raves',
      color: AppColors.categoryParty,
    ),
    _CategoryItem(
      key: 'food_drinks',
      emoji: '🍔',
      name: 'Food & Drinks',
      tagline: 'Restaurants & street food',
      color: AppColors.categoryFood,
    ),
    _CategoryItem(
      key: 'hangouts_social',
      emoji: '🤝',
      name: 'Hangouts / Social',
      tagline: 'Casual meetups & chills',
      color: AppColors.categoryHangouts,
    ),
    _CategoryItem(
      key: 'music_performance',
      emoji: '🎵',
      name: 'Music & Performance',
      tagline: 'Live shows & concerts',
      color: AppColors.categoryMusic,
    ),
    _CategoryItem(
      key: 'games_activities',
      emoji: '🎮',
      name: 'Games & Activities',
      tagline: 'Sports, games & fun',
      color: AppColors.categoryGames,
    ),
    _CategoryItem(
      key: 'art_culture',
      emoji: '🎨',
      name: 'Art & Culture',
      tagline: 'Galleries, exhibits & more',
      color: AppColors.categoryArt,
    ),
    _CategoryItem(
      key: 'study_work',
      emoji: '📚',
      name: 'Study / Work Spots',
      tagline: 'Cafes & coworking',
      color: AppColors.categoryStudy,
    ),
    _CategoryItem(
      key: 'popups_street',
      emoji: '🔥',
      name: 'Pop-Ups & Street',
      tagline: 'Markets, stalls & vendors',
      color: AppColors.categoryPopups,
    ),
  ];

  bool get _canContinue => _selected.length >= _minRequired;


  void _toggle(String key) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_selected.contains(key)) {
        _selected.remove(key);
      } else {
        _selected.add(key);
      }
    });
  }

  Future<void> _onContinue() async {
    if (!_canContinue) return;


    final storage = context.read<StorageService>();
    await storage.saveSelectedCategories(_selected.toList());

    if (mounted) context.go(RoutePaths.feed);
  }

  void _onSkip() {
    context.go(RoutePaths.feed);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [

            Expanded(
              child: SingleChildScrollView(
                padding: AppSpacing.screenPadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.xxxl),


                    const Text(
                      'What are you into?',
                      style: AppTypography.h1,
                    ),

                    AppSpacing.verticalXs,


                    Text(
                      'Pick at least $_minRequired to get started',
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),

                    AppSpacing.verticalXxl,


                    GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      childAspectRatio: 1.45,
                      children: _categories.map((cat) {
                        final isSelected = _selected.contains(cat.key);
                        return _CategoryCard(
                          item: cat,
                          isSelected: isSelected,
                          onTap: () => _toggle(cat.key),
                        );
                      }).toList(),
                    ),

                    AppSpacing.verticalBase,


                    _buildSelectionIndicator(),

                    AppSpacing.verticalXl,
                  ],
                ),
              ),
            ),


            _buildBottomSection(),
          ],
        ),
      ),
    );
  }


  Widget _buildSelectionIndicator() {
    return Center(
      child: Column(
        children: [
          Text(
            '${_selected.length} of ${_categories.length} selected',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.cyan,
            ),
          ),
          AppSpacing.verticalSm,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_categories.length, (index) {
              final isFilled = index < _selected.length;
              return Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFilled ? AppColors.cyan : AppColors.surface,
                ),
              );
            }),
          ),
        ],
      ),
    );
  }


  Widget _buildBottomSection() {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppSpacing.lg,
        right: AppSpacing.lg,
        bottom: AppSpacing.xxl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            opacity: _canContinue ? 1.0 : 0.5,
            child: MobGradientButton(
              label: 'Continue \u2192',
              onPressed: _canContinue ? _onContinue : null,
            ),
          ),
          AppSpacing.verticalMd,
          MobTextButton(
            label: 'Skip for now',
            color: AppColors.textTertiary,
            onPressed: _onSkip,
          ),
        ],
      ),
    );
  }
}


class _CategoryItem {
  const _CategoryItem({
    required this.key,
    required this.emoji,
    required this.name,
    required this.tagline,
    required this.color,
  });


  final String key;


  final String emoji;


  final String name;


  final String tagline;


  final Color color;
}


class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  final _CategoryItem item;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.cyan.withValues(alpha: 0.05)
              : AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: isSelected ? AppColors.cyan : AppColors.border,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Stack(
          children: [

            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [

                  Text(
                    item.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  AppSpacing.verticalSm,


                  Text(
                    item.name,
                    style: AppTypography.buttonSmall,
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  AppSpacing.verticalXs,


                  Text(
                    item.tagline,
                    style: AppTypography.overline.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 0,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),


            Positioned(
              top: 8,
              right: 8,
              child: AnimatedScale(
                scale: isSelected ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOutBack,
                child: Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cyan,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.check,
                    size: 12,
                    color: AppColors.background,
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
