import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../services/auth_service.dart';
import '../../widgets/app_navigation.dart';

class SizingFormScreen extends StatefulWidget {
  const SizingFormScreen({super.key});

  @override
  State<SizingFormScreen> createState() => _SizingFormScreenState();
}

class _SizingFormScreenState extends State<SizingFormScreen>
    with TickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  int _currentStep = 0;

  // Form values
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _phoneController = TextEditingController();
  int? _selectedAge;
  String _selectedDestination = 'Ladakh';
  String _selectedExperience = 'Beginner';
  String _selectedJacketSize = 'M';
  String _selectedGloveSize = 'M';
  bool _isSaving = false;

  static const List<String> _destinations = [
    'Ladakh', 'Spiti Valley', 'Manali', 'Zanskar', 'Rohtang Pass', 'Khardung La',
  ];
  static const List<String> _experiences = ['Beginner', 'Intermediate', 'Expert', 'Pro Racer'];
  static const List<String> _sizes = ['XS', 'S', 'M', 'L', 'XL', 'XXL', '3XL'];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
    _animController.forward();

    final user = AuthService().currentUser;
    if (user != null && user.phone != '+91 98765 00000') {
      _phoneController.text = user.phone;
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _animController.reset();
      setState(() => _currentStep++);
      _animController.forward();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _animController.reset();
      setState(() => _currentStep--);
      _animController.forward();
    }
  }

  bool _validateCurrentStep() {
    if (_currentStep == 0) {
      final h = double.tryParse(_heightController.text);
      final w = double.tryParse(_weightController.text);
      if (h == null || h < 100 || h > 230) {
        _showError('Enter a valid height (100–230 cm)');
        return false;
      }
      if (w == null || w < 30 || w > 200) {
        _showError('Enter a valid weight (30–200 kg)');
        return false;
      }
      if (_selectedAge == null) {
        _showError('Please select your age');
        return false;
      }
    }
    return true;
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Row(children: [
        const Icon(Icons.error_outline, color: Colors.white, size: 18),
        const SizedBox(width: 8),
        Text(msg, style: const TextStyle(fontWeight: FontWeight.w600)),
      ]),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
    ));
  }

  Future<void> _saveAndContinue() async {
    setState(() => _isSaving = true);
    final h = double.tryParse(_heightController.text);
    final w = double.tryParse(_weightController.text);
    final phone = _phoneController.text.trim();

    AuthService().updateProfile(
      name: AuthService().currentUser?.name ?? 'Rider',
      phone: phone.isNotEmpty ? phone : '+91 98765 00000',
      heightCm: h,
      weightKg: w,
      age: _selectedAge,
      preferredDestination: _selectedDestination,
    );
    AuthService().markSizingComplete();
    await Future.delayed(const Duration(milliseconds: 600));

    if (!mounted) return;
    setState(() => _isSaving = false);
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => const AppNavigation(),
        transitionsBuilder: (_, anim, _, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 800;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: isWide ? _buildWideLayout() : _buildMobileLayout(),
    );
  }

  Widget _buildWideLayout() {
    return Row(
      children: [
        Container(
          width: 360,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.darkCharcoal, AppColors.mountainBlueDark],
            ),
          ),
          child: _buildLeftPanel(),
        ),
        Expanded(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 56, vertical: 48),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 500),
                child: _buildFormContent(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout() {
    return SafeArea(
      child: Column(
        children: [
          _buildMobileHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildFormContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.darkCharcoal, AppColors.mountainBlueDark]),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: AppColors.mountainBlue, borderRadius: BorderRadius.circular(10)),
                child: const Icon(Icons.sports_motorsports, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              const Text('Smart Gear', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(20)),
                child: const Text('Setup Profile', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text('Your Rider Profile', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Help us fit the perfect gear for you', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
          const SizedBox(height: 14),
          _buildStepIndicator(),
        ],
      ),
    );
  }

  Widget _buildLeftPanel() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(children: [
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(color: AppColors.mountainBlue, borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.sports_motorsports, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 12),
            const Text('Smart Gear', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
          ]),
          const SizedBox(height: 40),
          const Text(
            'Your Rider\nProfile Setup',
            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800, height: 1.2, letterSpacing: -0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'We use your measurements to suggest perfectly fitted CE Level 2 gear for Himalayan adventures.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 32),
          _buildStepIndicator(),
          const SizedBox(height: 40),
          ...[
            ('AI-powered size prediction', Icons.auto_awesome),
            ('Altitude-adapted gear bundles', Icons.terrain),
            ('Personalized trip recommendations', Icons.map_outlined),
          ].map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: Row(children: [
              Container(
                width: 34, height: 34,
                decoration: BoxDecoration(color: AppColors.mountainBlue.withValues(alpha: 0.25), borderRadius: BorderRadius.circular(8)),
                child: Icon(item.$2, color: AppColors.mountainBlueLight, size: 17),
              ),
              const SizedBox(width: 12),
              Text(item.$1, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
            ]),
          )),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Row(children: [
              const Icon(Icons.lock_outline, color: Colors.white60, size: 18),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Your data is secure and only used for gear recommendations.',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.65), fontSize: 12, height: 1.4),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    const steps = ['Measurements', 'Gear Sizes', 'Preferences'];
    return Row(
      children: List.generate(steps.length, (i) {
        final isActive = i == _currentStep;
        final isDone = i < _currentStep;
        return Expanded(
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 26, height: 26,
                      decoration: BoxDecoration(
                        color: isDone ? AppColors.success : isActive ? AppColors.mountainBlue : Colors.white.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: isDone
                            ? const Icon(Icons.check, color: Colors.white, size: 14)
                            : Text('${i + 1}', style: TextStyle(color: isActive ? Colors.white : Colors.white54, fontSize: 11, fontWeight: FontWeight.w700)),
                      ),
                    ),
                    if (i < steps.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          color: isDone ? AppColors.success : Colors.white.withValues(alpha: 0.15),
                        ),
                      ),
                  ]),
                  const SizedBox(height: 4),
                  Text(steps[i], style: TextStyle(color: isActive ? Colors.white : Colors.white54, fontSize: 10, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500)),
                ],
              ),
            ),
          ]),
        );
      }),
    );
  }

  Widget _buildFormContent() {
    return FadeTransition(
      opacity: _fadeAnim,
      child: SlideTransition(
        position: _slideAnim,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStepHeader(),
            const SizedBox(height: 28),
            if (_currentStep == 0) _buildStep0(),
            if (_currentStep == 1) _buildStep1(),
            if (_currentStep == 2) _buildStep2(),
            const SizedBox(height: 28),
            _buildNavigationButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepHeader() {
    const headers = [
      ('Your Measurements', 'We\'ll use these for AI-powered sizing.', Icons.straighten),
      ('Gear Sizes', 'Select your preferred sizing for riding gear.', Icons.checkroom),
      ('Riding Preferences', 'Personalize your adventure profile.', Icons.explore),
    ];
    final h = headers[_currentStep];
    return Row(children: [
      Container(
        width: 52, height: 52,
        decoration: BoxDecoration(color: AppColors.mountainBlueLight, borderRadius: BorderRadius.circular(14)),
        child: Icon(h.$3, color: AppColors.mountainBlue, size: 26),
      ),
      const SizedBox(width: 14),
      Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(h.$1, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal)),
          Text(h.$2, style: const TextStyle(fontSize: 13, color: AppColors.slate)),
        ]),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(20), border: Border.all(color: AppColors.border)),
        child: Text('Step ${_currentStep + 1} of 3', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.slate)),
      ),
    ]);
  }

  Widget _buildStep0() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Expanded(child: _buildNumberInput('Height (cm)', 'e.g. 175', _heightController, Icons.height)),
        const SizedBox(width: 16),
        Expanded(child: _buildNumberInput('Weight (kg)', 'e.g. 72', _weightController, Icons.monitor_weight_outlined)),
      ]),
      const SizedBox(height: 20),
      _buildLabel('Phone Number'),
      const SizedBox(height: 6),
      _buildTextField(controller: _phoneController, hint: '+91 98765 XXXXX', icon: Icons.phone_outlined, keyboard: TextInputType.phone),
      const SizedBox(height: 20),
      _buildLabel('Age'),
      const SizedBox(height: 6),
      _buildDropdownSelector(
        value: _selectedAge?.toString(),
        items: List.generate(53, (i) => '${i + 18}'),
        hint: 'Select your age',
        icon: Icons.cake_outlined,
        onChanged: (v) => setState(() => _selectedAge = int.tryParse(v ?? '')),
      ),
      const SizedBox(height: 20),
      _buildInfoCard('Why we need this', 'Your height and weight help our AI recommend perfectly fitted CE Level 2 jackets, pants, and boots for Himalayan terrain.', Icons.info_outline),
    ]);
  }

  Widget _buildStep1() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildLabel('Jacket / Body Armor Size'),
      const SizedBox(height: 10),
      _buildSizeSelector(selected: _selectedJacketSize, sizes: _sizes, onSelected: (s) => setState(() => _selectedJacketSize = s)),
      const SizedBox(height: 22),
      _buildLabel('Glove Size'),
      const SizedBox(height: 10),
      _buildSizeSelector(selected: _selectedGloveSize, sizes: _sizes, onSelected: (s) => setState(() => _selectedGloveSize = s)),
      const SizedBox(height: 22),
      _buildInfoCard('Size Guide', 'Not sure? Our AI will also suggest sizes based on your measurements. You can always update this in your profile.', Icons.checkroom),
    ]);
  }

  Widget _buildStep2() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildLabel('Primary Destination'),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8, runSpacing: 8,
        children: _destinations.map((dest) {
          final selected = _selectedDestination == dest;
          return GestureDetector(
            onTap: () => setState(() => _selectedDestination = dest),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: selected ? AppColors.mountainBlue : AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: selected ? AppColors.mountainBlue : AppColors.border, width: selected ? 2 : 1),
                boxShadow: selected ? [BoxShadow(color: AppColors.mountainBlue.withValues(alpha: 0.2), blurRadius: 8)] : [],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.terrain, size: 15, color: selected ? Colors.white : AppColors.slate),
                const SizedBox(width: 6),
                Text(dest, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.darkCharcoal)),
              ]),
            ),
          );
        }).toList(),
      ),
      const SizedBox(height: 24),
      _buildLabel('Riding Experience'),
      const SizedBox(height: 8),
      Column(
        children: _experiences.asMap().entries.map((entry) {
          final exp = entry.value;
          final selected = _selectedExperience == exp;
          final icons = [Icons.directions_bike, Icons.two_wheeler, Icons.sports_motorsports, Icons.emoji_events];
          return GestureDetector(
            onTap: () => setState(() => _selectedExperience = exp),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: selected ? AppColors.mountainBlue : AppColors.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: selected ? AppColors.mountainBlue : AppColors.border, width: selected ? 2 : 1),
              ),
              child: Row(children: [
                Icon(icons[entry.key], size: 20, color: selected ? Colors.white : AppColors.slate),
                const SizedBox(width: 12),
                Expanded(child: Text(exp, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppColors.darkCharcoal))),
                if (selected) const Icon(Icons.check_circle, color: Colors.white, size: 18),
              ]),
            ),
          );
        }).toList(),
      ),
    ]);
  }

  Widget _buildNavigationButtons() {
    final isLastStep = _currentStep == 2;
    return Row(children: [
      if (_currentStep > 0)
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.arrow_back_rounded, size: 18),
            label: const Text('Back'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.darkCharcoal,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: _prevStep,
          ),
        ),
      if (_currentStep > 0) const SizedBox(width: 12),
      Expanded(
        flex: 2,
        child: ElevatedButton(
          onPressed: _isSaving ? null : () {
            if (!_validateCurrentStep()) return;
            if (isLastStep) {
              _saveAndContinue();
            } else {
              _nextStep();
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: isLastStep ? AppColors.success : AppColors.mountainBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 2,
          ),
          child: _isSaving
              ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
              : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(isLastStep ? 'Complete Setup' : 'Continue', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Icon(isLastStep ? Icons.check_circle_outline : Icons.arrow_forward_rounded, size: 18),
                ]),
        ),
      ),
    ]);
  }

  Widget _buildLabel(String text) => Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal));

  Widget _buildNumberInput(String label, String hint, TextEditingController ctrl, IconData icon) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _buildLabel(label),
      const SizedBox(height: 6),
      _buildTextField(controller: ctrl, hint: hint, icon: icon, keyboard: TextInputType.number),
    ]);
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, TextInputType? keyboard}) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, size: 20, color: AppColors.slate),
        hintText: hint,
        filled: true, fillColor: AppColors.surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.border)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.mountainBlue, width: 2)),
      ),
    );
  }

  Widget _buildDropdownSelector({required String? value, required List<String> items, required String hint, required IconData icon, required ValueChanged<String?> onChanged}) {
    return Container(
      decoration: BoxDecoration(color: AppColors.surfaceMuted, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Row(children: [
        Icon(icon, size: 20, color: AppColors.slate),
        const SizedBox(width: 8),
        Expanded(
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(hint, style: const TextStyle(fontSize: 14, color: AppColors.slate)),
              items: items.map((v) => DropdownMenuItem(value: v, child: Text(v, style: const TextStyle(fontSize: 14)))).toList(),
              onChanged: onChanged,
              isExpanded: true,
            ),
          ),
        ),
      ]),
    );
  }

  Widget _buildSizeSelector({required String selected, required List<String> sizes, required ValueChanged<String> onSelected}) {
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: sizes.map((size) {
        final isSelected = selected == size;
        return GestureDetector(
          onTap: () => onSelected(size),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 54, height: 54,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.mountainBlue : AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: isSelected ? AppColors.mountainBlue : AppColors.border, width: isSelected ? 2 : 1),
              boxShadow: isSelected ? [BoxShadow(color: AppColors.mountainBlue.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))] : [],
            ),
            child: Center(child: Text(size, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: isSelected ? Colors.white : AppColors.darkCharcoal))),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInfoCard(String title, String body, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.mountainBlueLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mountainBlue.withValues(alpha: 0.2)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(icon, size: 18, color: AppColors.mountainBlue),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.mountainBlue)),
          const SizedBox(height: 3),
          Text(body, style: const TextStyle(fontSize: 12, color: AppColors.slate, height: 1.4)),
        ])),
      ]),
    );
  }
}
