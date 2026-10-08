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
  final _timeFmt = DateFormat('hh:mm a');

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
        final current = authVm.doctor?.status ?? DoctorStatus.OFFLINE;
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
                  'Your online availability controls patient queue routing and instant emergency matching.',
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
                      style: HithaText.bodyMedium.copyWith(
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? HithaColors.forest : HithaColors.inkSoft,
                      ),
                    ),
                    trailing: isSelected ? const Icon(Icons.check, color: HithaColors.forest, size: 20) : null,
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

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final dashVm = context.watch<DashboardViewModel>();
    final doctor = authVm.doctor;

    return Scaffold(
      backgroundColor: HithaColors.cream,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: HithaSpacing.page),
              child: Row(
                children: [
                  const HithaLotus(size: 26, color: HithaColors.forest),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'HITHA.LK',
                        style: HithaText.caption.copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: HithaColors.forest,
                        ),
                      ),
                      Text(
                        'PEACE OF MIND',
                        style: HithaText.caption.copyWith(fontSize: 9, color: HithaColors.inkFaint),
                      ),
                    ],
                  ),
                  const Spacer(),
                  if (doctor != null)
                    HithaAvatar(
                      url: doctor.profilePictureUrl,
                      size: 36,
                      radius: 12,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await Future.wait([
            authVm.init(),
            dashVm.loadDashboard(),
          ]);
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(
            left: HithaSpacing.page,
            right: HithaSpacing.page,
            top: 16,
            bottom: HithaSpacing.pageBottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Practitioner Hero Card
              _buildHeroCard(context, authVm, doctor),
              const SizedBox(height: 16),

              // 2. SLMC Review Banner (if unverified or pending)
              if (doctor != null && doctor.verificationStatus != VerificationStatus.ACTIVE)
                _buildVerificationBanner(doctor),

              // 3. KPI Metrics Row
              _buildKpiMetrics(dashVm),
              const SizedBox(height: 20),

              // 4. Quick Action Hub (2x3 Grid)
              _buildQuickActionHub(context),
              const SizedBox(height: 24),

              // 5. Today's Consultations Queue
              _buildTodayScheduleSection(context, dashVm),
              const SizedBox(height: 24),

              // 6. Live Dynamic Availability Preview
              _buildAvailabilityPreviewSection(context, dashVm),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, AuthViewModel authVm, DoctorProfile? doctor) {
    final status = doctor?.status ?? DoctorStatus.ONLINE;
    Color statusColor;
    switch (status) {
      case DoctorStatus.ONLINE:
        statusColor = HithaColors.moss;
        break;
      case DoctorStatus.BUSY:
        statusColor = HithaColors.saffron;
        break;
      case DoctorStatus.AWAY:
      case DoctorStatus.PAUSED:
        statusColor = HithaColors.slate400;
        break;
      case DoctorStatus.OFFLINE:
        statusColor = HithaColors.clay;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        color: HithaColors.forest,
        borderRadius: BorderRadius.circular(HithaRadius.cardLg),
        boxShadow: HithaShadows.elevated,
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor != null ? 'Ayubowan, ${doctor.fullName}' : 'Ayubowan, Doctor',
                      style: HithaText.h2.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Flexible(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(HithaRadius.badge),
                            ),
                            child: Text(
                              doctor?.category.label.toUpperCase() ?? 'PRACTITIONER',
                              style: HithaText.caption.copyWith(color: HithaColors.sprout),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        if (doctor != null && doctor.slmcLicenseNumber.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Text(
                            doctor.slmcLicenseNumber,
                            style: HithaText.mono.copyWith(
                              fontSize: 11,
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Sign Out',
                onPressed: () async {
                  await authVm.logout();
                  if (context.mounted) context.go(Routes.login);
                },
                icon: const Icon(Icons.logout, color: Colors.white70, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Welcome back to your clinical sanctuary dashboard.',
            style: HithaText.bodySmall.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 18),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 14),

          // Status & Profile row
          Row(
            children: [
              // Online status pill
              InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _showStatusPicker(context, authVm),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        status.label,
                        style: HithaText.caption.copyWith(color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.white70),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () => context.push(Routes.profile),
                icon: const Icon(Icons.edit_outlined, size: 16, color: HithaColors.sprout),
                label: Text(
                  'Profile Settings',
                  style: HithaText.caption.copyWith(color: HithaColors.sprout, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationBanner(DoctorProfile doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: HithaColors.saffronLight,
        borderRadius: BorderRadius.circular(HithaRadius.sub),
        border: Border.all(color: HithaColors.saffron),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.hourglass_top_rounded, color: HithaColors.saffron, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SLMC Credentials Under Review',
                  style: HithaText.bodySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: HithaColors.forestDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your SLMC registration is pending verification by the administrator. You can configure your calendar, but patient bookings will unlock after approval.',
                  style: HithaText.caption.copyWith(color: HithaColors.inkSoft),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiMetrics(DashboardViewModel dashVm) {
    final w = dashVm.walletSummary;

    return Row(
      children: [
        Expanded(
          child: HithaCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ACTIVE QUEUE', style: HithaText.caption),
                const SizedBox(height: 6),
                Text('${dashVm.upcomingQueueCount}', style: HithaText.hero.copyWith(fontSize: 24)),
                const SizedBox(height: 2),
                Text('Today\'s slots', style: HithaText.caption.copyWith(fontSize: 10)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: HithaCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('AVAILABLE', style: HithaText.caption),
                const SizedBox(height: 6),
                Text(
                  formatLkr(w.balanceAvailable).replaceFirst('LKR ', ''),
                  style: HithaText.mono.copyWith(fontSize: 16, color: HithaColors.moss),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text('LKR Cleared', style: HithaText.caption.copyWith(fontSize: 10)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: HithaCard(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ESCROW', style: HithaText.caption),
                const SizedBox(height: 6),
                Text(
                  formatLkr(w.balanceEscrow).replaceFirst('LKR ', ''),
                  style: HithaText.mono.copyWith(fontSize: 16, color: HithaColors.saffron),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text('LKR Held', style: HithaText.caption.copyWith(fontSize: 10)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActionHub(BuildContext context) {
    final items = [
      _QuickActionItem(
        title: 'Income Telemetry',
        subtitle: 'REVENUE & CUTS',
        icon: Icons.trending_up_rounded,
        route: Routes.finance,
      ),
      _QuickActionItem(
        title: 'Wallet & Payouts',
        subtitle: 'BANK TRANSFERS',
        icon: Icons.account_balance_wallet_outlined,
        route: Routes.wallet,
      ),
      _QuickActionItem(
        title: 'Wellness Blog',
        subtitle: 'MANAGE ARTICLES',
        icon: Icons.article_outlined,
        route: Routes.blogs,
      ),
      _QuickActionItem(
        title: 'Availability Calendar',
        subtitle: 'MANAGE SCHEDULE',
        icon: Icons.calendar_today_outlined,
        route: Routes.availability,
      ),
      _QuickActionItem(
        title: 'Pricing & Overrides',
        subtitle: 'MANAGE PRICING',
        icon: Icons.sell_outlined,
        route: Routes.pricing,
      ),
      _QuickActionItem(
        title: 'Consultations Queue',
        subtitle: 'VIEW SESSIONS',
        icon: Icons.video_call_outlined,
        route: Routes.bookings,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CaptionLabel('PRACTITIONER CORE WORKSPACE'),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: items.length,
          itemBuilder: (ctx, i) {
            final it = items[i];
            return HithaCard(
              padding: const EdgeInsets.all(14),
              onTap: () => context.push(it.route),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(it.icon, size: 24, color: HithaColors.forest),
                      const Icon(Icons.arrow_forward_ios, size: 12, color: HithaColors.inkFaint),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        it.title,
                        style: HithaText.bodySmall.copyWith(fontWeight: FontWeight.w700, color: HithaColors.forest),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        it.subtitle,
                        style: HithaText.caption.copyWith(fontSize: 9, color: HithaColors.inkFaint),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTodayScheduleSection(BuildContext context, DashboardViewModel dashVm) {
    final bookings = dashVm.todayBookings;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const CaptionLabel('TODAY\'S APPOINTMENT QUEUE'),
            TextButton(
              onPressed: () => context.push(Routes.bookings),
              child: Text(
                'View All (${bookings.length}) →',
                style: HithaText.bodySmall.copyWith(color: HithaColors.mintDark, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (bookings.isEmpty)
          const EmptyStateCard(
            title: 'No Sessions Booked for Today',
            message: 'Your upcoming patient consultations will appear here once booked.',
          )
        else
          ...bookings.map((booking) => _buildBookingCard(context, booking)),
      ],
    );
  }

  Widget _buildBookingCard(BuildContext context, BookingItem booking) {
    Color statusBg;
    Color statusFg;
    switch (booking.status) {
      case BookingStatus.ACTIVE:
        statusBg = HithaColors.sprout;
        statusFg = HithaColors.moss;
        break;
      case BookingStatus.CONFIRMED:
        statusBg = HithaColors.creamDark;
        statusFg = HithaColors.forest;
        break;
      case BookingStatus.COMPLETED:
        statusBg = HithaColors.hairline;
        statusFg = HithaColors.inkSoft;
        break;
      default:
        statusBg = HithaColors.clayTint;
        statusFg = HithaColors.clay;
    }

    final isStartable = booking.status == BookingStatus.ACTIVE || booking.status == BookingStatus.CONFIRMED;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: HithaCard(
        padding: const EdgeInsets.all(16),
        onTap: () => context.push(Routes.bookingDetailsPath(booking.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(booking.bookingReference, style: HithaText.mono.copyWith(fontSize: 11)),
                const Spacer(),
                HithaPill(
                  text: booking.status.label,
                  background: statusBg,
                  foreground: statusFg,
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                HithaAvatar(url: booking.patientAvatarUrl, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.isAnonymous ? 'Anonymous Client' : booking.patientName,
                        style: HithaText.bodyMedium.copyWith(fontWeight: FontWeight.w700, color: HithaColors.forest),
                      ),
                      Text(
                        '${_timeFmt.format(booking.scheduledStartTime)} - ${_timeFmt.format(booking.scheduledEndTime)}',
                        style: HithaText.bodySmall,
                      ),
                    ],
                  ),
                ),
                Text(formatLkr(booking.feeLkr), style: HithaText.mono.copyWith(fontSize: 12)),
              ],
            ),
            if (isStartable) ...[
              const SizedBox(height: 12),
              PrimaryButton(
                text: 'Start Patient Session',
                icon: Icons.video_call,
                color: HithaColors.mintDark,
                onPressed: () => context.push(Routes.meetingPath(booking.id)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvailabilityPreviewSection(BuildContext context, DashboardViewModel dashVm) {
    final slots = dashVm.availabilityWindows;

    return HithaCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.calendar_month, color: HithaColors.forest, size: 20),
                  const SizedBox(width: 8),
                  Text('Live Availability Preview', style: HithaText.h3),
                ],
              ),
              TextButton(
                onPressed: () => context.push(Routes.availability),
                child: Text(
                  'Configure →',
                  style: HithaText.bodySmall.copyWith(color: HithaColors.mintDark, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Computed live bookable slots visible to patients after factoring recurring templates and blocked days.',
            style: HithaText.bodySmall,
          ),
          const SizedBox(height: 14),

          // Slots horizontal list
          if (slots.isEmpty)
            Text('No active availability slots configured yet.', style: HithaText.bodySmall)
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: slots.map((w) {
                  return Container(
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: HithaColors.creamLight,
                      borderRadius: BorderRadius.circular(HithaRadius.sub),
                      border: Border.all(color: HithaColors.hairline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(w.dayName, style: HithaText.bodySmall.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 4),
                        Text('${w.startTime} - ${w.endTime}', style: HithaText.mono.copyWith(fontSize: 12)),
                        const SizedBox(height: 2),
                        Text(formatLkr(w.priceLkr), style: HithaText.caption.copyWith(color: HithaColors.inkFaint)),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

class _QuickActionItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final String route;

  _QuickActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.route,
  });
}
