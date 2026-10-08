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
      const WeeklyTemplateItem(dayOfWeek: 6, startTime: '09:00', endTime: '13:00', isActive: false),
      const WeeklyTemplateItem(dayOfWeek: 7, startTime: '09:00', endTime: '13:00', isActive: false),
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

      // If templates is empty, merge with standard Mon-Sun defaults
      final fullTemplates = List<WeeklyTemplateItem>.from(defaultWeeklyTemplates());
      for (var i = 0; i < fullTemplates.length; i++) {
        final existing = templates.where((t) => t.dayOfWeek == fullTemplates[i].dayOfWeek).firstOrNull;
        if (existing != null) {
          fullTemplates[i] = existing;
        }
      }

      return {
        'templates': fullTemplates,
        'customSlots': customSlots,
      };
    } catch (_) {
      return {
        'templates': defaultWeeklyTemplates(),
        'customSlots': <CustomSlotItem>[],
      };
    }
  }

  Future<bool> saveWeeklyTemplates(List<WeeklyTemplateItem> templates) async {
    try {
      final active = templates.where((t) => t.isActive).map((t) => t.toJson()).toList();
      await _apiClient.post('/doctors/availability', {
        'templates': active,
        'customSlots': [],
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
