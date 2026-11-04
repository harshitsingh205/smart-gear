import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/prediction_model.dart';
import '../../services/ai_service.dart';

class DemandPrediction extends StatefulWidget {
  const DemandPrediction({super.key});

  @override
  State<DemandPrediction> createState() => _DemandPredictionState();
}

class _DemandPredictionState extends State<DemandPrediction> {
  final AIService _aiService = AIService();

  String _destination = 'Ladakh';
  String _month = 'July';
  String _weather = 'Cold';
  String _touristSeason = 'Peak';
  bool _holidayPeriod = true;
  double _bikeBookings = 180;

  bool _isLoading = false;
  PredictionModel? _predictionResult;

  final List<String> _destinations = ['Ladakh', 'Spiti Valley', 'Manali', 'Rishikesh'];
  final List<String> _months = ['May', 'June', 'July', 'August', 'September', 'October'];
  final List<String> _weathers = ['Very Cold', 'Cold', 'Moderate', 'Rainy'];
  final List<String> _seasons = ['Peak', 'Shoulder', 'Off-Peak'];

  @override
  void initState() {
    super.initState();
    _runPrediction();
  }

  Future<void> _runPrediction() async {
    setState(() => _isLoading = true);
    final result = await _aiService.predictDemand(
      destination: _destination,
      month: _month,
      weather: _weather,
      touristSeason: _touristSeason,
      holidayPeriod: _holidayPeriod,
      bikeBookings: _bikeBookings.round(),
    );
    if (mounted) {
      setState(() {
        _predictionResult = result;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Top Header Bar
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'AI Demand Prediction & Stock Planning',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: AppColors.darkCharcoal,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(width: 8),
                            Icon(Icons.auto_awesome, color: AppColors.mountainBlue, size: 20),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Simulate weather patterns, bike rental footfall, and tourist influx to prevent gear stockouts',
                          style: TextStyle(fontSize: 13, color: AppColors.slate),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.mountainBlueLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.mountainBlue.withValues(alpha: 0.3)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.memory, size: 14, color: AppColors.mountainBlue),
                          SizedBox(width: 6),
                          Text(
                            'ML Surrogate Model',
                            style: TextStyle(color: AppColors.mountainBlue, fontSize: 11, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Content Area
            SliverPadding(
              padding: const EdgeInsets.all(24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Input Configuration Card
                  _buildInputFormCard(),

                  const SizedBox(height: 24),

                  // Prediction Results View
                  if (_isLoading)
                    Container(
                      height: 240,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Running AI Demand Forecasting Model...', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.slate)),
                          ],
                        ),
                      ),
                    )
                  else if (_predictionResult != null)
                    _buildPredictionOutput(_predictionResult!),

                  const SizedBox(height: 24),

                  // Architecture & Production Integration Note
                  _buildArchitectureNote(),

                  const SizedBox(height: 40),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputFormCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppTheme.softShadow],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tune, color: AppColors.mountainBlue, size: 20),
              SizedBox(width: 8),
              Text(
                'Simulation Parameters & Indicators',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Adjust seasonal and operational variables to simulate demand spikes across high-altitude circuits',
            style: TextStyle(fontSize: 12, color: AppColors.slate),
          ),
          const SizedBox(height: 20),

          // Dropdowns Grid
          LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 760;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  SizedBox(
                    width: isDesktop ? (constraints.maxWidth - 48) / 4 : (constraints.maxWidth - 16) / 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _destination,
                      decoration: const InputDecoration(labelText: 'Destination Circuit', filled: true),
                      items: _destinations.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                      onChanged: (v) => setState(() => _destination = v!),
                    ),
                  ),
                  SizedBox(
                    width: isDesktop ? (constraints.maxWidth - 48) / 4 : (constraints.maxWidth - 16) / 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _month,
                      decoration: const InputDecoration(labelText: 'Travel Month', filled: true),
                      items: _months.map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                      onChanged: (v) => setState(() => _month = v!),
                    ),
                  ),
                  SizedBox(
                    width: isDesktop ? (constraints.maxWidth - 48) / 4 : (constraints.maxWidth - 16) / 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _weather,
                      decoration: const InputDecoration(labelText: 'Weather Outlook', filled: true),
                      items: _weathers.map((w) => DropdownMenuItem(value: w, child: Text(w))).toList(),
                      onChanged: (v) => setState(() => _weather = v!),
                    ),
                  ),
                  SizedBox(
                    width: isDesktop ? (constraints.maxWidth - 48) / 4 : (constraints.maxWidth - 16) / 2,
                    child: DropdownButtonFormField<String>(
                      initialValue: _touristSeason,
                      decoration: const InputDecoration(labelText: 'Tourist Footfall', filled: true),
                      items: _seasons.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                      onChanged: (v) => setState(() => _touristSeason = v!),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 20),

          // Slider & Switch Row
          Row(
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Estimated Motorcycle Fleet Bookings:',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkCharcoal),
                        ),
                        Text(
                          '${_bikeBookings.round()} bikes',
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.mountainBlue),
                        ),
                      ],
                    ),
                    Slider(
                      value: _bikeBookings,
                      min: 30,
                      max: 400,
                      divisions: 37,
                      activeColor: AppColors.mountainBlue,
                      onChanged: (v) => setState(() => _bikeBookings = v),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceMuted,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Text('Holiday / Festival Rush', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    const SizedBox(width: 8),
                    Switch(
                      value: _holidayPeriod,
                      activeThumbColor: AppColors.mountainBlue,
                      onChanged: (v) => setState(() => _holidayPeriod = v),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _runPrediction,
              icon: const Icon(Icons.bolt, size: 18),
              label: const Text('Run Demand Simulation'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mountainBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPredictionOutput(PredictionModel result) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // AI Insight Banner
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.mountainBlueLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.mountainBlue.withValues(alpha: 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: AppColors.mountainBlue, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.psychology, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'AI Operational Strategy & Sizing Insight',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.mountainBlueDark),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6)),
                          child: Text(
                            'Confidence: ${(result.confidenceScore * 100).toStringAsFixed(1)}%',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.mountainBlue),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      result.aiInsight,
                      style: const TextStyle(fontSize: 13, color: AppColors.darkCharcoal, height: 1.4),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Forecast Table & Category Demand Cards
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
            boxShadow: [AppTheme.softShadow],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Predicted Gear Demand vs Fleet Capacity',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal),
              ),
              const SizedBox(height: 4),
              const Text(
                'Target buffer includes 15% safety stock for sudden pass closures and tourist extensions',
                style: TextStyle(fontSize: 12, color: AppColors.slate),
              ),
              const SizedBox(height: 20),

              // Responsive Grid of Demand Details
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth >= 800;
                  final crossAxisCount = isWide ? 3 : 1;

                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: isWide ? 1.8 : 2.6,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: result.demandDetails.length,
                    itemBuilder: (context, i) {
                      final item = result.demandDetails[i];
                      final isShortage = item.shortage > 0;

                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isShortage ? AppColors.warningLight.withValues(alpha: 0.5) : AppColors.surfaceMuted,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isShortage ? AppColors.warning.withValues(alpha: 0.4) : AppColors.border,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    item.categoryName,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: item.demandTrend == 'Peak' ? AppColors.errorLight : AppColors.mountainBlueLight,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    item.demandTrend.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: item.demandTrend == 'Peak' ? AppColors.error : AppColors.mountainBlue,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Projected Demand', style: TextStyle(fontSize: 10, color: AppColors.slate)),
                                    Text(
                                      '${item.predictedCount} units',
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    const Text('Current In-Stock', style: TextStyle(fontSize: 10, color: AppColors.slate)),
                                    Text(
                                      '${item.currentInventory} units',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: isShortage ? AppColors.warning : AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Safe Target: ${item.recommendedInventory}u',
                                  style: const TextStyle(fontSize: 11, color: AppColors.slate, fontWeight: FontWeight.w500),
                                ),
                                Text(
                                  isShortage ? 'Shortfall: +${item.shortage} units' : 'Optimal Stock',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: isShortage ? AppColors.error : AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildArchitectureNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: const Row(
        children: [
          Icon(Icons.info_outline, color: AppColors.slate, size: 20),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Academic & Commercial Architecture Note: This demand prediction module utilizes an embedded regression heuristic for rapid client-side prototyping. In enterprise deployment, it routes to a Python FastAPI / XGBoost service trained on historical Leh-Manali tourism footfall & weather API feeds.',
              style: TextStyle(fontSize: 11, color: AppColors.slate, height: 1.4),
            ),
          ),
        ],
      ),
    );
  }
}
