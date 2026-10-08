import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Reusable Standardized Empty State Component
/// Follows strict 90% black / 10% red visual design language.
class EmptyStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData? actionIcon;

  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Glowing circular icon badge
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.card,
                border: Border.all(
                  color: AppColors.brightRed.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.redGlow,
                    blurRadius: 18,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(icon, color: AppColors.brightRed, size: 42),
            ),
            const SizedBox(height: 22),

            // Title
            Text(
              title,
              style: AppTypography.headingMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),

            // Description
            Text(
              description,
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(height: 1.45),
            ),

            // Optional Action Button
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 26),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brightRed,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(22),
                  ),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                ),
                onPressed: () {
                  LiveItHaptics.selection();
                  onAction!();
                },
                icon: Icon(actionIcon ?? Icons.explore_outlined, size: 18),
                label: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.0,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
