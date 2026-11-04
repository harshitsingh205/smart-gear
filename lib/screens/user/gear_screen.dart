import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../services/gear_service.dart';
import '../../models/gear_model.dart';
import '../../widgets/gear_card.dart';
import '../user/gear_details_screen.dart';

class GearScreen extends StatefulWidget {
  const GearScreen({super.key});

  @override
  State<GearScreen> createState() => _GearScreenState();
}

class _GearScreenState extends State<GearScreen> {
  final TextEditingController _searchController = TextEditingController();
  GearCategory? _selectedCategory;
  String _selectedAvailability = 'All';
  String _searchQuery = '';

  List<GearModel> get _filteredGear => GearService().filterGear(
        category: _selectedCategory,
        availability: _selectedAvailability == 'All' ? null : _selectedAvailability,
        searchQuery: _searchQuery,
      );

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredGear;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Gear Catalog'),
        automaticallyImplyLeading: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text('${filtered.length} items',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.slate, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search + Filters
          Container(
            color: AppColors.surface,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              children: [
                // Search Bar
                TextField(
                  controller: _searchController,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.slate),
                    hintText: 'Search helmets, jackets, boots...',
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(height: 12),

                // Category chips
                SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      _CategoryChip(
                        label: 'All',
                        isSelected: _selectedCategory == null,
                        onTap: () => setState(() => _selectedCategory = null),
                      ),
                      ...GearCategory.values.map((cat) => _CategoryChip(
                            label: cat.label,
                            isSelected: _selectedCategory == cat,
                            onTap: () => setState(() =>
                                _selectedCategory = _selectedCategory == cat ? null : cat),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Availability Filter
                Row(
                  children: [
                    const Text('Status:', style: TextStyle(fontSize: 13, color: AppColors.slate)),
                    const SizedBox(width: 8),
                    ...['All', 'Available', 'Restock Soon'].map((a) => Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(a, style: const TextStyle(fontSize: 12)),
                            selected: _selectedAvailability == a,
                            onSelected: (_) => setState(() => _selectedAvailability = a),
                            selectedColor: AppColors.mountainBlueLight,
                            labelStyle: TextStyle(
                              color: _selectedAvailability == a
                                  ? AppColors.mountainBlue
                                  : AppColors.slate,
                              fontWeight: _selectedAvailability == a
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                                side: BorderSide(
                                    color: _selectedAvailability == a
                                        ? AppColors.mountainBlue
                                        : AppColors.border)),
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Gear Grid
          Expanded(
            child: filtered.isEmpty
                ? _buildEmptyState()
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final width = constraints.maxWidth;
                      final int cols;
                      final double ratio;
                      if (width < 340) {
                        cols = 1;
                        ratio = 1.05;
                      } else if (width < 600) {
                        cols = 2;
                        ratio = 0.58;
                      } else if (width < 900) {
                        cols = 3;
                        ratio = 0.65;
                      } else {
                        cols = 4;
                        ratio = 0.72;
                      }
                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: cols,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: ratio,
                        ),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final gear = filtered[index];
                          return GearCard(
                            gear: gear,
                            onViewDetails: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => GearDetailsScreen(gear: gear)),
                            ),
                            onRentNow: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => GearDetailsScreen(gear: gear, autoOpenRent: true)),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2_outlined, size: 64, color: AppColors.slate.withValues(alpha: 0.4)),
          const SizedBox(height: 16),
          const Text('No gear found',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal)),
          const SizedBox(height: 8),
          const Text('Try adjusting your filters or search query.',
              style: TextStyle(fontSize: 14, color: AppColors.slate)),
          const SizedBox(height: 20),
          OutlinedButton(
            onPressed: () {
              _searchController.clear();
              setState(() {
                _searchQuery = '';
                _selectedCategory = null;
                _selectedAvailability = 'All';
              });
            },
            child: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mountainBlue : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isSelected ? AppColors.mountainBlue : AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.slate,
          ),
        ),
      ),
    );
  }
}
