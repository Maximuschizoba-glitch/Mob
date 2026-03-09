

class ApiEndpoints {
  ApiEndpoints._();


  static const String baseUrl = 'https://mob.getbuukride.com/api/v1';


  static const String health = '/health';
  static const String info = '/info';


  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String logout = '/auth/logout';
  static const String user = '/auth/user';
  static const String sendPhoneOtp = '/auth/send-phone-otp';
  static const String verifyPhone = '/auth/verify-phone';
  static const String verifyEmail = '/auth/verify-email';
  static const String guestToken = '/auth/guest';
  static const String registerFcmToken = '/auth/fcm-token';


  static const String happenings = '/happenings';
  static const String happeningsMap = '/happenings/map';

  static String happeningDetail(String uuid) => '/happenings/$uuid';
  static String happeningUpdate(String uuid) => '/happenings/$uuid';
  static String happeningEnd(String uuid) => '/happenings/$uuid/end';
  static String happeningDelete(String uuid) => '/happenings/$uuid';
  static String happeningSnaps(String uuid) => '/happenings/$uuid/snaps';
  static String happeningReport(String uuid) => '/happenings/$uuid/report';


  static const String tickets = '/tickets';
  static const String purchaseTicket = '/tickets/purchase';

  static String ticketDetail(String uuid) => '/tickets/$uuid';
  static String verifyTicketPayment(String uuid) => '/tickets/$uuid/verify';


  static String verifyTicketCheckIn(String happeningUuid) =>
      '/happenings/$happeningUuid/tickets/verify';


  static String escrowStatus(String uuid) => '/escrow/$uuid';
  static String escrowByHappening(String happeningUuid) =>
      '/happenings/$happeningUuid/escrow';
  static String escrowComplete(String uuid) => '/escrow/$uuid/complete';


  static const String hostVerify = '/host/verify';
  static const String hostVerificationStatus = '/host/verification-status';


  static const String profile = '/profile';
  static const String updateProfile = '/profile/update';
  static const String myHappenings = '/profile/happenings';


  static const String notifications = '/notifications';
  static const String markAllRead = '/notifications/read-all';
  static String notificationRead(String uuid) => '/notifications/$uuid/read';
  static const String unreadCount = '/notifications/unread-count';


  static const String webhookPaystack = '/webhooks/paystack';
  static const String webhookFlutterwave = '/webhooks/flutterwave';
}
