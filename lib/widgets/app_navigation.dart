import 'package:flutter/material.dart';
import '../app/theme.dart';
import '../services/auth_service.dart';
import '../screens/user/home_screen.dart';
import '../screens/user/gear_screen.dart';
import '../screens/user/trip_screen.dart';
import '../screens/user/bookings_screen.dart';
import '../screens/user/profile_screen.dart';
import '../screens/admin/admin_dashboard.dart';
import '../screens/admin/inventory_screen.dart';
import '../screens/admin/bookings_management.dart';
import '../screens/admin/demand_prediction.dart';
import '../screens/admin/pricing_screen.dart';
import '../screens/admin/analytics_screen.dart';
import '../screens/admin/customers_screen.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/user_avatar.dart';

class AppNavigation extends StatefulWidget {
  const AppNavigation({super.key});

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation> {
  int _selectedIndex = 0;

  final List<_NavItem> _userNavItems = const [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home'),
    _NavItem(icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2, label: 'Gear'),
    _NavItem(icon: Icons.map_outlined, activeIcon: Icons.map, label: 'Trips'),
    _NavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: 'Bookings'),
    _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, label: 'Profile'),
  ];

  final List<_NavItem> _adminNavItems = const [
    _NavItem(icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, label: 'Dashboard'),
    _NavItem(icon: Icons.inventory_2_outlined, activeIcon: Icons.inventory_2, label: 'Inventory'),
    _NavItem(icon: Icons.receipt_long_outlined, activeIcon: Icons.receipt_long, label: 'Bookings'),
    _NavItem(icon: Icons.auto_graph_outlined, activeIcon: Icons.auto_graph, label: 'Demand'),
    _NavItem(icon: Icons.analytics_outlined, activeIcon: Icons.analytics, label: 'Analytics'),
    _NavItem(icon: Icons.sell_outlined, activeIcon: Icons.sell, label: 'Pricing'),
    _NavItem(icon: Icons.group_outlined, activeIcon: Icons.group, label: 'Customers'),
  ];

  List<Widget> get _userScreens => [
    const HomeScreen(),
    const GearScreen(),
    const TripScreen(),
    const BookingsScreen(),
    const ProfileScreen(),
  ];

  List<Widget> get _adminScreens => [
    const AdminDashboard(),
    const InventoryScreen(),
    const BookingsManagement(),
    const DemandPrediction(),
    const AnalyticsScreen(),
    const PricingScreen(),
    const CustomersScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final isAdmin = authService.isAdmin;
    final navItems = isAdmin ? _adminNavItems : _userNavItems;
    final screens = isAdmin ? _adminScreens : _userScreens;

    // Clamp index whenever mode changes
    if (_selectedIndex >= screens.length) _selectedIndex = 0;

    return ResponsiveLayout(
      mobile: _MobileNav(
        selectedIndex: _selectedIndex,
        navItems: navItems,
        screens: screens,
        onTap: (i) => setState(() => _selectedIndex = i),
      ),
      desktop: _DesktopNav(
        selectedIndex: _selectedIndex,
        navItems: navItems,
        screens: screens,
        onTap: (i) => setState(() => _selectedIndex = i),
        isAdmin: isAdmin,
      ),
    );
  }
}

