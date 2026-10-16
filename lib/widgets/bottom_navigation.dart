import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Phase 12 Polished CustomBottomNavigation
/// Clean, restrained 90% black / 10% red navigation bar with subtle active state highlight and haptic feedback.
class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.only(top: 8, bottom: 8),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(
              index: 0,
              icon: Icons.home_rounded,
              activeIcon: Icons.home_rounded,
              label: 'Home',
            ),
            _buildNavItem(
              index: 1,
              icon: Icons.search_rounded,
              activeIcon: Icons.search_rounded,
              label: 'Search',
            ),
            _buildNavItem(
              index: 2,
              icon: Icons.collections_bookmark_outlined,
              activeIcon: Icons.collections_bookmark_rounded,
              label: 'Library',
            ),
            _buildNavItem(
              index: 3,
              icon: Icons.person_outline_rounded,
              activeIcon: Icons.person_rounded,
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required IconData icon,
    required IconData activeIcon,
    required String label,
  }) {
    final isActive = currentIndex == index;

    return InkWell(
      onTap: () {
        if (!isActive) {
          LiveItHaptics.selection();
        }
        onTap(index);
      },
      borderRadius: AppRadii.r12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? activeIcon : icon,
              color: isActive ? AppColors.brightRed : AppColors.secondaryText,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.brightRed : AppColors.secondaryText,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isActive ? 14 : 0,
              height: 2,
              decoration: BoxDecoration(
                color: isActive ? AppColors.brightRed : Colors.transparent,
                borderRadius: BorderRadius.circular(1),
                boxShadow: isActive
                    ? const [
                        BoxShadow(
                          color: AppColors.redGlow,
                          blurRadius: 4,
                          spreadRadius: 0.5,
                        ),
                      ]
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
