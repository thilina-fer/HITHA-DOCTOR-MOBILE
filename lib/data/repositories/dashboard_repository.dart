import '../../config/app_config.dart';
import '../../domain/models/models.dart';
import '../services/api_client.dart';
import '../services/sample_data.dart';

class DashboardRepository {
  DashboardRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<BookingItem>> getTodayBookings() async {
    try {
      final res = await _apiClient.get('/doctors/bookings', query: {'status': 'ALL', 'page': '0', 'size': '10'});
      if (res is Map<String, dynamic> && res['content'] is List) {
        return (res['content'] as List)
            .map((e) => BookingItem.fromJson(e as Map<String, dynamic>))
            .toList();
      } else if (res is List) {
        return res.map((e) => BookingItem.fromJson(e as Map<String, dynamic>)).toList();
      }
      return SampleData.todayBookings;
    } catch (e) {
      if (AppConfig.demoMode) {
        return SampleData.todayBookings;
      }
      return SampleData.todayBookings;
    }
  }

  Future<WalletSummary> getWalletSummary() async {
    try {
      final res = await _apiClient.get('/doctor/wallet/summary');
      if (res is Map<String, dynamic>) {
        return WalletSummary.fromJson(res);
      }
      return SampleData.walletSummary;
    } catch (e) {
      return SampleData.walletSummary;
    }
  }

  Future<List<AvailabilityWindow>> getAvailabilityWindows() async {
    try {
      final res = await _apiClient.get('/doctors/availability');
      if (res is List) {
        return res.map((e) => AvailabilityWindow.fromJson(e as Map<String, dynamic>)).toList();
      }
      return SampleData.availabilityWindows;
    } catch (e) {
      return SampleData.availabilityWindows;
    }
  }
}
