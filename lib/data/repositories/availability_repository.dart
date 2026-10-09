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

      // If templates is empty, provide standard initial default templates
      final resolvedTemplates = templates.isNotEmpty
          ? templates
          : List<WeeklyTemplateItem>.from(defaultWeeklyTemplates());

      resolvedTemplates.sort((a, b) {
        final dayCmp = a.dayOfWeek.compareTo(b.dayOfWeek);
        if (dayCmp != 0) return dayCmp;
        return a.startTime.compareTo(b.startTime);
      });

      return {
        'templates': resolvedTemplates,
        'customSlots': customSlots,
      };
    } catch (_) {
      return {
        'templates': defaultWeeklyTemplates(),
        'customSlots': <CustomSlotItem>[],
      };
    }
  }

  Future<bool> saveWeeklyTemplates(
    List<WeeklyTemplateItem> templates, {
    List<CustomSlotItem>? existingCustomSlots,
  }) async {
    try {
      final active = templates.where((t) => t.isActive).map((t) => t.toJson()).toList();
      final customPayload = existingCustomSlots?.map((cs) => {
            'startTime': cs.startTime.toUtc().toIso8601String(),
            'endTime': cs.endTime.toUtc().toIso8601String(),
          }).toList() ?? [];

      await _apiClient.post('/doctors/availability', {
        'templates': active,
        'customSlots': customPayload,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> addCustomSlot(DateTime start, DateTime end) async {
    try {
      await _apiClient.post('/doctors/availability/custom-slots', {
        'startTime': start.toUtc().toIso8601String(),
        'endTime': end.toUtc().toIso8601String(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteCustomSlot(String id) async {
    try {
      await _apiClient.delete('/doctors/availability/custom-slots/$id');
      return true;
    } catch (_) {
      return false;
    }
  }

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

  Future<bool> addBlockedDate(DateTime start, DateTime end, String reason) async {
    try {
      await _apiClient.post('/doctors/blocked-dates', {
        'startTime': start.toUtc().toIso8601String(),
        'endTime': end.toUtc().toIso8601String(),
        'reason': reason,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteBlockedDate(String id) async {
    try {
      await _apiClient.delete('/doctors/blocked-dates/$id');
      return true;
    } catch (_) {
      return false;
    }
  }
}
