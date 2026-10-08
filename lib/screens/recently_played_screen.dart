import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/song_card.dart';

/// Recently Played Screen
class RecentlyPlayedScreen extends StatelessWidget {
  const RecentlyPlayedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, audio, child) {
        final recentSongs = audio.recentlyPlayed;

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            title: const Text(
              'Recently Played',
              style: TextStyle(
                color: AppColors.primaryText,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: AppColors.background,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          body: SafeArea(
            child: recentSongs.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history_rounded, color: AppColors.brightRed, size: 60),
                        SizedBox(height: 16),
                        Text(
                          'Nothing played yet',
                          style: TextStyle(color: AppColors.primaryText, fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 6),
                        Text(
                          'Songs you play will appear here.',
                          style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: recentSongs.length,
                    itemBuilder: (context, index) {
                      final song = recentSongs[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SongTile(
                          song: song,
                          onTap: () => audio.playSong(song, queueList: recentSongs, index: index),
                        ),
                      );
                    },
                  ),
          ),
        );
      },
    );
  }
}
