import '../services/api_client.dart';

class MeetingRepository {
  MeetingRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> joinAsDoctor(String bookingId) async {
    try {
      final res = await _apiClient.post('/doctors/sessions/$bookingId/join');
      if (res is Map<String, dynamic>) {
        return res;
      }
      return {};
    } catch (_) {
      return {};
    }
  }

  Future<Map<String, dynamic>?> getClinicalNotes(String bookingId) async {
    try {
      final res = await _apiClient.get('/doctors/sessions/$bookingId/notes');
      if (res is Map<String, dynamic>) {
        return res;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> saveClinicalNotes({
    required String bookingId,
    required String chiefComplaint,
    required String clinicalObservations,
    required String diagnosis,
    required String treatmentPlan,
  }) async {
    try {
      await _apiClient.post('/doctors/sessions/$bookingId/notes', {
        'chiefComplaint': chiefComplaint.trim(),
        'clinicalObservations': clinicalObservations.trim(),
        'diagnosis': diagnosis.trim(),
        'treatmentPlan': treatmentPlan.trim(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> searchDrugs(String query) async {
    try {
      final res = await _apiClient.get(
        '/doctors/prescriptions/drugs/search',
        query: {'query': query, 'limit': '10'},
      );
      if (res is List && res.isNotEmpty) {
        return res.cast<Map<String, dynamic>>();
      }
      return _defaultDrugs
          .where((d) => (d['name'] as String).toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (_) {
      return _defaultDrugs
          .where((d) => (d['name'] as String).toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
  }

  Future<bool> issuePrescription({
    required String bookingId,
    required List<Map<String, dynamic>> items,
    required String doctorAdvice,
  }) async {
    try {
      await _apiClient.post('/doctors/sessions/$bookingId/prescription', {
        'items': items,
        'doctorAdvice': doctorAdvice.trim(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> completeSession(String bookingId) async {
    try {
      await _apiClient.post('/session/$bookingId/complete');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getSessionDocuments(String bookingId) async {
    try {
      final res = await _apiClient.get('/doctors/sessions/$bookingId/documents');
      if (res is List) {
        return res.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getPatientNotesHistory(String patientId) async {
    try {
      final res = await _apiClient.get('/doctors/patients/$patientId/notes-history');
      if (res is List) {
        return res.cast<Map<String, dynamic>>();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  static const List<Map<String, dynamic>> _defaultDrugs = [
    {'id': 'd1', 'name': 'Sertraline 50mg', 'form': 'Tablet', 'dosage': '50mg OD'},
    {'id': 'd2', 'name': 'Escitalopram 10mg', 'form': 'Tablet', 'dosage': '10mg OD morning'},
    {'id': 'd3', 'name': 'Fluoxetine 20mg', 'form': 'Capsule', 'dosage': '20mg OD'},
    {'id': 'd4', 'name': 'Clonazepam 0.5mg', 'form': 'Tablet', 'dosage': '0.5mg nocte SOS'},
    {'id': 'd5', 'name': 'Lorazepam 1mg', 'form': 'Tablet', 'dosage': '1mg PRN'},
    {'id': 'd6', 'name': 'Propranolol 20mg', 'form': 'Tablet', 'dosage': '20mg BD'},
    {'id': 'd7', 'name': 'Quetiapine 25mg', 'form': 'Tablet', 'dosage': '25mg nocte'},
    {'id': 'd8', 'name': 'Melatonin 3mg', 'form': 'Tablet', 'dosage': '3mg 30m before bedtime'},
  ];
}
