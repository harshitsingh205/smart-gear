import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/theme.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';

class BookingsManagement extends StatefulWidget {
  const BookingsManagement({super.key});

  @override
  State<BookingsManagement> createState() => _BookingsManagementState();
}

class _BookingsManagementState extends State<BookingsManagement> with SingleTickerProviderStateMixin {
  final BookingService _bookingService = BookingService();
  late TabController _tabController;
  String _searchQuery = '';

  final List<String> _tabs = ['All', 'Upcoming', 'Active', 'Completed', 'Cancelled'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<BookingModel> _filterBookings(List<BookingModel> list, String tab) {
    return list.where((b) {
      if (tab != 'All' && b.status.toLowerCase() != tab.toLowerCase()) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchId = b.id.toLowerCase().contains(q);
        final matchUser = b.userName.toLowerCase().contains(q);
        final matchGear = b.gearName.toLowerCase().contains(q);
        if (!matchId && !matchUser && !matchGear) return false;
      }
      return true;
    }).toList();
  }

  void _showBookingDetails(BookingModel b) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(b.id, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.mountainBlue)),
                    const SizedBox(height: 2),
                    Text('Booked by ${b.userName}', style: const TextStyle(color: AppColors.slate, fontSize: 13)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusBg(b.status),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    b.status.toUpperCase(),
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: _statusColor(b.status)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _detailRow('Rented Item', b.gearName),
                  const Divider(color: AppColors.border, height: 16),
                  _detailRow('Size Allocated', b.size),
                  const Divider(color: AppColors.border, height: 16),
                  _detailRow('Dates', '${dateFormat.format(b.startDate)} - ${dateFormat.format(b.endDate)} (${b.numberOfDays} days)'),
                  const Divider(color: AppColors.border, height: 16),
                  _detailRow('Pickup Hub', b.pickupLocation),
                  const Divider(color: AppColors.border, height: 16),
                  _detailRow('Daily Rental Rate', '₹${b.pricePerDay.toInt()} / day'),
                  const Divider(color: AppColors.border, height: 16),
                  _detailRow('Security Deposit', '₹${b.securityDeposit.toInt()} (Refundable)'),
                  const Divider(color: AppColors.border, height: 16),
                  _detailRow('Total Paid', '₹${b.totalPrice.toInt()}', isBold: true),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                if (b.status == 'upcoming')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _bookingService.updateBookingStatus(b.id, 'active');
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Gear handed over! Status updated to Active.'), backgroundColor: AppColors.success),
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Handover Gear (Active)'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.mountainBlue),
                    ),
                  ),
                if (b.status == 'active')
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _bookingService.updateBookingStatus(b.id, 'completed');
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Gear returned! Deposit released to customer.'), backgroundColor: AppColors.success),
                        );
                      },
                      icon: const Icon(Icons.assignment_turned_in, size: 18),
                      label: const Text('Accept Return & Refund Deposit'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.success),
                    ),
                  ),
                if (b.status != 'cancelled' && b.status != 'completed') ...[
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: () {
                      _bookingService.cancelBooking(b.id);
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Booking marked as cancelled.'), backgroundColor: AppColors.error),
                      );
                    },
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                    child: const Text('Cancel Booking'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.slate)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
            color: isBold ? AppColors.mountainBlueDark : AppColors.darkCharcoal,
          ),
        ),
      ],
    );
  }

  Color _statusBg(String status) {
    switch (status) {
      case 'active':
        return AppColors.successLight;
      case 'upcoming':
        return AppColors.mountainBlueLight;
      case 'completed':
        return AppColors.surfaceMuted;
      default:
        return AppColors.errorLight;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'active':
        return AppColors.success;
      case 'upcoming':
        return AppColors.mountainBlue;
      case 'completed':
        return AppColors.slate;
      default:
        return AppColors.error;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM dd');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _bookingService,
          builder: (context, _) {
            final allBookings = _bookingService.allBookings;
            final activeCount = _bookingService.activeBookings.length;
            final upcomingCount = _bookingService.upcomingBookings.length;
            final totalDeposits = allBookings
                .where((b) => b.status == 'active' || b.status == 'upcoming')
                .fold<double>(0.0, (sum, b) => sum + b.securityDeposit);

            return CustomScrollView(
              slivers: [
                // Header Bar
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(bottom: BorderSide(color: AppColors.border)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bookings & Dispatch Center',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: AppColors.darkCharcoal,
                            letterSpacing: -0.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Manage rider handovers, returns, and security deposit reconciliations',
                          style: TextStyle(fontSize: 13, color: AppColors.slate),
                        ),
                      ],
                    ),
                  ),
                ),

                // Summary KPI Row
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isWide = constraints.maxWidth >= 700;
                        return Row(
                          children: [
                            Expanded(child: _kpiMiniCard('Total Orders', '${allBookings.length}', Icons.receipt_long, AppColors.mountainBlue)),
                            const SizedBox(width: 12),
                            Expanded(child: _kpiMiniCard('Active Out', '$activeCount', Icons.directions_bike, AppColors.success)),
                            if (isWide) ...[
                              const SizedBox(width: 12),
                              Expanded(child: _kpiMiniCard('Awaiting Pickup', '$upcomingCount', Icons.hourglass_top, AppColors.warning)),
                              const SizedBox(width: 12),
                              Expanded(child: _kpiMiniCard('Held Deposits', '₹${totalDeposits.toInt()}', Icons.lock_clock, AppColors.mountainBlueDark)),
                            ],
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // Search & Filter Tabs
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          onChanged: (v) => setState(() => _searchQuery = v),
                          decoration: InputDecoration(
                            hintText: 'Search Booking ID (e.g. SG-2026-10245), Rider name or Gear...',
                            prefixIcon: const Icon(Icons.search, color: AppColors.slate),
                            filled: true,
                            fillColor: AppColors.surface,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: AppColors.border),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TabBar(
                          controller: _tabController,
                          isScrollable: true,
                          labelColor: AppColors.mountainBlue,
                          unselectedLabelColor: AppColors.slate,
                          indicatorColor: AppColors.mountainBlue,
                          indicatorWeight: 3,
                          tabs: _tabs.map((tab) => Tab(text: tab)).toList(),
                          onTap: (_) => setState(() {}),
                        ),
                      ],
                    ),
                  ),
                ),

                // List of Bookings for selected tab
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final currentTab = _tabs[_tabController.index];
                        final filtered = _filterBookings(allBookings, currentTab);

                        if (filtered.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(40),
                            decoration: BoxDecoration(
                              color: AppColors.surface,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Center(
                              child: Column(
                                children: [
                                  Icon(Icons.inbox_outlined, size: 48, color: AppColors.slate),
                                  SizedBox(height: 12),
                                  Text(
                                    'No bookings found under this filter',
                                    style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.slate),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        final b = filtered[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: AppColors.border),
                            boxShadow: [AppTheme.softShadow],
                          ),
                          child: InkWell(
                            onTap: () => _showBookingDetails(b),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: _statusBg(b.status),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.sports_motorsports, color: _statusColor(b.status), size: 24),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            b.id,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w800,
                                              fontSize: 13,
                                              color: AppColors.mountainBlue,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: _statusBg(b.status),
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              b.status.toUpperCase(),
                                              style: TextStyle(
                                                fontSize: 9,
                                                fontWeight: FontWeight.w800,
                                                color: _statusColor(b.status),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        b.gearName,
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.darkCharcoal),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Rider: ${b.userName} • Size ${b.size} • ${dateFormat.format(b.startDate)} - ${dateFormat.format(b.endDate)}',
                                        style: const TextStyle(fontSize: 12, color: AppColors.slate),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      '₹${b.totalPrice.toInt()}',
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal),
                                    ),
                                    Text(
                                      'Deposit: ₹${b.securityDeposit.toInt()}',
                                      style: const TextStyle(fontSize: 10, color: AppColors.slate),
                                    ),
                                    const SizedBox(height: 6),
                                    const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.slate),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      childCount: _filterBookings(allBookings, _tabs[_tabController.index]).isEmpty
                          ? 1
                          : _filterBookings(allBookings, _tabs[_tabController.index]).length,
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 40)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _kpiMiniCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal)),
                Text(label, style: const TextStyle(fontSize: 11, color: AppColors.slate), maxLines: 1, overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
