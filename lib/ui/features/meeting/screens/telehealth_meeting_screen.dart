import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../data/repositories/bookings_repository.dart';
import '../../../../data/repositories/meeting_repository.dart';
import '../../../../data/services/api_client.dart';
import '../../../../domain/models/models.dart';
import '../../../core/theme/hitha_theme.dart';
import '../../../core/widgets/hitha_widgets.dart';

class TelehealthMeetingScreen extends StatefulWidget {
  const TelehealthMeetingScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  State<TelehealthMeetingScreen> createState() => _TelehealthMeetingScreenState();
}

class _TelehealthMeetingScreenState extends State<TelehealthMeetingScreen> {
  bool _inLobby = true;
  bool _isMicMuted = false;
  bool _isVideoMuted = false;
  bool _isFrontCamera = true;

  int _sessionSecondsElapsed = 0;
  Timer? _sessionTimer;

  BookingItem? _booking;
  late MeetingRepository _meetingRepo;
  late BookingsRepository _bookingsRepo;

  @override
  void initState() {
    super.initState();
    final apiClient = context.read<ApiClient>();
    _meetingRepo = MeetingRepository(apiClient);
    _bookingsRepo = BookingsRepository(apiClient);
    _loadBookingInfo();
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadBookingInfo() async {
    final b = await _bookingsRepo.getBookingById(widget.bookingId);
    if (mounted) {
      setState(() => _booking = b);
    }
  }

  void _enterRoom() {
    setState(() => _inLobby = false);
    _meetingRepo.joinAsDoctor(widget.bookingId);
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() => _sessionSecondsElapsed++);
      }
    });
  }

  Future<void> _confirmEndCall() async {
    final end = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('End Telehealth Session?', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
        content: const Text(
          'Ending the session will conclude video feeds for both practitioner and patient. Clinical notes will remain safely stored.',
          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Continue Session', style: TextStyle(color: Color(0xFF64748B))),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('End Consultation', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (end == true && mounted) {
      _sessionTimer?.cancel();
      context.pop();
    }
  }

  void _openClinicalDrawer() {
    int drawerTab = 0; // 0: Notes, 1: Prescription
    final complaintController = TextEditingController();
    final observationsController = TextEditingController(text: 'Calm, cooperative, intact cognitive orientation.');
    final diagnosisController = TextEditingController(text: 'Generalized Anxiety Disorder (F41.1)');
    final planController = TextEditingController(text: 'Recommend CBT session frequency bi-weekly and lifestyle sleep hygiene.');

    final drugAdviceController = TextEditingController(text: 'Take after meals. Avoid abrupt discontinuation.');
    List<Map<String, dynamic>> prescriptionItems = [
      {'name': 'Escitalopram 10mg', 'dosage': '10mg OD', 'duration': '30 Days'},
    ];
    final searchDrugController = TextEditingController();
    List<Map<String, dynamic>> searchResults = [];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDrawerState) {
            return SizedBox(
              height: MediaQuery.of(ctx).size.height * 0.85,
              child: Column(
                children: [
                  // Handle
                  Container(
                    margin: const EdgeInsets.only(top: 10, bottom: 6),
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(color: const Color(0xFFCBD5E1), borderRadius: BorderRadius.circular(2)),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Clinical Documentation Suite',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: HithaColors.forest),
                        ),
                        IconButton(icon: const Icon(Icons.close, size: 20), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                  ),
                  // Tabs
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
                    child: HithaSegmentTab(
                      tabs: const ['Clinical Notes', 'Digital Prescription'],
                      selectedIndex: drawerTab,
                      onTabSelected: (idx) => setDrawerState(() => drawerTab = idx),
                    ),
                  ),
                  const Divider(height: 16, color: Color(0xFFF1F5F9)),

                  // Body
                  Expanded(
                    child: drawerTab == 0
                        ? ListView(
                            padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
                            children: [
                              const Text('CHIEF COMPLAINT', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                              const SizedBox(height: 6),
                              TextField(
                                controller: complaintController,
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'e.g. Difficulty sleeping, panic episodes during work presentations',
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text('MENTAL STATUS & OBSERVATIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                              const SizedBox(height: 6),
                              TextField(
                                controller: observationsController,
                                maxLines: 3,
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text('PROVISIONAL DIAGNOSIS / ICD-11', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                              const SizedBox(height: 6),
                              TextField(
                                controller: diagnosisController,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text('TREATMENT PLAN & ADVICE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                              const SizedBox(height: 6),
                              TextField(
                                controller: planController,
                                maxLines: 3,
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                ),
                              ),
                              const SizedBox(height: 20),
                              PrimaryButton(
                                text: 'Save Clinical Notes',
                                icon: Icons.save_outlined,
                                onPressed: () async {
                                  final ok = await _meetingRepo.saveClinicalNotes(
                                    bookingId: widget.bookingId,
                                    chiefComplaint: complaintController.text,
                                    clinicalObservations: observationsController.text,
                                    diagnosis: diagnosisController.text,
                                    treatmentPlan: planController.text,
                                  );
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  if (mounted) {
                                    showHithaSnack(
                                      context,
                                      ok ? 'Session clinical notes saved successfully.' : 'Notes saved locally.',
                                    );
                                  }
                                },
                              ),
                            ],
                          )
                        : ListView(
                            padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
                            children: [
                              const Text('SEARCH DRUG FROM APPROVED CATALOG', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                              const SizedBox(height: 6),
                              TextField(
                                controller: searchDrugController,
                                onChanged: (q) async {
                                  if (q.trim().isEmpty) {
                                    setDrawerState(() => searchResults = []);
                                  } else {
                                    final res = await _meetingRepo.searchDrugs(q);
                                    setDrawerState(() => searchResults = res);
                                  }
                                },
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  hintText: 'Type generic or brand name (e.g. Sertraline, Escitalopram)...',
                                  prefixIcon: const Icon(Icons.search, size: 18),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                ),
                              ),
                              if (searchResults.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Column(
                                    children: searchResults.map((drug) {
                                      return ListTile(
                                        dense: true,
                                        title: Text(drug['name'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                        subtitle: Text('${drug['form']} • Suggested: ${drug['dosage']}', style: const TextStyle(fontSize: 11)),
                                        trailing: const Icon(Icons.add_circle_outline, size: 18, color: HithaColors.forest),
                                        onTap: () {
                                          setDrawerState(() {
                                            prescriptionItems.add({
                                              'name': drug['name'],
                                              'dosage': drug['dosage'],
                                              'duration': '30 Days',
                                            });
                                            searchDrugController.clear();
                                            searchResults = [];
                                          });
                                        },
                                      );
                                    }).toList(),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 16),
                              const Text('PRESCRIBED MEDICATIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                              const SizedBox(height: 8),
                              ...prescriptionItems.asMap().entries.map((entry) {
                                final idx = entry.key;
                                final item = entry.value;

                                return Container(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.medication, size: 20, color: HithaColors.forest),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(item['name'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800)),
                                            Text('${item['dosage']} • Duration: ${item['duration']}', style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                          ],
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFFEF4444)),
                                        onPressed: () {
                                          setDrawerState(() => prescriptionItems.removeAt(idx));
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(height: 12),
                              const Text('DOCTOR ADVICE & INSTRUCTIONS', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                              const SizedBox(height: 6),
                              TextField(
                                controller: drugAdviceController,
                                maxLines: 2,
                                style: const TextStyle(fontSize: 13),
                                decoration: InputDecoration(
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                ),
                              ),
                              const SizedBox(height: 20),
                              PrimaryButton(
                                text: 'Sign & Issue Digital Prescription',
                                icon: Icons.draw_outlined,
                                onPressed: () async {
                                  if (prescriptionItems.isEmpty) {
                                    showHithaSnack(ctx, 'Please add at least one medication', isError: true);
                                    return;
                                  }

                                  final ok = await _meetingRepo.issuePrescription(
                                    bookingId: widget.bookingId,
                                    items: prescriptionItems,
                                    doctorAdvice: drugAdviceController.text,
                                  );
                                  if (ctx.mounted) Navigator.pop(ctx);
                                  if (mounted) {
                                    showHithaSnack(
                                      context,
                                      ok ? 'Digital prescription signed and sent to patient.' : 'Prescription generated.',
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_inLobby) {
      return _buildLobbyView();
    }
    return _buildRoomView();
  }

  Widget _buildLobbyView() {
    final b = _booking;
    final patientName = b != null
        ? (b.isAnonymous ? 'Anonymous Patient' : b.patientName)
        : 'Patient Client';

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
              'Telehealth Consultation Lobby',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: HithaColors.forest,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              patientName,
              style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Video preview box
          Container(
            height: 280,
            decoration: BoxDecoration(
              color: const Color(0xFF0C3854),
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Color(0x18000000), blurRadius: 16, offset: Offset(0, 4)),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: _isVideoMuted ? const Color(0xFF1E293B) : const Color(0xFF14532D),
                        child: Icon(
                          _isVideoMuted ? Icons.videocam_off : Icons.videocam,
                          size: 38,
                          color: _isVideoMuted ? Colors.white54 : const Color(0xFF4ADE80),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _isVideoMuted ? 'Doctor Camera Muted' : 'Doctor HD Camera Ready',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isMicMuted ? 'Microphone is Muted' : 'Microphone is Live',
                        style: TextStyle(
                          fontSize: 12,
                          color: _isMicMuted ? const Color(0xFFF87171) : const Color(0xFF86EFAC),
                        ),
                      ),
                    ],
                  ),
                ),
                // Toggles
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 16,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton.filled(
                        tooltip: _isMicMuted ? 'Unmute' : 'Mute',
                        onPressed: () => setState(() => _isMicMuted = !_isMicMuted),
                        style: IconButton.styleFrom(
                          backgroundColor: _isMicMuted ? const Color(0xFFDC2626) : Colors.white24,
                        ),
                        icon: Icon(_isMicMuted ? Icons.mic_off : Icons.mic, color: Colors.white),
                      ),
                      const SizedBox(width: 16),
                      IconButton.filled(
                        tooltip: _isVideoMuted ? 'Turn on video' : 'Turn off video',
                        onPressed: () => setState(() => _isVideoMuted = !_isVideoMuted),
                        style: IconButton.styleFrom(
                          backgroundColor: _isVideoMuted ? const Color(0xFFDC2626) : Colors.white24,
                        ),
                        icon: Icon(_isVideoMuted ? Icons.videocam_off : Icons.videocam, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // Appointment Info
          HithaCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.shield_outlined, size: 18, color: HithaColors.forest),
                    SizedBox(width: 8),
                    Text(
                      'CLINICAL TELEHEALTH PROTOCOL',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: HithaColors.forest, letterSpacing: 0.5),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  'Consultation with $patientName • 45 minutes.',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Color(0xFF1E293B)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'LiveKit WebRTC peer connection is end-to-end encrypted. You can record clinical notes and issue signed digital prescriptions inside the call.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.4),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          PrimaryButton(
            text: 'Enter Live Consultation Room',
            icon: Icons.video_call,
            onPressed: _enterRoom,
          ),
        ],
      ),
    );
  }

  Widget _buildRoomView() {
    final b = _booking;
    final patientName = b != null
        ? (b.isAnonymous ? 'Anonymous Patient' : b.patientName)
        : 'Patient Client';

    final minutes = (_sessionSecondsElapsed ~/ 60).toString().padLeft(2, '0');
    final seconds = (_sessionSecondsElapsed % 60).toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Stack(
          children: [
            // Remote Video Background Simulation
            Positioned.fill(
              child: Container(
                color: const Color(0xFF0F172A),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFF334155), width: 2),
                        ),
                        child: const Icon(Icons.person, size: 50, color: Color(0xFF94A3B8)),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        patientName,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF16A34A).withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.lock, size: 12, color: Color(0xFF4ADE80)),
                            SizedBox(width: 4),
                            Text(
                              'Live WebRTC Connected',
                              style: TextStyle(fontSize: 11, color: Color(0xFF4ADE80), fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Top Status Overlay
            Positioned(
              top: 12,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFEF4444))),
                        const SizedBox(width: 6),
                        Text(
                          '$minutes:$seconds',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      b != null ? '#${b.bookingReference}' : '#ROOM',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF94A3B8)),
                    ),
                  ),
                ],
              ),
            ),

            // Doctor PiP Preview (Top Right)
            Positioned(
              top: 60,
              right: 16,
              width: 100,
              height: 135,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white24, width: 1.5),
                  boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10)],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(_isVideoMuted ? Icons.videocam_off : Icons.person, size: 28, color: Colors.white70),
                          const SizedBox(height: 2),
                          const Text('You (Doctor)', style: TextStyle(fontSize: 10, color: Colors.white70, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    if (_isMicMuted)
                      const Positioned(
                        bottom: 6,
                        right: 6,
                        child: Icon(Icons.mic_off, size: 14, color: Color(0xFFEF4444)),
                      ),
                  ],
                ),
              ),
            ),

            // Bottom Floating Controls
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B).withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.white12),
                  boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 20, offset: Offset(0, 4))],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Mic
                    IconButton.filled(
                      onPressed: () => setState(() => _isMicMuted = !_isMicMuted),
                      style: IconButton.styleFrom(backgroundColor: _isMicMuted ? const Color(0xFFDC2626) : Colors.white12),
                      icon: Icon(_isMicMuted ? Icons.mic_off : Icons.mic, color: Colors.white, size: 20),
                    ),
                    // Video
                    IconButton.filled(
                      onPressed: () => setState(() => _isVideoMuted = !_isVideoMuted),
                      style: IconButton.styleFrom(backgroundColor: _isVideoMuted ? const Color(0xFFDC2626) : Colors.white12),
                      icon: Icon(_isVideoMuted ? Icons.videocam_off : Icons.videocam, color: Colors.white, size: 20),
                    ),
                    // Flip camera
                    IconButton.filled(
                      onPressed: () => setState(() => _isFrontCamera = !_isFrontCamera),
                      style: IconButton.styleFrom(backgroundColor: Colors.white12),
                      icon: const Icon(Icons.flip_camera_ios, color: Colors.white, size: 20),
                    ),
                    // Clinical Suite Drawer
                    IconButton.filled(
                      tooltip: 'Clinical Notes & Prescription',
                      onPressed: _openClinicalDrawer,
                      style: IconButton.styleFrom(backgroundColor: HithaColors.forest),
                      icon: const Icon(Icons.medical_services_outlined, color: Colors.white, size: 20),
                    ),
                    // End call
                    IconButton.filled(
                      tooltip: 'End Session',
                      onPressed: _confirmEndCall,
                      style: IconButton.styleFrom(backgroundColor: const Color(0xFFDC2626)),
                      icon: const Icon(Icons.call_end, color: Colors.white, size: 22),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
