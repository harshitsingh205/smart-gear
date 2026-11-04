import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../services/booking_service.dart';
import '../../widgets/stat_card.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bookingService = BookingService();

    final allBookings = bookingService.allBookings;
    final totalRevenue = allBookings.fold<double>(0, (sum, b) => sum + b.totalPrice);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
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
                      'Fleet Analytics & Intelligence',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkCharcoal,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Comprehensive telemetry on rental duration, revenue velocity, and fleet wear',
                      style: TextStyle(fontSize: 13, color: AppColors.slate),
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
                  // Top Metrics Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isWide = constraints.maxWidth >= 900;
                      final isMed = constraints.maxWidth >= 600;
                      final cols = isWide ? 4 : (isMed ? 2 : 1);

                      return GridView.count(
                        crossAxisCount: cols,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisSpacing: 16,
                        mainAxisSpacing: 16,
                        childAspectRatio: isWide ? 1.6 : 2.0,
                        children: [
                          const StatCard(
                            title: 'Avg Rental Duration',
                            value: '7.2 Days',
                            subtitle: 'Leh-Manali expedition standard',
                            icon: Icons.date_range,
                            iconColor: AppColors.mountainBlue,
                            iconBackgroundColor: AppColors.mountainBlueLight,
                            trendText: '+1.1d vs 2025',
                            isTrendPositive: true,
                          ),
                          const StatCard(
                            title: 'Fleet Utilization',
                            value: '82.6%',
                            subtitle: 'Peak season occupancy',
                            icon: Icons.pie_chart_outline,
                            iconColor: AppColors.success,
                            iconBackgroundColor: AppColors.successLight,
                            trendText: 'Optimal buffer held',
                            isTrendPositive: true,
                          ),
                          const StatCard(
                            title: 'Repeat Tourist Rate',
                            value: '36.4%',
                            subtitle: 'Annual multi-circuit riders',
                            icon: Icons.sync,
                            iconColor: AppColors.accent,
                            iconBackgroundColor: AppColors.mountainBlueLight,
                            trendText: '+5.2% referral gain',
                            isTrendPositive: true,
                          ),
                          StatCard(
                            title: 'Avg Order Value',
                            value: '₹${(totalRevenue / (allBookings.isEmpty ? 1 : allBookings.length)).toStringAsFixed(0)}',
                            subtitle: 'Includes deposit coverage',
                            icon: Icons.payments_outlined,
                            iconColor: AppColors.mountainBlueDark,
                            iconBackgroundColor: AppColors.mountainBlueLight,
                            trendText: '+14.8% bundle uptake',
                            isTrendPositive: true,
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 24),

                  // Revenue & Seasonal Demand Trend
                  _buildRevenueBarChart(),

                  const SizedBox(height: 24),

                  // Circuits & Sizing Split Row
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isDesktop = constraints.maxWidth >= 860;
                      if (isDesktop) {
                        return const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _CircuitSplitCard()),
                            SizedBox(width: 20),
                            Expanded(child: _SizingDistributionCard()),
                          ],
                        );
                      } else {
                        return const Column(
                          children: [
                            _CircuitSplitCard(),
                            SizedBox(height: 20),
                            _SizingDistributionCard(),
                          ],
                        );
                      }
                    },
                  ),

                  const SizedBox(height: 24),

                  // Fleet Quality & Safety Record Card
                  _buildSafetyMetricCard(),

                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRevenueBarChart() {
    final months = [
      {'label': 'May', 'revenue': 1.8, 'bookings': 240},
      {'label': 'Jun', 'revenue': 3.6, 'bookings': 480},
      {'label': 'Jul', 'revenue': 5.2, 'bookings': 720},
      {'label': 'Aug', 'revenue': 4.7, 'bookings': 650},
      {'label': 'Sep', 'revenue': 3.1, 'bookings': 420},
      {'label': 'Oct', 'revenue': 1.2, 'bookings': 180},
    ];

    const maxRev = 6.0;

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
                    'Monthly Revenue Velocity (₹ Lakhs)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal),
                  ),
                  SizedBox(height: 4),
                  Text('Correlated with Khardung La & Rohtang Pass highway openings', style: TextStyle(fontSize: 12, color: AppColors.slate)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(6)),
                child: const Text('Peak Q3 Surge', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 180,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: months.map((m) {
                final rev = m['revenue'] as double;
                final factor = (rev / maxRev).clamp(0.08, 1.0);
                final isPeak = rev >= 4.0;

                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text('₹${rev}L', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isPeak ? AppColors.mountainBlueDark : AppColors.slate)),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: FractionallySizedBox(
                              heightFactor: factor,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isPeak ? AppColors.mountainBlue : AppColors.mountainBlue.withValues(alpha: 0.4),
                                  borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(m['label'] as String, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyMetricCard() {
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
              Icon(Icons.health_and_safety, color: AppColors.success, size: 22),
              SizedBox(width: 8),
              Text(
                'Fleet Safety & Equipment Health Telemetry',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Sanitization protocols, CE armor impact logs, and post-ride inspection grades',
            style: TextStyle(fontSize: 12, color: AppColors.slate),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _metricHighlight('96.4%', 'Undamaged Return Rate', 'Full deposit released'),
              ),
              Expanded(
                child: _metricHighlight('100%', 'UV & Ozone Sanitized', 'Pre-dispatch protocol'),
              ),
              Expanded(
                child: _metricHighlight('0.8%', 'Armor Replacement', 'Post-impact CE retirement'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricHighlight(String value, String title, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.mountainBlueDark)),
          const SizedBox(height: 4),
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 10, color: AppColors.slate)),
        ],
      ),
    );
  }
}

