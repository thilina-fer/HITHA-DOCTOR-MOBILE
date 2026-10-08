import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../config/routes.dart';
import '../../../../domain/models/models.dart';
import '../../../core/theme/hitha_theme.dart';
import '../../../core/widgets/hitha_widgets.dart';
import '../view_models/auth_view_model.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController(text: '+94 ');
  final _slmcCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  DoctorCategory _selectedCategory = DoctorCategory.CLINICAL_PSYCHOLOGIST;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _slmcCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    final authVm = context.read<AuthViewModel>();

    final success = await authVm.register(
      firstName: _firstNameCtrl.text.trim(),
      lastName: _lastNameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim().replaceAll(' ', ''),
      password: _passwordCtrl.text,
      category: _selectedCategory,
      slmcLicenseNumber: _slmcCtrl.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      await authVm.sendOtp(
        identifier: _phoneCtrl.text.trim().replaceAll(' ', ''),
        purpose: 'DOCTOR_LOGIN',
      );
      if (mounted) {
        showHithaSnack(context, 'Verification code sent to ${_phoneCtrl.text.trim()}');
        context.push(Routes.verifyPhone);
      }
    } else if (authVm.errorMessage != null) {
      showHithaSnack(context, authVm.errorMessage!, isError: true);
    }
  }

  OutlineInputBorder _inputBorder(Color color, [double width = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF7FAF8),
      body: Stack(
        children: [
          // 1. Organic Decorative Background Elements (matching Sign In)
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
            top: 180,
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

          // 2. Main Scrollable Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Centered Logo
                      Image.asset(
                        'assets/images/hitha_logo.png',
                        width: 130,
                        height: 130,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const HithaLotus(size: 60, color: HithaColors.forest),
                      ),
                      const SizedBox(height: 12),

                      // Short & Sweet Title
                      Text(
                        'Create Doctor Account',
                        textAlign: TextAlign.center,
                        style: HithaText.h1.copyWith(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          color: const Color(0xFF0D3B66),
                        ),
                      ),
                      const SizedBox(height: 22),

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
                              // 1. First Name (Vertical list item)
                              _buildFieldLabel('First Name'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _firstNameCtrl,
                                style: _inputTextStyle(),
                                decoration: _inputDecoration(
                                  hintText: 'Kasun',
                                  prefixIcon: Icons.person_outline_rounded,
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Please enter your first name';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // 2. Last Name (Vertical list item below First Name)
                              _buildFieldLabel('Last Name'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _lastNameCtrl,
                                style: _inputTextStyle(),
                                decoration: _inputDecoration(
                                  hintText: 'Perera',
                                  prefixIcon: Icons.person_outline_rounded,
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Please enter your last name';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // 3. Email Address
                              _buildFieldLabel('Email Address'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                style: _inputTextStyle(),
                                decoration: _inputDecoration(
                                  hintText: 'doctor@hitha.lk',
                                  prefixIcon: Icons.mail_outline_rounded,
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Please enter your email';
                                  if (!val.contains('@')) return 'Please enter a valid email';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // 4. Phone Number
                              _buildFieldLabel('Sri Lankan Phone Number'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _phoneCtrl,
                                keyboardType: TextInputType.phone,
                                style: _inputTextStyle(),
                                decoration: _inputDecoration(
                                  hintText: '+94 77 123 4567',
                                  prefixIcon: Icons.phone_outlined,
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Please enter your phone number';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // 5. SLMC Registration Number
                              _buildFieldLabel('SLMC Registration Number'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _slmcCtrl,
                                textCapitalization: TextCapitalization.characters,
                                style: _inputTextStyle(),
                                decoration: _inputDecoration(
                                  hintText: 'SLMC-12345',
                                  prefixIcon: Icons.badge_outlined,
                                ),
                                validator: (val) {
                                  if (val == null || val.trim().isEmpty) return 'Please enter your SLMC number';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),

                              // 6. Practitioner Category (No price displayed)
                              _buildFieldLabel('Practitioner Category'),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF3F7F6),
                                  borderRadius: BorderRadius.circular(13),
                                  border: Border.all(color: const Color(0xFFE0EBE7), width: 1),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.medical_services_outlined,
                                      color: Color(0xFF90A4B2),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: DropdownButtonHideUnderline(
                                        child: DropdownButton<DoctorCategory>(
                                          value: _selectedCategory,
                                          isExpanded: true,
                                          icon: const Icon(
                                            Icons.keyboard_arrow_down,
                                            color: Color(0xFF90A4B2),
                                            size: 22,
                                          ),
                                          style: _inputTextStyle(),
                                          dropdownColor: Colors.white,
                                          items: DoctorCategory.values.map((cat) {
                                            return DropdownMenuItem<DoctorCategory>(
                                              value: cat,
                                              child: Text(
                                                cat.label,
                                                style: _inputTextStyle(),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            );
                                          }).toList(),
                                          onChanged: (val) {
                                            if (val != null) setState(() => _selectedCategory = val);
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),

                              // 7. Password
                              _buildFieldLabel('Password (min. 8 characters)'),
                              const SizedBox(height: 8),
                              TextFormField(
                                controller: _passwordCtrl,
                                obscureText: _obscurePassword,
                                style: _inputTextStyle(),
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
                                  enabledBorder: _inputBorder(const Color(0xFFE0EBE7)),
                                  focusedBorder: _inputBorder(const Color(0xFF0D3B66), 1.5),
                                  errorBorder: _inputBorder(HithaColors.clay),
                                  focusedErrorBorder: _inputBorder(HithaColors.clay, 1.5),
                                ),
                                validator: (val) {
                                  if (val == null || val.length < 8) {
                                    return 'Password must be at least 8 characters';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 24),

                              // Register Button
                              SizedBox(
                                width: double.infinity,
                                height: 50,
                                child: FilledButton(
                                  onPressed: authVm.loading ? null : _handleRegister,
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
                                          'Register as a Doctor',
                                          style: HithaText.bodyMedium.copyWith(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Back to Sign In Link
                              Center(
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      'Already registered? ',
                                      style: HithaText.bodySmall.copyWith(
                                        color: const Color(0xFF5A7184),
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () => context.pop(),
                                      child: Text(
                                        'Sign In',
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

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: HithaText.bodySmall.copyWith(
        fontWeight: FontWeight.w700,
        fontSize: 13,
        color: const Color(0xFF32536A),
      ),
    );
  }

  TextStyle _inputTextStyle() {
    return HithaText.body.copyWith(
      fontSize: 14,
      color: const Color(0xFF0D3B66),
      fontWeight: FontWeight.w500,
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: HithaText.body.copyWith(
        fontSize: 13.5,
        color: const Color(0xFF9EADB8),
      ),
      filled: true,
      fillColor: const Color(0xFFF3F7F6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      prefixIcon: Icon(
        prefixIcon,
        color: const Color(0xFF90A4B2),
        size: 20,
      ),
      isDense: true,
      enabledBorder: _inputBorder(const Color(0xFFE0EBE7)),
      focusedBorder: _inputBorder(const Color(0xFF0D3B66), 1.5),
      errorBorder: _inputBorder(HithaColors.clay),
      focusedErrorBorder: _inputBorder(HithaColors.clay, 1.5),
    );
  }
}
