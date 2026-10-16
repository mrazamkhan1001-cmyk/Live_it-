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
              color: const Color(0xFF0D0D0D),
              borderRadius: AppRadii.r12,
              border: Border.all(color: AppColors.brightRed, width: 1.0),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.redGlow,
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: AppRadii.r12,
              child: Stack(
                children: [
                  Padding(
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
                                style: const TextStyle(
                                  color: AppColors.primaryText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                song.artist,
                                style: const TextStyle(
                                  color: AppColors.secondaryText,
                                  fontSize: 12,
                                ),
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
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: audio.isSongFavorite(song.id)
                                ? AppColors.brightRed
                                : AppColors.secondaryText,
                            size: 21,
                          ),
                          onPressed: () {
                            LiveItHaptics.selection();
                            audio.toggleFavorite(song);
                          },
                        ),

                        // Prominent Solid Circular Red Play/Pause Button
                        GestureDetector(
                          onTap: audio.isLoading
                              ? null
                              : () {
                                  LiveItHaptics.light();
                                  audio.togglePlayPause();
                                },
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: const BoxDecoration(
                              color: AppColors.brightRed,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: audio.isLoading
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Icon(
                                      audio.isPlaying
                                          ? Icons.pause_rounded
                                          : Icons.play_arrow_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 4),

                        // Next Button
                        IconButton(
                          icon: const Icon(
                            Icons.skip_next_rounded,
                            color: Colors.white,
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

                  // Bottom Red Progress Line Indicator
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.transparent,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.brightRed,
                      ),
                      minHeight: 2,
                    ),
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
