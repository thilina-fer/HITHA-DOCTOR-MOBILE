import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../config/routes.dart';
import '../../../core/theme/hitha_theme.dart';
import '../../../core/widgets/hitha_widgets.dart';
import '../../auth/view_models/auth_view_model.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bioCtrl = TextEditingController();
  final _qualificationsCtrl = TextEditingController();
  final _specialtiesCtrl = TextEditingController();

  String _gender = 'MALE';
  final Set<String> _languages = {'en', 'si'};

  @override
  void dispose() {
    _bioCtrl.dispose();
    _qualificationsCtrl.dispose();
    _specialtiesCtrl.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_languages.isEmpty) {
      showHithaSnack(context, 'Please select at least one consultation language.', isError: true);
      return;
    }

    final authVm = context.read<AuthViewModel>();

    final quals = _qualificationsCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final specs = _specialtiesCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    final success = await authVm.completeProfile(
      professionalBio: _bioCtrl.text.trim(),
      gender: _gender,
      languages: _languages.toList(),
      qualifications: quals,
      specialties: specs,
    );

    if (!mounted) return;

    if (success) {
      showHithaSnack(context, 'Profile completed! Awaiting SLMC Administrative Review.');
      context.go(Routes.dashboard);
    } else if (authVm.errorMessage != null) {
      showHithaSnack(context, authVm.errorMessage!, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();

    return Scaffold(
      backgroundColor: HithaColors.cream,
      appBar: HithaAppBar(
        title: 'Complete Practitioner Profile',
        showBack: false,
        actions: [
          IconButton(
            tooltip: 'Sign Out',
            onPressed: () async {
              await authVm.logout();
              if (context.mounted) context.go(Routes.login);
            },
            icon: const Icon(Icons.logout, color: HithaColors.clay),
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: HithaSpacing.page, vertical: 20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: HithaCard(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const HithaPill(
                            text: 'PHASE 2 ONBOARDING',
                            background: HithaColors.sprout,
                            foreground: HithaColors.moss,
                          ),
                          const Spacer(),
                          Text(
                            'Step 2 of 2',
                            style: HithaText.caption.copyWith(color: HithaColors.inkFaint),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text('Practitioner Clinical Dossier', style: HithaText.h2),
                      const SizedBox(height: 6),
                      Text(
                        'This information will appear on your public doctor profile for patients seeking mental health consultations.',
                        style: HithaText.bodySmall,
                      ),
                      const SizedBox(height: 24),

                      // Bio
                      HithaTextField(
                        label: 'Professional Bio',
                        controller: _bioCtrl,
                        hint: 'Describe your clinical approach, experience, and therapeutic methods...',
                        maxLines: 4,
                      ),
                      const SizedBox(height: 20),

                      // Gender selection
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gender',
                            style: HithaText.bodySmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: HithaColors.forest,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              ChoiceChip(
                                label: const Text('Male'),
                                selected: _gender == 'MALE',
                                onSelected: (_) => setState(() => _gender = 'MALE'),
                                selectedColor: HithaColors.forest,
                                labelStyle: TextStyle(color: _gender == 'MALE' ? Colors.white : HithaColors.forest),
                              ),
                              const SizedBox(width: 10),
                              ChoiceChip(
                                label: const Text('Female'),
                                selected: _gender == 'FEMALE',
                                onSelected: (_) => setState(() => _gender = 'FEMALE'),
                                selectedColor: HithaColors.forest,
                                labelStyle: TextStyle(color: _gender == 'FEMALE' ? Colors.white : HithaColors.forest),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Consultation Languages
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Consultation Languages',
                            style: HithaText.bodySmall.copyWith(
                              fontWeight: FontWeight.w700,
                              color: HithaColors.forest,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            children: [
                              FilterChip(
                                label: const Text('English (en)'),
                                selected: _languages.contains('en'),
                                onSelected: (val) => setState(() {
                                  val ? _languages.add('en') : _languages.remove('en');
                                }),
                              ),
                              FilterChip(
                                label: const Text('Sinhala (si)'),
                                selected: _languages.contains('si'),
                                onSelected: (val) => setState(() {
                                  val ? _languages.add('si') : _languages.remove('si');
                                }),
                              ),
                              FilterChip(
                                label: const Text('Tamil (ta)'),
                                selected: _languages.contains('ta'),
                                onSelected: (val) => setState(() {
                                  val ? _languages.add('ta') : _languages.remove('ta');
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Qualifications
                      HithaTextField(
                        label: 'Qualifications (comma-separated)',
                        controller: _qualificationsCtrl,
                        hint: 'MBBS (Colombo), MSc Clinical Psychology, SLPA Fellow',
                      ),
                      const SizedBox(height: 16),

                      // Specialties
                      HithaTextField(
                        label: 'Clinical Specialties (comma-separated)',
                        controller: _specialtiesCtrl,
                        hint: 'Anxiety, Depression, Trauma / PTSD, CBT, Family Therapy',
                      ),
                      const SizedBox(height: 28),

                      PrimaryButton(
                        text: 'Save Dossier & Go to Dashboard',
                        loading: authVm.loading,
                        onPressed: _handleSubmit,
                        icon: Icons.done_all_rounded,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
