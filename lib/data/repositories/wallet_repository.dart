import '../../domain/models/models.dart';
import '../services/api_client.dart';
import '../services/sample_data.dart';

class WalletRepository {
  WalletRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<WalletSummary> getWalletSummary() async {
    try {
      final res = await _apiClient.get('/doctor/wallet/summary');
      if (res is Map<String, dynamic>) {
        return WalletSummary.fromJson(res);
      }
      return SampleData.walletSummary;
    } catch (_) {
      return SampleData.walletSummary;
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
      if (res is List && res.isNotEmpty) {
        return res.map((e) => PayoutMethod.fromJson(e as Map<String, dynamic>)).toList();
      }
      return _defaultPayoutMethods;
    } catch (_) {
      return _defaultPayoutMethods;
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
      if (rawList.isNotEmpty) {
        return rawList.map((e) => WalletTransaction.fromJson(e as Map<String, dynamic>)).toList();
      }
      return _sampleTransactions;
    } catch (_) {
      return _sampleTransactions;
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

  static final List<PayoutMethod> _defaultPayoutMethods = [
    const PayoutMethod(
      id: 'pm-1',
      bankName: 'Commercial Bank of Ceylon',
      accountNumber: '8004928172',
      accountHolderName: 'Dr. Thilina Fernando',
      branchName: 'Colombo 07',
      isDefault: true,
    ),
  ];

  static final List<WalletTransaction> _sampleTransactions = [
    WalletTransaction(
      id: 'tx-1',
      description: 'Consultation Fee • Anuki Samarasinghe',
      amountLkr: 4250.0,
      type: 'CREDIT',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      status: 'COMPLETED',
    ),
    WalletTransaction(
      id: 'tx-2',
      description: 'CEFT Bank Payout to COMB 8004928172',
      amountLkr: 15000.0,
      type: 'DEBIT',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      status: 'COMPLETED',
    ),
    WalletTransaction(
      id: 'tx-3',
      description: 'Consultation Escrow Held • Kusal Mendis',
      amountLkr: 4250.0,
      type: 'ESCROW_HOLD',
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      status: 'PENDING',
    ),
    WalletTransaction(
      id: 'tx-4',
      description: 'Consultation Fee • Nimna Perera',
      amountLkr: 4250.0,
      type: 'CREDIT',
      createdAt: DateTime.now().subtract(const Duration(days: 4)),
      status: 'COMPLETED',
    ),
  ];
}
