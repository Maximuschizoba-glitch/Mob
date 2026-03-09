import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../core/services/firebase_storage_service.dart';
import '../../../../shared/widgets/widgets.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../../data/models/host_verification_request.dart';
import '../../domain/repositories/host_verification_repository.dart';
import '../bloc/host_verification_cubit.dart';
import '../bloc/host_verification_state.dart';


class HostVerificationRequestPage extends StatelessWidget {
  const HostVerificationRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => HostVerificationCubit(
        hostVerificationRepository: ctx.read<HostVerificationRepository>(),
      )..loadVerificationStatus(),
      child: const _VerificationGuard(),
    );
  }
}


class _VerificationGuard extends StatelessWidget {
  const _VerificationGuard();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HostVerificationCubit, HostVerificationState>(
      listener: (context, state) {
        if (state is HostVerificationLoaded) {
          final v = state.verification;

          if (v.isPending || v.isApproved) {
            context.pushReplacement(RoutePaths.hostVerificationStatus);
          }
        }
      },
      builder: (context, state) {

        if (state is HostVerificationLoading ||
            state is HostVerificationInitial) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              backgroundColor: AppColors.background,
              elevation: 0,
              scrolledUnderElevation: 0,
              leading: IconButton(
                icon: const Icon(
                  Icons.arrow_back,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => context.pop(),
              ),
              title: const Text('Get Verified', style: AppTypography.h3),
              centerTitle: true,
            ),
            body: const Center(
              child: CircularProgressIndicator(color: AppColors.cyan),
            ),
          );
        }


        if (state is HostVerificationLoaded) {
          final v = state.verification;
          if (v.isPending || v.isApproved) {
            return const SizedBox.shrink();
          }
        }


        return const _VerificationFormView();
      },
    );
  }
}


enum _DocumentOption {
  cac,
  instagram,
  website;


  String get apiValue {
    switch (this) {
      case _DocumentOption.cac:
        return 'cac';
      case _DocumentOption.instagram:
        return 'instagram';
      case _DocumentOption.website:
        return 'website';
    }
  }


  String get title {
    switch (this) {
      case _DocumentOption.cac:
        return 'CAC Certificate';
      case _DocumentOption.instagram:
        return 'Instagram Profile';
      case _DocumentOption.website:
        return 'Website';
    }
  }


  String get description {
    switch (this) {
      case _DocumentOption.cac:
        return 'Upload company registration document';
      case _DocumentOption.instagram:
        return 'Active Instagram with event history';
      case _DocumentOption.website:
        return 'Business or portfolio website';
    }
  }


  String get emoji {
    switch (this) {
      case _DocumentOption.cac:
        return '\u{1F4C4}';
      case _DocumentOption.instagram:
        return '\u{1F4F1}';
      case _DocumentOption.website:
        return '\u{1F310}';
    }
  }


  bool get isFileUpload => this == _DocumentOption.cac;


  String get urlLabel {
    switch (this) {
      case _DocumentOption.cac:
        return 'CAC Document';
      case _DocumentOption.instagram:
        return 'Instagram Profile URL';
      case _DocumentOption.website:
        return 'Website URL';
    }
  }


  String get urlHint {
    switch (this) {
      case _DocumentOption.cac:
        return '';
      case _DocumentOption.instagram:
        return 'https://instagram.com/your_handle';
      case _DocumentOption.website:
        return 'https://yourbusiness.com';
    }
  }
}


class _VerificationFormView extends StatefulWidget {
  const _VerificationFormView();

  @override
  State<_VerificationFormView> createState() => _VerificationFormViewState();
}

