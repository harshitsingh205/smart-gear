import 'package:flutter/foundation.dart';
import '../models/gear_model.dart';

class GearService extends ChangeNotifier {
  static final GearService _instance = GearService._internal();
  factory GearService() => _instance;
  GearService._internal() {
    _initMockGear();
  }

  final List<GearModel> _gearList = [];

  List<GearModel> get allGear => List.unmodifiable(_gearList);

  List<GearModel> get popularGear =>
      _gearList.where((g) => g.rating >= 4.7).take(6).toList();

  List<GearModel> searchGear(String query, {GearCategory? category, String? destination}) {
    return _gearList.where((g) {
      final cleanQuery = query.trim().toLowerCase();
      final matchesQuery = cleanQuery.isEmpty ||
          g.name.toLowerCase().contains(cleanQuery) ||
          g.description.toLowerCase().contains(cleanQuery) ||
          g.features.any((f) => f.toLowerCase().contains(cleanQuery));
      final matchesCategory = category == null || g.category == category;
      final matchesDestination = destination == null ||
          destination.isEmpty ||
          destination == 'All' ||
          destination == 'All Hubs' ||
          g.destination.toLowerCase() == destination.toLowerCase() ||
          g.destination.toLowerCase() == 'all';
      return matchesQuery && matchesCategory && matchesDestination;
    }).toList();
  }

