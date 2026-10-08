import '../../domain/models/models.dart';
import '../services/api_client.dart';
import '../services/sample_data.dart';

class DashboardRepository {
  DashboardRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<BookingItem>> getTodayBookings() async {
    try {
      final res = await _apiClient.get('/doctors/bookings', query: {'page': '0', 'size': '20'});
      List rawList = [];
      if (res is Map<String, dynamic> && res['content'] is List) {
        rawList = res['content'] as List;
      } else if (res is List) {
        rawList = res;
      }
      if (rawList.isNotEmpty) {
        return rawList
            .map((e) => BookingItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return SampleData.todayBookings;
    } catch (e) {
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
      final now = DateTime.now();
      final s = now.subtract(const Duration(days: 7));
      final e = now.add(const Duration(days: 21));
      final startIso = "${s.year}-${s.month.toString().padLeft(2, '0')}-${s.day.toString().padLeft(2, '0')}";
      final endIso = "${e.year}-${e.month.toString().padLeft(2, '0')}-${e.day.toString().padLeft(2, '0')}";

      final res = await _apiClient.get('/doctors/availability', query: {
        'startDate': startIso,
        'endDate': endIso,
      });

      if (res is List && res.isNotEmpty) {
        return res.map((e) => AvailabilityWindow.fromJson(e as Map<String, dynamic>)).toList();
      }
      return SampleData.availabilityWindows;
    } catch (e) {
      return SampleData.availabilityWindows;
    }
  }
}
