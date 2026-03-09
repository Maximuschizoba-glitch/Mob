import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';


class LocationService {


  static const double defaultLatitude = 6.5244;


  static const double defaultLongitude = 3.3792;


  Future<bool> requestPermission() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }


  Future<bool> hasPermission() async {
    return Permission.locationWhenInUse.isGranted;
  }


  Future<bool> isPermanentlyDenied() async {
    return Permission.locationWhenInUse.isPermanentlyDenied;
  }


  Future<bool> openSettings() async {
    return openAppSettings();
  }


  Future<Position?> getCurrentPosition() async {
    final granted = await hasPermission();
    if (!granted) return null;

    try {
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 10),
        ),
      );
    } catch (_) {
      return null;
    }
  }


  Future<({double lat, double lng})> getPositionOrDefault() async {
    final position = await getCurrentPosition();
    if (position != null) {
      return (lat: position.latitude, lng: position.longitude);
    }
    return (lat: defaultLatitude, lng: defaultLongitude);
  }
}
