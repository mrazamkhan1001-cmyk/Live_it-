import 'package:flutter/material.dart';
import '../models/song.dart';
import '../theme/app_theme.dart';

class SongTile extends StatelessWidget {
  final Song song;
  final bool isCurrent;
  final bool isPlaying;
  final int? indexNumber;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;
  final VoidCallback? onMoreTap;

  const SongTile({
    super.key,
    required this.song,
    this.isCurrent = false,
    this.isPlaying = false,
    this.indexNumber,
    required this.onTap,
    this.onFavoriteTap,
    this.onMoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (indexNumber != null) ...[
            SizedBox(
              width: 22,
              child: Text(
                '$indexNumber',
                style: const TextStyle(
                  color: AppColors.primaryText,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Stack(
            alignment: Alignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  song.artworkUrl,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 48,
                    height: 48,
                    color: AppColors.card,
                    child: const Icon(Icons.music_note, color: AppColors.brightRed),
                  ),
                ),
              ),
              if (isCurrent)
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isPlaying ? Icons.equalizer : Icons.play_arrow,
                    color: AppColors.brightRed,
                    size: 26,
                  ),
                ),
            ],
          ),
        ],
      ),
      title: Text(
        song.title,
        style: TextStyle(
          color: isCurrent ? AppColors.brightRed : AppColors.primaryText,
          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
          fontSize: 15,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artist,
        style: const TextStyle(
          color: AppColors.secondaryText,
          fontSize: 13,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (onFavoriteTap != null)
            IconButton(
              icon: Icon(
                song.isFavorite ? Icons.favorite : Icons.favorite_border,
                color: song.isFavorite ? AppColors.brightRed : AppColors.secondaryText,
                size: 20,
              ),
              onPressed: onFavoriteTap,
            ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppColors.secondaryText, size: 20),
            onPressed: onMoreTap,
          ),
        ],
      ),
    );
  }
}
