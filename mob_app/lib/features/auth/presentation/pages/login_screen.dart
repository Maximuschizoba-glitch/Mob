import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../core/utils/navigation_helpers.dart';
import '../../../../shared/widgets/mob_gradient_button.dart';
import '../../../../shared/widgets/mob_text_field.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();


  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();


  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();


  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }


  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Password is required';
    return null;
  }


  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: AppSpacing.screenPadding,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppSpacing.verticalXxl,


                          const Text(
                            'Welcome Back',
                            style: AppTypography.h1,
                          ),
                          AppSpacing.verticalXs,
                          Text(
                            'Log in to find the vibe',
                            style: AppTypography.body.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),

                          AppSpacing.verticalXxl,


                          MobTextField(
                            controller: _emailController,
                            focusNode: _emailFocus,
                            label: 'Email',
                            hint: 'Email address',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autofillHints: const [AutofillHints.email],
                            validator: _validateEmail,
                            onSubmitted: (_) => _passwordFocus.requestFocus(),
                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: AppColors.textTertiary,
                              size: 20,
                            ),
                          ),

                          AppSpacing.verticalBase,


                          MobTextField(
                            controller: _passwordController,
                            focusNode: _passwordFocus,
                            label: 'Password',
                            hint: 'Password',
                            obscureText: _obscurePassword,
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.done,
                            autofillHints: const [AutofillHints.password],
                            validator: _validatePassword,
                            onSubmitted: (_) => _onSubmit(),
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: AppColors.textTertiary,
                              size: 20,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: AppColors.textTertiary,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(() =>
                                    _obscurePassword = !_obscurePassword);
                              },
                            ),
                          ),

                          AppSpacing.verticalSm,


                          Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: _onForgotPassword,
                              child: Text(
                                'Forgot Password?',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.cyan,
                                ),
                              ),
                            ),
                          ),

                          AppSpacing.verticalXxl,


                          BlocBuilder<AuthCubit, AuthState>(
                            buildWhen: (prev, curr) =>
                                curr is AuthLoading || prev is AuthLoading,
                            builder: (context, state) {
                              return MobGradientButton(
                                label: 'LOG IN',
                                icon: Icons.arrow_forward,
                                isLoading: state is AuthLoading,
                                onPressed:
                                    state is AuthLoading ? null : _onSubmit,
                              );
                            },
                          ),

                          AppSpacing.verticalBase,


                          _buildSignUpLink(),


                          const Spacer(),


                          _buildOrDivider(),

                          AppSpacing.verticalBase,


                          _buildGuestLink(),

                          AppSpacing.verticalXxl,
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }


  Widget _buildSignUpLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: AppTypography.bodySmall,
          children: [
            const TextSpan(text: 'Don\u2019t have an account? '),
            TextSpan(
              text: 'Sign Up',
              style: const TextStyle(
                color: AppColors.cyan,
                fontWeight: FontWeight.w600,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => context.pushReplacement(RoutePaths.register),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildOrDivider() {
    return Row(
      children: [
        const Expanded(
          child: Divider(color: AppColors.surface, thickness: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
          child: Text(
            'or',
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ),
        const Expanded(
          child: Divider(color: AppColors.surface, thickness: 1),
        ),
      ],
    );
  }


  Widget _buildGuestLink() {
    return Center(
      child: GestureDetector(
        onTap: _onContinueAsGuest,
        behavior: HitTestBehavior.opaque,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.visibility_outlined,
              size: 16,
              color: AppColors.textTertiary,
            ),
            AppSpacing.horizontalSm,
            Text(
              'CONTINUE AS GUEST',
              style: AppTypography.overline.copyWith(
                color: AppColors.textTertiary,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }


  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state is Authenticated) {

      if (!state.user.phoneVerified) {
        context.go(RoutePaths.phoneOtp);
      } else {
        context.go(RoutePaths.feed);
      }
    } else if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _onContinueAsGuest() async {
    await context.read<AuthCubit>().continueAsGuest();
    if (mounted) context.go(RoutePaths.feed);
  }

  void _onForgotPassword() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Password reset coming soon!'),
        backgroundColor: AppColors.elevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        ),
      ),
    );
  }
}
