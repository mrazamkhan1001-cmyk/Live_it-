import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/song_card.dart';
import 'song_details_screen.dart';

/// Favorites / Liked Songs Screen matching Section 18
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, audio, child) {
        final favorites = audio.favorites;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Liked Songs'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: favorites.isEmpty
                ? const Center(
                    child: Text(
                      'No liked songs yet.',
                      style: TextStyle(color: AppColors.secondaryText, fontSize: 14),
                    ),
                  )
                : Column(
                    children: [
                      // Header Play All & Shuffle Buttons Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                if (favorites.isNotEmpty) audio.playSong(favorites.first, queueList: favorites);
                              },
                              icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                              label: const Text('Play All', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.brightRed,
                                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: () => audio.toggleShuffle(),
                              icon: const Icon(Icons.shuffle, color: AppColors.primaryText, size: 18),
                              label: const Text('Shuffle', style: TextStyle(color: AppColors.primaryText)),
                              style: OutlinedButton.styleFrom(
                                backgroundColor: AppColors.card,
                                side: const BorderSide(color: AppColors.divider),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Songs List
                      Expanded(
                        child: ListView.builder(
                          itemCount: favorites.length,
                          itemBuilder: (context, index) {
                            final song = favorites[index];
                            final isCurrent = audio.currentSong?.id == song.id;

                            return SongTile(
                              song: song,
                              isCurrent: isCurrent,
                              isPlaying: isCurrent && audio.isPlaying,
                              onTap: () => audio.playSong(song, queueList: favorites, index: index),
                              onMoreTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(builder: (_) => SongDetailsScreen(song: song)),
                                );
                              },
                              onFavoriteTap: () => audio.toggleFavorite(song),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
