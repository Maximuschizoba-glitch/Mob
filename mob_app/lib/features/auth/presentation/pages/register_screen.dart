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
import '../widgets/password_strength_indicator.dart';
import '../widgets/phone_input_field.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();


  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();


  final _nameFocus = FocusNode();
  final _emailFocus = FocusNode();
  final _phoneFocus = FocusNode();
  final _passwordFocus = FocusNode();
  final _confirmPasswordFocus = FocusNode();


  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _passwordText = '';


  Map<String, String?> _serverErrors = {};

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    super.dispose();
  }


  String get _fullPhone {
    final digits = _phoneController.text.replaceAll(RegExp(r'\s+'), '');
    if (digits.isEmpty) return '';
    final normalized = digits.startsWith('0') ? digits.substring(1) : digits;
    return '+234$normalized';
  }


  String? _validateName(String? value) {
    if (_serverErrors['name'] != null) return _serverErrors['name'];
    if (value == null || value.trim().isEmpty) return 'Name is required';
    if (value.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? _validateEmail(String? value) {
    if (_serverErrors['email'] != null) return _serverErrors['email'];
    if (value == null || value.trim().isEmpty) return 'Email is required';
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) return 'Enter a valid email';
    return null;
  }

  String? _validatePhone(String? value) {
    if (_serverErrors['phone'] != null) return _serverErrors['phone'];
    if (value == null || value.trim().isEmpty) return 'Phone number is required';
    final digits = value.replaceAll(RegExp(r'\s+'), '');
    if (digits.length < 10 || digits.length > 11) {
      return 'Enter a valid Nigerian phone number';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (_serverErrors['password'] != null) return _serverErrors['password'];
    if (value == null || value.isEmpty) return 'Password is required';
    if (value.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) return 'Please confirm your password';
    if (value != _passwordController.text) return 'Passwords do not match';
    return null;
  }


  void _onSubmit() {

    setState(() => _serverErrors = {});

    if (!_formKey.currentState!.validate()) return;

    context.read<AuthCubit>().register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _fullPhone,
          password: _passwordController.text,
          passwordConfirmation: _confirmPasswordController.text,
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
          centerTitle: true,
          title: const Text(
            'Create Account',
            style: AppTypography.button,
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppSpacing.verticalXl,


                  MobTextField(
                    controller: _nameController,
                    focusNode: _nameFocus,
                    label: 'Full Name',
                    hint: 'Full name',
                    keyboardType: TextInputType.name,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    validator: _validateName,
                    onChanged: (_) => _clearServerError('name'),
                    onSubmitted: (_) => _emailFocus.requestFocus(),
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                  ),

                  AppSpacing.verticalBase,


                  MobTextField(
                    controller: _emailController,
                    focusNode: _emailFocus,
                    label: 'Email',
                    hint: 'Email address',
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    validator: _validateEmail,
                    onChanged: (_) => _clearServerError('email'),
                    onSubmitted: (_) => _phoneFocus.requestFocus(),
                    prefixIcon: const Icon(
                      Icons.email_outlined,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                  ),

                  AppSpacing.verticalBase,


                  PhoneInputField(
                    controller: _phoneController,
                    focusNode: _phoneFocus,
                    validator: _validatePhone,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _passwordFocus.requestFocus(),
                  ),

                  AppSpacing.verticalBase,


                  MobTextField(
                    controller: _passwordController,
                    focusNode: _passwordFocus,
                    label: 'Password',
                    hint: 'Password (min. 8 characters)',
                    obscureText: _obscurePassword,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: _validatePassword,
                    onChanged: (value) {
                      setState(() => _passwordText = value);
                      _clearServerError('password');
                    },
                    onSubmitted: (_) => _confirmPasswordFocus.requestFocus(),
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
                        setState(() => _obscurePassword = !_obscurePassword);
                      },
                    ),
                  ),


                  AppSpacing.verticalSm,
                  PasswordStrengthIndicator(password: _passwordText),

                  AppSpacing.verticalBase,


                  MobTextField(
                    controller: _confirmPasswordController,
                    focusNode: _confirmPasswordFocus,
                    label: 'Confirm Password',
                    hint: 'Confirm password',
                    obscureText: _obscureConfirmPassword,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: _validateConfirmPassword,
                    onSubmitted: (_) => _onSubmit(),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.textTertiary,
                      size: 20,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textTertiary,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() =>
                            _obscureConfirmPassword = !_obscureConfirmPassword);
                      },
                    ),
                  ),

                  AppSpacing.verticalSm,


                  _buildTermsText(),

                  AppSpacing.verticalXl,


                  BlocBuilder<AuthCubit, AuthState>(
                    buildWhen: (prev, curr) =>
                        curr is AuthLoading || prev is AuthLoading,
                    builder: (context, state) {
                      return MobGradientButton(
                        label: 'SIGN UP',
                        icon: Icons.arrow_forward,
                        isLoading: state is AuthLoading,
                        onPressed: state is AuthLoading ? null : _onSubmit,
                      );
                    },
                  ),

                  AppSpacing.verticalBase,


                  _buildLoginLink(),

                  AppSpacing.verticalXl,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildTermsText() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: AppTypography.overline.copyWith(
          color: AppColors.textTertiary,
          letterSpacing: 0,
          height: 1.5,
        ),
        children: [
          const TextSpan(text: 'By signing up, you agree to our '),
          TextSpan(
            text: 'Terms of Service',
            style: const TextStyle(color: AppColors.cyan),
            recognizer: TapGestureRecognizer()..onTap = _onTermsTap,
          ),
          const TextSpan(text: ' and '),
          TextSpan(
            text: 'Privacy Policy',
            style: const TextStyle(color: AppColors.cyan),
            recognizer: TapGestureRecognizer()..onTap = _onPrivacyTap,
          ),
        ],
      ),
    );
  }


  Widget _buildLoginLink() {
    return Center(
      child: RichText(
        text: TextSpan(
          style: AppTypography.bodySmall,
          children: [
            const TextSpan(text: 'Already have an account? '),
            TextSpan(
              text: 'Log In',
              style: const TextStyle(
                color: AppColors.cyan,
                fontWeight: FontWeight.w600,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () => context.pushReplacement(RoutePaths.login),
            ),
          ],
        ),
      ),
    );
  }


  void _onAuthStateChanged(BuildContext context, AuthState state) {
    if (state is Authenticated) {

      context.go(RoutePaths.phoneOtp);
    } else if (state is AuthError) {
      if (state.hasValidationErrors) {

        setState(() {
          _serverErrors = {
            'name': state.fieldError('name'),
            'email': state.fieldError('email'),
            'phone': state.fieldError('phone'),
            'password': state.fieldError('password'),
          };
        });
        _formKey.currentState?.validate();
      } else {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }


  void _clearServerError(String field) {
    if (_serverErrors[field] != null) {
      setState(() => _serverErrors = {..._serverErrors, field: null});
    }
  }

  void _onTermsTap() {

  }

  void _onPrivacyTap() {

  }
}
