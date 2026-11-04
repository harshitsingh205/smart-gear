import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/gear_model.dart';
import '../../services/gear_service.dart';

class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen> {
  final GearService _gearService = GearService();

  void _applySinglePrice(GearModel gear) {
    if (gear.suggestedPrice <= 0) return;
    _gearService.updatePrice(gear.id, gear.suggestedPrice);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Updated "${gear.name}" rate to ₹${gear.suggestedPrice.toInt()}/day.'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  void _applyAllSuggestedPrices() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.mountainBlue),
            SizedBox(width: 8),
            Text('Apply AI Pricing Rates?', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          ],
        ),
        content: const Text(
          'This will update daily rental rates across all inventory items to match AI-recommended peak season demand yield. You can still manually adjust rates at any time.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel', style: TextStyle(color: AppColors.slate))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.mountainBlue),
            onPressed: () {
              _gearService.applyAllSuggestedPrices();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Applied all AI suggested pricing rates across active catalog!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Confirm & Apply All'),
          ),
        ],
      ),
    );
  }

  void _editCustomPrice(GearModel gear) {
    final ctrl = TextEditingController(text: gear.pricePerDay.toInt().toString());
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Custom Rate: ${gear.name}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Enter new daily rental rate (₹):', style: TextStyle(fontSize: 13, color: AppColors.slate)),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                prefixText: '₹ ',
                labelText: 'Price Per Day',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newRate = double.tryParse(ctrl.text);
              if (newRate != null && newRate > 0) {
                _gearService.updatePrice(gear.id, newRate);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Price updated to ₹${newRate.toInt()}/day.'), backgroundColor: AppColors.success),
                );
              }
            },
            child: const Text('Save Rate'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListenableBuilder(
          listenable: _gearService,
          builder: (context, _) {
            final allGear = _gearService.allGear;

            return CustomScrollView(
              slivers: [
                // Top Header Bar
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
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Dynamic Pricing & Yield Optimization',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.darkCharcoal,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Icon(Icons.sell_outlined, color: AppColors.mountainBlue, size: 20),
                              ],
                            ),
                            SizedBox(height: 4),
                            Text(
                              'AI-recommended rates balancing tourist demand peaks, pass conditions, and fleet availability',
                              style: TextStyle(fontSize: 13, color: AppColors.slate),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: _applyAllSuggestedPrices,
                          icon: const Icon(Icons.bolt, size: 18),
                          label: const Text('Apply All AI Rates'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mountainBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // AI Yield Strategy Banner
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
                    child: Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.mountainBlueLight,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.mountainBlue.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.auto_awesome, color: AppColors.mountainBlue, size: 24),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'High Season Surcharge Strategy Active (+10% to +15% recommended)',
                                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppColors.mountainBlueDark),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Prices reflect current inventory pressures in Leh during the Ladakh festival and July Khardung La riding rush. Human approval required before rates go live.',
                                  style: TextStyle(fontSize: 12, color: AppColors.darkCharcoal),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Pricing Catalog Table / Cards
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: SliverToBoxAdapter(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth >= 900;
                        if (isDesktop) {
                          return _buildDesktopPricingTable(allGear);
                        } else {
                          return _buildMobilePricingCards(allGear);
                        }
                      },
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

  Widget _buildDesktopPricingTable(List<GearModel> gearList) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppTheme.softShadow],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(AppColors.surfaceMuted),
          columnSpacing: 24,
          horizontalMargin: 20,
          columns: const [
            DataColumn(label: Text('Gear Item', style: TextStyle(fontWeight: FontWeight.w700))),
            DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.w700))),
            DataColumn(label: Text('Current Rate', style: TextStyle(fontWeight: FontWeight.w700))),
            DataColumn(label: Text('Demand Tier', style: TextStyle(fontWeight: FontWeight.w700))),
            DataColumn(label: Text('AI Suggested Rate', style: TextStyle(fontWeight: FontWeight.w700))),
            DataColumn(label: Text('Difference', style: TextStyle(fontWeight: FontWeight.w700))),
            DataColumn(label: Text('Action', style: TextStyle(fontWeight: FontWeight.w700))),
          ],
          rows: gearList.map((gear) {
            final diff = gear.suggestedPrice - gear.pricePerDay;
            final isOptimized = diff.abs() < 1.0;

            return DataRow(
              cells: [
                DataCell(
                  SizedBox(
                    width: 240,
                    child: Text(
                      gear.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                DataCell(Text(gear.category.label, style: const TextStyle(fontSize: 13))),
                DataCell(
                  Text('₹${gear.pricePerDay.toInt()} / day', style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: gear.demandLevel == 'High' ? AppColors.warningLight : AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      gear.demandLevel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: gear.demandLevel == 'High' ? AppColors.warning : AppColors.slate,
                      ),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '₹${gear.suggestedPrice.toInt()} / day',
                        style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.mountainBlue),
                      ),
                      const SizedBox(width: 4),
                      const Icon(Icons.auto_awesome, size: 12, color: AppColors.mountainBlue),
                    ],
                  ),
                ),
                DataCell(
                  Text(
                    isOptimized ? 'Matched' : (diff > 0 ? '+₹${diff.toInt()}' : '-₹${(-diff).toInt()}'),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: isOptimized ? AppColors.success : (diff > 0 ? AppColors.mountainBlue : AppColors.error),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isOptimized)
                        ElevatedButton(
                          onPressed: () => _applySinglePrice(gear),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mountainBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                            minimumSize: Size.zero,
                          ),
                          child: const Text('Apply AI'),
                        )
                      else
                        const Text('Active Rate', style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w700)),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: const Icon(Icons.edit, size: 16, color: AppColors.slate),
                        tooltip: 'Set Custom Rate',
                        onPressed: () => _editCustomPrice(gear),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildMobilePricingCards(List<GearModel> gearList) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: gearList.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final gear = gearList[index];
        final diff = gear.suggestedPrice - gear.pricePerDay;
        final isOptimized = diff.abs() < 1.0;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
            boxShadow: [AppTheme.softShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      gear.name,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: gear.demandLevel == 'High' ? AppColors.warningLight : AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${gear.demandLevel} Demand',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: gear.demandLevel == 'High' ? AppColors.warning : AppColors.slate,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Current Rate', style: TextStyle(fontSize: 11, color: AppColors.slate)),
                      Text(
                        '₹${gear.pricePerDay.toInt()}/day',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_forward, color: AppColors.slate, size: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Text('AI Recommendation', style: TextStyle(fontSize: 11, color: AppColors.mountainBlue, fontWeight: FontWeight.w600)),
                          SizedBox(width: 4),
                          Icon(Icons.auto_awesome, size: 10, color: AppColors.mountainBlue),
                        ],
                      ),
                      Text(
                        '₹${gear.suggestedPrice.toInt()}/day',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.mountainBlue),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 14),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => _editCustomPrice(gear),
                    child: const Text('Edit Custom Rate', style: TextStyle(fontSize: 12)),
                  ),
                  const SizedBox(width: 8),
                  if (!isOptimized)
                    ElevatedButton(
                      onPressed: () => _applySinglePrice(gear),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mountainBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                      child: const Text('Apply AI Rate'),
                    )
                  else
                    const Text('Rate Synchronized ✓', style: TextStyle(color: AppColors.success, fontSize: 12, fontWeight: FontWeight.w700)),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
