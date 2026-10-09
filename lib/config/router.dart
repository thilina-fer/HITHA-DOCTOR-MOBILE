import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../ui/features/auth/screens/forgot_password_screen.dart';
import '../ui/features/auth/screens/register_screen.dart';
import '../ui/features/auth/screens/sign_in_screen.dart';
import '../ui/features/auth/screens/verify_phone_screen.dart';
import '../ui/features/auth/view_models/auth_view_model.dart';
import '../ui/features/availability/screens/doctor_availability_screen.dart';
import '../ui/features/blogs/screens/doctor_blogs_screen.dart';
import '../ui/features/bookings/screens/booking_details_screen.dart';
import '../ui/features/bookings/screens/doctor_bookings_screen.dart';
import '../ui/features/dashboard/screens/doctor_dashboard_screen.dart';
import '../ui/features/finance/screens/doctor_finance_screen.dart';
import '../ui/features/meeting/screens/telehealth_meeting_screen.dart';
import '../ui/features/onboarding/screens/complete_profile_screen.dart';
import '../ui/features/onboarding/screens/get_started_screen.dart';
import '../ui/features/pricing/screens/doctor_pricing_screen.dart';
import '../ui/features/profile/screens/doctor_profile_screen.dart';
import '../ui/features/shell/doctor_shell.dart';
import '../ui/features/wallet/screens/doctor_wallet_screen.dart';
import 'routes.dart';

GoRouter createRouter(AuthViewModel authVm) {
  return GoRouter(
    initialLocation: authVm.isAuthenticated ? Routes.dashboard : Routes.getStarted,
    refreshListenable: authVm,
    redirect: (context, state) {
      if (!authVm.isInitialized) return null;

      final isAuth = authVm.isAuthenticated;
      final isProfileComplete = authVm.isProfileComplete;
      final path = state.uri.path;

      final isAuthRoute = path == Routes.getStarted ||
          path == Routes.login ||
          path == Routes.register ||
          path == Routes.verifyPhone ||
          path == Routes.forgotPassword;

      // Handle root '/' or empty path explicitly
      if (path == '/' || path.isEmpty) {
        if (!isAuth) return Routes.getStarted;
        if (!isProfileComplete) return Routes.completeProfile;
        return Routes.dashboard;
      }

      // 1. If not authenticated, restrict to auth routes (default to Get Started screen)
      if (!isAuth) {
        return isAuthRoute ? null : Routes.getStarted;
      }

      // 2. If authenticated but profile is incomplete, force complete-profile
      if (!isProfileComplete) {
        return path == Routes.completeProfile ? null : Routes.completeProfile;
      }

      // 3. If authenticated & complete, prevent revisiting onboarding/auth
      if (isAuthRoute || path == Routes.completeProfile) {
        return Routes.dashboard;
      }

      return null;
    },
    routes: [
      // Public Onboarding & Auth routes with custom smooth animations
      GoRoute(
        path: Routes.getStarted,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const GetStartedScreen(),
          transitionDuration: const Duration(milliseconds: 400),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      ),
      GoRoute(
        path: Routes.login,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const SignInScreen(),
          transitionDuration: const Duration(milliseconds: 420),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
            return SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero).animate(curved),
              child: FadeTransition(opacity: curved, child: child),
            );
          },
        ),
      ),
      GoRoute(
        path: Routes.register,
        pageBuilder: (context, state) => CustomTransitionPage<void>(
          key: state.pageKey,
          child: const RegisterScreen(),
          transitionDuration: const Duration(milliseconds: 420),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
            return SlideTransition(
              position: Tween<Offset>(begin: const Offset(0.08, 0), end: Offset.zero).animate(curved),
              child: FadeTransition(opacity: curved, child: child),
            );
          },
        ),
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
            builder: (context, state) => const DoctorWalletScreen(),
          ),
          GoRoute(
            path: Routes.profile,
            builder: (context, state) => const DoctorProfileScreen(),
          ),
        ],
      ),

      // Standalone nested routes
      GoRoute(
        path: Routes.finance,
        builder: (context, state) => const DoctorFinanceScreen(),
      ),
      GoRoute(
        path: Routes.blogs,
        builder: (context, state) => const DoctorBlogsScreen(),
      ),
      GoRoute(
        path: Routes.pricing,
        builder: (context, state) => const DoctorPricingScreen(),
      ),
      GoRoute(
        path: Routes.bookingDetails,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? '';
          return BookingDetailsScreen(bookingId: id);
        },
      ),
      GoRoute(
        path: Routes.meeting,
        builder: (context, state) {
          final id = state.pathParameters['bookingId'] ?? '';
          return TelehealthMeetingScreen(bookingId: id);
        },
      ),
    ],
  );
}
