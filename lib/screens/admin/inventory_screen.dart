import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/gear_model.dart';
import '../../services/gear_service.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final GearService _gearService = GearService();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  String _selectedStatus = 'All';

  final List<String> _categories = [
    'All',
    'Jackets',
    'Pants',
    'Boots',
    'Gloves',
    'Helmets',
    'Knee Guards',
    'Elbow Guards',
    'Thermal Wear',
  ];

  final List<String> _statuses = ['All', 'Available', 'Restock Soon', 'Maintenance'];

  List<GearModel> _getFilteredGear(List<GearModel> all) {
    return all.where((g) {
      if (_selectedCategory != 'All' && g.category.label != _selectedCategory) {
        return false;
      }
      if (_selectedStatus != 'All' && g.status != _selectedStatus) {
        return false;
      }
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final nameMatch = g.name.toLowerCase().contains(q);
        final catMatch = g.category.label.toLowerCase().contains(q);
        if (!nameMatch && !catMatch) return false;
      }
      return true;
    }).toList();
  }

  void _showAddGearDialog() {
    final nameCtrl = TextEditingController();
    final priceCtrl = TextEditingController(text: '300');
    final stockCtrl = TextEditingController(text: '50');
    final descCtrl = TextEditingController();
    GearCategory category = GearCategory.jackets;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Add Gear to Inventory', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 420,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Equipment Name',
                      hintText: 'e.g. Arctic Thermal Tourer Jacket',
                    ),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<GearCategory>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: GearCategory.values
                        .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setDlgState(() => category = v);
                    },
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Daily Rate (₹)',
                            prefixText: '₹ ',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: stockCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Initial Units',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Brief Description & Safety Rating',
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: AppColors.slate)),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isEmpty) return;
                final price = double.tryParse(priceCtrl.text) ?? 300.0;
                final stock = int.tryParse(stockCtrl.text) ?? 50;

                final newGear = GearModel(
                  id: 'gear_${DateTime.now().millisecondsSinceEpoch}',
                  name: nameCtrl.text.trim(),
                  category: category,
                  sizes: const ['S', 'M', 'L', 'XL'],
                  pricePerDay: price,
                  suggestedPrice: price * 1.15,
                  totalStock: stock,
                  availableStock: stock,
                  rentedCount: 0,
                  maintenanceCount: 0,
                  destination: 'Ladakh',
                  rating: 4.8,
                  reviewsCount: 1,
                  description: descCtrl.text.trim().isNotEmpty
                      ? descCtrl.text.trim()
                      : 'Professional motorcycle adventure touring equipment.',
                  features: const ['CE Certified Protection', 'Weatherproof', 'High Visibility Accents'],
                  demandLevel: 'Medium',
                  status: 'Available',
                  imageUrl:
                      'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=800&q=80',
                );

                _gearService.addGear(newGear);
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added "${newGear.name}" to inventory!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              },
              child: const Text('Add Gear'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateStockDialog(GearModel gear) {
    final totalCtrl = TextEditingController(text: gear.totalStock.toString());
    final availCtrl = TextEditingController(text: gear.availableStock.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Update Stock: ${gear.name}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: totalCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Total Fleet Units'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: availCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Ready / Available Units'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final total = int.tryParse(totalCtrl.text) ?? gear.totalStock;
              final avail = int.tryParse(availCtrl.text) ?? gear.availableStock;
              _gearService.updateStock(gear.id, total, avail);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Stock counts updated successfully!'), backgroundColor: AppColors.success),
              );
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _showMaintenanceDialog(GearModel gear) {
    final countCtrl = TextEditingController(text: '2');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Send to Maintenance', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Item: ${gear.name}', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Currently available: ${gear.availableStock} units', style: const TextStyle(color: AppColors.slate, fontSize: 13)),
            const SizedBox(height: 14),
            TextField(
              controller: countCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Number of units for inspection / repair'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.warning),
            onPressed: () {
              final count = int.tryParse(countCtrl.text) ?? 1;
              _gearService.markMaintenance(gear.id, count);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Sent $count units to maintenance.'), backgroundColor: AppColors.warning),
              );
            },
            child: const Text('Send Units'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(GearModel gear) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Deletion', style: TextStyle(fontWeight: FontWeight.w700)),
        content: Text('Are you sure you want to remove "${gear.name}" from active fleet inventory?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              _gearService.deleteGear(gear.id);
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Item deleted from inventory.'), backgroundColor: AppColors.error),
              );
            },
            child: const Text('Delete'),
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
            final filtered = _getFilteredGear(allGear);

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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Inventory & Fleet Management',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkCharcoal,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Track stocks, maintenance schedules, and active rental distribution',
                              style: TextStyle(fontSize: 13, color: AppColors.slate),
                            ),
                          ],
                        ),
                        ElevatedButton.icon(
                          onPressed: _showAddGearDialog,
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Gear'),
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

                // Filters and Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search bar & status dropdown
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                onChanged: (v) => setState(() => _searchQuery = v),
                                decoration: InputDecoration(
                                  hintText: 'Search equipment name or category...',
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
                            ),
                            const SizedBox(width: 14),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedStatus,
                                  items: _statuses
                                      .map((s) => DropdownMenuItem(value: s, child: Text('Status: $s')))
                                      .toList(),
                                  onChanged: (v) {
                                    if (v != null) setState(() => _selectedStatus = v);
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Category Chips
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: _categories.map((cat) {
                              final isSelected = _selectedCategory == cat;
                              return Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(cat),
                                  selected: isSelected,
                                  onSelected: (val) {
                                    if (val) setState(() => _selectedCategory = cat);
                                  },
                                  selectedColor: AppColors.mountainBlue,
                                  labelStyle: TextStyle(
                                    color: isSelected ? Colors.white : AppColors.darkCharcoal,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                                    fontSize: 12,
                                  ),
                                  backgroundColor: AppColors.surface,
                                  side: BorderSide(
                                    color: isSelected ? AppColors.mountainBlue : AppColors.border,
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Data View: Responsive Table on Wide, Cards on Mobile
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  sliver: SliverToBoxAdapter(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isDesktop = constraints.maxWidth >= 900;

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
                                  Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.slate),
                                  SizedBox(height: 12),
                                  Text(
                                    'No gear found matching your criteria',
                                    style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.slate),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }

                        if (isDesktop) {
                          return _buildDesktopTable(filtered);
                        } else {
                          return _buildMobileCards(filtered);
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

  // ── Desktop Table ──────────────────────────────────────────────────────────
  Widget _buildDesktopTable(List<GearModel> gearList) {
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
          columnSpacing: 20,
          horizontalMargin: 20,
          columns: const [
            DataColumn(label: Text('Gear Item', style: TextStyle(fontWeight: FontWeight.w700))),
            DataColumn(label: Text('Category', style: TextStyle(fontWeight: FontWeight.w700))),
            DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.w700))),
            DataColumn(label: Text('Available', style: TextStyle(fontWeight: FontWeight.w700))),
            DataColumn(label: Text('Rented', style: TextStyle(fontWeight: FontWeight.w700))),
            DataColumn(label: Text('Maintenance', style: TextStyle(fontWeight: FontWeight.w700))),
            DataColumn(label: Text('Daily Rate', style: TextStyle(fontWeight: FontWeight.w700))),
            DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.w700))),
            DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.w700))),
          ],
          rows: gearList.map((gear) {
            Color statusBg = AppColors.successLight;
            Color statusText = AppColors.success;
            if (gear.status == 'Restock Soon') {
              statusBg = AppColors.warningLight;
              statusText = AppColors.warning;
            } else if (gear.status == 'Out of Stock') {
              statusBg = AppColors.errorLight;
              statusText = AppColors.error;
            }

            return DataRow(
              cells: [
                DataCell(
                  SizedBox(
                    width: 220,
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: Image.network(
                            gear.imageUrl,
                            width: 38,
                            height: 38,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => Container(
                              width: 38,
                              height: 38,
                              color: AppColors.surfaceMuted,
                              child: const Icon(Icons.shield, size: 20, color: AppColors.slate),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            gear.name,
                            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                DataCell(Text(gear.category.label, style: const TextStyle(fontSize: 13))),
                DataCell(Text('${gear.totalStock}', style: const TextStyle(fontWeight: FontWeight.w600))),
                DataCell(
                  Text(
                    '${gear.availableStock}',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: gear.availableStock <= 30 ? AppColors.warning : AppColors.success,
                    ),
                  ),
                ),
                DataCell(Text('${gear.rentedCount}')),
                DataCell(
                  Text(
                    '${gear.maintenanceCount}',
                    style: TextStyle(
                      color: gear.maintenanceCount > 0 ? AppColors.warning : AppColors.slate,
                    ),
                  ),
                ),
                DataCell(Text('₹${gear.pricePerDay.toInt()}', style: const TextStyle(fontWeight: FontWeight.w700))),
                DataCell(
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: statusBg, borderRadius: BorderRadius.circular(6)),
                    child: Text(
                      gear.status,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: statusText),
                    ),
                  ),
                ),
                DataCell(
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_note, size: 20, color: AppColors.mountainBlue),
                        tooltip: 'Update Stock',
                        onPressed: () => _showUpdateStockDialog(gear),
                      ),
                      IconButton(
                        icon: const Icon(Icons.build_circle_outlined, size: 18, color: AppColors.warning),
                        tooltip: 'Maintenance',
                        onPressed: () => _showMaintenanceDialog(gear),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                        tooltip: 'Delete',
                        onPressed: () => _confirmDelete(gear),
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

  // ── Mobile Cards ───────────────────────────────────────────────────────────
  Widget _buildMobileCards(List<GearModel> gearList) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: gearList.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final gear = gearList[index];
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      gear.imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(
                        width: 50,
                        height: 50,
                        color: AppColors.surfaceMuted,
                        child: const Icon(Icons.shield, color: AppColors.slate),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          gear.name,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${gear.category.label} • ₹${gear.pricePerDay.toInt()}/day',
                          style: const TextStyle(fontSize: 12, color: AppColors.slate),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: gear.availableStock > 25 ? AppColors.successLight : AppColors.warningLight,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      gear.status,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: gear.availableStock > 25 ? AppColors.success : AppColors.warning,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _metricTile('Total Fleet', '${gear.totalStock}'),
                  _metricTile('Available', '${gear.availableStock}', isHighlight: true),
                  _metricTile('Rented', '${gear.rentedCount}'),
                  _metricTile('Maint.', '${gear.maintenanceCount}'),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: AppColors.border, height: 1),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () => _showUpdateStockDialog(gear),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Update Stock', style: TextStyle(fontSize: 12)),
                  ),
                  TextButton.icon(
                    onPressed: () => _showMaintenanceDialog(gear),
                    icon: const Icon(Icons.build, size: 16, color: AppColors.warning),
                    label: const Text('Maintenance', style: TextStyle(fontSize: 12, color: AppColors.warning)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.error),
                    onPressed: () => _confirmDelete(gear),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _metricTile(String label, String value, {bool isHighlight = false}) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w800,
            color: isHighlight ? AppColors.mountainBlue : AppColors.darkCharcoal,
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 10, color: AppColors.slate)),
      ],
    );
  }
}
