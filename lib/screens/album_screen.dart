import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/song_card.dart';
import 'song_details_screen.dart';

/// Album Screen matching Section 11 & Mockup #6
class AlbumScreen extends StatelessWidget {
  final String albumTitle;
  final String artistName;

  const AlbumScreen({
    super.key,
    this.albumTitle = 'Arcane (Soundtrack)',
    this.artistName = 'Various Artists',
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, audio, child) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  // Large Album Artwork matching Mockup #6
                  Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.brightRed, width: 1.5),
                      boxShadow: const [
                        BoxShadow(color: AppColors.redGlow, blurRadius: 20, spreadRadius: 2),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(
                        'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=500',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Album Title & Artist info
                  Text(
                    albumTitle,
                    style: const TextStyle(
                      color: AppColors.primaryText,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$artistName • 2021 • ${audio.queue.length} songs',
                    style: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Action Buttons Row (Play & Shuffle) matching Mockup #6
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Red Play Button
                      ElevatedButton.icon(
                        onPressed: () {
                          if (audio.queue.isNotEmpty) audio.playSong(audio.queue.first);
                        },
                        icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                        label: const Text('Play', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brightRed,
                          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Shuffle Button
                      OutlinedButton.icon(
                        onPressed: () {
                          audio.toggleShuffle();
                        },
                        icon: const Icon(Icons.shuffle, color: AppColors.primaryText, size: 18),
                        label: const Text('Shuffle', style: TextStyle(color: AppColors.primaryText)),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.card,
                          side: const BorderSide(color: AppColors.divider),
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Track list
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: audio.queue.length,
                    itemBuilder: (context, index) {
                      final song = audio.queue[index];
                      final isCurrent = audio.currentSong?.id == song.id;

                      return SongTile(
                        song: song,
                        isCurrent: isCurrent,
                        isPlaying: isCurrent && audio.isPlaying,
                        onTap: () => audio.playSong(song, index: index),
                        onMoreTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => SongDetailsScreen(song: song)),
                          );
                        },
                        onFavoriteTap: () => audio.toggleFavorite(song),
                      );
                    },
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
