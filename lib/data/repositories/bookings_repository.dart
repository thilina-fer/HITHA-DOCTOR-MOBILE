import '../../domain/models/models.dart';
import '../services/api_client.dart';
import '../services/sample_data.dart';

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

      if (rawList.isNotEmpty) {
        return rawList
            .map((e) => BookingItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      // Filter sample fallback data if matching status is given
      if (status != null && status.isNotEmpty) {
        return SampleData.todayBookings
            .where((b) => b.status.value.toUpperCase() == status.toUpperCase())
            .toList();
      }
      return SampleData.todayBookings;
    } catch (_) {
      if (status != null && status.isNotEmpty) {
        return SampleData.todayBookings
            .where((b) => b.status.value.toUpperCase() == status.toUpperCase())
            .toList();
      }
      return SampleData.todayBookings;
    }
  }

  Future<BookingItem?> getBookingById(String id) async {
    try {
      final res = await _apiClient.get('/doctors/bookings/$id');
      if (res is Map<String, dynamic>) {
        return BookingItem.fromJson(res);
      }
      return SampleData.todayBookings.where((b) => b.id == id).firstOrNull;
    } catch (_) {
      return SampleData.todayBookings.where((b) => b.id == id).firstOrNull ??
          BookingItem(
            id: id,
            bookingReference: 'HTH-BK${id.length > 4 ? id.substring(0, 4) : id}',
            patientName: 'Anuki Samarasinghe',
            patientPhone: '+94 77 123 4567',
            scheduledStartTime: DateTime.now().add(const Duration(hours: 1)),
            scheduledEndTime: DateTime.now().add(const Duration(hours: 1, minutes: 45)),
            status: BookingStatus.CONFIRMED,
            feeLkr: 5000.0,
            sessionNotes: 'Follow-up consultation for cognitive behavioral assessment.',
          );
    }
  }
}
