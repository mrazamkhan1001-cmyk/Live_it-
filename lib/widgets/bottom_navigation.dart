import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

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
        color: Color(0xFF050505),
        border: Border(
          top: BorderSide(
            color: Color(0xFF1E1E1E),
            width: 1,
          ),
        ),
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
            icon: Icons.music_note_rounded,
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
      onTap: () => onTap(index),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isActive)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF280006),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.brightRed, width: 1.2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x66FF1018),
                      blurRadius: 8,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: Icon(
                  activeIcon,
                  color: AppColors.brightRed,
                  size: 20,
                ),
              )
            else
              Icon(
                icon,
                color: const Color(0xFF8E8E93),
                size: 22,
              ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.brightRed : const Color(0xFF8E8E93),
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
