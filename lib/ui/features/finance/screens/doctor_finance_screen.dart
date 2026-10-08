import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../data/repositories/finance_repository.dart';
import '../../../../data/services/api_client.dart';
import '../../../core/theme/hitha_theme.dart';
import '../../../core/widgets/hitha_widgets.dart';

class DoctorFinanceScreen extends StatefulWidget {
  const DoctorFinanceScreen({super.key});

  @override
  State<DoctorFinanceScreen> createState() => _DoctorFinanceScreenState();
}

class _DoctorFinanceScreenState extends State<DoctorFinanceScreen> {
  bool _isLoading = true;
  late FinanceRepository _repo;
  DoctorFinanceSummary _summary = const DoctorFinanceSummary();

  @override
  void initState() {
    super.initState();
    final apiClient = context.read<ApiClient>();
    _repo = FinanceRepository(apiClient);
    _loadSummary();
  }

  Future<void> _loadSummary() async {
    setState(() => _isLoading = true);
    final s = await _repo.getSummary();
    if (mounted) {
      setState(() {
        _summary = s;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: HithaColors.forest),
          onPressed: () => context.pop(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Income Telemetry',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: HithaColors.forest,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Revenue metrics, commission & consultation payouts',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: HithaColors.forest, size: 21),
            onPressed: _loadSummary,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: HithaColors.forest))
          : RefreshIndicator(
              onRefresh: _loadSummary,
              color: HithaColors.forest,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  // Net Lifetime Revenue Card
                  _buildRevenueBannerCard(),
                  const SizedBox(height: 14),

                  // Today Snapshot Row
                  Row(
                    children: [
                      Expanded(
                        child: HithaStatCard(
                          title: "Today's Income",
                          value: formatLkr(_summary.todayNetLkr),
                          subtitle: 'Net doctor share',
                          icon: Icons.today,
                          iconColor: const Color(0xFF16A34A),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: HithaStatCard(
                          title: 'Appointments',
                          value: '${_summary.todayConsultationsCount} Booked',
                          subtitle: 'Scheduled today',
                          icon: Icons.calendar_month,
                          iconColor: const Color(0xFF2563EB),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Volume & Escrow Row
                  Row(
                    children: [
                      Expanded(
                        child: HithaStatCard(
                          title: 'Total Sessions',
                          value: '${_summary.totalConsultationsCount}',
                          subtitle: 'Lifetime appointments',
                          icon: Icons.checklist_rtl_rounded,
                          iconColor: HithaColors.forest,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: HithaStatCard(
                          title: 'Active Escrow',
                          value: formatLkr(_summary.balanceEscrowLkr),
                          subtitle: 'Held safely',
                          icon: Icons.shield_outlined,
                          iconColor: const Color(0xFFD97706),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Commission Transparency Card
                  _buildCommissionTransparencyCard(),
                  const SizedBox(height: 16),

                  // Go to Wallet button
                  PrimaryButton(
                    text: 'Open Wallet & Request CEFT Payout',
                    icon: Icons.account_balance_wallet_outlined,
                    onPressed: () => context.push('/doctor/wallet'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildRevenueBannerCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: HithaColors.forest,
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x180C3854),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'LIFETIME NET DOCTOR EARNINGS',
                style: TextStyle(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF94A3B8),
                  letterSpacing: 0.6,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '85% DOCTOR SHARE',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF34D399),
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            formatLkr(_summary.totalNetLkr),
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Gross Patient Billing', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                  const SizedBox(height: 2),
                  Text(
                    formatLkr(_summary.totalGrossLkr),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('Platform Infrastructure (15%)', style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8))),
                  const SizedBox(height: 2),
                  Text(
                    '- ${formatLkr(_summary.totalCommissionLkr)}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFFFCA5A5)),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCommissionTransparencyCard() {
    return HithaCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'FEE DISTRIBUTION TRANSPARENCY',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Color(0xFF64748B),
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          // Split Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                Expanded(
                  flex: 85,
                  child: Container(
                    height: 10,
                    color: const Color(0xFF10B981),
                  ),
                ),
                Expanded(
                  flex: 15,
                  child: Container(
                    height: 10,
                    color: const Color(0xFFCBD5E1),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF10B981))),
                  const SizedBox(width: 6),
                  const Text('Doctor Share (85%)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF334155))),
                ],
              ),
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF94A3B8))),
                  const SizedBox(width: 6),
                  const Text('Platform & CEFT (15%)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B))),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Text(
              'Hitha operates on a zero-hidden-fee model. Cloud video infrastructure, encrypted storage, and bank transfer charges are fully covered by the 15% platform fee.',
              style: TextStyle(fontSize: 11, color: Color(0xFF64748B), height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
