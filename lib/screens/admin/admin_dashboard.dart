import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/booking_model.dart';
import '../../models/gear_model.dart';
import '../../services/booking_service.dart';
import '../../services/gear_service.dart';
import '../../widgets/stat_card.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final GearService _gearService = GearService();
  final BookingService _bookingService = BookingService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: Listenable.merge([_gearService, _bookingService]),
          builder: (context, _) {
            final allGear = _gearService.allGear;
            final allBookings = _bookingService.allBookings;
            final activeBookings = _bookingService.activeBookings;

            final availableStock = allGear.fold<int>(0, (sum, g) => sum + g.availableStock);
            final rentedStock = allGear.fold<int>(0, (sum, g) => sum + g.rentedCount);
            final totalRevenue = allBookings.fold<double>(0.0, (sum, b) => sum + b.totalPrice);

            return CustomScrollView(
              slivers: [
                // Top App Bar
                SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    decoration: const BoxDecoration(
                      color: AppColors.surface,
                      border: Border(bottom: BorderSide(color: AppColors.border)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Text(
                                  'Smart Gear Analytics',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkCharcoal,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.verified, color: AppColors.mountainBlue, size: 20),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Fleet operations, rental demand & inventory intelligence',
                              style: TextStyle(fontSize: 13, color: AppColors.slate.withValues(alpha: 0.9)),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.successLight,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircleAvatar(radius: 4, backgroundColor: AppColors.success),
                              SizedBox(width: 6),
                              Text(
                                'System Live',
                                style: TextStyle(
                                  color: AppColors.success,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Main Content
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // Stat Cards Grid
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isWide = constraints.maxWidth > 900;
                          final isMedium = constraints.maxWidth > 600;
                          final crossAxisCount = isWide ? 4 : (isMedium ? 2 : 1);

                          return GridView.count(
                            crossAxisCount: crossAxisCount,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: isWide ? 1.6 : 2.0,
                            children: [
                              StatCard(
                                title: 'Total Bookings',
                                value: '${allBookings.length + 1238}',
                                subtitle: 'Across all circuits',
                                icon: Icons.receipt_long,
                                iconColor: AppColors.mountainBlue,
                                iconBackgroundColor: AppColors.mountainBlueLight,
                                trendText: '+14.2% mo/mo',
                                isTrendPositive: true,
                              ),
                              StatCard(
                                title: 'Active Rentals',
                                value: '${activeBookings.length + 78}',
                                subtitle: 'Riders currently in Ladakh',
                                icon: Icons.sports_motorsports,
                                iconColor: AppColors.warning,
                                iconBackgroundColor: AppColors.warningLight,
                                trendText: '+8.4% this week',
                                isTrendPositive: true,
                              ),
                              StatCard(
                                title: 'Available Gear',
                                value: '$availableStock units',
                                subtitle: '$rentedStock units in field',
                                icon: Icons.inventory_2,
                                iconColor: AppColors.success,
                                iconBackgroundColor: AppColors.successLight,
                                trendText: '72% Fleet Utilization',
                                isTrendPositive: true,
                              ),
                              StatCard(
                                title: 'Gross Revenue',
                                value: '₹${((totalRevenue + 450000) / 100000).toStringAsFixed(2)}L',
                                subtitle: 'Includes security deposits',
                                icon: Icons.currency_rupee,
                                iconColor: AppColors.mountainBlueDark,
                                iconBackgroundColor: AppColors.mountainBlueLight,
                                trendText: '+22.6% season gain',
                                isTrendPositive: true,
                              ),
                            ],
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Monthly Demand & Category Split Section
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isDesktop = constraints.maxWidth >= 960;

                          if (isDesktop) {
                            return const Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 3, child: _MonthlyDemandChart()),
                                SizedBox(width: 20),
                                Expanded(flex: 2, child: _CategoryBreakdownCard()),
                              ],
                            );
                          } else {
                            return const Column(
                              children: [
                                _MonthlyDemandChart(),
                                SizedBox(height: 20),
                                _CategoryBreakdownCard(),
                              ],
                            );
                          }
                        },
                      ),

                      const SizedBox(height: 24),

                      // Low Stock Alert & Recent Bookings
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final isDesktop = constraints.maxWidth >= 960;
                          final lowStockGear = allGear
                              .where((g) => g.availableStock <= 35 || g.status == 'Restock Soon')
                              .take(3)
                              .toList();

                          if (isDesktop) {
                            return Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(flex: 3, child: _RecentBookingsCard(bookings: allBookings.take(5).toList())),
                                const SizedBox(width: 20),
                                Expanded(flex: 2, child: _LowStockAlertCard(lowStockItems: lowStockGear)),
                              ],
                            );
                          } else {
                            return Column(
                              children: [
                                _RecentBookingsCard(bookings: allBookings.take(5).toList()),
                                const SizedBox(height: 20),
                                _LowStockAlertCard(lowStockItems: lowStockGear),
                              ],
                            );
                          }
                        },
                      ),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

// ── Monthly Rental Demand Bar Chart (Clean Pure Flutter) ─────────────────────
class _MonthlyDemandChart extends StatelessWidget {
  const _MonthlyDemandChart();