class _CircuitSplitCard extends StatelessWidget {
  const _CircuitSplitCard();

  @override
  Widget build(BuildContext context) {
    final circuits = [
      {'name': 'Leh - Ladakh Circuit', 'share': 0.64, 'color': AppColors.mountainBlue},
      {'name': 'Spiti Valley Circuit', 'share': 0.22, 'color': AppColors.accent},
      {'name': 'Manali - Rohtang Loop', 'share': 0.10, 'color': AppColors.success},
      {'name': 'Rishikesh - Uttarkashi', 'share': 0.04, 'color': AppColors.warning},
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
          const Text('Rental Volume by Tourist Destination', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Expedition circuits with highest gear demand', style: TextStyle(fontSize: 12, color: AppColors.slate)),
          const SizedBox(height: 20),
          ...circuits.map((c) {
            final share = c['share'] as double;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(c['name'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      Text('${(share * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.slate)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: share,
                      minHeight: 6,
                      backgroundColor: AppColors.surfaceMuted,
                      valueColor: AlwaysStoppedAnimation<Color>(c['color'] as Color),
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

class _SizingDistributionCard extends StatelessWidget {
  const _SizingDistributionCard();

  @override
  Widget build(BuildContext context) {
    final sizes = [
      {'size': 'Size L (Large)', 'share': 0.42, 'color': AppColors.mountainBlue},
      {'size': 'Size M (Medium)', 'share': 0.30, 'color': AppColors.mountainBlueDark},
      {'size': 'Size XL (Extra Large)', 'share': 0.18, 'color': AppColors.accent},
      {'size': 'Size S (Small)', 'share': 0.06, 'color': AppColors.slate},
      {'size': 'Size XXL', 'share': 0.04, 'color': AppColors.slate.withValues(alpha: 0.5)},
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
          const Text('Rider Anthropometric Sizing Distribution', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Guides seasonal purchase procurement split', style: TextStyle(fontSize: 12, color: AppColors.slate)),
          const SizedBox(height: 20),
          ...sizes.map((s) {
            final share = s['share'] as double;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(s['size'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                      Text('${(share * 100).toInt()}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.slate)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: share,
                      minHeight: 6,
                      backgroundColor: AppColors.surfaceMuted,
                      valueColor: AlwaysStoppedAnimation<Color>(s['color'] as Color),
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
