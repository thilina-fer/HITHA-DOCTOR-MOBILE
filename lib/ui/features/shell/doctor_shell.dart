import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes.dart';
import '../../core/theme/hitha_theme.dart';

class DoctorShell extends StatelessWidget {
  const DoctorShell({super.key, required this.child});

  final Widget child;

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith(Routes.availability)) return 1;
    if (location.startsWith(Routes.bookings)) return 2;
    if (location.startsWith(Routes.wallet) || location.startsWith(Routes.finance)) return 3;
    return 0; // Dashboard
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
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      body: child,
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: HithaColors.hairline)),
        ),
        child: SafeArea(
          child: NavigationBarTheme(
            data: NavigationBarThemeData(
              indicatorColor: HithaColors.sprout,
              iconTheme: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return const IconThemeData(color: HithaColors.forest);
                }
                return const IconThemeData(color: HithaColors.inkFaint);
              }),
              labelTextStyle: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return HithaText.caption.copyWith(color: HithaColors.forest, fontWeight: FontWeight.w700);
                }
                return HithaText.caption.copyWith(color: HithaColors.inkFaint);
              }),
            ),
            child: NavigationBar(
              selectedIndex: currentIndex,
              onDestinationSelected: (idx) => _onItemTapped(idx, context),
              backgroundColor: Colors.white,
              elevation: 0,
              height: 65,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(Icons.dashboard_rounded),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month),
                  label: 'Schedule',
                ),
                NavigationDestination(
                  icon: Icon(Icons.medical_services_outlined),
                  selectedIcon: Icon(Icons.medical_services_rounded),
                  label: 'Bookings',
                ),
                NavigationDestination(
                  icon: Icon(Icons.account_balance_wallet_outlined),
                  selectedIcon: Icon(Icons.account_balance_wallet_rounded),
                  label: 'Wallet',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
