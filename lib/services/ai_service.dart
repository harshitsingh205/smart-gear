import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/prediction_model.dart';
import 'firebase_config.dart';

class AIService extends ChangeNotifier {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  /// Gemini API key is loaded from FirebaseConfig by default, or overridden by user
  static String _customGeminiKey = '';
  static String get geminiApiKey =>
      _customGeminiKey.isNotEmpty ? _customGeminiKey : FirebaseConfig.geminiApiKey;
  static String get _model => FirebaseConfig.geminiModel;
  static bool get hasGeminiKey => geminiApiKey.isNotEmpty;

  static void setGeminiApiKey(String key) {
    _customGeminiKey = key.trim();
    debugPrint('Gemini key configured: ${_customGeminiKey.isNotEmpty}');
  }

  /// Simulates AI sizing & gear bundle recommendation based on rider body metrics,
  /// destination weather profiles, duration, and riding experience.
  Future<AIRecommendationResult> getGearRecommendation({
    required double heightCm,
    required double weightKg,
    required int age,
    required String destination,
    required int durationDays,
    required String travelMonth,
    required String expectedWeather,
    required String ridingExperience,
  }) async {
    // Brief inference latency simulation
    await Future.delayed(const Duration(milliseconds: 300));

    // 1. Anthropometric Sizing Inference
    String jacketSize = 'L';
    String pantsSize = '34';
    String glovesSize = 'L';
    String bootsSize = 'UK 9';

    if (heightCm < 168) {
      jacketSize = 'S';
      pantsSize = '30';
      glovesSize = 'S';
      bootsSize = 'UK 7';
    } else if (heightCm < 176) {
      jacketSize = weightKg > 78 ? 'L' : 'M';
      pantsSize = weightKg > 78 ? '34' : '32';
      glovesSize = 'M';
      bootsSize = 'UK 8';
    } else if (heightCm < 184) {
      jacketSize = weightKg > 86 ? 'XL' : 'L';
      pantsSize = weightKg > 86 ? '36' : '34';
      glovesSize = 'L';
      bootsSize = 'UK 9';
    } else {
      jacketSize = weightKg > 92 ? 'XXL' : 'XL';
      pantsSize = weightKg > 92 ? '38' : '36';
      glovesSize = 'XL';
      bootsSize = 'UK 10';
    }

    // 2. Route & Climate Analysis
    final isExtremeCold = expectedWeather == 'Very Cold' ||
        expectedWeather == 'Cold' ||
        destination == 'Ladakh' ||
        destination == 'Spiti';

    final isRainy = expectedWeather == 'Rainy' ||
        travelMonth == 'July' ||
        travelMonth == 'August';

    final bool thermalRecommended = isExtremeCold || durationDays >= 5;
    final bool kneeGuardsRecommended = true;
    final bool elbowGuardsRecommended = ridingExperience == 'Beginner';

    // 3. Contextual Reasons Engine
    final List<String> reasons = [];

    reasons.add(
      'Based on your height ($heightCm cm) and weight ($weightKg kg), size $jacketSize allows a snug aerodynamic fit while comfortably accommodating thermal midlayers.',
    );

    if (destination == 'Ladakh' || destination == 'Spiti') {
      reasons.add(
        'High Himalayan passes (Khardung La, Tanglang La at 17,500+ ft) experience severe sub-zero wind chill. Thermal wind-block base layers are critical to avoid hypothermia.',
      );
      reasons.add(
        'Articulated knee guards with dual-pivot hinge offer essential protection against unpredictable high-altitude gravel slides and river water crossings (pagal nalas).',
      );
    } else {
      reasons.add(
        'Optimized for $destination highway cruising and canyon twisties with breathable abrasion-resistant Cordura construction.',
      );
    }

    if (isRainy) {
      reasons.add(
        'Monsoon forecast detected for $travelMonth. Full waterproof taped-seam rain gear layer included.',
      );
    }

    if (ridingExperience == 'Beginner') {
      reasons.add(
        'Added Level 2 impact elbow and knee armor bundle for heightened confidence and safety margin on unpaved gravel.',
      );
    }

    double confidence = 94.0;
    if (age > 25 && age < 45) confidence += 2.5;
    if (durationDays >= 7) confidence += 1.5;

    return AIRecommendationResult(
      jacketSize: jacketSize,
      glovesSize: glovesSize,
      bootsSize: bootsSize,
      pantsSize: pantsSize,
      thermalRecommended: thermalRecommended,
      kneeGuardsRecommended: kneeGuardsRecommended,
      elbowGuardsRecommended: elbowGuardsRecommended,
      confidencePercentage: confidence.clamp(88.0, 98.5),
      reasons: reasons,
      recommendedProductIds: ['gear_01', 'gear_02', 'gear_03', 'gear_06', 'gear_08'],
    );
  }

