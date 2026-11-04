import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/theme.dart';
import '../../models/gear_model.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../models/booking_model.dart';

class BookingScreen extends StatefulWidget {
  final GearModel gear;
  final String selectedSize;
  final DateTime startDate;
  final DateTime endDate;
  final int numberOfDays;
  final double pricePerDay;
  final double securityDeposit;
  final double totalPrice;

  const BookingScreen({
    super.key,
    required this.gear,
    required this.selectedSize,
    required this.startDate,
    required this.endDate,
    required this.numberOfDays,
    required this.pricePerDay,
    required this.securityDeposit,
    required this.totalPrice,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  bool _isConfirming = false;
  BookingModel? _confirmedBooking;

  Future<void> _confirmBooking() async {
    setState(() => _isConfirming = true);
    await Future.delayed(const Duration(milliseconds: 800));
    final user = AuthService().currentUser;
    final booking = BookingService().createBooking(
      userId: user?.id ?? 'guest',
      userName: user?.name ?? 'Guest Rider',
      gearId: widget.gear.id,
      gearName: widget.gear.name,
      gearCategory: widget.gear.category.label,
      size: widget.selectedSize,
      startDate: widget.startDate,
      endDate: widget.endDate,
      pricePerDay: widget.pricePerDay,
      securityDeposit: widget.securityDeposit,
      imageUrl: widget.gear.imageUrl,
    );
    if (!mounted) return;
    setState(() {
      _isConfirming = false;
      _confirmedBooking = booking;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_confirmedBooking != null) {
      return _ConfirmationScreen(booking: _confirmedBooking!);
    }

    final df = DateFormat('dd MMM yyyy');
    final gear = widget.gear;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Confirm Booking'),
        leading: const BackButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gear Info Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [AppTheme.softShadow],
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SizedBox(
                      width: 80,
                      height: 80,
                      child: Image.network(
                        gear.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: AppColors.surfaceMuted,
                          child: const Icon(Icons.sports_motorsports, color: AppColors.mountainBlue),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(gear.category.label.toUpperCase(),
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mountainBlue, letterSpacing: 0.5)),
                        const SizedBox(height: 4),
                        Text(gear.name,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal),
                            maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceMuted,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('Size: ${widget.selectedSize}',
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.darkCharcoal)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Rental Period
            _buildSection('Rental Period', [
              _buildInfoRow(Icons.calendar_today_outlined, 'Start Date', df.format(widget.startDate)),
              _buildInfoRow(Icons.calendar_today, 'End Date', df.format(widget.endDate)),
              _buildInfoRow(Icons.timelapse, 'Duration', '${widget.numberOfDays} Days'),
              _buildInfoRow(Icons.location_on_outlined, 'Pickup', 'Leh Adventure Hub, Fort Road'),
            ]),
            const SizedBox(height: 20),

            // Price Breakdown
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Price Breakdown',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal)),
                  const SizedBox(height: 14),
                  _buildPriceRow('Rental Cost',
                      '₹${widget.pricePerDay.toInt()} × ${widget.numberOfDays} days',
                      '₹${(widget.pricePerDay * widget.numberOfDays).toInt()}'),
                  _buildPriceRow('Security Deposit',
                      'Refundable on return',
                      '₹${widget.securityDeposit.toInt()}'),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Amount',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal)),
                      Text('₹${widget.totalPrice.toInt()}',
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.mountainBlue)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Policies
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: AppColors.warning),
                      SizedBox(width: 8),
                      Text('Booking Policy', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.warning)),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('• Security deposit refunded within 24hrs of return\n'
                      '• Free cancellation up to 48 hours before pickup\n'
                      '• Valid ID required at pickup\n'
                      '• Gear must be returned in same condition',
                      style: TextStyle(fontSize: 12, color: AppColors.darkCharcoal, height: 1.6)),
                ],
              ),
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isConfirming ? null : _confirmBooking,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _isConfirming
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Confirm Booking', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Back to Gear'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal)),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.mountainBlue),
          const SizedBox(width: 10),
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.slate)),
          const Spacer(),
          Text(value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal)),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String subtitle, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkCharcoal)),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.slate)),
              ],
            ),
          ),
          Text(value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal)),
        ],
      ),
    );
  }
}

// ── Booking Confirmation Screen ──────────────────────────────────────────────
class _ConfirmationScreen extends StatelessWidget {
  final BookingModel booking;

  const _ConfirmationScreen({required this.booking});

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy');

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),

              // Success Icon
              Container(
                width: 96,
                height: 96,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.successLight,
                ),
                child: const Icon(Icons.check_circle, color: AppColors.success, size: 56),
              ),
              const SizedBox(height: 24),

              const Text('Booking Confirmed!',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal)),
              const SizedBox(height: 8),
              const Text('Your gear will be ready for pickup.',
                  style: TextStyle(fontSize: 15, color: AppColors.slate), textAlign: TextAlign.center),

              const SizedBox(height: 32),

              // Booking Details Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [AppTheme.softShadow],
                ),
                child: Column(
                  children: [
                    // Booking ID with Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: AppColors.mountainBlueLight,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.receipt, size: 18, color: AppColors.mountainBlue),
                          const SizedBox(width: 8),
                          Text(booking.id,
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.mountainBlue)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _detailRow('Gear', booking.gearName),
                    _detailRow('Size', booking.size),
                    _detailRow('Pickup', booking.pickupLocation),
                    _detailRow('Date', df.format(booking.startDate)),
                    _detailRow('Return', df.format(booking.endDate)),
                    _detailRow('Duration', '${booking.numberOfDays} Days'),
                    const Divider(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Paid',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal)),
                        Text('₹${booking.totalPrice.toInt()}',
                            style: const TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.mountainBlue)),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: const Text('Back to Home', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 90,
            child: Text(label, style: const TextStyle(fontSize: 13, color: AppColors.slate)),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal)),
          ),
        ],
      ),
    );
  }
}
