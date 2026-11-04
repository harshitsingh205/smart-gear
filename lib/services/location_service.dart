import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

/// Represents a detected location with city/region info
class LocationInfo {
  final double latitude;
  final double longitude;
  final String city;
  final String region;
  final String country;
  final String displayName;

  const LocationInfo({
    required this.latitude,
    required this.longitude,
    required this.city,
    required this.region,
    required this.country,
    required this.displayName,
  });

  /// Infers the nearest SmartGear destination from coordinates
  String get nearestDestination {
    // Ladakh / Leh region
    if (latitude >= 33.5 && latitude <= 35.5 && longitude >= 76.5 && longitude <= 78.5) {
      return 'Ladakh';
    }
    // Spiti Valley
    if (latitude >= 31.5 && latitude <= 32.5 && longitude >= 77.5 && longitude <= 79.0) {
      return 'Spiti';
    }
    // Manali / Kullu
    if (latitude >= 31.5 && latitude <= 32.5 && longitude >= 76.5 && longitude <= 77.5) {
      return 'Manali';
    }
    // Rishikesh / Haridwar
    if (latitude >= 29.5 && latitude <= 30.5 && longitude >= 77.8 && longitude <= 78.5) {
      return 'Rishikesh';
    }
    return 'Ladakh'; // Default
  }

  /// Altitude-based weather guess
  String get suggestedWeather {
    if (latitude >= 33.5) return 'Very Cold';
    if (latitude >= 32.0) return 'Cold';
    return 'Moderate';
  }
}

class LocationService extends ChangeNotifier {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  LocationInfo? _locationInfo;
  bool _isLoading = false;
  String? _errorMessage;

  LocationInfo? get locationInfo => _locationInfo;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasLocation => _locationInfo != null;

