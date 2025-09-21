import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'emergency/home_screen.dart';
import 'family/family_screen.dart';
import 'guides/help_screen.dart';
import 'profile/settings_screen.dart';
import '../../language/language_controller.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<Widget> _screens = [
    HomeScreen(),
    FamilyScreen(),
    HelpScreen(),
    SettingsScreen(),
  ];

  // Navigation items with enhanced Material 3 icons
  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: Icons.emergency_outlined,
      selectedIcon: Icons.emergency,
      label: 'navbar_emergency',
      color: Colors.red[600]!,
    ),
    NavigationItem(
        icon: Icons.people_alt_outlined,
        selectedIcon: Icons.people_alt,
        label: 'navbar_family',
        color: Colors.teal[600]!
    ),
    NavigationItem(
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book,
      label: 'navbar_guides',
      color: Colors.blue[600]!,
    ),
    NavigationItem(
      icon: Icons.person_outline,
      selectedIcon: Icons.person,
      label: 'navbar_profile',
      color: Colors.green[600]!,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.forward();

    _initLocation();

  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  void _initLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) return;
    }

    // Start listening immediately
    Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // meters
      ),
    ).listen((Position position) {
      print('Warmup: ${position.latitude}, ${position.longitude}');
    });
  }

  void _onDestinationSelected(int index) {
    if (_currentIndex != index) {
      _animationController.reset();
      setState(() => _currentIndex = index);
      _animationController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onDestinationSelected,
          elevation: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shadowColor: Colors.transparent,
          indicatorColor: _navigationItems[_currentIndex].color.withOpacity(0.15),
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          height: 70,
          destinations: _navigationItems.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final isSelected = _currentIndex == index;

            return NavigationDestination(
              icon: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(isSelected ? 8 : 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? item.color.withOpacity(0.1)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isSelected ? item.selectedIcon : item.icon,
                  color: isSelected
                      ? item.color
                      : Colors.grey[600],
                  size: isSelected ? 26 : 26,
                ),
              ),
              selectedIcon: Container(
                padding: const EdgeInsets.all(8),

                child: Icon(
                  item.selectedIcon,
                  color: item.color,
                  size: 26,
                ),
              ),
              label: LanguageController.get(item.label),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final Color color;

  const NavigationItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.color,
  });
}