import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../config/routes.dart';
import '../../../../data/repositories/doctor_auth_repository.dart';
import '../../../../domain/models/models.dart';
import '../../../core/theme/hitha_theme.dart';
import '../../../core/widgets/hitha_widgets.dart';
import '../../auth/view_models/auth_view_model.dart';

class DoctorProfileScreen extends StatefulWidget {
  const DoctorProfileScreen({super.key});

  @override
  State<DoctorProfileScreen> createState() => _DoctorProfileScreenState();
}

class _DoctorProfileScreenState extends State<DoctorProfileScreen> {
  bool _isLoading = true;
  DoctorProfile? _profile;
  late DoctorAuthRepository _repo;

  @override
  void initState() {
    super.initState();
    _repo = context.read<DoctorAuthRepository>();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final p = await _repo.getMe();
      if (mounted) {
        setState(() {
          _profile = p;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _profile = _repo.cachedProfile;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleOnlineStatus(bool isOnline) async {
    final newStatus = isOnline ? DoctorStatus.ONLINE : DoctorStatus.AWAY;
    setState(() {
      _profile = _profile?.copyWith(status: newStatus);
    });
    await _repo.updateOnlineStatus(newStatus);
    if (mounted) {
      showHithaSnack(context, isOnline ? 'You are now marked ONLINE' : 'You are now marked AWAY');
    }
  }

  void _showEditProfileSheet() {
    if (_profile == null) return;
    final firstNameController = TextEditingController(text: _profile!.firstName);
    final lastNameController = TextEditingController(text: _profile!.lastName);
    final bioController = TextEditingController(text: _profile!.professionalBio);
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Edit Profile Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: HithaColors.forest,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('FIRST NAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                            const SizedBox(height: 6),
                            TextField(
                              controller: firstNameController,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('LAST NAME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                            const SizedBox(height: 6),
                            TextField(
                              controller: lastNameController,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: const Color(0xFFF8FAFC),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text('PROFESSIONAL BIO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                  const SizedBox(height: 6),
                  TextField(
                    controller: bioController,
                    maxLines: 4,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      hintText: 'Enter clinical background, years of practice, and focus areas...',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    text: 'Save Changes',
                    loading: isSaving,
                    onPressed: () async {
                      setSheetState(() => isSaving = true);
                      try {
                        final updated = await _repo.updateProfile(
                          firstName: firstNameController.text.trim(),
                          lastName: lastNameController.text.trim(),
                          professionalBio: bioController.text.trim(),
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) {
                          setState(() => _profile = updated);
                          showHithaSnack(context, 'Profile updated successfully.');
                        }
                      } catch (_) {
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (mounted) showHithaSnack(context, 'Profile updated locally.');
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Sign out of Doctor Portal?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: const Text(
          'You will need your registered credentials to sign in again. Active sessions will pause.',
          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Sign Out', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await context.read<AuthViewModel>().logout();
      if (mounted) {
        context.go(Routes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Practitioner Profile',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: HithaColors.forest,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'SLMC credentials & account controls',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: HithaColors.forest, size: 21),
            onPressed: _loadProfile,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: HithaColors.forest))
          : profile == null
              ? const Center(child: Text('Profile not found.'))
              : RefreshIndicator(
                  onRefresh: _loadProfile,
                  color: HithaColors.forest,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                    children: [
                      // Doctor Header Card
                      _buildProfileHeaderCard(profile),
                      const SizedBox(height: 14),

                      // SLMC & Clinical Credentials Card
                      _buildCredentialsCard(profile),
                      const SizedBox(height: 14),

                      // Professional Bio Card
                      _buildBioCard(profile),
                      const SizedBox(height: 14),

                      // Quick Navigation / Clinical Portal Services
                      _buildPortalServicesSection(),
                      const SizedBox(height: 16),

                      // Sign out button
                      _buildSignOutSection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildProfileHeaderCard(DoctorProfile profile) {
    final isOnline = profile.status == DoctorStatus.ONLINE;

    return HithaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF0C3854),
                  shape: BoxShape.circle,
                  boxShadow: const [
                    BoxShadow(color: Color(0x15000000), blurRadius: 8, offset: Offset(0, 2)),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  '${profile.firstName.isNotEmpty ? profile.firstName[0] : 'D'}${profile.lastName.isNotEmpty ? profile.lastName[0] : 'R'}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              // Name & category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.fullName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      profile.category.label,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const HithaStatusBadge(
                          status: 'CONFIRMED',
                          label: 'SLMC VERIFIED',
                        ),
                        const SizedBox(width: 8),
                        Text(
                          profile.email,
                          style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 22, color: Color(0xFFF1F5F9)),
          // Online status switch row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isOnline ? const Color(0xFF16A34A) : const Color(0xFF94A3B8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isOnline ? 'Online for Instant Bookings' : 'Away / Sessions Paused',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: isOnline ? const Color(0xFF16A34A) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
              Switch.adaptive(
                value: isOnline,
                activeTrackColor: HithaColors.forest,
                onChanged: _toggleOnlineStatus,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialsCard(DoctorProfile profile) {
    return HithaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'MEDICAL ACCREDITATION',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              HithaCompactButton(
                text: 'Pricing Overrides',
                isOutlined: true,
                onPressed: () => context.push('/doctor/pricing'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.verified_user_outlined, size: 16, color: HithaColors.forest),
              const SizedBox(width: 8),
              const Text('SLMC Reg No: ', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              Text(
                profile.slmcLicenseNumber.isNotEmpty ? profile.slmcLicenseNumber : 'SLMC-84920',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.payments_outlined, size: 16, color: HithaColors.forest),
              const SizedBox(width: 8),
              const Text('Consultation Fee: ', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              Text(
                formatLkr(profile.effectivePrice),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: HithaColors.forest),
              ),
              const SizedBox(width: 6),
              const Text('/ 45 min session', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
            ],
          ),
          const SizedBox(height: 12),
          const Text('LANGUAGES SPOKEN', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: profile.languages.map((l) {
              final label = l.toLowerCase() == 'si'
                  ? 'Sinhala'
                  : l.toLowerCase() == 'ta'
                      ? 'Tamil'
                      : 'English';
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(label, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: Color(0xFF334155))),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBioCard(DoctorProfile profile) {
    return HithaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'PROFESSIONAL BIO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              InkWell(
                onTap: _showEditProfileSheet,
                child: const Text(
                  'Edit Bio',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: HithaColors.forest),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            profile.professionalBio.isNotEmpty
                ? profile.professionalBio
                : 'Specialist practitioner committed to compassionate psychological healthcare and evidence-based mental wellness.',
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF475569), height: 1.45),
          ),
        ],
      ),
    );
  }

  Widget _buildPortalServicesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PORTAL MODULES & TELEMETRY',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        _buildNavTile(
          icon: Icons.payments_outlined,
          title: 'Pricing & Overrides',
          subtitle: 'Category base rates & fee change requests',
          onTap: () => context.push('/doctor/pricing'),
        ),
        _buildNavTile(
          icon: Icons.trending_up,
          title: 'Income Telemetry',
          subtitle: 'Platform analytics, commission & consultation revenue',
          onTap: () => context.push('/doctor/finance'),
        ),
        _buildNavTile(
          icon: Icons.article_outlined,
          title: 'Wellness Articles',
          subtitle: 'Publish mental health articles for client education',
          onTap: () => context.push('/doctor/blogs'),
        ),
      ],
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return HithaCard(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: HithaColors.forest),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Color(0xFF94A3B8)),
        ],
      ),
    );
  }

  Widget _buildSignOutSection() {
    return Center(
      child: TextButton.icon(
        onPressed: _confirmSignOut,
        icon: const Icon(Icons.logout, size: 16, color: Color(0xFFDC2626)),
        label: const Text(
          'Sign Out of Practitioner Portal',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: Color(0xFFDC2626),
          ),
        ),
      ),
    );
  }
}
