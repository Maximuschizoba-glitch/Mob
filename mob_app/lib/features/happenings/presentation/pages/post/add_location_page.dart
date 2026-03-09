import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../../../core/constants/app_colors.dart';
import '../../../../../core/constants/app_spacing.dart';
import '../../../../../core/constants/app_typography.dart';
import '../../../../../core/constants/map_style.dart';
import '../../../../../core/services/location_service.dart';
import '../../../../../shared/widgets/mob_gradient_button.dart';
import '../../../../../shared/widgets/mob_text_button.dart';
import '../../bloc/post_happening_cubit.dart';
import '../../bloc/post_happening_state.dart';


class AddLocationPage extends StatefulWidget {
  const AddLocationPage({super.key});

  @override
  State<AddLocationPage> createState() => _AddLocationPageState();
}

class _AddLocationPageState extends State<AddLocationPage> {
  GoogleMapController? _mapController;
  bool _mapReady = false;


  double? _latitude;
  double? _longitude;
  String? _address;


  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  List<geo.Location> _searchResults = [];
  List<String> _searchLabels = [];
  bool _isSearching = false;
  bool _showSearchResults = false;


  double _radiusMeters = 500;


  late LatLng _initialPosition;

  @override
  void initState() {
    super.initState();

    final state = context.read<PostHappeningCubit>().state;


    if (state.latitude != null && state.longitude != null) {
      _latitude = state.latitude;
      _longitude = state.longitude;
      _address = state.address;
      _initialPosition = LatLng(state.latitude!, state.longitude!);
      if (state.radiusMeters != null) {
        _radiusMeters = state.radiusMeters!;
      }
    } else {
      _initialPosition = const LatLng(
        LocationService.defaultLatitude,
        LocationService.defaultLongitude,
      );
    }


    if (state.latitude == null) {
      _resolveInitialPosition();
    }
  }

