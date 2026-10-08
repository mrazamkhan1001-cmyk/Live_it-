import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/song_card.dart';

/// Downloads Screen matching Section 19
class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, audio, child) {
        final downloadedSongs = audio.queue.where((s) => s.isDownloaded).toList();

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text('Downloads'),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: downloadedSongs.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download_done_rounded, color: AppColors.brightRed, size: 60),
                        SizedBox(height: 16),
                        Text(
                          'No downloaded tracks',
                          style: TextStyle(color: AppColors.primaryText, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Downloaded music for offline playback will appear here.',
                          style: TextStyle(color: AppColors.secondaryText, fontSize: 12),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(top: 12),
                    itemCount: downloadedSongs.length,
                    itemBuilder: (context, index) {
                      final song = downloadedSongs[index];
                      final isCurrent = audio.currentSong?.id == song.id;

                      return SongTile(
                        song: song,
                        isCurrent: isCurrent,
                        isPlaying: isCurrent && audio.isPlaying,
                        onTap: () => audio.playSong(song, queueList: downloadedSongs, index: index),
                        onFavoriteTap: () => audio.toggleFavorite(song),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
