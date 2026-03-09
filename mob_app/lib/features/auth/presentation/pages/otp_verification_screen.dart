import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../core/utils/navigation_helpers.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../widgets/otp_input.dart';


class OtpVerificationScreen extends StatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  State<OtpVerificationScreen> createState() => _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends State<OtpVerificationScreen> {
  final _otpKey = GlobalKey<OtpInputState>();

  String _otp = '';
  String _phone = '';


  static const int _timerDuration = 60;
  int _secondsRemaining = _timerDuration;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resolvePhone();
      _sendOtp();
      _startTimer();


      if (AppConfig.otpBypassEnabled) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!mounted) return;
          _otpKey.currentState?.fill(AppConfig.devOtpCode);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }


  void _resolvePhone() {
    final cubit = context.read<AuthCubit>();
    final user = cubit.currentUser;
    if (user?.phone != null && user!.phone!.isNotEmpty) {
      setState(() => _phone = user.phone!);
    }
  }


  String get _maskedPhone {
    if (_phone.length < 8) return _phone;


    final local = _phone.startsWith('+234')
        ? _phone.substring(4)
        : _phone;

    if (local.length < 7) return '+234 $local';

    final first3 = local.substring(0, 3);
    final last4 = local.substring(local.length - 4);
    return '+234 $first3 *** $last4';
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _secondsRemaining = _timerDuration;
      _canResend = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining <= 1) {
        timer.cancel();
        setState(() {
          _secondsRemaining = 0;
          _canResend = true;
        });
      } else {
        setState(() => _secondsRemaining--);
      }
    });
  }

  String get _timerText {
    final minutes = _secondsRemaining ~/ 60;
    final seconds = _secondsRemaining % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }


  void _sendOtp() {
    if (_phone.isEmpty) return;
    context.read<AuthCubit>().sendOtp(phone: _phone);
  }

  void _onResend() {
    if (!_canResend) return;
    _otpKey.currentState?.clear();
    _otpKey.currentState?.focusFirst();
    setState(() => _otp = '');
    _sendOtp();
    _startTimer();
  }

  void _onVerify() {
    if (_otp.length != 6 || _phone.isEmpty) return;
    context.read<AuthCubit>().verifyOtp(phone: _phone, otp: _otp);
  }

  void _onOtpChanged(String value) {
    setState(() => _otp = value);
  }

  void _onOtpCompleted(String value) {
    setState(() => _otp = value);

    _onVerify();
  }


  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: _onAuthStateChanged,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.safePop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              children: [
                AppSpacing.verticalXxxl,


                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.cyan.withValues(alpha: 0.1),
                  ),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.shield_outlined,
                    size: 28,
                    color: AppColors.cyan,
                  ),
                ),

                AppSpacing.verticalLg,


                const Text(
                  'Security Check',
                  style: AppTypography.h2,
                  textAlign: TextAlign.center,
                ),

                AppSpacing.verticalSm,


                Text(
                  'Enter the 6-digit code sent to',
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),

                AppSpacing.verticalXs,


                Text(
                  _maskedPhone,
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.cyan,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),

                AppSpacing.verticalXxl,


                if (AppConfig.otpBypassEnabled)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.md),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.warning.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                        border: Border.all(
                          color: AppColors.warning.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.build_rounded,
                            size: 14,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Text(
                            'Dev Mode — OTP auto-filled with ${AppConfig.devOtpCode}',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.warning,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),


                OtpInput(
                  key: _otpKey,
                  length: 6,
                  onChanged: _onOtpChanged,
                  onCompleted: _onOtpCompleted,
                ),

                AppSpacing.verticalXl,


                _buildTimerSection(),

                AppSpacing.verticalXxl,


                _buildVerifyButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildTimerSection() {
    return Column(
      children: [

        if (!_canResend)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.elevated,
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.schedule,
                  size: 14,
                  color: AppColors.cyan,
                ),
                AppSpacing.horizontalSm,
                Text(
                  _timerText,
                  style: AppTypography.buttonSmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

        AppSpacing.verticalBase,


        Text(
          'Didn\u2019t receive a code?',
          style: AppTypography.caption.copyWith(
            color: AppColors.textTertiary,
          ),
        ),

        AppSpacing.verticalXs,


        GestureDetector(
          onTap: _canResend ? _onResend : null,
          child: Text(
            'Resend code',
            style: AppTypography.bodySmall.copyWith(
              color: _canResend ? AppColors.cyan : AppColors.textTertiary,
              fontWeight: _canResend ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerifyButton() {
    return BlocBuilder<AuthCubit, AuthState>(
      buildWhen: (prev, curr) => curr is AuthLoading || prev is AuthLoading,
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        final isEnabled = _otp.length == 6 && !isLoading;

        return SizedBox(
          width: double.infinity,
          child: _VerifyButton(
            isLoading: isLoading,
            isEnabled: isEnabled,
            onPressed: _onVerify,
          ),
        );
      },
    );
  }


  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state is OtpVerified) {

      if (!state.user.emailVerified) {
        context.go(RoutePaths.emailVerification);
      } else {
        context.go(RoutePaths.feed);
      }
    } else if (state is OtpSent) {

    } else if (state is AuthError) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      _otpKey.currentState?.clear();
      _otpKey.currentState?.focusFirst();
      setState(() => _otp = '');
    }
  }
}


class _VerifyButton extends StatelessWidget {
  const _VerifyButton({
    required this.isLoading,
    required this.isEnabled,
    required this.onPressed,
  });

  final bool isLoading;
  final bool isEnabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: isEnabled || isLoading ? 1.0 : 0.5,
      child: Container(
        width: double.infinity,
        height: AppSpacing.buttonHeight,
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: AppSpacing.buttonRadius,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isEnabled ? onPressed : null,
            borderRadius: AppSpacing.buttonRadius,
            splashColor: AppColors.textPrimary.withValues(alpha: 0.1),
            highlightColor: AppColors.textPrimary.withValues(alpha: 0.05),
            child: Center(
              child: isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: AppColors.textPrimary,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('VERIFY NOW', style: AppTypography.button),
                        AppSpacing.horizontalSm,
                        Icon(
                          Icons.bolt,
                          color: AppColors.textPrimary,
                          size: 20,
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
