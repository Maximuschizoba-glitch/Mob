import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../core/services/location_service.dart';
import '../../../../shared/widgets/mob_gradient_button.dart';
import '../../../../shared/widgets/mob_outlined_button.dart';


class LocationPermissionScreen extends StatefulWidget {
  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() =>
      _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen>
    with SingleTickerProviderStateMixin {
  final _locationService = LocationService();
  bool _isRequesting = false;


  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }


  Future<void> _onAllowLocation() async {
    setState(() => _isRequesting = true);

    final granted = await _locationService.requestPermission();

    if (!mounted) return;

    if (granted) {

      _locationService.getCurrentPosition();
      _navigateNext();
    } else {

      final permanentlyDenied = await _locationService.isPermanentlyDenied();
      if (permanentlyDenied && mounted) {
        await _locationService.openSettings();
      }
      if (mounted) setState(() => _isRequesting = false);
    }
  }

  void _onNotNow() {
    _navigateNext();
  }

  void _navigateNext() {

    context.go(RoutePaths.categorySelection);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [

            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: AppSpacing.screenPadding,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [

                      _buildRadarVisual(),

                      AppSpacing.verticalXl,


                      const Text(
                        'Discover What\u2019s\nAround You',
                        style: AppTypography.h2,
                        textAlign: TextAlign.center,
                      ),

                      AppSpacing.verticalSm,


                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 300),
                        child: Text(
                          'Mob uses your location to show happenings, events, and vibes near you in real time.',
                          style: AppTypography.body.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                      AppSpacing.verticalBase,


                      _buildPrivacyBadge(),
                    ],
                  ),
                ),
              ),
            ),


            Padding(
              padding: const EdgeInsets.only(
                left: AppSpacing.lg,
                right: AppSpacing.lg,
                bottom: AppSpacing.xxxl,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [

                  MobGradientButton(
                    label: 'Allow Location',
                    isLoading: _isRequesting,
                    onPressed: _isRequesting ? null : _onAllowLocation,
                  ),

                  AppSpacing.verticalMd,


                  MobOutlinedButton(
                    label: 'Not Now',
                    onPressed: _onNotNow,
                  ),

                  AppSpacing.verticalMd,


                  Text(
                    'You can change this in Settings anytime',
                    style: AppTypography.overline.copyWith(
                      color: AppColors.textTertiary,
                      letterSpacing: 0,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildRadarVisual() {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        final scale = _pulseAnimation.value;
        return SizedBox(
          width: 140,
          height: 140,
          child: Stack(
            alignment: Alignment.center,
            children: [

              Transform.scale(
                scale: scale,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cyan.withValues(alpha: 0.08),
                  ),
                ),
              ),


              Transform.scale(
                scale: 0.95 + (scale - 0.85) * 0.5,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cyan.withValues(alpha: 0.12),
                  ),
                ),
              ),


              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.cyan.withValues(alpha: 0.18),
                ),
              ),


              const Icon(
                Icons.location_on,
                size: 32,
                color: AppColors.cyan,
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildPrivacyBadge() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(
          color: AppColors.success.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.shield_outlined,
            size: 16,
            color: AppColors.success,
          ),
          AppSpacing.horizontalSm,
          Text(
            'Your location is never shared publicly',
            style: AppTypography.caption.copyWith(
              color: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}