class _VerificationFormViewState extends State<_VerificationFormView> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _documentUrlController = TextEditingController();

  _DocumentOption? _selectedDocType;


  File? _selectedCacFile;
  String? _cacFileName;
  bool _isUploadingFile = false;
  double _uploadProgress = 0.0;
  String? _uploadedCacUrl;

  @override
  void dispose() {
    _businessNameController.dispose();
    _bioController.dispose();
    _documentUrlController.dispose();
    super.dispose();
  }


  bool get _isFormValid {
    final hasBusinessName = _businessNameController.text.trim().isNotEmpty;
    final hasDocType = _selectedDocType != null;

    if (!hasBusinessName || !hasDocType) return false;

    if (_selectedDocType!.isFileUpload) {

      return _uploadedCacUrl != null && _uploadedCacUrl!.isNotEmpty;
    } else {

      return _documentUrlController.text.trim().isNotEmpty;
    }
  }


  String get _documentUrl {
    if (_selectedDocType?.isFileUpload == true) {
      return _uploadedCacUrl ?? '';
    }
    return _documentUrlController.text.trim();
  }

  void _onSubmit() {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDocType == null) return;


    if (_selectedDocType!.isFileUpload && (_uploadedCacUrl == null || _uploadedCacUrl!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload your CAC document first'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final request = HostVerificationRequest(
      businessName: _businessNameController.text.trim(),
      bio: _bioController.text.trim().isNotEmpty
          ? _bioController.text.trim()
          : null,
      documentType: _selectedDocType!.apiValue,
      documentUrl: _documentUrl,
    );

    context.read<HostVerificationCubit>().submitVerification(request);
  }


  Future<void> _pickCacFile() async {
    final result = await MobBottomSheet.show<String>(
      context,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Upload CAC Document', style: AppTypography.h3),
          AppSpacing.verticalSm,
          Text(
            'Take a photo of your CAC certificate or choose from gallery',
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          AppSpacing.verticalLg,
          _UploadOption(
            icon: Icons.camera_alt_outlined,
            label: 'Take Photo',
            onTap: () => Navigator.pop(context, 'camera'),
          ),
          AppSpacing.verticalSm,
          _UploadOption(
            icon: Icons.photo_library_outlined,
            label: 'Choose from Gallery',
            onTap: () => Navigator.pop(context, 'gallery'),
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

    if (source == null) return;

    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: source,
      maxWidth: 1600,
      maxHeight: 1600,
      imageQuality: 90,
    );

    if (image == null || !mounted) return;

    final file = File(image.path);
    final fileName = image.name;

    setState(() {
      _selectedCacFile = file;
      _cacFileName = fileName;
      _uploadedCacUrl = null;
      _uploadProgress = 0.0;
    });

    await _uploadCacFile(file);
  }

  Future<void> _uploadCacFile(File file) async {
    final authCubit = context.read<AuthCubit>();
    final userId = authCubit.currentUser?.uuid ?? '';

    if (userId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Authentication error. Please log in again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
      return;
    }

    setState(() {
      _isUploadingFile = true;
      _uploadProgress = 0.0;
    });

    try {
      final storageService = context.read<FirebaseStorageService>();
      final downloadUrl = await storageService.uploadVerificationDocument(
        file: file,
        userId: userId,
        onProgress: (progress) {
          if (mounted) {
            setState(() => _uploadProgress = progress);
          }
        },
      );

      if (mounted) {
        setState(() {
          _uploadedCacUrl = downloadUrl;
          _isUploadingFile = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingFile = false;
          _selectedCacFile = null;
          _cacFileName = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Upload failed: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _removeCacFile() {
    setState(() {
      _selectedCacFile = null;
      _cacFileName = null;
      _uploadedCacUrl = null;
      _uploadProgress = 0.0;
      _isUploadingFile = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HostVerificationCubit, HostVerificationState>(
      listener: (context, state) {
        if (state is HostVerificationSubmitted) {
          _showSuccessDialog();
        } else if (state is HostVerificationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => context.pop(),
          ),
          title: const Text('Get Verified', style: AppTypography.h3),
          centerTitle: true,
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: AppSpacing.screenPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                _buildHeroSection(),
                AppSpacing.verticalXl,


                _buildBenefitsRow(),
                AppSpacing.verticalXxl,


                _buildFormFields(),
                AppSpacing.verticalXxl,


                _buildSubmitButton(),
                AppSpacing.verticalBase,


                _buildReviewNote(),
                AppSpacing.verticalXxl,
              ],
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildHeroSection() {
    return Column(
      children: [

        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.cyan.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Text(
            '\u{1F451}',
            style: TextStyle(fontSize: 32),
          ),
        ),
        AppSpacing.verticalBase,
        const Text(
          'Become a Verified Host',
          style: AppTypography.h1,
          textAlign: TextAlign.center,
        ),
        AppSpacing.verticalSm,
        Text(
          'Build trust with your audience and unlock premium features.',
          style: AppTypography.body.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }


  Widget _buildBenefitsRow() {
    return const Row(
      children: [
        Expanded(
          child: _BenefitCard(
            emoji: '\u{1F6E1}\u{FE0F}',
            title: 'Trust Badge',
            description: 'Verified badge on all your events',
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _BenefitCard(
            emoji: '\u{1F441}\u{FE0F}',
            title: 'More Visibility',
            description: 'Priority placement in discovery feed',
          ),
        ),
        SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _BenefitCard(
            emoji: '\u{1F3AB}',
            title: 'Sell Tickets',
            description: 'Enable ticketing with escrow protection',
          ),
        ),
      ],
    );
  }


  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        MobTextField(
          controller: _businessNameController,
          label: 'Business / Brand Name',
          hint: 'Your business or brand name',
          prefixIcon: const Icon(
            Icons.business_outlined,
            color: AppColors.textTertiary,
            size: 20,
          ),
          textInputAction: TextInputAction.next,
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Business name is required';
            }
            return null;
          },
          onChanged: (_) => setState(() {}),
        ),
        AppSpacing.verticalLg,


        MobTextField(
          controller: _bioController,
          label: 'About You',
          hint: 'Tell us about your events and hosting experience...',
          maxLines: 3,
          maxLength: 300,
          textInputAction: TextInputAction.newline,
          onChanged: (_) => setState(() {}),
        ),
        AppSpacing.verticalLg,


        const MobSectionLabel(label: 'Verification Document'),
        AppSpacing.verticalSm,
        Text(
          'Choose one document to verify your identity',
          style: AppTypography.caption.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        AppSpacing.verticalBase,

        for (final option in _DocumentOption.values) ...[
          _DocumentTypeCard(
            option: option,
            isSelected: _selectedDocType == option,
            onTap: () {
              setState(() {
                _selectedDocType = option;

                _documentUrlController.clear();
                _removeCacFile();
              });
            },
          ),
          if (option != _DocumentOption.values.last)
            AppSpacing.verticalSm,
        ],

        AppSpacing.verticalLg,


        if (_selectedDocType != null && _selectedDocType!.isFileUpload)
          _buildCacUploadSection()
        else
          _buildUrlField(),
      ],
    );
  }


  Widget _buildCacUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CAC DOCUMENT',
          style: AppTypography.overline.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
            fontSize: 11,
          ),
        ),
        AppSpacing.verticalSm,


        if (_selectedCacFile == null && !_isUploadingFile)
          GestureDetector(
            onTap: _pickCacFile,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xl,
              ),
              decoration: BoxDecoration(
                color: AppColors.elevated,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                border: Border.all(
                  color: AppColors.border,
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.cloud_upload_outlined,
                      color: AppColors.cyan,
                      size: 24,
                    ),
                  ),
                  AppSpacing.verticalBase,
                  Text(
                    'Upload CAC Certificate',
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  AppSpacing.verticalXs,
                  Text(
                    'Take a photo or choose from gallery',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),


        if (_isUploadingFile)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: AppColors.elevated,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.border, width: 0.5),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.description_outlined,
                      color: AppColors.cyan,
                      size: 20,
                    ),
                    AppSpacing.horizontalSm,
                    Expanded(
                      child: Text(
                        _cacFileName ?? 'Uploading...',
                        style: AppTypography.body.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                AppSpacing.verticalBase,
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: _uploadProgress,
                    backgroundColor: AppColors.surface,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.cyan,
                    ),
                    minHeight: 4,
                  ),
                ),
                AppSpacing.verticalSm,
                Text(
                  '${(_uploadProgress * 100).toInt()}% uploaded',
                  style: AppTypography.micro.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ),


        if (_selectedCacFile != null &&
            !_isUploadingFile &&
            _uploadedCacUrl != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.base),
            decoration: BoxDecoration(
              color: AppColors.elevated,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: AppColors.success.withValues(alpha: 0.5),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: AppColors.success,
                    size: 22,
                  ),
                ),
                AppSpacing.horizontalMd,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _cacFileName ?? 'CAC Document',
                        style: AppTypography.body.copyWith(
                          fontWeight: FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Uploaded successfully',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.success,
                        ),
                      ),
                    ],
                  ),
                ),

                GestureDetector(
                  onTap: _pickCacFile,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: const Icon(
                      Icons.swap_horiz_rounded,
                      color: AppColors.textSecondary,
                      size: 22,
                    ),
                  ),
                ),

                GestureDetector(
                  onTap: _removeCacFile,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: const Icon(
                      Icons.close_rounded,
                      color: AppColors.error,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }


  Widget _buildUrlField() {
    return MobTextField(
      controller: _documentUrlController,
      label: _selectedDocType?.urlLabel ?? 'Document URL',
      hint: _selectedDocType?.urlHint ?? 'Select a document type first',
      prefixIcon: const Icon(
        Icons.link_rounded,
        color: AppColors.textTertiary,
        size: 20,
      ),
      keyboardType: TextInputType.url,
      textInputAction: TextInputAction.done,
      enabled: _selectedDocType != null,
      validator: (value) {

        if (_selectedDocType?.isFileUpload == true) return null;

        if (value == null || value.trim().isEmpty) {
          return 'URL is required';
        }

        final trimmed = value.trim();
        if (!trimmed.startsWith('http://') &&
            !trimmed.startsWith('https://')) {
          return 'Must be a valid URL (starting with https://)';
        }
        return null;
      },
      onChanged: (_) => setState(() {}),
    );
  }


  Widget _buildSubmitButton() {
    return BlocBuilder<HostVerificationCubit, HostVerificationState>(
      builder: (context, state) {
        final isSubmitting = state is HostVerificationSubmitting;
        return MobGradientButton(
          label: 'Submit Verification Request',
          isLoading: isSubmitting,
          onPressed: _isFormValid && !isSubmitting && !_isUploadingFile
              ? _onSubmit
              : null,
        );
      },
    );
  }


  Widget _buildReviewNote() {
    return Text(
      '\u{1F4DD} Review takes 24-48 hours. We\'ll notify you '
      'once a decision is made.',
      style: AppTypography.caption.copyWith(
        color: AppColors.textSecondary,
      ),
      textAlign: TextAlign.center,
    );
  }


  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppSpacing.verticalBase,


              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.success,
                  size: 40,
                ),
              ),

              AppSpacing.verticalLg,

              const Text(
                'Application Submitted!',
                style: AppTypography.h3,
                textAlign: TextAlign.center,
              ),

              AppSpacing.verticalSm,

              Text(
                'Your verification request has been submitted. '
                'We\'ll review it within 24-48 hours.',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),

              AppSpacing.verticalXl,

              MobGradientButton(
                label: 'View Status',
                onPressed: () {
                  Navigator.of(dialogContext).pop();
                  context.pushReplacement(RoutePaths.hostVerificationStatus);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}


class _UploadOption extends StatelessWidget {
  const _UploadOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.base,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: AppColors.elevated,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.cyan, size: 22),
            AppSpacing.horizontalMd,
            Text(
              label,
              style: AppTypography.body.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}


class _BenefitCard extends StatelessWidget {
  const _BenefitCard({
    required this.emoji,
    required this.title,
    required this.description,
  });

  final String emoji;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return MobCard(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.base,
      ),
      child: Column(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 24)),
          AppSpacing.verticalSm,
          Text(
            title,
            style: AppTypography.caption.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          AppSpacing.verticalXs,
          Text(
            description,
            style: AppTypography.micro.copyWith(
              color: AppColors.textTertiary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}


class _DocumentTypeCard extends StatelessWidget {
  const _DocumentTypeCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final _DocumentOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.base),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.cyan.withValues(alpha: 0.05)
              : AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(
            color: isSelected ? AppColors.cyan : AppColors.border,
            width: isSelected ? 1.5 : 0.5,
          ),
        ),
        child: Row(
          children: [

            Text(option.emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: AppSpacing.md),


            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: AppTypography.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isSelected
                          ? AppColors.cyan
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    option.description,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),


            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.cyan : AppColors.textTertiary,
                  width: isSelected ? 2 : 1.5,
                ),
                color: isSelected
                    ? AppColors.cyan.withValues(alpha: 0.15)
                    : Colors.transparent,
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.cyan,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
