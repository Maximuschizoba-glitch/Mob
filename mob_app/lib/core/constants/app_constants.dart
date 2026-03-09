

class AppConstants {
  AppConstants._();


  static const String appName = 'Mob';
  static const String tagline = 'See what\'s happening now';


  static const String currency = '\u20A6';
  static const String currencyCode = 'NGN';
  static const String countryCode = '+234';
  static const String countryFlag = '\u{1F1F3}\u{1F1EC}';
  static const String defaultCity = 'Lagos';
  static const String timezone = 'Africa/Lagos';


  static const double defaultFeedRadius = 10.0;
  static const double minAreaRadius = 100.0;
  static const double maxAreaRadius = 2000.0;
  static const double defaultLat = 6.5244;
  static const double defaultLng = 3.3792;


  static const int maxSnapsPerHappening = 5;
  static const int happeningExpiryHours = 24;
  static const int maxBioLength = 150;
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 500;
  static const int maxReportDetailsLength = 500;


  static const double platformFeePercent = 10.0;
  static const String paymentGatewayPaystack = 'paystack';
  static const String paymentGatewayFlutterwave = 'flutterwave';


  static const int otpLength = 6;
  static const int otpTimeoutSeconds = 60;


  static const int snapAutoAdvanceSeconds = 5;


  static const int activityHighThreshold = 8;
  static const int activityMediumThreshold = 3;


  static const int autoHideReportCount = 3;


  static const Duration animFast = Duration(milliseconds: 200);
  static const Duration animNormal = Duration(milliseconds: 300);
  static const Duration animSlow = Duration(milliseconds: 500);


  static const int defaultPageSize = 20;
}
