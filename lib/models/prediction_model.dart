class GearDemandDetail {
  final String categoryName;
  final int predictedCount;
  final int currentInventory;
  final int recommendedInventory;
  final int shortage; // recommendedInventory - currentInventory (if > 0)
  final String demandTrend; // 'Increasing', 'Stable', 'Peak'

  const GearDemandDetail({
    required this.categoryName,
    required this.predictedCount,
    required this.currentInventory,
    required this.recommendedInventory,
    required this.shortage,
    required this.demandTrend,
  });
}

class PredictionModel {
  final String id;
  final String month;
  final String destination;
  final String weather; // 'Cold', 'Very Cold', 'Moderate', 'Rainy'
  final String touristSeason; // 'Peak', 'Shoulder', 'Off-Peak'
  final bool holidayPeriod;
  final int bikeBookings;
  final Map<String, int> predictedDemand;
  final List<GearDemandDetail> demandDetails;
  final String aiInsight;
  final double confidenceScore;
  final DateTime generatedAt;

  const PredictionModel({
    required this.id,
    required this.month,
    required this.destination,
    required this.weather,
    required this.touristSeason,
    required this.holidayPeriod,
    required this.bikeBookings,
    required this.predictedDemand,
    required this.demandDetails,
    required this.aiInsight,
    required this.confidenceScore,
    required this.generatedAt,
  });
}

class AIRecommendationResult {
  final String jacketSize;
  final String glovesSize;
  final String bootsSize;
  final String pantsSize;
  final bool thermalRecommended;
  final bool kneeGuardsRecommended;
  final bool elbowGuardsRecommended;
  final double confidencePercentage;
  final List<String> reasons;
  final List<String> recommendedProductIds;

  const AIRecommendationResult({
    required this.jacketSize,
    required this.glovesSize,
    required this.bootsSize,
    required this.pantsSize,
    required this.thermalRecommended,
    required this.kneeGuardsRecommended,
    required this.elbowGuardsRecommended,
    required this.confidencePercentage,
    required this.reasons,
    required this.recommendedProductIds,
  });
}
