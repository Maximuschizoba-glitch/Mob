import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../shared/widgets/mob_avatar.dart';
import '../../../../shared/widgets/mob_badge.dart';
import '../../domain/entities/snap.dart';
import '../bloc/snaps_cubit.dart';
import '../bloc/snaps_state.dart';
import '../widgets/snap_progress_bars.dart';


class SnapViewerScreen extends StatefulWidget {
  const SnapViewerScreen({
    super.key,
    required this.happeningUuid,
    required this.happeningTitle,
    this.startIndex = 0,
  });

  final String happeningUuid;
  final String happeningTitle;
  final int startIndex;

  @override
  State<SnapViewerScreen> createState() => _SnapViewerScreenState();
}

class _SnapViewerScreenState extends State<SnapViewerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressController;


  double _dragOffset = 0.0;


  bool _isPaused = false;


  bool _isMuted = true;


  bool _videoPlaybackFailed = false;


  VideoPlayerController? _activeVideoController;


  VideoPlayerController? _preloadVideoController;


  int _preloadedIndex = -1;


  int _currentIndex = -1;

  @override
  void initState() {
    super.initState();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..addStatusListener(_onProgressComplete);


    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);


    context.read<SnapsCubit>().loadSnaps(widget.happeningUuid);
  }

  @override
  void dispose() {
    _progressController.dispose();
    _disposeActiveVideo();
    _disposePreloadVideo();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }


  void _disposeActiveVideo() {
    _activeVideoController?.removeListener(_onVideoTick);
    _activeVideoController?.dispose();
    _activeVideoController = null;
  }

  void _disposePreloadVideo() {
    _preloadVideoController?.dispose();
    _preloadVideoController = null;
    _preloadedIndex = -1;
  }


  void _onSnapChanged(List<Snap> snaps, int index) {
    if (index == _currentIndex) return;
    _currentIndex = index;
    _videoPlaybackFailed = false;


    _disposeActiveVideo();

    final snap = snaps[index];

    if (snap.isVideo) {

      if (_preloadedIndex == index && _preloadVideoController != null) {
        _activeVideoController = _preloadVideoController;
        _preloadVideoController = null;
        _preloadedIndex = -1;
        _startVideoSnap(snap, _activeVideoController!);
      } else {
        _disposePreloadVideo();
        _initVideoController(snap).then((controller) {
          if (!mounted || _currentIndex != index) {
            controller?.dispose();
            return;
          }
          if (controller == null) {

            _handleVideoPlaybackFailure(snap);
            return;
          }
          _activeVideoController = controller;
          _startVideoSnap(snap, controller);
        });
      }
    } else {

      _progressController.duration = const Duration(seconds: 5);
      _startProgress();
    }


    _preloadNextVideo(snaps, index);
  }


  Future<VideoPlayerController?> _initVideoController(Snap snap) async {
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(snap.mediaUrl),
    );

    try {
      await controller.initialize();
    } catch (e) {
      debugPrint('[Mob] Video init failed: $e');
      controller.dispose();
      return null;
    }


    if (controller.value.hasError) {
      debugPrint(
        '[Mob] Video error after init: ${controller.value.errorDescription}',
      );
      controller.dispose();
      return null;
    }

    controller.setVolume(_isMuted ? 0.0 : 1.0);
    controller.setLooping(false);
    return controller;
  }

  void _startVideoSnap(Snap snap, VideoPlayerController controller) {
    if (!mounted) return;


    final videoDuration = controller.value.duration;
    if (videoDuration > Duration.zero) {
      _progressController.duration = videoDuration;
    } else {
      _progressController.duration = Duration(
        seconds: snap.durationSeconds ?? 5,
      );
    }

    controller.setVolume(_isMuted ? 0.0 : 1.0);
    controller.addListener(_onVideoTick);
    controller.play();
    _startProgress();

    if (mounted) setState(() {});
  }


  void _handleVideoPlaybackFailure(Snap snap) {
    _disposeActiveVideo();

    if (!mounted) return;

    setState(() => _videoPlaybackFailed = true);


    _progressController.duration = const Duration(seconds: 5);
    _startProgress();
  }

  void _onVideoTick() {
    if (!mounted) return;
    final controller = _activeVideoController;
    if (controller == null) return;

    final value = controller.value;


    if (value.hasError) {
      debugPrint('[Mob] Video runtime error: ${value.errorDescription}');
      final snap = _currentSnapOrNull;
      if (snap != null) {
        _handleVideoPlaybackFailure(snap);
      }
      return;
    }


    if (value.isInitialized &&
        value.duration > Duration.zero &&
        !_isPaused) {
      final fraction =
          value.position.inMilliseconds / value.duration.inMilliseconds;

      if ((_progressController.value - fraction).abs() > 0.02) {
        _progressController.value = fraction.clamp(0.0, 1.0);
      }
    }


    if (value.isCompleted) {
      controller.removeListener(_onVideoTick);
      _onProgressComplete(AnimationStatus.completed);
    }


    if (mounted) setState(() {});
  }

  void _preloadNextVideo(List<Snap> snaps, int currentIndex) {
    _disposePreloadVideo();

    final nextIndex = currentIndex + 1;
    if (nextIndex >= snaps.length) return;

    final nextSnap = snaps[nextIndex];
    if (!nextSnap.isVideo) return;

    _preloadedIndex = nextIndex;
    _initVideoController(nextSnap).then((controller) {
      if (!mounted || _preloadedIndex != nextIndex) {
        controller?.dispose();
        return;
      }
      if (controller == null) {

        _preloadedIndex = -1;
        return;
      }
      _preloadVideoController = controller;
    });
  }


  void _onProgressComplete(AnimationStatus status) {
    if (status == AnimationStatus.completed) {
      final state = context.read<SnapsCubit>().state;
      if (state is SnapsLoaded) {
        if (state.currentIndex < state.snaps.length - 1) {
          context.read<SnapsCubit>().nextSnap();
        } else {
          _closeViewer();
        }
      }
    }
  }

  void _startProgress() {
    _progressController
      ..reset()
      ..forward();
  }

  void _pauseProgress() {
    _progressController.stop();
    _activeVideoController?.pause();
    setState(() => _isPaused = true);
  }

  void _resumeProgress() {
    _activeVideoController?.play();


    final snap = _currentSnapOrNull;
    if (snap != null && !snap.isVideo) {
      _progressController.forward();
    }
    setState(() => _isPaused = false);
  }

  Snap? get _currentSnapOrNull {
    final state = context.read<SnapsCubit>().state;
    if (state is SnapsLoaded) {
      return state.snaps[state.currentIndex];
    }
    return null;
  }

  void _closeViewer() {
    if (mounted) context.pop();
  }

  void _onTapLeft() {
    final cubit = context.read<SnapsCubit>();
    final state = cubit.state;
    if (state is SnapsLoaded && state.currentIndex > 0) {
      cubit.previousSnap();
    }
  }

  void _onTapRight() {
    final cubit = context.read<SnapsCubit>();
    final state = cubit.state;
    if (state is SnapsLoaded) {
      if (state.currentIndex < state.snaps.length - 1) {
        cubit.nextSnap();
      } else {
        _closeViewer();
      }
    }
  }

  void _toggleMute() {
    setState(() => _isMuted = !_isMuted);
    _activeVideoController?.setVolume(_isMuted ? 0.0 : 1.0);
  }

  String _formatTimeAgo(DateTime? createdAt) {
    if (createdAt == null) return '';
    final diff = DateTime.now().difference(createdAt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: BlocConsumer<SnapsCubit, SnapsState>(
        listener: (context, state) {
          if (state is SnapsLoaded) {

            if (state.currentIndex == 0 && widget.startIndex > 0) {
              context.read<SnapsCubit>().goToSnap(widget.startIndex);
            }
            _onSnapChanged(state.snaps, state.currentIndex);
          } else if (state is SnapsEmpty) {
            _closeViewer();
          } else if (state is SnapsError) {
            Future.delayed(const Duration(seconds: 2), _closeViewer);
          }
        },
        listenWhen: (prev, curr) {
          if (prev is SnapsLoaded && curr is SnapsLoaded) {
            if (prev.currentIndex != curr.currentIndex) {
              _onSnapChanged(curr.snaps, curr.currentIndex);
            }
          }
          return true;
        },
        builder: (context, state) {
          if (state is SnapsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.cyan),
            );
          }

          if (state is SnapsError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.error,
                    size: 48,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    state.message,
                    style: AppTypography.body.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          if (state is SnapsLoaded) {
            return _buildViewer(context, state);
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildViewer(BuildContext context, SnapsLoaded state) {
    final snap = state.snaps[state.currentIndex];
    final screenSize = MediaQuery.of(context).size;
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;


    final dragFraction =
        (_dragOffset.abs() / screenSize.height).clamp(0.0, 1.0);
    final scale = 1.0 - (dragFraction * 0.15);
    final borderRadius = dragFraction > 0
        ? BorderRadius.circular(16 * dragFraction)
        : BorderRadius.zero;

    return GestureDetector(

      onVerticalDragUpdate: (details) {
        setState(() => _dragOffset += details.delta.dy);
        if (!_isPaused) _pauseProgress();
      },
      onVerticalDragEnd: (details) {
        if (_dragOffset > 100) {
          _closeViewer();
        } else {
          setState(() => _dragOffset = 0.0);
          if (_isPaused) _resumeProgress();
        }
      },

      onLongPressStart: (_) => _pauseProgress(),
      onLongPressEnd: (_) => _resumeProgress(),
      child: Transform.translate(
        offset: Offset(0, _dragOffset.clamp(0.0, double.infinity)),
        child: Transform.scale(
          scale: scale,
          child: ClipRRect(
            borderRadius: borderRadius,
            child: Container(
              color: Colors.black,
              child: Stack(
                fit: StackFit.expand,
                children: [

                  _buildMedia(snap, screenSize),


                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: screenSize.height * 0.3,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0x99000000),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),


                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: screenSize.height * 0.25,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [
                            Color(0x99000000),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  ),


                  Positioned(
                    top: topPadding + AppSpacing.sm,
                    left: AppSpacing.md,
                    right: AppSpacing.md,
                    child: Column(
                      children: [
                        SnapProgressBars(
                          totalSnaps: state.snaps.length,
                          currentIndex: state.currentIndex,
                          controller: _progressController,
                          snapDurations: state.snaps
                              .map((s) => s.isVideo
                                  ? (s.durationSeconds ?? 5)
                                  : 5)
                              .toList(),
                        ),
                        const SizedBox(height: 4),
                        _buildUserInfoRow(snap),
                      ],
                    ),
                  ),


                  Positioned(
                    bottom: bottomPadding + AppSpacing.base,
                    left: AppSpacing.base,
                    right: AppSpacing.base,
                    child: _buildBottomInfo(snap),
                  ),


                  if (snap.isVideo && !_videoPlaybackFailed) ...[

                    if (_isPaused &&
                        _activeVideoController != null &&
                        !(_activeVideoController!.value.isPlaying))
                      Center(
                        child: Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow_rounded,
                            color: AppColors.textPrimary,
                            size: 40,
                          ),
                        ),
                      ),


                    Positioned(
                      bottom: bottomPadding + 56,
                      right: AppSpacing.base,
                      child: GestureDetector(
                        onTap: _toggleMute,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.5),
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            _isMuted
                                ? Icons.volume_off_rounded
                                : Icons.volume_up_rounded,
                            color: AppColors.textPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                    ),


                    if (_activeVideoController != null &&
                        _activeVideoController!.value.isInitialized)
                      Positioned(
                        bottom: bottomPadding + 60,
                        left: AppSpacing.base,
                        child: Text(
                          '${_formatDuration(_activeVideoController!.value.position)}'
                          ' / '
                          '${_formatDuration(_activeVideoController!.value.duration)}',
                          style: AppTypography.caption.copyWith(
                            color:
                                AppColors.textPrimary.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],


                  Positioned.fill(
                    child: Row(
                      children: [
                        Expanded(
                          flex: 30,
                          child: GestureDetector(
                            onTap: _onTapLeft,
                            behavior: HitTestBehavior.translucent,
                            child: const SizedBox.expand(),
                          ),
                        ),
                        Expanded(
                          flex: 70,
                          child: GestureDetector(
                            onTap: _onTapRight,
                            behavior: HitTestBehavior.translucent,
                            child: const SizedBox.expand(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Widget _buildMedia(Snap snap, Size screenSize) {
    if (snap.isVideo) {
      return _buildVideoMedia(snap, screenSize);
    }
    return _buildImageMedia(snap, screenSize);
  }

  Widget _buildImageMedia(Snap snap, Size screenSize) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: CachedNetworkImage(
        key: ValueKey(snap.uuid),
        imageUrl: snap.mediaUrl,
        fit: BoxFit.cover,
        width: screenSize.width,
        height: screenSize.height,
        placeholder: (_, __) => _buildMediaPlaceholder(),
        errorWidget: (_, __, ___) => _buildMediaError(),
      ),
    );
  }

  Widget _buildVideoMedia(Snap snap, Size screenSize) {

    if (_videoPlaybackFailed) {
      return _buildVideoFallback(snap, screenSize);
    }

    final controller = _activeVideoController;

    if (controller == null || !controller.value.isInitialized) {

      if (snap.thumbnailUrl != null) {
        return CachedNetworkImage(
          key: ValueKey('thumb_${snap.uuid}'),
          imageUrl: snap.thumbnailUrl!,
          fit: BoxFit.cover,
          width: screenSize.width,
          height: screenSize.height,
          placeholder: (_, __) => _buildMediaPlaceholder(),
          errorWidget: (_, __, ___) => _buildMediaPlaceholder(),
        );
      }
      return _buildMediaPlaceholder();
    }


    final videoSize = controller.value.size;
    final videoAspect = videoSize.width > 0
        ? videoSize.width / videoSize.height
        : 9.0 / 16.0;
    final screenAspect = screenSize.width / screenSize.height;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: SizedBox.expand(
        key: ValueKey('video_${snap.uuid}'),
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: videoAspect > screenAspect
                ? screenSize.height * videoAspect
                : screenSize.width,
            height: videoAspect > screenAspect
                ? screenSize.height
                : screenSize.width / videoAspect,
            child: VideoPlayer(controller),
          ),
        ),
      ),
    );
  }


  Widget _buildVideoFallback(Snap snap, Size screenSize) {
    return Stack(
      fit: StackFit.expand,
      children: [

        if (snap.thumbnailUrl != null)
          CachedNetworkImage(
            key: ValueKey('fallback_${snap.uuid}'),
            imageUrl: snap.thumbnailUrl!,
            fit: BoxFit.cover,
            width: screenSize.width,
            height: screenSize.height,
            placeholder: (_, __) => Container(color: Colors.black),
            errorWidget: (_, __, ___) => Container(color: Colors.black),
          )
        else
          Container(color: Colors.black),


        Center(
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.videocam_off_rounded,
                  color: AppColors.textTertiary,
                  size: 36,
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  'Video unavailable',
                  style: TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaPlaceholder() {
    return Container(
      color: AppColors.background,
      child: const Center(
        child: CircularProgressIndicator(
          color: AppColors.cyan,
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildMediaError() {
    return Container(
      color: AppColors.background,
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: AppColors.textTertiary,
          size: 48,
        ),
      ),
    );
  }


  Widget _buildUserInfoRow(Snap snap) {
    return Row(
      children: [
        MobAvatar(
          imageUrl: snap.uploaderAvatarUrl,
          size: 32,
          initials: snap.uploaderName?.isNotEmpty == true
              ? snap.uploaderName!.substring(0, 1)
              : '?',
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                snap.uploaderName ?? 'Anonymous',
                style: AppTypography.buttonSmall.copyWith(
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _formatTimeAgo(snap.createdAt),
                style: AppTypography.caption.copyWith(
                  color: AppColors.textPrimary.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: _closeViewer,
          child: Container(
            width: 32,
            height: 32,
            alignment: Alignment.center,
            child: const Icon(
              Icons.close,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomInfo(Snap snap) {
    return Row(
      children: [
        MobBadge(
          label: widget.happeningTitle.length > 20
              ? '${widget.happeningTitle.substring(0, 20)}...'
              : widget.happeningTitle,
          color: AppColors.cyan,
        ),
        const Spacer(),
        GestureDetector(
          onTap: () {
            context.pop();
            context.push(
              RoutePaths.happeningDetailPath(widget.happeningUuid),
            );
          },
          child: Text(
            'View Happening \u203A',
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.cyan,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
