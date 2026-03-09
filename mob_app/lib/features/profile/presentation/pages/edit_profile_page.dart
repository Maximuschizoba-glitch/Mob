import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../data/models/update_profile_request.dart';
import '../../domain/repositories/profile_repository.dart';
import '../bloc/profile_cubit.dart';
import '../bloc/profile_state.dart';


class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {

    final authState = context.read<AuthCubit>().state;
    if (authState is! Authenticated) {
      return const SizedBox.shrink();
    }

    return BlocProvider(
      create: (ctx) => ProfileCubit(
        profileRepository: ctx.read<ProfileRepository>(),
      )..loadProfile(),
      child: const _EditProfileView(),
    );
  }
}

class _EditProfileView extends StatefulWidget {
  const _EditProfileView();

  @override
  State<_EditProfileView> createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<_EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;

  bool _hasChanges = false;
  String? _initialName;
  String? _initialBio;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();

    _nameController.addListener(_checkForChanges);
    _bioController.addListener(_checkForChanges);
  }

  @override
  void dispose() {
    _nameController.removeListener(_checkForChanges);
    _bioController.removeListener(_checkForChanges);
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _initFieldsFromUser(User user) {
    if (_initialName == null) {
      _initialName = user.name;
      _initialBio = '';
      _nameController.text = user.name;
    }
  }

  void _checkForChanges() {
    final changed = _nameController.text.trim() != _initialName ||
        _bioController.text.trim() != (_initialBio ?? '');
    if (changed != _hasChanges) {
      setState(() => _hasChanges = changed);
    }
  }

  void _saveProfile() {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final bio = _bioController.text.trim();

    context.read<ProfileCubit>().updateProfile(
          UpdateProfileRequest(
            name: name != _initialName ? name : null,
            bio: bio != (_initialBio ?? '') ? bio : null,
          ),
        );
  }

  Future<void> _pickAvatar() async {
    final result = await MobBottomSheet.show<String>(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Change Photo',
            style: AppTypography.h3,
          ),
          AppSpacing.verticalLg,
          _AvatarOption(
            icon: Icons.camera_alt_outlined,
            label: 'Take Photo',
            onTap: () => Navigator.pop(context, 'camera'),
          ),
          AppSpacing.verticalSm,
          _AvatarOption(
            icon: Icons.photo_library_outlined,
            label: 'Choose from Gallery',
            onTap: () => Navigator.pop(context, 'gallery'),
          ),
          AppSpacing.verticalSm,
          _AvatarOption(
            icon: Icons.delete_outline,
            label: 'Remove Photo',
            color: AppColors.error,
            onTap: () => Navigator.pop(context, 'remove'),
          ),
          AppSpacing.verticalBase,
        ],
      ),
    );

    if (result == null || !mounted) return;

    ImageSource? source;
    if (result == 'camera') {
      source = ImageSource.camera;
    } else if (result == 'gallery') {
      source = ImageSource.gallery;
    }

    if (source != null) {
      final picker = ImagePicker();
      final image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      if (image != null && mounted) {
        context.read<ProfileCubit>().updateAvatar(image.path);
      }
    }
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listenWhen: (prev, curr) =>
          curr is ProfileUpdateSuccess || curr is ProfileError,
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message ?? 'Profile updated'),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );

          context.read<AuthCubit>().refreshUser();
          context.pop();
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


        if (state is ProfileInitial) {
          context.read<AuthCubit>().logout();
        }
      },
      builder: (context, state) {

        final user = _resolveUser(context, state);
        if (user != null) {
          _initFieldsFromUser(user);
        }

        final isUpdating = state is ProfileUpdating;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded),
              color: AppColors.textPrimary,
              onPressed: () => context.pop(),
            ),
            title: const Text('Edit Profile', style: AppTypography.h3),
            centerTitle: true,
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: TextButton(
                  onPressed: _hasChanges && !isUpdating ? _saveProfile : null,
                  child: isUpdating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: AppColors.cyan,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          'Save',
                          style: AppTypography.buttonSmall.copyWith(
                            color: _hasChanges
                                ? AppColors.cyan
                                : AppColors.textDisabled,
                          ),
                        ),
                ),
              ),
            ],
          ),
          body: user == null
              ? Center(child: MobLoadingShimmer.feedCard())
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: AppSpacing.screenPadding,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          _AvatarSection(
                            user: user,
                            onTap: _pickAvatar,
                          ),

                          AppSpacing.verticalXxl,


                          const MobSectionLabel(label: 'Identity'),
                          AppSpacing.verticalBase,
                          MobTextField(
                            label: 'Full Name',
                            hint: 'Enter your name',
                            controller: _nameController,
                            textInputAction: TextInputAction.next,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Name is required';
                              }
                              return null;
                            },
                          ),
                          AppSpacing.verticalLg,
                          MobTextField(
                            label: 'Bio',
                            hint: 'Tell people about yourself...',
                            controller: _bioController,
                            maxLines: 3,
                            maxLength: 150,
                            textInputAction: TextInputAction.done,
                          ),

                          AppSpacing.verticalXxl,


                          const MobSectionLabel(label: 'Contact'),
                          AppSpacing.verticalBase,
                          _ReadOnlyField(
                            label: 'Email',
                            value: user.email,
                            isVerified: user.emailVerified,
                          ),
                          AppSpacing.verticalLg,
                          _ReadOnlyField(
                            label: 'Phone',
                            value: user.phone != null
                                ? '+234 ${user.phone}'
                                : 'Not set',
                            isVerified: user.phoneVerified,
                          ),

                          AppSpacing.verticalXxl,
                          AppSpacing.verticalXl,


                          Center(
                            child: GestureDetector(
                              onTap: _confirmDeleteAccount,
                              child: Text(
                                'Delete Account',
                                style: AppTypography.buttonSmall.copyWith(
                                  color: AppColors.error,
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
      },
    );
  }

  User? _resolveUser(BuildContext context, ProfileState state) {
    if (state is ProfileLoaded) return state.user;
    if (state is ProfileUpdating) return state.user;
    if (state is ProfileUpdateSuccess) return state.user;
    if (state is ProfileError && state.previousUser != null) {
      return state.previousUser;
    }
    return context.read<AuthCubit>().currentUser;
  }
}


