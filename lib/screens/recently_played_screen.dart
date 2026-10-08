import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/song_card.dart';
import '../widgets/empty_state_view.dart';

/// Phase 12 Polished Recently Played Screen
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
                ? EmptyStateView(
                    icon: Icons.history_rounded,
                    title: 'Nothing Played Yet',
                    description: 'Songs you stream and play will automatically appear in your listening history.',
                    actionLabel: 'EXPLORE MUSIC',
                    actionIcon: Icons.explore_outlined,
                    onAction: () => Navigator.of(context).pop(),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    itemCount: recentSongs.length,
                    itemBuilder: (context, index) {
                      final song = recentSongs[index];
                      final isCurrent = audio.currentSong?.id == song.id;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: SongTile(
                          song: song,
                          isCurrent: isCurrent,
                          isPlaying: isCurrent && audio.isPlaying,
                          onTap: () => audio.playSong(
                            song,
                            queueList: recentSongs,
                            index: index,
                          ),
                          onFavoriteTap: () => audio.toggleFavorite(song),
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
