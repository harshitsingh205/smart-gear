class TripChecklistItem {
  final String title;
  bool isCompleted;
  final bool isGearRental;

  TripChecklistItem({
    required this.title,
    this.isCompleted = false,
    this.isGearRental = true,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'isCompleted': isCompleted,
    'isGearRental': isGearRental,
  };

  factory TripChecklistItem.fromJson(Map<String, dynamic> json) => TripChecklistItem(
    title: json['title'] as String,
    isCompleted: json['isCompleted'] as bool? ?? false,
    isGearRental: json['isGearRental'] as bool? ?? true,
  );
}

class TripModel {
  final String id;
  final String userId;
  final String destination;
  final DateTime startDate;
  final DateTime endDate;
  final String bikeType;
  final int numberOfRiders;
  final String weatherOverview;
  final List<TripChecklistItem> checklist;
  final List<String> recommendedGearIds;

  TripModel({
    required this.id,
    required this.userId,
    required this.destination,
    required this.startDate,
    required this.endDate,
    required this.bikeType,
    required this.numberOfRiders,
    required this.weatherOverview,
    required this.checklist,
    required this.recommendedGearIds,
  });

  int get durationDays => endDate.difference(startDate).inDays + 1;

  TripModel copyWith({
    String? id,
    String? userId,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? bikeType,
    int? numberOfRiders,
    String? weatherOverview,
    List<TripChecklistItem>? checklist,
    List<String>? recommendedGearIds,
  }) {
    return TripModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      destination: destination ?? this.destination,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      bikeType: bikeType ?? this.bikeType,
      numberOfRiders: numberOfRiders ?? this.numberOfRiders,
      weatherOverview: weatherOverview ?? this.weatherOverview,
      checklist: checklist ?? this.checklist,
      recommendedGearIds: recommendedGearIds ?? this.recommendedGearIds,
    );
  }
}
