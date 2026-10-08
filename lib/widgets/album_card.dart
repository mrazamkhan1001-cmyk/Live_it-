import 'package:flutter/material.dart';

import '../models/album.dart';
import '../theme/app_theme.dart';

/// Phase 12 Polished AlbumCard Component
/// Standard 140x140 size with rounded 12px corners, subtle border,
/// restrained shadow, and clean typography.
class AlbumCard extends StatelessWidget {
  final Album album;
  final VoidCallback onTap;

  const AlbumCard({super.key, required this.album, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        LiveItHaptics.light();
        onTap();
      },
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: AppRadii.r12,
                border: Border.all(color: AppColors.divider, width: 1),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.redGlow,
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Image.network(
                  album.coverUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.card,
                    child: const Icon(
                      Icons.album,
                      color: AppColors.brightRed,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              album.title,
              style: AppTypography.titleMedium,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              '${album.artist} • ${album.year}',
              style: AppTypography.bodySmall,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