  /// Fetch user's current location and reverse-geocode to city name
  Future<LocationInfo?> detectLocation() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        // Fallback: use IP-based geolocation
        return await _detectViaIP();
      }

      // Get GPS coordinates
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 10),
        ),
      );

      // Reverse geocode using free API
      final info = await _reverseGeocode(position.latitude, position.longitude);
      _locationInfo = info;
      notifyListeners();
      return info;
    } catch (e) {
      debugPrint('GPS location error: $e');
      // Fallback to IP-based location
      return await _detectViaIP();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Reverse geocode lat/lon to city name using nominatim (free, no key required)
  Future<LocationInfo?> _reverseGeocode(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json',
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'SmartGearApp/1.0 (smartgear@gmail.com)',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final address = data['address'] as Map<String, dynamic>? ?? {};
        final city = (address['city'] as String?) ??
            (address['town'] as String?) ??
            (address['village'] as String?) ??
            (address['county'] as String?) ??
            'Unknown City';
        final state = (address['state'] as String?) ?? '';
        final country = (address['country'] as String?) ?? 'India';

        final info = LocationInfo(
          latitude: lat,
          longitude: lon,
          city: city,
          region: state,
          country: country,
          displayName: '$city, $state',
        );
        _locationInfo = info;
        return info;
      }
    } catch (e) {
      debugPrint('Reverse geocoding error: $e');
    }
    return _fallbackLocation();
  }

  /// IP-based geolocation fallback using free ipapi.co
  Future<LocationInfo?> _detectViaIP() async {
    try {
      final response = await http
          .get(Uri.parse('https://ipapi.co/json/'))
          .timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final lat = (data['latitude'] as num?)?.toDouble() ?? 28.6;
        final lon = (data['longitude'] as num?)?.toDouble() ?? 77.2;
        final city = (data['city'] as String?) ?? 'Delhi';
        final region = (data['region'] as String?) ?? 'Delhi';
        final country = (data['country_name'] as String?) ?? 'India';

        final info = LocationInfo(
          latitude: lat,
          longitude: lon,
          city: city,
          region: region,
          country: country,
          displayName: '$city, $region',
        );
        _locationInfo = info;
        notifyListeners();
        return info;
      }
    } catch (e) {
      debugPrint('IP geolocation error: $e');
    }
    return _fallbackLocation();
  }

  /// Hardcoded fallback when all detection fails
  LocationInfo _fallbackLocation() {
    const info = LocationInfo(
      latitude: 28.6139,
      longitude: 77.2090,
      city: 'New Delhi',
      region: 'Delhi',
      country: 'India',
      displayName: 'New Delhi, Delhi',
    );
    _locationInfo = info;
    notifyListeners();
    return info;
  }

  /// Returns gear category suggestions based on current location + season
  List<LocationGearSuggestion> getGearSuggestionsForLocation() {
    final loc = _locationInfo;
    if (loc == null) return _defaultSuggestions();

    final month = DateTime.now().month;
    final dest = loc.nearestDestination;

    // Near Himalayan destinations
    if (dest == 'Ladakh' || dest == 'Spiti') {
      return [
        LocationGearSuggestion(
          icon: '🏔️',
          title: 'Thermal Base Layer',
          reason: 'Sub-zero winds at 17,500+ ft passes',
          priority: 'Must Have',
          priceRange: '₹199–₹399/day',
          isUrgent: true,
        ),
        LocationGearSuggestion(
          icon: '🧥',
          title: 'CE Level 2 Armored Jacket',
          reason: 'Mandatory for mountain gravel roads',
          priority: 'Must Have',
          priceRange: '₹349–₹599/day',
          isUrgent: true,
        ),
        LocationGearSuggestion(
          icon: '🥾',
          title: 'Waterproof Adventure Boots',
          reason: 'Essential for river crossings (nalas)',
          priority: 'Must Have',
          priceRange: '₹249–₹449/day',
          isUrgent: false,
        ),
        LocationGearSuggestion(
          icon: '🧤',
          title: 'Gauntlet Gloves',
          reason: 'Wind-block knuckle protection above 14,000 ft',
          priority: 'Recommended',
          priceRange: '₹149–₹299/day',
          isUrgent: false,
        ),
      ];
    }

    if (dest == 'Manali') {
      final bool isMonsoon = month >= 7 && month <= 9;
      return [
        LocationGearSuggestion(
          icon: '🧥',
          title: 'All-Weather Riding Jacket',
          reason: 'Rohtang Pass conditions year-round',
          priority: 'Must Have',
          priceRange: '₹299–₹549/day',
          isUrgent: true,
        ),
        if (isMonsoon)
          LocationGearSuggestion(
            icon: '🌧️',
            title: 'Waterproof Rain Suit',
            reason: 'Heavy monsoon rains in Jul–Sep',
            priority: 'Must Have',
            priceRange: '₹199–₹349/day',
            isUrgent: true,
          ),
        LocationGearSuggestion(
          icon: '🪖',
          title: 'Modular Helmet',
          reason: 'Flip-up visor ideal for mountain checkposts',
          priority: 'Recommended',
          priceRange: '₹199–₹399/day',
          isUrgent: false,
        ),
      ];
    }

    if (dest == 'Rishikesh') {
      return [
        LocationGearSuggestion(
          icon: '🧥',
          title: 'Mesh Riding Jacket',
          reason: 'Hot & humid Garhwal summer riding',
          priority: 'Recommended',
          priceRange: '₹199–₹399/day',
          isUrgent: false,
        ),
        LocationGearSuggestion(
          icon: '🧤',
          title: 'Short Sports Gloves',
          reason: 'Lightweight grip for highway cruising',
          priority: 'Recommended',
          priceRange: '₹99–₹199/day',
          isUrgent: false,
        ),
      ];
    }

    return _defaultSuggestions();
  }

  List<LocationGearSuggestion> _defaultSuggestions() => [
        LocationGearSuggestion(
          icon: '🧥',
          title: 'Riding Jacket',
          reason: 'Essential protection for every ride',
          priority: 'Recommended',
          priceRange: '₹299–₹549/day',
          isUrgent: false,
        ),
        LocationGearSuggestion(
          icon: '🪖',
          title: 'Full-Face Helmet',
          reason: 'Maximum head protection',
          priority: 'Must Have',
          priceRange: '₹199–₹399/day',
          isUrgent: false,
        ),
      ];
}

/// A gear suggestion card driven by location context
class LocationGearSuggestion {
  final String icon;
  final String title;
  final String reason;
  final String priority;
  final String priceRange;
  final bool isUrgent;

  const LocationGearSuggestion({
    required this.icon,
    required this.title,
    required this.reason,
    required this.priority,
    required this.priceRange,
    required this.isUrgent,
  });
}
