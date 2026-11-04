import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../services/booking_service.dart';
import '../../widgets/booking_card.dart';
import '../../models/booking_model.dart';

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _cancelBooking(String id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cancel Booking', style: TextStyle(fontWeight: FontWeight.w800)),
        content: const Text('Are you sure you want to cancel this booking?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Keep Booking')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Yes, Cancel'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      BookingService().cancelBooking(id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Booking cancelled successfully'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
        );
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final svc = BookingService();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Bookings'),
        automaticallyImplyLeading: false,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.mountainBlue,
          unselectedLabelColor: AppColors.slate,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          indicatorColor: AppColors.mountainBlue,
          indicatorWeight: 2.5,
          tabs: [
            Tab(text: 'Upcoming (${svc.upcomingBookings.length})'),
            Tab(text: 'Active (${svc.activeBookings.length})'),
            const Tab(text: 'Completed'),
            const Tab(text: 'Cancelled'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _BookingList(
            bookings: svc.upcomingBookings,
            emptyMessage: 'No upcoming bookings',
            emptySubtitle: 'Book your riding gear for the next adventure!',
            onCancel: _cancelBooking,
          ),
          _BookingList(
            bookings: svc.activeBookings,
            emptyMessage: 'No active rentals',
            emptySubtitle: 'Your active gear rentals will appear here.',
          ),
          _BookingList(
            bookings: svc.completedBookings,
            emptyMessage: 'No completed bookings',
            emptySubtitle: 'Your rental history will appear here after trips.',
          ),
          _BookingList(
            bookings: svc.cancelledBookings,
            emptyMessage: 'No cancelled bookings',
            emptySubtitle: 'Cancelled rentals appear here.',
          ),
        ],
      ),
    );
  }
}

class _BookingList extends StatelessWidget {
  final List<BookingModel> bookings;
  final String emptyMessage;
  final String emptySubtitle;
  final Function(String)? onCancel;

  const _BookingList({
    required this.bookings,
    required this.emptyMessage,
    required this.emptySubtitle,
    this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    if (bookings.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_outlined, size: 64, color: AppColors.slate.withValues(alpha: 0.4)),
              const SizedBox(height: 16),
              Text(emptyMessage,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal)),
              const SizedBox(height: 8),
              Text(emptySubtitle,
                  style: const TextStyle(fontSize: 14, color: AppColors.slate),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: bookings.length,
      itemBuilder: (context, index) {
        final booking = bookings[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: BookingCard(
            booking: booking,
            onViewDetails: () => _showDetails(context, booking),
            onCancelBooking: onCancel != null ? () => onCancel!(booking.id) : null,
          ),
        );
      },
    );
  }

  void _showDetails(BuildContext context, BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            Text(booking.id,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal)),
            const SizedBox(height: 16),
            _detailRow('Gear', booking.gearName),
            _detailRow('Category', booking.gearCategory),
            _detailRow('Size', booking.size),
            _detailRow('Status', booking.status.toUpperCase()),
            _detailRow('Pickup', booking.pickupLocation),
            _detailRow('Total', '₹${booking.totalPrice.toInt()}'),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          SizedBox(width: 80, child: Text(label, style: const TextStyle(color: AppColors.slate, fontSize: 13))),
          Expanded(child: Text(value,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.darkCharcoal))),
        ],
      ),
    );
  }
}
