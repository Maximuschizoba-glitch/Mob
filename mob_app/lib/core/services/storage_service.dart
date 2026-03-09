import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';


class StorageService {
  StorageService({
    required FlutterSecureStorage secureStorage,
    required SharedPreferences prefs,
  })  : _secureStorage = secureStorage,
        _prefs = prefs;

  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;


  static const String _tokenKey = 'auth_token';


  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _guestModeKey = 'guest_mode';
  static const String _selectedCategoriesKey = 'selected_categories';
  static const String _fcmTokenKey = 'fcm_token';
  static const String _lastKnownLatKey = 'last_known_lat';
  static const String _lastKnownLngKey = 'last_known_lng';


  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }


  Future<String?> getToken() async {
    return _secureStorage.read(key: _tokenKey);
  }


  Future<void> clearToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }


  Future<bool> hasToken() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }


  Future<void> setOnboardingComplete() async {
    await _prefs.setBool(_onboardingCompleteKey, true);
  }


  bool isOnboardingComplete() {
    return _prefs.getBool(_onboardingCompleteKey) ?? false;
  }


  Future<void> setGuestMode(bool isGuest) async {
    await _prefs.setBool(_guestModeKey, isGuest);
  }


  bool isGuestMode() {
    return _prefs.getBool(_guestModeKey) ?? false;
  }


  Future<void> saveSelectedCategories(List<String> categories) async {
    await _prefs.setStringList(_selectedCategoriesKey, categories);
  }


  List<String>? getSelectedCategories() {
    return _prefs.getStringList(_selectedCategoriesKey);
  }


  Future<void> saveFcmToken(String token) async {
    await _prefs.setString(_fcmTokenKey, token);
  }


  String? getFcmToken() {
    return _prefs.getString(_fcmTokenKey);
  }


  Future<void> saveLastKnownLocation(double lat, double lng) async {
    await _prefs.setDouble(_lastKnownLatKey, lat);
    await _prefs.setDouble(_lastKnownLngKey, lng);
  }


  ({double lat, double lng})? getLastKnownLocation() {
    final lat = _prefs.getDouble(_lastKnownLatKey);
    final lng = _prefs.getDouble(_lastKnownLngKey);
    if (lat != null && lng != null) {
      return (lat: lat, lng: lng);
    }
    return null;
  }


  Future<void> clearAll() async {
    final onboardingDone = isOnboardingComplete();

    await _secureStorage.deleteAll();
    await _prefs.clear();


    if (onboardingDone) {
      await setOnboardingComplete();
    }
  }
}
