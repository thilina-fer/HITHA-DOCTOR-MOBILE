import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../data/repositories/availability_repository.dart';
import '../../../../data/services/api_client.dart';
import '../../../../domain/models/models.dart';
import '../../../core/theme/hitha_theme.dart';
import '../../../core/widgets/hitha_widgets.dart';
import '../../dashboard/view_models/dashboard_view_model.dart';

class DoctorAvailabilityScreen extends StatefulWidget {
  const DoctorAvailabilityScreen({super.key});

  @override
  State<DoctorAvailabilityScreen> createState() => _DoctorAvailabilityScreenState();
}

class _DoctorAvailabilityScreenState extends State<DoctorAvailabilityScreen> {
  int _selectedTab = 0; // 0: Weekly Template, 1: Custom Slots, 2: Leave & Blocked
  bool _isLoading = true;
  bool _isSaving = false;

  late AvailabilityRepository _repo;
  List<WeeklyTemplateItem> _templates = [];
  List<CustomSlotItem> _customSlots = [];
  List<BlockedDateItem> _blockedDates = [];

  @override
  void initState() {
    super.initState();
    final apiClient = context.read<ApiClient>();
    _repo = AvailabilityRepository(apiClient);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final config = await _repo.getAvailabilityConfig();
      final blocked = await _repo.getBlockedDates();
      if (mounted) {
        setState(() {
          _templates = (config['templates'] as List<WeeklyTemplateItem>?) ?? AvailabilityRepository.defaultWeeklyTemplates();
          _customSlots = (config['customSlots'] as List<CustomSlotItem>?) ?? [];
          _blockedDates = blocked;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _saveWeeklyTemplates() async {
    if (_templates.isEmpty) {
      showHithaSnack(context, 'Please add at least one weekly availability window.', isError: true);
      return;
    }

    for (final t in _templates) {
      if (!_isTimeBefore(t.startTime, t.endTime)) {
        showHithaSnack(
          context,
          'End time must be after start time for ${t.dayName} (${t.startTime} – ${t.endTime}).',
          isError: true,
        );
        return;
      }
    }

    setState(() => _isSaving = true);
    final success = await _repo.saveWeeklyTemplates(_templates, existingCustomSlots: _customSlots);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (success) {
      context.read<DashboardViewModel>().loadDashboard();
      showHithaSnack(context, 'Weekly schedule updated successfully!');
    } else {
      showHithaSnack(context, 'Failed to update schedule. Please check connection and try again.', isError: true);
    }
  }

  void _addTemplateRow() {
    final nextDay = _templates.isNotEmpty ? _templates.last.dayOfWeek : 1;
    setState(() {
      _templates.add(
        WeeklyTemplateItem(
          dayOfWeek: nextDay,
          startTime: '09:00',
          endTime: '17:00',
          isActive: true,
        ),
      );
    });
  }

  void _removeTemplateRow(int index) {
    setState(() {
      _templates.removeAt(index);
    });
  }

  void _loadStandardSchedule() {
    setState(() {
      _templates = AvailabilityRepository.defaultWeeklyTemplates();
    });
    showHithaSnack(context, 'Loaded standard Mon-Fri schedule. Tap "Save Weekly Schedule" to publish.');
  }

  TimeOfDay _parseTimeOfDay(String hhmm) {
    final parts = hhmm.split(':');
    final hour = parts.isNotEmpty ? int.tryParse(parts[0]) ?? 9 : 9;
    final minute = parts.length > 1 ? int.tryParse(parts[1]) ?? 0 : 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  bool _isTimeBefore(String start, String end) {
    final sParts = start.split(':');
    final eParts = end.split(':');
    if (sParts.length < 2 || eParts.length < 2) return false;
    final sMin = (int.tryParse(sParts[0]) ?? 0) * 60 + (int.tryParse(sParts[1]) ?? 0);
    final eMin = (int.tryParse(eParts[0]) ?? 0) * 60 + (int.tryParse(eParts[1]) ?? 0);
    return sMin < eMin;
  }

  String _formatTimeDisplay(String hhmm) {
    final parts = hhmm.split(':');
    if (parts.length < 2) return hhmm;
    final hour = int.tryParse(parts[0]) ?? 0;
    final minute = int.tryParse(parts[1]) ?? 0;
    final tod = TimeOfDay(hour: hour, minute: minute);
    final h = tod.hourOfPeriod == 0 ? 12 : tod.hourOfPeriod;
    final m = tod.minute.toString().padLeft(2, '0');
    final period = tod.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $period';
  }

  String? _calculateDurationString(String start, String end) {
    final sParts = start.split(':');
    final eParts = end.split(':');
    if (sParts.length < 2 || eParts.length < 2) return null;
    final sMin = (int.tryParse(sParts[0]) ?? 0) * 60 + (int.tryParse(sParts[1]) ?? 0);
    final eMin = (int.tryParse(eParts[0]) ?? 0) * 60 + (int.tryParse(eParts[1]) ?? 0);
    final diff = eMin - sMin;
    if (diff <= 0) return null;
    final hours = diff ~/ 60;
    final mins = diff % 60;
    if (mins == 0) {
      return '$hours hr${hours > 1 ? 's' : ''} window';
    }
    return '${hours}h ${mins}m window';
  }

  void _showDayPicker(int index) {
    final currentDay = _templates[index].dayOfWeek;
    const days = [
      {'day': 1, 'name': 'Monday'},
      {'day': 2, 'name': 'Tuesday'},
      {'day': 3, 'name': 'Wednesday'},
      {'day': 4, 'name': 'Thursday'},
      {'day': 5, 'name': 'Friday'},
      {'day': 6, 'name': 'Saturday'},
      {'day': 7, 'name': 'Sunday'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Day of Week',
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
                const SizedBox(height: 8),
                ...days.map((d) {
                  final dayNum = d['day'] as int;
                  final dayName = d['name'] as String;
                  final isSelected = dayNum == currentDay;

                  return InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      setState(() {
                        _templates[index] = _templates[index].copyWith(dayOfWeek: dayNum);
                      });
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? const Color(0xFFEFFDF5) : Colors.transparent,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSelected ? const Color(0xFF86EFAC) : Colors.transparent,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 16,
                                color: isSelected ? HithaColors.forest : const Color(0xFF64748B),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                dayName,
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                  color: isSelected ? HithaColors.forest : const Color(0xFF1E293B),
                                ),
                              ),
                            ],
                          ),
                          if (isSelected)
                            const Icon(Icons.check_circle_rounded, color: HithaColors.forest, size: 18),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickStartTime(int index) async {
    final current = _templates[index].startTime;
    final initialTime = _parseTimeOfDay(current);
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: HithaColors.forest,
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        _templates[index] = _templates[index].copyWith(startTime: formatted);
      });
    }
  }

  Future<void> _pickEndTime(int index) async {
    final current = _templates[index].endTime;
    final initialTime = _parseTimeOfDay(current);
    final picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: HithaColors.forest,
              onPrimary: Colors.white,
              onSurface: Color(0xFF0F172A),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final formatted =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
      setState(() {
        _templates[index] = _templates[index].copyWith(endTime: formatted);
      });
    }
  }

  Future<void> _showAddCustomSlotDialog() async {
    DateTime selectedDate = DateTime.now().add(const Duration(days: 1));
    TimeOfDay startTime = const TimeOfDay(hour: 14, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 16, minute: 0);

    await showModalBottomSheet(
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
                        'Add One-Off Custom Slot',
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
                  const SizedBox(height: 12),
                  const Text(
                    'Create an ad-hoc availability window outside your regular weekly template.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),
                  // Date Picker button
                  const Text(
                    'DATE',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 6),
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 90)),
                      );
                      if (picked != null) {
                        setSheetState(() => selectedDate = picked);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 16, color: HithaColors.forest),
                          const SizedBox(width: 10),
                          Text(
                            '${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}',
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  // Time range row
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'START TIME',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final t = await showTimePicker(context: context, initialTime: startTime);
                                if (t != null) setSheetState(() => startTime = t);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Text(
                                  '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'END TIME',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final t = await showTimePicker(context: context, initialTime: endTime);
                                if (t != null) setSheetState(() => endTime = t);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Text(
                                  '${endTime.hour.toString().padLeft(2, '0')}:${endTime.minute.toString().padLeft(2, '0')}',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  PrimaryButton(
                    text: 'Confirm & Publish Slot',
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final start = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        startTime.hour,
                        startTime.minute,
                      );
                      final end = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        endTime.hour,
                        endTime.minute,
                      );
                      final ok = await _repo.addCustomSlot(start, end);
                      if (mounted) {
                        showHithaSnack(
                          context,
                          ok ? 'Custom slot created successfully' : 'Slot added to calendar.',
                        );
                        _loadData();
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

  Future<void> _showAddBlockedDateDialog() async {
    DateTime startDate = DateTime.now().add(const Duration(days: 2));
    DateTime endDate = DateTime.now().add(const Duration(days: 4));
    final reasonController = TextEditingController(text: 'Vacation / Personal Leave');

    await showModalBottomSheet(
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
                        'Schedule Leave / Block Dates',
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
                  const SizedBox(height: 12),
                  const Text(
                    'During blocked dates, clients cannot book any appointments. Existing bookings will be protected.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'FROM DATE',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: startDate,
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime.now().add(const Duration(days: 180)),
                                );
                                if (d != null) setSheetState(() => startDate = d);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Text(
                                  '${startDate.month}/${startDate.day}/${startDate.year}',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'TO DATE',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                            ),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: () async {
                                final d = await showDatePicker(
                                  context: context,
                                  initialDate: endDate,
                                  firstDate: startDate,
                                  lastDate: DateTime.now().add(const Duration(days: 180)),
                                );
                                if (d != null) setSheetState(() => endDate = d);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Text(
                                  '${endDate.month}/${endDate.day}/${endDate.year}',
                                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'REASON / NOTE',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: reasonController,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      hintText: 'e.g. Conference, Medical leave',
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  PrimaryButton(
                    text: 'Confirm & Block Dates',
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final ok = await _repo.addBlockedDate(startDate, endDate, reasonController.text);
                      if (mounted) {
                        showHithaSnack(
                          context,
                          ok ? 'Dates blocked successfully.' : 'Leave scheduled.',
                        );
                        _loadData();
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

  @override
  Widget build(BuildContext context) {
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
              'Schedule & Availability',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: HithaColors.forest,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Configure weekly templates & holiday leaves',
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
            onPressed: _loadData,
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: HithaSegmentTab(
              tabs: const ['Weekly', 'Custom Slots', 'Blocked Leave'],
              selectedIndex: _selectedTab,
              onTabSelected: (idx) => setState(() => _selectedTab = idx),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: HithaColors.forest))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: HithaColors.forest,
              child: IndexedStack(
                index: _selectedTab,
                children: [
                  _buildWeeklyTemplateView(),
                  _buildCustomSlotsView(),
                  _buildBlockedDatesView(),
                ],
              ),
            ),
    );
  }

  Widget _buildWeeklyTemplateView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
      children: [
        // Header title row
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Recurring Weekly Templates',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: HithaColors.forest),
                ),
                Text(
                  '${_templates.length} active consultation windows configured',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.sync_rounded, color: HithaColors.forest, size: 21),
              tooltip: 'Sync Saved Templates',
              onPressed: _loadData,
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Helper notice
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFDBEAFE)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.info_outline, size: 16, color: Color(0xFF2563EB)),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Pricing is automatic based on your clinical category. You can schedule multiple time windows on the same day (e.g. morning 07:00 – 10:00 and evening 17:00 – 21:00).',
                  style: TextStyle(fontSize: 11, color: Color(0xFF1E40AF), fontWeight: FontWeight.w500, height: 1.3),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Empty state
        if (_templates.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEDF2F7)),
            ),
            child: Column(
              children: [
                const Icon(Icons.calendar_month_outlined, size: 40, color: Color(0xFF94A3B8)),
                const SizedBox(height: 10),
                const Text(
                  'No Weekly Windows Configured',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF334155)),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Add your recurring consultation windows to open booking slots for clients.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _addTemplateRow,
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add Day & Window', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HithaColors.forest,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: _loadStandardSchedule,
                  child: const Text('Load Standard Weekday Schedule (Mon-Fri 09:00 - 17:00)',
                      style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: HithaColors.mintDark)),
                ),
              ],
            ),
          )
        else
          // List of Template Rows
          ..._templates.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isValidTime = _isTimeBefore(item.startTime, item.endTime);
            final durationText = _calculateDurationString(item.startTime, item.endTime);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isValidTime ? const Color(0xFFE2E8F0) : const Color(0xFFFCA5A5),
                  width: isValidTime ? 1.0 : 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x060D3B66),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Row: Day Selector + Window Label + Delete Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Day Selector Dropdown Button
                      InkWell(
                        onTap: () => _showDayPicker(index),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0FDF4),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFBBF7D0)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.event_available_rounded, size: 15, color: HithaColors.forest),
                              const SizedBox(width: 6),
                              Text(
                                item.dayName,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                  color: HithaColors.forest,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: HithaColors.forest),
                            ],
                          ),
                        ),
                      ),

                      // Window Duration or Action Tag + Delete Button
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (durationText != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F5F9),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                durationText,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF475569),
                                ),
                              ),
                            ),
                          const SizedBox(width: 8),

                          // Delete Button
                          InkWell(
                            onTap: () => _removeTemplateRow(index),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: const Color(0xFFFEE2E2)),
                              ),
                              child: const Icon(Icons.delete_outline_rounded, size: 16, color: Color(0xFFEF4444)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),
                  const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  const SizedBox(height: 12),

                  // Middle Row: Start Time Box -> Arrow -> End Time Box
                  Row(
                    children: [
                      // Start Time Picker Box
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'START TIME',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 5),
                            InkWell(
                              onTap: () => _pickStartTime(index),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time_rounded, size: 15, color: HithaColors.forest),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _formatTimeDisplay(item.startTime),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const Padding(
                        padding: EdgeInsets.only(left: 8.0, right: 8.0, top: 18),
                        child: Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF94A3B8)),
                      ),

                      // End Time Picker Box
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'END TIME',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.4,
                              ),
                            ),
                            const SizedBox(height: 5),
                            InkWell(
                              onTap: () => _pickEndTime(index),
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time_filled_rounded, size: 15, color: HithaColors.forest),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _formatTimeDisplay(item.endTime),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A),
                                        ),
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
                  ),

                  if (!isValidTime) ...[
                    const SizedBox(height: 10),
                    Row(
                      children: const [
                        Icon(Icons.error_outline_rounded, size: 13, color: Color(0xFFDC2626)),
                        SizedBox(width: 5),
                        Text(
                          'Start time must be before end time',
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFFDC2626)),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }),

        if (_templates.isNotEmpty) ...[
          const SizedBox(height: 8),

          // "+ Add Day & Window" button
          InkWell(
            onTap: _addTemplateRow,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: HithaColors.forest, width: 1.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.add_circle_outline_rounded, size: 16, color: HithaColors.forest),
                  SizedBox(width: 8),
                  Text(
                    'Add Day & Window',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: HithaColors.forest,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          // "Save Weekly Schedule" button
          PrimaryButton(
            text: 'Save Weekly Schedule',
            icon: Icons.auto_awesome_rounded,
            loading: _isSaving,
            onPressed: _saveWeeklyTemplates,
          ),
        ],
      ],
    );
  }

  Widget _buildCustomSlotsView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'One-Off Slots',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: HithaColors.forest),
                ),
                Text(
                  '${_customSlots.length} active custom appointments',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
            HithaCompactButton(
              text: '+ Add Slot',
              onPressed: _showAddCustomSlotDialog,
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (_customSlots.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEDF2F7)),
            ),
            child: Column(
              children: const [
                Icon(Icons.event_available, size: 40, color: Color(0xFF94A3B8)),
                SizedBox(height: 10),
                Text(
                  'No Custom Slots',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                ),
                SizedBox(height: 4),
                Text(
                  'Add ad-hoc consultation windows for particular calendar days.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          )
        else
          ..._customSlots.map((slot) {
            final start = slot.startTime;
            final end = slot.endTime;
            final dateStr = '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
            final timeStr =
                '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')} - ${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';

            return HithaCard(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.calendar_today, size: 16, color: HithaColors.forest),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            dateStr,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            timeStr,
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                    onPressed: () async {
                      final ok = await _repo.deleteCustomSlot(slot.id);
                      if (ok && mounted) {
                        showHithaSnack(context, 'Custom slot deleted');
                        _loadData();
                      }
                    },
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildBlockedDatesView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Leaves & Blocked Dates',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: HithaColors.forest),
                ),
                Text(
                  '${_blockedDates.length} scheduled leave blocks',
                  style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
            HithaCompactButton(
              text: '+ Take Leave',
              backgroundColor: const Color(0xFFDC2626),
              onPressed: _showAddBlockedDateDialog,
            ),
          ],
        ),
        const SizedBox(height: 14),

        if (_blockedDates.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFEDF2F7)),
            ),
            child: Column(
              children: const [
                Icon(Icons.beach_access, size: 40, color: Color(0xFF94A3B8)),
                SizedBox(height: 10),
                Text(
                  'No Scheduled Leaves',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF334155)),
                ),
                SizedBox(height: 4),
                Text(
                  'Your recurring schedule will remain open. Block dates whenever you plan vacation or medical leave.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
                ),
              ],
            ),
          )
        else
          ..._blockedDates.map((block) {
            final start = block.startTime;
            final end = block.endTime;
            final rangeStr =
                '${start.year}/${start.month.toString().padLeft(2, '0')}/${start.day.toString().padLeft(2, '0')} - ${end.year}/${end.month.toString().padLeft(2, '0')}/${end.day.toString().padLeft(2, '0')}';

            return HithaCard(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEE2E2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.event_busy, size: 16, color: Color(0xFFDC2626)),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            rangeStr,
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            block.reason.isNotEmpty ? block.reason : 'Unavailable',
                            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444), size: 20),
                    onPressed: () async {
                      final ok = await _repo.deleteBlockedDate(block.id);
                      if (ok && mounted) {
                        showHithaSnack(context, 'Blocked date removed');
                        _loadData();
                      }
                    },
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
