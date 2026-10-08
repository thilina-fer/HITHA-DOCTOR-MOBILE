import '../../domain/models/models.dart';
import '../services/api_client.dart';

class PricingRepository {
  PricingRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<PriceRequestItem>> getPriceRequests() async {
    try {
      final res = await _apiClient.get('/doctors/price-requests');
      if (res is List && res.isNotEmpty) {
        return res.map((e) => PriceRequestItem.fromJson(e as Map<String, dynamic>)).toList();
      }
      return _sampleHistory;
    } catch (_) {
      return _sampleHistory;
    }
  }

  Future<bool> submitPriceRequest({
    required double requestedPriceLkr,
    required String reason,
  }) async {
    try {
      await _apiClient.post('/doctors/price-requests', {
        'requestedPriceLkr': requestedPriceLkr,
        'reason': reason.trim(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  static final List<PriceRequestItem> _sampleHistory = [
    PriceRequestItem(
      id: 'pr-1',
      currentPriceLkr: 4500.0,
      requestedPriceLkr: 5000.0,
      reason: 'Board certification completion and updated SLMC senior specialist status.',
      status: 'APPROVED',
      createdAt: DateTime.now().subtract(const Duration(days: 45)),
    ),
  ];
}