class _AvatarSection extends StatelessWidget {
  const _AvatarSection({
    required this.user,
    required this.onTap,
  });

  final User user;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          children: [
            Stack(
              children: [
                MobAvatar(
                  imageUrl: user.avatarUrl,
                  size: 120,
                  showBorder: true,
                  initials: user.initials,
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.cyan,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.background,
                        width: 3,
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.background,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
            AppSpacing.verticalSm,
            Text(
              'Change Photo',
              style: AppTypography.buttonSmall.copyWith(
                color: AppColors.cyan,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _ReadOnlyField extends StatelessWidget {
  const _ReadOnlyField({
    required this.label,
    required this.value,
    required this.isVerified,
  });

  final String label;
  final String value;
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.overline.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
            fontSize: 11,
          ),
        ),
        AppSpacing.verticalSm,
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.base,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border, width: 0.5),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textDisabled,
                  ),
                ),
              ),
              _VerificationBadge(isVerified: isVerified),
            ],
          ),
        ),
      ],
    );
  }
}

class _VerificationBadge extends StatelessWidget {
  const _VerificationBadge({required this.isVerified});

  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    if (isVerified) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.check_circle,
            size: 16,
            color: AppColors.success,
          ),
          const SizedBox(width: 4),
          Text(
            'Verified',
            style: AppTypography.caption.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.info_outline,
          size: 16,
          color: AppColors.warning,
        ),
        const SizedBox(width: 4),
        Text(
          'Not verified',
          style: AppTypography.caption.copyWith(
            color: AppColors.warning,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}


class _AvatarOption extends StatelessWidget {
  const _AvatarOption({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.textPrimary;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md,
          horizontal: AppSpacing.base,
        ),
        decoration: BoxDecoration(
          color: AppColors.elevated,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            Icon(icon, color: effectiveColor, size: 22),
            AppSpacing.horizontalMd,
            Text(
              label,
              style: AppTypography.body.copyWith(color: effectiveColor),
            ),
          ],
        ),
      ),
    );
  }
}
