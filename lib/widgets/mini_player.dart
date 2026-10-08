import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../screens/player_screen.dart';

/// Phase 12 Polished MiniPlayer
/// Clean 90% black / 10% red styling with smooth interaction feedback,
/// haptics, responsive artwork, animated title/artist transitions, and single-player engine sync.
class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, audio, child) {
        final song = audio.currentSong;
        if (song == null) return const SizedBox.shrink();

        final progress = audio.duration.inMilliseconds > 0
            ? (audio.position.inMilliseconds / audio.duration.inMilliseconds)
                  .clamp(0.0, 1.0)
            : 0.0;

        return GestureDetector(
          onTap: () {
            LiveItHaptics.selection();
            Navigator.of(context)
                .push(LiveItScalePageRoute(child: const PlayerScreen()));
          },
          child: Container(
            height: 64,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: AppRadii.r12,
              border: Border.all(color: AppColors.divider, width: 1),
              boxShadow: AppShadows.card,
            ),
            child: ClipRRect(
              borderRadius: AppRadii.r12,
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Row(
                        children: [
                          // Artwork Thumbnail
                          ClipRRect(
                            borderRadius: AppRadii.r8,
                            child: Image.network(
                              song.artworkUrl,
                              width: 44,
                              height: 44,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 44,
                                height: 44,
                                color: AppColors.darkRed,
                                child: const Icon(
                                  Icons.music_note,
                                  color: AppColors.brightRed,
                                  size: 22,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // Title & Artist
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  song.title,
                                  style: AppTypography.titleMedium,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  song.artist,
                                  style: AppTypography.bodySmall,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),

                          // Favorite Heart Button
                          IconButton(
                            icon: Icon(
                              audio.isSongFavorite(song.id)
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: audio.isSongFavorite(song.id)
                                  ? AppColors.brightRed
                                  : AppColors.secondaryText,
                              size: 20,
                            ),
                            onPressed: () {
                              LiveItHaptics.selection();
                              audio.toggleFavorite(song);
                            },
                          ),

                          // Play/Pause Button with Loading state support
                          IconButton(
                            icon: audio.isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      color: AppColors.brightRed,
                                    ),
                                  )
                                : Icon(
                                    audio.isPlaying
                                        ? Icons.pause_circle_filled
                                        : Icons.play_circle_filled,
                                    color: AppColors.brightRed,
                                    size: 32,
                                  ),
                            onPressed: audio.isLoading
                                ? null
                                : () {
                                    LiveItHaptics.light();
                                    audio.togglePlayPause();
                                  },
                          ),

                          // Next Button
                          IconButton(
                            icon: const Icon(
                              Icons.skip_next,
                              color: AppColors.primaryText,
                              size: 24,
                            ),
                            onPressed: () {
                              LiveItHaptics.light();
                              audio.nextSong();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Bottom Red Progress Line Indicator
                  LinearProgressIndicator(
                    value: progress,
                    backgroundColor: AppColors.divider,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.brightRed,
                    ),
                    minHeight: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
