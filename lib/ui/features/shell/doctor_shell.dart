import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes.dart';
import '../../core/theme/hitha_theme.dart';
import '../../core/widgets/floating_pill_nav_bar.dart';

class DoctorShell extends StatelessWidget {
  const DoctorShell({super.key, required this.child});

  final Widget child;

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    if (location.startsWith(Routes.availability)) return 1;
    if (location.startsWith(Routes.bookings)) return 2;
    if (location.startsWith(Routes.profile) ||
        location.startsWith(Routes.wallet) ||
        location.startsWith(Routes.finance)) {
      return 3;
    }
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
        context.go(Routes.profile);
        break;
    }
  }

  void _showQuickActionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 38,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              'Quick Actions',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF0F172A),
                                letterSpacing: -0.3,
                              ),
                            ),
                            Text(
                              'Instant shortcuts for clinic management',
                              style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 20, color: Color(0xFF64748B)),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _buildQuickActionTile(
                  icon: Icons.calendar_month_rounded,
                  iconColor: const Color(0xFF7C5CFC),
                  iconBg: const Color(0xFFF3E8FF),
                  title: 'Manage Weekly Availability',
                  subtitle: 'Configure clinic hours & consultation slots',
                  onTap: () {
                    Navigator.pop(ctx);
                    context.go(Routes.availability);
                  },
                ),
                _buildQuickActionTile(
                  icon: Icons.account_balance_wallet_rounded,
                  iconColor: const Color(0xFFD97706),
                  iconBg: const Color(0xFFFEF3C7),
                  title: 'Doctor Wallet & Earnings',
                  subtitle: 'Review revenue, payout requests & balance',
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push(Routes.wallet);
                  },
                ),
                _buildQuickActionTile(
                  icon: Icons.medical_services_rounded,
                  iconColor: const Color(0xFF0D9488),
                  iconBg: const Color(0xFFCCFBF1),
                  title: 'View Active Bookings',
                  subtitle: 'Upcoming patient consultations & notes',
                  onTap: () {
                    Navigator.pop(ctx);
                    context.go(Routes.bookings);
                  },
                ),
                _buildQuickActionTile(
                  icon: Icons.payments_outlined,
                  iconColor: HithaColors.forest,
                  iconBg: const Color(0xFFEFFDF5),
                  title: 'Consultation Pricing Rates',
                  subtitle: 'Review clinical tier rates & overrides',
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push(Routes.pricing);
                  },
                ),
                _buildQuickActionTile(
                  icon: Icons.article_outlined,
                  iconColor: const Color(0xFF2563EB),
                  iconBg: const Color(0xFFEFF6FF),
                  title: 'Publish Wellness Articles',
                  subtitle: 'Share clinical advice for patient community',
                  onTap: () {
                    Navigator.pop(ctx);
                    context.push(Routes.blogs);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActionTile({
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, size: 19, color: iconColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Color(0xFF94A3B8)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      extendBody: false,
      backgroundColor: const Color(0xFFF8FAFC),
      body: child,
      bottomNavigationBar: FloatingPillNavBar(
        selectedIndex: currentIndex,
        onItemSelected: (idx) => _onItemTapped(idx, context),
        onCenterButtonPressed: () => _showQuickActionsModal(context),
        centerButtonIcon: Icons.add_rounded,
        centerButtonGradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
        ),
        items: const [
          FloatingNavItem(
            icon: Icons.home_outlined,
            activeIcon: Icons.home_rounded,
            label: 'Home',
            activeColor: Color(0xFF7C5CFC),
            activeBgColor: Color(0xFFF3E8FF),
          ),
          FloatingNavItem(
            icon: Icons.calendar_today_outlined,
            activeIcon: Icons.calendar_month_rounded,
            label: 'Schedule',
            activeColor: Color(0xFF7C5CFC),
            activeBgColor: Color(0xFFF3E8FF),
          ),
          FloatingNavItem(
            icon: Icons.medical_services_outlined,
            activeIcon: Icons.medical_services_rounded,
            label: 'Bookings',
            activeColor: Color(0xFF7C5CFC),
            activeBgColor: Color(0xFFF3E8FF),
          ),
          FloatingNavItem(
            icon: Icons.person_outline_rounded,
            activeIcon: Icons.person_rounded,
            label: 'Profile',
            activeColor: Color(0xFF7C5CFC),
            activeBgColor: Color(0xFFF3E8FF),
          ),
        ],
      ),
    );
  }
}