  /// Simulates AI Demand Prediction for Admin & Fleet operations
  Future<PredictionModel> predictDemand({
    required String destination,
    required String month,
    required String weather,
    required String touristSeason,
    required bool holidayPeriod,
    required int bikeBookings,
  }) async {
    await Future.delayed(const Duration(milliseconds: 350));

    double multiplier = 1.0;
    if (touristSeason == 'Peak') multiplier *= 1.45;
    if (touristSeason == 'Shoulder') multiplier *= 1.15;
    if (touristSeason == 'Off-Peak') multiplier *= 0.65;
    if (holidayPeriod) multiplier *= 1.25;

    final bookingFactor = (bikeBookings / 100.0).clamp(0.5, 2.5);
    multiplier *= bookingFactor;

    final jackets = (100 * multiplier).round().clamp(40, 260);
    final gloves = (115 * multiplier).round().clamp(50, 310);
    final boots = (75 * multiplier).round().clamp(30, 210);
    final pants = (65 * multiplier).round().clamp(25, 180);
    final helmets = (110 * multiplier).round().clamp(45, 290);
    final thermal = (95 * multiplier).round().clamp(35, 250);

    final details = [
      GearDemandDetail(
        categoryName: 'Riding Jackets',
        predictedCount: jackets,
        currentInventory: 65,
        recommendedInventory: (jackets * 1.15).round(),
        shortage: ((jackets * 1.15).round() - 65).clamp(0, 300),
        demandTrend: touristSeason == 'Peak' ? 'Peak' : 'Increasing',
      ),
      GearDemandDetail(
        categoryName: 'Riding Gloves',
        predictedCount: gloves,
        currentInventory: 48,
        recommendedInventory: (gloves * 1.15).round(),
        shortage: ((gloves * 1.15).round() - 48).clamp(0, 300),
        demandTrend: 'Peak',
      ),
      GearDemandDetail(
        categoryName: 'Riding Boots',
        predictedCount: boots,
        currentInventory: 35,
        recommendedInventory: (boots * 1.15).round(),
        shortage: ((boots * 1.15).round() - 35).clamp(0, 300),
        demandTrend: 'Increasing',
      ),
      GearDemandDetail(
        categoryName: 'Riding Pants',
        predictedCount: pants,
        currentInventory: 42,
        recommendedInventory: (pants * 1.10).round(),
        shortage: ((pants * 1.10).round() - 42).clamp(0, 300),
        demandTrend: 'Stable',
      ),
      GearDemandDetail(
        categoryName: 'Modular Helmets',
        predictedCount: helmets,
        currentInventory: 25,
        recommendedInventory: (helmets * 1.20).round(),
        shortage: ((helmets * 1.20).round() - 25).clamp(0, 300),
        demandTrend: 'Peak',
      ),
      GearDemandDetail(
        categoryName: 'Thermal Base Layers',
        predictedCount: thermal,
        currentInventory: 20,
        recommendedInventory: (thermal * 1.25).round(),
        shortage: ((thermal * 1.25).round() - 20).clamp(0, 300),
        demandTrend: 'Peak',
      ),
    ];

    String insight =
        'Expected riding jacket and thermal layer demand is surging for $destination in $month ($touristSeason Season). '
        'High mountain passes like Khardung La and Chang La require heavy thermal layers. '
        'Recommended buffer of +15% above current stock to prevent tourist stockouts.';

    return PredictionModel(
      id: 'pred_${DateTime.now().millisecondsSinceEpoch}',
      month: month,
      destination: destination,
      weather: weather,
      touristSeason: touristSeason,
      holidayPeriod: holidayPeriod,
      bikeBookings: bikeBookings,
      predictedDemand: {
        'Jackets': jackets,
        'Gloves': gloves,
        'Boots': boots,
        'Pants': pants,
        'Helmets': helmets,
        'Thermal': thermal,
      },
      demandDetails: details,
      aiInsight: insight,
      confidenceScore: 94.2,
      generatedAt: DateTime.now(),
    );
  }

