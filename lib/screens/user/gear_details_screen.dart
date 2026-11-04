import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/theme.dart';
import '../../models/gear_model.dart';
import 'booking_screen.dart';

class GearDetailsScreen extends StatefulWidget {
  final GearModel gear;
  final bool autoOpenRent;

  const GearDetailsScreen({super.key, required this.gear, this.autoOpenRent = false});

  @override
  State<GearDetailsScreen> createState() => _GearDetailsScreenState();
}

class _GearDetailsScreenState extends State<GearDetailsScreen> {
  String? _selectedSize;
  DateTime _startDate = DateTime.now().add(const Duration(days: 1));
  DateTime _endDate = DateTime.now().add(const Duration(days: 8));
  final int _quantity = 1;

  int get _numberOfDays => _endDate.difference(_startDate).inDays.abs() + 1;
  double get _rentalCost => widget.gear.pricePerDay * _numberOfDays * _quantity;
  double get _securityDeposit => widget.gear.pricePerDay * 4;
  double get _total => _rentalCost + _securityDeposit;

  @override
  void initState() {
    super.initState();
    if (widget.gear.sizes.isNotEmpty) {
      _selectedSize = widget.gear.sizes.first;
    }
    if (widget.autoOpenRent) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToRentSection());
    }
  }

  final GlobalKey _rentSectionKey = GlobalKey();

  void _scrollToRentSection() {
    final context = _rentSectionKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(context, duration: const Duration(milliseconds: 400));
    }
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.mountainBlue),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate.isBefore(_startDate.add(const Duration(days: 1)))) {
          _endDate = _startDate.add(const Duration(days: 1));
        }
      } else {
        _endDate = picked;
      }
    });
  }

  void _proceedToBooking() {
    if (_selectedSize == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a size'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookingScreen(
          gear: widget.gear,
          selectedSize: _selectedSize!,
          startDate: _startDate,
          endDate: _endDate,
          numberOfDays: _numberOfDays,
          pricePerDay: widget.gear.pricePerDay,
          securityDeposit: _securityDeposit,
          totalPrice: _total,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy');
    final gear = widget.gear;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: AppColors.surface,
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.arrow_back, size: 20, color: AppColors.darkCharcoal),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    gear.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(
                      color: AppColors.surfaceMuted,
                      child: const Icon(Icons.sports_motorsports, size: 80, color: AppColors.mountainBlue),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                          colors: [AppColors.background, Colors.transparent],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Category + Name
                Text(gear.category.label.toUpperCase(),
                    style: const TextStyle(
                        fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mountainBlue, letterSpacing: 0.5)),
                const SizedBox(height: 6),
                Text(gear.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal)),
                const SizedBox(height: 12),

                // Rating + Price Row
                Row(
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text('${gear.rating}',
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal)),
                        Text(' (${gear.reviewsCount} reviews)',
                            style: const TextStyle(fontSize: 13, color: AppColors.slate)),
                      ],
                    ),
                    const Spacer(),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text('₹${gear.pricePerDay.toInt()}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal)),
                        const Text('/day', style: TextStyle(fontSize: 13, color: AppColors.slate)),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Description
                Text(gear.description,
                    style: const TextStyle(fontSize: 14, color: AppColors.slate, height: 1.6)),
                const SizedBox(height: 20),

                // Features
                const Text('Features', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal)),
                const SizedBox(height: 10),
                ...gear.features.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.successLight),
                            child: const Icon(Icons.check, size: 13, color: AppColors.success),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(f,
                                style: const TextStyle(fontSize: 14, color: AppColors.darkCharcoal)),
                          ),
                        ],
                      ),
                    )),

                const SizedBox(height: 24),

                // Booking Section
                Container(
                  key: _rentSectionKey,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Book This Gear',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal)),
                      const SizedBox(height: 16),

                      // Size Selection
                      const Text('Select Size', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkCharcoal)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: gear.sizes.map((size) {
                          final isSelected = _selectedSize == size;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedSize = size),
                            child: Container(
                              width: 56,
                              height: 40,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.mountainBlue : AppColors.surface,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                    color: isSelected ? AppColors.mountainBlue : AppColors.border,
                                    width: isSelected ? 2 : 1),
                              ),
                              child: Text(
                                size,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected ? Colors.white : AppColors.darkCharcoal,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 16),

                      // Date Selection
                      Row(
                        children: [
                          Expanded(child: _buildDateTile('Start Date', df.format(_startDate), () => _pickDate(true))),
                          const SizedBox(width: 12),
                          Expanded(child: _buildDateTile('End Date', df.format(_endDate), () => _pickDate(false))),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Duration badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.mountainBlueLight,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.timelapse, size: 16, color: AppColors.mountainBlue),
                            const SizedBox(width: 8),
                            Text('$_numberOfDays days',
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.mountainBlue)),
                            const Spacer(),
                            Text('₹${gear.pricePerDay.toInt()} × $_numberOfDays days',
                                style: const TextStyle(fontSize: 13, color: AppColors.mountainBlue)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Price Breakdown
                      _buildPriceRow('Rental Cost', '₹${_rentalCost.toInt()}'),
                      _buildPriceRow('Security Deposit', '₹${_securityDeposit.toInt()}', isSubtle: true),
                      const Divider(height: 20),
                      _buildPriceRow('Total', '₹${_total.toInt()}', isTotal: true),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: gear.isAvailable ? _proceedToBooking : null,
                          icon: const Icon(Icons.shopping_bag_outlined),
                          label: const Text('Rent Now'),
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                        ),
                      ),

                      if (!gear.isAvailable) ...[
                        const SizedBox(height: 10),
                        const Text(
                          '⚠ This item is currently unavailable. Check back soon!',
                          style: TextStyle(fontSize: 13, color: AppColors.warning),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTile(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.slate)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: AppColors.mountainBlue),
                const SizedBox(width: 6),
                Text(value,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isSubtle = false, bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontSize: isTotal ? 15 : 13,
                  fontWeight: isTotal ? FontWeight.w800 : FontWeight.w500,
                  color: isSubtle ? AppColors.slate : (isTotal ? AppColors.darkCharcoal : AppColors.darkCharcoal))),
          Text(value,
              style: TextStyle(
                  fontSize: isTotal ? 15 : 13,
                  fontWeight: FontWeight.w700,
                  color: isTotal ? AppColors.mountainBlue : AppColors.darkCharcoal)),
        ],
      ),
    );
  }
}
