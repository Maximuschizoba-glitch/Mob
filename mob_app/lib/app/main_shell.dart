import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_typography.dart';
import '../core/constants/route_paths.dart';
import '../core/services/tab_refresh.dart';
import '../core/utils/auth_guard.dart';
import '../shared/widgets/bottom_nav_bar.dart';
import '../shared/widgets/offline_banner.dart';


class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.navigationShell,
  });


  final StatefulNavigationShell navigationShell;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {

  DateTime? _lastBackPressTime;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBackPress(context);
      },
      child: Scaffold(
        body: Column(
          children: [
            const OfflineBanner(),
            Expanded(child: widget.navigationShell),
          ],
        ),
        bottomNavigationBar: MobBottomNavBar(
          currentIndex: widget.navigationShell.currentIndex,
          onTap: _onTabTap,
          onPostTap: () => _onPostTap(context),
        ),
      ),
    );
  }


  void _handleBackPress(BuildContext context) {
    final now = DateTime.now();

    if (_lastBackPressTime != null &&
        now.difference(_lastBackPressTime!) < const Duration(seconds: 2)) {

      Navigator.of(context).pop();
      return;
    }

    _lastBackPressTime = now;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Press back again to exit',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          backgroundColor: AppColors.elevated,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }


  void _onTabTap(int index) {
    final previousIndex = widget.navigationShell.currentIndex;


    if (index != previousIndex) {
      if (index == 0) feedTabActiveNotifier.value++;
      if (index == 1) mapTabActiveNotifier.value++;
    }

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == previousIndex,
    );
  }


  void _onPostTap(BuildContext context) {
    if (!requireAuth(context, action: 'post happenings')) return;
    context.push(RoutePaths.post);
  }
}