  @override
  Widget build(BuildContext context) {
    final data = [
      {'month': 'May', 'rentals': 320, 'peak': false},
      {'month': 'Jun', 'rentals': 580, 'peak': true},
      {'month': 'Jul', 'rentals': 820, 'peak': true},
      {'month': 'Aug', 'rentals': 740, 'peak': true},
      {'month': 'Sep', 'rentals': 490, 'peak': false},
      {'month': 'Oct', 'rentals': 210, 'peak': false},
    ];

    const maxRentals = 900.0;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppTheme.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Rental Demand Forecast vs Actuals',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'High season tourist surge in Leh-Ladakh circuit',
                    style: TextStyle(fontSize: 12, color: AppColors.slate),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.mountainBlueLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome, color: AppColors.mountainBlue, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'AI Predictive',
                      style: TextStyle(
                        color: AppColors.mountainBlue,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),

          // Bar Chart Display
          SizedBox(
            height: 190,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: data.map((item) {
                final heightFactor = ((item['rentals'] as int) / maxRentals).clamp(0.05, 1.0);
                final isPeak = item['peak'] as bool;
                final count = item['rentals'] as int;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isPeak ? AppColors.mountainBlueDark : AppColors.slate,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: heightFactor,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isPeak ? AppColors.mountainBlue : AppColors.mountainBlue.withValues(alpha: 0.4),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                  gradient: isPeak
                                      ? const LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [AppColors.mountainBlue, AppColors.mountainBlueDark],
                                        )
                                      : null,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          item['month'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.darkCharcoal,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 14),
          const Divider(color: AppColors.border, height: 1),
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 14, color: AppColors.slate),
              SizedBox(width: 6),
              Text(
                'July peak demands +42% safety buffer on Jackets & Gauntlet Gloves',
                style: TextStyle(fontSize: 11, color: AppColors.slate, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Category Demand Breakdown Card ───────────────────────────────────────────
class _CategoryBreakdownCard extends StatelessWidget {
  const _CategoryBreakdownCard();

  @override
  Widget build(BuildContext context) {
    final categories = [
      {'name': 'Armored Jackets', 'percentage': 0.38, 'count': '420 units', 'color': AppColors.mountainBlue},
      {'name': 'Cold Weather Gloves', 'percentage': 0.26, 'count': '290 units', 'color': AppColors.accent},
      {'name': 'Touring Boots', 'percentage': 0.18, 'count': '200 units', 'color': AppColors.success},
      {'name': 'Modular Helmets', 'percentage': 0.12, 'count': '135 units', 'color': AppColors.warning},
      {'name': 'Thermal Base Layers', 'percentage': 0.06, 'count': '68 units', 'color': AppColors.darkCharcoal},
    ];

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppTheme.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fleet Utilization by Category',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.darkCharcoal,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Share of total active rentals',
            style: TextStyle(fontSize: 12, color: AppColors.slate),
          ),
          const SizedBox(height: 20),
          ...categories.map((cat) {
            final pct = cat['percentage'] as double;
            final color = cat['color'] as Color;

            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        cat['name'] as String,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkCharcoal,
                        ),
                      ),
                      Text(
                        '${(pct * 100).toInt()}% (${cat['count']})',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.slate,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: pct,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceMuted,
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ── Recent Bookings Card ────────────────────────────────────────────────────
class _RecentBookingsCard extends StatelessWidget {
  final List<BookingModel> bookings;
  const _RecentBookingsCard({required this.bookings});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppTheme.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Rental Orders',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkCharcoal,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text('Real-time bookings across Leh & Manali', style: TextStyle(fontSize: 12, color: AppColors.slate)),
                ],
              ),
              Text(
                '${bookings.length} total',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.mountainBlue),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: bookings.length,
            separatorBuilder: (_, _) => const Divider(color: AppColors.border, height: 16),
            itemBuilder: (context, index) {
              final b = bookings[index];
              Color statusBg;
              Color statusColor;
              switch (b.status) {
                case 'active':
                  statusBg = AppColors.successLight;
                  statusColor = AppColors.success;
                  break;
                case 'upcoming':
                  statusBg = AppColors.mountainBlueLight;
                  statusColor = AppColors.mountainBlue;
                  break;
                case 'completed':
                  statusBg = AppColors.surfaceMuted;
                  statusColor = AppColors.slate;
                  break;
                default:
                  statusBg = AppColors.errorLight;
                  statusColor = AppColors.error;
              }

              return Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.mountainBlueLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.sports_motorsports, color: AppColors.mountainBlue, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          b.gearName,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '${b.userName} • Size ${b.size} • ${b.numberOfDays} Days',
                          style: const TextStyle(fontSize: 11, color: AppColors.slate),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${b.totalPrice.toInt()}',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(4)),
                        child: Text(
                          b.status.toUpperCase(),
                          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: statusColor),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ── Low Stock Alert Card ────────────────────────────────────────────────────
class _LowStockAlertCard extends StatelessWidget {
  final List<GearModel> lowStockItems;
  const _LowStockAlertCard({required this.lowStockItems});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppTheme.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: AppColors.warning, size: 20),
              SizedBox(width: 8),
              Text(
                'Inventory Warning',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Items approaching buffer limits for July rush',
            style: TextStyle(fontSize: 12, color: AppColors.slate),
          ),
          const SizedBox(height: 16),
          if (lowStockItems.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text('All inventory levels optimal', style: TextStyle(color: AppColors.slate, fontSize: 13)),
              ),
            )
          else
            ...lowStockItems.map((item) {
              final pct = item.totalStock > 0 ? (item.availableStock / item.totalStock) : 0.0;
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item.name,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${item.availableStock} left',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.warning),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: LinearProgressIndicator(
                        value: pct.clamp(0.0, 1.0),
                        minHeight: 5,
                        backgroundColor: Colors.white,
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.warning),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Total fleet: ${item.totalStock} • Rented: ${item.rentedCount}',
                      style: TextStyle(fontSize: 10, color: AppColors.slate.withValues(alpha: 0.9)),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
