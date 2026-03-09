import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/widgets/mob_gradient_button.dart';
import '../../../../shared/widgets/mob_text_button.dart';
import '../bloc/auth_cubit.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;


  static const List<_OnboardingSlide> _slides = [
    _OnboardingSlide(
      icon: Icons.explore,
      color: AppColors.cyan,
      title: 'Discover What\u2019s\nHappening Now',
      body:
          'Find events, hangouts, and vibes happening around you in real time. Never miss out.',
    ),
    _OnboardingSlide(
      icon: Icons.local_fire_department,
      color: AppColors.purple,
      title: 'Real Vibes,\nReal Crowds',
      body:
          'See live crowd levels, vibe scores, and snaps from people actually there right now.',
    ),
    _OnboardingSlide(
      icon: Icons.camera_alt,
      color: AppColors.magenta,
      title: 'Share What\u2019s\nPopping',
      body:
          'Snap what\u2019s happening and share with the city. Your snaps help others discover the vibe.',
    ),
  ];

  bool get _isLastPage => _currentPage == _slides.length - 1;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }


  void _onNext() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _onSkipOrGetStarted() async {
    final storage = context.read<StorageService>();
    await storage.setOnboardingComplete();
    if (mounted) context.go(RoutePaths.welcome);
  }

  Future<void> _onBrowseAsGuest() async {
    final storage = context.read<StorageService>();
    await storage.setOnboardingComplete();
    if (mounted) {
      await context.read<AuthCubit>().continueAsGuest();
    }
    if (mounted) context.go(RoutePaths.feed);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [

            _buildSkipBar(),


            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _slides.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) =>
                    _buildSlide(_slides[index]),
              ),
            ),


            _buildDots(),

            AppSpacing.verticalXl,


            _buildBottomButtons(),

            AppSpacing.verticalXxl,
          ],
        ),
      ),
    );
  }


  Widget _buildSkipBar() {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.base,
        right: AppSpacing.lg,
        left: AppSpacing.lg,
      ),
      child: Align(
        alignment: Alignment.centerRight,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _isLastPage ? 0.0 : 1.0,
          child: IgnorePointer(
            ignoring: _isLastPage,
            child: MobTextButton(
              label: 'Skip',
              color: AppColors.textSecondary,
              onPressed: _onSkipOrGetStarted,
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildSlide(_OnboardingSlide slide) {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [

          Expanded(
            flex: 55,
            child: Center(
              child: _buildIllustration(slide),
            ),
          ),


          Expanded(
            flex: 45,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  AppSpacing.verticalLg,


                  Text(
                    slide.title,
                    style: AppTypography.h1,
                    textAlign: TextAlign.center,
                  ),

                  AppSpacing.verticalMd,


                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 300),
                    child: Text(
                      slide.body,
                      style: AppTypography.body.copyWith(
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
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


  Widget _buildIllustration(_OnboardingSlide slide) {
    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [

          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  slide.color.withValues(alpha: 0.25),
                  slide.color.withValues(alpha: 0.0),
                ],
              ),
            ),
          ),


          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: slide.color.withValues(alpha: 0.15),
              border: Border.all(
                color: slide.color.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            alignment: Alignment.center,
            child: Icon(
              slide.icon,
              size: 52,
              color: slide.color,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_slides.length, (index) {
        final isActive = index == _currentPage;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: isActive ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isActive ? AppColors.cyan : AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
          ),
        );
      }),
    );
  }


  Widget _buildBottomButtons() {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        children: [

          MobGradientButton(
            label: _isLastPage ? 'Get Started' : 'Next',
            onPressed: _isLastPage ? _onSkipOrGetStarted : _onNext,
          ),


          if (_isLastPage) ...[
            AppSpacing.verticalBase,
            MobTextButton(
              label: 'Browse as Guest',
              color: AppColors.textSecondary,
              onPressed: _onBrowseAsGuest,
            ),
          ],
        ],
      ),
    );
  }
}


class _OnboardingSlide {
  const _OnboardingSlide({
    required this.icon,
    required this.color,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String body;
}
