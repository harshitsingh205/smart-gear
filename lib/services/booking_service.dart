import 'package:flutter/foundation.dart';
import '../models/booking_model.dart';

class BookingService extends ChangeNotifier {
  static final BookingService _instance = BookingService._internal();
  factory BookingService() => _instance;
  BookingService._internal() {
    _initMockBookings();
  }

  final List<BookingModel> _bookings = [];

  List<BookingModel> get allBookings => List.unmodifiable(_bookings);

  List<BookingModel> get upcomingBookings =>
      _bookings.where((b) => b.status == 'upcoming').toList();

  List<BookingModel> get activeBookings =>
      _bookings.where((b) => b.status == 'active').toList();

  List<BookingModel> get completedBookings =>
      _bookings.where((b) => b.status == 'completed').toList();

  List<BookingModel> get cancelledBookings =>
      _bookings.where((b) => b.status == 'cancelled').toList();

  void _initMockBookings() {
    final now = DateTime.now();
    _bookings.addAll([
      BookingModel(
        id: 'SG-2026-10245',
        userId: 'usr_001',
        userName: 'Aarav Sharma',
        gearId: 'gear_01',
        gearName: 'All-Terrain Armored Touring Jacket',
        gearCategory: 'Jackets',
        size: 'L',
        startDate: now.add(const Duration(days: 4)),
        endDate: now.add(const Duration(days: 11)),
        numberOfDays: 7,
        pricePerDay: 350.0,
        securityDeposit: 1500.0,
        totalPrice: 3950.0, // (350 * 7) + 1500 deposit
        status: 'upcoming',
        pickupLocation: 'Leh Adventure Hub, Fort Road',
        createdAt: now.subtract(const Duration(days: 3)),
        imageUrl: 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=800&q=80',
      ),
      BookingModel(
        id: 'SG-2026-10246',
        userId: 'usr_001',
        userName: 'Aarav Sharma',
        gearId: 'gear_02',
        gearName: 'Pro-Tour Cold Weather Gauntlet Gloves',
        gearCategory: 'Gloves',
        size: 'L',
        startDate: now.add(const Duration(days: 4)),
        endDate: now.add(const Duration(days: 11)),
        numberOfDays: 7,
        pricePerDay: 150.0,
        securityDeposit: 500.0,
        totalPrice: 1550.0,
        status: 'upcoming',
        pickupLocation: 'Leh Adventure Hub, Fort Road',
        createdAt: now.subtract(const Duration(days: 3)),
        imageUrl: 'https://images.unsplash.com/photo-1622180203374-9524a54b734d?auto=format&fit=crop&w=800&q=80',
      ),
      BookingModel(
        id: 'SG-2026-10238',
        userId: 'usr_002',
        userName: 'Rohan Mehta',
        gearId: 'gear_03',
        gearName: 'Adventure Waterproof Touring Boots',
        gearCategory: 'Boots',
        size: 'UK 9',
        startDate: now.subtract(const Duration(days: 2)),
        endDate: now.add(const Duration(days: 3)),
        numberOfDays: 5,
        pricePerDay: 300.0,
        securityDeposit: 1200.0,
        totalPrice: 2700.0,
        status: 'active',
        pickupLocation: 'Manali Mall Road Station',
        createdAt: now.subtract(const Duration(days: 10)),
        imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80',
      ),
      BookingModel(
        id: 'SG-2026-10232',
        userId: 'usr_003',
        userName: 'Priya Nair',
        gearId: 'gear_05',
        gearName: 'Dual-Sport Modular Adventure Helmet',
        gearCategory: 'Helmets',
        size: 'M',
        startDate: now.subtract(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 5)),
        numberOfDays: 6,
        pricePerDay: 250.0,
        securityDeposit: 1000.0,
        totalPrice: 2500.0,
        status: 'active',
        pickupLocation: 'Leh Adventure Hub, Fort Road',
        createdAt: now.subtract(const Duration(days: 7)),
        imageUrl: 'https://images.unsplash.com/photo-1558981806-ec527fa84c39?auto=format&fit=crop&w=800&q=80',
      ),
      BookingModel(
        id: 'SG-2026-10190',
        userId: 'usr_001',
        userName: 'Aarav Sharma',
        gearId: 'gear_06',
        gearName: 'Bionic Articulated Knee Armor',
        gearCategory: 'Knee Guards',
        size: 'Regular',
        startDate: now.subtract(const Duration(days: 30)),
        endDate: now.subtract(const Duration(days: 23)),
        numberOfDays: 7,
        pricePerDay: 120.0,
        securityDeposit: 500.0,
        totalPrice: 1340.0,
        status: 'completed',
        pickupLocation: 'Spiti Kaza Rental Depot',
        createdAt: now.subtract(const Duration(days: 35)),
        imageUrl: 'https://images.unsplash.com/photo-1549465220-1a8b9238cd48?auto=format&fit=crop&w=800&q=80',
      ),
      BookingModel(
        id: 'SG-2026-10185',
        userId: 'usr_004',
        userName: 'Vikram Joshi',
        gearId: 'gear_08',
        gearName: 'Wind-Block Merino Thermal Base Layer',
        gearCategory: 'Thermal Wear',
        size: 'XL',
        startDate: now.subtract(const Duration(days: 45)),
        endDate: now.subtract(const Duration(days: 38)),
        numberOfDays: 7,
        pricePerDay: 120.0,
        securityDeposit: 400.0,
        totalPrice: 1240.0,
        status: 'completed',
        pickupLocation: 'Leh Adventure Hub, Fort Road',
        createdAt: now.subtract(const Duration(days: 50)),
        imageUrl: 'https://images.unsplash.com/photo-1521572267360-ee0c2909d518?auto=format&fit=crop&w=800&q=80',
      ),
      BookingModel(
        id: 'SG-2026-10170',
        userId: 'usr_005',
        userName: 'Sneha Patel',
        gearId: 'gear_04',
        gearName: 'Cordura Adventure Riding Trousers',
        gearCategory: 'Pants',
        size: '32',
        startDate: now.subtract(const Duration(days: 60)),
        endDate: now.subtract(const Duration(days: 54)),
        numberOfDays: 6,
        pricePerDay: 280.0,
        securityDeposit: 1000.0,
        totalPrice: 2680.0,
        status: 'completed',
        pickupLocation: 'Rishikesh Rider Outpost',
        createdAt: now.subtract(const Duration(days: 65)),
        imageUrl: 'https://images.unsplash.com/photo-1517445312882-bc9910d016b7?auto=format&fit=crop&w=800&q=80',
      ),
      BookingModel(
        id: 'SG-2026-10210',
        userId: 'usr_002',
        userName: 'Rohan Mehta',
        gearId: 'gear_09',
        gearName: 'Heavy-Duty Monsoon Rain Overcoat & Pants',
        gearCategory: 'Jackets',
        size: 'L',
        startDate: now.subtract(const Duration(days: 15)),
        endDate: now.subtract(const Duration(days: 10)),
        numberOfDays: 5,
        pricePerDay: 130.0,
        securityDeposit: 500.0,
        totalPrice: 1150.0,
        status: 'cancelled',
        pickupLocation: 'Manali Mall Road Station',
        createdAt: now.subtract(const Duration(days: 20)),
        imageUrl: 'https://images.unsplash.com/photo-1544441893-675973e31985?auto=format&fit=crop&w=800&q=80',
      ),
      BookingModel(
        id: 'SG-2026-10250',
        userId: 'usr_006',
        userName: 'Karan Thapar',
        gearId: 'gear_01',
        gearName: 'All-Terrain Armored Touring Jacket',
        gearCategory: 'Jackets',
        size: 'XL',
        startDate: now.add(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 18)),
        numberOfDays: 8,
        pricePerDay: 350.0,
        securityDeposit: 1500.0,
        totalPrice: 4300.0,
        status: 'upcoming',
        pickupLocation: 'Leh Adventure Hub, Fort Road',
        createdAt: now.subtract(const Duration(days: 1)),
        imageUrl: 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?auto=format&fit=crop&w=800&q=80',
      ),
      BookingModel(
        id: 'SG-2026-10255',
        userId: 'usr_007',
        userName: 'Tanvi Deshmukh',
        gearId: 'gear_03',
        gearName: 'Adventure Waterproof Touring Boots',
        gearCategory: 'Boots',
        size: 'UK 7',
        startDate: now.add(const Duration(days: 15)),
        endDate: now.add(const Duration(days: 22)),
        numberOfDays: 7,
        pricePerDay: 300.0,
        securityDeposit: 1200.0,
        totalPrice: 3300.0,
        status: 'upcoming',
        pickupLocation: 'Leh Adventure Hub, Fort Road',
        createdAt: now,
        imageUrl: 'https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80',
      ),
    ]);
  }

  BookingModel createBooking({
    required String userId,
    required String userName,
    required String gearId,
    required String gearName,
    required String gearCategory,
    required String size,
    required DateTime startDate,
    required DateTime endDate,
    required double pricePerDay,
    required double securityDeposit,
    String pickupLocation = 'Leh Adventure Hub, Fort Road',
    String? imageUrl,
  }) {
    final days = endDate.difference(startDate).inDays;
    final numberOfDays = days <= 0 ? 1 : days;
    final totalPrice = (pricePerDay * numberOfDays) + securityDeposit;
    final id = 'SG-2026-${10260 + _bookings.length}';

    final newBooking = BookingModel(
      id: id,
      userId: userId,
      userName: userName,
      gearId: gearId,
      gearName: gearName,
      gearCategory: gearCategory,
      size: size,
      startDate: startDate,
      endDate: endDate,
      numberOfDays: numberOfDays,
      pricePerDay: pricePerDay,
      securityDeposit: securityDeposit,
      totalPrice: totalPrice,
      status: 'upcoming',
      pickupLocation: pickupLocation,
      createdAt: DateTime.now(),
      imageUrl: imageUrl,
    );

    _bookings.insert(0, newBooking);
    notifyListeners();
    return newBooking;
  }

  void cancelBooking(String id) {
    final idx = _bookings.indexWhere((b) => b.id == id);
    if (idx != -1) {
      _bookings[idx] = _bookings[idx].copyWith(status: 'cancelled');
      notifyListeners();
    }
  }

  void updateBookingStatus(String id, String newStatus) {
    final idx = _bookings.indexWhere((b) => b.id == id);
    if (idx != -1) {
      _bookings[idx] = _bookings[idx].copyWith(status: newStatus);
      notifyListeners();
    }
  }
}
