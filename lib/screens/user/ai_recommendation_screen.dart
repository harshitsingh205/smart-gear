import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../services/ai_service.dart';
import '../../services/auth_service.dart';
import '../../models/prediction_model.dart';

class AIRecommendationScreen extends StatefulWidget {
  const AIRecommendationScreen({super.key});

  @override
  State<AIRecommendationScreen> createState() => _AIRecommendationScreenState();
}

class _AIRecommendationScreenState extends State<AIRecommendationScreen> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  bool _isLoading = false;
  AIRecommendationResult? _result;

  // Step 1 - Body
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _ageController = TextEditingController();

  // Step 2 - Destination
  String _destination = 'Ladakh';

  // Step 3 - Duration
  int _durationDays = 7;

  // Step 4 - Month
  String _travelMonth = 'June';

  // Step 5 - Weather
  String _expectedWeather = 'Cold';

  // Step 6 - Experience
  String _ridingExperience = 'Intermediate';

  void _nextStep() {
    if (_currentStep == 0) {
      final h = double.tryParse(_heightController.text);
      final w = double.tryParse(_weightController.text);
      if (h == null || w == null || h < 140 || h > 220 || w < 40 || w > 150) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter valid height (140-220cm) and weight (40-150kg)'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    if (_currentStep < 5) {
      _pageController.nextPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
      setState(() => _currentStep++);
    } else {
      _getRecommendation();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(duration: const Duration(milliseconds: 350), curve: Curves.easeInOut);
      setState(() => _currentStep--);
    }
  }

  Future<void> _getRecommendation() async {
    setState(() => _isLoading = true);
    final user = AuthService().currentUser;
    final result = await AIService().getGearRecommendation(
      heightCm: double.tryParse(_heightController.text) ?? user?.heightCm ?? 175,
      weightKg: double.tryParse(_weightController.text) ?? user?.weightKg ?? 70,
      age: int.tryParse(_ageController.text) ?? user?.age ?? 25,
      destination: _destination,
      durationDays: _durationDays,
      travelMonth: _travelMonth,
      expectedWeather: _expectedWeather,
      ridingExperience: _ridingExperience,
    );
    if (!mounted) return;
    setState(() {
      _result = result;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    final user = AuthService().currentUser;
    if (user?.heightCm != null) _heightController.text = user!.heightCm!.toInt().toString();
    if (user?.weightKg != null) _weightController.text = user!.weightKg!.toInt().toString();
    if (user?.age != null) _ageController.text = user!.age!.toString();
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _ageController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_result != null) return _ResultPage(result: _result!, onRetry: () => setState(() => _result = null));
    if (_isLoading) return _LoadingPage();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Recommendation'),
        leading: const BackButton(),
      ),
      body: Column(
        children: [
          // Step Progress
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              children: [
                Row(
                  children: List.generate(6, (i) => Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i < 5 ? 4 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        color: i <= _currentStep ? AppColors.mountainBlue : AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  )),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Step ${_currentStep + 1} of 6',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.mountainBlue)),
                    Text(_stepTitle(_currentStep),
                        style: const TextStyle(fontSize: 13, color: AppColors.slate)),
                  ],
                ),
              ],
            ),
          ),

          // Step Pages
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildStep1(),
                _buildStep2(),
                _buildStep3(),
                _buildStep4(),
                _buildStep5(),
                _buildStep6(),
              ],
            ),
          ),

          // Nav Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _prevStep,
                      child: const Text('Back'),
                    ),
                  ),
                if (_currentStep > 0) const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _nextStep,
                    child: Text(_currentStep == 5 ? 'Get Recommendation' : 'Next'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _stepTitle(int step) {
    const titles = ['Body Info', 'Destination', 'Duration', 'Travel Month', 'Weather', 'Experience'];
    return titles[step];
  }

  Widget _buildStepContainer(String title, String subtitle, Widget child) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal)),
          const SizedBox(height: 6),
          Text(subtitle, style: const TextStyle(fontSize: 14, color: AppColors.slate)),
          const SizedBox(height: 28),
          child,
        ],
      ),
    );
  }

  Widget _buildStep1() => _buildStepContainer(
    'Your Body Measurements',
    'Used to calculate your gear sizes accurately.',
    Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildField('Height (cm)', 'e.g. 178', _heightController, Icons.height,
                  type: TextInputType.number),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildField('Weight (kg)', 'e.g. 74', _weightController, Icons.monitor_weight_outlined,
                  type: TextInputType.number),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildField('Age', 'e.g. 27', _ageController, Icons.cake_outlined, type: TextInputType.number),
      ],
    ),
  );

  Widget _buildStep2() => _buildStepContainer(
    'Where are you riding?',
    'AI adjusts gear types based on terrain and altitude.',
    Column(
      children: ['Ladakh', 'Manali', 'Spiti', 'Rishikesh', 'Other'].map((dest) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _SelectionTile(
            label: dest,
            subtitle: _destinationSubtitle(dest),
            icon: Icons.location_on_outlined,
            isSelected: _destination == dest,
            onTap: () => setState(() => _destination = dest),
          ),
        );
      }).toList(),
    ),
  );

  Widget _buildStep3() => _buildStepContainer(
    'Trip Duration',
    'Longer trips may need additional thermal layers.',
    Column(
      children: [
        Text('$_durationDays Days',
            style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: AppColors.mountainBlue)),
        const SizedBox(height: 20),
        Slider(
          value: _durationDays.toDouble(),
          min: 1,
          max: 30,
          divisions: 29,
          activeColor: AppColors.mountainBlue,
          onChanged: (v) => setState(() => _durationDays = v.round()),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            Text('1 Day', style: TextStyle(fontSize: 13, color: AppColors.slate)),
            Text('30 Days', style: TextStyle(fontSize: 13, color: AppColors.slate)),
          ],
        ),
      ],
    ),
  );

  Widget _buildStep4() => _buildStepContainer(
    'Travel Month',
    'Weather patterns vary significantly by month in Ladakh.',
    Wrap(
      spacing: 10,
      runSpacing: 10,
      children: ['January', 'February', 'March', 'April', 'May', 'June',
                  'July', 'August', 'September', 'October', 'November', 'December'].map((m) {
        final selected = _travelMonth == m;
        return GestureDetector(
          onTap: () => setState(() => _travelMonth = m),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: selected ? AppColors.mountainBlue : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: selected ? AppColors.mountainBlue : AppColors.border),
            ),
            child: Text(
              m,
              style: TextStyle(
                fontSize: 14,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.white : AppColors.darkCharcoal,
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );

  Widget _buildStep5() => _buildStepContainer(
    'Expected Weather',
    'AI uses this to determine thermal and rain gear needs.',
    Column(
      children: [
        _WeatherOption(label: 'Very Cold', subtitle: 'Sub-zero wind chill (High altitude passes)', icon: '🥶', selected: _expectedWeather == 'Very Cold', onTap: () => setState(() => _expectedWeather = 'Very Cold')),
        const SizedBox(height: 10),
        _WeatherOption(label: 'Cold', subtitle: 'Chilly mountain temperatures (10–15°C)', icon: '🧊', selected: _expectedWeather == 'Cold', onTap: () => setState(() => _expectedWeather = 'Cold')),
        const SizedBox(height: 10),
        _WeatherOption(label: 'Moderate', subtitle: 'Pleasant riding conditions (15–25°C)', icon: '☁️', selected: _expectedWeather == 'Moderate', onTap: () => setState(() => _expectedWeather = 'Moderate')),
        const SizedBox(height: 10),
        _WeatherOption(label: 'Rainy', subtitle: 'Monsoon season, wet roads expected', icon: '🌧️', selected: _expectedWeather == 'Rainy', onTap: () => setState(() => _expectedWeather = 'Rainy')),
      ],
    ),
  );

  Widget _buildStep6() => _buildStepContainer(
    'Riding Experience',
    'Beginners get additional protective gear recommendations.',
    Column(
      children: [
        _SelectionTile(label: 'Beginner', subtitle: 'Less than 2 years riding experience', icon: Icons.school_outlined, isSelected: _ridingExperience == 'Beginner', onTap: () => setState(() => _ridingExperience = 'Beginner')),
        const SizedBox(height: 10),
        _SelectionTile(label: 'Intermediate', subtitle: '2-5 years, comfortable on highways', icon: Icons.motorcycle, isSelected: _ridingExperience == 'Intermediate', onTap: () => setState(() => _ridingExperience = 'Intermediate')),
        const SizedBox(height: 10),
        _SelectionTile(label: 'Experienced', subtitle: '5+ years, off-road and mountain touring', icon: Icons.terrain, isSelected: _ridingExperience == 'Experienced', onTap: () => setState(() => _ridingExperience = 'Experienced')),
      ],
    ),
  );

  Widget _buildField(String label, String hint, TextEditingController controller, IconData icon,
      {TextInputType type = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkCharcoal)),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: type,
          decoration: InputDecoration(prefixIcon: Icon(icon, size: 18), hintText: hint),
        ),
      ],
    );
  }

  String _destinationSubtitle(String d) {
    const m = {
      'Ladakh': 'High altitude (3,500-5,300m) • Sub-zero wind chill',
      'Manali': 'Mountain passes, winding roads • 2,050m',
      'Spiti': 'Remote high-altitude desert • 3,800-4,550m',
      'Rishikesh': 'River valley, river crossings • 356m',
      'Other': 'Custom destination',
    };
    return m[d] ?? '';
  }
}

