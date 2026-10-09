import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../config/routes.dart';
import '../../../core/theme/hitha_theme.dart';
import '../../../core/widgets/hitha_widgets.dart';
import '../view_models/auth_view_model.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final authVm = context.read<AuthViewModel>();

    final success = await authVm.login(
      _identifierCtrl.text.trim(),
      _passwordCtrl.text,
    );

    if (!mounted) return;

    if (success) {
      if (!authVm.isProfileComplete) {
        context.go(Routes.completeProfile);
      } else {
        context.go(Routes.dashboard);
      }
    } else if (authVm.errorMessage != null) {
      showHithaSnack(context, authVm.errorMessage!, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      body: Stack(
        children: [
          // 1. Organic Decorative Background Elements
          Positioned(
            top: -60,
            left: -60,
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE5F4EE).withValues(alpha: 0.6),
              ),
            ),
          ),
          Positioned(
            top: 140,
            right: -70,
            child: Container(
              width: 190,
              height: 190,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE5F4EE).withValues(alpha: 0.45),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -50,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFE5F4EE).withValues(alpha: 0.65),
              ),
            ),
          ),

          // Back button to Get Started screen
          Positioned(
            top: 10,
            left: 16,
            child: SafeArea(
              child: InkWell(
                onTap: () => context.go(Routes.getStarted),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: const Color(0xFFE2EBE7)),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x0A0D3B66),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back_rounded, size: 20, color: Color(0xFF0F766E)),
                ),
              ),
            ),
          ),

          // 2. Main Scrollable Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 410),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Hero(
                        tag: 'hitha_brand_logo',
                        child: HithaBrandLogo(
                          iconHeight: 64,
                          textHeight: 24,
                          isVertical: true,
                          spacing: 12,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Short & Sweet Single Title
                      Text(
                        'Welcome Back, Doctor',
                        textAlign: TextAlign.center,
                        style: HithaText.h1.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: const Color(0xFF0D3B66),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Form Card
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE2EBE7), width: 1.2),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x0C0D3B66),
                              blurRadius: 20,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Email or Phone Number Label
                              Text(
                                'Email or Phone Number',
                                style: HithaText.bodySmall.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                  color: const Color(0xFF32536A),
                                ),
                              ),
                              const SizedBox(height: 8),

                              // Email or Phone Input
                              TextFormField(
                                controller: _identifierCtrl,
                                keyboardType: TextInputType.emailAddress,
                                style: HithaText.body.copyWith(
                                  fontSize: 14,
                                  color: const Color(0xFF0D3B66),
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'doctor@hitha.lk or +94 77 123 4567',
                                  hintStyle: HithaText.body.copyWith(
                                    fontSize: 13.5,
                                    color: const Color(0xFF9EADB8),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF3F7F6),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  prefixIcon: const Icon(
                                    Icons.person_outline_rounded,
                                    color: Color(0xFF90A4B2),
                                    size: 20,
                                  ),
                                  isDense: true,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(13),
                                    borderSide: const BorderSide(color: Color(0xFFE0EBE7), width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(13),
                                    borderSide: const BorderSide(color: Color(0xFF0D3B66), width: 1.5),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(13),
                                    borderSide: const BorderSide(color: HithaColors.clay, width: 1),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(13),
                                    borderSide: const BorderSide(color: HithaColors.clay, width: 1.5),
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) {
                                    return 'Please enter your email or phone number';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 18),

                              // Password Label Row with "Forgot Password?"
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Portal Password',
                                    style: HithaText.bodySmall.copyWith(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                      color: const Color(0xFF32536A),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.push(Routes.forgotPassword),
                                    child: Text(
                                      'Forgot Password?',
                                      style: HithaText.bodySmall.copyWith(
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF0D3B66),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),

                              // Password Input
                              TextFormField(
                                controller: _passwordCtrl,
                                obscureText: _obscurePassword,
                                style: HithaText.body.copyWith(
                                  fontSize: 14,
                                  color: const Color(0xFF0D3B66),
                                  fontWeight: FontWeight.w500,
                                ),
                                decoration: InputDecoration(
                                  hintText: '••••••••',
                                  hintStyle: HithaText.body.copyWith(
                                    fontSize: 15,
                                    letterSpacing: 2,
                                    color: const Color(0xFF9EADB8),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF3F7F6),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: Color(0xFF90A4B2),
                                    size: 20,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                      color: const Color(0xFF90A4B2),
                                      size: 20,
                                    ),
                                    onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                  ),
                                  isDense: true,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(13),
                                    borderSide: const BorderSide(color: Color(0xFFE0EBE7), width: 1),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(13),
                                    borderSide: const BorderSide(color: Color(0xFF0D3B66), width: 1.5),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(13),
                                    borderSide: const BorderSide(color: HithaColors.clay, width: 1),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(13),
                                    borderSide: const BorderSide(color: HithaColors.clay, width: 1.5),
                                  ),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 22),

                              // Sign In Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: FilledButton(
                                  onPressed: authVm.loading ? null : _handleLogin,
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFF0D3B66),
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: HithaColors.creamDark,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: authVm.loading
                                      ? const SizedBox.square(
                                          dimension: 20,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                        )
                                      : Text(
                                          'Sign In to Portal',
                                          style: HithaText.bodyMedium.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 18),

                              // OR Divider
                              Row(
                                children: [
                                  const Expanded(
                                    child: Divider(color: Color(0xFFE4EDE9), thickness: 1),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 14),
                                    child: Text(
                                      'OR',
                                      style: HithaText.caption.copyWith(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF95A8B6),
                                      ),
                                    ),
                                  ),
                                  const Expanded(
                                    child: Divider(color: Color(0xFFE4EDE9), thickness: 1),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),

                              // Google Sign In Button (UI only, no backend integration)
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: OutlinedButton(
                                  onPressed: () {
                                    showHithaSnack(context, 'Google Sign-In is not integrated yet.');
                                  },
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF32536A),
                                    side: const BorderSide(color: Color(0xFFDCE6E2), width: 1.2),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const GoogleLogo(size: 20),
                                      const SizedBox(width: 12),
                                      Text(
                                        'Sign in with Google',
                                        style: HithaText.bodyMedium.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 14.5,
                                          color: const Color(0xFF32536A),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Register as a Doctor Footer Row
                              Center(
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      'New to Hitha? ',
                                      style: HithaText.bodySmall.copyWith(
                                        color: const Color(0xFF5A7184),
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => context.push(Routes.register),
                                      child: Text(
                                        'Register as a Doctor',
                                        style: HithaText.bodySmall.copyWith(
                                          color: const Color(0xFF0D3B66),
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Official multi-color Google 'G' icon rendered with vector precision.
class GoogleLogo extends StatelessWidget {
  const GoogleLogo({super.key, this.size = 20});
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24.0;

    // Blue
    final bluePaint = Paint()
      ..color = const Color(0xFF4285F4)
      ..style = PaintingStyle.fill;
    final bluePath = Path()
      ..moveTo(23.745 * s, 12.27 * s)
      ..cubicTo(23.745 * s, 11.57 * s, 23.685 * s, 10.87 * s, 23.555 * s, 10.2 * s)
      ..lineTo(12 * s, 10.2 * s)
      ..lineTo(12 * s, 14.71 * s)
      ..lineTo(18.6 * s, 14.71 * s)
      ..cubicTo(18.31 * s, 16.23 * s, 17.46 * s, 17.51 * s, 16.2 * s, 18.36 * s)
      ..lineTo(20.08 * s, 21.39 * s)
      ..cubicTo(22.35 * s, 19.3 * s, 23.745 * s, 16.22 * s, 23.745 * s, 12.27 * s)
      ..close();
    canvas.drawPath(bluePath, bluePaint);

    // Green
    final greenPaint = Paint()
      ..color = const Color(0xFF34A853)
      ..style = PaintingStyle.fill;
    final greenPath = Path()
      ..moveTo(12 * s, 24 * s)
      ..cubicTo(15.24 * s, 24 * s, 17.95 * s, 22.92 * s, 19.93 * s, 21.09 * s)
      ..lineTo(16.05 * s, 18.06 * s)
      ..cubicTo(14.97 * s, 18.78 * s, 13.6 * s, 19.22 * s, 12 * s, 19.22 * s)
      ..cubicTo(8.88 * s, 19.22 * s, 6.23 * s, 17.12 * s, 5.28 * s, 14.29 * s)
      ..lineTo(1.27 * s, 17.42 * s)
      ..cubicTo(3.25 * s, 21.27 * s, 7.31 * s, 24 * s, 12 * s, 24 * s)
      ..close();
    canvas.drawPath(greenPath, greenPaint);

    // Yellow
    final yellowPaint = Paint()
      ..color = const Color(0xFFFBBC05)
      ..style = PaintingStyle.fill;
    final yellowPath = Path()
      ..moveTo(5.28 * s, 14.29 * s)
      ..cubicTo(5.03 * s, 13.57 * s, 4.9 * s, 12.8 * s, 4.9 * s, 12 * s)
      ..cubicTo(4.9 * s, 11.2 * s, 5.03 * s, 10.43 * s, 5.28 * s, 9.71 * s)
      ..lineTo(1.27 * s, 6.58 * s)
      ..cubicTo(0.46 * s, 8.2 * s, 0, 10.04 * s, 0, 12 * s)
      ..cubicTo(0, 13.96 * s, 0.46 * s, 15.8 * s, 1.27 * s, 17.42 * s)
      ..lineTo(5.28 * s, 14.29 * s)
      ..close();
    canvas.drawPath(yellowPath, yellowPaint);

    // Red
    final redPaint = Paint()
      ..color = const Color(0xFFEA4335)
      ..style = PaintingStyle.fill;
    final redPath = Path()
      ..moveTo(12 * s, 4.75 * s)
      ..cubicTo(13.77 * s, 4.75 * s, 15.35 * s, 5.36 * s, 16.6 * s, 6.55 * s)
      ..lineTo(20.02 * s, 3.13 * s)
      ..cubicTo(17.95 * s, 1.19 * s, 15.24 * s, 0, 12 * s, 0)
      ..cubicTo(7.31 * s, 0, 3.25 * s, 2.73 * s, 1.27 * s, 6.58 * s)
      ..lineTo(5.28 * s, 9.71 * s)
      ..cubicTo(6.23 * s, 6.88 * s, 8.88 * s, 4.75 * s, 12 * s, 4.75 * s)
      ..close();
    canvas.drawPath(redPath, redPaint);
  }

  @override
  bool shouldRepaint(_GoogleLogoPainter oldDelegate) => false;
}
