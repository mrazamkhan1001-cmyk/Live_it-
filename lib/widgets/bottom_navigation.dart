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
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider, width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            index: 0,
            icon: Icons.home_outlined,
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
            icon: Icons.music_note_outlined,
            activeIcon: Icons.music_note_rounded,
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
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F0507),
                  borderRadius: AppRadii.r8,
                  border: Border.all(
                    color: AppColors.brightRed.withValues(alpha: 0.6),
                    width: 1.0,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: AppColors.redGlow,
                      blurRadius: 6,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(activeIcon, color: AppColors.brightRed, size: 20),
              )
            else
              Icon(icon, color: AppColors.secondaryText, size: 22),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.brightRed : AppColors.secondaryText,
                fontSize: 11,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