  void _initMockGear() {
    _gearList.addAll([
      const GearModel(
        id: 'gear_01',
        name: 'All-Terrain Armored Touring Jacket',
        category: GearCategory.jackets,
        sizes: ['S', 'M', 'L', 'XL', 'XXL'],
        pricePerDay: 350.0,
        suggestedPrice: 400.0,
        totalStock: 200,
        availableStock: 65,
        rentedCount: 120,
        maintenanceCount: 15,
        destination: 'Ladakh',
        rating: 4.9,
        reviewsCount: 128,
        description:
            'Engineered for the extremes of Ladakh and Spiti. Features 600D Cordura construction, CE Level 2 armor at back, shoulders, and elbows, removable thermal liner, and waterproof breathable membrane.',
        features: [
          'CE Level 2 Armor',
          'Removable Thermal Liner',
          '100% Waterproof Membrane',
          'Reflective High-Vis Panels',
          'Ventilation Zippers for Valley Climates'
        ],
        demandLevel: 'High',
        status: 'Available',
        imageUrl: 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=800&q=80',
      ),
      const GearModel(
        id: 'gear_02',
        name: 'Pro-Tour Cold Weather Gauntlet Gloves',
        category: GearCategory.gloves,
        sizes: ['S', 'M', 'L', 'XL'],
        pricePerDay: 150.0,
        suggestedPrice: 175.0,
        totalStock: 250,
        availableStock: 48,
        rentedCount: 190,
        maintenanceCount: 12,
        destination: 'Ladakh',
        rating: 4.8,
        reviewsCount: 94,
        description:
            'Full gauntlet leather and textile gloves with carbon knuckle guards, Thinsulate thermal insulation, and touch-screen compatible fingertips for sub-zero pass crossings like Khardung La.',
        features: [
          'Carbon Knuckle Shield',
          '3M Thinsulate Thermal Insulation',
          'Touchscreen Compatible Fingers',
          'Visor Wiper on Left Thumb',
          'Reinforced Scaphoid Slider'
        ],
        demandLevel: 'High',
        status: 'Available',
        imageUrl: 'https://images.unsplash.com/photo-1622180203374-9524a54b734d?auto=format&fit=crop&w=800&q=80',
      ),
      const GearModel(
        id: 'gear_03',
        name: 'Adventure Waterproof Touring Boots',
        category: GearCategory.boots,
        sizes: ['UK 7', 'UK 8', 'UK 9', 'UK 10', 'UK 11'],
        pricePerDay: 300.0,
        suggestedPrice: 320.0,
        totalStock: 140,
        availableStock: 35,
        rentedCount: 95,
        maintenanceCount: 10,
        destination: 'Ladakh',
        rating: 4.8,
        reviewsCount: 76,
        description:
            'Rugged adventure touring boots with waterproof Drystar membrane, reinforced shin and ankle plates, and vulcanized lugged outsole for rocky river crossings and slippery mud tracks.',
        features: [
          'Waterproof & Breathable Membrane',
          'Rigid Ankle & Shin Protectors',
          'Heavy-Duty Lug Sole for Water Crossings',
          'Quick-Release Cam-Buckles',
          'Ortholite Anti-Fatigue Insole'
        ],
        demandLevel: 'High',
        status: 'Available',
        imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80',
      ),
      const GearModel(
        id: 'gear_04',
        name: 'Cordura Adventure Riding Trousers',
        category: GearCategory.pants,
        sizes: ['30', '32', '34', '36', '38'],
        pricePerDay: 280.0,
        suggestedPrice: 300.0,
        totalStock: 130,
        availableStock: 42,
        rentedCount: 80,
        maintenanceCount: 8,
        destination: 'Ladakh',
        rating: 4.7,
        reviewsCount: 65,
        description:
            'Heavy-duty riding pants with CE knee and hip protectors, adjustable waist, ventilation ports, and high abrasion-resistant seat panel for long saddle hours on remote highways.',
        features: [
          'CE Level 2 Knee & Hip Armor',
          'Waterproof Rain Liner Included',
          'Stretch Panels at Crotch & Lower Back',
          'Grip Panels on Saddle Contact Area',
          'Jacket Connection Zipper'
        ],
        demandLevel: 'Medium',
        status: 'Available',
        imageUrl: 'https://images.unsplash.com/photo-1517445312882-bc9910d016b7?auto=format&fit=crop&w=800&q=80',
      ),
      const GearModel(
        id: 'gear_05',
        name: 'Dual-Sport Modular Adventure Helmet',
        category: GearCategory.helmets,
        sizes: ['M', 'L', 'XL'],
        pricePerDay: 250.0,
        suggestedPrice: 280.0,
        totalStock: 180,
        availableStock: 25,
        rentedCount: 145,
        maintenanceCount: 10,
        destination: 'Ladakh',
        rating: 4.9,
        reviewsCount: 140,
        description:
            'ECE 22.06 and DOT certified dual-sport helmet with aerodynamic sun peak, drop-down sun visor, anti-fog Pinlock 70 lens, and flip-up modular chin bar.',
        features: [
          'ECE 22.06 & DOT Certified',
          'Pinlock Anti-Fog Lens Fitted',
          'Integrated Drop-Down Sun Visor',
          'Emergency Quick-Release Cheek Pads',
          'Intercom Speaker Pockets'
        ],
        demandLevel: 'High',
        status: 'Restock Soon',
        imageUrl: 'https://images.unsplash.com/photo-1558981806-ec527fa84c39?auto=format&fit=crop&w=800&q=80',
      ),
      const GearModel(
        id: 'gear_06',
        name: 'Bionic Articulated Knee Armor',
        category: GearCategory.kneeGuards,
        sizes: ['Regular', 'Large'],
        pricePerDay: 120.0,
        suggestedPrice: 130.0,
        totalStock: 150,
        availableStock: 70,
        rentedCount: 75,
        maintenanceCount: 5,
        destination: 'Ladakh',
        rating: 4.7,
        reviewsCount: 52,
        description:
            'Ergonomically hinged knee-and-shin guard with dual-pivot system mimicking natural knee movement. Offers superior patella protection against gravel impact and falls.',
        features: [
          'Dual-Pivot Articulation',
          'High-Impact Polypropylene Shell',
          'Breathable Bio-Foam Padding',
          'Triple Quick-Snap Straps',
          'Slim Profile Fits Under Riding Pants'
        ],
        demandLevel: 'Medium',
        status: 'Available',
        imageUrl: 'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?auto=format&fit=crop&w=800&q=80',
      ),
      const GearModel(
        id: 'gear_07',
        name: 'Pro-Guard Ergonomic Elbow Protectors',
        category: GearCategory.elbowGuards,
        sizes: ['M', 'L'],
        pricePerDay: 100.0,
        suggestedPrice: 110.0,
        totalStock: 110,
        availableStock: 60,
        rentedCount: 45,
        maintenanceCount: 5,
        destination: 'Ladakh',
        rating: 4.6,
        reviewsCount: 38,
        description:
            'Lightweight slip-on elbow protection with reactive D3O smart foam that stays flexible during movement and locks instantaneously upon impact.',
        features: [
          'CE Certified Impact Protection',
          'Moisture-Wicking Elastic Sleeve',
          'Silicone Anti-Slip Hem Grippers',
          'Ultra-Thin Fits Seamlessly Under Layer'
        ],
        demandLevel: 'Low',
        status: 'Available',
        imageUrl: 'https://images.unsplash.com/photo-1584824486509-112e4181ff6b?auto=format&fit=crop&w=800&q=80',
      ),
      const GearModel(
        id: 'gear_08',
        name: 'Wind-Block Merino Thermal Base Layer',
        category: GearCategory.thermalWear,
        sizes: ['S', 'M', 'L', 'XL'],
        pricePerDay: 120.0,
        suggestedPrice: 140.0,
        totalStock: 160,
        availableStock: 20,
        rentedCount: 135,
        maintenanceCount: 5,
        destination: 'Ladakh',
        rating: 4.9,
        reviewsCount: 112,
        description:
            'Premium 260gsm Merino wool thermal top and bottom with wind-stopping chest panel. Essential for combating sudden altitude drops and freezing rain at 15,000+ feet.',
        features: [
          '100% Merino Wool Fabric',
          'Front Wind-Block Membrane Panel',
          'Natural Odor Resistant & Quick-Drying',
          'Flatlock Seams Prevent Chafing',
          'Warmth-to-Weight Ratio Engineered for Touring'
        ],
        demandLevel: 'High',
        status: 'Restock Soon',
        imageUrl: 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&w=800&q=80',
      ),
      const GearModel(
        id: 'gear_09',
        name: 'Heavy-Duty Monsoon Rain Overcoat & Pants',
        category: GearCategory.jackets,
        sizes: ['M', 'L', 'XL', 'XXL'],
        pricePerDay: 130.0,
        suggestedPrice: 150.0,
        totalStock: 90,
        availableStock: 45,
        rentedCount: 40,
        maintenanceCount: 5,
        destination: 'Manali',
        rating: 4.6,
        reviewsCount: 44,
        description:
            '10,000mm hydrostatic head waterproof suit designed to be worn over full armor during severe Himalayan cloudbursts and Rohtang pass mud crossings.',
        features: [
          '10,000mm Waterproof Rating',
          'Taped Seams Throughout',
          'Expandable Gussets for Boot Clearance',
          'Bright Neon Visibility Strips'
        ],
        demandLevel: 'Medium',
        status: 'Available',
        imageUrl: 'https://images.unsplash.com/photo-1544441893-675973e31985?auto=format&fit=crop&w=800&q=80',
      ),
      const GearModel(
        id: 'gear_10',
        name: 'Sub-Zero Windproof Balaclava & Neck Gaiter',
        category: GearCategory.thermalWear,
        sizes: ['Universal Fit'],
        pricePerDay: 60.0,
        suggestedPrice: 70.0,
        totalStock: 200,
        availableStock: 80,
        rentedCount: 115,
        maintenanceCount: 5,
        destination: 'Ladakh',
        rating: 4.8,
        reviewsCount: 88,
        description:
            'Gore-Tex Infinium windstopper fleece balaclava that stops piercing icy winds entering the helmet collar. Perforated neoprene mouth panel for easy breathing.',
        features: [
          'Windstopper Fleece Neck Protection',
          'Breathing Vents to Prevent Shield Fogging',
          'Moisture Wicking Crown',
          'Hypoallergenic Fabric'
        ],
        demandLevel: 'High',
        status: 'Available',
        imageUrl: 'https://images.unsplash.com/photo-1578632767115-351597cf2477?auto=format&fit=crop&w=800&q=80',
      ),
      // Spiti Hub Products
      const GearModel(
        id: 'gear_11',
        name: 'Spiti Glacial & Loose-Shale Knee Armor',
        category: GearCategory.kneeGuards,
        sizes: ['Regular', 'Large'],
        pricePerDay: 130.0,
        suggestedPrice: 150.0,
        totalStock: 120,
        availableStock: 44,
        rentedCount: 70,
        maintenanceCount: 6,
        destination: 'Spiti',
        rating: 4.8,
        reviewsCount: 61,
        description:
            'Reinforced dual-pivot articulated armor built specifically for the unforgiving loose shale, rocky climbs, and Kunzum pass glacial fordings.',
        features: [
          'High-Density Polyethylene Shield',
          'Multi-Axis Flex Motion',
          'Quick-Latch Neoprene Straps',
          'Impact Dampening Gel Core'
        ],
        demandLevel: 'High',
        status: 'Available',
        imageUrl: 'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?auto=format&fit=crop&w=800&q=80',
      ),
      const GearModel(
        id: 'gear_12',
        name: 'Kunzum Arctic High-Altitude Cordura Jacket',
        category: GearCategory.jackets,
        sizes: ['M', 'L', 'XL'],
        pricePerDay: 380.0,
        suggestedPrice: 420.0,
        totalStock: 110,
        availableStock: 32,
        rentedCount: 72,
        maintenanceCount: 6,
        destination: 'Spiti',
        rating: 4.9,
        reviewsCount: 78,
        description:
            'Engineered for extreme sub-zero Spiti valley rides. Dual-layer insulated liner with CE Level 2 back, chest, and shoulder armor inserts.',
        features: [
          'CE Level 2 Full Armor Set',
          'Waterproof YKK Aquaguard Zips',
          'Thermal Microfleece Collar',
          'Hydration Bladder Pocket'
        ],
        demandLevel: 'High',
        status: 'Available',
        imageUrl: 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=800&q=80',
      ),
      const GearModel(
        id: 'gear_13',
        name: 'Spiti River-Crossing Gore-Tex Boots',
        category: GearCategory.boots,
        sizes: ['UK 8', 'UK 9', 'UK 10', 'UK 11'],
        pricePerDay: 320.0,
        suggestedPrice: 350.0,
        totalStock: 95,
        availableStock: 28,
        rentedCount: 62,
        maintenanceCount: 5,
        destination: 'Spiti',
        rating: 4.8,
        reviewsCount: 54,
        description:
            'Deep cleated sole with 100% waterproof Gore-Tex barrier. Essential for tackling cold torrents at Chhatru and Batal water crossings.',
        features: [
          'Gore-Tex Waterproofing',
          'Steel Shank Sole Support',
          'Molded Shin Guard',
          'Fast Aluminum Cam Buckles'
        ],
        demandLevel: 'High',
        status: 'Available',
        imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80',
      ),
      // Manali Hub Products
      const GearModel(
        id: 'gear_14',
        name: 'Rohtang Alpine Heated Waterproof Gloves',
        category: GearCategory.gloves,
        sizes: ['M', 'L', 'XL'],
        pricePerDay: 180.0,
        suggestedPrice: 210.0,
        totalStock: 130,
        availableStock: 50,
        rentedCount: 74,
        maintenanceCount: 6,
        destination: 'Manali',
        rating: 4.7,
        reviewsCount: 82,
        description:
            'Battery-assisted heated gauntlets designed for freezing temperatures around Rohtang Pass, Atal Tunnel, and Baralacha La.',
        features: [
          'Integrated Carbon Heat Elements',
          'Hipora Waterproof Membrane',
          'Hard Knuckle & Palm Sliders',
          'Adjustable Dual Cuff Seal'
        ],
        demandLevel: 'High',
        status: 'Available',
        imageUrl: 'https://images.unsplash.com/photo-1622180203374-9524a54b734d?auto=format&fit=crop&w=800&q=80',
      ),
      const GearModel(
        id: 'gear_15',
        name: 'All-Season Alpine Waterproof Touring Pants',
        category: GearCategory.pants,
        sizes: ['32', '34', '36', '38'],
        pricePerDay: 260.0,
        suggestedPrice: 290.0,
        totalStock: 85,
        availableStock: 30,
        rentedCount: 50,
        maintenanceCount: 5,
        destination: 'Manali',
        rating: 4.7,
        reviewsCount: 49,
        description:
            'Cordura weather-sealed riding trousers with detachable thermal insulation layer and adjustable CE Level 2 knee armor.',
        features: [
          'Detachable Quilted Thermal Liner',
          'CE Level 2 Knee & Hip Armor',
          'Zip Air-Intakes on Thighs',
          'Heavy Abrasion Saddle Grip'
        ],
        demandLevel: 'Medium',
        status: 'Available',
        imageUrl: 'https://images.unsplash.com/photo-1517445312882-bc9910d016b7?auto=format&fit=crop&w=800&q=80',
      ),
      // Rishikesh Hub Products
      const GearModel(
        id: 'gear_16',
        name: 'Aero-Flow Mesh Summer Highway Jacket',
        category: GearCategory.jackets,
        sizes: ['S', 'M', 'L', 'XL'],
        pricePerDay: 260.0,
        suggestedPrice: 290.0,
        totalStock: 140,
        availableStock: 55,
        rentedCount: 80,
        maintenanceCount: 5,
        destination: 'Rishikesh',
        rating: 4.8,
        reviewsCount: 91,
        description:
            'High-flow 3D mesh chassis engineered for hot valley climates and foothill mountain twists. Includes Level 2 back and shoulder armor.',
        features: [
          'Full-Torso 3D High-Flow Mesh',
          'CE Level 2 Flexible Armor',
          'Detachable Windbreaker Liner',
          'Reflective Luminescent Stripes'
        ],
        demandLevel: 'Medium',
        status: 'Available',
        imageUrl: 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=800&q=80',
      ),
      const GearModel(
        id: 'gear_17',
        name: 'Air-Intake Ventilated Carbon Riding Gloves',
        category: GearCategory.gloves,
        sizes: ['S', 'M', 'L', 'XL'],
        pricePerDay: 110.0,
        suggestedPrice: 130.0,
        totalStock: 160,
        availableStock: 68,
        rentedCount: 88,
        maintenanceCount: 4,
        destination: 'Rishikesh',
        rating: 4.7,
        reviewsCount: 58,
        description:
            'Short-cuff breathable leather and mesh gloves with carbon knuckle shield and TPR finger vents for pleasant foothill highway touring.',
        features: [
          'Direct Air-Scoop Finger Vents',
          'Real Carbon-Fiber Knuckle Plate',
          'Touchscreen Index & Thumb',
          'Reinforced Clarino Palm'
        ],
        demandLevel: 'Medium',
        status: 'Available',
        imageUrl: 'https://images.unsplash.com/photo-1622180203374-9524a54b734d?auto=format&fit=crop&w=800&q=80',
      ),
      const GearModel(
        id: 'gear_18',
        name: 'Dual-Sport Trail Aerodynamic Helmet',
        category: GearCategory.helmets,
        sizes: ['M', 'L', 'XL'],
        pricePerDay: 220.0,
        suggestedPrice: 250.0,
        totalStock: 110,
        availableStock: 42,
        rentedCount: 63,
        maintenanceCount: 5,
        destination: 'Rishikesh',
        rating: 4.8,
        reviewsCount: 67,
        description:
            'Lightweight polycarbonate shell with detachable visor beak and integrated drop-down sunshield. Tested for road-to-trail transitions.',
        features: [
          'ECE 22.06 & ISI Certified',
          'Drop-Down Internal Sun Visor',
          'Removable Peak for Highway Speed',
          'Washable Anti-Bacterial Liner'
        ],
        demandLevel: 'High',
        status: 'Available',
        imageUrl: 'https://images.unsplash.com/photo-1558981806-ec527fa84c39?auto=format&fit=crop&w=800&q=80',
      ),
    ]);
  }

