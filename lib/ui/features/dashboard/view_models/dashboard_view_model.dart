import 'package:flutter/foundation.dart';

import '../../../../data/repositories/dashboard_repository.dart';
import '../../../../domain/models/models.dart';

class DashboardViewModel extends ChangeNotifier {
  DashboardViewModel(this._dashboardRepository);

  final DashboardRepository _dashboardRepository;

  bool _loading = false;
  String? _errorMessage;
  List<BookingItem> _todayBookings = const [];
  WalletSummary _walletSummary = const WalletSummary();
  List<AvailabilityWindow> _availabilityWindows = const [];
  List<WeeklyTemplateItem> _weeklyTemplates = const [];
  List<CustomSlotItem> _customSlots = const [];
  String _calendarTab = 'WEEK'; // 'WEEK' or 'MONTH'

  bool get loading => _loading;
  String? get errorMessage => _errorMessage;
  List<BookingItem> get todayBookings => _todayBookings;
  WalletSummary get walletSummary => _walletSummary;
  List<AvailabilityWindow> get availabilityWindows => _availabilityWindows;
  List<WeeklyTemplateItem> get weeklyTemplates => _weeklyTemplates;
  List<CustomSlotItem> get customSlots => _customSlots;
  String get calendarTab => _calendarTab;

  int get upcomingQueueCount =>
      _todayBookings.where((b) => b.status == BookingStatus.CONFIRMED || b.status == BookingStatus.ACTIVE).length;

  void setCalendarTab(String tab) {
    if (_calendarTab == tab) return;
    _calendarTab = tab;
    notifyListeners();
  }

  Future<void> loadDashboard() async {
    _loading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _dashboardRepository.getTodayBookings(),
        _dashboardRepository.getWalletSummary(),
        _dashboardRepository.getAvailabilityWindows(),
        _dashboardRepository.getAvailabilityConfig(),
      ]);

      _todayBookings = results[0] as List<BookingItem>;
      _walletSummary = results[1] as WalletSummary;
      _availabilityWindows = results[2] as List<AvailabilityWindow>;
      final config = results[3] as Map<String, dynamic>;
      _weeklyTemplates = (config['templates'] as List<WeeklyTemplateItem>?) ?? const [];
      _customSlots = (config['customSlots'] as List<CustomSlotItem>?) ?? const [];
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Resolves availability slots for [date], synthesizing slots from configured
  /// weekly templates and custom slots if computed windows are empty or unavailable.
  List<AvailabilityWindow> getSlotsForDate(DateTime date, {double defaultFee = 2500.0}) {
    // 1. Direct matching from backend computed availability windows
    final direct = _availabilityWindows.where((w) {
      if (w.startDateTime != null) {
        return w.startDateTime!.year == date.year &&
            w.startDateTime!.month == date.month &&
            w.startDateTime!.day == date.day;
      }
      return w.dayOfWeek == date.weekday;
    }).toList();

    if (direct.isNotEmpty) {
      return direct;
    }

    // 2. Synthesize from custom slots configured specifically for this date
    final List<AvailabilityWindow> synthesized = [];
    final matchingCustom = _customSlots.where((cs) {
      return cs.startTime.year == date.year &&
          cs.startTime.month == date.month &&
          cs.startTime.day == date.day;
    }).toList();

    for (final cs in matchingCustom) {
      final startH = cs.startTime.hour.toString().padLeft(2, '0');
      final startM = cs.startTime.minute.toString().padLeft(2, '0');
      final endH = cs.endTime.hour.toString().padLeft(2, '0');
      final endM = cs.endTime.minute.toString().padLeft(2, '0');
      synthesized.add(
        AvailabilityWindow(
          id: cs.id,
          startDateTime: cs.startTime,
          endDateTime: cs.endTime,
          dayOfWeek: date.weekday,
          dayName: _dayName(date.weekday),
          startTime: '$startH:$startM',
          endTime: '$endH:$endM',
          priceLkr: defaultFee,
          isBooked: false,
        ),
      );
    }

    // 3. Synthesize from active weekly recurring template for this weekday
    final template = _weeklyTemplates.where((t) => t.dayOfWeek == date.weekday && t.isActive).firstOrNull;
    if (template != null) {
      final partsStart = template.startTime.split(':');
      final partsEnd = template.endTime.split(':');
      final startHour = partsStart.isNotEmpty ? int.tryParse(partsStart[0]) ?? 9 : 9;
      final startMinute = partsStart.length > 1 ? int.tryParse(partsStart[1]) ?? 0 : 0;
      final endHour = partsEnd.isNotEmpty ? int.tryParse(partsEnd[0]) ?? 17 : 17;
      final endMinute = partsEnd.length > 1 ? int.tryParse(partsEnd[1]) ?? 0 : 0;

      var current = DateTime(date.year, date.month, date.day, startHour, startMinute);
      final finish = DateTime(date.year, date.month, date.day, endHour, endMinute);

      // Slice configured hours into 1-hour session intervals
      while (current.isBefore(finish)) {
        var next = current.add(const Duration(hours: 1));
        if (next.isAfter(finish)) next = finish;

        // Check if any existing booking occupies this interval
        final isBooked = _todayBookings.any((b) {
          return b.scheduledStartTime.isBefore(next) && b.scheduledEndTime.isAfter(current);
        });

        final sH = current.hour.toString().padLeft(2, '0');
        final sM = current.minute.toString().padLeft(2, '0');
        final eH = next.hour.toString().padLeft(2, '0');
        final eM = next.minute.toString().padLeft(2, '0');

        synthesized.add(
          AvailabilityWindow(
            id: 'tpl-${date.weekday}-${current.hour}',
            startDateTime: current,
            endDateTime: next,
            dayOfWeek: date.weekday,
            dayName: _dayName(date.weekday),
            startTime: '$sH:$sM',
            endTime: '$eH:$eM',
            priceLkr: defaultFee,
            isBooked: isBooked,
          ),
        );

        current = next;
      }
    }

    return synthesized;
  }

  static String _dayName(int weekday) {
    const days = ['', 'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return weekday >= 1 && weekday <= 7 ? days[weekday] : '';
  }
}
