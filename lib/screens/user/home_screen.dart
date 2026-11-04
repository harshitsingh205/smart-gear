import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../services/auth_service.dart';
import '../../services/gear_service.dart';
import '../../services/booking_service.dart';
import '../../services/ai_service.dart';
import '../../services/location_service.dart';
import '../../models/gear_model.dart';
import '../../models/booking_model.dart';
import '../../widgets/ai_chat_button.dart';
import '../../widgets/user_avatar.dart';
import '../user/ai_recommendation_screen.dart';
import '../user/sizing_form_screen.dart';
import '../user/gear_details_screen.dart';
import '../user/booking_screen.dart';
import '../user/trip_screen.dart';
import '../user/bookings_screen.dart';
import '../user/profile_screen.dart';

enum SortOption {
  recommended('Recommended'),
  rating('Top Rated'),
  priceLowHigh('Price: Low to High'),
  priceHighLow('Price: High to Low'),
  popular('Most Popular');

  final String label;
  const SortOption(this.label);
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  final LocationService _locationService = LocationService();
  final GearService _gearService = GearService();
  final TextEditingController _searchController = TextEditingController();

  bool _locationLoading = false;
  String _selectedDestination = 'All Hubs';
  GearCategory? _selectedCategory;
  String _searchQuery = '';
  SortOption _selectedSort = SortOption.recommended;
  bool _isGridView = false;
  bool _inStockOnly = false;
  double _maxPrice = 500.0;
  final Set<String> _wishlist = {};

  final List<String> _destinations = ['All Hubs', 'Ladakh', 'Spiti', 'Manali', 'Rishikesh'];

