import 'package:flutter/material.dart';

import '../models/artist.dart';
import '../theme/app_theme.dart';

/// Phase 12 Polished ArtistCard Component
/// 90px circular avatar with subtle red accent border, smooth clipping, and centered label.
class ArtistCard extends StatelessWidget {
  final Artist artist;
  final VoidCallback onTap;

  const ArtistCard({super.key, required this.artist, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        LiveItHaptics.light();
        onTap();
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 14),
        child: Column(
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.brightRed.withValues(alpha: 0.8),
                  width: 1.3,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.redGlow,
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  artist.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.card,
                    child: const Icon(
                      Icons.person,
                      color: AppColors.brightRed,
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              artist.name,
              style: AppTypography.titleMedium.copyWith(fontSize: 13),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
