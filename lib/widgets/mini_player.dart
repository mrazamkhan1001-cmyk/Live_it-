import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../screens/player_screen.dart';

class MiniPlayer extends StatelessWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, audio, child) {
        final song = audio.currentSong;
        if (song == null) return const SizedBox.shrink();

        final progress = audio.duration.inMilliseconds > 0
            ? (audio.position.inMilliseconds / audio.duration.inMilliseconds).clamp(0.0, 1.0)
            : 0.0;

        return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const PlayerScreen(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(animation),
                    child: child,
                  );
                },
              ),
            );
          },
          child: Container(
            height: 64,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.card,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black54,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        // Artwork Thumbnail
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            song.artworkUrl,
                            width: 44,
                            height: 44,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 44,
                              height: 44,
                              color: AppColors.darkRed,
                              child: const Icon(Icons.music_note, color: AppColors.brightRed),
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
                                  fontWeight: FontWeight.bold,
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
                            audio.isSongFavorite(song.id) ? Icons.favorite : Icons.favorite_border,
                            color: audio.isSongFavorite(song.id) ? AppColors.brightRed : AppColors.secondaryText,
                            size: 20,
                          ),
                          onPressed: () => audio.toggleFavorite(song),
                        ),

                        // Play/Pause Button
                        IconButton(
                          icon: Icon(
                            audio.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                            color: AppColors.brightRed,
                            size: 32,
                          ),
                          onPressed: () => audio.togglePlayPause(),
                        ),

                        // Next Button
                        IconButton(
                          icon: const Icon(
                            Icons.skip_next,
                            color: AppColors.primaryText,
                            size: 24,
                          ),
                          onPressed: () => audio.nextSong(),
                        ),
                      ],
                    ),
                  ),
                ),

                // Top Red Progress Line Indicator
                LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.divider,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.brightRed),
                  minHeight: 2,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
