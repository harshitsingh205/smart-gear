import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../app/theme.dart';
import '../../models/trip_model.dart';

class TripScreen extends StatefulWidget {
  const TripScreen({super.key});

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  bool _showPlanner = false;
  TripModel? _currentTrip;

  // Form state
  String _destination = 'Ladakh';
  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  DateTime _endDate = DateTime.now().add(const Duration(days: 14));
  String _bikeType = 'Royal Enfield Himalayan';
  int _numberOfRiders = 1;

  final _bikeTypes = [
    'Royal Enfield Himalayan',
    'Royal Enfield Classic 350',
    'Bajaj Dominar 400',
    'KTM Adventure 390',
    'BMW GS 310',
    'Other',
  ];

  void _planTrip() {
    final checklist = [
      TripChecklistItem(title: 'Riding Jacket', isCompleted: true),
      TripChecklistItem(title: 'Riding Gloves', isCompleted: true),
      TripChecklistItem(title: 'Riding Boots', isCompleted: true),
      TripChecklistItem(title: 'Knee Guards', isCompleted: true),
      TripChecklistItem(title: 'Thermal Base Layer', isCompleted: false),
      TripChecklistItem(title: 'Rain Protection Suit', isCompleted: false),
      TripChecklistItem(title: 'Neck Gaiter & Balaclava', isCompleted: false, isGearRental: false),
      TripChecklistItem(title: 'First Aid Kit', isCompleted: false, isGearRental: false),
      TripChecklistItem(title: 'Emergency Contacts Card', isCompleted: false, isGearRental: false),
      TripChecklistItem(title: 'Altitude Sickness Medication', isCompleted: false, isGearRental: false),
    ];

    setState(() {
      _currentTrip = TripModel(
        id: 'trip_${DateTime.now().millisecondsSinceEpoch}',
        userId: 'usr_001',
        destination: _destination,
        startDate: _startDate,
        endDate: _endDate,
        bikeType: _bikeType,
        numberOfRiders: _numberOfRiders,
        weatherOverview: _getWeatherOverview(_destination),
        checklist: checklist,
        recommendedGearIds: ['gear_01', 'gear_02', 'gear_03', 'gear_06', 'gear_08'],
      );
      _showPlanner = true;
    });
  }

  String _getWeatherOverview(String dest) {
    const map = {
      'Ladakh': '🌡 Peak summer: 15°C (day) / -5°C (night at passes). Wind chill at Khardung La: -15°C. Thermal layers critical.',
      'Manali': '🌡 Summer: 20°C (day) / 5°C (night). Rainy season July-Aug. Rohtang Pass may be closed during heavy snowfall.',
      'Spiti': '🌡 Extreme terrain. 10°C (day) / -8°C (night). Very remote. Full armor + thermal essential.',
      'Rishikesh': '🌡 Moderate. 28°C (day) / 18°C (night). River crossings possible. Waterproof boots recommended.',
      'Other': '🌡 Weather data unavailable. Pack layers and full protective gear.',
    };
    return map[dest] ?? map['Other']!;
  }

