import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../config/routes.dart';
import '../../../core/theme/hitha_theme.dart';
import '../../../core/widgets/hitha_widgets.dart';
import '../view_models/auth_view_model.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _identifierCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _newPasswordCtrl = TextEditingController();

  bool _codeSent = false;

  @override
  void dispose() {
    _identifierCtrl.dispose();
    _otpCtrl.dispose();
    _newPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSendCode() async {
    final id = _identifierCtrl.text.trim();
    if (id.isEmpty) {
      showHithaSnack(context, 'Please enter your registered email or phone number', isError: true);
      return;
    }

    final authVm = context.read<AuthViewModel>();
    final success = await authVm.sendOtp(identifier: id, purpose: 'PASSWORD_RESET');

    if (!mounted) return;

    if (success) {
      setState(() => _codeSent = true);
      showHithaSnack(context, 'Recovery code sent to $id');
    } else if (authVm.errorMessage != null) {
      showHithaSnack(context, authVm.errorMessage!, isError: true);
    }
  }

  Future<void> _handleResetPassword() async {
    final code = _otpCtrl.text.trim();
    final newPass = _newPasswordCtrl.text;

    if (code.length < 6 || newPass.length < 8) {
      showHithaSnack(context, 'Please provide the 6-digit code and a new password (min. 8 characters)', isError: true);
      return;
    }

    final authVm = context.read<AuthViewModel>();
    final success = await authVm.resetPassword(
      identifier: _identifierCtrl.text.trim(),
      code: code,
      newPassword: newPass,
    );

    if (!mounted) return;

    if (success) {
      showHithaSnack(context, 'Password updated successfully! Please sign in.');
      context.go(Routes.login);
    } else if (authVm.errorMessage != null) {
      showHithaSnack(context, authVm.errorMessage!, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: HithaColors.cream,
      appBar: const HithaAppBar(title: 'Account Recovery'),
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
                    Text('Reset Your Password', style: HithaText.h2),
                    const SizedBox(height: 6),
                    Text(
                      !_codeSent
                          ? 'Enter your registered email address or phone number to receive a one-time verification recovery code.'
                          : 'Enter the 6-digit recovery code and create a new secure password.',
                      style: HithaText.bodySmall,
                    ),
                    const SizedBox(height: 24),

                    HithaTextField(
                      label: 'Registered Email or Phone',
                      controller: _identifierCtrl,
                      hint: 'doctor@hitha.lk or +9477...',
                      readOnly: _codeSent,
                      prefixIcon: const Icon(Icons.person_outline, color: HithaColors.inkFaint, size: 20),
                    ),

                    if (_codeSent) ...[
                      const SizedBox(height: 16),
                      HithaTextField(
                        label: '6-Digit Recovery Code',
                        controller: _otpCtrl,
                        hint: '123456',
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        prefixIcon: const Icon(Icons.shield_outlined, color: HithaColors.inkFaint, size: 20),
                      ),
                      const SizedBox(height: 16),
                      HithaTextField(
                        label: 'New Password (min. 8 characters)',
                        controller: _newPasswordCtrl,
                        hint: '••••••••',
                        isPassword: true,
                        prefixIcon: const Icon(Icons.lock_outline, color: HithaColors.inkFaint, size: 20),
                      ),
                    ],

                    const SizedBox(height: 24),

                    if (!_codeSent)
                      PrimaryButton(
                        text: 'Send Recovery Code',
                        loading: authVm.loading,
                        onPressed: _handleSendCode,
                        icon: Icons.send_rounded,
                      )
                    else
                      PrimaryButton(
                        text: 'Reset & Update Password',
                        loading: authVm.loading,
                        onPressed: _handleResetPassword,
                        icon: Icons.check_circle_outline,
                      ),

                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () => context.pop(),
                        child: Text(
                          'Back to Sign In',
                          style: HithaText.bodyMedium.copyWith(
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
