import 'package:flutter/material.dart';
import 'home/home_screen.dart';
import 'favorites/favorites_screen.dart';
import 'my_listings/my_listings_screen.dart';
import 'profile/profile_screen.dart';
import '../../core/constants/app_colors.dart';

class MainScaffold extends StatefulWidget {
  final int initialIndex;
  
  const MainScaffold({Key? key, this.initialIndex = 0}) : super(key: key);

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  late int _currentIndex;

  final List<Widget> _screens = const [
    HomeScreen(),
    FavoritesScreen(),
    MyListingsScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          indicatorColor: AppColors.primary.withOpacity(0.15),
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.home_outlined, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              selectedIcon: const Icon(Icons.home, color: AppColors.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_outline, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              selectedIcon: const Icon(Icons.favorite, color: AppColors.primary),
              label: 'Favorites',
            ),
            NavigationDestination(
              icon: Icon(Icons.list_alt_outlined, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              selectedIcon: const Icon(Icons.list_alt, color: AppColors.primary),
              label: 'My Listings',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
              selectedIcon: const Icon(Icons.person, color: AppColors.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
