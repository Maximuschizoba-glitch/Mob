import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../core/connectivity/connectivity_cubit.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';


class OfflineBanner extends StatefulWidget {
  const OfflineBanner({super.key});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _sizeAnimation;


  bool _wasOffline = false;


  bool _showingReconnected = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _sizeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onConnectivityChanged(bool isOnline) {
    if (!isOnline) {

      _wasOffline = true;
      if (_showingReconnected) {
        setState(() => _showingReconnected = false);
      }
      _controller.forward();
    } else if (_wasOffline) {

      _wasOffline = false;
      setState(() => _showingReconnected = true);

      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          _controller.reverse().then((_) {
            if (mounted) {
              setState(() => _showingReconnected = false);
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ConnectivityCubit, bool>(
      listener: (context, isOnline) => _onConnectivityChanged(isOnline),
      child: SizeTransition(
        sizeFactor: _sizeAnimation,
        axisAlignment: -1.0,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: _showingReconnected
              ? AppColors.success
              : AppColors.error.withValues(alpha: 0.9),
          child: SafeArea(
            bottom: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _showingReconnected
                      ? Icons.wifi_rounded
                      : Icons.wifi_off_rounded,
                  color: AppColors.textPrimary,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  _showingReconnected
                      ? 'Back online'
                      : 'No internet connection',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
