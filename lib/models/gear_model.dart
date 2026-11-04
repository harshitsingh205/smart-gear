enum GearCategory {
  jackets('Jackets'),
  pants('Pants'),
  boots('Boots'),
  gloves('Gloves'),
  helmets('Helmets'),
  kneeGuards('Knee Guards'),
  elbowGuards('Elbow Guards'),
  thermalWear('Thermal Wear');

  final String label;
  const GearCategory(this.label);

  static GearCategory fromString(String val) {
    return GearCategory.values.firstWhere(
      (e) => e.name.toLowerCase() == val.toLowerCase() || e.label.toLowerCase() == val.toLowerCase(),
      orElse: () => GearCategory.jackets,
    );
  }
}

class GearModel {
  final String id;
  final String name;
  final GearCategory category;
  final List<String> sizes;
  final double pricePerDay;
  final double suggestedPrice;
  final int totalStock;
  final int availableStock;
  final int rentedCount;
  final int maintenanceCount;
  final String destination;
  final double rating;
  final int reviewsCount;
  final String description;
  final List<String> features;
  final String demandLevel; // 'Low', 'Medium', 'High'
  final String status; // 'Available', 'Restock Soon', 'Maintenance'
  final String imageUrl;

  const GearModel({
    required this.id,
    required this.name,
    required this.category,
    required this.sizes,
    required this.pricePerDay,
    this.suggestedPrice = 0,
    required this.totalStock,
    required this.availableStock,
    this.rentedCount = 0,
    this.maintenanceCount = 0,
    this.destination = 'Ladakh',
    this.rating = 4.8,
    this.reviewsCount = 42,
    required this.description,
    required this.features,
    this.demandLevel = 'High',
    this.status = 'Available',
    required this.imageUrl,
  });

  bool get isAvailable => availableStock > 0 && status == 'Available';

  GearModel copyWith({
    String? id,
    String? name,
    GearCategory? category,
    List<String>? sizes,
    double? pricePerDay,
    double? suggestedPrice,
    int? totalStock,
    int? availableStock,
    int? rentedCount,
    int? maintenanceCount,
    String? destination,
    double? rating,
    int? reviewsCount,
    String? description,
    List<String>? features,
    String? demandLevel,
    String? status,
    String? imageUrl,
  }) {
    return GearModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      sizes: sizes ?? this.sizes,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      suggestedPrice: suggestedPrice ?? this.suggestedPrice,
      totalStock: totalStock ?? this.totalStock,
      availableStock: availableStock ?? this.availableStock,
      rentedCount: rentedCount ?? this.rentedCount,
      maintenanceCount: maintenanceCount ?? this.maintenanceCount,
      destination: destination ?? this.destination,
      rating: rating ?? this.rating,
      reviewsCount: reviewsCount ?? this.reviewsCount,
      description: description ?? this.description,
      features: features ?? this.features,
      demandLevel: demandLevel ?? this.demandLevel,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category.name,
      'sizes': sizes,
      'pricePerDay': pricePerDay,
      'suggestedPrice': suggestedPrice,
      'totalStock': totalStock,
      'availableStock': availableStock,
      'rentedCount': rentedCount,
      'maintenanceCount': maintenanceCount,
      'destination': destination,
      'rating': rating,
      'reviewsCount': reviewsCount,
      'description': description,
      'features': features,
      'demandLevel': demandLevel,
      'status': status,
      'imageUrl': imageUrl,
    };
  }

  factory GearModel.fromJson(Map<String, dynamic> json) {
    return GearModel(
      id: json['id'] as String,
      name: json['name'] as String,
      category: GearCategory.fromString(json['category'] as String),
      sizes: List<String>.from(json['sizes'] as List),
      pricePerDay: (json['pricePerDay'] as num).toDouble(),
      suggestedPrice: (json['suggestedPrice'] as num?)?.toDouble() ?? 0,
      totalStock: json['totalStock'] as int,
      availableStock: json['availableStock'] as int,
      rentedCount: json['rentedCount'] as int? ?? 0,
      maintenanceCount: json['maintenanceCount'] as int? ?? 0,
      destination: json['destination'] as String? ?? 'Ladakh',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      reviewsCount: json['reviewsCount'] as int? ?? 40,
      description: json['description'] as String? ?? '',
      features: List<String>.from(json['features'] as List? ?? []),
      demandLevel: json['demandLevel'] as String? ?? 'Medium',
      status: json['status'] as String? ?? 'Available',
      imageUrl: json['imageUrl'] as String? ?? '',
    );
  }
}
