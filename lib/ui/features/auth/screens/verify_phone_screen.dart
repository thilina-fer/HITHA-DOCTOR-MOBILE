import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../config/routes.dart';
import '../../../core/theme/hitha_theme.dart';
import '../../../core/widgets/hitha_widgets.dart';
import '../view_models/auth_view_model.dart';

class VerifyPhoneScreen extends StatefulWidget {
  const VerifyPhoneScreen({super.key});

  @override
  State<VerifyPhoneScreen> createState() => _VerifyPhoneScreenState();
}

class _VerifyPhoneScreenState extends State<VerifyPhoneScreen> {
  final _otpCtrl = TextEditingController();

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleVerify() async {
    final code = _otpCtrl.text.trim();
    if (code.length < 6) {
      showHithaSnack(context, 'Please enter the 6-digit verification code', isError: true);
      return;
    }

    final authVm = context.read<AuthViewModel>();
    final success = await authVm.verifyOtp(code);

    if (!mounted) return;

    if (success) {
      showHithaSnack(context, 'Phone verified successfully!');
      if (!authVm.isProfileComplete) {
        context.go(Routes.completeProfile);
      } else {
        context.go(Routes.dashboard);
      }
    } else if (authVm.errorMessage != null) {
      showHithaSnack(context, authVm.errorMessage!, isError: true);
    }
  }

  Future<void> _handleResend() async {
    final authVm = context.read<AuthViewModel>();
    if (authVm.pendingPhoneIdentifier != null) {
      final ok = await authVm.sendOtp(
        identifier: authVm.pendingPhoneIdentifier!,
        purpose: 'DOCTOR_LOGIN',
      );
      if (ok && mounted) {
        showHithaSnack(context, 'New OTP sent to ${authVm.pendingPhoneIdentifier}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final phone = authVm.pendingPhoneIdentifier ?? 'your phone';

    return Scaffold(
      backgroundColor: HithaColors.cream,
      appBar: const HithaAppBar(title: 'Phone Verification'),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: HithaSpacing.page, vertical: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: HithaCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: const BoxDecoration(
                          color: HithaColors.sprout,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.mark_email_read_outlined, color: HithaColors.forest, size: 28),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Verify Your Phone',
                      style: HithaText.h2,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We have dispatched a 6-digit verification code via SMS to $phone.',
                      style: HithaText.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    HithaTextField(
                      label: '6-Digit Verification Code',
                      controller: _otpCtrl,
                      hint: '123456',
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                      prefixIcon: const Icon(Icons.shield_outlined, color: HithaColors.inkFaint, size: 20),
                    ),
                    const SizedBox(height: 20),

                    PrimaryButton(
                      text: 'Verify & Continue',
                      loading: authVm.loading,
                      onPressed: _handleVerify,
                      icon: Icons.check,
                    ),
                    const SizedBox(height: 16),

                    Center(
                      child: TextButton(
                        onPressed: _handleResend,
                        child: Text(
                          "Didn't receive the SMS? Resend Code",
                          style: HithaText.bodySmall.copyWith(
                            color: HithaColors.mintDark,
                            fontWeight: FontWeight.w700,
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
    );
  }
}
