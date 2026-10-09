import '../services/api_client.dart';

class DoctorFinanceSummary {
  final double todayGrossLkr;
  final double todayNetLkr;
  final double totalGrossLkr;
  final double totalNetLkr;
  final double totalCommissionLkr;
  final double balanceEscrowLkr;
  final double balanceAvailableLkr;
  final double totalWithdrawnLkr;
  final int totalConsultationsCount;
  final int todayConsultationsCount;
  final double activeCommissionPercent;

  const DoctorFinanceSummary({
    this.todayGrossLkr = 0.0,
    this.todayNetLkr = 0.0,
    this.totalGrossLkr = 0.0,
    this.totalNetLkr = 0.0,
    this.totalCommissionLkr = 0.0,
    this.balanceEscrowLkr = 0.0,
    this.balanceAvailableLkr = 0.0,
    this.totalWithdrawnLkr = 0.0,
    this.totalConsultationsCount = 0,
    this.todayConsultationsCount = 0,
    this.activeCommissionPercent = 15.0,
  });

  factory DoctorFinanceSummary.fromJson(Map<String, dynamic> json) {
    return DoctorFinanceSummary(
      todayGrossLkr: (json['todayGrossEarningsLkr'] as num?)?.toDouble() ?? 0.0,
      todayNetLkr: (json['todayNetEarningsLkr'] as num?)?.toDouble() ?? 0.0,
      totalGrossLkr: (json['totalGrossEarningsLkr'] as num?)?.toDouble() ?? 0.0,
      totalNetLkr: (json['totalNetEarningsLkr'] as num?)?.toDouble() ?? 0.0,
      totalCommissionLkr: (json['totalCommissionDeductedLkr'] as num?)?.toDouble() ?? 0.0,
      balanceEscrowLkr: (json['balanceEscrowLkr'] as num?)?.toDouble() ?? 0.0,
      balanceAvailableLkr: (json['balanceAvailableLkr'] as num?)?.toDouble() ?? 0.0,
      totalWithdrawnLkr: (json['totalWithdrawnLkr'] as num?)?.toDouble() ?? 0.0,
      totalConsultationsCount: (json['totalConsultationsCount'] as num?)?.toInt() ?? 0,
      todayConsultationsCount: (json['todayConsultationsCount'] as num?)?.toInt() ?? 0,
      activeCommissionPercent: (json['activeCommissionRatePercent'] as num?)?.toDouble() ?? 15.0,
    );
  }
}

class FinanceRepository {
  FinanceRepository(this._apiClient);

  final ApiClient _apiClient;

  Future<DoctorFinanceSummary> getSummary() async {
    try {
      final res = await _apiClient.get('/doctor/finance/summary');
      if (res is Map<String, dynamic>) {
        return DoctorFinanceSummary.fromJson(res);
      }
      return const DoctorFinanceSummary();
    } catch (_) {
      return const DoctorFinanceSummary();
    }
  }
}
