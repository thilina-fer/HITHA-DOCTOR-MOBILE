import '../../domain/models/models.dart';
import '../services/api_client.dart';

class AvailabilityRepository {
  AvailabilityRepository(this._apiClient);

  final ApiClient _apiClient;

  static List<WeeklyTemplateItem> defaultWeeklyTemplates() {
    return [
      const WeeklyTemplateItem(dayOfWeek: 1, startTime: '09:00', endTime: '17:00', isActive: true),
      const WeeklyTemplateItem(dayOfWeek: 2, startTime: '09:00', endTime: '17:00', isActive: true),
      const WeeklyTemplateItem(dayOfWeek: 3, startTime: '09:00', endTime: '17:00', isActive: true),
      const WeeklyTemplateItem(dayOfWeek: 4, startTime: '09:00', endTime: '17:00', isActive: true),
      const WeeklyTemplateItem(dayOfWeek: 5, startTime: '09:00', endTime: '17:00', isActive: true),
    ];
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

      templates.sort((a, b) {
        final dayCmp = a.dayOfWeek.compareTo(b.dayOfWeek);
        if (dayCmp != 0) return dayCmp;
        return a.startTime.compareTo(b.startTime);
      });

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

  /// Saves weekly recurring templates to the backend (`POST /doctors/availability`).
  /// Throws [ApiException] with the backend's exact validation or business error message.
  Future<void> saveWeeklyTemplates(
    List<WeeklyTemplateItem> templates, {
    List<CustomSlotItem>? existingCustomSlots,
  }) async {
    final active = templates.where((t) => t.isActive).map((t) => t.toJson()).toList();
    final Map<String, dynamic> body = {
      'templates': active,
    };

    if (existingCustomSlots != null && existingCustomSlots.isNotEmpty) {
      body['customSlots'] = existingCustomSlots.map((cs) => {
            'startTime': cs.rawStartTime ?? cs.startTime.toUtc().toIso8601String(),
            'endTime': cs.rawEndTime ?? cs.endTime.toUtc().toIso8601String(),
          }).toList();
    } else {
      body['customSlots'] = [];
    }

    await _apiClient.post('/doctors/availability', body);
  }

  /// Adds a single one-off ad-hoc slot (`POST /doctors/availability/custom-slots`).
  Future<void> addCustomSlot(DateTime start, DateTime end) async {
    if (!end.isAfter(start)) {
      throw ApiException('End time must be strictly after start time.');
    }
    await _apiClient.post('/doctors/availability/custom-slots', {
      'startTime': start.toUtc().toIso8601String(),
      'endTime': end.toUtc().toIso8601String(),
    });
  }

  /// Removes a one-off custom slot (`DELETE /doctors/availability/custom-slots/{id}`).
  Future<void> deleteCustomSlot(String id) async {
    await _apiClient.delete('/doctors/availability/custom-slots/$id');
  }

  /// Fetches scheduled leaves and blocked ranges (`GET /doctors/blocked-dates`).
  Future<List<BlockedDateItem>> getBlockedDates() async {
    try {
      final res = await _apiClient.get('/doctors/blocked-dates');
      if (res is List) {
        return res.map((e) => BlockedDateItem.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Schedules leave or blocked dates (`POST /doctors/blocked-dates`).
  Future<void> addBlockedDate(DateTime start, DateTime end, String reason) async {
    if (!end.isAfter(start)) {
      throw ApiException('End date/time must be strictly after start date/time.');
    }
    await _apiClient.post('/doctors/blocked-dates', {
      'startTime': start.toUtc().toIso8601String(),
      'endTime': end.toUtc().toIso8601String(),
      'reason': reason.trim(),
    });
  }

  /// Removes scheduled leave (`DELETE /doctors/blocked-dates/{id}`).
  Future<void> deleteBlockedDate(String id) async {
    await _apiClient.delete('/doctors/blocked-dates/$id');
  }
}
