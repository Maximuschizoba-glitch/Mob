import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/services/firebase_storage_service.dart';
import '../../../../core/utils/image_compressor.dart';
import '../../../../core/utils/video_processor.dart';
import '../../../auth/presentation/bloc/auth_cubit.dart';
import '../bloc/snaps_cubit.dart';
import '../bloc/snaps_state.dart';


class SnapUploadScreen extends StatefulWidget {
  const SnapUploadScreen({
    super.key,
    required this.happeningUuid,
    this.happeningTitle = '',
  });

  final String happeningUuid;
  final String happeningTitle;

  @override
  State<SnapUploadScreen> createState() => _SnapUploadScreenState();
}

class _SnapUploadScreenState extends State<SnapUploadScreen> {
  final ImagePicker _picker = ImagePicker();
  final VideoProcessor _videoProcessor = VideoProcessor();


  File? _selectedFile;
  String _mediaType = 'image';


  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;


  bool _isCompressing = false;
  double _compressionProgress = 0.0;


  bool _isUploadingToFirebase = false;
  double _firebaseUploadProgress = 0.0;
  String _uploadStatusText = '';


  int? _videoDurationSeconds;


  File? _videoThumbnail;

  @override
  void dispose() {
    _videoController?.dispose();
    _videoProcessor.cancelCompression();
    super.dispose();
  }


  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1920,
      );
      if (photo != null) {
        await _setImageFile(File(photo.path));
      }
    } on PlatformException catch (e) {
      if (mounted) _showPermissionDeniedDialog(e.message ?? 'camera');
    }
  }

  Future<void> _recordVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: maxVideoDurationSeconds),
      );
      if (video != null) {
        await _processVideoFile(File(video.path));
      }
    } on PlatformException catch (e) {
      if (mounted) _showPermissionDeniedDialog(e.message ?? 'camera');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? file = await _picker.pickMedia();
      if (file == null) return;

      final path = file.path.toLowerCase();
      final isVideo = path.endsWith('.mp4') ||
          path.endsWith('.mov') ||
          path.endsWith('.avi') ||
          path.endsWith('.mkv') ||
          path.endsWith('.webm') ||
          path.endsWith('.3gp') ||
          (file.mimeType?.startsWith('video/') ?? false);

      if (isVideo) {
        await _processVideoFile(File(file.path));
      } else {
        await _setImageFile(File(file.path));
      }
    } on PlatformException catch (e) {
      if (mounted) _showPermissionDeniedDialog(e.message ?? 'photo library');
    }
  }


  Future<void> _setImageFile(File file) async {
    _disposeVideoController();


    final compressed = await ImageCompressor.compress(file);

    if (!mounted) return;
    setState(() {
      _selectedFile = compressed;
      _mediaType = 'image';
      _videoThumbnail = null;
    });
  }

  Future<void> _processVideoFile(File videoFile) async {
    setState(() {
      _isCompressing = true;
      _compressionProgress = 0.0;
    });

    try {
      final result = await _videoProcessor.processForUpload(
        videoFile,
        onProgress: (progress) {
          if (mounted) {
            setState(() => _compressionProgress = progress);
          }
        },
      );

      if (!mounted) return;

      setState(() {
        _isCompressing = false;
        _selectedFile = result.compressedFile;
        _mediaType = 'video';
        _videoDurationSeconds = result.durationSeconds;
        _videoThumbnail = result.thumbnail;
      });

      await _initVideoPreview(result.compressedFile);
    } on VideoTooLongException catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.message);
        setState(() => _isCompressing = false);
      }
    } on VideoCompressionException catch (e) {
      if (mounted) {
        _showErrorSnackBar(e.message);
        setState(() => _isCompressing = false);
      }
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar('Video processing failed: $e');
        setState(() => _isCompressing = false);
      }
    }
  }


  Future<void> _initVideoPreview(File videoFile) async {
    _disposeVideoController();

    final controller = VideoPlayerController.file(videoFile);
    _videoController = controller;

    try {
      await controller.initialize();
      controller.setLooping(true);
      controller.setVolume(0.0);
      controller.play();

      if (mounted) {
        setState(() => _isVideoInitialized = true);
      }
    } catch (_) {

    }
  }

  void _disposeVideoController() {
    _videoController?.dispose();
    _videoController = null;
    _isVideoInitialized = false;
  }

  void _toggleVideoPlayback() {
    final controller = _videoController;
    if (controller == null || !_isVideoInitialized) return;

    setState(() {
      if (controller.value.isPlaying) {
        controller.pause();
      } else {
        controller.play();
      }
    });
  }


  Future<void> _uploadSnap() async {
    if (_selectedFile == null) return;

    final authCubit = context.read<AuthCubit>();
    final userId = authCubit.currentUser?.uuid;
    if (userId == null) {
      _showErrorSnackBar('You must be signed in to upload snaps.');
      return;
    }

    final firebaseStorage = context.read<FirebaseStorageService>();
    final snapsCubit = context.read<SnapsCubit>();

    setState(() {
      _isUploadingToFirebase = true;
      _firebaseUploadProgress = 0.0;
      _uploadStatusText = 'Uploading media...';
    });

    try {

      final mediaUrl = await firebaseStorage.uploadSnapMedia(
        file: _selectedFile!,
        userId: userId,
        mediaType: _mediaType,
        onProgress: (progress) {
          if (mounted) {
            setState(() => _firebaseUploadProgress = progress);
          }
        },
      );


      String? thumbnailUrl;
      if (_mediaType == 'video' && _videoThumbnail != null) {
        if (mounted) {
          setState(() => _uploadStatusText = 'Uploading thumbnail...');
        }
        thumbnailUrl = await firebaseStorage.uploadSnapThumbnail(
          file: _videoThumbnail!,
          userId: userId,
        );
      }

      if (!mounted) return;

      setState(() {
        _isUploadingToFirebase = false;
        _uploadStatusText = 'Saving snap...';
      });


      snapsCubit.uploadSnap(
        mediaUrl: mediaUrl,
        mediaType: _mediaType,
        thumbnailUrl: thumbnailUrl,
        durationSeconds: _mediaType == 'video' ? _videoDurationSeconds : null,
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _isUploadingToFirebase = false;
          _uploadStatusText = '';
        });
        _showErrorSnackBar('Upload failed: $e');
      }
    }
  }


  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  void _showPermissionDeniedDialog(String detail) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.card,
        title: const Text(
          'Permission Required',
          style: AppTypography.h4,
        ),
        content: Text(
          'Mob needs access to your $detail to add snaps. '
          'Please enable it in your device settings.',
          style: AppTypography.body.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'OK',
              style: AppTypography.buttonSmall.copyWith(
                color: AppColors.cyan,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _clearSelection() {
    _disposeVideoController();
    setState(() {
      _selectedFile = null;
      _mediaType = 'image';
      _videoThumbnail = null;
      _videoDurationSeconds = null;
      _isUploadingToFirebase = false;
      _firebaseUploadProgress = 0.0;
      _uploadStatusText = '';
    });
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<SnapsCubit, SnapsState>(
        listener: (context, state) {
          if (state is SnapUploaded) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Snap uploaded!'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 2),
              ),
            );
            context.pop();
          } else if (state is SnapsError) {
            setState(() {
              _isUploadingToFirebase = false;
              _uploadStatusText = '';
            });
            _showErrorSnackBar(state.message);
          }
        },
        builder: (context, state) {
          final isApiUploading = state is SnapUploading;
          final isBusy = _isUploadingToFirebase || isApiUploading;

          return SafeArea(
            child: Column(
              children: [
                _buildAppBar(isBusy),
                Expanded(
                  child: _isCompressing
                      ? _buildCompressionProgress()
                      : _selectedFile == null
                          ? _buildSourceSelection()
                          : _buildPreview(),
                ),
                _buildBottomBar(state, isBusy),
              ],
            ),
          );
        },
      ),
    );
  }


  Widget _buildAppBar(bool isBusy) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [

          GestureDetector(
            onTap: isBusy ? null : () => context.pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.elevated,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.close,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          AppSpacing.horizontalMd,

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add Snap', style: AppTypography.h4),
                if (widget.happeningTitle.isNotEmpty)
                  Text(
                    widget.happeningTitle,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textTertiary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildSourceSelection() {
    return Padding(
      padding: AppSpacing.screenPadding,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Container(
            width: 120,
            height: 120,
            decoration: const BoxDecoration(
              color: AppColors.elevated,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt_outlined,
              color: AppColors.cyan,
              size: 48,
            ),
          ),
          AppSpacing.verticalXl,
          const Text(
            'Add a snap',
            style: AppTypography.h3,
          ),
          AppSpacing.verticalSm,
          Text(
            'Share what\'s happening right now',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          AppSpacing.verticalXxl,


          _buildSourceButton(
            icon: Icons.camera_alt,
            label: 'Take Photo',
            onTap: _takePhoto,
          ),
          AppSpacing.verticalMd,
          _buildSourceButton(
            icon: Icons.videocam,
            label: 'Record Video',
            onTap: _recordVideo,
          ),
          AppSpacing.verticalMd,
          _buildSourceButton(
            icon: Icons.photo_library_outlined,
            label: 'Choose from Gallery',
            onTap: _pickFromGallery,
          ),

          AppSpacing.verticalXl,

          const Text(
            '\u{1F4F9} Videos: max 30 seconds \u00B7 Images: max 10MB',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w400,
              color: AppColors.textTertiary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: AppSpacing.buttonHeight,
        decoration: BoxDecoration(
          color: AppColors.elevated,
          borderRadius: AppSpacing.buttonRadius,
          border: Border.all(color: AppColors.surface, width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.cyan, size: 22),
            AppSpacing.horizontalMd,
            Text(
              label,
              style: AppTypography.buttonSmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildCompressionProgress() {
    return Center(
      child: Padding(
        padding: AppSpacing.screenPadding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            SizedBox(
              width: 80,
              height: 80,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: _compressionProgress,
                    color: AppColors.cyan,
                    backgroundColor: AppColors.surface,
                    strokeWidth: 4,
                  ),
                  Text(
                    '${(_compressionProgress * 100).toInt()}%',
                    style: AppTypography.buttonSmall.copyWith(
                      color: AppColors.cyan,
                    ),
                  ),
                ],
              ),
            ),
            AppSpacing.verticalXl,
            Text(
              'Optimizing video...',
              style: AppTypography.body.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            AppSpacing.verticalSm,
            Text(
              'This may take a moment',
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildPreview() {
    return Column(
      children: [
        Expanded(
          child: _mediaType == 'video'
              ? _buildVideoPreview()
              : _buildImagePreview(),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Stack(
      fit: StackFit.expand,
      children: [

        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: Image.file(
            _selectedFile!,
            fit: BoxFit.contain,
          ),
        ),

        Positioned(
          top: AppSpacing.base,
          right: AppSpacing.base,
          child: _buildChangeButton(),
        ),
      ],
    );
  }

  Widget _buildVideoPreview() {
    return Stack(
      fit: StackFit.expand,
      children: [

        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          child: _isVideoInitialized
              ? GestureDetector(
                  onTap: _toggleVideoPlayback,
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    ),
                  ),
                )
              : _videoThumbnail != null
                  ? Image.file(_videoThumbnail!, fit: BoxFit.contain)
                  : const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.cyan,
                      ),
                    ),
        ),


        if (_isVideoInitialized)
          Positioned.fill(
            child: GestureDetector(
              onTap: _toggleVideoPlayback,
              behavior: HitTestBehavior.translucent,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity:
                    (_videoController?.value.isPlaying ?? false) ? 0.0 : 1.0,
                child: Center(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: AppColors.textPrimary,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),
          ),


        if (_isVideoInitialized)
          Positioned(
            bottom: AppSpacing.base,
            left: AppSpacing.base,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: ValueListenableBuilder<VideoPlayerValue>(
                valueListenable: _videoController!,
                builder: (context, value, _) {
                  return Text(
                    '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
                    style: AppTypography.micro.copyWith(
                      color: AppColors.textPrimary,
                    ),
                  );
                },
              ),
            ),
          ),


        Positioned(
          top: AppSpacing.base,
          right: AppSpacing.base,
          child: _buildChangeButton(),
        ),


        Positioned(
          top: AppSpacing.base,
          left: AppSpacing.base,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.purple.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.videocam, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  'VIDEO',
                  style: AppTypography.micro.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChangeButton() {
    return GestureDetector(
      onTap: _clearSelection,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.6),
          borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.refresh, color: AppColors.textPrimary, size: 16),
            const SizedBox(width: 4),
            Text(
              'Change',
              style: AppTypography.caption.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildBottomBar(SnapsState state, bool isBusy) {
    if (_selectedFile == null && !_isCompressing) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg,
      ),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(color: AppColors.surface, width: 0.5),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          GestureDetector(
            onTap: isBusy || _isCompressing ? null : _uploadSnap,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: isBusy || _isCompressing ? 0.5 : 1.0,
              child: Container(
                width: double.infinity,
                height: AppSpacing.buttonHeight,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: AppSpacing.buttonRadius,
                ),
                child: Center(
                  child: isBusy
                      ? _buildUploadProgress(state)
                      : const Text(
                          'Upload Snap',
                          style: AppTypography.button,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadProgress(SnapsState state) {

    final String statusText;
    final int percent;

    if (_isUploadingToFirebase) {
      percent = (_firebaseUploadProgress * 100).toInt();
      statusText = _uploadStatusText.isNotEmpty
          ? '$_uploadStatusText $percent%'
          : 'Uploading... $percent%';
    } else if (state is SnapUploading) {
      percent = (state.progress * 100).toInt();
      statusText = 'Saving snap... $percent%';
    } else {
      percent = 0;
      statusText = _uploadStatusText.isNotEmpty
          ? _uploadStatusText
          : 'Processing...';
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            color: AppColors.textPrimary,
            strokeWidth: 2,
          ),
        ),
        AppSpacing.horizontalSm,
        Text(
          statusText,
          style: AppTypography.button,
        ),
      ],
    );
  }
}
