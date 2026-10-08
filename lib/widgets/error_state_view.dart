import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Reusable Standardized Error State Component
/// Displays concise error information with retry functionality and 90/10 visual balance.
class ErrorStateView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  final String retryLabel;
  final IconData icon;

  const ErrorStateView({
    super.key,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Retry',
    this.icon = Icons.cloud_off_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.card,
                border: Border.all(
                  color: AppColors.brightRed.withValues(alpha: 0.4),
                  width: 1.2,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.redGlow,
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Icon(icon, color: AppColors.brightRed, size: 38),
            ),
            const SizedBox(height: 18),
            Text(
              message,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.secondaryText,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  LiveItHaptics.selection();
                  onRetry!();
                },
                icon: const Icon(
                  Icons.refresh_rounded,
                  size: 18,
                  color: Colors.white,
                ),
                label: Text(
                  retryLabel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brightRed,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 11,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
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
