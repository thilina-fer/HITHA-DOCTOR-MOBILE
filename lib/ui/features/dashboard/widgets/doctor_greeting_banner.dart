import 'package:flutter/material.dart';

import '../../../../domain/models/models.dart';

/// Dark forest green banner displaying practitioner greetings, clinical category badge,
/// live status toggle, ongoing session telemetry, and quick portal actions.
class DoctorGreetingBanner extends StatelessWidget {
  const DoctorGreetingBanner({
    super.key,
    required this.doctor,
    required this.ongoingSessionsCount,
    required this.onStatusChangeTap,
    required this.onOngoingSessionsTap,
    required this.onEditProfileTap,
    required this.onLogoutTap,
  });

  final DoctorProfile? doctor;
  final int ongoingSessionsCount;
  final VoidCallback onStatusChangeTap;
  final VoidCallback onOngoingSessionsTap;
  final VoidCallback onEditProfileTap;
  final VoidCallback onLogoutTap;

  @override
  Widget build(BuildContext context) {
    final status = doctor?.status ?? DoctorStatus.ONLINE;
    final doctorName = (doctor != null && doctor!.firstName.isNotEmpty)
        ? 'Dr. ${doctor!.firstName}'
        : 'Dr. Thilina';
    final categoryLabel = (doctor != null)
        ? doctor!.category.label.toUpperCase()
        : 'CLINICAL COUNSELOR';

    final Color statusDotColor = switch (status) {
      DoctorStatus.ONLINE => const Color(0xFF10B981),
      DoctorStatus.BUSY => const Color(0xFFF59E0B),
      _ => const Color(0xFF94A3B8),
    };

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0F3226),
            Color(0xFF163E30),
            Color(0xFF123629),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: const Color(0xFF1F4D3C), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33062018),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Subtle organic ambient glow in top right
          Positioned(
            top: -20,
            right: -20,
            child: Container(
              width: 110,
              height: 110,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x122DD4BF),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Greeting Title + Category Badge
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      'Ayubowan, $doctorName',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0x242DD4BF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0x662DD4BF), width: 0.8),
                      ),
                      child: Text(
                        categoryLabel,
                        style: const TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2DD4BF),
                          letterSpacing: 0.4,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),

                // 2. Subtitle
                const Text(
                  'Welcome back to your digital sanctuary dashboard.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 12),

                // 3. Telemetry and Action Controls (Mobile-Optimized Wrap)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Status Pill with White "Change" Button
                    GestureDetector(
                      onTap: onStatusChangeTap,
                      child: Container(
                        padding: const EdgeInsets.only(left: 9, right: 3, top: 3, bottom: 3),
                        decoration: BoxDecoration(
                          color: const Color(0xFF092018),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF1B4D3C), width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: statusDotColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              status.label.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                'Change',
                                style: TextStyle(
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF0B2B20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Ongoing Sessions Pill
                    GestureDetector(
                      onTap: onOngoingSessionsTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF092018),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF1B4D3C), width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: ongoingSessionsCount > 0
                                    ? const Color(0xFF38BDF8)
                                    : const Color(0xFF94A3B8),
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$ongoingSessionsCount Ongoing Sessions',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Edit Profile Button
                    GestureDetector(
                      onTap: onEditProfileTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF092018),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0x802DD4BF),
                            width: 0.8,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.person_outline_rounded, size: 13, color: Color(0xFF2DD4BF)),
                            SizedBox(width: 5),
                            Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Logout Button
                    GestureDetector(
                      onTap: onLogoutTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5.5),
                        decoration: BoxDecoration(
                          color: const Color(0x28EF4444),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0x60EF4444), width: 0.8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.logout_rounded, size: 12, color: Color(0xFFFCA5A5)),
                            SizedBox(width: 5),
                            Text(
                              'Logout',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFFCA5A5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
