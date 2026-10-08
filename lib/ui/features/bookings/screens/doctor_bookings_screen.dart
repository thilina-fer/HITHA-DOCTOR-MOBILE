import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../data/repositories/bookings_repository.dart';
import '../../../../data/services/api_client.dart';
import '../../../../domain/models/models.dart';
import '../../../core/theme/hitha_theme.dart';
import '../../../core/widgets/hitha_widgets.dart';

class DoctorBookingsScreen extends StatefulWidget {
  const DoctorBookingsScreen({super.key});

  @override
  State<DoctorBookingsScreen> createState() => _DoctorBookingsScreenState();
}

class _DoctorBookingsScreenState extends State<DoctorBookingsScreen> {
  int _selectedTab = 0; // 0: Upcoming, 1: Completed, 2: Cancelled, 3: All
  bool _isLoading = true;
  String _searchQuery = '';
  late BookingsRepository _repo;
  List<BookingItem> _allBookings = [];

  final _searchController = TextEditingController();

  static const _tabs = ['Upcoming', 'Completed', 'Cancelled', 'All'];

  @override
  void initState() {
    super.initState();
    final apiClient = context.read<ApiClient>();
    _repo = BookingsRepository(apiClient);
    _loadBookings();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    setState(() => _isLoading = true);
    try {
      final list = await _repo.getBookings();
      if (mounted) {
        setState(() {
          _allBookings = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<BookingItem> get _filteredBookings {
    var list = _allBookings;

    // Filter by tab
    if (_selectedTab == 0) {
      list = list.where((b) => b.status == BookingStatus.CONFIRMED || b.status == BookingStatus.ACTIVE).toList();
    } else if (_selectedTab == 1) {
      list = list.where((b) => b.status == BookingStatus.COMPLETED).toList();
    } else if (_selectedTab == 2) {
      list = list.where((b) => b.status == BookingStatus.CANCELLED || b.status == BookingStatus.EXPIRED).toList();
    }

    // Filter by search query
    if (_searchQuery.trim().isNotEmpty) {
      final q = _searchQuery.toLowerCase().trim();
      list = list.where((b) {
        return b.patientName.toLowerCase().contains(q) ||
            b.bookingReference.toLowerCase().contains(q) ||
            b.id.toLowerCase().contains(q);
      }).toList();
    }

    return list;
  }

  @override
  Widget build(BuildContext context) {
    final bookings = _filteredBookings;

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
              'Consultations Queue',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: HithaColors.forest,
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Manage patient appointments & telehealth sessions',
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
            onPressed: _loadBookings,
          ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(102),
          child: Column(
            children: [
              // Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: SizedBox(
                  height: 38,
                  child: TextField(
                    controller: _searchController,
                    onChanged: (val) => setState(() => _searchQuery = val),
                    style: const TextStyle(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Search patient name or booking ID...',
                      hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                      prefixIcon: const Icon(Icons.search, size: 18, color: Color(0xFF94A3B8)),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 16),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _searchQuery = '');
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: const Color(0xFFF1F5F9),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
              // Segmented Tab Switcher
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: HithaSegmentTab(
                  tabs: _tabs,
                  selectedIndex: _selectedTab,
                  onTabSelected: (idx) => setState(() => _selectedTab = idx),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: HithaColors.forest))
          : RefreshIndicator(
              onRefresh: _loadBookings,
              color: HithaColors.forest,
              child: bookings.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 90),
                      itemCount: bookings.length,
                      itemBuilder: (context, index) {
                        return _buildBookingCard(bookings[index]);
                      },
                    ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.18),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.calendar_today_outlined, size: 30, color: Color(0xFF3B82F6)),
              ),
              const SizedBox(height: 14),
              Text(
                'No ${_tabs[_selectedTab]} Consultations',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 6),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Bookings will appear here as soon as patients confirm consultation slots.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookingCard(BookingItem item) {
    final dateFormat = DateFormat('EEE, MMM d • hh:mm a');
    final formattedTime = dateFormat.format(item.scheduledStartTime.toLocal());
    final isUpcoming = item.status == BookingStatus.CONFIRMED || item.status == BookingStatus.ACTIVE;

    return HithaCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      onTap: () => context.push('/doctor/bookings/${item.id}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: item.isAnonymous ? const Color(0xFFF1F5F9) : const Color(0xFFE0F2FE),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Icon(
                  item.isAnonymous ? Icons.shield_outlined : Icons.person_outline,
                  size: 22,
                  color: item.isAnonymous ? const Color(0xFF64748B) : HithaColors.forest,
                ),
              ),
              const SizedBox(width: 12),
              // Patient details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Text(
                            item.patientName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ),
                        HithaStatusBadge(
                          status: item.status.value,
                          label: item.status.label,
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '#${item.bookingReference}',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF475569),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Icon(Icons.videocam_outlined, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        const Text(
                          'Video Telehealth',
                          style: TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          // Time & Price Info pill
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFEDF2F7)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded, size: 14, color: HithaColors.forest),
                    const SizedBox(width: 6),
                    Text(
                      formattedTime,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ],
                ),
                Text(
                  formatLkr(item.feeLkr),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: HithaColors.forest,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          // Actions Row
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              HithaCompactButton(
                text: 'View Dossier',
                isOutlined: true,
                onPressed: () => context.push('/doctor/bookings/${item.id}'),
              ),
              if (isUpcoming) ...[
                const SizedBox(width: 8),
                HithaCompactButton(
                  text: 'Enter Room',
                  icon: Icons.videocam,
                  backgroundColor: HithaColors.forest,
                  onPressed: () => context.push('/meeting/${item.id}'),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
