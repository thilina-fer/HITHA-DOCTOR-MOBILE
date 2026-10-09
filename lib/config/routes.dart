abstract final class Routes {
  static const getStarted = '/doctor/get-started';
  static const login = '/doctor/login';
  static const register = '/doctor/register';
  static const verifyPhone = '/doctor/verify-phone';
  static const forgotPassword = '/doctor/forgot-password';
  static const completeProfile = '/doctor/complete-profile';

  // Shell tabs & dashboard
  static const dashboard = '/doctor/dashboard';
  static const profile = '/doctor/profile';
  static const availability = '/doctor/availability';
  static const pricing = '/doctor/pricing';
  static const bookings = '/doctor/bookings';
  static const bookingDetails = '/doctor/bookings/:id';
  static const wallet = '/doctor/wallet';
  static const finance = '/doctor/finance';
  static const blogs = '/doctor/blogs';
  static const meeting = '/meeting/:bookingId';

  static String bookingDetailsPath(String id) => '/doctor/bookings/$id';
  static String meetingPath(String bookingId) => '/meeting/$bookingId';
}