  Future<void> _resolveInitialPosition() async {
    final locationService = context.read<LocationService>();
    final pos = await locationService.getPositionOrDefault();
    if (mounted && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLng(LatLng(pos.lat, pos.lng)),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PostHappeningCubit, PostHappeningState>(
      builder: (context, state) {
        return Column(
          children: [
            _buildAppBar(context),
            _buildProgressBar(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: AppSpacing.screenPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppSpacing.verticalLg,
                          _buildSearchBar(),
                        ],
                      ),
                    ),
                    if (_showSearchResults && _searchLabels.isNotEmpty)
                      _buildSearchResultsList(),
                    AppSpacing.verticalMd,
                    _buildMapSection(state),
                    Padding(
                      padding: AppSpacing.screenPadding,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AppSpacing.verticalMd,
                          if (_address != null) _buildSelectedLocationCard(),
                          if (state.isCasual) ...[
                            AppSpacing.verticalLg,
                            _buildLocationTypeToggle(state),
                            if (!state.useExactLocation) ...[
                              AppSpacing.verticalMd,
                              _buildRadiusSlider(),
                            ],
                          ],
                          if (state.error != null) ...[
                            AppSpacing.verticalLg,
                            _buildErrorMessage(state.error!),
                          ],
                          AppSpacing.verticalLg,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomBar(context, state),
          ],
        );
      },
    );
  }


  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.base,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.read<PostHappeningCubit>().previousStep(),
            child: Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.elevated,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back,
                color: AppColors.textPrimary,
                size: 20,
              ),
            ),
          ),
          const Expanded(
            child: Text(
              'Add Location',
              style: AppTypography.h4,
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            'Step 3 of 4',
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildProgressBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.base),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: SizedBox(
          height: 4,
          child: Stack(
            children: [
              Container(color: AppColors.card),
              FractionallySizedBox(
                widthFactor: 0.75,
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }


  Widget _buildSearchBar() {
    return Container(
      height: AppSpacing.inputHeight,
      decoration: BoxDecoration(
        color: AppColors.elevated,
        borderRadius: AppSpacing.inputRadius,
        border: Border.all(color: AppColors.surface, width: 0.5),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.only(left: AppSpacing.md),
            child: Icon(
              Icons.search,
              color: AppColors.textTertiary,
              size: 20,
            ),
          ),
          Expanded(
            child: TextField(
              controller: _searchController,
              style: AppTypography.body.copyWith(
                color: AppColors.textPrimary,
              ),
              cursorColor: AppColors.cyan,
              decoration: InputDecoration(
                hintText: 'Search for a place...',
                hintStyle: AppTypography.body.copyWith(
                  color: AppColors.textTertiary,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
          if (_searchController.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {
                  _searchResults = [];
                  _searchLabels = [];
                  _showSearchResults = false;
                });
              },
              child: const Padding(
                padding: EdgeInsets.only(right: AppSpacing.md),
                child: Icon(
                  Icons.close,
                  color: AppColors.textTertiary,
                  size: 20,
                ),
              ),
            ),
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.only(right: AppSpacing.md),
              child: SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.cyan,
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _searchLabels = [];
        _showSearchResults = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() => _isSearching = true);
    try {
      final locations = await geo.locationFromAddress(query);
      if (!mounted) return;


      final labels = <String>[];
      final validLocations = <geo.Location>[];
      for (final loc in locations.take(5)) {
        try {
          final placemarks = await geo.placemarkFromCoordinates(
            loc.latitude,
            loc.longitude,
          );
          if (placemarks.isNotEmpty) {
            final pm = placemarks.first;
            final parts = [
              pm.street,
              pm.subLocality,
              pm.locality,
              pm.administrativeArea,
            ].where((p) => p != null && p.isNotEmpty);
            labels.add(parts.join(', '));
            validLocations.add(loc);
          }
        } catch (_) {
          labels.add('${loc.latitude.toStringAsFixed(4)}, '
              '${loc.longitude.toStringAsFixed(4)}');
          validLocations.add(loc);
        }
      }

      if (mounted) {
        setState(() {
          _searchResults = validLocations;
          _searchLabels = labels;
          _showSearchResults = labels.isNotEmpty;
          _isSearching = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _searchResults = [];
          _searchLabels = [];
          _showSearchResults = false;
          _isSearching = false;
        });
      }
    }
  }

  Widget _buildSearchResultsList() {
    return Container(
      margin: AppSpacing.screenPadding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(color: AppColors.surface, width: 0.5),
      ),
      constraints: const BoxConstraints(maxHeight: 200),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _searchLabels.length,
        separatorBuilder: (_, __) => const Divider(
          color: AppColors.surface,
          height: 1,
        ),
        itemBuilder: (context, index) {
          return ListTile(
            dense: true,
            leading: const Icon(
              Icons.location_on,
              color: AppColors.cyan,
              size: 20,
            ),
            title: Text(
              _searchLabels[index],
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _onSearchResultTap(index),
          );
        },
      ),
    );
  }

  void _onSearchResultTap(int index) {
    final loc = _searchResults[index];
    final label = _searchLabels[index];

    setState(() {
      _latitude = loc.latitude;
      _longitude = loc.longitude;
      _address = label;
      _showSearchResults = false;
      _searchController.clear();
    });


    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(loc.latitude, loc.longitude),
        16,
      ),
    );
  }


  Widget _buildMapSection(PostHappeningState state) {
    final showRadius = state.isCasual && !state.useExactLocation;

    return SizedBox(
      height: 300,
      child: Stack(
        children: [

          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _initialPosition,
              zoom: 15,
            ),
            style: darkMapStyle,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            compassEnabled: false,
            circles: showRadius && _latitude != null && _longitude != null
                ? {
                    Circle(
                      circleId: const CircleId('radius_circle'),
                      center: LatLng(_latitude!, _longitude!),
                      radius: _radiusMeters,
                      fillColor: AppColors.cyan.withValues(alpha: 0.08),
                      strokeColor: AppColors.cyan.withValues(alpha: 0.25),
                      strokeWidth: 1,
                    ),
                  }
                : {},
            onMapCreated: (controller) {
              _mapController = controller;
              _mapReady = true;
            },
            onCameraMove: (position) {
              _latitude = position.target.latitude;
              _longitude = position.target.longitude;
            },
            onCameraIdle: _onCameraIdle,
          ),


          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.card.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                  ),
                  child: Text(
                    'DRAG TO REFINE',
                    style: AppTypography.micro.copyWith(
                      color: AppColors.cyan,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                const Icon(
                  Icons.location_on,
                  color: AppColors.cyan,
                  size: 40,
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),


          Positioned(
            right: AppSpacing.base,
            bottom: AppSpacing.base,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MapButton(
                  icon: Icons.my_location,
                  onTap: _recenterMap,
                ),
                AppSpacing.verticalSm,
                _MapButton(
                  icon: Icons.add,
                  onTap: () => _mapController
                      ?.animateCamera(CameraUpdate.zoomIn()),
                ),
                AppSpacing.verticalSm,
                _MapButton(
                  icon: Icons.remove,
                  onTap: () => _mapController
                      ?.animateCamera(CameraUpdate.zoomOut()),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onCameraIdle() async {
    if (!_mapReady || _latitude == null || _longitude == null) return;


    try {
      final placemarks = await geo.placemarkFromCoordinates(
        _latitude!,
        _longitude!,
      );
      if (!mounted) return;

      if (placemarks.isNotEmpty) {
        final pm = placemarks.first;
        final parts = [
          pm.street,
          pm.subLocality,
          pm.locality,
          pm.administrativeArea,
        ].where((p) => p != null && p.isNotEmpty);
        setState(() {
          _address = parts.join(', ');
        });
      }
    } catch (_) {

    }
  }

  Future<void> _recenterMap() async {
    final locationService = context.read<LocationService>();
    final pos = await locationService.getPositionOrDefault();
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(LatLng(pos.lat, pos.lng), 15),
    );
  }


  Widget _buildSelectedLocationCard() {
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPadding,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(color: AppColors.surface, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.cyan.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on,
              color: AppColors.cyan,
              size: 22,
            ),
          ),
          AppSpacing.horizontalMd,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selected Location',
                  style: AppTypography.overline.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 10,
                  ),
                ),
                AppSpacing.verticalXs,
                Text(
                  _address ?? '',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildLocationTypeToggle(PostHappeningState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'LOCATION TYPE',
          style: AppTypography.overline.copyWith(
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
            fontSize: 11,
          ),
        ),
        AppSpacing.verticalSm,
        Container(
          decoration: BoxDecoration(
            color: AppColors.elevated,
            borderRadius: AppSpacing.buttonRadius,
          ),
          child: Row(
            children: [
              Expanded(
                child: _TogglePill(
                  label: 'Exact Location',
                  isSelected: state.useExactLocation,
                  onTap: () {
                    context.read<PostHappeningCubit>().setLocation(
                          useExactLocation: true,
                        );
                  },
                ),
              ),
              Expanded(
                child: _TogglePill(
                  label: 'General Area',
                  isSelected: !state.useExactLocation,
                  onTap: () {
                    context.read<PostHappeningCubit>().setLocation(
                          useExactLocation: false,
                          radiusMeters: _radiusMeters,
                        );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }


  Widget _buildRadiusSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'AREA RADIUS',
              style: AppTypography.overline.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 0.5,
                fontSize: 11,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.cyan.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Text(
                _radiusMeters >= 1000
                    ? '${(_radiusMeters / 1000).toStringAsFixed(1)}km'
                    : '${_radiusMeters.round()}m',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.cyan,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        AppSpacing.verticalSm,
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.cyan,
            inactiveTrackColor: AppColors.surface,
            thumbColor: AppColors.cyan,
            overlayColor: AppColors.cyan.withValues(alpha: 0.15),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
          ),
          child: Slider(
            value: _radiusMeters,
            min: 100,
            max: 2000,
            divisions: 19,
            onChanged: (value) {
              setState(() => _radiusMeters = value);
              context.read<PostHappeningCubit>().setLocation(
                    radiusMeters: value,
                  );
            },
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '100m',
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            Text(
              '2km',
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }


  Widget _buildErrorMessage(String message) {
    return Container(
      width: double.infinity,
      padding: AppSpacing.cardPaddingCompact,
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: AppSpacing.cardRadius,
        border: Border.all(
          color: AppColors.error.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 18),
          AppSpacing.horizontalSm,
          Expanded(
            child: Text(
              message,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildBottomBar(BuildContext context, PostHappeningState state) {
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
          MobGradientButton(
            label: 'Continue',
            onPressed: () {
              final cubit = context.read<PostHappeningCubit>();
              cubit.setLocation(
                latitude: _latitude,
                longitude: _longitude,
                address: _address,
                radiusMeters:
                    state.isCasual && !state.useExactLocation
                        ? _radiusMeters
                        : null,
                useExactLocation: state.useExactLocation,
              );
              cubit.nextStep();
            },
          ),
          AppSpacing.verticalSm,
          MobTextButton(
            label: '\u2190 Previous Step',
            onPressed: () {
              context.read<PostHappeningCubit>().previousStep();
            },
          ),
        ],
      ),
    );
  }
}


class _TogglePill extends StatelessWidget {
  const _TogglePill({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.cyan.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: AppSpacing.buttonRadius,
          border: Border.all(
            color: isSelected ? AppColors.cyan : Colors.transparent,
            width: 1,
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppTypography.buttonSmall.copyWith(
            color: isSelected ? AppColors.cyan : AppColors.textTertiary,
          ),
        ),
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  const _MapButton({
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
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.card,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 18),
      ),
    );
  }
}
