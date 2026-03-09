

class RoutePaths {
  RoutePaths._();


  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String phoneOtp = '/phone-otp';
  static const String emailVerification = '/email-verification';
  static const String locationPermission = '/location-permission';
  static const String categorySelection = '/category-selection';


  static const String feed = '/feed';
  static const String map = '/map';
  static const String tickets = '/tickets';
  static const String profile = '/profile';


  static const String happeningDetail = '/happening/:uuid';


  static String happeningDetailPath(String uuid) => '/happening/$uuid';


  static const String snapViewer = '/snaps/:happeningUuid';


  static String snapViewerPath(String happeningUuid) =>
      '/snaps/$happeningUuid';


  static const String snapCamera = '/snap-camera/:happeningUuid';


  static String snapCameraPath(String happeningUuid) =>
      '/snap-camera/$happeningUuid';


  static const String post = '/post';


  static const String ticketPurchase = '/ticket-purchase/:happeningUuid';


  static String ticketPurchasePath(String happeningUuid) =>
      '/ticket-purchase/$happeningUuid';


  static const String paymentWebView = '/payment/:reference';


  static String paymentWebViewPath(String reference) =>
      '/payment/$reference';


  static const String ticketConfirmation =
      '/ticket-confirmation/:ticketUuid';


  static String ticketConfirmationPath(String ticketUuid) =>
      '/ticket-confirmation/$ticketUuid';


  static const String ticketDetail = '/ticket/:uuid';


  static String ticketDetailPath(String uuid) => '/ticket/$uuid';


  static const String hostDashboard = '/host-dashboard/:happeningUuid';


  static String hostDashboardPath(String happeningUuid) =>
      '/host-dashboard/$happeningUuid';


  static const String ticketScanner = '/ticket-scanner/:happeningUuid';


  static String ticketScannerPath(String happeningUuid) =>
      '/ticket-scanner/$happeningUuid';


  static const String editProfile = '/edit-profile';
  static const String settings = '/settings';
  static const String myHappenings = '/my-happenings';
  static const String hostVerification = '/host-verification';
  static const String hostVerificationStatus = '/host-verification-status';


  static const String notifications = '/notifications';


  static const String offline = '/offline';
}