// ── Mobile Bottom Nav ──────────────────────────────────────────────────────
class _MobileNav extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItem> navItems;
  final List<Widget> screens;
  final ValueChanged<int> onTap;

  const _MobileNav({
    required this.selectedIndex,
    required this.navItems,
    required this.screens,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _AnimatedTabSwitcher(selectedIndex: selectedIndex, screens: screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          border: const Border(top: BorderSide(color: AppColors.border)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            height: 64,
            child: Row(
              children: List.generate(navItems.length, (i) {
                final item = navItems[i];
                final selected = i == selectedIndex;
                return Expanded(
                  child: InkWell(
                    onTap: () => onTap(i),
                    splashColor: AppColors.mountainBlue.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeInOut,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: selected ? 36 : 0,
                            height: 3,
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: AppColors.mountainBlue,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          Icon(
                            selected ? item.activeIcon : item.icon,
                            size: 22,
                            color: selected ? AppColors.mountainBlue : AppColors.slate,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                              color: selected ? AppColors.mountainBlue : AppColors.slate,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Animated Tab Switcher ────────────────────────────────────────────────────
class _AnimatedTabSwitcher extends StatefulWidget {
  final int selectedIndex;
  final List<Widget> screens;
  const _AnimatedTabSwitcher({required this.selectedIndex, required this.screens});

  @override
  State<_AnimatedTabSwitcher> createState() => _AnimatedTabSwitcherState();
}

class _AnimatedTabSwitcherState extends State<_AnimatedTabSwitcher> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: List.generate(widget.screens.length, (i) {
        final isCurrent = i == widget.selectedIndex;
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 220),
          opacity: isCurrent ? 1.0 : 0.0,
          curve: Curves.easeInOut,
          child: IgnorePointer(
            ignoring: !isCurrent,
            child: widget.screens[i],
          ),
        );
      }),
    );
  }
}

// ── Desktop Sidebar Nav ──────────────────────────────────────────────────
class _DesktopNav extends StatelessWidget {
  final int selectedIndex;
  final List<_NavItem> navItems;
  final List<Widget> screens;
  final ValueChanged<int> onTap;
  final bool isAdmin;

  const _DesktopNav({
    required this.selectedIndex,
    required this.navItems,
    required this.screens,
    required this.onTap,
    required this.isAdmin,
  });

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    return Scaffold(
      body: Row(
        children: [
          // Sidebar
          Container(
            width: 240,
            color: AppColors.darkCharcoal,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.fromLTRB(20, 32, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: AppColors.mountainBlue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Transform.flip(
                              flipX: true,
                              child: const Icon(Icons.sports_motorsports, color: Colors.white, size: 20),
                            ),
                          ),
                          const SizedBox(width: 10),
                          RichText(
                            text: const TextSpan(
                              style: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                              children: [
                                TextSpan(text: 'Smart ', style: TextStyle(color: Colors.white)),
                                TextSpan(text: 'Gear', style: TextStyle(color: AppColors.mountainBlueLight)),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isAdmin ? AppColors.warning.withValues(alpha: 0.15) : AppColors.mountainBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isAdmin ? 'Admin Dashboard' : 'Rider Portal',
                          style: TextStyle(
                            color: isAdmin ? AppColors.warning : AppColors.mountainBlueLight,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const Divider(color: Colors.white12, height: 1),

                // Nav items
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    itemCount: navItems.length,
                    itemBuilder: (context, i) {
                      final item = navItems[i];
                      final selected = i == selectedIndex;
                      return Container(
                        margin: const EdgeInsets.only(bottom: 4),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.mountainBlue : Colors.transparent,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: ListTile(
                          leading: Icon(
                            selected ? item.activeIcon : item.icon,
                            color: selected ? Colors.white : Colors.white54,
                            size: 20,
                          ),
                          title: Text(
                            item.label,
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.white70,
                              fontSize: 14,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                          onTap: () => onTap(i),
                          dense: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      );
                    },
                  ),
                ),

                const Divider(color: Colors.white12, height: 1),

                // Bottom: User info + logout (admin gets switch-to-rider)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (isAdmin) ...[
                        InkWell(
                          onTap: () {
                            authService.logout();
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.06),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.person, color: Colors.white60, size: 18),
                                SizedBox(width: 10),
                                Text(
                                  'Exit Admin Mode',
                                  style: TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                      Row(
                        children: [
                          UserAvatar(user: authService.currentUser, size: 36, borderRadius: 10),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  authService.currentUser?.name.split(' ').first ?? 'Rider',
                                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  authService.currentUser?.email ?? '',
                                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(child: IndexedStack(index: selectedIndex, children: screens)),
        ],
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}
