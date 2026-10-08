import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/mini_player.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'library_screen.dart';
import 'profile_screen.dart';

/// Root Application Shell containing the 4 primary tabs,
/// persistent MiniPlayer, and shared BottomNavigation.
class MainShellScreen extends StatefulWidget {
  final int initialIndex;

  const MainShellScreen({super.key, this.initialIndex = 0});

  /// Allows child widgets to request tab switching through context
  static void navigateToTab(BuildContext context, int index) {
    final state = context.findAncestorStateOfType<_MainShellScreenState>();
    state?.switchTab(index);
  }

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void switchTab(int index) {
    if (index >= 0 && index < 4 && _currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(onNavigateToTab: switchTab),
          SearchScreen(onNavigateToTab: switchTab),
          LibraryScreen(onNavigateToTab: switchTab),
          ProfileScreen(onNavigateToTab: switchTab),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const MiniPlayer(),
          CustomBottomNavigation(currentIndex: _currentIndex, onTap: switchTab),
        ],
      ),
    );
  }
}