  GearModel? getGearById(String id) {
    try {
      return _gearList.firstWhere((g) => g.id == id);
    } catch (_) {
      return null;
    }
  }

  List<GearModel> filterGear({
    GearCategory? category,
    String? size,
    double? maxPrice,
    String? availability,
    String? searchQuery,
    String? destination,
  }) {
    return _gearList.where((g) {
      if (category != null && g.category != category) return false;
      if (size != null && size.isNotEmpty && size != 'All' && !g.sizes.contains(size)) return false;
      if (maxPrice != null && g.pricePerDay > maxPrice) return false;
      if (availability != null && availability != 'All') {
        if (availability == 'Available' && g.availableStock <= 0) return false;
        if (availability == 'Restock Soon' && g.status != 'Restock Soon') return false;
      }
      if (destination != null && destination != 'All' && g.destination != destination) return false;
      if (searchQuery != null && searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchName = g.name.toLowerCase().contains(query);
        final matchDesc = g.description.toLowerCase().contains(query);
        final matchCat = g.category.label.toLowerCase().contains(query);
        if (!matchName && !matchDesc && !matchCat) return false;
      }
      return true;
    }).toList();
  }

  void addGear(GearModel gear) {
    _gearList.add(gear);
    notifyListeners();
  }

  void updateGear(GearModel gear) {
    final idx = _gearList.indexWhere((g) => g.id == gear.id);
    if (idx != -1) {
      _gearList[idx] = gear;
      notifyListeners();
    }
  }

