import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
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
  int _selectedDateIndex = 0;

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

  void _showNotificationsSheet(BuildContext context, List<BookingItem> bookings) {
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
                if (bookings.isNotEmpty) ...[
                  ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFDCFCE7),
                      child: Icon(Icons.check, color: Color(0xFF16A34A), size: 18),
                    ),
                    title: const Text('Consultation Active', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                    subtitle: Text(
                      '${bookings.first.patientName} (${bookings.first.bookingReference}) is ready for telehealth.',
                      style: const TextStyle(fontSize: 12),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                  const Divider(),
                ],
                ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFEFF6FF),
                    child: Icon(Icons.account_balance_wallet, color: Color(0xFF2563EB), size: 18),
                  ),
                  title: const Text('Escrow Telemetry', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                  subtitle: const Text('Real-time earnings synced with Hitha Core Ledger.', style: TextStyle(fontSize: 12)),
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
      backgroundColor: const Color(0xFFF8FAFC),
      drawer: _buildDrawer(context, authVm, doctor),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 1. Top Custom App Bar
            _buildTopAppBar(context, authVm, dashVm, doctor),

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
                      // Clean Greeting & Status Header
                      _buildGreetingHeader(context, authVm, doctor),
                      const SizedBox(height: 18),

                      // SLMC Review Banner (if unverified or pending)
                      if (doctor != null && doctor.verificationStatus != VerificationStatus.ACTIVE) ...[
                        _buildVerificationBanner(doctor),
                        const SizedBox(height: 16),
                      ],

                      // Section 1: Next Session Card (Real Data)
                      _buildNextSessionSection(context, dashVm),
                      const SizedBox(height: 24),

                      // Section 2: Availability Section (Real Data)
                      _buildAvailabilitySection(context, dashVm),
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
  Widget _buildTopAppBar(
    BuildContext context,
    AuthViewModel authVm,
    DashboardViewModel dashVm,
    DoctorProfile? doctor,
  ) {
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
            onTap: () => _showNotificationsSheet(context, dashVm.todayBookings),
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

  // --- Clean Greeting & Status Header ---
  Widget _buildGreetingHeader(BuildContext context, AuthViewModel authVm, DoctorProfile? doctor) {
    final status = doctor?.status ?? DoctorStatus.ONLINE;
    final doctorName = (doctor != null && doctor.firstName.isNotEmpty)
        ? 'Dr. ${doctor.firstName}'
        : 'Dr. Thilina';

    return Column(
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
        const SizedBox(height: 6),
        const Text(
          'Welcome back to your digital sanctuary.',
          style: TextStyle(
            fontSize: 13.5,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  // --- Section 1: Next Session Card (Real Backend Data) ---
  Widget _buildNextSessionSection(BuildContext context, DashboardViewModel dashVm) {
    final bookings = dashVm.todayBookings;
    final BookingItem? nextSession = bookings.isNotEmpty ? bookings.first : null;

    final sessionDate = nextSession?.scheduledStartTime ?? DateTime.now();
    final monthStr = DateFormat('MMM').format(sessionDate).toUpperCase();
    final dayStr = DateFormat('dd').format(sessionDate);
    final weekdayStr = DateFormat('EEE').format(sessionDate).toUpperCase();

    final timeStartStr = nextSession != null
        ? DateFormat('hh.mm a').format(nextSession.scheduledStartTime)
        : '11.40 AM';
    final timeEndStr = nextSession != null
        ? DateFormat('hh.mm a').format(nextSession.scheduledEndTime)
        : '12.25 PM';

    final patientName = nextSession?.patientName ?? 'Anonymous Patient';
    final refStr = nextSession != null ? 'REF : ${nextSession.bookingReference}' : 'REF : 123654';
    final feeStr = nextSession != null ? nextSession.feeLkr.toStringAsFixed(2) : '5000.00';
    final bookingId = nextSession?.id ?? '123654';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title Row: Next Session + View All
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Next Session',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            GestureDetector(
              onTap: () => context.go(Routes.bookings),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: const Text(
                  'View All',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Next Session Card Container
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFEDF2F7), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C0D3B66),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left: Grey Date Box (Real Date)
                  Container(
                    width: 88,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          monthStr,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          dayStr,
                          style: const TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          weekdayStr,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Right: Session Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Time + Green Status Pill
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 14, color: Color(0xFF1E293B)),
                                const SizedBox(width: 5),
                                Text(
                                  '$timeStartStr - $timeEndStr',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                              ],
                            ),
                            // Green Indicator Pill
                            Container(
                              width: 38,
                              height: 12,
                              decoration: BoxDecoration(
                                color: const Color(0xFF00E676),
                                borderRadius: BorderRadius.circular(10),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x6600E676),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        // Patient Name
                        Text(
                          patientName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),

                        // Ref
                        Text(
                          refStr,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF64748B),
                            fontFamily: 'monospace',
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),

                        // Session Fee Label & Amount
                        const Text(
                          'SESSION FEE :',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF64748B),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          feeStr,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Full width JOIN NOW Button
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () => context.push(Routes.meetingPath(bookingId)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0C3854),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    'JOIN NOW',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // --- Section 2: Availability Section (Real Backend Windows) ---
  Widget _buildAvailabilitySection(BuildContext context, DashboardViewModel dashVm) {
    // Generate 7 consecutive days starting today
    final now = DateTime.now();
    final dynamicDates = List.generate(7, (i) => now.add(Duration(days: i)));
    final selectedDate = dynamicDates[_selectedDateIndex < dynamicDates.length ? _selectedDateIndex : 0];

    // Filter real availability windows from backend for the selected date
    final daySlots = dashVm.availabilityWindows.where((w) {
      if (w.startDateTime != null) {
        return w.startDateTime!.year == selectedDate.year &&
            w.startDateTime!.month == selectedDate.month &&
            w.startDateTime!.day == selectedDate.day;
      }
      return w.dayOfWeek == selectedDate.weekday;
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title: "Availability" + Configure action
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Availability',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            GestureDetector(
              onTap: () => context.go(Routes.availability),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Configure',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      color: HithaColors.forest,
                    ),
                  ),
                  SizedBox(width: 4),
                  Icon(Icons.tune_rounded, size: 16, color: HithaColors.forest),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Dynamic 7-Day Horizontal Cards Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          clipBehavior: Clip.none,
          child: Row(
            children: List.generate(dynamicDates.length, (index) {
              final d = dynamicDates[index];
              final isSelected = _selectedDateIndex == index;
              final monthStr = DateFormat('MMM').format(d).toUpperCase();
              final dayStr = DateFormat('dd').format(d);
              final weekdayStr = DateFormat('EEE').format(d).toUpperCase();

              return Padding(
                padding: EdgeInsets.only(right: index == dynamicDates.length - 1 ? 0 : 12),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDateIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 76,
                    height: 104,
                    decoration: BoxDecoration(
                      color: isSelected ? HithaColors.forest : Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isSelected ? HithaColors.forest : const Color(0xFFE2E8F0),
                        width: isSelected ? 1.5 : 1.2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isSelected ? const Color(0x280D3B66) : const Color(0x060D3B66),
                          blurRadius: isSelected ? 12 : 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          monthStr,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isSelected ? const Color(0xFFD1FAE5) : const Color(0xFF64748B),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dayStr,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: isSelected ? Colors.white : const Color(0xFF0F172A),
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          weekdayStr,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isSelected ? const Color(0xFFD1FAE5) : const Color(0xFF64748B),
                            letterSpacing: 0.5,
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
        const SizedBox(height: 16),

        // "Time slots" Container
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFEDF2F7), width: 1.2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0C0D3B66),
                blurRadius: 18,
                offset: Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.access_time_rounded, color: Color(0xFF0D9488), size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Time slots',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F8F0),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${daySlots.length} Active Slots',
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF065F46),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Time slot rows
              if (daySlots.isEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      Icon(Icons.event_available_outlined, size: 36, color: Colors.grey.shade400),
                      const SizedBox(height: 8),
                      Text(
                        'No time slots configured for ${DateFormat('EEE, MMM d').format(selectedDate)}',
                        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Tap below to configure recurring templates or open instant slots.',
                        style: TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              else
                ...List.generate(daySlots.length, (slotIdx) {
                  final slot = daySlots[slotIdx];
                  final isBooked = slot.isBooked;

                  return Container(
                    margin: EdgeInsets.only(bottom: slotIdx == daySlots.length - 1 ? 0 : 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: isBooked ? const Color(0xFFF1F5F9) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isBooked ? const Color(0xFFCBD5E1) : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isBooked ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${slot.startTime} – ${slot.endTime}',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                  color: isBooked ? const Color(0xFF64748B) : const Color(0xFF0F172A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${isBooked ? "Booked Consultation" : "Available Slot"} • LKR ${slot.priceLkr.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: Color(0xFF64748B),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isBooked ? const Color(0xFFEFF6FF) : const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isBooked ? 'BOOKED' : 'OPEN',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: isBooked ? const Color(0xFF2563EB) : const Color(0xFF16A34A),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 14),

              // Manage & Add Time Slots button
              InkWell(
                onTap: () => context.go(Routes.availability),
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_circle_outline_rounded, size: 18, color: Color(0xFF0D9488)),
                      SizedBox(width: 8),
                      Text(
                        'Manage & Add Time Slots',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F766E),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
