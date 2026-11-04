import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../models/user_model.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  String _searchQuery = '';

  // Pre-seeded realistic customer data for the CSE / AI demo
  final List<UserModel> _customers = [
    const UserModel(
      id: 'usr_001',
      name: 'Aarav Sharma',
      email: 'aarav.sharma@gmail.com',
      phone: '+91 98765 43210',
      heightCm: 178,
      weightKg: 76,
      age: 28,
      preferredDestination: 'Ladakh',
      role: 'rider',
    ),
    const UserModel(
      id: 'usr_002',
      name: 'Priya Patel',
      email: 'priya.patel@outlook.com',
      phone: '+91 98112 34567',
      heightCm: 165,
      weightKg: 58,
      age: 26,
      preferredDestination: 'Spiti Valley',
      role: 'rider',
    ),
    const UserModel(
      id: 'usr_003',
      name: 'Vikramaditya Roy',
      email: 'vikram.roy@yahoo.in',
      phone: '+91 99201 88776',
      heightCm: 184,
      weightKg: 85,
      age: 34,
      preferredDestination: 'Ladakh',
      role: 'rider',
    ),
    const UserModel(
      id: 'usr_004',
      name: 'Ananya Deshmukh',
      email: 'ananya.d@gmail.com',
      phone: '+91 97654 32198',
      heightCm: 170,
      weightKg: 62,
      age: 29,
      preferredDestination: 'Manali',
      role: 'rider',
    ),
    const UserModel(
      id: 'usr_005',
      name: 'Rohan Mehra',
      email: 'rohan.mehra@techcorp.io',
      phone: '+91 98450 12345',
      heightCm: 180,
      weightKg: 80,
      age: 31,
      preferredDestination: 'Spiti Valley',
      role: 'rider',
    ),
  ];

  List<UserModel> get _filteredCustomers {
    if (_searchQuery.isEmpty) return _customers;
    final q = _searchQuery.toLowerCase();
    return _customers.where((c) {
      return c.name.toLowerCase().contains(q) ||
          c.email.toLowerCase().contains(q) ||
          c.phone.contains(q) ||
          (c.preferredDestination?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  void _showCustomerDetail(UserModel c) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: AppColors.mountainBlue,
                  child: Text(
                    c.name.split(' ').map((n) => n[0]).take(2).join(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(c.name, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.darkCharcoal)),
                      Text(c.email, style: const TextStyle(color: AppColors.slate, fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: AppColors.successLight, borderRadius: BorderRadius.circular(6)),
                  child: const Row(
                    children: [
                      Icon(Icons.verified_user, color: AppColors.success, size: 14),
                      SizedBox(width: 4),
                      Text('KYC Verified', style: TextStyle(color: AppColors.success, fontSize: 11, fontWeight: FontWeight.w700)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceMuted,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _infoRow('Phone Number', c.phone),
                  const Divider(color: AppColors.border, height: 16),
                  _infoRow('Preferred Destination', c.preferredDestination ?? 'Ladakh'),
                  const Divider(color: AppColors.border, height: 16),
                  _infoRow('Anthropometrics', '${c.heightCm?.toInt() ?? 175} cm • ${c.weightKg?.toInt() ?? 70} kg • Age ${c.age ?? 27}'),
                  const Divider(color: AppColors.border, height: 16),
                  _infoRow('AI Recommended Sizing', 'Jackets: L • Gloves: L • Boots: UK 9', isHighlighted: true),
                  const Divider(color: AppColors.border, height: 16),
                  _infoRow('Driving License & ID Proof', 'Verified (DL: JK02-2021-00892)'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(ctx),
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Close Profile'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {bool isHighlighted = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.slate)),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isHighlighted ? FontWeight.w800 : FontWeight.w600,
            color: isHighlighted ? AppColors.mountainBlueDark : AppColors.darkCharcoal,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header Bar
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rider & Customer Directory',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: AppColors.darkCharcoal,
                        letterSpacing: -0.5,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Verified rider profiles, anthropometric measurement history, and adventure records',
                      style: TextStyle(fontSize: 13, color: AppColors.slate),
                    ),
                  ],
                ),
              ),
            ),

            // Search Bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: 'Search rider by name, phone, email, or destination...',
                    prefixIcon: const Icon(Icons.search, color: AppColors.slate),
                    filled: true,
                    fillColor: AppColors.surface,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: AppColors.border),
                    ),
                  ),
                ),
              ),
            ),

            // Riders List
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final c = _filteredCustomers[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [AppTheme.softShadow],
                      ),
                      child: InkWell(
                        onTap: () => _showCustomerDetail(c),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: AppColors.mountainBlueLight,
                              child: Text(
                                c.name.split(' ').map((n) => n[0]).take(2).join(),
                                style: const TextStyle(
                                  color: AppColors.mountainBlue,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        c.name,
                                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.darkCharcoal),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(Icons.verified, size: 14, color: AppColors.mountainBlue),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${c.email} • ${c.phone}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.slate),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Height: ${c.heightCm?.toInt() ?? 175}cm | Weight: ${c.weightKg?.toInt() ?? 70}kg | Target: ${c.preferredDestination ?? 'Ladakh'}',
                                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.darkCharcoal),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.mountainBlueLight,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Rider',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mountainBlue),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.slate),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  childCount: _filteredCustomers.length,
                ),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 40)),
          ],
        ),
      ),
    );
  }
}
