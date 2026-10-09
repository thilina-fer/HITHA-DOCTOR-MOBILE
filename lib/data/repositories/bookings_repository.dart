import '../../domain/models/models.dart';
import '../services/api_client.dart';

class BookingsRepository {
  BookingsRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<BookingItem>> getBookings({
    String? status,
    int page = 0,
    int size = 30,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'size': size.toString(),
      };
      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final res = await _apiClient.get('/doctors/bookings', query: queryParams);
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

  Future<BookingItem?> getBookingById(String id) async {
    try {
      final res = await _apiClient.get('/doctors/bookings/$id');
      if (res is Map<String, dynamic>) {
        return BookingItem.fromJson(res);
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
