import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_config.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/repositories/profile_repository.dart';
import '../bloc/profile_cubit.dart';
import '../bloc/profile_state.dart';


class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => ProfileCubit(
        profileRepository: ctx.read<ProfileRepository>(),
      ),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatefulWidget {
  const _SettingsView();

  @override
  State<_SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<_SettingsView> {
  bool _pushNotifications = true;
  bool _emailNotifications = true;

  @override
  void initState() {
    super.initState();
    _loadNotificationPrefs();
  }

  Future<void> _loadNotificationPrefs() async {


  }

  void _togglePushNotifications(bool value) {
    setState(() => _pushNotifications = value);

  }

  void _toggleEmailNotifications(bool value) {
    setState(() => _emailNotifications = value);

  }

  void _confirmLogout() {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: const Text('Log Out', style: AppTypography.h3),
        content: Text(
          'Are you sure you want to log out?',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: AppTypography.buttonSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Log Out',
              style: AppTypography.buttonSmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        context.read<AuthCubit>().logout();
      }
    });
  }

  void _confirmDeleteAccount() {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        title: Text(
          'Delete Account',
          style: AppTypography.h3.copyWith(color: AppColors.error),
        ),
        content: Text(
          'This action is permanent and cannot be undone. '
          'All your data, happenings, and tickets will be deleted.',
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(
              'Cancel',
              style: AppTypography.buttonSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(
              'Delete',
              style: AppTypography.buttonSmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && mounted) {
        context.read<ProfileCubit>().deleteAccount();
      }
    });
  }

  void _showChangePasswordSheet() {
    final currentPwController = TextEditingController();
    final newPwController = TextEditingController();
    final confirmPwController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    MobBottomSheet.show(
      context,
      maxHeight: 0.75,
      child: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Change Password', style: AppTypography.h3),
            AppSpacing.verticalLg,
            MobTextField(
              label: 'Current Password',
              hint: 'Enter current password',
              controller: currentPwController,
              obscureText: true,
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                return null;
              },
            ),
            AppSpacing.verticalBase,
            MobTextField(
              label: 'New Password',
              hint: 'Enter new password',
              controller: newPwController,
              obscureText: true,
              textInputAction: TextInputAction.next,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (v.length < 8) return 'Must be at least 8 characters';
                return null;
              },
            ),
            AppSpacing.verticalBase,
            MobTextField(
              label: 'Confirm New Password',
              hint: 'Confirm new password',
              controller: confirmPwController,
              obscureText: true,
              textInputAction: TextInputAction.done,
              validator: (v) {
                if (v == null || v.isEmpty) return 'Required';
                if (v != newPwController.text) return 'Passwords do not match';
                return null;
              },
            ),
            AppSpacing.verticalLg,
            MobGradientButton(
              label: 'Update Password',
              onPressed: () {
                if (formKey.currentState!.validate()) {

                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Password change will be available soon'),
                      backgroundColor: AppColors.warning,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
            ),
            AppSpacing.verticalBase,
          ],
        ),
      ),
    );
  }

  void _showDataPrivacySheet() {
    MobBottomSheet.show(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Data & Privacy', style: AppTypography.h3),
          AppSpacing.verticalLg,
          Text(
            'Mob collects location data to show you nearby happenings '
            'and enable the map feature. Your data is used to personalize '
            'your experience and is never sold to third parties.',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          AppSpacing.verticalBase,
          Text(
            'You can manage your location permissions in your device settings. '
            'To delete your account and all associated data, use the Account section '
            'in Settings.',
            style: AppTypography.body.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          AppSpacing.verticalLg,
          MobOutlinedButton(
            label: 'Close',
            onPressed: () => Navigator.pop(context),
          ),
          AppSpacing.verticalBase,
        ],
      ),
    );
  }

  Future<void> _openLocationSettings() async {

    final uri = Uri.parse('app-settings:');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileCubit, ProfileState>(
      listener: (context, state) {

        if (state is ProfileInitial) {
          context.read<AuthCubit>().logout();
        }
        if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Unauthenticated) {
            context.go('/welcome');
          }
        },
        child: Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              color: AppColors.textPrimary,
              onPressed: () => context.pop(),
            ),
            title: const Text('Settings', style: AppTypography.h3),
            centerTitle: true,
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.base,
                vertical: AppSpacing.sm,
              ),
              children: [

                _buildUserCard(context),

                AppSpacing.verticalLg,


                _buildSectionHeader('Notifications'),
                AppSpacing.verticalSm,
                _SettingsGroup(
                  children: [
                    _SettingsToggleRow(
                      icon: Icons.notifications_outlined,
                      title: 'Push Notifications',
                      value: _pushNotifications,
                      onChanged: _togglePushNotifications,
                    ),
                    _SettingsToggleRow(
                      icon: Icons.email_outlined,
                      title: 'Email Notifications',
                      value: _emailNotifications,
                      onChanged: _toggleEmailNotifications,
                    ),
                  ],
                ),

                AppSpacing.verticalLg,


                _buildSectionHeader('Appearance'),
                AppSpacing.verticalSm,
                _SettingsGroup(
                  children: [
                    _SettingsInfoRow(
                      icon: Icons.dark_mode_outlined,
                      title: 'App Theme',
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Dark Mode',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.check_circle,
                            size: 16,
                            color: AppColors.cyan,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                AppSpacing.verticalLg,


                _buildSectionHeader('Privacy'),
                AppSpacing.verticalSm,
                _SettingsGroup(
                  children: [
                    _SettingsTapRow(
                      icon: Icons.location_on_outlined,
                      title: 'Location Services',
                      onTap: _openLocationSettings,
                    ),
                    _SettingsTapRow(
                      icon: Icons.shield_outlined,
                      title: 'Data & Privacy',
                      onTap: _showDataPrivacySheet,
                    ),
                  ],
                ),

                AppSpacing.verticalLg,


                _buildSectionHeader('Account'),
                AppSpacing.verticalSm,
                _SettingsGroup(
                  children: [
                    _SettingsTapRow(
                      icon: Icons.person_outline,
                      title: 'Personal Info',
                      onTap: () => context.push('/edit-profile'),
                    ),
                    _SettingsTapRow(
                      icon: Icons.lock_outline,
                      title: 'Password & Security',
                      onTap: _showChangePasswordSheet,
                    ),
                  ],
                ),

                AppSpacing.verticalLg,


                _buildSectionHeader('About'),
                AppSpacing.verticalSm,
                _SettingsGroup(
                  children: [
                    _SettingsTapRow(
                      icon: Icons.description_outlined,
                      title: 'Terms of Service',
                      onTap: () => _openUrl(
                        AppConfig.termsUrl,
                      ),
                    ),
                    _SettingsTapRow(
                      icon: Icons.privacy_tip_outlined,
                      title: 'Privacy Policy',
                      onTap: () => _openUrl(
                        AppConfig.privacyUrl,
                      ),
                    ),
                    _SettingsInfoRow(
                      icon: Icons.info_outline,
                      title: 'About Mob',
                      trailing: Text(
                        'v1.0.0',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),

                AppSpacing.verticalXxl,


                _buildLogoutButton(),

                AppSpacing.verticalBase,


                Center(
                  child: GestureDetector(
                    onTap: _confirmDeleteAccount,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm,
                      ),
                      child: Text(
                        'Delete Account',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ),
                ),

                AppSpacing.verticalXxl,
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildUserCard(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    if (authState is! Authenticated) return const SizedBox.shrink();

    final user = authState.user;

    return GestureDetector(
      onTap: () => context.push('/edit-profile'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        ),
        child: Row(
          children: [
            MobAvatar(
              imageUrl: user.avatarUrl,
              size: AppSpacing.avatarMd,
              initials: user.initials,
            ),
            AppSpacing.horizontalMd,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.xs),
      child: Text(
        label.toUpperCase(),
        style: AppTypography.overline.copyWith(
          color: AppColors.textTertiary,
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: _confirmLogout,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: AppColors.error.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.logout_rounded,
              color: AppColors.error,
              size: 20,
            ),
            AppSpacing.horizontalSm,
            Text(
              'Log Out',
              style: AppTypography.button.copyWith(
                color: AppColors.error,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _SettingsGroup extends StatelessWidget {
  const _SettingsGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: Column(
        children: [
          for (int i = 0; i < children.length; i++) ...[
            children[i],
            if (i < children.length - 1)
              const Divider(
                height: 0.5,
                thickness: 0.5,
                color: AppColors.border,
                indent: 52,
              ),
          ],
        ],
      ),
    );
  }
}


class _SettingsTapRow extends StatelessWidget {
  const _SettingsTapRow({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: 14,
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textSecondary, size: 22),
              AppSpacing.horizontalMd,
              Expanded(
                child: Text(title, style: AppTypography.body),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _SettingsToggleRow extends StatelessWidget {
  const _SettingsToggleRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: 6,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 22),
          AppSpacing.horizontalMd,
          Expanded(
            child: Text(title, style: AppTypography.body),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: AppColors.cyan,
            activeTrackColor: AppColors.cyan.withValues(alpha: 0.3),
            inactiveThumbColor: AppColors.textTertiary,
            inactiveTrackColor: AppColors.surface,
          ),
        ],
      ),
    );
  }
}


class _SettingsInfoRow extends StatelessWidget {
  const _SettingsInfoRow({
    required this.icon,
    required this.title,
    required this.trailing,
  });

  final IconData icon;
  final String title;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: 14,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 22),
          AppSpacing.horizontalMd,
          Expanded(
            child: Text(title, style: AppTypography.body),
          ),
          trailing,
        ],
      ),
    );
  }
}
