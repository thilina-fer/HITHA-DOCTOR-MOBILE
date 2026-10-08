import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../config/routes.dart';
import '../../../../domain/models/models.dart';
import '../../../core/theme/hitha_theme.dart';
import '../../../core/widgets/hitha_widgets.dart';
import '../../auth/view_models/auth_view_model.dart';
import '../view_models/dashboard_view_model.dart';

class DoctorDashboardScreen extends StatefulWidget {
  const DoctorDashboardScreen({super.key});

  @override
  State<DoctorDashboardScreen> createState() => _DoctorDashboardScreenState();
}

class _DoctorDashboardScreenState extends State<DoctorDashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _selectedDayIndex = 1; // Default to Friday Oct 9 (index 1)

  final List<Map<String, String>> _days = const [
    {'day': 'THU', 'date': 'Oct 8'},
    {'day': 'FRI', 'date': 'Oct 9'},
    {'day': 'SAT', 'date': 'Oct 10'},
    {'day': 'SUN', 'date': 'Oct 11'},
    {'day': 'MON', 'date': 'Oct 12'},
    {'day': 'TUE', 'date': 'Oct 13'},
    {'day': 'WED', 'date': 'Oct 14'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().loadDashboard();
    });
  }

  void _showStatusPicker(BuildContext context, AuthViewModel authVm) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        final current = authVm.doctor?.status ?? DoctorStatus.ONLINE;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Update Practitioner Status', style: HithaText.h3),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Your online availability controls patient queue routing and instant telehealth matching.',
                  style: HithaText.bodySmall,
                ),
                const SizedBox(height: 16),
                ...DoctorStatus.values.map((status) {
                  final isSelected = current == status;
                  Color dotColor;
                  switch (status) {
                    case DoctorStatus.ONLINE:
                      dotColor = HithaColors.moss;
                      break;
                    case DoctorStatus.BUSY:
                      dotColor = HithaColors.saffron;
                      break;
                    case DoctorStatus.AWAY:
                    case DoctorStatus.PAUSED:
                      dotColor = HithaColors.slate400;
                      break;
                    case DoctorStatus.OFFLINE:
                      dotColor = HithaColors.clay;
                      break;
                  }

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    leading: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
                    ),
                    title: Text(
                      status.label,
                      style: TextStyle(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? HithaColors.forest : HithaColors.ink,
                      ),
                    ),
                    trailing: isSelected
                        ? const Icon(Icons.check_circle, color: HithaColors.forest, size: 20)
                        : null,
                    onTap: () async {
                      Navigator.pop(ctx);
                      await authVm.updateOnlineStatus(status);
                      if (context.mounted) {
                        showHithaSnack(context, 'Status changed to ${status.label}');
                      }
                    },
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showNotificationsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Notifications', style: HithaText.h3),
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFDCFCE7),
                    child: Icon(Icons.check, color: Color(0xFF16A34A), size: 18),
                  ),
                  title: const Text('Consultation Confirmed', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: const Text('Anonymous Patient (#a4b5517) scheduled for today at 11:40 AM.', style: TextStyle(fontSize: 12)),
                  contentPadding: EdgeInsets.zero,
                ),
                const Divider(),
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEFF6FF),
                    child: Icon(Icons.account_balance_wallet, color: Color(0xFF2563EB), size: 18),
                  ),
                  title: const Text('Escrow Cleared', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: const Text('LKR 10,000 released to your available balance.', style: TextStyle(fontSize: 12)),
                  contentPadding: EdgeInsets.zero,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final dashVm = context.watch<DashboardViewModel>();
    final doctor = authVm.doctor;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF4F8F6),
      drawer: _buildDrawer(context, authVm, doctor),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Top Custom App Bar matching mockup
            _buildTopAppBar(context, authVm, doctor),

            // 2. Scrollable Body
            Expanded(
              child: RefreshIndicator(
                color: HithaColors.forest,
                onRefresh: () async {
                  await Future.wait([
                    authVm.init(),
                    dashVm.loadDashboard(),
                  ]);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 10,
                    bottom: HithaSpacing.pageBottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Greeting & Status Header with Serene Botanical illustration
                      _buildGreetingHeader(context, authVm, doctor),
                      const SizedBox(height: 16),

                      // SLMC Review Banner (if unverified or pending)
                      if (doctor != null && doctor.verificationStatus != VerificationStatus.ACTIVE) ...[
                        _buildVerificationBanner(doctor),
                        const SizedBox(height: 16),
                      ],

                      // Card 1: Next Session Card
                      _buildNextSessionCard(context),
                      const SizedBox(height: 18),

                      // Card 2: Today's Schedule Card
                      _buildTodayScheduleCard(context),
                      const SizedBox(height: 20),
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

  // --- Top App Bar ---
  Widget _buildTopAppBar(BuildContext context, AuthViewModel authVm, DoctorProfile? doctor) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Hamburger Menu
          IconButton(
            icon: const Icon(Icons.menu_rounded, color: Color(0xFF1E293B), size: 26),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),

          const Spacer(),

          // Centered Logo & Brand Name
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const HithaLotus(size: 26, color: Color(0xFF0D9488)),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'HITHA.LK',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.4,
                      color: Color(0xFF0F766E),
                    ),
                  ),
                  Text(
                    'peace of mind',
                    style: TextStyle(
                      fontSize: 9,
                      letterSpacing: 0.6,
                      color: Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Notification Bell with Red Badge
          GestureDetector(
            onTap: () => _showNotificationsSheet(context),
            child: Stack(
              children: [
                const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.notifications_none_rounded, color: Color(0xFF1E293B), size: 25),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEF4444),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Doctor Avatar with Dropdown Arrow
          GestureDetector(
            onTap: () => context.go(Routes.profile),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                HithaAvatar(
                  url: doctor?.profilePictureUrl,
                  size: 34,
                  radius: 17,
                ),
                const SizedBox(width: 3),
                const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF64748B)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Greeting & Status Header with Leaf Illustration ---
  Widget _buildGreetingHeader(BuildContext context, AuthViewModel authVm, DoctorProfile? doctor) {
    final status = doctor?.status ?? DoctorStatus.ONLINE;
    final doctorName = (doctor != null && doctor.firstName.isNotEmpty)
        ? 'Dr. ${doctor.firstName}'
        : 'Dr. Thilina';

    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Serene Botanical Leaves in Top-Right
        const Positioned(
          right: -10,
          top: -10,
          width: 140,
          height: 140,
          child: CustomPaint(
            painter: _SereneBotanicalLeavesPainter(),
          ),
        ),

        // Text & Status Row
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Good morning,',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 3),
            Row(
              children: [
                Text(
                  doctorName,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(width: 12),

                // Interactive Status Pill Dropdown
                GestureDetector(
                  onTap: () => _showStatusPicker(context, authVm),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8F0),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFC6F0D9)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: status == DoctorStatus.ONLINE
                                ? const Color(0xFF10B981)
                                : status == DoctorStatus.BUSY
                                    ? const Color(0xFFF59E0B)
                                    : const Color(0xFF94A3B8),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          status.label,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF065F46),
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 16,
                          color: Color(0xFF065F46),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Welcome back to your digital sanctuary.\nYou have 2 upcoming consultations today.',
              style: TextStyle(
                fontSize: 13.5,
                height: 1.45,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // --- Next Session Card ---
  Widget _buildNextSessionCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEDF2F7), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0D3B66),
            blurRadius: 18,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Video icon + "Next Session" + "View All ->"
          Row(
            children: [
              const Icon(Icons.videocam_outlined, color: Color(0xFF0D9488), size: 24),
              const SizedBox(width: 8),
              const Text(
                'Next Session',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.go(Routes.bookings),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Text(
                        'View All',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded, size: 14, color: Color(0xFF0F766E)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Details Row: Date Block + Time/Patient + Confirmed Badge
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Date Block
              Container(
                width: 58,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  children: const [
                    Text(
                      'OCT',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '9',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'FRI',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),

              // Patient Info & Time
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF64748B)),
                        SizedBox(width: 5),
                        Text(
                          '11:40 AM – 12:25 PM',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Anonymous Patient',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Ref: #a4b5517',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Color(0xFF94A3B8),
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Confirmed Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.check_circle_rounded, size: 13, color: Color(0xFF16A34A)),
                    SizedBox(width: 4),
                    Text(
                      'Confirmed',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF16A34A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Fee & "Join Room" Button Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Session Fee
              Row(
                children: [
                  const Icon(Icons.payments_outlined, color: Color(0xFF0D9488), size: 24),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Session Fee',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'LKR 5,000',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              // Join Room Button
              ElevatedButton.icon(
                onPressed: () => context.push(Routes.meetingPath('a4b5517')),
                icon: const Icon(Icons.videocam_outlined, color: Colors.white, size: 18),
                label: const Text(
                  'Join Room',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C3854),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- Today's Schedule Card ---
  Widget _buildTodayScheduleCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFEDF2F7), width: 1.2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A0D3B66),
            blurRadius: 18,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Calendar Icon + Title + Date
          Row(
            children: const [
              Icon(Icons.calendar_today_outlined, color: Color(0xFF0D9488), size: 22),
              SizedBox(width: 8),
              Text(
                "Today's Schedule",
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                ),
              ),
              Spacer(),
              Text(
                'Fri, Oct 9, 2026',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Horizontal 7-Day Selector Strip
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: List.generate(_days.length, (index) {
                final dayData = _days[index];
                final isSelected = _selectedDayIndex == index;

                return Padding(
                  padding: EdgeInsets.only(right: index == _days.length - 1 ? 0 : 8),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDayIndex = index;
                      });
                    },
                    child: Container(
                      width: 52,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFF065F46) : const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF065F46) : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            dayData['day']!,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : const Color(0xFF64748B),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            dayData['date']!,
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w800,
                              color: isSelected ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 20),

          // Timeline Queue: Item 1
          _buildTimelineRow(
            timeStart: '11:40 AM',
            timeEnd: '12:25 PM',
            patient: 'Anonymous Patient',
            ref: 'Ref: #a4b5517',
            statusText: 'Confirmed',
            bookingId: 'a4b5517',
            isFirst: true,
            isLast: false,
          ),

          // Timeline Queue: Item 2
          _buildTimelineRow(
            timeStart: '01:30 PM',
            timeEnd: '02:15 PM',
            patient: 'Anonymous Patient',
            ref: 'Ref: #zc371bfe',
            statusText: 'Confirmed',
            bookingId: 'zc371bfe',
            isFirst: false,
            isLast: true,
          ),
          const SizedBox(height: 18),

          // Full width "Manage Availability" Button
          InkWell(
            onTap: () => context.go(Routes.availability),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.calendar_today_outlined, size: 18, color: Color(0xFF0F172A)),
                  SizedBox(width: 10),
                  Text(
                    'Manage Availability',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  Spacer(),
                  Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF64748B)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- Timeline Consultation Row ---
  Widget _buildTimelineRow({
    required String timeStart,
    required String timeEnd,
    required String patient,
    required String ref,
    required String statusText,
    required String bookingId,
    required bool isFirst,
    required bool isLast,
  }) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline indicator & line
          SizedBox(
            width: 18,
            child: Column(
              children: [
                const SizedBox(height: 4),
                Container(
                  width: 10,
                  height: 10,
                  decoration: const BoxDecoration(
                    color: Color(0xFF0D9488),
                    shape: BoxShape.circle,
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: const Color(0xFFE2E8F0),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Time Column
          SizedBox(
            width: 72,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  timeStart,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  timeEnd,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Patient Name & Ref
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patient,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  ref,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
          const SizedBox(width: 6),

          // Confirmed Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.check_circle_rounded, size: 12, color: Color(0xFF16A34A)),
                SizedBox(width: 3),
                Text(
                  'Confirmed',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF16A34A),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Join Button
          ElevatedButton.icon(
            onPressed: () => context.push(Routes.meetingPath(bookingId)),
            icon: const Icon(Icons.videocam_outlined, color: Colors.white, size: 14),
            label: const Text(
              'Join',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0C3854),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: const Size(60, 32),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- SLMC Verification Alert Banner ---
  Widget _buildVerificationBanner(DoctorProfile doctor) {
    return Container(
      decoration: BoxDecoration(
        color: HithaColors.creamDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: HithaColors.saffron.withValues(alpha: 0.35)),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Icon(Icons.verified_user_outlined, color: HithaColors.forest, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SLMC Credential Verification: ${doctor.verificationStatus.value}',
                  style: HithaText.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: HithaColors.forest,
                    fontSize: 13,
                  ),
                ),
                Text(
                  'Your profile dossier is under review by Hitha Medical Board.',
                  style: HithaText.caption.copyWith(color: HithaColors.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Drawer for Hamburger Menu ---
  Widget _buildDrawer(BuildContext context, AuthViewModel authVm, DoctorProfile? doctor) {
    return Drawer(
      backgroundColor: Colors.white,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: Color(0xFFF4F8F6),
                border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Row(
                children: [
                  HithaAvatar(url: doctor?.profilePictureUrl, size: 48, radius: 24),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor?.fullName ?? 'Dr. Thilina',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          doctor?.email ?? 'practitioner@hitha.lk',
                          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctor?.slmcLicenseNumber.isNotEmpty == true
                              ? 'SLMC: ${doctor!.slmcLicenseNumber}'
                              : 'SLMC: SLMC-98765',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF0D9488),
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.dashboard_outlined, color: Color(0xFF0F766E)),
              title: const Text('Dashboard', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                context.go(Routes.dashboard);
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today_outlined, color: Color(0xFF0F766E)),
              title: const Text('Availability & Schedule', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                context.go(Routes.availability);
              },
            ),
            ListTile(
              leading: const Icon(Icons.medical_services_outlined, color: Color(0xFF0F766E)),
              title: const Text('Consultations Queue', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                context.go(Routes.bookings);
              },
            ),
            ListTile(
              leading: const Icon(Icons.account_balance_wallet_outlined, color: Color(0xFF0F766E)),
              title: const Text('Wallet & Payouts', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                context.go(Routes.wallet);
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline, color: Color(0xFF0F766E)),
              title: const Text('Practitioner Profile', style: TextStyle(fontWeight: FontWeight.w600)),
              onTap: () {
                Navigator.pop(context);
                context.go(Routes.profile);
              },
            ),
            const Spacer(),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: HithaColors.clay),
              title: const Text(
                'Sign Out',
                style: TextStyle(fontWeight: FontWeight.w700, color: HithaColors.clay),
              ),
              onTap: () async {
                Navigator.pop(context);
                await authVm.logout();
                if (context.mounted) {
                  context.go(Routes.login);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Translucent sage botanical leaves painter for serene wellness sanctuary ambiance
class _SereneBotanicalLeavesPainter extends CustomPainter {
  const _SereneBotanicalLeavesPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final leafPaint = Paint()
      ..color = const Color(0x3510B981) // Translucent emerald mint
      ..style = PaintingStyle.fill;

    final stemPaint = Paint()
      ..color = const Color(0x300D9488)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    final stemPath = Path()
      ..moveTo(size.width, 0)
      ..cubicTo(size.width * 0.82, size.height * 0.35, size.width * 0.68, size.height * 0.7, size.width * 0.58, size.height);
    canvas.drawPath(stemPath, stemPaint);

    void drawLeaf(double cx, double cy, double rx, double ry, double angle) {
      canvas.save();
      canvas.translate(cx, cy);
      canvas.rotate(angle);
      final path = Path()
        ..moveTo(0, -ry)
        ..quadraticBezierTo(rx, 0, 0, ry)
        ..quadraticBezierTo(-rx, 0, 0, -ry)
        ..close();
      canvas.drawPath(path, leafPaint);
      canvas.restore();
    }

    drawLeaf(size.width * 0.88, size.height * 0.22, 16, 38, -0.6);
    drawLeaf(size.width * 0.75, size.height * 0.32, 20, 44, -0.9);
    drawLeaf(size.width * 0.80, size.height * 0.52, 18, 40, -0.4);
    drawLeaf(size.width * 0.65, size.height * 0.64, 20, 46, -0.8);
    drawLeaf(size.width * 0.84, size.height * 0.76, 16, 36, -0.2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
