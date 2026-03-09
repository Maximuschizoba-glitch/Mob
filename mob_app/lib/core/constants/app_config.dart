

class AppConfig {
  AppConfig._();


  static const bool isDevMode = bool.fromEnvironment(
    'DEV_MODE',
    defaultValue: true,
  );


  static const bool otpBypassEnabled = isDevMode;


  static const String devOtpCode = '123456';


  static const String webBaseUrl = 'https://mob.getbuukride.com';


  static String get termsUrl => '$webBaseUrl/terms';


  static String get privacyUrl => '$webBaseUrl/privacy';


  static String happeningShareUrl(String uuid) =>
      '$webBaseUrl/happenings/$uuid';


  static String ticketShareUrl(String uuid) => '$webBaseUrl/tickets/$uuid';
}
