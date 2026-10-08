import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/playlist.dart';
import '../services/audio_service.dart';
import '../theme/app_theme.dart';
import '../widgets/song_card.dart';
import '../widgets/mini_player.dart';
import 'song_details_screen.dart';

/// Playlist Screen matching Section 6 & Master Prompt specifications
class PlaylistScreen extends StatelessWidget {
  final Playlist? playlist;
  final String playlistTitle;

  const PlaylistScreen({
    super.key,
    this.playlist,
    this.playlistTitle = 'Uchiha Vibes',
  });

  @override
  Widget build(BuildContext context) {
    final title = playlist?.title ?? playlistTitle;
    final cover = playlist?.coverUrl ?? 'https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=1000';
    final desc = playlist?.description ?? 'Songs for the ones who understand...';

    return Consumer<AudioPlayerService>(
      builder: (context, audio, child) {
        final songs = playlist?.songs ?? [];

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            top: false,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header Artwork Banner
                        Stack(
                          children: [
                            Container(
                              height: 240,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(cover),
                                  fit: BoxFit.cover,
                                  colorFilter: const ColorFilter.mode(Colors.black45, BlendMode.darken),
                                ),
                              ),
                            ),
                            Container(
                              height: 240,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Colors.transparent, AppColors.background],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                            ),
                            SafeArea(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back, color: AppColors.primaryText),
                                  onPressed: () => Navigator.of(context).pop(),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 20,
                              left: 20,
                              right: 20,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      color: AppColors.primaryText,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'By Azam Khan • ${songs.length} songs',
                                    style: const TextStyle(color: AppColors.secondaryText, fontSize: 13),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    desc,
                                    style: const TextStyle(color: AppColors.secondaryText, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        // Action Buttons Row (Play & Shuffle)
                        if (songs.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            child: Row(
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    if (songs.isNotEmpty) audio.playSong(songs.first, queueList: songs, index: 0);
                                  },
                                  icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                                  label: const Text('PLAY', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.brightRed,
                                    padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton.icon(
                                  onPressed: () => audio.toggleShuffle(),
                                  icon: const Icon(Icons.shuffle, color: AppColors.primaryText, size: 18),
                                  label: const Text('SHUFFLE', style: TextStyle(color: AppColors.primaryText, fontWeight: FontWeight.bold)),
                                  style: OutlinedButton.styleFrom(
                                    backgroundColor: AppColors.card,
                                    side: const BorderSide(color: AppColors.divider),
                                    padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 10),

                        // Track List or Empty State
                        songs.isEmpty
                            ? const Padding(
                                padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                                child: Center(
                                  child: Column(
                                    children: [
                                      Icon(Icons.queue_music_rounded, color: AppColors.brightRed, size: 54),
                                      SizedBox(height: 12),
                                      Text(
                                        'No songs in this playlist yet',
                                        style: TextStyle(color: AppColors.primaryText, fontSize: 16, fontWeight: FontWeight.bold),
                                      ),
                                      SizedBox(height: 6),
                                      Text(
                                        'Add tracks to build your custom playlist.',
                                        style: TextStyle(color: AppColors.secondaryText, fontSize: 13),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: songs.length,
                                itemBuilder: (context, index) {
                                  final song = songs[index];
                                  final isCurrent = audio.currentSong?.id == song.id;

                                  return SongTile(
                                    song: song,
                                    indexNumber: index + 1,
                                    isCurrent: isCurrent,
                                    isPlaying: isCurrent && audio.isPlaying,
                                    onTap: () => audio.playSong(song, queueList: songs, index: index),
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

                // Mini Player
                const MiniPlayer(),
              ],
            ),
          ),
        );
      },
    );
  }
}
