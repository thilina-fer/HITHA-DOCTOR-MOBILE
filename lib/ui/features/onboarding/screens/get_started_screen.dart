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
      duration: const Duration(milliseconds: 850),
    )..forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar: Centered Large Hitha Logo (Language pill removed as requested)
            FadeTransition(
              opacity: CurvedAnimation(
                parent: _animController,
                curve: const Interval(0.0, 0.45, curve: Curves.easeOut),
              ),
              child: Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 4),
                child: Center(
                  child: Hero(
                    tag: 'hitha_brand_logo',
                    child: Image.asset(
                      'assets/images/hitha_logo.png',
                      height: 95,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Text(
                        'HITHA.LK',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: Color(0xFF045D51),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Middle Section: Centered Well-Proportioned Doctor Hero Illustration with Soft Gradient Aura
            Expanded(
              flex: 5,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.92, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _animController,
                    curve: const Interval(0.12, 0.65, curve: Curves.easeOutBack),
                  ),
                ),
                child: FadeTransition(
                  opacity: CurvedAnimation(
                    parent: _animController,
                    curve: const Interval(0.12, 0.58, curve: Curves.easeOut),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: screenSize.height * 0.46,
                        maxWidth: 390,
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Soft mint gradient aura circle
                          Container(
                            width: 290,
                            height: 290,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Color(0xFFDCF2E7),
                                  Color(0xFFEAF6F0),
                                  Color(0x00FFFFFF),
                                ],
                                stops: [0.35, 0.72, 1.0],
                              ),
                            ),
                          ),

                          // Doctor Cutout Image (Nicely sized & centered without distracting leaves)
                          Positioned.fill(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              child: Image.asset(
                                'assets/images/Doctor.png',
                                fit: BoxFit.contain,
                                errorBuilder: (_, _, _) => const Icon(
                                  Icons.medical_services_rounded,
                                  size: 130,
                                  color: Color(0xFF045D51),
                                ),
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
