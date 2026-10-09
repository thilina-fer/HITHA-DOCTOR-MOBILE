import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../config/routes.dart';

class GetStartedScreen extends StatefulWidget {
  const GetStartedScreen({super.key});

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final PageController _pageController;
  int _currentPage = 0;
  String _selectedLanguage = 'EN';

  final List<Map<String, String>> _onboardingSlides = const [
    {
      'titlePrefix': 'Welcome to ',
      'titleHighlight': 'Hitha.lk',
      'subtitle': 'Your space to care, anytime, anywhere',
    },
    {
      'titlePrefix': 'Seamless ',
      'titleHighlight': 'Telehealth',
      'subtitle': 'Connect with patients via secure video consultations',
    },
    {
      'titlePrefix': 'Flexible ',
      'titleHighlight': 'Practice',
      'subtitle': 'Manage your schedule, earnings & digital wallet effortlessly',
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  void _showLanguageSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Select Language',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                _buildLanguageTile(ctx, 'EN', 'English'),
                _buildLanguageTile(ctx, 'SI', 'සිංහල (Sinhala)'),
                _buildLanguageTile(ctx, 'TA', 'தமிழ் (Tamil)'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageTile(BuildContext ctx, String code, String name) {
    final isSelected = _selectedLanguage == code;
    return InkWell(
      onTap: () {
        setState(() => _selectedLanguage = code);
        Navigator.pop(ctx);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        margin: const EdgeInsets.only(bottom: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE8F6F0) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected ? const Color(0xFF045D51) : const Color(0xFF334155),
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Color(0xFF045D51), size: 18),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Logo & Language Selector
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _animController,
                curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(width: 58), // Optical balance spacing
                    // Centered Hitha Logo
                    Hero(
                      tag: 'hitha_brand_logo',
                      child: Image.asset(
                        'assets/images/hitha_logo.png',
                        height: 68,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const Text(
                          'HITHA.LK',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                            color: Color(0xFF045D51),
                          ),
                        ),
                      ),
                    ),
                    // Language Selector Pill
                    InkWell(
                      onTap: _showLanguageSelector,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.language_rounded, size: 14, color: Color(0xFF64748B)),
                            const SizedBox(width: 4),
                            Text(
                              _selectedLanguage,
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF334155),
                              ),
                            ),
                            const SizedBox(width: 2),
                            const Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: Color(0xFF64748B)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Middle Section: Hero Doctor Illustration with botanical backdrop
            Expanded(
              flex: 5,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.90, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _animController,
                    curve: const Interval(0.15, 0.65, curve: Curves.easeOutBack),
                  ),
                ),
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _animController,
                    curve: const Interval(0.15, 0.6, curve: Curves.easeOut),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: screenSize.height * 0.44,
                        maxWidth: 380,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Organic mint aura blob
                          Container(
                            width: 250,
                            height: 250,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Color(0xFFE2F4EC),
                                  Color(0xFFEBF7F1),
                                  Color(0x00FFFFFF),
                                ],
                                stops: [0.3, 0.72, 1.0],
                              ),
                            ),
                          ),

                          // Watercolor botanical foliage
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _BotanicalLeavesPainter(),
                            ),
                          ),

                          // Doctor Cutout Image
                          Positioned(
                            bottom: 0,
                            top: 8,
                            child: Image.asset(
                              'assets/images/Doctor.png',
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const Icon(
                                Icons.medical_services_rounded,
                                size: 120,
                                color: Color(0xFF045D51),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Carousel dots indicator
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _animController,
                curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_onboardingSlides.length, (idx) {
                  final isActive = idx == _currentPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: isActive ? 18 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isActive ? const Color(0xFF045D51) : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 16),

            // Text Slides PageView (Swipeable)
            Expanded(
              flex: 2,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.18), end: Offset.zero).animate(
                  CurvedAnimation(
                    parent: _animController,
                    curve: const Interval(0.4, 0.8, curve: Curves.easeOutCubic),
                  ),
                ),
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _animController,
                    curve: const Interval(0.4, 0.8, curve: Curves.easeOut),
                  ),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: _onboardingSlides.length,
                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                    itemBuilder: (context, idx) {
                      final slide = _onboardingSlides[idx];
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 28),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(
                                  fontSize: 23,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1E293B),
                                  letterSpacing: -0.3,
                                ),
                                children: [
                                  TextSpan(text: slide['titlePrefix']),
                                  TextSpan(
                                    text: slide['titleHighlight'],
                                    style: const TextStyle(
                                      color: Color(0xFF045D51),
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              slide['subtitle']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            // Bottom Buttons Section
            SlideTransition(
              position: Tween<Offset>(begin: const Offset(0, 0.22), end: Offset.zero).animate(
                CurvedAnimation(
                  parent: _animController,
                  curve: const Interval(0.55, 1.0, curve: Curves.easeOutCubic),
                ),
              ),
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _animController,
                  curve: const Interval(0.55, 1.0, curve: Curves.easeOut),
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // "Get Started ->" Button
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 380),
                        child: SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: () => context.go(Routes.register),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF045D51),
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shadowColor: const Color(0x33045D51),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Text(
                                  'Get Started',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.arrow_forward_rounded, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // "Already have an account? Sign In" Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Already have an account? ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          InkWell(
                            onTap: () => context.go(Routes.login),
                            borderRadius: BorderRadius.circular(6),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                              child: Text(
                                'Sign In',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF045D51),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for soft botanical sage-green leaves behind doctor illustration
class _BotanicalLeavesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final leafPaint = Paint()
      ..color = const Color(0xFFA5D1BC).withValues(alpha: 0.70)
      ..style = PaintingStyle.fill;

    final stemPaint = Paint()
      ..color = const Color(0xFF86BAA1).withValues(alpha: 0.80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeCap = StrokeCap.round;

    // Stem path arching towards top-right
    final stemPath = Path()
      ..moveTo(size.width * 0.52, size.height * 0.88)
      ..quadraticBezierTo(
        size.width * 0.68,
        size.height * 0.52,
        size.width * 0.82,
        size.height * 0.16,
      );
    canvas.drawPath(stemPath, stemPaint);

    void drawLeaf(Offset center, double angle, double scale) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(angle);
      canvas.scale(scale);

      final leafPath = Path()
        ..moveTo(0, 0)
        ..cubicTo(10, -18, 24, -22, 22, -42)
        ..cubicTo(12, -34, 2, -18, 0, 0);

      canvas.drawPath(leafPath, leafPaint);
      canvas.restore();
    }

    drawLeaf(Offset(size.width * 0.82, size.height * 0.17), 0.25, 1.0);
    drawLeaf(Offset(size.width * 0.75, size.height * 0.32), 0.65, 1.15);
    drawLeaf(Offset(size.width * 0.68, size.height * 0.48), 0.85, 1.25);
    drawLeaf(Offset(size.width * 0.62, size.height * 0.62), 1.05, 1.05);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
