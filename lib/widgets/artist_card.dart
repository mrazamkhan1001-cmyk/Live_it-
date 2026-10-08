import 'package:flutter/material.dart';
import '../models/artist.dart';
import '../theme/app_theme.dart';

class ArtistCard extends StatelessWidget {
  final Artist artist;
  final VoidCallback onTap;

  const ArtistCard({
    super.key,
    required this.artist,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
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
                border: Border.all(color: AppColors.brightRed, width: 1.5),
              ),
              child: ClipOval(
                child: Image.network(
                  artist.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: AppColors.card,
                    child: const Icon(Icons.person, color: AppColors.brightRed, size: 40),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              artist.name,
              style: const TextStyle(
                color: AppColors.primaryText,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
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
