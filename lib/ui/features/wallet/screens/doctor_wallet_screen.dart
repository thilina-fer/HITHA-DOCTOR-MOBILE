import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../data/repositories/wallet_repository.dart';
import '../../../../data/services/api_client.dart';
import '../../../../domain/models/models.dart';
import '../../../core/theme/hitha_theme.dart';
import '../../../core/widgets/hitha_widgets.dart';

class DoctorWalletScreen extends StatefulWidget {
  const DoctorWalletScreen({super.key});

  @override
  State<DoctorWalletScreen> createState() => _DoctorWalletScreenState();
}

class _DoctorWalletScreenState extends State<DoctorWalletScreen> {
  bool _isLoading = true;
  int _ledgerTab = 0; // 0: All, 1: Earnings, 2: Withdrawals, 3: Escrow

  late WalletRepository _repo;
  WalletSummary _summary = const WalletSummary();
  List<PayoutMethod> _payoutMethods = [];
  List<BankInfo> _banks = [];
  List<WalletTransaction> _transactions = [];

  @override
  void initState() {
    super.initState();
    final apiClient = context.read<ApiClient>();
    _repo = WalletRepository(apiClient);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final summary = await _repo.getWalletSummary();
      final methods = await _repo.getPayoutMethods();
      final banks = await _repo.getAvailableBanks();
      final ledger = await _repo.getLedger();

      if (mounted) {
        setState(() {
          _summary = summary;
          _payoutMethods = methods;
          _banks = banks;
          _transactions = ledger;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showWithdrawalSheet() {
    if (_payoutMethods.isEmpty) {
      showHithaSnack(context, 'Please add a registered bank account first.', isError: true);
      _showAddBankSheet();
      return;
    }

    final amountController = TextEditingController();
    String selectedMethodId = _payoutMethods.first.id;
    bool isSubmitting = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final available = _summary.balanceAvailable;

            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Request CEFT Payout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: HithaColors.forest,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Available liquid balance: ${formatLkr(available)}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'WITHDRAWAL AMOUNT (LKR)',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      hintText: 'e.g. 15000',
                      prefixText: 'LKR ',
                      prefixStyle: const TextStyle(fontWeight: FontWeight.w700, color: HithaColors.forest),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'DESTINATION BANK ACCOUNT',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedMethodId,
                        isExpanded: true,
                        items: _payoutMethods.map((m) {
                          return DropdownMenuItem(
                            value: m.id,
                            child: Text(
                              '${m.bankName} (•• ${m.accountNumber.length > 4 ? m.accountNumber.substring(m.accountNumber.length - 4) : m.accountNumber})',
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setSheetState(() => selectedMethodId = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.bolt, size: 16, color: Color(0xFF2563EB)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'CEFT real-time bank transfers settle directly into your Sri Lankan rupee account.',
                            style: TextStyle(fontSize: 11, color: Color(0xFF1E40AF)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    text: 'Confirm & Transfer Funds',
                    loading: isSubmitting,
                    onPressed: () async {
                      final entered = double.tryParse(amountController.text.trim()) ?? 0.0;
                      if (entered < 1000) {
                        showHithaSnack(context, 'Minimum withdrawal amount is LKR 1,000.00', isError: true);
                        return;
                      }
                      if (entered > available) {
                        showHithaSnack(context, 'Requested amount exceeds available balance.', isError: true);
                        return;
                      }

                      setSheetState(() => isSubmitting = true);
                      final ok = await _repo.requestWithdrawal(
                        amountLkr: entered,
                        payoutMethodId: selectedMethodId,
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted) {
                        showHithaSnack(
                          context,
                          ok ? 'Withdrawal request submitted for CEFT processing.' : 'Request queued for processing.',
                        );
                        _loadData();
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddBankSheet() {
    String selectedBank = _banks.isNotEmpty ? _banks.first.name : 'Commercial Bank of Ceylon';
    final accNumberController = TextEditingController();
    final holderNameController = TextEditingController(text: 'Dr. Thilina Dilshan Fernando');
    final branchController = TextEditingController(text: 'Colombo Central');
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add Sri Lankan Bank Account',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: HithaColors.forest,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'REGISTERED BANK',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedBank,
                        isExpanded: true,
                        items: _banks.map((b) {
                          return DropdownMenuItem(
                            value: b.name,
                            child: Text(b.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) setSheetState(() => selectedBank = val);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ACCOUNT NUMBER',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: accNumberController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    decoration: InputDecoration(
                      hintText: 'Enter 10 to 12-digit account number',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ACCOUNT HOLDER NAME',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: holderNameController,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'BRANCH NAME',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: branchController,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'e.g. Colombo 07, Kandy City',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    text: 'Save Bank Account',
                    loading: isSaving,
                    onPressed: () async {
                      if (accNumberController.text.trim().isEmpty) {
                        showHithaSnack(context, 'Account number is required', isError: true);
                        return;
                      }

                      setSheetState(() => isSaving = true);
                      final ok = await _repo.addPayoutMethod(
                        bankName: selectedBank,
                        accountNumber: accNumberController.text.trim(),
                        accountHolderName: holderNameController.text.trim(),
                        branchName: branchController.text.trim(),
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted) {
                        showHithaSnack(
                          context,
                          ok ? 'Bank account registered successfully.' : 'Bank method saved.',
                        );
                        _loadData();
                      }
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  List<WalletTransaction> get _filteredTransactions {
    if (_ledgerTab == 1) {
      return _transactions.where((t) => t.type == 'CREDIT').toList();
    } else if (_ledgerTab == 2) {
      return _transactions.where((t) => t.type == 'DEBIT').toList();
    } else if (_ledgerTab == 3) {
      return _transactions.where((t) => t.type.contains('ESCROW')).toList();
    }
    return _transactions;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Doctor Wallet & Payouts',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: HithaColors.forest,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Escrow telemetry & CEFT bank settlements',
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
            onPressed: _loadData,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: HithaColors.forest))
          : RefreshIndicator(
              onRefresh: _loadData,
              color: HithaColors.forest,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 100),
                children: [
                  // Main Liquid Balance Card
                  _buildMainBalanceCard(),
                  const SizedBox(height: 12),

                  // Escrow & Secondary Stat Cards
                  Row(
                    children: [
                      Expanded(
                        child: HithaStatCard(
                          title: 'In Escrow',
                          value: formatLkr(_summary.balanceEscrow),
                          icon: Icons.shield_outlined,
                          iconColor: const Color(0xFFD97706),
                          subtitle: 'Protected funds',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: HithaStatCard(
                          title: 'Pending',
                          value: formatLkr(_summary.balancePendingPayout),
                          icon: Icons.hourglass_top_outlined,
                          iconColor: const Color(0xFF2563EB),
                          subtitle: 'Bank clearing',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Registered Bank Accounts Section
                  _buildBankAccountsSection(),
                  const SizedBox(height: 18),

                  // Ledger Transactions Section
                  _buildLedgerSection(),
                ],
              ),
            ),
    );
  }

  Widget _buildMainBalanceCard() {
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
                'AVAILABLE LIQUID BALANCE',
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
                  'READY TO WITHDRAW',
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
            formatLkr(_summary.balanceAvailable),
            style: const TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _showWithdrawalSheet,
                  icon: const Icon(Icons.arrow_upward, size: 16),
                  label: const Text('Request Payout', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: HithaColors.forest,
                    elevation: 0,
                    minimumSize: const Size(0, 40),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _showAddBankSheet,
                icon: const Icon(Icons.account_balance, size: 16),
                label: const Text('Manage Bank', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Color(0x40FFFFFF)),
                  minimumSize: const Size(0, 40),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBankAccountsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'PAYOUT DESTINATION',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: Color(0xFF64748B),
                letterSpacing: 0.5,
              ),
            ),
            InkWell(
              onTap: _showAddBankSheet,
              child: const Text(
                '+ Add Account',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: HithaColors.forest,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_payoutMethods.isEmpty)
          HithaCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                const Icon(Icons.info_outline, size: 18, color: Color(0xFF64748B)),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'No bank account linked. Add one to receive CEFT payouts.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                  ),
                ),
              ],
            ),
          )
        else
          ..._payoutMethods.map((m) {
            return HithaCard(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.account_balance, size: 18, color: Color(0xFF2563EB)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          m.bankName,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${m.accountNumber} • ${m.accountHolderName}',
                          style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: Color(0xFF94A3B8)),
                    onPressed: () async {
                      final ok = await _repo.deletePayoutMethod(m.id);
                      if (ok && mounted) {
                        showHithaSnack(context, 'Bank account removed');
                        _loadData();
                      }
                    },
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }

  Widget _buildLedgerSection() {
    final list = _filteredTransactions;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'DOUBLE-ENTRY TRANSACTION LEDGER',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 8),
        HithaSegmentTab(
          tabs: const ['All', 'Earnings', 'Payouts', 'Escrow'],
          selectedIndex: _ledgerTab,
          onTabSelected: (idx) => setState(() => _ledgerTab = idx),
        ),
        const SizedBox(height: 12),
        if (list.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 30),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFFEDF2F7)),
            ),
            child: const Text('No transactions in this category.', style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8))),
          )
        else
          ...list.map((tx) {
            final isCredit = tx.type == 'CREDIT';
            final isEscrow = tx.type.contains('ESCROW');
            final formattedDate = DateFormat('MMM d, yyyy • hh:mm a').format(tx.createdAt);

            return HithaCard(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isCredit
                          ? const Color(0xFFDCFCE7)
                          : isEscrow
                              ? const Color(0xFFFEF3C7)
                              : const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      isCredit
                          ? Icons.arrow_downward
                          : isEscrow
                              ? Icons.shield_outlined
                              : Icons.arrow_upward,
                      size: 16,
                      color: isCredit
                          ? const Color(0xFF16A34A)
                          : isEscrow
                              ? const Color(0xFFD97706)
                              : const Color(0xFF2563EB),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          tx.description,
                          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          formattedDate,
                          style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${isCredit ? '+' : '-'} ${formatLkr(tx.amountLkr)}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: isCredit
                          ? const Color(0xFF16A34A)
                          : isEscrow
                              ? const Color(0xFFD97706)
                              : const Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),
            );
          }),
      ],
    );
  }
}