class _SelectionTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectionTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.mountainBlueLight : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.mountainBlue : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.mountainBlue : AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: isSelected ? Colors.white : AppColors.slate, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? AppColors.mountainBlue : AppColors.darkCharcoal)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.slate)),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.mountainBlue, size: 22),
          ],
        ),
      ),
    );
  }
}

class _WeatherOption extends StatelessWidget {
  final String label;
  final String subtitle;
  final String icon;
  final bool selected;
  final VoidCallback onTap;

  const _WeatherOption({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: selected ? AppColors.mountainBlueLight : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColors.mountainBlue : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(icon, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: selected ? AppColors.mountainBlue : AppColors.darkCharcoal)),
                  Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.slate)),
                ],
              ),
            ),
            if (selected) const Icon(Icons.check_circle, color: AppColors.mountainBlue, size: 22),
          ],
        ),
      ),
    );
  }
}

// ── Loading Screen ────────────────────────────────────────────────────────────
class _LoadingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.mountainBlueLight,
                borderRadius: BorderRadius.circular(24),
              ),
              child: const Icon(Icons.smart_toy, color: AppColors.mountainBlue, size: 48),
            ),
            const SizedBox(height: 24),
            const Text('Analyzing your measurements...',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal)),
            const SizedBox(height: 8),
            const Text('AI model is processing your inputs',
                style: TextStyle(fontSize: 14, color: AppColors.slate)),
            const SizedBox(height: 32),
            const SizedBox(
              width: 48,
              height: 48,
              child: CircularProgressIndicator(color: AppColors.mountainBlue, strokeWidth: 3),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Result Page ───────────────────────────────────────────────────────────────
class _ResultPage extends StatelessWidget {
  final AIRecommendationResult result;
  final VoidCallback onRetry;

  const _ResultPage({required this.result, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Your AI Recommendation'),
        leading: BackButton(onPressed: onRetry),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // AI Demo Disclaimer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: AppColors.warning, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Demo Mode: Recommendation uses rule-based logic. Ready to plug into a Python ML API.',
                      style: TextStyle(fontSize: 12, color: AppColors.darkCharcoal),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Confidence Score
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.mountainBlue, AppColors.mountainBlueDark],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Recommendation Confidence',
                            style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text('${result.confidencePercentage.toStringAsFixed(1)}%',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 36, fontWeight: FontWeight.w900)),
                        const Text('High Confidence', style: TextStyle(color: Colors.white60, fontSize: 12)),
                      ],
                    ),
                  ),
                  const Icon(Icons.smart_toy, color: Colors.white, size: 64),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Size Recommendations
            const Text('Recommended Sizes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal)),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 2.2,
              children: [
                _SizeCard('Jacket', result.jacketSize, Icons.dry_cleaning),
                _SizeCard('Gloves', result.glovesSize, Icons.pan_tool),
                _SizeCard('Boots', result.bootsSize, Icons.snowshoeing),
                _SizeCard('Pants', result.pantsSize, Icons.accessibility_new),
              ],
            ),
            const SizedBox(height: 20),

            // Gear Recommendations
            const Text('Gear Bundle',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal)),
            const SizedBox(height: 12),
            _GearRecommendationTile('Knee Guards', result.kneeGuardsRecommended ? 'Recommended' : 'Optional', Icons.shield, result.kneeGuardsRecommended),
            const SizedBox(height: 8),
            _GearRecommendationTile('Elbow Guards', result.elbowGuardsRecommended ? 'Recommended' : 'Optional', Icons.shield_outlined, result.elbowGuardsRecommended),
            const SizedBox(height: 8),
            _GearRecommendationTile('Thermal Layer', result.thermalRecommended ? 'Highly Recommended' : 'Optional', Icons.ac_unit, result.thermalRecommended),
            const SizedBox(height: 20),

            // Why This Gear
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.psychology_outlined, color: AppColors.mountainBlue, size: 20),
                      SizedBox(width: 8),
                      Text('Why this recommendation?',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal)),
                    ],
                  ),
                  const SizedBox(height: 14),
                  ...result.reasons.asMap().entries.map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.mountainBlue,
                          ),
                          alignment: Alignment.center,
                          child: Text('${entry.key + 1}',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(entry.value,
                              style: const TextStyle(fontSize: 13, color: AppColors.darkCharcoal, height: 1.5)),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.inventory_2_outlined),
                label: const Text('Browse Matching Gear'),
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onRetry,
                child: const Text('Try Again with Different Inputs'),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _SizeCard extends StatelessWidget {
  final String label;
  final String size;
  final IconData icon;

  const _SizeCard(this.label, this.size, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppTheme.softShadow],
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.mountainBlue, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: const TextStyle(fontSize: 12, color: AppColors.slate)),
                Text(size,
                    style: const TextStyle(
                        fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GearRecommendationTile extends StatelessWidget {
  final String name;
  final String status;
  final IconData icon;
  final bool isRecommended;

  const _GearRecommendationTile(this.name, this.status, this.icon, this.isRecommended);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isRecommended ? AppColors.successLight : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isRecommended ? AppColors.success.withValues(alpha: 0.3) : AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: isRecommended ? AppColors.success : AppColors.slate, size: 22),
          const SizedBox(width: 12),
          Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal)),
          const Spacer(),
          Text(status,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isRecommended ? AppColors.success : AppColors.slate)),
        ],
      ),
    );
  }
}
