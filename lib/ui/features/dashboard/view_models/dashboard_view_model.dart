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
  String _calendarTab = 'WEEK'; // 'WEEK' or 'MONTH'

  bool get loading => _loading;
  String? get errorMessage => _errorMessage;
  List<BookingItem> get todayBookings => _todayBookings;
  WalletSummary get walletSummary => _walletSummary;
  List<AvailabilityWindow> get availabilityWindows => _availabilityWindows;
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
      ]);

      _todayBookings = results[0] as List<BookingItem>;
      _walletSummary = results[1] as WalletSummary;
      _availabilityWindows = results[2] as List<AvailabilityWindow>;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
