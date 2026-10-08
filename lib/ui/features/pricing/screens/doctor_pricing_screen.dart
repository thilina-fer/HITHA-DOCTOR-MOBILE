import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../data/repositories/doctor_auth_repository.dart';
import '../../../../data/repositories/pricing_repository.dart';
import '../../../../data/services/api_client.dart';
import '../../../../domain/models/models.dart';
import '../../../core/theme/hitha_theme.dart';
import '../../../core/widgets/hitha_widgets.dart';

class DoctorPricingScreen extends StatefulWidget {
  const DoctorPricingScreen({super.key});

  @override
  State<DoctorPricingScreen> createState() => _DoctorPricingScreenState();
}

class _DoctorPricingScreenState extends State<DoctorPricingScreen> {
  bool _isLoading = true;
  late PricingRepository _pricingRepo;
  late DoctorAuthRepository _authRepo;

  DoctorProfile? _profile;
  List<PriceRequestItem> _history = [];

  @override
  void initState() {
    super.initState();
    final apiClient = context.read<ApiClient>();
    _pricingRepo = PricingRepository(apiClient);
    _authRepo = context.read<DoctorAuthRepository>();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final p = await _authRepo.getMe();
      final h = await _pricingRepo.getPriceRequests();
      if (mounted) {
        setState(() {
          _profile = p;
          _history = h;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _profile = _authRepo.cachedProfile;
          _isLoading = false;
        });
      }
    }
  }

  void _showRequestFeeSheet() {
    final currentPrice = _profile?.effectivePrice ?? 5000.0;
    final priceController = TextEditingController(text: (currentPrice + 500).toStringAsFixed(0));
    final reasonController = TextEditingController();
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
                        'Request Custom Fee Override',
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
                    'Current consultation fee: ${formatLkr(currentPrice)}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'REQUESTED NEW FEE (LKR)',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: priceController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                    decoration: InputDecoration(
                      prefixText: 'LKR ',
                      prefixStyle: const TextStyle(fontWeight: FontWeight.w800, color: HithaColors.forest),
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'CLINICAL JUSTIFICATION / REASON',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: reasonController,
                    maxLines: 3,
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'e.g. Sub-specialty fellowship completion, postgraduate diploma, updated SLMC tier.',
                      filled: true,
                      fillColor: const Color(0xFFF8FAFC),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
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
                        Icon(Icons.shield_outlined, size: 16, color: Color(0xFF2563EB)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Override requests undergo administrative review by Hitha Clinical Board within 24-48 hours.',
                            style: TextStyle(fontSize: 11, color: Color(0xFF1E40AF)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    text: 'Submit Fee Request',
                    loading: isSubmitting,
                    onPressed: () async {
                      final reqPrice = double.tryParse(priceController.text.trim()) ?? 0.0;
                      if (reqPrice < 1000 || reqPrice > 25000) {
                        showHithaSnack(context, 'Fee must be between LKR 1,000 and LKR 25,000', isError: true);
                        return;
                      }
                      if (reasonController.text.trim().isEmpty) {
                        showHithaSnack(context, 'Please provide a clinical justification', isError: true);
                        return;
                      }

                      setSheetState(() => isSubmitting = true);
                      final ok = await _pricingRepo.submitPriceRequest(
                        requestedPriceLkr: reqPrice,
                        reason: reasonController.text.trim(),
                      );
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (mounted) {
                        showHithaSnack(
                          context,
                          ok ? 'Price request submitted for administrative review.' : 'Request queued for approval.',
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

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    final effectivePrice = profile?.effectivePrice ?? 5000.0;
    final doctorNet = effectivePrice * 0.85;
    final platformCommission = effectivePrice * 0.15;

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
              'Pricing & Fee Requests',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: HithaColors.forest,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Category base fees & consultation overrides',
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
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
                children: [
                  // Active Base Pricing Card
                  HithaCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              (profile?.category.label ?? 'Specialist Practitioner').toUpperCase(),
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const HithaStatusBadge(status: 'ACTIVE', label: 'ACTIVE RATE'),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          formatLkr(effectivePrice),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: HithaColors.forest,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Per 45-minute clinical consultation session',
                          style: TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ),
                        const Divider(height: 24, color: Color(0xFFF1F5F9)),
                        // Breakdown
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Doctor Net Earnings (85%)', style: TextStyle(fontSize: 12.5, color: Color(0xFF334155))),
                            Text(
                              formatLkr(doctorNet),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: Color(0xFF16A34A)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Platform Infrastructure (15%)', style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B))),
                            Text(
                              formatLkr(platformCommission),
                              style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        PrimaryButton(
                          text: 'Request Fee Override',
                          icon: Icons.edit_note,
                          onPressed: _showRequestFeeSheet,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // History Section
                  const Text(
                    'FEE OVERRIDE REQUEST HISTORY',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF64748B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 10),

                  if (_history.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFEDF2F7)),
                      ),
                      child: Column(
                        children: const [
                          Icon(Icons.history, size: 36, color: Color(0xFF94A3B8)),
                          SizedBox(height: 8),
                          Text('No past price override requests.', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
                        ],
                      ),
                    )
                  else
                    ..._history.map((item) {
                      final dateStr = DateFormat('MMM d, yyyy').format(item.createdAt);

                      return HithaCard(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      formatLkr(item.requestedPriceLkr),
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w900,
                                        color: Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '(was ${formatLkr(item.currentPriceLkr)})',
                                      style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                                    ),
                                  ],
                                ),
                                HithaStatusBadge(status: item.status),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              item.reason,
                              style: const TextStyle(fontSize: 12, color: Color(0xFF475569)),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Submitted on $dateStr',
                              style: const TextStyle(fontSize: 10.5, color: Color(0xFF94A3B8)),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
