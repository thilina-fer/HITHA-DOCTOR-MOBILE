import 'package:go_router/go_router.dart';

import '../ui/features/auth/screens/forgot_password_screen.dart';
import '../ui/features/auth/screens/register_screen.dart';
import '../ui/features/auth/screens/sign_in_screen.dart';
import '../ui/features/auth/screens/verify_phone_screen.dart';
import '../ui/features/auth/view_models/auth_view_model.dart';
import '../ui/features/availability/screens/doctor_availability_screen.dart';
import '../ui/features/bookings/screens/doctor_bookings_screen.dart';
import '../ui/features/common/placeholder_screen.dart';
import '../ui/features/dashboard/screens/doctor_dashboard_screen.dart';
import '../ui/features/onboarding/screens/complete_profile_screen.dart';
import '../ui/features/shell/doctor_shell.dart';
import 'routes.dart';

GoRouter createRouter(AuthViewModel authVm) {
  return GoRouter(
    initialLocation: Routes.dashboard,
    refreshListenable: authVm,
    redirect: (context, state) {
      if (!authVm.isInitialized) return null;

      final isAuth = authVm.isAuthenticated;
      final isProfileComplete = authVm.isProfileComplete;
      final path = state.uri.path;

      final isAuthRoute = path == Routes.login ||
          path == Routes.register ||
          path == Routes.verifyPhone ||
          path == Routes.forgotPassword;

      // 1. If not authenticated, restrict to auth routes
      if (!isAuth) {
        return isAuthRoute ? null : Routes.login;
      }

      // 2. If authenticated but profile is incomplete, force complete-profile
      if (!isProfileComplete) {
        return path == Routes.completeProfile ? null : Routes.completeProfile;
      }

      // 3. If authenticated & complete, prevent revisiting login/register/complete-profile
      if (isAuthRoute || path == Routes.completeProfile) {
        return Routes.dashboard;
      }

      return null;
    },
    routes: [
      // Public Auth routes
      GoRoute(
        path: Routes.login,
        builder: (context, state) => const SignInScreen(),
      ),
      GoRoute(
        path: Routes.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: Routes.verifyPhone,
        builder: (context, state) => const VerifyPhoneScreen(),
      ),
      GoRoute(
        path: Routes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      // Phase 2 Onboarding
      GoRoute(
        path: Routes.completeProfile,
        builder: (context, state) => const CompleteProfileScreen(),
      ),

      // Shell with bottom navigation
      ShellRoute(
        builder: (context, state, child) => DoctorShell(child: child),
        routes: [
          GoRoute(
            path: Routes.dashboard,
            builder: (context, state) => const DoctorDashboardScreen(),
          ),
          GoRoute(
            path: Routes.availability,
            builder: (context, state) => const DoctorAvailabilityScreen(),
          ),
          GoRoute(
            path: Routes.bookings,
            builder: (context, state) => const DoctorBookingsScreen(),
          ),
          GoRoute(
            path: Routes.wallet,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Doctor Wallet & Payouts',
              subtitle: 'Manage available liquid balance, escrow holds, and CEFT bank withdrawals.',
              badgeText: 'FLOW 12',
            ),
          ),
          GoRoute(
            path: Routes.profile,
            builder: (context, state) => const PlaceholderScreen(
              title: 'Practitioner Profile & Settings',
              subtitle: 'Update bio, languages, qualifications, and notification preferences.',
              badgeText: 'FLOW 06.1',
            ),
          ),
        ],
      ),

      // Standalone nested routes
      GoRoute(
        path: Routes.finance,
        builder: (context, state) => const PlaceholderScreen(
          title: 'Income Telemetry',
          subtitle: 'Revenue metrics, consultation payouts, and platform commission breakdown.',
          badgeText: 'FLOW 06.2',
        ),
      ),
      GoRoute(
        path: Routes.blogs,
        builder: (context, state) => const PlaceholderScreen(
          title: 'My Wellness Articles',
          subtitle: 'Author psychoeducational articles for editorial approval and publication.',
          badgeText: 'FLOW 06.4',
        ),
      ),
      GoRoute(
        path: Routes.pricing,
        builder: (context, state) => const PlaceholderScreen(
          title: 'Pricing & Overrides',
          subtitle: 'View category base fee and submit custom consultation fee requests.',
          badgeText: 'FLOW 06.6',
        ),
      ),
      GoRoute(
        path: Routes.bookingDetails,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return PlaceholderScreen(
            title: 'Consultation Dossier #$id',
            subtitle: 'Patient contact info, past clinical notes, and session controls.',
            badgeText: 'FLOW 09',
          );
        },
      ),
      GoRoute(
        path: Routes.meeting,
        builder: (context, state) {
          final id = state.pathParameters['bookingId'] ?? '';
          return PlaceholderScreen(
            title: 'Live Telehealth Session #$id',
            subtitle: 'LiveKit WebRTC video room with real-time clinical notes & digital prescription writer.',
            badgeText: 'FLOW 10 & 11',
          );
        },
      ),
    ],
  );
}
