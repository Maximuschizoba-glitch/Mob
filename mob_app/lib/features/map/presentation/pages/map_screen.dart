import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/route_paths.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/services/tab_refresh.dart';
import '../../../../shared/models/enums.dart';
import '../../../../shared/widgets/mob_chip.dart';
import '../../../feed/domain/entities/happening.dart';
import '../bloc/map_cubit.dart';
import '../bloc/map_state.dart';
import '../../../../core/constants/map_style.dart';
import '../widgets/map_marker_painter.dart';
import '../widgets/pin_preview_card.dart';


class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  GoogleMapController? _mapController;
  bool _mapReady = false;


  Happening? _selectedHappening;


  List<Happening> _happenings = const [];


  bool _hasHighActivity = false;


  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;


  static const _lagosDefault = LatLng(
    LocationService.defaultLatitude,
    LocationService.defaultLongitude,
  );

  @override
  void initState() {
    super.initState();


    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );


    _pulseController.addListener(_onPulseTick);

    context.read<MapCubit>().loadMap();


    mapTabActiveNotifier.addListener(_onTabRefresh);
  }

  void _onPulseTick() {
    if (mounted && _hasHighActivity) setState(() {});
  }

  @override
  void dispose() {
    mapTabActiveNotifier.removeListener(_onTabRefresh);
    _pulseController.removeListener(_onPulseTick);
    _pulseController.dispose();
    _mapController?.dispose();
    MapMarkerPainter.clearCache();
    super.dispose();
  }


  Future<void> _onTabRefresh() async {
    if (_mapController == null || !_mapReady) return;
    final bounds = await _mapController!.getVisibleRegion();
    if (!mounted) return;
    context.read<MapCubit>().fetchHappeningsInViewport(
          neLat: bounds.northeast.latitude,
          neLng: bounds.northeast.longitude,
          swLat: bounds.southwest.latitude,
          swLng: bounds.southwest.longitude,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          _buildMap(),


          _buildCategoryChips(),


          _buildMapControls(),


          _buildActivityLegend(),


          _buildPinPreview(),


          BlocBuilder<MapCubit, MapState>(
            buildWhen: (prev, curr) =>
                curr is MapLoading ||
                (prev is MapLoading && curr is! MapLoading),
            builder: (context, state) {
              if (state is! MapLoading) return const SizedBox.shrink();
              return const Positioned(
                top: 100,
                left: 0,
                right: 0,
                child: Center(
                  child: _MapLoadingIndicator(),
                ),
              );
            },
          ),


          BlocListener<MapCubit, MapState>(
            listenWhen: (prev, curr) => curr is MapError,
            listener: (context, state) {
              if (state is MapError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  ),
                );
              }
            },
            child: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }


  Widget _buildMap() {
    return BlocListener<MapCubit, MapState>(
      listenWhen: (prev, curr) => curr is MapLoaded,
      listener: (context, state) {
        if (state is MapLoaded) {
          _happenings = state.happenings;
          _hasHighActivity = _happenings.any(
            (h) => h.activityLevel == ActivityLevel.high,
          );
        }
      },
      child: BlocBuilder<MapCubit, MapState>(
        buildWhen: (prev, curr) => curr is MapLoaded,
        builder: (context, state) {
          if (state is MapLoaded) {
            _happenings = state.happenings;
            _hasHighActivity = _happenings.any(
              (h) => h.activityLevel == ActivityLevel.high,
            );
          }

          return FutureBuilder<Set<Marker>>(
            future: _happenings.isNotEmpty
                ? _buildMarkers(_happenings)
                : Future.value(<Marker>{}),
            builder: (context, markerSnapshot) {
              return GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: _lagosDefault,
                  zoom: 14,
                ),
                style: darkMapStyle,
                markers: markerSnapshot.data ?? {},

                circles: _buildRadarCircles(_happenings),
                myLocationEnabled: true,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: false,
                onMapCreated: _onMapCreated,
                onCameraIdle: _onCameraIdle,
                onTap: (_) => _dismissPinPreview(),
              );
            },
          );
        },
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    _mapReady = true;


    final position = await context.read<MapCubit>().getUserPosition();
    controller.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.lat, position.lng),
        14,
      ),
    );
  }

  void _onCameraIdle() async {
    if (!_mapReady || _mapController == null) return;

    final bounds = await _mapController!.getVisibleRegion();
    if (!mounted) return;
    context.read<MapCubit>().onCameraMove(
          neLat: bounds.northeast.latitude,
          neLng: bounds.northeast.longitude,
          swLat: bounds.southwest.latitude,
          swLng: bounds.southwest.longitude,
        );
  }


  Future<Set<Marker>> _buildMarkers(List<Happening> happenings) async {
    final dpr = MediaQuery.of(context).devicePixelRatio;
    final markers = <Marker>{};

    for (final h in happenings) {
      BitmapDescriptor icon;


      if (h.coverImageUrl != null && h.coverImageUrl!.isNotEmpty) {
        final imageMarker = await _createImageMarkerSafe(
          imageUrl: h.coverImageUrl!,
          category: h.category,
          activityLevel: h.activityLevel,
          dpr: dpr,
        );
        icon = imageMarker ??
            await MapMarkerPainter.createMarker(
              category: h.category,
              activityLevel: h.activityLevel,
              devicePixelRatio: dpr,
            );
      } else {

        icon = await MapMarkerPainter.createMarker(
          category: h.category,
          activityLevel: h.activityLevel,
          devicePixelRatio: dpr,
        );
      }

      markers.add(Marker(
        markerId: MarkerId(h.uuid),
        position: LatLng(h.latitude, h.longitude),
        icon: icon,
        onTap: () => _onMarkerTap(h),
      ));
    }

    return markers;
  }


  Future<BitmapDescriptor?> _createImageMarkerSafe({
    required String imageUrl,
    required HappeningCategory category,
    required ActivityLevel activityLevel,
    required double dpr,
  }) async {
    try {
      final cacheKey =
          'img_${imageUrl.hashCode}_${category.value}_${activityLevel.value}_$dpr';


      final imageProvider = NetworkImage(imageUrl);
      final imageStream = imageProvider.resolve(ImageConfiguration.empty);
      final completer = Completer<ui.Image>();

      late final ImageStreamListener listener;
      listener = ImageStreamListener(
        (info, _) {
          if (!completer.isCompleted) completer.complete(info.image);
          imageStream.removeListener(listener);
        },
        onError: (error, stackTrace) {
          if (!completer.isCompleted) completer.completeError(error);
          imageStream.removeListener(listener);
        },
      );
      imageStream.addListener(listener);

      final image = await completer.future.timeout(
        const Duration(seconds: 5),
      );

      return MapMarkerPainter.createImageMarker(
        image: image,
        category: category,
        activityLevel: activityLevel,
        devicePixelRatio: dpr,
        cacheKey: cacheKey,
      );
    } catch (e) {
      debugPrint('[Mob] Failed to load marker image: $e');
      return null;
    }
  }

  void _onMarkerTap(Happening happening) {
    setState(() => _selectedHappening = happening);
  }

  void _dismissPinPreview() {
    if (_selectedHappening != null) {
      setState(() => _selectedHappening = null);
    }
  }


  Widget _buildPinPreview() {
    final bottomOffset = MediaQuery.of(context).padding.bottom + 90;

    return AnimatedPositioned(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      left: 0,
      right: 0,
      bottom: _selectedHappening != null ? bottomOffset : -250,
      child: _selectedHappening != null
          ? PinPreviewCard(
              happening: _selectedHappening!,
              onViewDetails: () {
                context.push(
                  RoutePaths.happeningDetailPath(_selectedHappening!.uuid),
                );
              },
              onClose: _dismissPinPreview,
            )
          : const SizedBox.shrink(),
    );
  }


  Set<Circle> _buildRadarCircles(List<Happening> happenings) {
    final circles = <Circle>{};


    final double pulse = _pulseAnimation.value;

    for (final h in happenings) {
      final center = LatLng(h.latitude, h.longitude);


      if (h.isAreaBased && h.radiusMeters != null) {
        circles.add(Circle(
          circleId: CircleId('area_${h.uuid}'),
          center: center,
          radius: h.radiusMeters!,
          fillColor: h.activityLevel.color.withValues(alpha: 0.06),
          strokeColor: h.activityLevel.color.withValues(alpha: 0.15),
          strokeWidth: 1,
          consumeTapEvents: false,
        ));
      }


      switch (h.activityLevel) {
        case ActivityLevel.high:


          final fill1 = _lerp(0.08, 0.12, pulse);
          final fill2 = _lerp(0.05, 0.08, pulse);
          final fill3 = _lerp(0.03, 0.05, pulse);
          final stroke1 = _lerp(0.15, 0.22, pulse);
          final stroke2 = _lerp(0.12, 0.18, pulse);
          final stroke3 = _lerp(0.08, 0.12, pulse);

          circles.addAll([
            Circle(
              circleId: CircleId('radar_high_1_${h.uuid}'),
              center: center,
              radius: 100,
              fillColor: AppColors.activityHigh.withValues(alpha: fill1),
              strokeColor: AppColors.activityHigh.withValues(alpha: stroke1),
              strokeWidth: 1,
              consumeTapEvents: false,
            ),
            Circle(
              circleId: CircleId('radar_high_2_${h.uuid}'),
              center: center,
              radius: 200,
              fillColor: AppColors.activityHigh.withValues(alpha: fill2),
              strokeColor: AppColors.activityHigh.withValues(alpha: stroke2),
              strokeWidth: 1,
              consumeTapEvents: false,
            ),
            Circle(
              circleId: CircleId('radar_high_3_${h.uuid}'),
              center: center,
              radius: 300,
              fillColor: AppColors.activityHigh.withValues(alpha: fill3),
              strokeColor: AppColors.activityHigh.withValues(alpha: stroke3),
              strokeWidth: 1,
              consumeTapEvents: false,
            ),
          ]);

        case ActivityLevel.medium:

          circles.addAll([
            Circle(
              circleId: CircleId('radar_med_1_${h.uuid}'),
              center: center,
              radius: 100,
              fillColor: AppColors.activityMedium.withValues(alpha: 0.06),
              strokeColor: AppColors.activityMedium.withValues(alpha: 0.10),
              strokeWidth: 1,
              consumeTapEvents: false,
            ),
            Circle(
              circleId: CircleId('radar_med_2_${h.uuid}'),
              center: center,
              radius: 200,
              fillColor: AppColors.activityMedium.withValues(alpha: 0.03),
              strokeColor: AppColors.activityMedium.withValues(alpha: 0.06),
              strokeWidth: 1,
              consumeTapEvents: false,
            ),
          ]);

        case ActivityLevel.low:
          break;
      }
    }

    return circles;
  }


  static double _lerp(double a, double b, double t) => a + (b - a) * t;


  Widget _buildCategoryChips() {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 8,
      left: 0,
      right: 0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.background.withAlpha(230),
              AppColors.background.withAlpha(0),
            ],
            stops: const [0.7, 1.0],
          ),
        ),
        padding: const EdgeInsets.only(bottom: 12),
        child: BlocSelector<MapCubit, MapState, String?>(
          selector: (state) {
            if (state is MapLoaded) return state.activeCategory;
            return context.read<MapCubit>().activeCategory;
          },
          builder: (context, activeCategory) {
            return SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [

                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: MobChip(
                      label: 'All',
                      isActive: activeCategory == null,
                      onTap: () => _onCategoryTap(null),
                    ),
                  ),

                  ...HappeningCategory.values.map((cat) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: MobChip(
                        label: '${cat.emoji} ${cat.displayName}',
                        isActive: activeCategory == cat.value,
                        activeColor: cat.color,
                        onTap: () => _onCategoryTap(cat.value),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _onCategoryTap(String? category) {
    final cubit = context.read<MapCubit>();
    cubit.filterByCategory(category);

    _onCameraIdle();
  }


  Widget _buildMapControls() {
    return Positioned(
      right: 16,
      bottom: MediaQuery.of(context).padding.bottom + 100,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _MapControlButton(
            icon: Icons.my_location,
            onTap: _recenterMap,
          ),
          const SizedBox(height: 8),
          _MapControlButton(
            icon: Icons.add,
            onTap: () => _mapController?.animateCamera(CameraUpdate.zoomIn()),
          ),
          const SizedBox(height: 8),
          _MapControlButton(
            icon: Icons.remove,
            onTap: () => _mapController?.animateCamera(CameraUpdate.zoomOut()),
          ),
        ],
      ),
    );
  }

  Future<void> _recenterMap() async {
    if (_mapController == null) return;
    final position = await context.read<MapCubit>().getUserPosition();
    _mapController!.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(position.lat, position.lng),
        14,
      ),
    );
  }


  Widget _buildActivityLegend() {
    return Positioned(
      left: 16,
      bottom: MediaQuery.of(context).padding.bottom + 100,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.card.withAlpha(230),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _legendDot(AppColors.activityHigh, 'Hot'),
            const SizedBox(width: 10),
            _legendDot(AppColors.activityMedium, 'Active'),
            const SizedBox(width: 10),
            _legendDot(AppColors.activityLow, 'Chill'),
          ],
        ),
      ),
    );
  }

  Widget _legendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTypography.micro.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}


class _MapControlButton extends StatelessWidget {
  const _MapControlButton({
    required this.icon,
    required this.onTap,
  });

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: AppColors.card,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(64),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _MapLoadingIndicator extends StatelessWidget {
  const _MapLoadingIndicator();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.card.withAlpha(230),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: AppColors.cyan,
            ),
          ),
          SizedBox(width: 8),
          Text(
            'Loading map...',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