  /// Real-Time Gemini AI Chatbot with graceful expert knowledge fallback
  Future<String> getChatResponseAsync(String query) async {
    if (hasGeminiKey) {
      try {
        final url = Uri.parse(
          'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent',
        );

        final response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'X-goog-api-key': geminiApiKey,
          },
          body: jsonEncode({
            'system_instruction': {
              'parts': [
                {
                  'text':
                      'You are Smart Gear AI, an expert motorcycle adventure tour consultant and safety engineer '
                      'specializing in Himalayan expeditions (Ladakh, Khardung La, Tanglang La, Chang La, Spiti Valley, Rohtang Pass, Manali, Rishikesh). '
                      'Provide concise, practical, well-formatted advice on CE Level 2 armor, thermal layering, sizing, boot waterproofing, altitude safety, and gear rental availability.'
                }
              ]
            },
            'contents': [
              {
                'parts': [
                  {'text': query}
                ]
              }
            ]
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final candidates = data['candidates'] as List?;
          if (candidates != null && candidates.isNotEmpty) {
            final text = candidates[0]?['content']?['parts']?[0]?['text'] as String?;
            if (text != null && text.trim().isNotEmpty) {
              return text.trim();
            }
          }
        }
      } catch (e) {
        debugPrint('Gemini API call exception: $e');
      }
    }

    // Fallback to domain expert response engine
    return getChatResponse(query);
  }

  /// Synchronous fallback response engine with deep motorcycle touring knowledge
  String getChatResponse(String query) {
    final q = query.toLowerCase();

    if (q.contains('ladakh') || q.contains('gear do i need') || q.contains('what gear')) {
      return 'For a Ladakh motorcycle expedition, you need the Essential Armor Trio:\n'
          '1. CE Level 2 Armored All-Weather Jacket (with removable thermal liner)\n'
          '2. Thermal Gauntlet Gloves (wind-block with carbon knuckle shield)\n'
          '3. Waterproof High-Ankle Adventure Boots (vital for water crossings)\n'
          '4. Articulated Knee Guards & Windproof Thermal Base Layer.\n'
          'Our AI Recommendation tool can calculate your exact sizes in 30 seconds!';
    } else if (q.contains('jacket size') || q.contains('which size') || q.contains('size')) {
      return 'Jacket sizing for Himalayan rides should allow room for a thermal midlayer underneath.\n'
          '• Height 165–172 cm (60–70 kg): Size M\n'
          '• Height 173–182 cm (70–84 kg): Size L\n'
          '• Height 183+ cm (85+ kg): Size XL/XXL\n'
          'You can enter your exact height and weight in our "AI Recommendation" screen for tailored fit!';
    } else if (q.contains('7-day') || q.contains('pack') || q.contains('packing')) {
      return 'For a 7-day trip, pack light but protect against cold:\n'
          '• 1x Rented Riding Jacket + Pants\n'
          '• 1x Cold Weather Gauntlet Gloves + 1x Spare Light Gloves\n'
          '• 2x Merino Wool Thermal Sets (odor-resistant)\n'
          '• 1x Waterproof Rain Oversuit\n'
          '• Balaclava, Neck Gaiter, and Microfiber Visor Cleaner\n'
          '• Basic First-Aid & High-Altitude Acclimatization Tablets (Diamox).';
    } else if (q.contains('thermal') || q.contains('cold')) {
      return 'Yes, thermal base and mid-layers are HIGHLY recommended! Crossing passes like Khardung La (17,582 ft) or Tanglang La (17,480 ft) exposes you to sub-zero wind chills even in peak summer (July). Wind-stopping merino wool thermal wear prevents severe fatigue.';
    } else if (q.contains('available') || q.contains('stock') || q.contains('rent')) {
      return 'We currently have 65+ Armored Jackets, 48+ Gauntlet Gloves, 35+ Waterproof Boots, and 25+ Modular Helmets available for instant pickup at our Leh Adventure Hub (Fort Road). You can filter gear by size and reserve with zero cancellation fees up to 48 hours prior!';
    } else {
      return 'I am Smart Gear AI, your motorcycle adventure co-pilot! I can help you with recommended gear lists, size fitting, destination weather conditions, packing checklists, and rental availability. What would you like to know?';
    }
  }
}
