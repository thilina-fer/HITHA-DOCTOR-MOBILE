import '../../domain/models/models.dart';
import '../services/api_client.dart';

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
      return rawList
          .map((e) => BookingItem.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<WalletSummary> getWalletSummary() async {
    try {
      final res = await _apiClient.get('/doctor/wallet/summary');
      if (res is Map<String, dynamic>) {
        return WalletSummary.fromJson(res);
      }
      return const WalletSummary();
    } catch (_) {
      return const WalletSummary();
    }
  }

  Future<List<AvailabilityWindow>> getAvailabilityWindows() async {
    try {
      final now = DateTime.now();
      final s = now.subtract(const Duration(days: 3));
      final e = now.add(const Duration(days: 35));
      final startIso = "${s.year}-${s.month.toString().padLeft(2, '0')}-${s.day.toString().padLeft(2, '0')}";
      final endIso = "${e.year}-${e.month.toString().padLeft(2, '0')}-${e.day.toString().padLeft(2, '0')}";

      final res = await _apiClient.get('/doctors/availability', query: {
        'startDate': startIso,
        'endDate': endIso,
      });

      if (res is List) {
        return res.map((e) => AvailabilityWindow.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<Map<String, dynamic>> getAvailabilityConfig() async {
    try {
      final res = await _apiClient.get('/doctors/availability/templates');
      List<WeeklyTemplateItem> templates = [];
      List<CustomSlotItem> customSlots = [];

      if (res is Map<String, dynamic>) {
        if (res['templates'] is List) {
          templates = (res['templates'] as List)
              .map((e) => WeeklyTemplateItem.fromJson(e as Map<String, dynamic>))
              .toList();
        }
        if (res['customSlots'] is List) {
          customSlots = (res['customSlots'] as List)
              .map((e) => CustomSlotItem.fromJson(e as Map<String, dynamic>))
              .toList();
        }
      }
      return {
        'templates': templates,
        'customSlots': customSlots,
      };
    } catch (_) {
      return {
        'templates': <WeeklyTemplateItem>[],
        'customSlots': <CustomSlotItem>[],
      };
    }
  }
}
