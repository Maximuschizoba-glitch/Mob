// import 'package:connectivity_plus/connectivity_plus.dart';
// TEMP: connectivity_plus disabled due to iOS compatibility issue

class ConnectivityService {
  // Stub implementation without connectivity_plus
  
  Stream<bool> get onConnectivityChanged {
    // Always report as connected for now
    return Stream.value(true);
  }

  Future<bool> get isConnected async {
    // Assume always connected for MVP testing
    return true;
  }
}
