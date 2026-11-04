import 'package:flutter/material.dart';
import '../../app/theme.dart';
import '../../services/auth_service.dart';
import '../../services/booking_service.dart';
import '../../widgets/user_avatar.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService().currentUser;
    final completedBookings = BookingService().completedBookings.length;
    final totalBookings = BookingService().allBookings.where((b) => b.userId == user?.id).length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My Profile'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () => _showEditProfile(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
                boxShadow: [AppTheme.softShadow],
              ),
              child: Row(
                children: [
                  UserAvatar(
                    user: user,
                    size: 76,
                    borderRadius: 22,
                    showBorder: true,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.name ?? 'Rider',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal)),
                        const SizedBox(height: 4),
                        Text(user?.email ?? '',
                            style: const TextStyle(fontSize: 13, color: AppColors.slate)),
                        const SizedBox(height: 4),
                        Text(user?.phone ?? '',
                            style: const TextStyle(fontSize: 13, color: AppColors.slate)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Stats Row
            Row(
              children: [
                Expanded(child: _StatMini('Total Bookings', '$totalBookings', Icons.receipt_long)),
                const SizedBox(width: 12),
                Expanded(child: _StatMini('Completed', '$completedBookings', Icons.check_circle_outline)),
                const SizedBox(width: 12),
                Expanded(child: _StatMini('Destination', user?.preferredDestination ?? 'Ladakh', Icons.location_on_outlined)),
              ],
            ),
            const SizedBox(height: 24),

            // Body Measurements
            if (user?.heightCm != null || user?.weightKg != null) ...[
              const Text('Body Measurements',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal)),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Expanded(child: _MeasureTile('Height', '${user?.heightCm?.toInt() ?? '--'} cm', Icons.height)),
                    Container(width: 1, height: 40, color: AppColors.border),
                    Expanded(child: _MeasureTile('Weight', '${user?.weightKg?.toInt() ?? '--'} kg', Icons.monitor_weight_outlined)),
                    Container(width: 1, height: 40, color: AppColors.border),
                    Expanded(child: _MeasureTile('Age', '${user?.age ?? '--'} yrs', Icons.cake_outlined)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Menu Items
            const Text('Account',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkCharcoal)),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _MenuTile(Icons.receipt_long_outlined, 'My Bookings', () {}),
                  const Divider(height: 1, indent: 56),
                  _MenuTile(Icons.bookmark_outline, 'Saved Gear', () {}),
                  const Divider(height: 1, indent: 56),
                  _MenuTile(Icons.smart_toy_outlined, 'AI Recommendation History', () {}),
                  const Divider(height: 1, indent: 56),
                  _MenuTile(Icons.settings_outlined, 'Settings', () {}),
                  const Divider(height: 1, indent: 56),
                  _MenuTile(Icons.help_outline, 'Help & Support', () {}),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Logout
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => _logout(context),
                icon: const Icon(Icons.logout, color: AppColors.error),
                label: const Text('Logout', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.error),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  void _logout(BuildContext context) {
    AuthService().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showEditProfile(BuildContext context) {
    final user = AuthService().currentUser;
    final nameCtrl = TextEditingController(text: user?.name);
    final phoneCtrl = TextEditingController(text: user?.phone);
    final heightCtrl = TextEditingController(text: user?.heightCm?.toInt().toString());
    final weightCtrl = TextEditingController(text: user?.weightKg?.toInt().toString());
    final ageCtrl = TextEditingController(text: user?.age?.toString());

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Edit Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal)),
              const SizedBox(height: 20),
              TextField(controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline))),
              const SizedBox(height: 12),
              TextField(controller: phoneCtrl,
                  decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone_outlined))),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: TextField(controller: heightCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Height (cm)'))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: weightCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Weight (kg)'))),
                  const SizedBox(width: 10),
                  Expanded(child: TextField(controller: ageCtrl,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Age'))),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    AuthService().updateProfile(
                      name: nameCtrl.text,
                      phone: phoneCtrl.text,
                      heightCm: double.tryParse(heightCtrl.text),
                      weightKg: double.tryParse(weightCtrl.text),
                      age: int.tryParse(ageCtrl.text),
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('Save Changes'),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatMini extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatMini(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.mountainBlue, size: 22),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppColors.slate),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _MeasureTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MeasureTile(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18, color: AppColors.mountainBlue),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.darkCharcoal)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.slate)),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _MenuTile(this.icon, this.label, this.onTap);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.mountainBlue, size: 22),
      title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.darkCharcoal)),
      trailing: const Icon(Icons.chevron_right, color: AppColors.slate, size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
    );
  }
}
