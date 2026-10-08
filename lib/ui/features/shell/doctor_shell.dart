import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes.dart';
import '../../core/widgets/floating_pill_nav_bar.dart';

class DoctorShell extends StatelessWidget {
  const DoctorShell({super.key, required this.child});

  final Widget child;

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith(Routes.availability)) return 1;
    if (location.startsWith(Routes.bookings)) return 2;
    if (location.startsWith(Routes.wallet) || location.startsWith(Routes.finance)) return 3;
    if (location.startsWith(Routes.profile)) return 4;
    return 0; // Dashboard / Home
  }

  void _onItemTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go(Routes.dashboard);
        break;
      case 1:
        context.go(Routes.availability);
        break;
      case 2:
        context.go(Routes.bookings);
        break;
      case 3:
        context.go(Routes.wallet);
        break;
      case 4:
        context.go(Routes.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: FloatingPillNavBar(
        selectedIndex: currentIndex,
        onItemSelected: (idx) => _onItemTapped(idx, context),
        items: const [
          FloatingNavItem(
            icon: Icons.home_outlined,
            label: 'Home',
            activeColor: Color(0xFFE04F5F),
            activeBgColor: Color(0xFFFDE8E8),
          ),
          FloatingNavItem(
            icon: Icons.calendar_today_outlined,
            label: 'Schedule',
            activeColor: Color(0xFF7C3AED),
            activeBgColor: Color(0xFFEDE9FE),
          ),
          FloatingNavItem(
            icon: Icons.medical_services_outlined,
            label: 'Bookings',
            activeColor: Color(0xFF0D9488),
            activeBgColor: Color(0xFFCCFBF1),
          ),
          FloatingNavItem(
            icon: Icons.history_rounded,
            label: 'Wallet',
            activeColor: Color(0xFFD97706),
            activeBgColor: Color(0xFFFEF3C7),
          ),
          FloatingNavItem(
            icon: Icons.person_outline_rounded,
            label: 'Profile',
            activeColor: Color(0xFFDB2777),
            activeBgColor: Color(0xFFFCE7F3),
          ),
        ],
      ),
    );
  }
}