  void updateStock(String id, int totalStock, int availableStock) {
    final idx = _gearList.indexWhere((g) => g.id == id);
    if (idx != -1) {
      final current = _gearList[idx];
      _gearList[idx] = current.copyWith(
        totalStock: totalStock,
        availableStock: availableStock,
        status: availableStock > 20
            ? 'Available'
            : (availableStock > 0 ? 'Restock Soon' : 'Out of Stock'),
      );
      notifyListeners();
    }
  }

  void markMaintenance(String id, int count) {
    final idx = _gearList.indexWhere((g) => g.id == id);
    if (idx != -1) {
      final current = _gearList[idx];
      final newAvail = (current.availableStock - count).clamp(0, current.totalStock);
      _gearList[idx] = current.copyWith(
        maintenanceCount: current.maintenanceCount + count,
        availableStock: newAvail,
      );
      notifyListeners();
    }
  }

  void updatePrice(String id, double newPrice) {
    final idx = _gearList.indexWhere((g) => g.id == id);
    if (idx != -1) {
      _gearList[idx] = _gearList[idx].copyWith(pricePerDay: newPrice);
      notifyListeners();
    }
  }

  void applyAllSuggestedPrices() {
    for (int i = 0; i < _gearList.length; i++) {
      if (_gearList[i].suggestedPrice > 0) {
        _gearList[i] = _gearList[i].copyWith(
          pricePerDay: _gearList[i].suggestedPrice,
        );
      }
    }
    notifyListeners();
  }

  void deleteGear(String id) {
    _gearList.removeWhere((g) => g.id == id);
    notifyListeners();
  }
}