  @override
  void initState() {
    super.initState();
    _detectLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _detectLocation() async {
    setState(() => _locationLoading = true);
    await _locationService.detectLocation();
    if (mounted) {
      final nearest = _locationService.locationInfo?.nearestDestination;
      if (nearest != null && _destinations.contains(nearest) && _selectedDestination == 'All Hubs') {
        _selectedDestination = nearest;
      }
      setState(() => _locationLoading = false);
    }
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning';
    if (hour < 17) return 'Good afternoon';
    return 'Good evening';
  }

  List<GearModel> _getFilteredAndSortedGear() {
    final destinationFilter = _selectedDestination == 'All Hubs' ? 'All' : _selectedDestination;
    List<GearModel> list = _gearService.searchGear(
      _searchQuery,
      category: _selectedCategory,
      destination: destinationFilter,
    );

    if (_inStockOnly) {
      list = list.where((g) => g.isAvailable).toList();
    }

    if (_maxPrice < 500.0) {
      list = list.where((g) => g.pricePerDay <= _maxPrice).toList();
    }

    switch (_selectedSort) {
      case SortOption.rating:
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case SortOption.priceLowHigh:
        list.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
        break;
      case SortOption.priceHighLow:
        list.sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
        break;
      case SortOption.popular:
        list.sort((a, b) => b.rentedCount.compareTo(a.rentedCount));
        break;
      case SortOption.recommended:
        list.sort((a, b) => (b.rating * 100 + b.reviewsCount).compareTo(a.rating * 100 + a.reviewsCount));
        break;
    }

    return list;
  }

  void _toggleWishlist(String id, String name) {
    setState(() {
      if (_wishlist.contains(id)) {
        _wishlist.remove(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Removed $name from wishlist'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else {
        _wishlist.add(id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Saved $name to your wishlist ⭐'),
            duration: const Duration(seconds: 1),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final allGear = _getFilteredAndSortedGear();
    final popularGear = _gearService.popularGear;
    final upcomingBookings = BookingService().upcomingBookings;
    final locationSuggestions = _locationService.getGearSuggestionsForLocation();

    return Scaffold(
      backgroundColor: AppColors.background,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openChat(context),
        backgroundColor: AppColors.mountainBlue,
        elevation: 6,
        highlightElevation: 8,
        icon: const Icon(Icons.auto_awesome, color: Colors.white, size: 20),
        label: const Text(
          'Ask AI Copilot',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: RefreshIndicator(
              color: AppColors.mountainBlue,
              onRefresh: _detectLocation,
              child: CustomScrollView(
            physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
            slivers: [
              // ── Top Header & Greeting ──────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${_getGreeting()}, ${user?.name.split(' ').first ?? 'Rider'}',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w900,
                                        color: AppColors.darkCharcoal,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                _buildLocationChip(),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ProfileScreen()),
                            ),
                            child: Stack(
                              children: [
                                UserAvatar(
                                  user: user,
                                  size: 48,
                                  borderRadius: 16,
                                  showBorder: true,
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: AppColors.success,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: Colors.white, width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ── Search & Filter Bar ─────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: _searchQuery.isNotEmpty ? AppColors.mountainBlue : AppColors.border,
                                  width: _searchQuery.isNotEmpty ? 1.5 : 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: _searchController,
                                onChanged: (val) => setState(() => _searchQuery = val),
                                decoration: InputDecoration(
                                  hintText: 'Search jackets, modular helmets, boots, armor...',
                                  hintStyle: const TextStyle(fontSize: 13, color: AppColors.slate),
                                  prefixIcon: const Icon(Icons.search, color: AppColors.mountainBlue, size: 22),
                                  suffixIcon: _searchQuery.isNotEmpty
                                      ? IconButton(
                                          icon: const Icon(Icons.clear, size: 18, color: AppColors.slate),
                                          onPressed: () {
                                            _searchController.clear();
                                            setState(() => _searchQuery = '');
                                          },
                                        )
                                      : null,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          InkWell(
                            onTap: () => _showFilterModal(context),
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: (_inStockOnly || _maxPrice < 500.0 || _selectedSort != SortOption.recommended)
                                    ? AppColors.mountainBlue
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: (_inStockOnly || _maxPrice < 500.0 || _selectedSort != SortOption.recommended)
                                      ? AppColors.mountainBlue
                                      : AppColors.border,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.04),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  Icon(
                                    Icons.tune_rounded,
                                    size: 22,
                                    color: (_inStockOnly || _maxPrice < 500.0 || _selectedSort != SortOption.recommended)
                                        ? Colors.white
                                        : AppColors.darkCharcoal,
                                  ),
                                  if (_inStockOnly || _maxPrice < 500.0 || _selectedSort != SortOption.recommended)
                                    Positioned(
                                      top: 10,
                                      right: 10,
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: Colors.amberAccent,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // ── Quick Interactive Action Tiles ────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildActionTile(
                          icon: Icons.auto_awesome,
                          label: 'AI Sizing',
                          sublabel: '30s Fit',
                          color: const Color(0xFF1E56A0),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const AIRecommendationScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildActionTile(
                          icon: Icons.map_outlined,
                          label: 'Plan Trip',
                          sublabel: 'Checklist',
                          color: const Color(0xFF0F766E),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const TripScreen()),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildActionTile(
                          icon: Icons.alt_route_rounded,
                          label: 'Pass Radar',
                          sublabel: 'Live Status',
                          color: const Color(0xFFB45309),
                          onTap: () => _showPassConditionsModal(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildActionTile(
                          icon: Icons.storefront_outlined,
                          label: 'Hubs',
                          sublabel: '4 Centers',
                          color: const Color(0xFF4338CA),
                          onTap: () => _showHubsModal(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Category Horizontal Filter Chips ──────────────────────────
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 42,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _buildCategoryChip('All Gear', null, Icons.dashboard_customize_outlined),
                      _buildCategoryChip('Jackets', GearCategory.jackets, Icons.dry_cleaning_outlined),
                      _buildCategoryChip('Helmets', GearCategory.helmets, Icons.sports_motorsports_outlined),
                      _buildCategoryChip('Boots', GearCategory.boots, Icons.hiking_outlined),
                      _buildCategoryChip('Gloves', GearCategory.gloves, Icons.front_hand_outlined),
                      _buildCategoryChip('Pants', GearCategory.pants, Icons.straighten_outlined),
                      _buildCategoryChip('Thermals', GearCategory.thermalWear, Icons.ac_unit_outlined),
                      _buildCategoryChip('Armor', GearCategory.kneeGuards, Icons.shield_outlined),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 18)),

              // ── Main Sliver Content List ──────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // 1. AI Anthropometric Sizing Hero Banner
                    _buildAICTACard(context),
                    const SizedBox(height: 20),

                    // 2. Interactive Route & Precise AI Destination Advisory
                    _buildDestinationSelectorAndAdvisory(context),
                    const SizedBox(height: 22),

                    // 3. Context-Aware Location Suggestions
                    if (locationSuggestions.isNotEmpty) ...[
                      _buildContextSuggestionsSection(context, locationSuggestions),
                      const SizedBox(height: 22),
                    ],

                    // 4. High-Pass Expedition Bundles (Value Packs)
                    _buildExpeditionBundlesSection(context),
                    const SizedBox(height: 22),

                    // 5. Active Upcoming Booking Banner (if exists)
                    if (upcomingBookings.isNotEmpty) ...[
                      _buildUpcomingCard(context, upcomingBookings.first),
                      const SizedBox(height: 22),
                    ],

                    // 6. Filtered Products Catalog with List/Grid Toggle
                    _buildProductCatalogSection(context, allGear),
                    const SizedBox(height: 24),

                    // 7. Top Verified Gear Essentials Carousel
                    _buildPopularGearCarousel(context, popularGear),
                    const SizedBox(height: 24),

                    // 8. Trust & Expedition Hub Guarantees
                    _buildTrustGuaranteesSection(),
                    const SizedBox(height: 90),
                  ]),
                ),
              ),
            ],
            ),
          ),
        ),
      ),
    ),
  );
}

  // ─── Location Chip ────────────────────────────────────────────────────────────
  Widget _buildLocationChip() {
    final loc = _locationService.locationInfo;
    return GestureDetector(
      onTap: _detectLocation,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: AppColors.mountainBlueLight.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.mountainBlue.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_locationLoading)
              const SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.mountainBlue),
              )
            else
              const Icon(Icons.location_on, size: 14, color: AppColors.mountainBlue),
            const SizedBox(width: 5),
            Text(
              _locationLoading
                  ? 'Locating Hub...'
                  : loc != null
                      ? '${loc.city} • Near ${loc.nearestDestination} Hub'
                      : 'Auto-Detect Destination',
              style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700, color: AppColors.mountainBlue),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.refresh_rounded, size: 13, color: AppColors.mountainBlue),
          ],
        ),
      ),
    );
  }

  // ─── Quick Action Tiles ───────────────────────────────────────────────────────
  Widget _buildActionTile({
    required IconData icon,
    required String label,
    required String sublabel,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              sublabel,
              style: const TextStyle(fontSize: 9.5, color: AppColors.slate, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Category Chip ────────────────────────────────────────────────────────────
  Widget _buildCategoryChip(String title, GearCategory? category, IconData icon) {
    final isSelected = _selectedCategory == category;
    final count = _gearService.searchGear(
      '',
      category: category,
      destination: _selectedDestination == 'All Hubs' ? 'All' : _selectedDestination,
    ).length;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: () => setState(() => _selectedCategory = isSelected ? null : category),
        borderRadius: BorderRadius.circular(20),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.mountainBlue : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? AppColors.mountainBlue : AppColors.border,
              width: 1.2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.mountainBlue.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : AppColors.mountainBlue,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? Colors.white : AppColors.darkCharcoal,
                ),
              ),
              const SizedBox(width: 5),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white.withValues(alpha: 0.25) : AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : AppColors.slate,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── AI Anthropometric Sizing Card ───────────────────────────────────────────
  Widget _buildAICTACard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F325E), Color(0xFF1E56A0), Color(0xFF0D2547)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E56A0).withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -25,
            child: Opacity(
              opacity: 0.12,
              child: const Icon(Icons.sports_motorsports, size: 170, color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.auto_awesome, color: Colors.amberAccent, size: 13),
                          SizedBox(width: 5),
                          Text(
                            'GEMINI 2.0 SIZING ENGINE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.successLight.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified, color: Color(0xFF4ADE80), size: 12),
                          SizedBox(width: 4),
                          Text('98% Fit Accuracy', style: TextStyle(color: Colors.white, fontSize: 10.5, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Zero-Guesswork Sizing\n& Layering In 30 Seconds',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Input your height, weight & route month. Our AI fits CE Level 2 armor, wind-chill base layers, and glove tolerances perfectly.',
                  style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AIRecommendationScreen()),
                      ),
                      icon: const Icon(Icons.bolt, color: AppColors.mountainBlue, size: 16),
                      label: const Text('Calculate Sizing Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.mountainBlue,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800),
                      ),
                    ),
                    const SizedBox(width: 10),
                    OutlinedButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SizingFormScreen()),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white38),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Update Profile', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Destination Selector & AI Advisory ──────────────────────────────────────
  Widget _buildDestinationSelectorAndAdvisory(BuildContext context) {
    final dest = _selectedDestination;

    String passInfo;
    String terrainAdvisory;
    String passElevation;
    Color alertColor = AppColors.mountainBlue;

    if (dest == 'Ladakh') {
      passInfo = 'Khardung La (17,582 ft) & Chang La';
      passElevation = '-4°C Wind Chill • Pass OPEN';
      terrainAdvisory = 'CE Level 2 back/chest armor, 100% waterproof boots for Pagal Nalas (glacial streams), and Merino wool thermal base layers mandatory.';
      alertColor = const Color(0xFF0284C7);
    } else if (dest == 'Spiti') {
      passInfo = 'Kunzum Pass (14,931 ft) & Chhatru Nala';
      passElevation = 'Glacial Crossings • Loose Shale';
      terrainAdvisory = 'Dual-pivot articulated knee armor, vulcanized lugged boots for river beds, and wind-block fleece neck gaiters strongly advised.';
      alertColor = const Color(0xFFEA580C);
    } else if (dest == 'Manali') {
      passInfo = 'Rohtang Pass (13,058 ft) & Atal Tunnel';
      passElevation = 'High-Altitude Rain & Mud Tracks';
      terrainAdvisory = '10,000mm hydrostatic rain overcoat and battery-assisted heated gloves recommended for unexpected sudden cold bursts.';
      alertColor = const Color(0xFF0D9488);
    } else if (dest == 'Rishikesh') {
      passInfo = 'Garhwal Foothills & Neelkanth Twists';
      passElevation = '26°C Mild • Fast Highway Corners';
      terrainAdvisory = 'High-flow 3D mesh breathable touring jackets with Level 2 armor and short ventilated carbon gloves ideal for humid valley climbs.';
      alertColor = const Color(0xFF4F46E5);
    } else {
      passInfo = 'Trans-Himalayan Expedition Hubs';
      passElevation = '4 Stocked Hub Centers Active';
      terrainAdvisory = 'Showing full verified fleet across Leh, Kaza, Old Manali, and Tapovan hubs. Choose a hub above for real-time mountain pass advisories.';
      alertColor = AppColors.mountainBlue;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(Icons.explore_outlined, color: AppColors.mountainBlue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Expedition Destination Hub',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.radar, color: AppColors.warning, size: 12),
                    SizedBox(width: 4),
                    Text('Live Route AI', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.warning)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Destination Pills Horizontal Bar
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _destinations.map((d) {
                final active = _selectedDestination == d;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedDestination = d),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? AppColors.mountainBlue : AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: active ? AppColors.mountainBlue : AppColors.border),
                      ),
                      child: Text(
                        d,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                          color: active ? Colors.white : AppColors.darkCharcoal,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 14),

          // Route Condition Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: alertColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: alertColor.withValues(alpha: 0.25)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.terrain_rounded, color: alertColor, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              passInfo,
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: alertColor),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              passElevation,
                              style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: alertColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        terrainAdvisory,
                        style: const TextStyle(fontSize: 11.5, color: AppColors.darkCharcoal, height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Context-Aware Suggestions ───────────────────────────────────────────────
  Widget _buildContextSuggestionsSection(BuildContext context, List<LocationGearSuggestion> suggestions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recommended For Your Route',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal),
                ),
                Text('Based on terrain severity and altitude profiles', style: TextStyle(fontSize: 11.5, color: AppColors.slate)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.mountainBlueLight,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text('Smart Check', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700, color: AppColors.mountainBlue)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 125,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: suggestions.length,
            itemBuilder: (context, index) {
              final item = suggestions[index];
              return Container(
                width: 220,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: item.isUrgent ? AppColors.warning.withValues(alpha: 0.5) : AppColors.border,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(item.icon, style: const TextStyle(fontSize: 20)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: item.isUrgent ? AppColors.warningLight : AppColors.successLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            item.priority,
                            style: TextStyle(
                              fontSize: 9.5,
                              fontWeight: FontWeight.w800,
                              color: item.isUrgent ? AppColors.warning : AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          item.reason,
                          style: const TextStyle(fontSize: 10.5, color: AppColors.slate, height: 1.25),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    Text(
                      item.priceRange,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mountainBlue),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── High-Pass Expedition Bundles ─────────────────────────────────────────────
  Widget _buildExpeditionBundlesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Expedition Value Bundles',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal),
                ),
                Text('Pre-packaged safety suites • Save up to 22%', style: TextStyle(fontSize: 11.5, color: AppColors.slate)),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.successLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.shield_outlined, color: AppColors.success, size: 12),
                  SizedBox(width: 4),
                  Text('All-In-One', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: AppColors.success)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Bundle Card 1: Ladakh Ultimate Kit
        _buildBundleCard(
          context: context,
          title: 'Ladakh High-Altitude Armor Bundle',
          subtitle: 'Jacket + Boots + Gloves + Merino Base Layer',
          pricePerDay: '₹720',
          originalPrice: '₹920',
          savingsBadge: 'SAVE 22%',
          tags: ['CE Level 2 Armor', 'Sub-Zero -10°C Ready', '100% Waterproof'],
          imageUrl: 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=600&q=80',
          hubTag: 'Leh Hub Stocked',
          onTap: () {
            final jacket = _gearService.allGear.firstWhere((g) => g.id == 'gear_01');
            Navigator.push(context, MaterialPageRoute(builder: (_) => GearDetailsScreen(gear: jacket, autoOpenRent: true)));
          },
        ),
        const SizedBox(height: 12),

        // Bundle Card 2: Spiti Rough-Road Kit
        _buildBundleCard(
          context: context,
          title: 'Spiti Glacial & Loose-Shale Pack',
          subtitle: 'Waterproof Boots + Articulated Knee Armor + Rain Suit',
          pricePerDay: '₹460',
          originalPrice: '₹550',
          savingsBadge: 'SAVE 16%',
          tags: ['Dual-Pivot Knee', 'Vulcanized Lug Sole', 'Gravel Impact'],
          imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=600&q=80',
          hubTag: 'Kaza & Leh Stocked',
          onTap: () {
            final boots = _gearService.allGear.firstWhere((g) => g.id == 'gear_03');
            Navigator.push(context, MaterialPageRoute(builder: (_) => GearDetailsScreen(gear: boots, autoOpenRent: true)));
          },
        ),
      ],
    );
  }

  Widget _buildBundleCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String pricePerDay,
    required String originalPrice,
    required String savingsBadge,
    required List<String> tags,
    required String imageUrl,
    required String hubTag,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Image.network(
                imageUrl,
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => Container(height: 120, color: AppColors.surfaceMuted),
              ),
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    savingsBadge,
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                  ),
                ),
              ),
              Positioned(
                bottom: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(hubTag, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$pricePerDay/day',
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.mountainBlue),
                        ),
                        Text(
                          originalPrice,
                          style: const TextStyle(
                            fontSize: 11,
                            decoration: TextDecoration.lineThrough,
                            color: AppColors.slate,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: const TextStyle(fontSize: 11.5, color: AppColors.slate)),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: tags.map((t) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(t, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.slate)),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 38,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mountainBlue,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Reserve Complete Suite', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward_rounded, size: 15),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ─── Product Catalog Section (With Grid & List View Toggle) ──────────────────
  Widget _buildProductCatalogSection(BuildContext context, List<GearModel> gearList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedCategory != null
                      ? '${_selectedCategory!.label} Catalog'
                      : (_selectedDestination == 'All Hubs' ? 'Certified Expedition Gear' : '$_selectedDestination Hub Gear'),
                  style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal),
                ),
                Text(
                  '${gearList.length} verified items available',
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.mountainBlue),
                ),
              ],
            ),
            Row(
              children: [
                // Grid / List Toggle
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => setState(() => _isGridView = false),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: !_isGridView ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.view_agenda_outlined,
                            size: 16,
                            color: !_isGridView ? AppColors.mountainBlue : AppColors.slate,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () => setState(() => _isGridView = true),
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: _isGridView ? Colors.white : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.grid_view_rounded,
                            size: 16,
                            color: _isGridView ? AppColors.mountainBlue : AppColors.slate,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (gearList.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                const Icon(Icons.search_off_rounded, size: 44, color: AppColors.slate),
                const SizedBox(height: 10),
                const Text('No gear matched your active filters', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                const Text('Try resetting filters or switching destination hub', style: TextStyle(fontSize: 12, color: AppColors.slate)),
                const SizedBox(height: 14),
                OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _searchController.clear();
                      _searchQuery = '';
                      _selectedCategory = null;
                      _selectedDestination = 'All Hubs';
                      _inStockOnly = false;
                      _maxPrice = 500.0;
                    });
                  },
                  child: const Text('Reset All Filters'),
                ),
              ],
            ),
          )
        else if (_isGridView)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: gearList.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.64,
            ),
            itemBuilder: (context, index) {
              return _buildGridProductCard(context, gearList[index]);
            },
          )
        else
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: gearList.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _buildDetailedProductCard(context, gearList[index]);
            },
          ),
      ],
    );
  }

  // ─── Detailed List Product Card ──────────────────────────────────────────────
  Widget _buildDetailedProductCard(BuildContext context, GearModel gear) {
    final isWishlisted = _wishlist.contains(gear.id);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GearDetailsScreen(gear: gear)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image & Stock Badge
            Stack(
              children: [
                Image.network(
                  gear.imageUrl,
                  width: 115,
                  height: 165,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(
                    width: 115,
                    height: 165,
                    color: AppColors.surfaceMuted,
                    child: const Icon(Icons.sports_motorsports, color: AppColors.mountainBlue, size: 36),
                  ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 11),
                        const SizedBox(width: 2),
                        Text(
                          gear.rating.toStringAsFixed(1),
                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  bottom: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.mountainBlue.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      gear.destination,
                      style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),

            // Product Details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.mountainBlueLight,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            gear.category.label,
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.mountainBlue),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => _toggleWishlist(gear.id, gear.name),
                          child: Icon(
                            isWishlisted ? Icons.favorite : Icons.favorite_border,
                            color: isWishlisted ? AppColors.error : AppColors.slate,
                            size: 19,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      gear.name,
                      style: const TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkCharcoal,
                        height: 1.25,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      gear.description,
                      style: const TextStyle(fontSize: 11, color: AppColors.slate, height: 1.3),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),

                    // Sizes and Stock Info
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Sizes: ${gear.sizes.join(', ')}',
                          style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w600, color: AppColors.darkCharcoal),
                        ),
                        Text(
                          '${gear.availableStock} in stock',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: gear.availableStock > 20 ? AppColors.success : AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Pricing & Instant Rent Action
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '₹${gear.pricePerDay.toInt()}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: AppColors.mountainBlue,
                                ),
                              ),
                              const TextSpan(
                                text: '/day',
                                style: TextStyle(fontSize: 11, color: AppColors.slate),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton(
                          onPressed: gear.isAvailable
                              ? () => _openQuickRentSheet(context, gear)
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.mountainBlue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            minimumSize: const Size(60, 32),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Rent Now', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Compact Grid Product Card ───────────────────────────────────────────────
  Widget _buildGridProductCard(BuildContext context, GearModel gear) {
    final isWishlisted = _wishlist.contains(gear.id);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GearDetailsScreen(gear: gear)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  gear.imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Container(height: 120, color: AppColors.surfaceMuted),
                ),
                Positioned(
                  top: 6,
                  right: 6,
                  child: GestureDetector(
                    onTap: () => _toggleWishlist(gear.id, gear.name),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        color: isWishlisted ? AppColors.error : AppColors.slate,
                        size: 15,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      '★ ${gear.rating}',
                      style: const TextStyle(color: Colors.white, fontSize: 9.5, fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gear.name,
                    style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '₹${gear.pricePerDay.toInt()}/day',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.mountainBlue),
                      ),
                      Text(
                        gear.destination,
                        style: const TextStyle(fontSize: 10, color: AppColors.slate, fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    height: 30,
                    child: ElevatedButton(
                      onPressed: gear.isAvailable
                          ? () => _openQuickRentSheet(context, gear)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mountainBlue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.zero,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: const Text('Rent', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Popular Gear Carousel ───────────────────────────────────────────────────
  Widget _buildPopularGearCarousel(BuildContext context, List<GearModel> gearList) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Top Expedition Essentials',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal),
                ),
                Text('Highest rated by Himalayan cross-country riders', style: TextStyle(fontSize: 11.5, color: AppColors.slate)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: gearList.length,
            itemBuilder: (context, index) {
              final item = gearList[index];
              return Container(
                width: 165,
                margin: const EdgeInsets.only(right: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => GearDetailsScreen(gear: item)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(
                        item.imageUrl,
                        height: 110,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(height: 110, color: AppColors.surfaceMuted),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '₹${item.pricePerDay.toInt()}/day',
                                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.mountainBlue),
                                ),
                                Row(
                                  children: [
                                    const Icon(Icons.star, color: Colors.amber, size: 12),
                                    const SizedBox(width: 2),
                                    Text(
                                      '${item.rating}',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ─── Upcoming Booking Card ───────────────────────────────────────────────────
  Widget _buildUpcomingCard(BuildContext context, BookingModel booking) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.mountainBlue.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.mountainBlue.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.success),
                  ),
                  const SizedBox(width: 8),
                  const Text('Active / Upcoming Rental', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.mountainBlue)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.mountainBlueLight,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text('Confirmed & Prepped', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.mountainBlue)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              if (booking.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Image.network(
                    booking.imageUrl!,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (c, e, s) => Container(width: 50, height: 50, color: AppColors.surfaceMuted),
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(booking.gearName, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal)),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_outlined, size: 13, color: AppColors.slate),
                        const SizedBox(width: 4),
                        Text(
                          '${_formatDate(booking.startDate)} – ${_formatDate(booking.endDate)}  (${booking.numberOfDays} days)',
                          style: const TextStyle(fontSize: 11.5, color: AppColors.slate),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(Icons.store_mall_directory_outlined, size: 13, color: AppColors.slate),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            booking.pickupLocation,
                            style: const TextStyle(fontSize: 11, color: AppColors.slate),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 34,
            child: OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const BookingsScreen()),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.mountainBlue),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('View All Bookings & QR Pass', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Trust Guarantees ────────────────────────────────────────────────────────
  Widget _buildTrustGuaranteesSection() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceMuted,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('The SmartGear Expedition Promise', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal)),
          const SizedBox(height: 12),
          _trustRow(Icons.verified_user_outlined, 'CE Level 2 & ECE 22.06 Certified Impact Protection'),
          const SizedBox(height: 8),
          _trustRow(Icons.shield_outlined, 'Zero Security Deposit via Aadhaar / Passport Verification'),
          const SizedBox(height: 8),
          _trustRow(Icons.sanitizer_outlined, 'Ozone & UV Sanitized Before Every Dispatch'),
          const SizedBox(height: 8),
          _trustRow(Icons.place_outlined, 'Free Pickup at Fort Road Hub (Leh), Old Manali & Kaza'),
        ],
      ),
    );
  }

  Widget _trustRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.mountainBlue),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 12, color: AppColors.darkCharcoal, fontWeight: FontWeight.w500)),
        ),
      ],
    );
  }

  // ─── Filter Modal Bottom Sheet ────────────────────────────────────────────────
  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: AppColors.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Filter & Sort Gear',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.darkCharcoal),
                        ),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              _selectedSort = SortOption.recommended;
                              _inStockOnly = false;
                              _maxPrice = 500.0;
                            });
                            setState(() {});
                          },
                          child: const Text('Reset', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                    const Divider(),
                    const SizedBox(height: 8),

                    // Sort By
                    const Text('Sort By', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: SortOption.values.map((opt) {
                        final selected = _selectedSort == opt;
                        return ChoiceChip(
                          label: Text(opt.label),
                          selected: selected,
                          selectedColor: AppColors.mountainBlue,
                          labelStyle: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: selected ? Colors.white : AppColors.darkCharcoal,
                          ),
                          onSelected: (val) {
                            setModalState(() => _selectedSort = opt);
                            setState(() {});
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Max Price Slider
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Max Daily Price', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal)),
                        Text('₹${_maxPrice.toInt()}/day', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.mountainBlue)),
                      ],
                    ),
                    Slider(
                      value: _maxPrice,
                      min: 100,
                      max: 500,
                      divisions: 8,
                      activeColor: AppColors.mountainBlue,
                      label: '₹${_maxPrice.toInt()}',
                      onChanged: (val) {
                        setModalState(() => _maxPrice = val);
                        setState(() {});
                      },
                    ),

                    // In Stock Switch
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Available Stock Only', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      subtitle: const Text('Hide items that are out of stock or in maintenance', style: TextStyle(fontSize: 11, color: AppColors.slate)),
                      value: _inStockOnly,
                      activeThumbColor: AppColors.mountainBlue,
                      onChanged: (val) {
                        setModalState(() => _inStockOnly = val);
                        setState(() {});
                      },
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mountainBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(
                          'Show ${_getFilteredAndSortedGear().length} Results',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ─── Mountain Pass Conditions Modal ──────────────────────────────────────────
  void _showPassConditionsModal(BuildContext context) {
    final passes = [
      {'name': 'Khardung La', 'alt': '17,582 ft', 'status': 'OPEN', 'temp': '-4°C', 'color': AppColors.success, 'road': 'Clear, high wind chill, snow at summit'},
      {'name': 'Chang La', 'alt': '17,688 ft', 'status': 'OPEN', 'temp': '-6°C', 'color': AppColors.success, 'road': 'Icy patches, carry warm thermals'},
      {'name': 'Kunzum Pass', 'alt': '14,931 ft', 'status': 'CAUTION', 'temp': '1°C', 'color': AppColors.warning, 'road': 'Glacial water streams high at 2 PM'},
      {'name': 'Rohtang Pass', 'alt': '13,058 ft', 'status': 'OPEN', 'temp': '7°C', 'color': AppColors.success, 'road': 'Intermittent mist & rain overcoat required'},
      {'name': 'Baralacha La', 'alt': '15,910 ft', 'status': 'CAUTION', 'temp': '-2°C', 'color': AppColors.warning, 'road': 'Sub-zero morning black ice'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
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
              const Row(
                children: [
                  Icon(Icons.terrain_rounded, color: AppColors.mountainBlue, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'High Mountain Pass Radar',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.darkCharcoal),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Live terrain, opening status, and wind chill advisory', style: TextStyle(fontSize: 12, color: AppColors.slate)),
              const Divider(height: 20),
              ...passes.map((p) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(p['name'] as String, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal)),
                                  const SizedBox(width: 6),
                                  Text('(${p['alt']})', style: const TextStyle(fontSize: 11, color: AppColors.slate, fontWeight: FontWeight.w600)),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(p['road'] as String, style: const TextStyle(fontSize: 11, color: AppColors.slate)),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: (p['color'] as Color).withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                p['status'] as String,
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: p['color'] as Color),
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(p['temp'] as String, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal)),
                          ],
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Hub Centers Modal ───────────────────────────────────────────────────────
  void _showHubsModal(BuildContext context) {
    final hubs = [
      {'city': 'Leh Hub (Ladakh)', 'address': 'Fort Road, Opposite Polo Ground', 'timing': '8:00 AM – 9:00 PM', 'support': '+91 98765 11001'},
      {'city': 'Old Manali Hub', 'address': 'Club House Road, Old Manali', 'timing': '7:30 AM – 9:30 PM', 'support': '+91 98765 11002'},
      {'city': 'Kaza Hub (Spiti)', 'address': 'Main Market, Near Monastery Road', 'timing': '8:00 AM – 8:00 PM', 'support': '+91 98765 11003'},
      {'city': 'Tapovan Hub (Rishikesh)', 'address': 'Badrinath Road, Near Laxman Jhula', 'timing': '7:00 AM – 10:00 PM', 'support': '+91 98765 11004'},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
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
              const Row(
                children: [
                  Icon(Icons.storefront_rounded, color: AppColors.mountainBlue, size: 22),
                  SizedBox(width: 8),
                  Text(
                    'Expedition Hubs & Centers',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.darkCharcoal),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Free in-person pickup, fitting verification, and exchange', style: TextStyle(fontSize: 12, color: AppColors.slate)),
              const Divider(height: 20),
              ...hubs.map((h) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceMuted,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(h['city']!, style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal)),
                        const SizedBox(height: 3),
                        Text(h['address']!, style: const TextStyle(fontSize: 11.5, color: AppColors.slate)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('🕒 ${h['timing']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.darkCharcoal)),
                            Text('📞 ${h['support']}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mountainBlue)),
                          ],
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Quick Rent Sheet ────────────────────────────────────────────────────────
  void _openQuickRentSheet(BuildContext context, GearModel gear) {
    String selectedSize = gear.sizes.isNotEmpty ? gear.sizes.first : 'M';
    int days = 7;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final rentCost = gear.pricePerDay * days;
            final securityDeposit = gear.pricePerDay * 4;
            final total = rentCost + securityDeposit;

            return Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
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
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            gear.imageUrl,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(width: 60, height: 60, color: AppColors.surfaceMuted),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(gear.name, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                              const SizedBox(height: 2),
                              Text('₹${gear.pricePerDay.toInt()}/day • Hub: ${gear.destination}', style: const TextStyle(fontSize: 12, color: AppColors.slate)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Select Size
                    const Text('Select Your Size', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: gear.sizes.map((s) {
                        final sel = selectedSize == s;
                        return ChoiceChip(
                          label: Text(s),
                          selected: sel,
                          selectedColor: AppColors.mountainBlue,
                          labelStyle: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: sel ? Colors.white : AppColors.darkCharcoal,
                          ),
                          onSelected: (val) {
                            if (val) setSheetState(() => selectedSize = s);
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),

                    // Duration Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Trip Duration', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800)),
                        Text('$days Days', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.mountainBlue)),
                      ],
                    ),
                    Slider(
                      value: days.toDouble(),
                      min: 1,
                      max: 21,
                      divisions: 20,
                      activeColor: AppColors.mountainBlue,
                      label: '$days days',
                      onChanged: (val) => setSheetState(() => days = val.toInt()),
                    ),

                    // Cost Breakdown
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Rental ($days days × ₹${gear.pricePerDay.toInt()})', style: const TextStyle(fontSize: 12, color: AppColors.slate)),
                              Text('₹${rentCost.toInt()}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Refundable Deposit', style: TextStyle(fontSize: 12, color: AppColors.slate)),
                              Text('₹${securityDeposit.toInt()}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                            ],
                          ),
                          const Divider(height: 14),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Total Estimated', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w900)),
                              Text('₹${total.toInt()}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.mountainBlue)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(ctx);
                          final now = DateTime.now();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => BookingScreen(
                                gear: gear,
                                selectedSize: selectedSize,
                                startDate: now.add(const Duration(days: 1)),
                                endDate: now.add(Duration(days: 1 + days)),
                                numberOfDays: days,
                                pricePerDay: gear.pricePerDay,
                                securityDeposit: securityDeposit,
                                totalPrice: total,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.mountainBlue,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Confirm & Reserve Online', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800)),
                            SizedBox(width: 8),
                            Icon(Icons.arrow_forward_rounded, size: 16),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _openChat(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AIChatButton(onQueryAsync: (q) => AIService().getChatResponseAsync(q)),
    );
  }

  String _formatDate(DateTime d) => '${d.day} ${_months[d.month - 1]}';
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
}
