import 'package:flutter/material.dart';

import '../../../../domain/models/models.dart';

/// Dark forest green banner displaying practitioner greetings, clinical category badge,
/// subtle organic wave curves, ongoing session telemetry, and quick profile edit action.
class DoctorGreetingBanner extends StatelessWidget {
  const DoctorGreetingBanner({
    super.key,
    required this.doctor,
    required this.ongoingSessionsCount,
    required this.onOngoingSessionsTap,
    required this.onEditProfileTap,
  });

  final DoctorProfile? doctor;
  final int ongoingSessionsCount;
  final VoidCallback onOngoingSessionsTap;
  final VoidCallback onEditProfileTap;

  @override
  Widget build(BuildContext context) {
    final doctorName = (doctor != null && doctor!.firstName.isNotEmpty)
        ? 'Dr. ${doctor!.firstName}'
        : 'Doctor';
    final categoryLabel = (doctor != null)
        ? doctor!.category.label.toUpperCase()
        : 'PRACTITIONER';

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
          // 1. Subtle Sanctuary Wave Curves & Shading
          const Positioned.fill(
            child: CustomPaint(
              painter: _SubtleWavePainter(),
            ),
          ),

          // 2. Subtle Organic Ambient Glow in Top Right
          Positioned(
            top: -24,
            right: -24,
            child: Container(
              width: 120,
              height: 120,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0x122DD4BF),
              ),
            ),
          ),

          // 3. Foreground Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting Title + Category Badge
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

                // Subtitle
                const Text(
                  'Welcome back to your digital sanctuary dashboard.',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF94A3B8),
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 13),

                // Telemetry & Profile Action Row
                Wrap(
                  spacing: 10,
                  runSpacing: 8,
                  children: [
                    // Ongoing Sessions Pill
                    GestureDetector(
                      onTap: onOngoingSessionsTap,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
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
                                fontSize: 11,
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
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                            Icon(Icons.person_outline_rounded, size: 14, color: Color(0xFF2DD4BF)),
                            SizedBox(width: 5),
                            Text(
                              'Edit Profile',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
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

/// Custom painter that draws subtle flowing organic sanctuary waves across the banner.
class _SubtleWavePainter extends CustomPainter {
  const _SubtleWavePainter();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Wave 1 - Gentle filled translucent flow from bottom-left to mid-right
    final paint1 = Paint()
      ..shader = const LinearGradient(
        colors: [
          Color(0x102DD4BF),
          Color(0x0510B981),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    final path1 = Path()
      ..moveTo(0, h * 0.40)
      ..cubicTo(w * 0.25, h * 0.18, w * 0.60, h * 0.80, w, h * 0.38)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(path1, paint1);

    // Wave 1 Accent Stroke Line
    final strokePaint1 = Paint()
      ..color = const Color(0x162DD4BF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final strokePath1 = Path()
      ..moveTo(0, h * 0.40)
      ..cubicTo(w * 0.25, h * 0.18, w * 0.60, h * 0.80, w, h * 0.38);
    canvas.drawPath(strokePath1, strokePaint1);

    // Wave 2 - Secondary undulating wave stroke
    final strokePaint2 = Paint()
      ..color = const Color(0x1234D399)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final strokePath2 = Path()
      ..moveTo(0, h * 0.70)
      ..cubicTo(w * 0.30, h * 0.42, w * 0.68, h * 0.95, w, h * 0.62);
    canvas.drawPath(strokePath2, strokePaint2);

    // Wave 3 - Soft crest stroke near top-center
    final strokePaint3 = Paint()
      ..color = const Color(0x0E6EE7B7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final strokePath3 = Path()
      ..moveTo(w * 0.12, 0)
      ..cubicTo(w * 0.45, h * 0.52, w * 0.80, h * 0.15, w, h * 0.48);
    canvas.drawPath(strokePath3, strokePaint3);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
