import '../../domain/models/models.dart';
import '../services/api_client.dart';

class PricingRepository {
  PricingRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<List<PriceRequestItem>> getPriceRequests() async {
    try {
      final res = await _apiClient.get('/doctors/price-requests');
      if (res is List) {
        return res.map((e) => PriceRequestItem.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      return [];
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
}