  Future<void> _pickDate(bool isStart) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : _endDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppColors.mountainBlue),
        ),
        child: child!,
      ),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        if (_endDate.isBefore(_startDate.add(const Duration(days: 1)))) {
          _endDate = _startDate.add(const Duration(days: 1));
        }
      } else {
        _endDate = picked;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Trip Planner'),
        automaticallyImplyLeading: false,
        actions: [
          if (_showPlanner)
            TextButton(
              onPressed: () => setState(() {
                _showPlanner = false;
                _currentTrip = null;
              }),
              child: const Text('New Trip', style: TextStyle(color: AppColors.mountainBlue)),
            ),
        ],
      ),
      body: _showPlanner && _currentTrip != null
          ? _TripDetailView(trip: _currentTrip!)
          : _buildPlannerForm(),
    );
  }

  Widget _buildPlannerForm() {
    final df = DateFormat('dd MMM yyyy');
    final days = _endDate.difference(_startDate).inDays + 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Hero
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.mountainBlue, AppColors.mountainBlueDark],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Plan Your Adventure',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                      SizedBox(height: 6),
                      Text('Enter trip details for AI gear recommendations',
                          style: TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
                Icon(Icons.map, color: Colors.white, size: 48),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Destination
          const Text('Destination', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ['Ladakh', 'Manali', 'Spiti', 'Rishikesh'].map((d) {
              final sel = _destination == d;
              return GestureDetector(
                onTap: () => setState(() => _destination = d),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.mountainBlue : AppColors.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: sel ? AppColors.mountainBlue : AppColors.border),
                  ),
                  child: Text(d, style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: sel ? Colors.white : AppColors.darkCharcoal)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Dates
          const Text('Trip Dates', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal)),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _DateTile('Start', df.format(_startDate), () => _pickDate(true))),
              const SizedBox(width: 12),
              Expanded(child: _DateTile('End', df.format(_endDate), () => _pickDate(false))),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.mountainBlueLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text('Duration: $days days',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.mountainBlue)),
          ),
          const SizedBox(height: 20),

          // Bike Type
          const Text('Bike Type', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DropdownButton<String>(
              value: _bikeType,
              isExpanded: true,
              underline: const SizedBox(),
              onChanged: (v) => setState(() => _bikeType = v!),
              items: _bikeTypes.map((t) => DropdownMenuItem(value: t, child: Text(t, style: const TextStyle(fontSize: 14)))).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Number of Riders
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Number of Riders', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal)),
              Row(
                children: [
                  IconButton(
                    onPressed: () { if (_numberOfRiders > 1) setState(() => _numberOfRiders--); },
                    icon: const Icon(Icons.remove_circle_outline, color: AppColors.mountainBlue),
                  ),
                  Container(
                    width: 36,
                    alignment: Alignment.center,
                    child: Text('$_numberOfRiders',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal)),
                  ),
                  IconButton(
                    onPressed: () { if (_numberOfRiders < 20) setState(() => _numberOfRiders++); },
                    icon: const Icon(Icons.add_circle_outline, color: AppColors.mountainBlue),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _planTrip,
              icon: const Icon(Icons.explore),
              label: const Text('Plan This Trip', style: TextStyle(fontSize: 16)),
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _DateTile(this.label, this.value, this.onTap);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.slate)),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: AppColors.mountainBlue),
                const SizedBox(width: 6),
                Flexible(child: Text(value,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TripDetailView extends StatefulWidget {
  final TripModel trip;

  const _TripDetailView({required this.trip});

  @override
  State<_TripDetailView> createState() => _TripDetailViewState();
}

class _TripDetailViewState extends State<_TripDetailView> {
  late List<TripChecklistItem> _checklist;

  @override
  void initState() {
    super.initState();
    _checklist = List.from(widget.trip.checklist);
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('dd MMM yyyy');
    final trip = widget.trip;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Trip Header
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.darkCharcoal,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, color: AppColors.mountainBlueLight, size: 20),
                    const SizedBox(width: 6),
                    Text(trip.destination,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.mountainBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${trip.durationDays} Days',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text('${df.format(trip.startDate)} – ${df.format(trip.endDate)}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
                const SizedBox(height: 4),
                Text('${trip.bikeType} • ${trip.numberOfRiders} Rider${trip.numberOfRiders > 1 ? 's' : ''}',
                    style: const TextStyle(color: Colors.white54, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Weather
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.mountainBlueLight,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.mountainBlue.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.wb_sunny_outlined, color: AppColors.mountainBlue, size: 18),
                    SizedBox(width: 8),
                    Text('Weather Overview', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.mountainBlue)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(trip.weatherOverview,
                    style: const TextStyle(fontSize: 13, color: AppColors.darkCharcoal, height: 1.5)),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Gear Checklist
          const Text('Trip Gear Checklist',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal)),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: _checklist.asMap().entries.map((entry) {
                final i = entry.key;
                final item = entry.value;
                return Column(
                  children: [
                    ListTile(
                      leading: Checkbox(
                        value: item.isCompleted,
                        activeColor: AppColors.mountainBlue,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (v) => setState(() => _checklist[i].isCompleted = v ?? false),
                      ),
                      title: Text(item.title,
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: item.isCompleted
                                  ? AppColors.slate
                                  : AppColors.darkCharcoal,
                              decoration: item.isCompleted ? TextDecoration.lineThrough : null)),
                      trailing: item.isGearRental
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.mountainBlueLight,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text('Rental',
                                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.mountainBlue)),
                            )
                          : null,
                    ),
                    if (i < _checklist.length - 1)
                      const Divider(height: 1, indent: 16, endIndent: 16),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            '${_checklist.where((c) => c.isCompleted).length} of ${_checklist.length} items ready',
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.slate),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
