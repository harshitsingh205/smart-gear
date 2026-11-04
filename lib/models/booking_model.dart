class BookingModel {
  final String id;
  final String userId;
  final String userName;
  final String gearId;
  final String gearName;
  final String gearCategory;
  final String size;
  final DateTime startDate;
  final DateTime endDate;
  final int numberOfDays;
  final double pricePerDay;
  final double securityDeposit;
  final double totalPrice;
  final String status; // 'upcoming', 'active', 'completed', 'cancelled'
  final String pickupLocation;
  final DateTime createdAt;
  final String? imageUrl;

  const BookingModel({
    required this.id,
    required this.userId,
    required this.userName,
    required this.gearId,
    required this.gearName,
    required this.gearCategory,
    required this.size,
    required this.startDate,
    required this.endDate,
    required this.numberOfDays,
    required this.pricePerDay,
    required this.securityDeposit,
    required this.totalPrice,
    required this.status,
    required this.pickupLocation,
    required this.createdAt,
    this.imageUrl,
  });

  BookingModel copyWith({
    String? id,
    String? userId,
    String? userName,
    String? gearId,
    String? gearName,
    String? gearCategory,
    String? size,
    DateTime? startDate,
    DateTime? endDate,
    int? numberOfDays,
    double? pricePerDay,
    double? securityDeposit,
    double? totalPrice,
    String? status,
    String? pickupLocation,
    DateTime? createdAt,
    String? imageUrl,
  }) {
    return BookingModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userName: userName ?? this.userName,
      gearId: gearId ?? this.gearId,
      gearName: gearName ?? this.gearName,
      gearCategory: gearCategory ?? this.gearCategory,
      size: size ?? this.size,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      numberOfDays: numberOfDays ?? this.numberOfDays,
      pricePerDay: pricePerDay ?? this.pricePerDay,
      securityDeposit: securityDeposit ?? this.securityDeposit,
      totalPrice: totalPrice ?? this.totalPrice,
      status: status ?? this.status,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      createdAt: createdAt ?? this.createdAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'userName': userName,
      'gearId': gearId,
      'gearName': gearName,
      'gearCategory': gearCategory,
      'size': size,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'numberOfDays': numberOfDays,
      'pricePerDay': pricePerDay,
      'securityDeposit': securityDeposit,
      'totalPrice': totalPrice,
      'status': status,
      'pickupLocation': pickupLocation,
      'createdAt': createdAt.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      userName: json['userName'] as String? ?? 'Rider',
      gearId: json['gearId'] as String,
      gearName: json['gearName'] as String,
      gearCategory: json['gearCategory'] as String? ?? 'Jackets',
      size: json['size'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      numberOfDays: json['numberOfDays'] as int,
      pricePerDay: (json['pricePerDay'] as num).toDouble(),
      securityDeposit: (json['securityDeposit'] as num).toDouble(),
      totalPrice: (json['totalPrice'] as num).toDouble(),
      status: json['status'] as String,
      pickupLocation: json['pickupLocation'] as String? ?? 'Leh Adventure Hub',
      createdAt: DateTime.parse(json['createdAt'] as String),
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
