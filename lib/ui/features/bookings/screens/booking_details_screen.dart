import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../data/repositories/bookings_repository.dart';
import '../../../../data/services/api_client.dart';
import '../../../../domain/models/models.dart';
import '../../../core/theme/hitha_theme.dart';
import '../../../core/widgets/hitha_widgets.dart';

class BookingDetailsScreen extends StatefulWidget {
  const BookingDetailsScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  State<BookingDetailsScreen> createState() => _BookingDetailsScreenState();
}

class _BookingDetailsScreenState extends State<BookingDetailsScreen> {
  bool _isLoading = true;
  BookingItem? _booking;
  late BookingsRepository _repo;

  @override
  void initState() {
    super.initState();
    final apiClient = context.read<ApiClient>();
    _repo = BookingsRepository(apiClient);
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    setState(() => _isLoading = true);
    final item = await _repo.getBookingById(widget.bookingId);
    if (mounted) {
      setState(() {
        _booking = item;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final booking = _booking;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: HithaColors.forest),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Consultation Dossier',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: HithaColors.forest,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              booking != null ? '#${booking.bookingReference}' : '#${widget.bookingId}',
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          if (booking != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: HithaStatusBadge(
                  status: booking.status.value,
                  label: booking.status.label,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: HithaColors.forest))
          : booking == null
              ? const Center(child: Text('Consultation not found.'))
              : ListView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                  children: [
                    // Patient Header Card
                    _buildPatientProfileCard(booking),
                    const SizedBox(height: 14),

                    // Appointment Schedule Card
                    _buildAppointmentScheduleCard(booking),
                    const SizedBox(height: 14),

                    // Telehealth Consultation Room Card
                    _buildTelehealthRoomCard(booking),
                    const SizedBox(height: 14),

                    // Clinical Intake & Session Notes
                    _buildClinicalNotesCard(booking),
                    const SizedBox(height: 14),

                    // Financial Escrow & Payout Summary
                    _buildFinancialSummaryCard(booking),
                  ],
                ),
      bottomNavigationBar: booking != null &&
              (booking.status == BookingStatus.CONFIRMED || booking.status == BookingStatus.ACTIVE)
          ? Container(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Color(0xFFEDF2F7))),
              ),
              child: PrimaryButton(
                text: 'Launch Telehealth Room',
                icon: Icons.videocam,
                onPressed: () => context.push('/meeting/${booking.id}'),
              ),
            )
          : null,
    );
  }

  Widget _buildPatientProfileCard(BookingItem booking) {
    return HithaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: booking.isAnonymous ? const Color(0xFFF1F5F9) : const Color(0xFFE0F2FE),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Icon(
                  booking.isAnonymous ? Icons.shield_outlined : Icons.person,
                  size: 26,
                  color: booking.isAnonymous ? const Color(0xFF64748B) : HithaColors.forest,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.patientName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      booking.isAnonymous
                          ? 'Anonymous Client • End-to-end Encrypted'
                          : (booking.patientPhone ?? 'Contact registered via Hitha Portal'),
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (booking.isAnonymous) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.lock_outline, size: 14, color: Color(0xFF64748B)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Client identity protected under Hitha Privacy Guidelines. Session records are kept confidential.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAppointmentScheduleCard(BookingItem booking) {
    final start = booking.scheduledStartTime.toLocal();
    final end = booking.scheduledEndTime.toLocal();
    final dateStr = DateFormat('EEEE, MMMM d, yyyy').format(start);
    final timeStr = '${DateFormat('hh:mm a').format(start)} - ${DateFormat('hh:mm a').format(end)}';

    return HithaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'APPOINTMENT LOGISTICS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.calendar_today_outlined, size: 16, color: HithaColors.forest),
              const SizedBox(width: 10),
              Text(
                dateStr,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 16, color: HithaColors.forest),
              const SizedBox(width: 10),
              Text(
                '$timeStr (45 mins)',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: const [
              Icon(Icons.videocam_outlined, size: 16, color: HithaColors.forest),
              SizedBox(width: 10),
              Text(
                'Live WebRTC Video Consultation',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTelehealthRoomCard(BookingItem booking) {
    return HithaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TELEHEALTH ROOM LINK',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: 'https://hitha.lk/meeting/${booking.id}'));
                  showHithaSnack(context, 'Meeting link copied to clipboard');
                },
                child: Row(
                  children: const [
                    Icon(Icons.copy, size: 13, color: HithaColors.forest),
                    SizedBox(width: 4),
                    Text(
                      'Copy',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: HithaColors.forest),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Row(
              children: [
                const Icon(Icons.link, size: 16, color: Color(0xFF64748B)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'https://hitha.lk/meeting/${booking.id}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF334155), fontFamily: 'monospace'),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClinicalNotesCard(BookingItem booking) {
    return HithaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CLINICAL INTAKE & NOTES',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              InkWell(
                onTap: () => context.push('/meeting/${booking.id}'),
                child: const Text(
                  'Write Note',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: HithaColors.forest),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            booking.sessionNotes != null && booking.sessionNotes!.isNotEmpty
                ? booking.sessionNotes!
                : 'No initial clinical notes recorded yet. Notes can be entered during or following the live consultation.',
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF475569),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummaryCard(BookingItem booking) {
    final netPayout = booking.feeLkr * 0.85; // 85% practitioner share

    return HithaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FINANCIAL ESCROW STATUS',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Patient Paid Fee', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              Text(formatLkr(booking.feeLkr), style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Platform Commission (15%)', style: TextStyle(fontSize: 13, color: Color(0xFF64748B))),
              Text('- ${formatLkr(booking.feeLkr * 0.15)}', style: const TextStyle(fontSize: 13, color: Color(0xFFDC2626))),
            ],
          ),
          const Divider(height: 18, color: Color(0xFFE2E8F0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Doctor Net Payout',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
              ),
              Text(
                formatLkr(netPayout),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: HithaColors.forest),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: const [
                Icon(Icons.shield, size: 13, color: Color(0xFFB45309)),
                SizedBox(width: 6),
                Expanded(
                  child: Text(
                    'Held safely in Escrow. Released to available wallet upon completion.',
                    style: TextStyle(fontSize: 11, color: Color(0xFF92400E), fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
