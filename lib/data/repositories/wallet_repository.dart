import '../../domain/models/models.dart';
import '../services/api_client.dart';

class WalletRepository {
  WalletRepository(this._apiClient);

  final ApiClient _apiClient;

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

  Future<List<BankInfo>> getAvailableBanks() async {
    try {
      final res = await _apiClient.get('/doctor/wallet/banks');
      if (res is List && res.isNotEmpty) {
        return res.map((e) => BankInfo.fromJson(e as Map<String, dynamic>)).toList();
      }
      return _defaultBanks;
    } catch (_) {
      return _defaultBanks;
    }
  }

  Future<List<PayoutMethod>> getPayoutMethods() async {
    try {
      final res = await _apiClient.get('/doctor/wallet/payout-methods');
      if (res is List) {
        return res.map((e) => PayoutMethod.fromJson(e as Map<String, dynamic>)).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  Future<bool> addPayoutMethod({
    required String bankName,
    required String accountNumber,
    required String accountHolderName,
    required String branchName,
  }) async {
    try {
      await _apiClient.post('/doctor/wallet/payout-methods', {
        'bankName': bankName,
        'accountNumber': accountNumber,
        'accountHolderName': accountHolderName,
        'branchName': branchName,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deletePayoutMethod(String id) async {
    try {
      await _apiClient.delete('/doctor/wallet/payout-methods/$id');
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> requestWithdrawal({
    required double amountLkr,
    required String payoutMethodId,
  }) async {
    try {
      await _apiClient.post('/doctor/wallet/withdrawals', {
        'amountLkr': amountLkr,
        'payoutMethodId': payoutMethodId,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<List<WalletTransaction>> getLedger() async {
    try {
      final res = await _apiClient.get('/doctor/wallet/ledger', query: {'page': '0', 'size': '30'});
      List rawList = [];
      if (res is Map<String, dynamic> && res['content'] is List) {
        rawList = res['content'] as List;
      } else if (res is List) {
        rawList = res;
      }
      return rawList.map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static const List<BankInfo> _defaultBanks = [
    BankInfo(code: '7010', name: 'Bank of Ceylon (BOC)'),
    BankInfo(code: '7056', name: 'Commercial Bank of Ceylon (COMB)'),
    BankInfo(code: '7083', name: 'Hatton National Bank (HNB)'),
    BankInfo(code: '7162', name: 'Nations Trust Bank (NTB)'),
    BankInfo(code: '7214', name: 'People\'s Bank'),
    BankInfo(code: '7278', name: 'Sampath Bank'),
    BankInfo(code: '7287', name: 'Seylan Bank'),
  ];
}
